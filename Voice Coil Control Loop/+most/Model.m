classdef Model < most.DClass
    %MODEL Shared functionality for classes which are identifiable as 'models' (rig/user-level)
    
    %Shared functionality includes:
    %
    %   Property validation -- using mdlPropAttributes 'metadata'
    %   Config saving/loading -- storage of all 'saveable' props, respecting order in mdlPropAttributes
    %   Header saving/loading -- storage of all 'headerable' props
    
    %TODO: Allow general property-replacement throughout the property metadata table -- could use to specify 'size' attribute of a property, for instance
    %TODO: Use subsref to allow avoiding need to make boilerplate set-access methods
    %TODO: Allow 'Callback' specification in property attributes -- this will only work in concert somehow with subsref scheme
    %TODO: When validation fails with Options list -- error message should provide the list of valid options    
    %TODO: Better handle the case of empty vaues together with Options list..
    %TODO: Resolve issue -- should we expect that initialize() is /always/ called for a Model? (effectively a 'finalizer' method to complement constructor)

    %% ABSTRACT PROPERTIES
    properties (Abstract, Hidden, SetAccess=protected)
        mdlPropAttributes; %A structure effecting Map from property names to structures whose fields are Tags, with associated values, specifying attributes of each property
        
        %OPTIONAL (Can leave empty)
        mdlHeaderExcludeProps; %String cell array of props to forcibly exclude from header
    end
    
    
    %% SUPERUSER PROPERTIES 
    properties (Hidden)
        mdlVerbose = false; %Indicates whether model should provide command-line warnings/messages otherwise suppressed        
        
        mdlInitialized = false; %Flag indicating whether model has been initialized
    end
    
    properties (Hidden,Dependent)
        mdlDefaultConfigProps; % Returns default subset of props to be saved to Config file.
        mdlDefaultHeaderProps; % Returns default subset of props to be saved to Header file.
    end
    
    %% DEVELOPER PROPERTIES
    %'Friend' properties -- SetAccess would ideally be more restricted
    properties (Hidden,SetAccess=protected)
        hController={}; %Handle to Controller(s), if any, linked to this object 
        
        mdlDependsOnListeners; %Structure, whose fields are names of properties with 'DependsOn' property metadata tag, and whose values are an array of set listener handles        
    end
    
    properties (Access=private,Dependent)
        mdlPropSetVarName; % object-dependent variable name used in propset MAT files
    end
    
    %% CONSTRUCTOR/DESTRUCTOR    
    methods
        
        function obj = Model()
           
            znstProcessPropAttributes(); %Process property attributes            
           
            function znstProcessPropAttributes()

                propNames = fieldnames(obj.mdlPropAttributes);                
                
                for i=1:length(propNames)
                    currPropMD = obj.mdlPropAttributes.(propNames{i});

                    %Processing Step 1: Fill in Classes = 'numeric' if 'Classes' not provided and any of Range/Attributes/Size are set (meaning validateattributes() will get called)
                    if ~isfield(currPropMD,'Classes') && any(ismember(fieldnames(currPropMD),{'Range' 'Size' 'Attributes'}))
                         currPropMD.Classes = 'numeric';
                    end
                    
                    %Processing Step 2: Fill in AllowEmpty=false if 'AllowEmpty' not specified
                    if ~isfield(currPropMD,'AllowEmpty')
                         currPropMD.AllowEmpty = false;
                    end                    
                    
                    %Processing Step 3: Generate observable set event for any properties with 'DependsOn' tags, using intermediate listeners
                    if isfield(currPropMD,'DependsOn')
                        dependsOnList = currPropMD.DependsOn;
                                                
                        %Ensure/make Tag value a cell string array
                        assert(ischar(dependsOnList) || iscellstr(dependsOnList),'DependsOn tag was supplied for property ''%s'' with incorrect value -- must be a string or string cell array',propNames{i});
                        if ischar(dependsOnList)
                            dependsOnList = {dependsOnList};
                        end     
                        
                        %Ensure dependent property has a set property-access method
                        mp = findprop(obj,propNames{i});
                        assert(~isempty(mp.SetMethod),'Properties with ''DependsOn'' tag specified must have a set property-access method defined (typically empty). Property ''%s'' violates this rule.',propNames{i});
                        
                        %Bind listener to each of the properties this one 'dependsOn'   
                        listenerArray = event.proplistener.empty();
                        for j=1:length(dependsOnList)
                            mp = findprop(obj,dependsOnList{j});
                            assert(~isempty(mp) && mp.SetObservable,'Properties specified as ''DependsOn'' tag value must exist and be SetObservable. The DependsOn property ''%s'' for property ''%s'' violates this rule.',dependsOnList{j},propNames{i});
                            
                            listenerArray = [listenerArray addlistener(obj,dependsOnList{j},'PostSet',@(src,evnt)znstDummySet(src,evnt,propNames{i}))]; %#ok<AGROW> %TMW: Somehow it's not allowed to use trick of growing array from end to first, with first assignment providign the allocation.
                        end
                                                
                        obj.mdlDependsOnListeners.(propNames{i}) = listenerArray;                        
                        
                    end
                    
                    obj.mdlPropAttributes.(propNames{i}) = currPropMD;
                end                   
                            
                function znstDummySet(~,evnt,propName)
                    %Set specified property to dummy value -- for purpose of allowing any SetObserving listeners to fire
                    evnt.AffectedObject.(propName) = nan;
                end                
                
            end

        end
        
        function initialize(obj)
            
            %Where appropriate, auto-initialize props not initialized in class definition file
            znstInitializeOptionProps();
            
            %Initialize all app properties with side-effects, respecting any order specified by mdlPropAttributes
            %propNames = fieldnames(obj.mdlPropAttributes);
            mc = metaclass(obj);
            props = mc.Properties;
            propNames = cellfun(@(x)x.Name,props,'UniformOutput',false);            
            propNames = obj.mdlOrderPropList(propNames);
            
            %Put controller into 'robot mode' before setting properties in rapid programmatic fashion
            obj.zprvSetCtlrRobotMode();
            
            %Ensure all model and controller side-effects are honored by property 'eigensets'
            try
                for ii=1:length(propNames)
                    mp = findprop(obj,propNames{ii});
                    if ~isempty(mp.SetMethod) && strcmpi(mp.SetAccess,'public')
                        obj.(propNames{ii}) = obj.(propNames{ii}); %Forces set-access method to be invoked
                    end
                end
                
                %Initialize Controller object(s) associated with this model
                for i=1:length(obj.hController)
                    obj.hController{i}.initialize();
                end
            catch ME
                obj.zprvResetCtlrRobotMode();
                ME.rethrow();
            end
            
            %Restore controller(s) robot mode setting
            obj.zprvResetCtlrRobotMode();
            
            %Set flag indicating model has been initialized
            obj.mdlInitialized = true;
            
            return;
            
            function znstInitializeOptionProps()
                propNames = fieldnames(obj.mdlPropAttributes);
                for i=1:length(propNames)
                    propMD = obj.mdlPropAttributes.(propNames{i});
                    
                    if isfield(propMD,'Options')
                        
                        if isempty(obj.(propNames{i})) && (~isfield(propMD,'AllowEmpty') || ~propMD.AllowEmpty)
                            optionsList = propMD.Options;
                            
                            %TODO: Global/general string replacement in Model property metadata
                            if ischar(optionsList)
                                optionsList = obj.(propMD.Options);
                            end
                            
                            if isnumeric(optionsList)
                                if isvector(optionsList)
                                    defaultOption = optionsList(1);
                                elseif ndims(optionsList)
                                    defaultOption = optionsList(1,:);
                                else
                                    assert(false);
                                end
                            elseif iscellstr(optionsList)
                                defaultOption = optionsList{1};
                            else
                                assert(false);
                            end
                            
                            
                            if isfield(propMD,'List')
                                listSpec = propMD.List;
                                
                                %TODO: Global/general string replacement in Model property metadata
                                if ischar(listSpec) && ~ismember(lower(listSpec),{'vector' 'fullvector'})
                                    listSpec = obj.(propMD.List);
                                end
                                
                                if isnumeric(listSpec)
                                    if isscalar(listSpec)
                                        initSize = [listSpec 1];
                                    else
                                        initSize = listSpec;
                                    end
                                else %inf, 'vector', 'fullvector' options -- init with scalar value
                                    initSize = [1 1];
                                end
                                
                                obj.(propNames{i}) = repmat({defaultOption},initSize);
                            else
                                obj.(propNames{i}) = defaultOption;                                
                            end
                            
                        end
                    end
                end
            end
        end
        
        function delete(obj)
            for c = 1:numel(obj.hController)
                ctl = obj.hController{c};
                if isvalid(ctl)
                    delete(ctl);
                end
            end
        end

    end
    
    %% PROPERTY ACCESS
    methods        
        
        function v = get.mdlDefaultConfigProps(obj)
            v = obj.getDefaultConfigProps(class(obj));
        end
        
        function v = get.mdlDefaultHeaderProps(obj)
            v = obj.getDefaultHeaderProps(class(obj));           
        end
        
        function v = get.mdlPropSetVarName(obj)
            v = zlclVarNameForSaveAndRestore(class(obj));
        end 
        
    end
    
    %% USER METHODS
    methods

        function addController(obj,hController)
            %hController: Array of Controller objects
            
            validateattributes(hController,{'most.Controller'},{});
            
            for i=1:length(hController)
                obj.hController{end+1} = hController(i);
            end
        end
        
        function modelWarn(obj,warnMsg,varargin)
            if obj.mdlVerbose
                fprintf(2,[warnMsg '\n'],varargin{:});
            end            
        end
        
    end
    
    % Header/Config API
    methods
        
        % Save object configuration to file fname. This method starts with
        % the default configuration properties, then includes optional
        % 'include' or 'exclude' sets.
        %
        % incExcFlag (optional): either 'include' or 'exclude'
        % incExcList (optional): inclusion/exclusion property list (cellstr)
        function mdlSaveConfig(obj,fname,incExcFlag,incExcList)
            
            if nargin < 3
                incExcFlag = 'include';
                incExcList = cell(0,1);
            end
            assert(ischar(fname),'fname must be a filename.');
            assert(any(strcmp(incExcFlag,{'include';'exclude'})),...
                'incExcFlag must be either ''include'' or ''exclude''.');
            assert(iscellstr(incExcList),'incExcList must be a cellstring.');
                        
            defaultCfgProps = obj.mdlDefaultConfigProps;
            switch incExcFlag
                case 'include'
                    cfgProps = union(defaultCfgProps,incExcList);
                case 'exclude'
                    cfgProps = setdiff(defaultCfgProps,incExcList);
            end
                    
            obj.mdlSavePropSetFromList(cfgProps,fname);
        end
        
        function cfgPropSet = mdlLoadConfigToStruct(obj,fname)
            cfgPropSet = obj.mdlLoadPropSetToStruct(fname);            
        end
        
        function mdlLoadConfig(obj,fname)
            obj.mdlLoadPropSet(fname);
        end
        
        % xxx todo make this look like mdlSaveConfig with the include/exclude
        function mdlSaveHeader(obj,fname)
            % Save header properties of obj as a structure in a MAT file.

            pnames = obj.mdlDefaultHeaderProps;
            pnames = sort(pnames);
            obj.mdlSavePropSetFromList(pnames,fname);
        end
        
        % xxx make this more consistent with config?
        function str = modelGetHeader(obj,subsetType,subsetList,numericPrecision)
            % Get string encoding of the header properties of obj.
            %   subsetType: One of {'exclude' 'include'}
            %   subsetList: String cell array of properties to exclude from or include in header string
            %   numericPrecision: <optional> Number of digits to use in string encoding of properties with numeric values. Default value used otherwise.
            
            if nargin < 4 || isempty(numericPrecision)
                numericPrecision = []; %Use default
            end
            
            if nargin < 2 || isempty(subsetType)
                pnames =  obj.mdlDefaultHeaderProps;
            else
                assert(nargin >= 3,'If ''subsetType'' is specified, then ''subsetList'' must also be specified');
                
                switch subsetType
                    case 'exclude'
                        pnames = setdiff(obj.mdlDefaultHeaderProps,subsetList);
                    case 'include'
                        pnames = subsetList;
                    otherwise
                        assert('Unrecognized ''subsetType''');
                end
            end                        
            
            pnames = setdiff(pnames,obj.mdlHeaderExcludeProps);
            
            str = most.util.structOrObj2Assignments(obj,class(obj),pnames,numericPrecision);
        end        
            
    end
    
    %% SUPERUSER METHODS
    methods (Access=protected, Hidden)
        
        function mdlDummySetProp(obj,val,propName)
            %A standardized function to call from 'dummy' SetMethods defined for properties with 'DependsOn' metadata tag
            %Provides error message close to that which would normally be observed for setting a Dependent property with no SetMethod.
            assert(~obj.mdlInitialized || isnan(val),sprintf('In class ''%s'', no (non-dummy) set method is defined for Dependent property ''%s''.  A Dependent property needs a set method to assign its value.', class(obj), propName));
        end
        
        
    end
    
    %% DEVELOPER METHODS
    
    methods (Hidden)    
        
        function options = getPropOptions(obj,propName)
            %Gets the list of valid values for the specified property, if it exists
            
            options = [];
            
            if isfield(obj.mdlPropAttributes, propName)
                propAtt = obj.mdlPropAttributes.(propName);
                
                if isfield(propAtt,'Options')
                    optionsData = propAtt.Options;
                    if ischar(optionsData)
                        if ~isempty(findprop(obj,optionsData))
                            options = obj.(optionsData);
                        else
                            error('Invalid Options property metadata supplied for property ''%s''.',propName);
                        end
                    else
                        options = optionsData;
                    end
                end
            end
        end
        
    end
    
    %Controller robot-mode handling    
    methods (Access=protected)
        %TODO: Eliminate this layer by vectorizing the hController array (and having Controller handle)
        
        function zprvSetCtlrRobotMode(obj)
            for i=1:length(obj.hController)
                obj.hController{i}.robotModeSet();
            end            
        end
        
        function zprvResetCtlrRobotMode(obj)            
            for i=1:length(obj.hController)
                obj.hController{i}.robotModeReset();
            end
        end        
    end

    % PropSet API
    methods (Hidden) % Ultimately, protected
        
        % propNames: a cellstr of property names to get
        % propSet: a struct going from propNames to property values.
        %
        % Property values that are objects are ignored and set to [].
        function propSet = mdlGetPropSet(obj,propList)
            assert(iscellstr(propList),'propList must be a cellstring.');
            propSet = struct();
            for c = 1:numel(propList)
                pname = propList{c};
                try
                    val = obj.(pname);
                    if isobject(val)
                        propSet.(pname) = [];
                    else
                        propSet.(pname) = val;
                    end
                catch %#ok<CTCH>
                    warning('DClass:mdlGetPropSet:ErrDuringPropGet',...
                        'An error occured while getting property ''%s''.',pname);
                    propSet.(pname) = [];
                end
            end
        end
        
        % Apply a propSet to obj. Original values for the affected
        % properties are returned in origPropSet. 
        %
        % tfOrderByPropAttribs (optional): bool, default=true. If true,
        % then apply the property sets in the order specified by
        % obj.mdlPropAttributes. If false, apply property sets in the order
        % of fields in propSet.
        function origPropSet = mdlApplyPropSet(obj,propSet,tfOrder)
            assert(isstruct(propSet));
            if nargin < 3
                tfOrder = true;
            end
            assert(isscalar(tfOrder) && islogical(tfOrder));

            propNames = fieldnames(propSet);
            if tfOrder
                propNames = obj.mdlOrderPropList(propNames);                
            end
            
            obj.zprvSetCtlrRobotMode(); %Set controller(s)' robot mode
            
            try
                origPropSet = struct();
                for c = 1:numel(propNames)
                    pname = propNames{c};
                    try
                        origPropSet.(pname) = obj.(pname);
                        obj.(pname) = propSet.(pname);
                    catch ME 
                        warning('Model:errSettingProp',...
                            'Error getting/setting property ''%s''. (Line %d of function ''%s'')',pname,ME.stack(1).line,ME.stack(1).name);
                        if ~isfield(origPropSet,pname)
                            origPropSet.(pname) = [];
                        end
                    end
                end
            catch ME
                obj.zprvResetCtlrRobotMode();
                ME.rethrow();
            end
            
            obj.zprvResetCtlrRobotMode();            
        end
        
        % Save a propset to the specified MAT-file. The file is assumed to
        % be a MAT-file. The propSet is overwritten/appended to the
        % MAT-file.
        function mdlSavePropSet(obj,propSet,fname)
            assert(isstruct(propSet));
            assert(ischar(fname));

            varname = obj.mdlPropSetVarName;
            tmp.(varname) = propSet; %#ok<STRNU>
            
            % if (varname) already exists in the file, it will be
            % overwritten
            if exist(fname,'file')==2
                save(fname,'-struct','tmp','-mat','-append');
            else
                save(fname,'-struct','tmp','-mat');
            end
        end
        
        function mdlSavePropSetFromList(obj,propList,fname)
            propSet = obj.mdlGetPropSet(propList);
            obj.mdlSavePropSet(propSet,fname);            
        end
        
        % Load contents of propSet file to propSet struct.
        function propSet = mdlLoadPropSetToStruct(obj,fname)

            assert(exist(fname,'file')==2,'File ''%s'' not found.',fname);
            if isempty(obj)
                propSet = [];
                return;
            end            
            
            fileVars = load(fname,'-mat');
            varname = obj.mdlPropSetVarName;
            if ~isfield(fileVars,varname)
                error('DClass:varNotFound',...
                    'No property information for class ''%s'' found in file ''%s''.',class(obj),fname);
            end
            
            propSet = fileVars.(varname);
        end
        
        function mdlLoadPropSet(obj,fname)
            propSet = obj.mdlLoadPropSetToStruct(fname);
            obj.mdlApplyPropSet(propSet);
        end
        
        % Order property list by mdlPropAttributes. properties not
        % references in mdlPropAttributes are put at the end of the ordered
        % list.
        function propList = mdlOrderPropList(obj,propList)
            assert(iscellstr(propList));
            mdlPropAttribList = fieldnames(obj.mdlPropAttributes);
            [srted unsrted] = zlclGetSortedSubset(propList,mdlPropAttribList);
            propList = [srted(:);unsrted(:)];
        end        
        
    end
    
    methods (Access=protected)
                    
