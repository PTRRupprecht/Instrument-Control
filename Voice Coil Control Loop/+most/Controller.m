classdef Controller < most.DClass
    %CONTROLLER View controller for one or more GUI figures
    
    % Controller responsibilities:
    %   * Provides general mechanisms for model->view and view->model updates
    %   * Maintains metadata binding model properties, including pass-through properties, to GUI/view elements (controls & PropControls)
    %   * Also allows callbacks to be bound to model properties, e.g. for more complex GUI update logic
    %   * Manages figure handles for view -- i.e. launches the GUI windows
    %   * Manages figure handles created by the model (typically graphs/displays) -- i.e. controller handles figure location handling for both controller- and model-generated figure handles
    %   
    % Implementation details: 
    %   * On construction, Controller stores to UserData of each bound control either Tag of uicontrol or handle to PropControl
    %   
    %
    % Model->View update notes:
    %   * updateView() method iterates over uicontrols & PropControls bound to particular property, updating to match model
    %   * updateView() is configured as post-set listener for each of the properties identified with one or more GUI control elements
    %   * Thus...updateView() method is typically not called directly.
    %   * updateView() handles uicontrol updates directly; each PropControl updates each of its constituent handles
    %   * For pass-through PDEP properties, idea is to listen to the (planned) PDEP 'set success' event instead of property directly, so that property set occurs /before/ model update.
    %       (Should probably use this straightforward plan to start; can do more complex plan allowing GUI update and reversion on failure if needed/desired later)
    %
    % View->Model update notes:
    %   * For both uicontrols & PropControls, callbacks are always updateModel(handles.hController,hObject,eventdata,handles)
    %   * In all cases, after decode -- proceed to set the property (determined either from UserData directly or from PropControl data)
    %   * Relies passively on reversion mechanism -- if error occurs during the property setting, the model should get reverted and the model->view mechanism in place should restore view
    %
    %   * For uicontrols:
    %        * No PropControl data found
    %        * Similar to ScanImage, switch on uicontrol Type and use property metadata to do type coercion if needed
    %
    %   * For PropControl (zoom case):
    %       * PropControl data includes map/structure of handles to digits
    %       * Computes new zoom value (might just read all values) and possibly updates the other controls up front to reflect new value
    %       * Might use the Min/Max metadata (or perhaps rely on reversion mechanism)
    %
    %   * For PropControl (uitable/column array case):
    %       * PropControl data includes map of columns to prop names
    %       * From eventdata, identify edited column & hence edited prop name
    %       * Updates array value & sets property to new array value
    %
    %   * For PropControl (property table case):
    %       * PropControl data includes array of row number to prop name (computed from map of prop name to row name)
    %       * From evendata, identify edited row & hence edited prop name
    %       * Probably use hModel validation data to check entered data & do coercion etc.
    %
    % Initialization notes:
    %   * Controller constructor: UIControl/PropControl initialization
    %   (options for pull-down menus, PropControl.init calls)
    %   * Controller.initialize: initialize GUIs based on model state
    %
    % TODO:
    %   * Add PropControl metadata..can automatically bind appropriate listeners to identified properties , e.g. a listener that does PropControl resize to a model property reflecting size of array variables represented by that PropControl
    %   * Restore implementation of the structure-wide replacement of 'app:<propName>' with linkage to that property of hModel
    %   * For listeners, provide mechanism for global disable to allow setting of properties without linkage to view/GUI
    %   * Think about whether properties with Callback identified should use the standard (src,evnt) arguments or not?? (currently it does)
	%   * Consider more ways to handle systematically (rather than one-off) various forms of representing array-valued properties ... e.g. array of cloned controls, single set of controls with index determined by drop-down list, etc etc
    %   * Factor out core updateModel() logic to allow it to be used as a method call in contexts other than directly as a GUIDE callback, e.g. in Controller subclass methods
	
    %% ABSTRACT PROPERTIES
    properties (Abstract, SetAccess=protected)
        
        %TODO: Perhaps the 'UpdateViewEvents' categories pertain to 'Callback' bindings as well? In this case, 'none' option woudl likely be a separate 'Defer' tag.
        %TODO: Should we be using PreSet in some/all cases? At moment, errors in dependency section of a set-access method will lead to view/model mismatch. Maybe not worth fixing (we should fix all bugs where errors occur! exception might be device errors, which we can't fully control).
        %
        %propBindings fields:
        %   * GuiIDs: String cell array of 'parent-child' pairs comprising:
        %       1) (parent) a Tag identifying a gui name, i.e. one of the guiNames and
        %       2) (child) a Tag identifying either a uicontrol or a most.gui.control.PropControl object
        %   * Callback: A (concrete controller) method name to bind as listener to PostSet event for specified property
        %   * PrettyOptions: String cell array of option strings corresponding one-to-one to model property 'options' list
        %   * PropControlData: <OPTIONAL> Data to store with PropControl handle -- used to initialize the PropControl object
        %   * (UNDER DEV, DO NOT USE) UpdateViewEvents: One of {'set' 'get'}.
        %       'set': Update view on all PostSet events for specified property (property should be SetObservable)
        %       'get': Update view on all PostGet events for specified property (property should be GetObservable)
        %
        %   NOTE: All properties with bindings must be SetObservable in the Model.
        %
        propBindings; %Structure of property bindings, with one field per property that has bound GUI control(s)
    end
    
    %% VISIBLE PROPERTIES
    
    %%%Constructor Initialized%%%%%
    properties (SetAccess=private)
        hModel;
        guiNames;
        hGUIsArray; %Array (flat) of all handles to GUI-containing figures 'controlled' by this instance
        hGUIs; %Struture effecting Map of guiNames to handles of GUI figures
        hGUIData; % Structure containing guiData for all guis in hGUIs. eg hGUIData.(guiName).(tagName)
        
        hGUIBindingPostSetListeners = struct(); %struct from prop names -> set listener objs for GUI bindings (uicontrol/PropControl)
        hCallbackPostSetListeners = struct(); % struct from prop names -> set listener objs for custom callback bindings 

        prop2ControlStruct; %struct from propName to cell array of control handles (uicontrols or PropControls)
        prop2CallbackStruct; %struct from propName to custom callback method
        
        hAuxGUIs; %Auxiliary GUIs registered by external sources
        guiLayoutInfo; % struct from Tag to struct with fields 'Position' and 'Visibility'        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties
        robotMode = false; %Logical true indicating that model changes may happen at a higher rate than would be expected by a human operator
    end
    
    properties (Dependent)
        propNames; %List of app/model properties with bindings managed by this controller
        hManagedGUIs; %Array of all GUIS managed by controller (for layout); union of owned and externally-registered GUIs
    end    
    
    %% HIDDEN PROPERTIES
    
    properties (Access=private)
        robotModeCached;
    end
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = Controller(hModel,guiNames,guiNamesInvisible)

            import most.idioms.*
            
            validateattributes(hModel,{'most.Model'},{'scalar'});
            assert(iscellstr(guiNames),'guiNames must be a cellstring.');            
            if nargin < 3 || isempty(guiNamesInvisible)
                guiNamesInvisible = {};
            end
            assert(iscellstr(guiNamesInvisible),'guiNamesInvisible must be a cellstring.');
                        
            obj.hModel = hModel;
            obj.hModel.addController(obj); %Make bidirectional link
            obj.guiNames = union(guiNames,guiNamesInvisible);
            obj.hAuxGUIs = [];
            obj.guiLayoutInfo = struct();
            
            %Open all child GUIs %TODO: Consider case of multiple controllers interacting with same GUI?? in which case, only open if needed?
            for i=1:length(obj.guiNames)
                guiName = obj.guiNames{i};
                
                hGUI = feval(guiName,obj.hModel,obj);
                obj.hGUIsArray(i) = hGUI;                
                obj.hGUIs.(guiName) = obj.hGUIsArray(i);
                
				% ensure that figures match the default system bg color
				set(hGUI,'Color',get(0,'defaultUIControlBackgroundColor'));
				
                set(hGUI,'Tag',guiName);
                if ismember(guiName,guiNamesInvisible)
                    set(hGUI,'Visible','off');
                end                
               
                handles = guidata(hGUI);
                handles.hController = obj;
                handles.hModel = obj.hModel;
                guidata(hGUI,handles);
                
                obj.hGUIData.(guiName) = handles;
            end 
            
            %Default properties for GUI figures
            set(obj.hGUIsArray,'HandleVisibility','callback');
            set(obj.hGUIsArray,'CloseRequestFcn',@(src,evnt)set(src,'Visible','off')); % For the momnet GUIs owned by Controller are never really killed
            
            %%% Process property metadata (propBindings) %%%
            
            pcontrolTags2Data = struct(); %structure of unique PropControl tags to [substructures of propName to [PropControlData for that prop]]
            pcontrolTags2Handles = struct(); %structure of unique PropControl tags to the PropControl object handles
            
            nstProcessPropControlData(); %Preprocess PropControlData embedded in the property metadata
            
            propNames = obj.propNames;
            assert(numel(propNames)==numel(unique(propNames)),'Repeated property in propBindings');
            for i=1:length(propNames)
                propName = propNames{i};
                pbinding = obj.propBindings.(propName);
                metaprop = findprop(obj.hModel,propName);
                assert(~isempty(metaprop),'Property ''%s'' not found in model.',propName);
                assert(metaprop.SetObservable,'A binding was specified for property ''%s'', but property is not SetObservable',propName);

                %GUI bindings (uicontrol and pcontrol)
                obj.prop2ControlStruct.(propName) = cell(0,1);
                if isfield(pbinding,'GuiIDs')
                    obj.hGUIBindingPostSetListeners.(propName) = addlistener(obj.hModel,propName,'PostSet',@obj.updateView);
                    
                    guiIDs = pbinding.GuiIDs;                    
                    assert(iscellstr(guiIDs) && mod(length(guiIDs),2) == 0,...
                        'Property metadata for property ''%s'' contains invalid GuiIDs value. Must be a string cell array of figure/control Tag pairs.',propName);
                    figTags = guiIDs(1:2:end);
                    handleTags = guiIDs(2:2:end);
                    
                    for j=1:length(figTags)
                        hGUI = obj.hGUIs.(figTags{j});
                        
                        %Extract handle to control from GUI handle
                        hGUIHandles = guidata(hGUI);
                        assert(isfield(hGUIHandles,handleTags{j}),'Specified Tag (''%s'') not found in the supplied GUI (''%s''))',handleTags{j},figTags{j});
                        hControl = hGUIHandles.(handleTags{j});
                        assert(isscalar(hControl),'The specified Tag (''%s'') appears more than once in the figure ''%s'', which is not allowed',handleTags{j},figTags{j});
                        
                        if ishandle(hControl) && strcmpi(get(hControl,'Type'),'uicontrol')
                            set(hControl,'UserData',propName);
                            
                            % options-handling for PopupMenu UIControl
                            switch get(hControl,'Style')
                                case 'popupmenu'
                                    opts = obj.hModel.getPropOptions(propName);
                                    if ~isempty(opts)
                                        if iscellstr(opts) || isnumeric(opts)
                                            if isnumeric(opts)
                                                sz = size(opts);
                                                opts = mat2cell(opts,ones(sz(1),1),sz(2));
                                                opts = cellfun(@mat2str,opts,'UniformOutput',false);
                                            elseif isfield(pbinding,'PrettyOptions') 
                                                opts = pbinding.PrettyOptions;
                                            end

                                            attribs = obj.hModel.mdlPropAttributes.(propName);
                                            tfAllowEmpty = isfield(attribs,'AllowEmpty') && attribs.AllowEmpty;
                                            if tfAllowEmpty
                                                opts = [{''};opts(:)]; 
                                            end
                                            
                                            set(hControl,'String',opts);
                                        else
                                            % currently unhandled
                                        end
                                    end
                            end
                        elseif ishandle(hControl) && (strcmpi(get(hControl,'Type'),'uimenu') || strcmpi(get(hControl,'Type'),'uitoggletool'))
                            set(hControl,'UserData',propName);
                        elseif isa(hControl,'most.gui.control.PropControl')
                            set(hControl.hControls,'UserData',hControl);

                            pcTagStr = sprintf('%s_%s',figTags{j},handleTags{j});
                            pcontrolTags2Handles.(pcTagStr) = hControl;   

                            if isfield(pbinding,'PropControlData')
                                pcdata = pbinding.PropControlData;
                            else
                                pcdata = struct();
                            end
                            
                            % Default PropControlData:
                            % * model property attributes
                            % * ViewPrecision/ViewScaling
                            %
                            % At the moment, PropControls need
                            % modelPropAttribs primarily for range
                            % info for numeric props. Conceptually however
                            % other modelPropAttribs info could be useful
                            % as well. Re: ViewScaling, even though the
                            % actual scaling is handled by Controller at
                            % the moment, PropControls may need ViewScaling to
                            % adjust ranges obtained from modelPropAttribs.
                            if isfield(obj.hModel.mdlPropAttributes,propName)
                                pcdata.ModelPropAttribs = obj.hModel.mdlPropAttributes.(propName);
                            end
                            if isfield(pbinding,'ViewPrecision')
                                pcdata.ViewPrecision = pbinding.ViewPrecision;
                            end
                            if isfield(pbinding,'ViewScaling')
                                pcdata.ViewScaling = pbinding.ViewScaling;
                            end
                                                        
                            pcontrolTags2Data.(pcTagStr).(propName) = pcdata;
                        else
                            obj.DError('','UnrecognizedControl','Specified Tag (''%s'') did not correspond to either a uicontrol or PropControl handle on figure ''%s''', handleTags{j},figTags{j});
                        end
                        
                        obj.prop2ControlStruct.(propName){end+1,1} = hControl;
                    end
                end
                
                %Callback binding
                if isfield(pbinding,'Callback')
                    callbackName = pbinding.Callback;
                    obj.hCallbackPostSetListeners.(propName) = addlistener(obj.hModel,propName,'PostSet',@(src,evnt)obj.dispatchCallback(src,evnt,callbackName));
                    obj.prop2CallbackStruct.(propName) = callbackName;
                end
                
            end
            
            %Initialize PropControls
            PropControlTags = fieldnames(pcontrolTags2Data);
            for i=1:length(PropControlTags)
                hPropControl = pcontrolTags2Handles.(PropControlTags{i});
                pcData = pcontrolTags2Data.(PropControlTags{i});
                hPropControl.init(pcData);
            end
                       
            function nstProcessPropControlData()
                % * Fills in 'options' & 'optionsForceArrayCell'
                %   PropControlData fields as needed, by querying model obj
                % * Validates 'prettyOptions' PropControlData field as needed
              
                propNames = fieldnames(obj.propBindings);
                
                for k = 1:length(propNames)
                    propName = propNames{k};
                    
                    if isfield(obj.propBindings.(propName),'PropControlData')
                        pcData = obj.propBindings.(propName).PropControlData;
                        pcDataFields = fieldnames(pcData);
                        
                        %Determine whether PropControl needs property options information
                        tfUseOptions = false;
                        if ismember('prettyOptions',pcDataFields)
                            tfUseOptions = true;
                        else
                            for m=1:length(pcDataFields)
                                val = pcData.(pcDataFields{m});
                                if ischar(val) && ~isempty(strfind(val,'options')); % AL: Strange-looking criteria, but for now it works
                                    tfUseOptions = true;
                                    break;
                                end
                            end
                        end
                        
                        if tfUseOptions
                            optionsErrArgs = {'Invalid Options (or prettyOptions) metadata supplied for property ''%s''',propName};

                            % If the model supplies options, use those
                            appPropOptions = obj.hModel.getPropOptions(propName);
                            if ~isempty(appPropOptions)
                                assert(isnumeric(appPropOptions) || all(cellfun(@isnumeric,appPropOptions)) || iscellstr(appPropOptions), optionsErrArgs{:});                                
                                obj.propBindings.(propName).PropControlData.options = appPropOptions;                                
                            end
                            propOptions = obj.propBindings.(propName).PropControlData.options;

                            % Validate prettyOptions (optionally supplied)
                            tfPrettyOpts = isfield(pcData,'prettyOptions');
                            if tfPrettyOpts
                                assert(numel(pcData.prettyOptions)==numel(propOptions),optionsErrArgs{:});
                                prettyOptions = pcData.prettyOptions;
                            end

                            %Determine if array of options should always be represented as cell array
                            tfForceArrayCell = isfield(obj.hModel.mdlPropAttributes.(propName),'List');
                            obj.propBindings.(propName).PropControlData.optionsForceArrayCell = tfForceArrayCell;
                            
                            % Deal with AllowEmpty
                            if isfield(obj.hModel.mdlPropAttributes.(propName),'AllowEmpty') && obj.hModel.mdlPropAttributes.(propName).AllowEmpty
                                if isnumeric(propOptions)
                                    % a full row of nans means "empty option"
                                    propOptions = [nan(1,size(propOptions,2));propOptions]; %#ok<AGROW>
                                    if tfPrettyOpts
                                        prettyOptions = ['<empty>';prettyOptions(:)];
                                    end
                                elseif all(cellfun(@isnumeric,propOptions))
                                    propOptions = [nan;propOptions]; %#ok<AGROW>
                                    if tfPrettyOpts
                                        prettyOptions = ['<empty>';prettyOptions(:)];
                                    end
                                else
                                    % for now only do something with
                                    % numeric opts
                                end
                                
                                obj.propBindings.(propName).PropControlData.options = propOptions;
                                if tfPrettyOpts
                                    obj.propBindings.(propName).PropControlData.prettyOptions = prettyOptions;
                                end
                            end
                        end
                    end
                end
            end
            
        end        

        % Initialize GUIs based on model state.
        % 
        % At the moment, from the GUI's point of view, initialization is
        % equivalent to the sequence of actions whereby each model property
        % with a Controller binding is set to its initial value.
        % UIControls and PropControls are updated, and custom Callbacks are
        % fired. Custom callbacks are fired with a "fake" eventData (a
        % struct that looks similar to the typical event.PropertyEvent
        % object), since a genuine post-set event.PropertyEvent can only be
        % generated by a genuine PostSet event (initialization does not
        % actually set any model properties).
        %
        % Ultimately, it may be worthwhile to enable custom callbacks for
        % GUI initialization that are only fired once, when a GUI is first
        % started up. An example use case would be a table bound to model
        % property where the number of rows is constant, but known only at
        % runtime, after the model is initialized. The number of rows in
        % the table could be set in a custom initialization callback, after
        % which it would remain fixed.
        function initialize(obj)
            propNames = fieldnames(obj.propBindings);
            p2Ctl = obj.prop2ControlStruct;
            p2Cbk = obj.prop2CallbackStruct;
            
            robotModeCachedLocal = obj.robotMode;
            obj.robotMode = true;
            try
                for i=1:numel(propNames)
                    pname = propNames{i};
                    assert(isfield(p2Ctl,pname));
                    if ~isempty(p2Ctl.(pname))
                        obj.updateViewHidden(pname);
                    end
                    if isfield(p2Cbk,pname)
                        src = findprop(obj.hModel,pname);
                        assert(~isempty(src));
                        evt = struct('AffectedObject',obj.hModel,...
                            'Source',src,...
                            'EventName','Controller initialize');
                        obj.dispatchCallback(src,evt,p2Cbk.(pname));
                    end
                end
                
                obj.robotMode = robotModeCachedLocal;
  
            catch ME
                obj.robotMode = robotModeCachedLocal;

                fprintf(2,'*****************\n');
                fprintf(2,'Error occurred in initializing property ''%s'' of ''%s'' object''s Controller\n',propNames{i},class(obj.hModel));
                ME.rethrow();
            end
        end
        
        function delete(obj)
            %Delete figure handles explicitly, because HandleVisiblity='callback' 
            tf = ishandle(obj.hGUIsArray);
            delete(obj.hGUIsArray(tf));
            
            %Delete listeners (controller can be deleted, with model left intact)
            structfun(@delete,obj.hGUIBindingPostSetListeners);
            structfun(@delete,obj.hCallbackPostSetListeners);
        end
                
    end
    
       
    %% PROPERTY ACCESS
    methods
        function val = get.propNames(obj)
            val = fieldnames(obj.propBindings);
        end
        
        function h = get.hManagedGUIs(obj)
            obj.hAuxGUIs = obj.hAuxGUIs(ishandle(obj.hAuxGUIs));
            obj.hAuxGUIs = obj.hAuxGUIs(:);
            h = [obj.hGUIsArray(:);obj.hAuxGUIs(:)];
        end        
        
        function set.robotMode(obj,val)
            validateattributes(val,{'numeric' 'logical'},{'binary' 'scalar'});
            obj.robotMode = val;
        end
    end
    
    %% View/Model update methods
    methods
    
        function raiseAllGUIs(obj)
            arrayfun(@(x)obj.raiseGUI(x),obj.hManagedGUIs);
        end
        
        function showAllGUIs(obj)
            arrayfun(@(x)obj.showGUI(x),obj.hManagedGUIs);
        end        
        
        % bring a GUI window to the front if it is Visible.
        function raiseGUI(obj,guiH) %#ok<MANU>
            vis = get(guiH,'Visible');
            switch vis
                case 'on'
                    figure(guiH);
            end
        end
                
        function showGUI(obj,src,~)
            %src: Either a GUI figure handle, or the name (Tag) of a GUI managed by this controller
            
            if ishandle(src)
                set(src,'Visible','on')
            else
                assert(most.idioms.isstring(src));
                set(obj.hGUIs.(src),'Visible','on')
            end
        end
        
        function hideGUI(obj,src,~)
            %src: Either a GUI figure handle, or the name (Tag) of a GUI managed by this controller

            if ishandle(src)
                set(src,'Visible','off')
            else
                assert(most.idioms.isstring(src));
                set(obj.hGUIs.(src),'Visible','off')
            end
        end
        
        function updateView(obj,src,~)
            %src: A post-set listener -- or a string or string cell array specifying one or a list of property names
            %updateView() is used primarily as the generic property post-set listener - updates corresponding GUI element(s) (View)
                        
            if ischar(src)
                obj.updateViewHidden(src);
            elseif iscellstr(src)
                cellfun(@(propName)obj.updateViewHidden(propName),src);
            else
                obj.updateViewHidden(src.Name);
            end
        end
        
        function updatePropControlView(obj,pCtl)
            %Updates view for all properties associated with specified PropControl(s)
            %pCtl: Either handle to PropControl or a Tag (name) of a PropControl
            if ischar(pCtl)
                if ismember(pCtl,obj.propNames)
                    assert(false);
%                     hCtls = obj.prop2ControlStruct.(pCtlID);
%                     propNames = cell(0,1);
%                     for i=1:length(hCtls)
%                         if isa(hCtls{i},'most.gui.control.PropControl')
%                             propNames = [propNames;hCtls{i}.propNames(:)]; %#ok<AGROW>
%                         end
%                     end
%                     assert(~isempty(propNames),'The supplied pCtlID (''%s'') refers to a property without any PropControls', pCtlID);
%                     obj.updateView(unique(propNames));
                else %Must be a PCtrl Tag
                    %TODO!! (Determine hPCtl from its Tag)
                    %obj.updateView(hPCtl.propNames);
                end
            else
                assert(isa(pCtl,'most.gui.control.PropControl'));
                obj.updateView(pCtl.propNames);
            end
        end
            
        function updateModel(obj,src,evnt,handles)
            %Generic GUI callback -- updates corresponding application property (Model)
                                    
            %Determine corresponding property or PropControl
            userData = get(src,'UserData');
            
            if ischar(userData) %Direct uicontrol
                status = 'set';
                propName = userData;
                propBindings = obj.propBindings.(propName); %#ok<PROP>
                
                if ishandle(src) && strcmpi(get(src,'Type'),'uicontrol')
                    ctlStyle = get(src,'Style');
                elseif ishandle(src) && strcmpi(get(src,'Type'),'uimenu')
                    ctlStyle = 'uimenu';
                elseif ishandle(src) && strcmpi(get(src,'Type'),'uitoggletool')
                    ctlStyle = 'uitoggletool';
                end
                
                %Decode value
                switch ctlStyle 
                    case 'edit'
                        propVal = get(src,'String');
                    case {'slider' 'checkbox' 'togglebutton' 'radiobutton'}
                        propVal = get(src,'Value');
                    case 'listbox'
                        items = get(src,'String');
                        propVal = items(get(src,'Value')); %Encode as cell array of selected options
                    case 'popupmenu'
                        options = get(src,'String');
                        propIdx = get(src,'Value');
                        propVal = options{propIdx}; %Encode as string of the one-and-only selected option
                    case 'uimenu'
                        propVal = get(src,'Checked');
                        propVal = strcmp(propVal,'on');
                    case 'uitoggletool'
                        propVal = get(src,'State');
                        propVal = strcmp(propVal,'on');
                    otherwise
                        obj.DError('','UnsupportedUiControl','The control of type ''%s'' is not recognized or supported', get(src,'Style'));
                end      
                
                %Convert to model-type, e.g. convert to number, if needed
                %This code has to do some work just to determine whether a
                %conversion is needed; precomputed data structure might be
                %appropriate, or perhaps popupmenus and edit/listboxes
                %should have thin PropControls
                switch ctlStyle
                    case 'popupmenu'
                        opts = obj.hModel.getPropOptions(propName);
                        if ~isempty(opts) %Use model options-list, rather than FIG option strings extracted above   
                            
                            useOptsArray = true;
                            if obj.hModel.mdlPropAttributes.(propName).AllowEmpty
                                if isempty(propVal) 
                                    useOptsArray = false;
                                    if isnumeric(opts)
                                        propVal = [];
                                    end
                                else
                                    propIdx = propIdx - 1;%account for empty option added to start of list (by this class).
                                end
                            end
                            
                            if useOptsArray
                                if isnumeric(opts)
                                    propVal = opts(propIdx);
                                else
                                    propVal = opts{propIdx};
                                end
                            end
                        end
                        
                        if ischar(propVal) && zlclIsPropNumericClass(obj.hModel.mdlPropAttributes,propName) % model says prop has numeric class; handle case where options list set in GUIDE for numeric values
                            propVal = str2num(propVal); %#ok<ST2NM>
                        end
                        
                    case {'edit' 'listbox'}
                        if zlclIsPropNumericClass(obj.hModel.mdlPropAttributes,propName)
                            if iscell(propVal) %for listbox case
                                propVal = cellfun(@str2num,propVal);
                            else
                                propVal = str2num(propVal); %#ok<ST2NM>
                            end
                            
                            %Revert if non-numeric entry was given (and empty value is not allowed)
                            if any(isempty(propVal)) && ~obj.hModel.mdlPropAttributes.(propName).AllowEmpty % AL: this line looks fishy, propVal is at this point a numeric array no?
                                status = 'revert';
                            end
                        end
                end
            else %A PropControl
                hPropControl = userData;
                [status propName propVal] = hPropControl.decodeFcn(src,evnt,handles);
                propBindings = obj.propBindings.(propName); %#ok<PROP>
            end
            
            % Rescale based on ViewScaling
            % (See comments in updateViewHidden() for a note on how
            % ViewScaling/ViewPrecision work with uicontrols/PropControls etc)
            if isnumeric(propVal) && isfield(propBindings,'ViewScaling') %#ok<PROP>
                propVal = propVal/propBindings.ViewScaling; %#ok<PROP>
            end

            switch status
                case 'set'
                    try
                        obj.hModel.(propName) = propVal;
                    catch ME
                        %Revert View to reflect current (unchanged) model state
                        obj.updateViewHidden(propName);
                        
                        %Handle error messaging
                        obj.updateModelErrorFcn(ME);
                    end
                case 'revert'
                    obj.updateViewHidden(propName);
                otherwise
                    assert(false);
            end
        end   
        
        function channelsDisplay(obj,src,evnt,handles)
            
            userData = get(src,'UserData');
            hPropControl = userData;
            [status, propName, propVal] = hPropControl.decodeFcn(src,evnt,handles);
            propBindings = obj.propBindings.(propName); %#ok<PROP>

            switch status
                case 'set'
                    try
                        obj.hModel.channelsDisplay2 = propVal;
                    catch ME
                        %Revert View to reflect current (unchanged) model state
                        obj.updateViewHidden(propName);
                        
                        %Handle error messaging
                        obj.updateModelErrorFcn(ME);
                    end
            end
        end  
        
        function channelsSave2(obj,src,evnt,handles)
            
            userData = get(src,'UserData');
            hPropControl = userData;
            [status, propName, propVal] = hPropControl.decodeFcn(src,evnt,handles);
            propBindings = obj.propBindings.(propName); %#ok<PROP>

            switch status
                case 'set'
                    try
                        obj.hModel.channelsSave = propVal;
                    catch ME
                        %Revert View to reflect current (unchanged) model state
                        obj.updateViewHidden(propName);
                        
                        %Handle error messaging
                        obj.updateModelErrorFcn(ME);
                    end
            end
        end 
        
        function channelsInvert(obj,src,evnt,handles)
            
            userData = get(src,'UserData');
            hPropControl = userData;
            [status, propName, propVal] = hPropControl.decodeFcn(src,evnt,handles);
            propBindings = obj.propBindings.(propName); %#ok<PROP>

            switch status
                case 'set'
                    try
                        obj.hModel.channelsInvert = propVal;
                    catch ME
                        %Revert View to reflect current (unchanged) model state
                        obj.updateViewHidden(propName);
                        
                        %Handle error messaging
                        obj.updateModelErrorFcn(ME);
                    end
            end
        end 
        
        function updateModelErrorFcn(obj,ME)
            %Handle error messaging for errors generated when setting a model property, via updateModel() or otherwise
            %ME: MException object created by error
                                    
            switch ME.identifier
                case 'most:Model:invalidPropVal'
                    fprintf(2,'WARNING: Attempted to set invalid property value via GUI control. Attempt ignored. \n');
                case 'PDEPProp:SetError'
                    throwAsCaller(obj.DException('','ModelUpdateError',ME.message));
                otherwise
                    ME.rethrow();
            end        
        end
        
        function robotModeSet(obj)
            obj.robotModeCached = obj.robotMode;
            obj.robotMode = true;
        end
        
        function robotModeReset(obj)
            assert(~isempty(obj.robotModeCached),'No cached value of robotMode found. Was robotModeSet() not called before robotModeReset(), as expected?');
            obj.robotMode = obj.robotModeCached;
            obj.robotModeCached = [];
        end
        
    end
    
    %% Layout management
    methods
       
        % Get layout state (positions, visibility, advanced-panel-ness,
        % etc) for all managed GUIs.
        %
        % s: struct. fields: GUI tags. values: struct with fields
        % 'Position', 'Visible', 'Toggle'.
        function s = ctlrCurrentGUILayout(obj)
            guis = obj.hManagedGUIs;
            s = struct();
            for c = 1:numel(guis)
                g = guis(c);
                tag = get(g,'Tag');
                if isfield(s,tag)
                    error('Controller:DuplicateTag',...
                        'One or more figures have the same tag.');
                end
                s.(tag).Position = get(g,'Position');
                s.(tag).Visible = get(g,'Visible');
                if most.gui.AdvancedPanelToggler.isFigToggleable(g)
                    s.(tag).Toggle = most.gui.AdvancedPanelToggler.saveToggleState(g);
                else
                    s.(tag).Toggle = [];
                end
            end
        end
        
        % Take snapshot of layout state for all managed GUIs and save to
        % filename. If filename is not supplied, uigetfile is called.
        function ctlrSaveGUILayout(obj,filename)
            %AL: this stuff looks alot like the Model propSet code, any
            %way to consolidate? See also private methods below like 'getLayoutFileHelper'.
            % xxx def replace getLayoutFileHelper with SI4::filehelper thing
            if nargin < 2
                filename = obj.getLayoutFileHelper('put');
                if isempty(filename)
                    return;
                end
            end
            %assert(exist(filename,'file')==2);
                        
            layoutStruct = obj.ctlrCurrentGUILayout;
            
            varName = obj.getLayoutVarName();
            tmp.(varName) = layoutStruct; %#ok<STRNU>
            if exist(filename,'file')==2
                save(filename,'-struct','tmp','-mat','-append');
            else
                save(filename,'-struct','tmp','-mat');
            end
            obj.ensureClassDataFile(struct('lastLayoutFile',filename));
            obj.setClassDataVar('lastLayoutFile',filename);

            obj.guiLayoutInfo = layoutStruct;
        end

        % Load layout state from file. If filename is not supplied,
        % uigetfile is called.
        function ctlrLoadGUILayout(obj,filename)
            if nargin < 2
                filename = obj.getLayoutFileHelper('get');
                if isempty(filename)
                    return;
                end
            end
                
            if exist(filename,'file')~=2
                error('Controller:FileNotFound','File ''%s'' not found.',filename);
            end                
            obj.ensureClassDataFile(struct('lastLayoutFile',filename));
            obj.setClassDataVar('lastLayoutFile',filename);
                
            s = load(filename,'-mat');
            varName = obj.getLayoutVarName();
            layoutStruct = s.(varName);
            obj.ctlrLoadGUILayoutFromStruct(layoutStruct);
        end
        
        function ctlrLoadGUILayoutFromStruct(obj,layoutStruct)
            obj.guiLayoutInfo = layoutStruct;
            guis = obj.hManagedGUIs;
            for c = 1:numel(guis)
                obj.layoutGUI(guis(c));
            end                       
        end
        
        % If tag matches the Tag of a managed figure, that figure is
        % returned. If it doesn't, a new figure with that tag is created
        % and registered with obj. varargin are additional arguments to be
        % passed to figure().
        function h = figure(obj,tag,varargin)
            assert(ischar(tag));
            guis = obj.hManagedGUIs;
            tags = get(guis,{'Tag'});
            [tf loc] = ismember(tag,tags);
            if tf
                h = obj.hManagedGUIs(loc);
            else
                h = figure('Tag',tag,varargin{:});
                obj.registerGUI(h);
            end
        end
        
        % Register a figure to be managed. Lay the figure out if layout
        % info is available.
        function registerGUI(obj,figH)
            assert(ishandle(figH));
            guis = obj.hManagedGUIs;
            tags = get(guis,{'Tag'});
            tag = get(figH,'Tag');
            if ismember(tag,tags)
                error('Controller:FigureWithTagExists',...
                    'A figure with tag ''%s'' is already managed by the controller.',tag);
            end                
            
            obj.hAuxGUIs(end+1,1) = figH;
            obj.layoutGUI(figH);
            
            % We used to update the closeReqFcn of managed GUIs so that
            % they would be automatically unregistered (from Controller)
            % when the GUI was killed. However, all SI-related guis have
            % already overloaded their closeReqFcns to just set their
            % Visibility to off. So, for now, we will expect all registered
            % GUIs to explicitly de-register themselves if/when they go
            % away. (For SI, this will never happen at the moment.)            
        end
        
        function unregisterGUI(obj,figH)
            tfAux = figH==obj.hAuxGUIs;  
            if any(tfAux)
                obj.hAuxGUIs(tfAux,:) = [];
            end
        end
        
    end
    
    methods (Access=private)
       
        function layoutGUI(obj,figH)
            tag = get(figH,'Tag');
            if isfield(obj.guiLayoutInfo,tag)
                layoutInfo = obj.guiLayoutInfo.(tag);

                if isfield(layoutInfo,'Toggle')
                    toggleState = layoutInfo.Toggle;
                else
                    % this branch is only to support legacy .usr files that
                    % don't have up-to-date layout info
                    toggleState = [];
                end
                if ~isempty(toggleState)
                    assert(most.gui.AdvancedPanelToggler.isFigToggleable(figH));

                    most.gui.AdvancedPanelToggler.loadToggleState(figH,toggleState);

                    % gui is toggleable; for position, only set x- and 
                    % y-pos, not width and height, as those are controlled 
                    % by toggle-state.
                    pos = get(figH,'Position');
                    pos(1:2) = layoutInfo.Position(1:2);
                    set(figH,'Position',pos);
                    
                else
                    % not a toggleable GUI
                    
                    set(figH,'Position',layoutInfo.Position);
                end
                
                set(figH,'Visible',layoutInfo.Visible);
            end
        end
        
        function varName = getLayoutVarName(obj)
            varName = sprintf('%s_layout',class(obj));
            varName = regexprep(varName,'\.','__');
        end
        
        % Either returns a full filename, or [] if user cancels. 
        % action is either 'get' or 'put'.
        function filename = getLayoutFileHelper(obj,action)
            
            switch action
                case 'get', fileFcn = @uigetfile;
                case 'put', fileFcn = @uiputfile;
                otherwise, assert(false);
            end
            
            lastFile = obj.getClassDataVar('lastLayoutFile');            
            [fname pname] = fileFcn('*.lay','Select layout file',lastFile);
            if isequal(fname,0) || isequal(pname,0)
                filename = [];
            else
                filename = fullfile(pname,fname);
            end
        end
        
        function registeredGUICloseReqFcn(obj,src,~)
            assert(any(src==obj.hAuxGUIs));
            obj.unregisterGUI(src);
            closereq;
        end
        
    end
    
    %% PRIVATE/PROTECTED METHODS
       
    methods (Access=protected)

        function killGUI(obj,src,~)            
            %src: Either a GUI figure handle, or the name (Tag) of a GUI managed by this controller
            %
            % NOTE: This method might never be needed/advisable IF the API for adding GUIs to Controller is extended to allow dynamic/conditional addition, e.g via an addGUI() type method

            if ~ishandle(src)
                assert(most.idioms.isstring(src));                
                
                guiName = src;
                hGui = obj.hGUIs.(src);
            else          
                hGui = src;
                guiName = get(hGui,'Name');                
            end

            %Actually kill the GUI
            delete(hGui);
            
            %Remove references to GUI
            obj.guiNames = setdiff(obj.guiNames,guiName);
            obj.hGUIsArray(obj.hGUIsArray==hGui) = [];
            obj.hGUIs = rmfield(obj.hGUIs,guiName);
            obj.hGUIData = rmfield(obj.hGUIData,guiName);
        end
        
        function dispatchCallback(obj,src,evnt,callbackName)
           feval(callbackName,obj,src,evnt);   
           if obj.robotMode
               drawnow expose update; %Update GUI immediately, so event queue doesn't build up %TODO: Consider whether to do this only if model is uninitialized and/or in case where a Controller flag property enables this behavior
           end
        end
        
        function updateViewHidden(obj,propName)
            %TODO: Handle updates of pass-through (PDEP) properties -- maybe need, or don't need, getAppPropDirect()

            propVal = obj.hModel.(propName);
            propBinding = obj.propBindings.(propName);
            propControls = obj.prop2ControlStruct.(propName);
            cellfun(@(x)obj.updateControl(x,propName,propVal,propBinding),propControls);
        end
        
        function updateControl(obj,hControl,propName,propVal,propBinding)
            
            % Note on how ViewPrecision/ViewScaling work between
            % Controller, uicontrols, PropControls.
            %
            % ViewScaling is handled within Controller. Thus in
            % Controller/updateControl, (numeric) values are scaled before
            % being set() in uicontrols or before being passed to
            % PropControl/encodeFcn. Similarly, in Controller/updateModel,
            % (numeric) values from uicontrols or PropControl/decodeFcn are
            % rescaled before being set on the model. Put another way,
            % uicontrols/PropControls see only rescaled values.
            %
            % ViewPrecision is only relevant for encoding, and this is
            % handled in uicontrol-specific code and within PropControls. Thus
            % here in Controller/updateControl, un-viewPrecision-modified
            % values (eg values in the original model precision) are passed
            % to PropControl/encodeFcn. The responsibility for handling
            % ViewPrecision during encoding is given to
            % uicontrols/PropControls deliberately; how ViewPrecision is
            % achieved is a uicontrol/PropControl-dependent operation. (In
            % particular, note eg that encoding 1.2345 with a ViewPrecision
            % of 3 is not the same as encoding 1.23, for example in the
            % case of a spinner where the slider takes continuous values).

            if isnumeric(propVal) && isfield(propBinding,'ViewScaling')
                propVal = propVal*propBinding.ViewScaling;
            end
                            
            DE = obj.DException('','PropertyToGUIConvertFail','Unable to convert property value to GUI control value');                        
            if ishandle(hControl) % MATLAB UI component
                
                % Create a cell array "argument list" for view precision
                if isfield(propBinding,'ViewPrecision')
                    viewPrecision = {propBinding.ViewPrecision};
                else
                    viewPrecision = {};
                end
            
                switch get(hControl,'Type')
                    case 'uicontrol'
                        switch get(hControl,'Style')
                            case {'edit' 'text'}
                                if isnumeric(propVal)
                                    propStrVal = num2str(propVal,viewPrecision{:});
                                    set(hControl,'String',propStrVal);
                                elseif ischar(propVal)
                                    set(hControl,'String',propVal);
                                else
                                    DE.throw();
                                end
                                
                            case {'slider' 'checkbox' 'togglebutton' 'radiobutton'}
                                set(hControl,'Value',propVal);
                                
                            case 'listbox'
                                if isnumeric(propVal)
                                    % Use case for ViewPrecision+Listbox is
                                    % unclear but anyway this "works"
                                    propVal = {num2str(propVal,viewPrecision{:})}; 
                                    items = get(hControl,'String');
                                elseif iscellstr(propVal)
                                    items = get(hControl,'String');
                                else
                                    DE.throw();
                                end
                                
                                %Find indices into list of items
                                [~,indices] = intersect(items,propVal);
                                set(hControl,'Value',indices);
                                
                            case 'popupmenu'
                                %Handle case of property value being either a number or string
                                if isnumeric(propVal)
                                    if isempty(propVal)
                                        propVal = '';
                                    else
                                        % use case for viewprecision+popupmenu is
                                        % unclear but anyway this "works"
                                        propVal = mat2str(propVal,viewPrecision{:});
                                    end
                                    numericPropVal = true;
                                elseif ischar(propVal)
                                    numericPropVal = false;
                                else
                                    DE.throw();
                                end
                                
                                if strcmp(propVal,'Two_channels') || strcmp(propVal,'Four_channels')
                                    if strcmp(propVal,'Two_channels')
                                        set(hControl,'Value',1);
                                    else
                                        set(hControl,'Value',2);
                                    end
                                else
                                    %Find index into list of options
                                    options = get(hControl,'String');
                                    if numericPropVal
                                        options = strtrim(options); %Remove all whitespace (may have been added to prettify list display)
                                    else %ischar
                                        options = lower(options);
                                    end
                                    [~,propVal] = ismember(lower(propVal),options);
                                    if propVal > 0
                                        set(hControl,'Value',propVal);
                                    else
                                        DE.throw();
                                    end
                                end
                            otherwise
                                obj.DError('','UnsuportedUIControl','The control of type ''%s'' is not recognized or supported', get(hControl,'Style'));
                        end
                    case 'uimenu'
                        if ~(isnumeric(propVal) || islogical(propVal)) && ~isscalar(propVal)
                            DE.throw();
                        end
                        
                        if propVal
                            propVal = 'on';
                        else
                            propVal = 'off';
                        end
                        set(hControl,'Checked',propVal);
                    case 'uitoggletool'
                        if ~(isnumeric(propVal) || islogical(propVal)) && ~isscalar(propVal)
                            DE.throw();
                        end
                        
                        if propVal
                            propVal = 'on';
                        else
                            propVal = 'off';
                        end
                        set(hControl,'State',propVal);
                    
                    otherwise
                        % none
                end
            else % PropControl
                assert(isa(hControl,'most.gui.control.PropControl'));
                encodeFcn(hControl,propName,propVal);
            end
            
            if obj.robotMode
                drawnow expose update; %Update GUI immediately, so event queue doesn't build up %TODO: Consider whether to do this only if model is uninitialized and/or in case where a Controller flag property enables this behavior
            end
        end
        
    end
    
end

function tf = zlclIsPropNumericClass(propAtt,propName)
tf = isfield(propAtt,propName) && isfield(propAtt.(propName),'Classes') ...
    && ismember(lower(propAtt.(propName).Classes), ...
        {'numeric' 'single' 'double' 'int8' 'int16' 'int32' 'int64' 'uint8' 'uint16' 'uint32' 'uint64'}); %zzz:possibly include 'logical'? or handle differently?
end    

% % Update pcontrol data using app. Recurse through pcontrol data (assumed to
% % be nested struct); any fields encountered where the value is a char with
% % a colon represent fields that should be filled in by calling the listed
% % method on the application.
% function strct = lclUpdatePropControlData(hModel,strct)
% 
% fields = fieldnames(strct);
% for c = 1:numel(fields);
%     fname = fields{c};
%     val = strct.(fname);
%     if isstruct(val)
%         strct.(fname) = lclUpdatePropControlData(hModel,val);
%     elseif ischar(val) && ~isempty(strfind(val,':'))
%         colon = strfind(val,':');
%         assert(numel(colon)==1);
%         fcnname = val(colon+1:end);
%         strct.(fname) = eval(sprintf('hModel.%s',fcnname));
%     else
%         % no-op
%     end
% end