%         function props = getOrderedSaveableProps(obj)
%             p = fieldnames(obj.mdlPropAttributes);
%             tf = ismember(p,obj.mdlDefaultConfigProps);
%             props = p(tf);    
%         end
        
        function str = genAssertMsg(obj,val)
            %General error message to use for assertion failure in property  set-access methods
            %TODO: Factor this out one way or another (smartProperties??)
            %TODO: Possibly allow property name to be (optionally) specified, and reported in message
            
            if ischar(val) && isvector(val)
                str = sprintf('Value supplied (''%s'') not valid. Property was not set.',val);
            elseif isnumeric(val)
                str = sprintf('Value supplied (''%g'') not valid. Property was not set.',val);
            else
                str = sprintf('Invalid value supplied. Property was not set.');
            end
            
        end
        
        function val = validatePropArg(obj,propname,val)

            % Validate/convert a property value, using specifications as in
            % most.mimics.validateAttributes.
            %           
            % TAGS
            %
            %   Classes: <String or string cell array> As in most.mimics.validateAttributes.
            %   Attributes: <String or cell array> As in most.mimics.validateAttributes.
            %   AllowEmpty: <0 or 1> Specifies whether to allow empty values. This removes the 'nonempty' attribute supplied by default, and also enables 'AllowEmptyDouble' as in most.mimics.validateAttributes.
            %   Range: <Numeric or cell 2-vector or string> If numeric, as in most.mimics.validateAttributes. If a cell array, string values are the names of object properties supplying the min/max value for the range. If a string, the name of single property supplying the numeric 2-vector range.
            %   Size: <Numeric or cell array or string> If numeric, as in most.mimics.validateAttributes. If a cell array, elements are either numbers (sizes along dimensions) or object property names which return numbers. If a string, the name of a single property supplying the 'size' specification.
            %   Options: <Cell or numeric array, or string>  If a cell or numeric array, as in most.mimics.validateAttributes. If a string, the name of an object property supplying the options specification.
            %   List: <Integer scalar/array, or empty val, or Inf, or string member of {'vector' 'fullvector'}, or string> As in most.mimics.validateAttributes, unless a string. If a string, then the name of an object property supplying the list specification.
            %   CustomValidateFcn: <scalar fcn handle with signature val=f(val). The function should throw an error for invalid values, and return an (optionally) converted value. For property validation, this overrides all other tags. (Other tags may be present in the metadata for other purposes however.)
            %
            % NOTES
            %   * The 'nonempty' attribute is included by
            %   default. This can be overridden by using the
            %   AllowEmpty tag.
            %   The 'scalar' attribute is included by default. This is
            %   overridden when one of {'size' 'vector' 'numel'
            %   'nonscalar'} is included in the Attributes, when Options
            %   are specified, etc.
            %
            % TIPS
            %   Options (of numeric type) and Size tags can be combined for properties which are matrices comprising a list of array-values, with both the array-value options and the length being specifiable (possibly as object properties).
            %   To test for a flexible logical array (either 0/1 or true/false array), specify 'binary' as one of Attributes (no need to specify Classes)
            %
            %   TODO: What to do with AllowEmpty & Options combination?? For numeric Options, at moment empty values are not allowed, but they might want to be in some cases??
            %   TODO: Support for Size more/all of the options that are supported for List (Inf, empty val)
            
            ERRORARGS = {'most:Model:invalidPropVal', ...
                'Invalid value for property ''%s'' supplied:\n\t%s\n',...
                propname};
            
            propMDAll = obj.mdlPropAttributes;
            
            if isfield(propMDAll,propname)
                propMD = propMDAll.(propname);
                
                if isfield(propMD,'CustomValidateFcn')
                    fcn = propMD.CustomValidateFcn;
                    try
                        val = fcn(val);
                    catch ME
                        error(ERRORARGS{:},ME.message);
                    end
                    return;
                end

                if isfield(propMD,'Classes')
                    propMD.Classes = cellstr(propMD.Classes(:)');
                elseif ~isfield(propMD,'options') && any(isfield(propMD,{'Attributes' 'Size' 'Range'}))
                    % default to numeric
                    propMD.Classes = {'numeric'};
                end
                
                if isfield(propMD,'Attributes');
                    if ischar(propMD.Attributes)
                        propMD.Attributes = {propMD.Attributes};
                    end
                    propMD.Attributes = propMD.Attributes(:)';
                else
                    propMD.Attributes = cell(1,0);
                end
                
                if isfield(propMD,'Range')
                    try
                        rangeAttribs = obj.zprvRangeData2Attribs(propname,propMD.Range);
                    catch ME
                        ME.throwAsCaller();
                    end
                    propMD.Attributes = [propMD.Attributes rangeAttribs];
                end
                
                if isfield(propMD,'Size')
                    try
                        sizeAttribs = obj.zprvSizeData2Attribs(propname,propMD.Size);
                    catch ME
                        ME.throwAsCaller();
                    end
                    propMD.Attributes = [propMD.Attributes sizeAttribs];
                end
                
                if isfield(propMD,'Options')
                    if ischar(propMD.Options)
                        propMD.Options = obj.(propMD.Options);
                    end
                end
                
                if isfield(propMD,'List')
                    listVal = propMD.List;
                    if ischar(listVal)
                        switch lower(listVal)
                            case {'vector' 'fullvector'}
                            otherwise
                                propMD.List = obj.(listVal);
                        end
                    end
                end
                    
                tfAllowEmpty = isfield(propMD,'AllowEmpty') && propMD.AllowEmpty;
                if tfAllowEmpty
                    % At moment, not actively removing 'nonempty' if it's in
                    % attributes with AllowEmpty.
                    %
                    % AL: Strictly speaking the next line is wrong, what if
                    % someone wants to enable empties, but still restrict
                    % the class?
                    propMD.AllowEmptyDouble = true;                    
                else
                    if isfield(propMD,'Options') && iscell(propMD.Options)
                        % attribs ignored when using cell options
                    else                        
                        propMD.Attributes = [propMD.Attributes 'nonempty'];
                    end
                end

                tfCharAttrib = cellfun(@ischar,propMD.Attributes);
                charAttrib = propMD.Attributes(tfCharAttrib);
                if isfield(propMD,'Options')
                elseif isfield(propMD,'AllowEmpty') && propMD.AllowEmpty
                elseif isfield(propMD,'Classes') && any(strcmpi('string',propMD.Classes))
                elseif any(ismember({'nonscalar' 'size' 'numel' 'vector'},lower(charAttrib)))
                else
                    %Add 'scalar' attribute, by "default"
                    propMD.Attributes = [propMD.Attributes 'scalar'];
                end
                                
                cellPV = most.util.structPV2cellPV(propMD);
                try
                    most.mimics.validateAttributes(val,cellPV{:});
                catch ME
                    error(ERRORARGS{:},ME.message);
                end
                
                % AL: we used to convert empty values for cellstr/string
                % classes:
%                 if isempty(val)
%                     assert(allowEmpty,errorArgs{:});
%                     if ismember('cellstr',classesData)
%                         val = {};
%                     else
%                         val = '';
%                     end
%                 end
                                    
            end
            
        end
        
        function sizeAttributes = zprvSizeData2Attribs(obj,propname,sizeData)
            
            ERRORARGS = {'Invalid ''Size'' property metadata supplied for property ''%s''.',propname};
            
            if ischar(sizeData)
                sizeAttributes = obj.zprvSizeData2Attribs(propname,obj.(sizeData));
            elseif isnumeric(sizeData)
                sizeAttributes = {'Size' sizeData};
            elseif iscell(sizeData)
                sizeVal = zeros(size(sizeData));
                for j=1:numel(sizeData)
                    sizeDataVal = sizeData{j};
                    if isnumeric(sizeDataVal)
                        sizeVal(j) = sizeDataVal;
                    elseif ischar(sizeDataVal) && ~isempty(findprop(obj,sizeDataVal))
                        tmp = obj.(sizeDataVal);
                        try
                            validateattributes(tmp,{'numeric'},{'scalar' 'integer' 'nonnegative'});
                        catch %#ok<CTCH>
                            error('most:Model:invalidSize',ERRORARGS{:});
                        end
                        sizeVal(j) = tmp;
                    else
                        error('most:Model:invalidSize',ERRORARGS{:});
                    end
                end
                sizeAttributes = {'Size' sizeVal};
            else
                error('most:Model:invalidSize',ERRORARGS{:});
            end            
        end
        
        function attribs = zprvRangeData2Attribs(obj,propname,rangeMD)
            ERRORARGS = {'Invalid ''Range'' property metadata supplied for property ''%s''.' propname};

            if ischar(rangeMD)
                attribs = obj.zprvRangeData2Attribs(propname,obj.(rangeMD));
            elseif isnumeric(rangeMD)
                assert(numel(rangeMD)==2,ERRORARGS{:});
                attribs = {'Range' rangeMD};
            elseif iscell(rangeMD)
                assert(numel(rangeMD)==2,ERRORARGS{:});
                rangeVal = nan(1,2);
                for idx = 1:2
                    if isnumeric(rangeMD{idx})
                        rangeVal(idx) = rangeMD{idx};
                    elseif ischar(rangeMD{idx})
                        rangeVal(idx) = obj.(rangeMD{idx}); % better be a numeric scalar
                    else
                        error('most:Model:invalidRange',ERRORARGS{:});
                    end
                end
                attribs = {'Range' rangeVal};
            else
                error('most:Model:invalidRange',ERRORARGS{:});
            end
        end
        
    end
    
    methods (Static,Access=protected)
  
        function propNames = getDefaultConfigProps(clsName)
            fcn = @(x)(strcmpi(x.SetAccess,'public') && strcmpi(x.GetAccess,'public') && ...
                       ~x.Transient && ~x.Dependent && ~x.Constant && ~x.Hidden);
            propNames = most.Model.getAllPropsWithCriterion(clsName,fcn);                    
        end
        
        function propNames = getDefaultHeaderProps(clsName)
            fcn = @(x)(strcmpi(x.GetAccess,'public') && ~x.Hidden);
            propNames = most.Model.getAllPropsWithCriterion(clsName,fcn);
        end
        
        % predicateFcn is a function that returns a logical when given a
        % meta.Property object
        function propNames = getAllPropsWithCriterion(clsName,predicateFcn)
            mc = meta.class.fromName(clsName);
            ps = mc.Properties;
            tf = cellfun(predicateFcn,ps);
            ps = ps(tf);
            propNames = cellfun(@(x)x.Name,ps,'UniformOutput',false);     
        end
        
        % returns true if propName can be utilized as a config prop for the
        % given class.
        function tf = isPropConfigable(clsName,propName)
            mc = meta.class.fromName(clsName);
            allmp = mc.Properties;
            tf = cellfun(@(x)strcmp(x.Name,propName),allmp);
            assert(nnz(tf)==1);
            
            mp = allmp(tf);
            tf = strcmpi(mp.SetAccess,'public') && strcmpi(mp.GetAccess,'public');
        end
        
%         % This saves the specified properties of obj as a struct into the
%         % specified MATfile. The properties are put in the struct in order.
%         % The variable name stored in the MATfile is the classname of obj.      
%         function savePropsInOrder(obj,props,filename)
%             
%             s = obj.mdlGetPropSet(props);
%             
%             % generate a varname to save in the mat file
%             varname = zlclVarNameForSaveAndRestore(class(obj));
%             tmp.(varname) = s; %#ok<STRNU>
%             
%             % if (varname) already exists in the file, it will be
%             % overwritten
%             save(filename,'-struct','tmp');            
%         end
        
    end
            
end

%         % Saves the values of all properties in propList to the config file
%         % fname. The properties will be not necessarily be saved in the
%         % order given by propList. (The order is restricted as necessary by
%         % the ordering of mdlPropAttributes.)
%         function mdlSavePropSetFromList(obj,propList,fname)
%             
%             if numel(obj)~=1
%                 error('DClass:mdlSavePropSetFromList:invalidArg','obj must be a scalar object.');
%             end
%             
%             allSaveableProps = obj.getAllConfigSaveableProps;
%             tfSaveable = ismember(propList,allSaveableProps);
%             if ~all(tfSaveable)
%                 error('DClass:mdlSavePropSetFromList:invalidProp',...
%                       'One or more specified properties cannot be saved to a configuration.');
%             end
%             
%             allOrderedProps = obj.getOrderedSaveableProps;
%             [sortedProps unsortedProps] = zlclGetSortedSubset(propList,allOrderedProps);
%             propList = [sortedProps;unsortedProps];
%             
%             obj.savePropsInOrder(propList,fname);            
%            
%         end


%         function mdlRestorePropSubset(obj,fname)
%              assert(false,'Obsolete');
% %             if isempty(obj)
% %                 return;
% %             end
% %             
% %             s = load(fname,'-mat');
% %             varname = zlclVarNameForSaveAndRestore(class(obj));
% %             if ~isfield(s,varname)
% %                 error('DClass:mdlRestorePropSubset:ClassNotFound',...
% %                     'No information for class ''%s'' found in config file ''%s''.',class(obj),fname);
% %             end
% %             s = s.(varname);
% %             propList = fieldnames(s);
% %             
% %             
% %             % restore in order of current propMetadata (order in saved struct may be different)
% %             allSaveableProps = obj.getAllConfigSaveableProps;
% %             tfSaveable = ismember(propList,allSaveableProps);
% %             notfound = propList(~tfSaveable);
% %             for c = 1:numel(notfound)
% %                 warning('DClass:mdlRestorePropSubset',...
% %                     'Property ''%s'' saved to configuration cannot be restored.',notfound{c});
% %             end
% %             propList = propList(tfSaveable);
% %             
% %             allOrderedProps = obj.getOrderedSaveableProps;
% %             [sortedProps unsortedProps] = zlclGetSortedSubset(propList,allOrderedProps);
% %             propList = [sortedProps;unsortedProps];
% %             
% %             for c = 1:numel(propList)
% %                 pname = propList{c};
% %                 for d = 1:numel(obj)
% %                     try
% %                         obj(d).(pname) = s.(pname);
% %                     catch %#ok<CTCH>
% %                         warning('DClass:mdlRestorePropSubset:ErrDuringPropSet',...
% %                             'An error occured while restoring property ''%s''.',pname);
% %                     end
% %                 end
% %             end            
%         end


% sortedSubset is the subset of list that is in sortedReferenceList.
% sortedSubset is sorted by the reference list. unsortedSubset is the
% remainder of list. Its order is indeterminate.
function [sortedSubset unsortedSubset] = zlclGetSortedSubset(list,sortedReferenceList)

[tfOrdered loc] = ismember(list,sortedReferenceList);
sortedSubset = sortedReferenceList(sort(loc(tfOrdered)));
unsortedSubset = setdiff(list,sortedSubset);

end

function n = zlclVarNameForSaveAndRestore(clsName)
    n = regexprep(clsName,'\.','_');
end
        
