classdef SI4Controller < most.Controller
    %SI4CONTROLLER Controller for the ScanImage application
    
    %TODO: Multi-control logic mediated by this class should be considered for generalization via Controller and PropControl mechanisms TBD (e.g. the 'beam-indexed' properties).
    %       Alternatively, some recurring logic for handling such things should be provided by Controller base class
    %TODO: Eventually Controller should provide some facility for having 'deferred' updateView calls -- i.e. manual updates after intervening logic, rather than forcibly bound listener
    
    
    %% ABSTRACT PROPERTY REALIZATIONS (most.Controller)
    properties (SetAccess=protected)
        propBindings = lclInitPropBindings();
    end
    
    %% PUBLIC PROPERTIES
    properties
        beamDisplayIdx=1; %Index of beam whose properties are currently displayed/controlled
        channelsTargetDisplay; %A value indicating 'active' channel display, or Inf, indicating the merge display figure. If empty, no channel is active.
        scanPhaseDisplay = 'hardware'; %<One of {'software' 'hardware'} indicating which of scanPhase/scanPhaseCoarse model properties is currently being displayed/controlled
    end
    
    %% PRIVATE/PROTECTED PROPERTIES
    properties (Hidden)
        beamProp2Control; %Scalar struct. Fields: SI beam property name. values: uicontrol handle arrays for that prop. The properties in this struct must be beam-indexed (with round brackets).
        
        motorUserPositionIndex;
        motorStepSize = [0.1 0.1 0.1]; %Step size to use, in um, for motor increment/decrement operations in X,Y,Z axes. Z axis value pertains to active Z controller, if secondary is present.
        motorErrorListeners = [];
        
        scanZoomConfigIdx=1; %Index of scanZoomFactor to use for editing/displaying the zoom-arrayed parameters
        scanZoomIndexedPropsStruct; %Structure pertaining to zoom-indexed scan properties
        
        hChannelConfig;
        
        usrSettingsPropListeners; % col vec of listener objects used for userSettingsV4
    end
    
    properties (Hidden,Dependent)
        hMainPbFastCfg; % 6x1 vector of MainControls fastCfg buttons
        userFunctionsViewType; % string enum; either 'CFG', 'USR', or 'none'.
        userFunctionsCurrentEvents;
        userFunctionsCurrentProp;
        mainControlsStatusString;
    end
    
    properties (Constant,Hidden)
        motorMaxNumUserDefinedPositions = 100;
    end
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = SI4Controller(hModel)
            obj = obj@most.Controller(hModel,...
                {'mainControlsV4' 'powerControlsV4' 'motorControlsV4' 'triggerControlsV4' 'imageControlsV4' 'fastZControlsV4'}, ...
                {'configControlsV4' 'channelControlsV4' 'triggerControlsV4' 'fastConfigurationV4' 'userSettingsV4' 'userFunctionControlsV4' 'pmtControlsV4' 'posnControlsV4'});
            
            %Capture keypresses for FastCfg F-key behavior. At moment, set
            %KeyPressFcn for all figures, uicontrols, etc so that all
            %keypresses over SI guis are captured. This can be modified
            %if/when certain figures/uicontrols need their own KeyPressFcns.
            structfun(@(handles)obj.ziniSetKeyPressFcn(handles),obj.hGUIData);
            
            %GUI Initializations
            obj.ziniMainControls();
            obj.ziniConfigControls();
            obj.ziniImageControls();
            obj.ziniChannelControls();
            obj.ziniPowerControls();
            obj.ziniMotorControls();
            obj.ziniPosnControls();
            obj.ziniFastZControls();
            obj.ziniTriggerControls();
            
            obj.ziniFigPositions();
            
            % imageControlsV4.pmTargetFigure
            optionStrings = cell(obj.hModel.channelsNumChannels+2,1);
            optionStrings{1} = 'None';
            for i = 1:obj.hModel.channelsNumChannels
                optionStrings{i+1} = sprintf('Chan %d',i);
            end
            optionStrings{end} = 'Merge';
            set(obj.hGUIData.imageControlsV4.pmTargetFigure,'String',optionStrings);
            set(obj.hGUIData.imageControlsV4.pmTargetFigure,'Value',1);
            
            %             AL: ???, doesn't compute
            %             obj.hChannelConfig = findobj(obj.hGUIs.channelControlsV4,'Tag', 'pcChannelConfig');
            
            % Initialize tables in userFunctionControlsV4
            obj.hGUIData.userFunctionControlsV4.uft.refresh();
            obj.hGUIData.userFunctionControlsV4.uftOverride.refresh();
            
            
            % Initialize figure windows, where possible
            if ~obj.hModel.fastZAvailable
                obj.hideGUI('fastZControlsV4');
            end
            
            if isempty(obj.hModel.hPMT)
                obj.killGUI('pmtControlsV4');
            else
                obj.showGUI('pmtControlsV4');
            end
            
            %Listener Initializations
            obj.hModel.addlistener('motorPositionUpdate',@(src,evnt)obj.changedMotorPosition);
            
            %Initialize controller properties with set-access side-effects
            obj.motorStepSize = obj.motorStepSize;
            
            
        end
        
        function initialize(obj)
            %             % AL 7/6/2011. This is needed due to another variant of the
            %             % motor bug. After adding code to save layout for channel
            %             % display figs to user files, I found that on startup, timeout
            %             % would occur when reading SI4.motorPosition while
            %             % initializing the GUI (changedMotorPosition).
            %             drawnow;
            
            initialize@most.Controller(obj);
            
            %VI081311: Should likely move to constructor
            %Initialize additional properties
            obj.beamDisplayIdx = obj.beamDisplayIdx;
            obj.channelsTargetDisplay = obj.channelsTargetDisplay;
            obj.motorUserPositionIndex = 1;
            
            
            obj.ziniUsrSettingsGUI(); %VI081311: Should likely move to constructor
            
            
            %TODO: Initialize state of 'showAdvanced' and 'showOtherGUI' type toggle-buttons based on what's visible, now that USR file has been loaded
            
            %GUI initializations dependent on App initialization
            %obj.ziniMotorInitMotorControls();
            
            %
        end
        
        function zcbkKeyPress(obj,~,evt)
            % Currently this handles keypresses for all SI4 guis
            switch evt.Key
                case {'f1' 'f2' 'f3' 'f4' 'f5' 'f6'}
                    idx = str2double(evt.Key(2));
                    
                    tfRequireCtrl = get(obj.hGUIData.fastConfigurationV4.cbRequireControl,'Value');
                    tfLoadFastCfg = ~tfRequireCtrl || ismember('control',evt.Modifier);
                    tfBypassAutoStart = ismember('shift',evt.Modifier);
                    
                    if tfLoadFastCfg
                        obj.hModel.fastCfgLoadConfig(idx,tfBypassAutoStart);
                    end
            end
        end
        
        function ziniSetKeyPressFcn(obj,handles)
            tags = fieldnames(handles);
            for c = 1:numel(tags)
                h = handles.(tags{c});
                if isprop(h,'KeyPressFcn')
                    set(h,'KeyPressFcn',@(src,evt)obj.zcbkKeyPress(src,evt));
                end
            end
        end
        
        function ziniFigPositions(obj)
            most.gui.setPixelLocation(obj.hGUIs.mainControlsV4,[12 788]);
            most.gui.setPixelLocation(obj.hGUIs.motorControlsV4,[12 604]);
            most.gui.setPixelLocation(obj.hGUIs.powerControlsV4,[344 647]);
            most.gui.setPixelLocation(obj.hGUIs.imageControlsV4,[12 137]);
            most.gui.setPixelLocation(obj.hGUIs.fastZControlsV4,[586 616]);

            setpixelposition(obj.hModel.channelsHFig(1),[276 156 408 408]);
            setpixelposition(obj.hModel.channelsHFig(2),[701 156 408 408]);  %Invisible by default
            % PR2014
            setpixelposition(obj.hModel.channelsHFig(3),[1127 156 408 408]);  %Invisible by default
%             setpixelposition(obj.hModel.channelsHFig(4),[928 657 408 408]);  %Invisible by default
            setpixelposition(obj.hModel.channelsHMergeFig,[970 611 490 490]);  %Invisible by default

        end
        
        
        function ziniMainControls(obj)
            
            %Disable controls for currently unimplemented features
%             most.gui.disableAll(obj.hGUIData.mainControlsV4.pnlROIControls);
            
            disabledControls = {'stCycleIteration' 'stCycleIterationOf' 'etIterationsDone' 'etIterationsTotal' 'tbCycleControls' ...
                'stScanRotation' 'scanRotation' 'scanRotationSlider' 'zeroRotate' ...
                'stScanShiftSlow' 'stScanShiftFast' 'scanShiftSlow' 'scanShiftFast' ...
                'xstep' 'ystep' 'left' 'right' 'centerOnSelection' ... % 'up' 'down' 'zero' ...
                'zoomhundredsslider' 'zoomhundreds' ...
                'etScanAngleMultiplierFast' ...
                'pbLastLine' 'pbLastLineParent' ...
                'snapShot' 'numberOfFramesSnap'};
            
            cellfun(@(s)set(obj.hGUIData.mainControlsV4.(s),'Enable','off'),disabledControls);
            
            %Disable menu items for currently unimplemented features
            disabledMenuItems = {   'mnu_File_LoadCycle' 'mnu_File_SaveCycle' 'mnu_File_SaveCycleAs' ...
                'mnu_Settings_Beams' 'mnu_Settings_ExportedClocks' ...
                'mnu_View_CycleModeControls' 'mnu_View_ROIControls' 'mnu_View_PosnControls' ...
                'mnu_View_Channel1MaxDisplay' 'mnu_View_Channel2MaxDisplay' 'mnu_View_Channel3MaxDisplay' 'mnu_View_Channel4MaxDisplay'};
            
            cellfun(@(s)set(obj.hGUIData.mainControlsV4.(s),'Enable','off'),disabledMenuItems);
            
            %Re-purpose 'Align' controls toggle button to Point/Park control
            hPointBtn = obj.hGUIData.mainControlsV4.tbShowAlignGUI;
            set(hPointBtn,'Value',0);
            obj.changedPointButton(hPointBtn);
            
        end
        
        function ziniConfigControls(obj)
            
            %Hide controls not used in SI4
            hideControls = {'tbShowAdvanced' 'pbApplyConfig'};
            cellfun(@(s)set(obj.hGUIData.configControlsV4.(s),'Visible','off'), hideControls);
            
            %Disable controls with features not supported in SI4.1
            disableControls = {'stShutterDelay' 'stShutterDelayMs' 'etShutterDelay'};
            cellfun(@(s)set(obj.hGUIData.configControlsV4.(s),'Enable','off'), disableControls);
            
            %Tether default location to Main Controls (can later be overridden by user settings, if desired)
            most.gui.tetherGUIs(obj.hGUIs.mainControlsV4, obj.hGUIs.configControlsV4, 'righttop');
            
        end
        
        function ziniChannelControls(obj)
            
            %             handles = obj.hGUIData.channelControlsV4;
            %
            %             %Initialize Channel table PropControl
            %             hColArrayTable = most.gui.control.ColumnArrayTable(handles.tblChanConfig);
            %             handles.pcChannelConfig =  hColArrayTable;
            %             guidata(hSICtl.hGUIs.channelControlsV4,handles);
            %
            %             hColArrayTable.resize(obj.hModel.channelsNumChannels);
            
            obj.hGUIData.channelControlsV4.pcChannelConfig.resize(obj.hModel.channelsNumChannels);
            obj.hGUIData.channelControlsV4.channelImageHandler.initColorMapsInTable(); % re-init to deal with resize
            obj.hGUIData.channelControlsV4.channelImageHandler.registerChannelImageFigs(obj.hModel.channelsHFig);
        end
        
        function ziniImageControls(obj)
            
            %Initialize menubars
            set(obj.hGUIData.imageControlsV4.mnu_Settings_AverageSamples,'Enable','off'); %Average samples option not available in SI4
            set(obj.hGUIData.imageControlsV4.mnuPMTOffsets,'Visible','off'); %Hide PMT offsets
            
            %Initialize channel LUT controls
            for i=1:obj.hModel.channelsMaxNumber
                
                if i > obj.hModel.channelsNumChannels
                    set(findobj(obj.hGUIData.imageControlsV4.(sprintf('pnlChan%d',i)),'Type','uicontrol'),'Enable','off');
                    
                    set(obj.hGUIData.imageControlsV4.(sprintf('blackSlideChan%d',i)),'Min',0,'Max',1,'SliderStep',[.01 .1],'Value',0);
                    set(obj.hGUIData.imageControlsV4.(sprintf('whiteSlideChan%d',i)),'Min',0,'Max',1,'SliderStep',[.01 .1],'Value',0);
                    
                    set(obj.hGUIData.imageControlsV4.(sprintf('blackEditChan%d',i)),'String',num2str(0));
                    set(obj.hGUIData.imageControlsV4.(sprintf('whiteEditChan%d',i)),'String',num2str(0));
                else
                    %Allow 10-percent of negative range, if applicable
                    set(obj.hGUIData.imageControlsV4.(sprintf('blackSlideChan%d',i)),'Min',obj.hModel.channelsLUTRange(1)/10,'Max',obj.hModel.channelsLUTRange(2),'SliderStep',[.01 .1]);
                    set(obj.hGUIData.imageControlsV4.(sprintf('whiteSlideChan%d',i)),'Min',obj.hModel.channelsLUTRange(1)/10,'Max',obj.hModel.channelsLUTRange(2),'SliderStep',[.01 .1]);
                end
            end
            
            %Move Frame Averaging/Selection panel up if there are 2 or less channels
            if obj.hModel.channelsNumChannels <= 3
                
                charShift = (obj.hModel.channelsMaxNumber - 3) * 5;
                
                for i=4:obj.hModel.channelsMaxNumber
                    hPnl = obj.hGUIData.imageControlsV4.(sprintf('pnlChan%d',i));
                    set(hPnl,'Visible','off');
                    set(findall(hPnl),'Visible','off');
                end
                
                for i=1:3
                    hPnl = obj.hGUIData.imageControlsV4.(sprintf('pnlChan%d',i));
                    set(hPnl,'Position',get(hPnl,'Position') + [0 -charShift 0 0]);
                end
                
                %                 hPnl = obj.hGUIData.imageControlsV4.pnlAveragingAndSelection;
                %                 set(hPnl,'Position',get(hPnl,'Position') + [0 charShift 0 0]);
                %
                %                 hPnl = obj.hGUIData.imageControlsV4.pnlImageTools;
                %                 set(hPnl,'Position',get(hPnl,'Position') + [0 charShift 0 0]);
                
                hFig = obj.hGUIs.imageControlsV4;
                set(hFig,'Position',get(hFig,'Position') + [0 charShift 0 -charShift]);
                
            end
        end
        
        function ziniPowerControls(obj)
            set(obj.hGUIData.powerControlsV4.stPowerBox,'Enable','off');
            set(obj.hGUIData.powerControlsV4.tbShowPowerBox,'Enable','off');
            
            if obj.hModel.beamNumBeams > 1
                set(obj.hGUIData.powerControlsV4.sldBeamIdx,'Max',obj.hModel.beamNumBeams,'Min',1);
            else
                set(obj.hGUIData.powerControlsV4.sldBeamIdx,'Max',2,'Min',0,'Enable','off');
            end
            
            if obj.hModel.beamNumBeams
                znstConnectBeamPropToBeamControl('beamPowers',[findobj(obj.hGUIs.powerControlsV4,'Tag','etBeamPower');...
                    findobj(obj.hGUIs.powerControlsV4,'Tag','sldBeamPower')]);
                znstConnectBeamPropToBeamControl('beamPowerLimits',[findobj(obj.hGUIs.powerControlsV4,'Tag','etMaxLimit');...
                    findobj(obj.hGUIs.powerControlsV4,'Tag','sldMaxLimit')]);
                znstConnectBeamPropToBeamControl('beamLengthConstants',findobj(obj.hGUIs.powerControlsV4,'Tag','etZLengthConstant'));
                znstConnectBeamPropToBeamControl('beamPzAdjust',findobj(obj.hGUIs.powerControlsV4,'Tag','cbPzAdjust'));
                
                set(obj.hGUIData.powerControlsV4.pumBeamIdx,'Value',1);
                set(obj.hGUIData.powerControlsV4.sldBeamIdx,'Value',1);
                
                %TODO: Review the following, copied from prior constructor code -- is this needed? why not handled via normal initialization mechanism?
                obj.changedBeamPowerUnits();
            else
                most.gui.disableAll(obj.hGUIs.powerControlsV4);
                obj.hideGUI('powerControlsV4');
            end
            
            %TODO: Support this 'dynamic' binding of control to a property as a Controller method OR support a Pcontrol for binding to array vals with display/control of 1 index at a time determined by an index control
            function znstConnectBeamPropToBeamControl(propName,hControls)
                obj.beamProp2Control.(propName) = hControls;
                set(hControls,'UserData',propName);
            end
        end
        
        function ziniMotorControls(obj)
            
            %Disable all if motor is disabled
            if ~obj.hModel.motorHasMotor
                most.gui.disableAll(obj.hGUIs.motorControlsV4);
                return;
            end
            
            %Disable controls for features not supported in SI4
            disabledControls = {'etPosnID' 'stPosnID'};
            cellfun(@(s)set(obj.hGUIData.motorControlsV4.(s),'Enable','off'),disabledControls);
            
            if obj.hModel.motorHasSecondMotor
                set(obj.hGUIData.motorControlsV4.pbZeroXY,'Visible','off');
                set(obj.hGUIData.motorControlsV4.pbZeroZ,'Visible','off');
                set(obj.hGUIData.motorControlsV4.pbAltZeroXY,'Visible','on');
                set(obj.hGUIData.motorControlsV4.pbAltZeroZ,'Visible','on');
                set(obj.hGUIData.motorControlsV4.cbSecZ,'Visible','on');
                set(obj.hGUIData.motorControlsV4.etPosZZ,'Visible','on');
                
                switch obj.hModel.motorDimensionConfiguration
                    case 'xyz-z'
                        set(obj.hGUIData.motorControlsV4.etPosZZ,'Enable','on');
                    otherwise
                        set(obj.hGUIData.motorControlsV4.etPosZZ,'Enable','off');
                end
            else
                set(obj.hGUIData.motorControlsV4.pbZeroXY,'Visible','on');
                set(obj.hGUIData.motorControlsV4.pbZeroZ,'Visible','on');
                set(obj.hGUIData.motorControlsV4.pbAltZeroXY,'Visible','off');
                set(obj.hGUIData.motorControlsV4.pbAltZeroZ,'Visible','off');
                set(obj.hGUIData.motorControlsV4.cbSecZ,'Visible','off');
                set(obj.hGUIData.motorControlsV4.etPosZZ,'Visible','off');
            end
            
            listnrs = obj.hModel.hMotor.addlistener('LSCError',...
                @(src,evt)obj.motorErrorCbk(src,evt));
            if obj.hModel.motorHasSecondMotor
                listnrs(end+1,1) = obj.hModel.hMotorZ.addlistener('LSCError',...
                    @(src,evt)obj.motorErrorCbk(src,evt));
            end
            obj.motorErrorListeners = listnrs;
        end
        
        
        function ziniPosnControls(obj)
            set(obj.hGUIData.posnControlsV4.sldPositionNumber,'Min',0);
            set(obj.hGUIData.posnControlsV4.sldPositionNumber,'Max',obj.motorMaxNumUserDefinedPositions);
            set(obj.hGUIData.posnControlsV4.sldPositionNumber,'SliderStep',[1/obj.motorMaxNumUserDefinedPositions 3/obj.motorMaxNumUserDefinedPositions]);
            set(obj.hGUIData.posnControlsV4.sldPositionNumber,'Value',0);
        end
        
        function ziniUsrSettingsGUI(obj)
            availableUsrProps = obj.hModel.usrAvailableUsrPropList;
            
            % Throw a warning if any available user prop is not
            % SetObservable. This can happen b/c SetObservable-ness of usr
            % properties is required neither by the Model:mdlConfig
            % infrastructure nor by SI4 (this is arguably the right
            % thing to do). Meanwhile, the userSettings GUI provides a view
            % (via a propTable) into the current usrProps; this is
            % implemented via listeners. (Side note: ML silently allows
            % adding a listener to an obj for a prop that is not
            % SetObservable.)
            %
            % At the moment I believe all available usr props for SI3/4 are
            % indeed SetObservable, but this warning will be good for
            % maintenance moving forward.
            modelMC = metaclass(obj.hModel);
            metaprops = modelMC.Properties;
            allpropnames = cellfun(@(x)x.Name,metaprops,'UniformOutput',false);
            [tf loc] = ismember(availableUsrProps,allpropnames);
            assert(all(tf));
            usrMetaProps = metaprops(loc);
            tfSetObservable = cellfun(@(x)x.SetObservable,usrMetaProps);
            if any(~tfSetObservable)
                warning('SI4Controller:nonSetObservableUsrProp',...
                    'One or more available user properties is not SetObservable. The userSettings property table will not update for any such property.');
            end
            
            data(:,1) = sort(availableUsrProps);
            data(:,2) = {false}; % will get initted below
            set(obj.hGUIData.userSettingsV4.tblSpecifyUsrProps,'Data',data);
            obj.changedUsrPropListCurrent();
        end
        
        function ziniFastZControls(obj)
            % PR2015-07-08 for voice coil motor modifications
            if 0 %isempty(obj.hModel.hFastZ)
                most.gui.disableAll(obj.hGUIs.fastZControlsV4);
                obj.hideGUI(obj.hGUIs.fastZControlsV4);
            end
        end
        
        function ziniTriggerControls(obj)
            %Disable controls with features not supported in SI4.1
            disableControls = {'cbGapAdvance'};
            cellfun(@(s)set(obj.hGUIData.triggerControlsV4.(s),'Enable','off'), disableControls);
        end
        
        function delete(obj)
            if ~isempty(obj.motorErrorListeners)
                delete(obj.motorErrorListeners)
                obj.motorErrorListeners = [];
            end
        end
        
    end
    
    %% PROPERTY ACCESS
    methods
        
        function set.beamDisplayIdx(obj,val)
            if obj.hModel.beamNumBeams <= 0
                return;
            end
            
            assert(ismember(val,1:obj.hModel.beamNumBeams));
            if val~=obj.beamDisplayIdx
                obj.beamDisplayIdx = val;
                beamPropNames = fieldnames(obj.beamProp2Control); %#ok<MCSUP>
                for i = 1:numel(beamPropNames)
                    propName = obj.beamProp2Control.(beamPropNames{i}); %#ok<MCSUP>
                    obj.changedBeamParams(propName);
                end
                set(obj.hGUIData.powerControlsV4.pumBeamIdx,'Value',val); %#ok<*MCSUP>
                set(obj.hGUIData.powerControlsV4.sldBeamIdx,'Value',val);
            end
        end
        
        function set.channelsTargetDisplay(obj,val)
            assert(isempty(val) || ismember(val,[inf 1:obj.hModel.channelsNumChannels]));
            
            if isempty(val)
                % 'None'
                set(obj.hGUIData.imageControlsV4.pmTargetFigure,'Value',1);
            elseif isinf(val)
                % Merge window
                set(obj.hGUIData.imageControlsV4.pmTargetFigure,'Value',obj.hModel.channelsNumChannels + 2);
            else
                set(obj.hGUIData.imageControlsV4.pmTargetFigure,'Value',val+1);
            end
            obj.channelsTargetDisplay = val;
        end
        
        function set.motorStepSize(obj,val)
            
            currVal = obj.motorStepSize;
            assert(numel(val) == numel(currVal),'The motorStepSize value must have %d elements',numel(currVal));
            
            %Only change dimensions with valid values (positive, finite, smaller than fastMotionThreshold)
            val(val <= 0 | val > obj.hModel.motorFastMotionThreshold | isinf(val)) = nan;
            unchangedDims = isnan(val);
            val(unchangedDims) = currVal(unchangedDims);
            
            %Set property & update view
            obj.motorStepSize = val;
            
            set(obj.hGUIData.motorControlsV4.etStepSizeX,'String',num2str(val(1),'%0.5g'));
            set(obj.hGUIData.motorControlsV4.etStepSizeY,'String',num2str(val(2),'%0.5g'));
            set(obj.hGUIData.motorControlsV4.etStepSizeZ,'String',num2str(val(3),'%0.5g'));
            
        end
        %         function set.scanZoomConfigIdx(obj,val)
        %             validateattributes(val,{'numeric'},{'positive' 'scalar' 'integer'});
        %
        %             persistent hControl
        %
        %             if isempty(hControl)
        %                 hControl = findobj(obj.hGUIs.configControlsV4,'Tag','etConfigZoomFactor');
        %             end
        %
        %
        %             %             %Ensure index does not exceed maximum value
        %             %             if val > obj.scanZoomConfigIdxMax
        %             %                 val = obj.scanZoomConfigIdxMax;
        %             %             end
        %
        %             obj.scanZoomConfigIdx = val;
        %             set(hControl,'String',num2str(val));
        %
        %             %Update view of all zoom-indexed scan parameters
        %             obj.changedZoomIndexedScanParam();
        %         end
        
        %         function set.scanZoomConfigIdxMax(obj,val)
        %             validateattributes(val,'Classes','numeric','Attributes',{'positive' 'scalar' 'integer'});
        %             obj.scanZoomConfigIdxMax = val;
        %
        %             %Dependencies
        %             if obj.scanZoomConfigIdx > val
        %                 obj.scanZoomConfigIdx = obj.scanZoomConfigIdxMax;
        %             end
        %
        %
        %         end
        
        function set.motorUserPositionIndex(obj,val)
            validateattributes(val,{'numeric'},{'nonnegative' 'scalar' 'integer'});
            if val > obj.motorMaxNumUserDefinedPositions
                val = obj.motorMaxNumUserDefinedPositions;
            end
            
            obj.motorUserPositionIndex = val;
            if val==0
                set(obj.hGUIData.posnControlsV4.etPositionNumber,'String','');
            else
                set(obj.hGUIData.posnControlsV4.etPositionNumber,'String',num2str(val));
            end
            set(obj.hGUIData.posnControlsV4.sldPositionNumber,'Value',val);
        end
        
        % This sets the GUI-displayed status string, NOT the hModel status
        % string.
        function set.mainControlsStatusString(obj,val)
            set(obj.hGUIData.mainControlsV4.statusString,'String',val);
        end
        
        % This gets the GUI-displayed status string, NOT the hModel status
        % string.
        function val = get.mainControlsStatusString(obj)
            val = get(obj.hGUIData.mainControlsV4.statusString,'String');
        end
        
        function set.scanPhaseDisplay(obj,val)            
           assert(ischar(val) && ismember(lower(val),{'hardware' 'software'}),'Unsupported value supplied for scanPhaseDisplay. Should be one of {''hardware'', ''software''}}.');
           obj.scanPhaseDisplay = val;
           
           switch val
               case 'hardware'
                   set(obj.hGUIData.configControlsV4.etScanPhase,'TooltipString','Value from 0-254 used to align imaging with phase of scan (at current zoom)');
               case 'software'
                   set(obj.hGUIData.configControlsV4.etScanPhase,'TooltipString','Value from -127-128 used to align imaging with phase of scan (at current zoom, # pixels, # channels)');
               otherwise
                   assert(false);
           end
           
           obj.changedScanPhase();
        end
        
        function val = get.hMainPbFastCfg(obj)
            val = [obj.hGUIData.mainControlsV4.pbFastConfig1; ...
                obj.hGUIData.mainControlsV4.pbFastConfig2; ...
                obj.hGUIData.mainControlsV4.pbFastConfig3; ...
                obj.hGUIData.mainControlsV4.pbFastConfig4; ...
                obj.hGUIData.mainControlsV4.pbFastConfig5; ...
                obj.hGUIData.mainControlsV4.pbFastConfig6];
        end
        
        function viewType = get.userFunctionsViewType(obj)
            viewBtn = get(obj.hGUIData.userFunctionControlsV4.bgView,'SelectedObject');
            if ~isempty(viewBtn)
                switch get(viewBtn,'Tag')
                    case 'tbUsr'
                        viewType = 'USR';
                    case 'tbCfg'
                        viewType = 'CFG';
                end
            else
                viewType = 'none';
            end
        end
        
        function evtNames = get.userFunctionsCurrentEvents(obj)
            switch obj.userFunctionsViewType
                case 'none'
                    evtNames = cell(0,1);
                case 'CFG'
                    evtNames = obj.hModel.userFunctionsEvents;
                case 'USR'
                    evtNames = sort([obj.hModel.userFunctionsEvents;obj.hModel.userFunctionsUsrOnlyEvents]);
            end
        end
        
        function propName = get.userFunctionsCurrentProp(obj)
            switch obj.userFunctionsViewType
                case 'none'
                    propName = '';
                case 'CFG'
                    propName = 'userFunctionsCfg';
                case 'USR'
                    propName = 'userFunctionsUsr';
            end
        end
        
    end
    
    %% APP PROPERTY CALLBACKS
    % Methods named changedXXX(src,...) respond to changes to model, which should update the controller/GUI
    % Methods named changeXXX(hObject,...) respond to changes to GUI, which should update the model
    methods (Hidden)
        
        function changeBeamParams(obj,src,~,~)
            %Change occurred to beam-indexed params in view/controller
            
            switch get(src,'Style')
                case 'edit'
                    newVal = str2double(get(src,'String'));
                case 'slider'
                    newVal = get(src,'Value');
                otherwise
                    assert(false,'Unsupported control style.');
            end
            
            propName = get(src,'UserData');
            
            
            try
                obj.hModel.(propName)(obj.beamDisplayIdx) = newVal;
            catch ME
                % Error setting beam-indexed model prop; revert GUI
                obj.changedBeamParams(propName);
                
                % TODO what is the right thing here
                switch ME.identifier
                    % currently don't throw any warnings/errs
                end
            end
            
        end
        
        function changedBeamParams(obj,src,evnt)
            %Change occurred to beam-indexed property in model; refresh
            % controls tied to that prop.
            % src: either a meta.prop object (when changedBeamParams used as
            % prop listener), or a propName string
            
            if obj.hModel.beamNumBeams <= 0
                return;
            end
            
            if ischar(src)
                propName = src;
            elseif isa(src,'meta.property')
                propName = src.Name;
            else
                assert(false,'Invalid src input arg.');
            end
            
            newVal = obj.hModel.(propName)(obj.beamDisplayIdx);
            
            hControls = obj.beamProp2Control.(propName);
            for c = 1:numel(hControls)
                switch get(hControls(c),'Style')
                    case 'edit'
                        set(hControls(c),'String',num2str(newVal));
                    case 'slider'
                        set(hControls(c),'Value',newVal);
                    otherwise
                        assert(false,'Unsupported control style.');
                end
            end
        end
        
        function changeGUIToggleToolState(obj,src,guiToolFcn)
            if get(src,'Value');
                
                % Untoggle other togglebuttons
                switch get(src,'Tag')
                    case 'tbZoom'
                        set(obj.hGUIData.imageControlsV4.tbDataTip,'Value',false);
                    case 'tbDataTip'
                        set(obj.hGUIData.imageControlsV4.tbZoom,'Value',false);
                    otherwise
                        assert(false);
                end
                
                % Get target figure
                hFig = obj.zzzSelectImageFigure();
                if isempty(hFig)
                    set(src,'Value',false); % revert
                    return;
                end
                
                guiToolFcn(hFig,'on');
            else
                %TODO: Include merge figure
                arrayfun(@(hIm)guiToolFcn(ancestor(hIm,'figure'),'off'),[obj.hModel.channelsHImage]);
            end
        end
        
        function changedBeamPowerUnits(obj,src,evnt) %#ok<*INUSD>
            switch obj.hModel.beamPowerUnits
                case 'percent'
                    set(obj.hGUIData.powerControlsV4.rbPercentBeamPower,'Value',1);
                    set(obj.hGUIData.powerControlsV4.rbMilliwattBeamPower,'Value',0);
                case 'milliwatts'
                    set(obj.hGUIData.powerControlsV4.rbPercentBeamPower,'Value',0);
                    set(obj.hGUIData.powerControlsV4.rbMilliwattBeamPower,'Value',1);
                otherwise
                    assert(false,'Unsupported value of beamPowerUnits.');
            end
        end
        
        function changedBeamPzAdjust(obj,src,evnt)
            
            if obj.hModel.beamNumBeams <= 0
                return;
            end
            
            currBeamActive = obj.hModel.beamPzAdjust(obj.beamDisplayIdx);
            set(obj.hGUIData.powerControlsV4.cbPzAdjust,'Value',currBeamActive);
            
            if currBeamActive
                set(obj.hGUIData.powerControlsV4.etZLengthConstant,'Enable','on');
            else
                set(obj.hGUIData.powerControlsV4.etZLengthConstant,'Enable','off');
            end
        end
        
        function changedCfgFilename(obj,~,~)
            cfgFilename = obj.hModel.cfgFilename;
            [~,fname] = fileparts(cfgFilename);
            set([obj.hGUIData.mainControlsV4.configName obj.hGUIData.configControlsV4.configurationName],'String',fname);
        end
        
        function changedChannelsLUT(obj,src,evnt)
            
            channelsLUT = obj.hModel.channelsLUT;
            for i=1:obj.hModel.channelsNumChannels
                blackVal = channelsLUT(i,1);
                whiteVal = channelsLUT(i,2);
                
                set(obj.hGUIData.imageControlsV4.(sprintf('blackSlideChan%d',i)),'Value',blackVal);
                set(obj.hGUIData.imageControlsV4.(sprintf('whiteSlideChan%d',i)),'Value',whiteVal);
                
                set(obj.hGUIData.imageControlsV4.(sprintf('blackEditChan%d',i)),'String',num2str(blackVal));
                set(obj.hGUIData.imageControlsV4.(sprintf('whiteEditChan%d',i)),'String',num2str(whiteVal));
            end
        end
        
        function changeChannelsLUT(obj,src,blackOrWhite,chanIdx)
            %blackOrWhite: 0 if black, 1 if white
            %chanIdx: Index of channel whose LUT value to change
            
            switch get(src,'Style')
                case 'edit'
                    newVal = str2num(get(src,'String'));
                case 'slider'
                    newVal = get(src,'Value');
                    newVal = round(newVal); %Only support integer values, from slider controls
            end
            
            if isempty(newVal) %Erroneous entry
                obj.changedChannelsLUT(); %refresh View
            else
                %Force black level to be less than white level
                if ~blackOrWhite %set black level
                    if newVal >= obj.hModel.channelsLUT(chanIdx,~blackOrWhite+1)
                        newVal = obj.hModel.channelsLUT(chanIdx,~blackOrWhite+1) - 1;
                    end
                else %set white level
                    if newVal <= obj.hModel.channelsLUT(chanIdx,~blackOrWhite+1)
                        newVal = obj.hModel.channelsLUT(chanIdx,~blackOrWhite+1) + 1;
                    end
                end
                
                try
                    obj.hModel.channelsLUT(chanIdx,blackOrWhite+1) = newVal;
                catch ME
                    obj.changedChannelsLUT();
                    obj.updateModelErrorFcn(ME);
                end
            end
            
        end
        
        function changedChannelsMergeEnable(obj,src,evt)
            val = obj.hModel.channelsMergeEnable;
            if val
                set(obj.hGUIData.channelControlsV4.cbChannelsMergeFocusOnly,'Enable','on');
            else
                set(obj.hGUIData.channelControlsV4.cbChannelsMergeFocusOnly,'Enable','off');
            end
        end
        
        %         function changedChannelsInputRange(obj,src,~)
        %
        %
        %
        %             hTbl = findobj(obj.hGUIs.channelControlsV4,'Tag','tblChanConfig');
        %             data = get(hTbl,'Data');
        %             for i=1:obj.hModel.channelsNumChannels
        %                 data{i,4} = mat2str(obj.hModel.channelsInputRange{i});
        %             end
        %             set(hTbl,'Data',data);
        %         end
        %
        
        %         function changedChannelsNumChannels(obj,src,evnt)
        %
        %             %TODO: Use controlData AppController structure & class to implement boilerplate tasks for PropControls (e.g. resizing)
        %
        %             newSize = obj.hModel.channelsNumChannels;
        %             hTbl = findobj(obj.hGUIs.channelControlsV4,'Tag','tblChanConfig');
        %
        %             rowNames = cell(1,newSize);
        %             for i=1:length(rowNames)
        %                 rowNames{i} = sprintf('Channel %d',i);
        %             end
        %             set(hTbl,'RowNames',rowNames);
        %
        %             %Update PropControl size
        %             obj.hChannelConfig.resize(newSize);
        %             obj.updatePropControlView(obj.hChannelConfig); %When model correctly handles resize, this step would not be needed!
        %
        %         end
        
        function changedAcqFramesDone(obj,src,evnt)
            switch obj.hModel.acqState
                case 'focus'
                    %do nothing
                    val = obj.hModel.acqFramesDone;
                    set(obj.hGUIData.mainControlsV4.framesDone,'String',num2str(val));
                otherwise
                    val = obj.hModel.acqFramesDoneTotal;
                    set(obj.hGUIData.mainControlsV4.framesDone,'String',num2str(val));
            end
        end
        
        function changedAcqState(obj,src,evnt)
            hFocus = obj.hGUIData.mainControlsV4.focusButton;
            hGrab = obj.hGUIData.mainControlsV4.grabOneButton;
            hLoop = obj.hGUIData.mainControlsV4.startLoopButton;
            switch obj.hModel.acqState
                case 'idle'
                    set(hFocus,'String','FOCUS','Visible','on');
                    set(hGrab,'String','GRAB','Visible','on');
                    set(hLoop,'String','LOOP','Visible','on');
                    
                case 'focus'
                    set([hFocus hGrab hLoop],'Visible','off');
                    set(hFocus,'String','ABORT','Visible','on');
                    
                case 'grab'
                    set([hFocus hGrab hLoop],'Visible','off');
                    set(hGrab,'String','ABORT','Visible','on');
                    
                case {'loop' 'loop_wait'}
                    set([hFocus hGrab hLoop],'Visible','off');
                    set(hLoop,'String','ABORT','Visible','on');
                    
                    %TODO: Maybe add 'error' state??
                    
            end
        end
        
        %%% MOTOR %%%
        
        function changeMotorPosition(obj,src,coordinateIdx)
            newVal = str2double(get(src,'String'));
            try
                %NOTE: Indexing operation forces read of motorPosition prior to setting
                obj.hModel.motorPosition(coordinateIdx) = newVal;
            catch %#ok<CTCH>
                obj.changedMotorPosition(); % refreshes motor-Position-related GUI components
            end
        end
        
        % changedMotorPosition(obj,src,evt) - used as callback
        % changedMotorPosition(obj,tfUseLast)
        % changedMotorPosition(obj)
        function changedMotorPosition(obj,~,~)
            
            formatStr = '%.2f';
            
            motorPos = obj.hModel.motorPosition;
            if ~isempty(motorPos)
                set(obj.hGUIData.motorControlsV4.etPosX,'String',num2str(motorPos(1),formatStr));
                set(obj.hGUIData.motorControlsV4.etPosY,'String',num2str(motorPos(2),formatStr));
                set(obj.hGUIData.motorControlsV4.etPosZ,'String',num2str(motorPos(3),formatStr));
                set(obj.hGUIData.motorControlsV4.etPosR,'String',num2str(norm(motorPos(1:3)),formatStr));
                if numel(motorPos)==4
                    set(obj.hGUIData.motorControlsV4.etPosZZ,'String',num2str(motorPos(4),formatStr));
                end
            end
        end
        
        %%%%%%%%%%%%
        
        function changedPointButton(obj,src,~)
            if get(src,'Value')
                obj.hModel.scanPointBeam();
                set(src,'String','PARK','ForegroundColor','r');
            else
                obj.hModel.abort();
                set(src,'String','POINT','ForegroundColor',[0 .6 0]);
            end
        end
        
        function changedPMTEnable(obj,~,~)
            
            if ~isempty(obj.hModel.pmtEnable)
                for i=1:obj.hModel.pmtNumPMTs
                    hCtl = obj.hGUIData.pmtControlsV4.(sprintf('tbPMTEnable%d',i));
                    if obj.hModel.pmtEnable(i)
                        set(hCtl,'String','ON');
                        set(hCtl,'BackgroundColor',[0 .6 0]);
                    else
                        set(hCtl,'String','OFF');
                        set(hCtl,'BackgroundColor',get(0,'defaultUiControlBackgroundColor'));
                    end
                end
            end
        end
        
        function changePMTGain(obj,src,evnt,pmtIdx)
            %TODO: If pmtGain range were constrained in model, having queried the Thor API on initialization, this method would not be needed
            
            try
                obj.hModel.pmtGain(pmtIdx) = str2double(get(src,'String'));
            catch ME
                obj.changedPMTGain(); %Revert value
                ME.rethrow();
            end
        end
        
        function changedPMTGain(obj,~,~)
            if ~isempty(obj.hModel.pmtGain)
                for i=1:obj.hModel.pmtNumPMTs
                    hCtl = obj.hGUIData.pmtControlsV4.(sprintf('etPMTGain%d',i));
                    set(hCtl,'String',num2str(obj.hModel.pmtGain(i)));
                end
            end
        end
        
        %         function changedPMT(obj,~,~)
        %
        %             numPMTs = 2;
        %
        %             %Enable Props
        %             pmtEnableProps = {'pmtEnable1' 'pmtEnable2'};
        %             pmtEnableControls = {'tbPMTEnable1' 'tbPMTEnable2'};
        %
        %             for i=1:numPMTs
        %                 hCtl = obj.hGUIData.pmtControlsV4.(pmtEnableControls{i});
        %                 if obj.hModel.hPMT.(pmtEnableProps{i})
        %                     set(hCtl,'BackgroundColor',[0 .6 0]);
        %                 else
        %                     set(hCtl,'BackgroundColor',[.6 0 0]);
        %                 end
        %             end
        %
        %             %Gain Props
        %             pmtGainProps = {'pmtGain1' 'pmtGain2'};
        %             pmtGainControls = {'etPMTGain1' 'etPMTGain2'};
        %
        %             for i=1:numPMTs
        %                hCtl =  obj.hGUIData.pmtControlsV4.(pmtGainControls{i});
        %                set(hCtl,'String',num2str(obj.hModel.hPMT.(pmtGainProps{i});
        %             end
        %         end
        
        function changedScanAngleMultiplierSlow(obj,~,~)
            
            s = obj.hGUIData.configControlsV4;
            hForceSquareCtls = [s.cbForceSquarePixel s.cbForceSquarePixelation];
            
            if obj.hModel.scanAngleMultiplierSlow == 0
                set(obj.hGUIData.mainControlsV4.tbToggleLinescan,'Value',1);                
                set(hForceSquareCtls,'Enable','off');
                hLSM.scanAngleMultiplierSlow = obj.hModel.scanAngleMultiplierSlow;
            else
                set(obj.hGUIData.mainControlsV4.tbToggleLinescan,'Value',0);
                set(hForceSquareCtls,'Enable','on');
                hLSM.scanAngleMultiplierSlow = obj.hModel.scanAngleMultiplierSlow;
            end
        end
        
        function changedScanMode(obj,~,~)
            hScanMode = obj.hGUIData.configControlsV4.cbBidirectionalScan;
            switch obj.hModel.scanMode
                case 'bidirectional'
                    set(hScanMode,'Value',1);
                case 'unidirectional'
                    set(hScanMode,'Value',0);
            end
            obj.updateViewHidden('scanLinePeriod');
        end
        
        function changeScanPhase(obj,src)
            val = str2double(get(src,'String'));
            
%             switch obj.scanPhaseDisplay
%                 case 'hardware'
%                     propName = 'scanPhase';
%                 case 'software'
            propName = 'lineScan_delay2';
%                 otherwise
%                     assert(false);
%             end
            
            try
                obj.hModel.(propName) = val;
            catch ME
                obj.changedScanPhase();
                obj.updateModelErrorFcn(ME);
            end
        end
        
        function changeScanPhaseStepwise(obj,stepMultiplier,fineStep)            
            
%             switch obj.scanPhaseDisplay
%                 case 'hardware'
%                     propName = 'scanPhase';
%                 case 'software'
                    propName = 'lineScan_delay2';
%                 otherwise
%                     assert(false);
%             end            
            
            if fineStep
                step = 0.025; % in microseconds, PR
            else
                step = 0.5;
            end
            
            try
                obj.hModel.(propName) = obj.hModel.(propName) + step * stepMultiplier;
            catch ME
                obj.changedScanPhase();
                obj.updateModelErrorFcn(ME);
            end
        end
        
        function changedScanPhase(obj,~,~)
            hScanPhase = obj.hGUIData.configControlsV4.etScanPhase;
%             switch obj.scanPhaseDisplay
%                 case 'software'
            set(hScanPhase,'String',num2str(obj.hModel.lineScan_delay2));
%                 case 'hardware'
%                     set(hScanPhase,'String',num2str(obj.hModel.scanPhase));
%                 otherwise 
%                     assert(false);
%             end                                        
        end        
        
        function changedScanFramePeriod(obj,~,~)
            if isnan(obj.hModel.scanFramePeriod)
                set(obj.hGUIData.fastZControlsV4.etFramePeriod,'BackgroundColor',[0.9 0 0]);
                set(obj.hGUIData.configControlsV4.etFrameRate,'BackgroundColor',[0.9 0 0]);
            else
                set(obj.hGUIData.fastZControlsV4.etFramePeriod,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
                set(obj.hGUIData.configControlsV4.etFrameRate,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end
        
        function changedScanForceSquarePixelation_(obj,~,~)
            if obj.hModel.scanForceSquarePixelation_
                set(obj.hGUIData.configControlsV4.etLinesPerFrame,'Enable','inactive');
            else
                set(obj.hGUIData.configControlsV4.etLinesPerFrame,'Enable','on');
            end
        end
        
        function changedScanForceSquarePixel_(obj,~,~)
            if obj.hModel.scanForceSquarePixel_
                set(obj.hGUIData.mainControlsV4.etScanAngleMultiplierSlow,'Enable','inactive');
            else
                set(obj.hGUIData.mainControlsV4.etScanAngleMultiplierSlow,'Enable','on');
            end
        end

        
        function changeScanZoomFactor(obj,hObject,absIncrement,lastVal)
            
            hLSM = obj.hModel.hLSM;
            
            newVal = get(hObject,'Value');
                
            currentZoom = obj.hModel.scanZoomFactor;
            if newVal > lastVal
                newZoom = currentZoom + absIncrement;
                minFieldChange = -1;
            elseif newVal < lastVal
                newZoom = currentZoom - absIncrement;
                minFieldChange = 1;
            else
                assert(false);
            end
            
            
            %Handle case where incremented value rounds to the same field size
            currentFieldSize = hLSM.zoom2FieldSize(currentZoom);
            newFieldSize = hLSM.zoom2FieldSize(newZoom);
            
            if newFieldSize == currentFieldSize
                newFieldSize = currentFieldSize + minFieldChange;
                newZoom = hLSM.fieldSize2Zoom(newFieldSize);
            end
            
            %Update the model/view values as needed
            if newFieldSize <= hLSM.fieldSizeMax && newFieldSize >= hLSM.fieldSizeMin
                obj.hModel.scanZoomFactor = newZoom;
                hLSM.scanZoomFactor = newZoom;
            else
                obj.updateViewHidden('scanZoomFactor');
            end
        end
        
        function changedSecondsCounter(obj,~,~)
            
            %TODO: make value of 0 'sticky' for 0.3-0.4s using a timer object here
            hSecCntr = obj.hGUIData.mainControlsV4.secondsCounter;
            
            switch obj.hModel.secondsCounterMode
                case 'up' %countup timer
                    set(hSecCntr,'String',num2str(max(0,floor(obj.hModel.secondsCounter))));
                case 'down'  %countdown timer
                    set(hSecCntr,'String',num2str(max(0,ceil(obj.hModel.secondsCounter))));
                otherwise
                    set(hSecCntr,'String','0');
            end
        end
        
        function changedStackStartEndPositionPower(obj,~,~)
            startPos = obj.hModel.stackZStartPos;
            endPos = obj.hModel.stackZEndPos;
            startPower = obj.hModel.stackStartPower; % todo multibeam
            %            endPower = obj.hModel.stackEndPower; % todo multibeam
            
            if obj.hModel.fastZEnable
                hStartEndCtls = {'etStackStart' 'etStackEnd'};
                cellfun(@(x)set(obj.hGUIData.motorControlsV4.(x),'Enable','off'),hStartEndCtls);
            else
                zlclEnableUIControlBasedOnVal(obj.hGUIData.motorControlsV4.etStackStart,startPos,'inactive');
                zlclEnableUIControlBasedOnVal(obj.hGUIData.motorControlsV4.etStackEnd,endPos,'inactive');
            end
            
            if ~isnan(startPower)
                set(obj.hGUIData.motorControlsV4.cbUseStartPower,'Enable','on');
            else
                obj.hModel.stackUseStartPower = false;
                set(obj.hGUIData.motorControlsV4.cbUseStartPower,'Enable','off');
            end
            
            if obj.hModel.stackStartEndPointsDefined && obj.hModel.stackStartEndPowersDefined
                set(obj.hGUIData.motorControlsV4.cbOverrideLz,'Enable','on');
                set(obj.hGUIData.motorControlsV4.pbOverrideLz,'Enable','on');
            else
                obj.hModel.stackUserOverrideLz = false;
                set(obj.hGUIData.motorControlsV4.cbOverrideLz,'Enable','off');
                set(obj.hGUIData.motorControlsV4.pbOverrideLz,'Enable','off');
            end
        end
        
        function changedStackUseStartPower(obj,~,~)
            tfUseStartPower = obj.hModel.stackUseStartPower;
            if tfUseStartPower && ~obj.hModel.fastZEnable
                set(obj.hGUIData.motorControlsV4.etStartPower,'Enable','inactive');
            else
                set(obj.hGUIData.motorControlsV4.etStartPower,'Enable','off');
            end
        end
        
        function changedStatusString(obj,~,~)
            % For now, just display the string
            ss = obj.hModel.statusString;
            obj.mainControlsStatusString = ss;
        end
        
        function changedOverrideLz(obj,~,~)
            tf = obj.hModel.stackUserOverrideLz;
            if tf && ~obj.hModel.fastZEnable
                set(obj.hGUIData.motorControlsV4.etEndPower,'Enable','inactive');
            else
                set(obj.hGUIData.motorControlsV4.etEndPower,'Enable','off');
            end
        end
        
        function changedTriggerExtTrigAvailable(obj,~,~)
            hBtn = obj.hGUIData.mainControlsV4.tbExternalTrig;
            if obj.hModel.triggerExtTrigAvailable
                set(hBtn,'Enable','on');
            else
                set(hBtn,'Enable','off');
            end
        end
        
        function changedFastCfgCfgFilenames(obj,~,~)
            fastCfgFNames = obj.hModel.fastCfgCfgFilenames;
            tfEmpty = cellfun(@isempty,fastCfgFNames);
            set(obj.hMainPbFastCfg(tfEmpty),'Enable','off');
            set(obj.hMainPbFastCfg(~tfEmpty),'Enable','on');
        end
        
        function changedFastCfgAutoStartTf(obj,~,~)
            autoStartTf = obj.hModel.fastCfgAutoStartTf;
            defaultBackgroundColor = get(0,'defaultUicontrolBackgroundColor');
            set(obj.hMainPbFastCfg(autoStartTf),'BackGroundColor',[0 1 0]);
            set(obj.hMainPbFastCfg(~autoStartTf),'BackGroundColor',defaultBackgroundColor);
        end
        
        function changeFastZSettlingTimeVar(obj,src,~,~)
            
            val = str2double(get(src,'String'));
            if isnan(val)
                obj.changedFastZSettlingTime();
                return;
            end
            
            try
                switch obj.hModel.fastZScanType
                    case 'sawtooth'
                        obj.hModel.fastZAcquisitionDelay = val;
                    case 'step'
                        obj.hModel.fastZSettlingTime = val;
                    otherwise
                        assert(false);
                end
            catch ME
                obj.changedFastZSettlingTime();
                switch ME.identifier
                    case 'most:InvalidPropVal'
                        % no-op
                    case 'PDEPProp:SetError'
                        throwAsCaller(obj.DException('','ModelUpdateError',ME.message));
                    otherwise
                        ME.rethrow();
                end
            end
            
        end
        
        function changedFastZSettlingTime(obj,~,~)
            hFastZGUI = obj.hGUIData.fastZControlsV4;
            
            switch obj.hModel.fastZScanType
                case 'sawtooth'
                    set(hFastZGUI.etSettlingTime,'String',num2str(obj.hModel.fastZAcquisitionDelay));
                case 'step'
                    set(hFastZGUI.etSettlingTime,'String',num2str(obj.hModel.fastZSettlingTime));
                otherwise
                    assert(false);
            end
        end
        
        function changedLoggingEnable(obj,~,~)
            
            hAutoSaveCBs = [obj.hGUIData.mainControlsV4.cbAutoSave obj.hGUIData.configControlsV4.cbAutoSave];
            hLoggingControls = [obj.hGUIData.mainControlsV4.baseName obj.hGUIData.mainControlsV4.baseNameLabel ...
                obj.hGUIData.mainControlsV4.fileCounter obj.hGUIData.mainControlsV4.fileCounterLabel];
            
            if obj.hModel.loggingEnable
                set(hAutoSaveCBs,'BackgroundColor',[0 .8 0]);
                set(hLoggingControls,'Enable','on');
            else
                set(hAutoSaveCBs,'BackgroundColor',[1 0 0]);
                set(hLoggingControls,'Enable','off');
            end
            
        end
        
        
        function changedFastZDiscardFlybackFrames(obj,~,~)
            hFastZGUI = obj.hGUIData.fastZControlsV4;
            
            if obj.hModel.fastZDiscardFlybackFrames
                set(hFastZGUI.etNumDiscardFrames,'Enable','inactive');
            else
                set(hFastZGUI.etNumDiscardFrames,'Enable','off');
            end
        end
        
        function changedFastZEnable(obj,~,~)            
            obj.changedStackStartEndPositionPower();
            obj.changedStackUseStartPower();
            obj.changedOverrideLz();
        end
        
        function changedFastZScanType(obj,~,~)
            hFastZGUI = obj.hGUIData.fastZControlsV4;
            
            switch lower(obj.hModel.fastZScanType)
                case 'sawtooth'
                    set(hFastZGUI.stSettlingTime,'String','Acq Delay');
                case 'step'
                    set(hFastZGUI.stSettlingTime,'String','Settling Time');
                otherwise
                    assert(false);
            end
            
            obj.changedFastZSettlingTime();
        end
        
        
        function changedUserFunctionsCfg(obj,~,~)
            switch obj.userFunctionsViewType
                case 'CFG'
                    obj.hGUIData.userFunctionControlsV4.uft.refresh();
            end
        end
        
        function changedUserFunctionsUsr(obj,~,~)
            switch obj.userFunctionsViewType
                case 'USR'
                    obj.hGUIData.userFunctionControlsV4.uft.refresh();
            end
        end
        
        function changedUserFunctionsOverride(obj,~,~)
            obj.hGUIData.userFunctionControlsV4.uftOverride.refresh();
        end
        
        function changedUsrFilename(obj,~,~)
            usrFilename = obj.hModel.usrFilename;
            [~,fname] = fileparts(usrFilename);
            set(obj.hGUIData.mainControlsV4.userSettingsName,'String',fname);
        end
        
        function changedUsrPropListCurrent(obj,~,~)
            usrPropSubsetCurrent = obj.hModel.usrPropListCurrent;
            NUsrPropSubsetCurrent = numel(usrPropSubsetCurrent);
            
            % remove previous listeners for userSettingsV4
            delete(obj.usrSettingsPropListeners);
            
            % add new listeners
            listenerObjs = event.proplistener.empty(0,1);
            for c = 1:NUsrPropSubsetCurrent
                pname = usrPropSubsetCurrent{c};
                listenerObjs(c) = obj.hModel.addlistener(pname,'PostSet',@obj.changedCurrentUsrProp);
            end
            obj.usrSettingsPropListeners = listenerObjs;
            
            % Update currentUsrProps table to use new property subset
            obj.hGUIData.userSettingsV4.pcCurrentUSRProps.reset();
            formatStruct = struct('format','char','info',[]); % xxx explain char
            formatCell = num2cell(repmat(formatStruct,NUsrPropSubsetCurrent,1));
            metadata = cell2struct(formatCell,usrPropSubsetCurrent,1);
            obj.hGUIData.userSettingsV4.pcCurrentUSRProps.addProps(metadata);
            
            % Manually fire listeners for each prop in usrPropSubsetCurrent
            % so that the currentUsrProps table updates
            for c = 1:NUsrPropSubsetCurrent
                pname = usrPropSubsetCurrent{c};
                obj.changedCurrentUsrProp(pname);
            end
            
            % Update specifyCurrentUsrProps table
            data = get(obj.hGUIData.userSettingsV4.tblSpecifyUsrProps,'Data');
            availableUsrProps = data(:,1);
            tfInCurrentUsrSubset = ismember(availableUsrProps,usrPropSubsetCurrent);
            data(:,2) = num2cell(tfInCurrentUsrSubset);
            set(obj.hGUIData.userSettingsV4.tblSpecifyUsrProps,'Data',data);
        end
        
        % changedCurrentUsrProp(obj,src,evt)
        % changedCurrentUsrProp(obj,propName)
        function changedCurrentUsrProp(obj,varargin)
            switch nargin
                case 2
                    propName = varargin{1};
                case 3
                    src = varargin{1};
                    propName = src.Name;
                otherwise
                    assert(false,'Invalid number of args.');
            end
            val = obj.hModel.(propName);
            obj.hGUIData.userSettingsV4.pcCurrentUSRProps.encodeFcn(propName,val);
        end
        
        function changedDisplayRollingAverageFactorLock(obj,~,~)
            if obj.hModel.displayRollingAverageFactorLock
                set(obj.hGUIData.imageControlsV4.etRollingAverage,'Enable','off');
            else
                set(obj.hGUIData.imageControlsV4.etRollingAverage,'Enable','on');
            end
        end
        
        function changedDisplayFrameBatchSelectLast(obj,~,~)
            if obj.hModel.displayFrameBatchSelectLast
                set(obj.hGUIData.imageControlsV4.etFrameSelections,'Enable','off');
            else
                set(obj.hGUIData.imageControlsV4.etFrameSelections,'Enable','on');
            end
        end
        
        function changedDisplayFrameBatchFactorLock(obj,~,~)
            if obj.hModel.displayFrameBatchFactorLock
                set(obj.hGUIData.imageControlsV4.etFrameSelFactor,'Enable','off');
            else
                set(obj.hGUIData.imageControlsV4.etFrameSelFactor,'Enable','on');
            end
        end
        
        % This looks similar to Controller.updateModel for PropControls.
        % However updateModel() does not quite work as when there is a
        % failure, it reverts using Controller.updateViewHidden. This will
        % not work as the currentUsrProps are not currently participating
        % in the prop2Control struct business.
        function changeCurrentUsrProp(obj,hObject,eventdata,handles)
            [status propName propVal] = ...
                obj.hGUIData.userSettingsV4.pcCurrentUSRProps.decodeFcn(hObject,eventdata,handles);
            switch status
                case 'set'
                    try
                        obj.hModel.(propName) = propVal;
                    catch ME
                        obj.changedCurrentUsrProp(propName);
                        switch ME.identifier
                            case 'most:InvalidPropVal'
                                % no-op
                            case 'PDEPProp:SetError'
                                throwAsCaller(obj.DException('','ModelUpdateError',ME.message));
                            otherwise
                                ME.rethrow();
                        end
                    end
                case 'revert'
                    obj.changedCurrentUsrProp(propName);
                otherwise
                    assert(false);
            end
        end
        
        function specifyCurrentUsrProp(obj,hObject,eventdata,handles)
            data = get(hObject,'data');
            availableUsrProps = data(:,1);
            tf = cell2mat(data(:,2));
            obj.hModel.usrPropListCurrent = availableUsrProps(tf);
        end
    end
    
    %% ACTION CALLBACKS
    methods (Hidden)
        
        function showChannelDisplay(obj,channelIdx)
            tag = sprintf('image_channel%d',channelIdx);
            hFig = findobj(obj.hAuxGUIs,'Tag',tag);
            if ~isempty(hFig)
                set(hFig,'Visible','on');
            end
        end
        
        function imageFunction(obj,fcnName)
            
            hFig = obj.zzzSelectImageFigure();
            if isempty(hFig)
                return;
            end
            
            allChannelFigs = obj.hModel.channelsHFig;
            [tf chanIdx] = ismember(hFig,allChannelFigs);
            if tf
                feval(fcnName,obj.hModel,chanIdx);
            end
            
        end
        
        function calibrateBeam(obj)
            beamIdx = obj.beamDisplayIdx;
            obj.hModel.beamsCalibrate(beamIdx);
        end
        
        function showCalibrationCurve(obj)
            beamIdx = obj.beamDisplayIdx;
            obj.hModel.beamsShowCalibrationCurve(beamIdx);
        end
        
        function measureCalibrationOffset(obj)
            beamIdx = obj.beamDisplayIdx;
            offset = obj.hModel.beamsMeasureCalOffset(beamIdx,true);
            msg = sprintf('Calibration offset voltage: %.3g. Result saved to Machine Data file.',offset);
            msgbox(msg,'Calibration offset measured');
        end
        
        function motorZeroAction(obj,action)
            feval(action,obj.hModel);
            obj.changedMotorPosition();
        end
        
        function motorDefineUserPositionAndIncrement(obj)
            usrPosnIdx = obj.motorUserPositionIndex;
            if usrPosnIdx > 0
                obj.hModel.motorDefineUserPosition(usrPosnIdx);
                obj.motorUserPositionIndex = usrPosnIdx + 1;
            end
        end
        
        function motorGotoUserPosition(obj)
            usrPosnIdx = obj.motorUserPositionIndex;
            if usrPosnIdx > 0
                obj.hModel.motorGotoUserDefinedPosition(usrPosnIdx);
            end
        end
        
        function motorLoadUserPositions(obj,handles)
            obj.hModel.motorLoadUserDefinedPositions();
            obj.motorUserPositionIndex = 1;
        end
        
        function motorStepPosition(obj,incOrDec,stepDim)
            
            posn = obj.hModel.motorPosition;
            
            switch incOrDec
                case 'inc'
                    stepSign = 1;
                case 'dec'
                    stepSign = -1;
                otherwise
                    assert(false);
            end
            
            switch stepDim
                case 'x'
                    posn(1) = posn(1) + (stepSign * obj.motorStepSize(1));
                case 'y'
                    posn(2) = posn(2) + (stepSign * obj.motorStepSize(2));
                case 'z'
                    
                    if obj.hModel.motorSecondMotorZEnable 
                        if strcmpi(obj.hModel.motorDimensionConfiguration,'xyz-z')
                            posnIdx = 4;
                        else
                            posnIdx = 3;
                        end                        
                        
                        %Make 'decrement' = 'down'/'deeper'
                        if obj.hModel.mdfData.motor2ZDepthPositive
                            stepSign = stepSign * -1; 
                        end
                    else
                        posnIdx = 3;     
                        
                        %Make 'decrement' = 'down'/'deeper'
                        if obj.hModel.mdfData.motorZDepthPositive
                            stepSign = stepSign * -1;
                        end              
                    end
                                        
                    posn(posnIdx) = posn(posnIdx) + (stepSign * obj.motorStepSize(3));
              
                otherwise
                    assert(false);
            end
            
            obj.hModel.motorPosition = posn;
            
        end
        
        %% motor error callback
        function motorErrorCbk(obj,src,evt) %#ok<INUSD>
            structfun(@nstDisable,obj.hGUIData.motorControlsV4);
            
            set(obj.hGUIData.motorControlsV4.pbRecover,'Visible','on');
            set(obj.hGUIData.motorControlsV4.pbRecover,'Enable','on');
            uistack(obj.hGUIData.motorControlsV4.pbRecover,'top');
            
            function nstDisable(h)
                if isprop(h,'Enable')
                    set(h,'Enable','off');
                end
            end
        end
        
        function motorRecover(obj)
            if obj.hModel.motorHasMotor && obj.hModel.hMotor.lscErrPending
                obj.hModel.hMotor.recover();
            end
            if obj.hModel.motorHasSecondMotor && obj.hModel.hMotorZ.lscErrPending
                obj.hModel.hMotorZ.recover();
            end
            
            % if we made it this far, then assume the error is fixed
            structfun(@nstEnable,obj.hGUIData.motorControlsV4);
            
            set(obj.hGUIData.motorControlsV4.pbRecover,'Visible','off');
            set(obj.hGUIData.motorControlsV4.pbRecover,'Enable','off');
            
            function nstEnable(h)
                if isprop(h,'Enable')
                    set(h,'Enable','on');
                end
            end
        end
        

        function stackSetStackStart(obj)
            obj.hModel.stackSetStackStart();
            % xxx DOC why it would be a bad idea for hModel to have a
            % dependent, setAccess=private, setobservable prop called
            % "tfStackStartEndPowersDefined" and for appC to listen to that
            % prop.
            if obj.hModel.stackStartEndPowersDefined()
                set(obj.hGUIData.motorControlsV4.cbOverrideLz,'Enable','on');
            end
        end
        
        function stackSetStackEnd(obj)
            obj.hModel.stackSetStackEnd();
            if obj.hModel.stackStartEndPowersDefined()
                set(obj.hGUIData.motorControlsV4.cbOverrideLz,'Enable','on');
            end
        end
        
        function stackClearStartEnd(obj)
            obj.hModel.stackClearStartEnd();
            set(obj.hGUIData.motorControlsV4.cbOverrideLz,'Enable','off');
        end
        
        function stackClearEnd(obj)
            obj.hModel.stackClearEnd();
            set(obj.hGUIData.motorControlsV4.cbOverrideLz,'Enable','off');
        end
        
        function toggleLineScan(obj,src,evnt)
            
            lineScanEnable = get(src,'Value');
            
            if lineScanEnable
                obj.hModel.scanAngleMultiplierSlow = 0;
                hLSM.scanAngleMultiplierSlow = 0;
            else
                obj.hModel.scanParamResetToBase({'scanAngleMultiplierSlow'});
                if obj.hModel.scanAngleMultiplierSlow == 0 %No CFG file, or CFG file has no scanAngleMultiplierSlow value, or Base value=0
                    obj.hModel.scanAngleMultiplierSlow = 1;
                    hLSM.scanAngleMultiplierSlow = 1;
                end
            end
            
        end
        
    end
    
    %% CONTROLLER PROPERTY CALLBACKS
    
    methods (Hidden)
        
        function changeChannelsTargetDisplay(obj,src)
            val = get(src,'Value');
            switch val
                case 1 %None selected
                    obj.channelsTargetDisplay = [];
                case obj.hModel.channelsNumChannels + 2
                    obj.channelsTargetDisplay = inf;
                otherwise
                    obj.channelsTargetDisplay = val - 1;
            end
        end
        
    end
    
    
    %% PRIVATE/PROTECTED METHODS
    
    methods (Access=protected)
        
        function hFig = zzzSelectImageFigure(obj)
            %Selects image figure, either from channelsTargetDisplay property or by user-selection
            
            hFig = [];
            
            if isempty(obj.channelsTargetDisplay)
                obj.mainControlsStatusString = 'Select image...';
                chanFigs = obj.hModel.channelsHFig;
                hFig = most.gui.selectFigure(chanFigs);
                obj.mainControlsStatusString = '';
                % TODO they can select the MERGE figure
            elseif isinf(obj.channelsTargetDisplay)
                %TODO: Handle Merge figure
            else
                hFig = obj.hModel.channelsHFig(obj.channelsTargetDisplay);
            end
        end
        
    end
    
end

%% Initializers
function propBindings = lclInitPropBindings()

%NOTE: In this prop metadata list, order does NOT matter!
%NOTE: These are properties for which some/all handling of model-view linkage is managed 'automatically' by this class

%TODO: Some native approach for dependent properties could be specified here, to handle straightforward cases where change in one property affects view of another -- these are now handled as 'custom' behavior with 'Callbacks'
%      For example: scanLinePeriodUS value depends on scanMode


s = struct();

s.acqFramesDone = struct('Callback','changedAcqFramesDone');
s.acqNumFrames = struct('GuiIDs',{{'mainControlsV4','framesTotal'}});
s.acqNumAveragedFrames = struct('GuiIDs',{{'mainControlsV4','etNumAvgFramesSave'}});

s.displayShowCrosshair = struct('GuiIDs',{{'imageControlsV4','mnu_Settings_ShowCrosshair'}});
s.displayRollingAverageFactor = struct('GuiIDs',{{'imageControlsV4','etRollingAverage'}});
s.displayRollingAverageFactorLock = struct('GuiIDs',{{'imageControlsV4','cbLockRollAvg2AcqAvg'}},'Callback','changedDisplayRollingAverageFactorLock');
s.displayFrameBatchFactor = struct('GuiIDs',{{'imageControlsV4','etFrameSelFactor'}});
s.displayFrameBatchSelection = struct('GuiIDs',{{'imageControlsV4','etFrameSelections'}});
s.displayFrameBatchSelectLast = struct('GuiIDs',{{'imageControlsV4','cbUseLastSelFrame'}},'Callback','changedDisplayFrameBatchSelectLast');
s.displayFrameBatchFactorLock = struct('GuiIDs',{{'imageControlsV4','cbLockFrameSel2RollAvg'}},'Callback','changedDisplayFrameBatchFactorLock');

s.beamFlybackBlanking = struct('GuiIDs',{{'configControlsV4','cbBlankFlyback'}});
s.betweenFrames = struct('GuiIDs',{{'configControlsV4','betweenFrames'}});
s.beamFillFracAdjust = struct('GuiIDs',{{'configControlsV4','etFillFracAdjust'}});
s.onTimeAdjust = struct('GuiIDs',{{'configControlsV4','onTimeAdjust'}});
s.timingAdjustPockels = struct('GuiIDs',{{'configControlsV4','timingAdjustPockels'}});
s.beamPowers = struct('Callback','changedBeamParams');
s.beamPowerLimits = struct('Callback','changedBeamParams');
s.beamLiveAdjust = struct('GuiIDs',{{'powerControlsV4','cbLiveAdjust'}});
s.beamDirectMode = struct('GuiIDs',{{'powerControlsV4','cbDirectMode'}});
s.beamPowerUnits = struct('Callback','changedBeamPowerUnits');
s.beamPzAdjust = struct('Callback','changedBeamPzAdjust');
s.beamLengthConstants = struct('Callback','changedBeamParams');

s.cfgFilename = struct('Callback','changedCfgFilename');

s.fastCfgCfgFilenames = struct('GuiIDs',{{'fastConfigurationV4','pcFastCfgTable'}},'PropControlData',...
    struct('columnIdx',3,'format','cellstr','customEncodeFcn',@zlclShortenFilename),'Callback','changedFastCfgCfgFilenames');
s.fastCfgAutoStartTf = struct('GuiIDs',{{'fastConfigurationV4','pcFastCfgTable'}},'PropControlData',...
    struct('columnIdx',4,'format','logical'),'Callback','changedFastCfgAutoStartTf');
s.fastCfgAutoStartType = struct('GuiIDs',{{'fastConfigurationV4','pcFastCfgTable'}},'PropControlData',...
    struct('columnIdx',5,'format','options'));

s.delayedChannelsOn = struct('GuiIDs',{{'mainControlsV4','delayedChannelsOn'}});
s.nbDelayedChannels = struct('GuiIDs',{{'mainControlsV4','nbDelayedChannels'}});

s.extClockEdge = struct('GuiIDs',{{'configControlsV4' 'extClockEdge'}}); % PR2014-11-17
s.extClockLevel = struct('GuiIDs',{{'configControlsV4','extClockLevel'}});


s.frameDecimationFactor = struct('GuiIDs',{{'configControlsV4' 'etFrameAcqFcnDecimationFactor'}}); % PR2014-08-27
s.lineScan_delay1 = struct('GuiIDs',{{'configControlsV4' 'edit78'}}); % PR2014-08-20
s.framerate_user = struct('GuiIDs',{{'configControlsV4' 'edit79'}}); % PR2014-08-27
s.framerate_user_check = struct('GuiIDs',{{'configControlsV4','checkbox29'}}); % PR2014-08-27
s.scanAngleMultiplierFast = struct('GuiIDs',{{'mainControlsV4','etScanAngleMultiplierFast'}});
s.scanAngleMultiplierSlow = struct('GuiIDs',{{'mainControlsV4','etScanAngleMultiplierSlow'}},'Callback','changedScanAngleMultiplierSlow');
s.scanZoomFactor = struct('GuiIDs',{{'mainControlsV4' 'pcZoom'}});
s.scanPixelsPerLine = struct('GuiIDs',{{'configControlsV4','pmPixelsPerLine'}});
s.xCorrChannel = struct('GuiIDs',{{'configControlsV4','xCorrChannelChoise'}});
s.scanLinesPerFrame = struct('GuiIDs',{{'configControlsV4','etLinesPerFrame'}});
s.scanLinePeriod = struct('GuiIDs',{{'configControlsV4','etLinePeriod'}},'ViewScaling',1e6,'ViewPrecision',5);
s.scanPhase = struct('Callback','changedScanPhase');
% s.scanPhaseFine = struct('Callback','changedScanPhase');
s.lineScan_delay2 = struct('Callback','changedScanPhase');
s.scanFillFraction = struct('GuiIDs',{{'configControlsV4','etFillFrac'}});
s.scanFillFractionSpatial = struct('GuiIDs',{{'configControlsV4','etFillFracSpatial'}},'ViewPrecision','%0.3f');
s.scanPixelTimeMean = struct('GuiIDs',{{'configControlsV4','etPixelTimeMean'}},'ViewScaling',1e9,'ViewPrecision','%.1f');
s.scanPixelTimeMaxMinRatio = struct('GuiIDs',{{'configControlsV4','etPixelTimeMaxMinRatio'}},'ViewPrecision','%.1f');
s.scanForceSquarePixelation = struct('GuiIDs',{{'configControlsV4','cbForceSquarePixelation'}});
s.scanForceSquarePixel  = struct('GuiIDs',{{'configControlsV4','cbForceSquarePixel'}});
s.scanForceSquarePixel_ = struct('Callback','changedScanForceSquarePixel_');
s.scanForceSquarePixelation_ = struct('Callback','changedScanForceSquarePixelation_');

s.maxValueShow = struct('GuiIDs',{{'configControlsV4','maxValueShow'}},'ViewPrecision',5);
s.meanValueShow = struct('GuiIDs',{{'configControlsV4','meanValueShow'}},'ViewPrecision',5);
s.showMeanLive = struct('GuiIDs',{{'configControlsV4','showMean'}});

s.scanMode = struct('Callback','changedScanMode');
s.scanFrameRate = struct('GuiIDs',{{'configControlsV4','etFrameRate'}},'ViewPrecision','%.2f');
s.scanFramePeriod = struct('GuiIDs',{{'fastZControlsV4','etFramePeriod'}},'ViewPrecision','%.1f','ViewScaling',1000,'Callback','changedScanFramePeriod');

s.stackSlicesDone = struct('GuiIDs',{{'mainControlsV4','slicesDone'}});
s.stackNumSlices = struct('GuiIDs',{{'mainControlsV4','slicesTotal','motorControlsV4','etNumberOfZSlices','fastZControlsV4','etNumZSlices'}});
s.stackZStartPos = struct('GuiIDs',{{'motorControlsV4','etStackStart'}},'Callback','changedStackStartEndPositionPower');
s.stackZEndPos = struct('GuiIDs',{{'motorControlsV4','etStackEnd'}},'Callback','changedStackStartEndPositionPower');
s.stackStartPower = struct('GuiIDs',{{'motorControlsV4','etStartPower'}},'Callback','changedStackStartEndPositionPower');
s.stackEndPower = struct('GuiIDs',{{'motorControlsV4','etEndPower'}},'Callback','changedStackStartEndPositionPower');
s.stackUseStartPower = struct('GuiIDs',{{'motorControlsV4','cbUseStartPower'}},'Callback','changedStackUseStartPower');
s.stackUserOverrideLz = struct('GuiIDs',{{'motorControlsV4','cbOverrideLz'}},'Callback','changedOverrideLz');
s.stackZStepSize = struct('GuiIDs',{{'motorControlsV4','etZStepPerSlice','fastZControlsV4','etZStepPerSlice'}});
s.stackReturnHome = struct('GuiIDs',{{'motorControlsV4','cbReturnHome','fastZControlsV4','cbReturnHome'}});
s.stackStartCentered = struct('GuiIDs',{{'motorControlsV4','cbCenteredStack','fastZControlsV4','cbCenteredStack'}});

s.motorPosition = struct('Callback','changedMotorPosition');
s.motorSecondMotorZEnable = struct('GuiIDs',{{'motorControlsV4','cbSecZ'}});

%s.channelsActive = struct('GuiIDs',{{'channelControlsV4','pcChannelConfig'}},'PropControlData',struct('columnIdx',1,'format','logicalindices','formatInfo',[]));
s.channelsDisplay = struct('GuiIDs',{{'channelControlsV4','pcChannelConfig'}},'PropControlData',struct('columnIdx',2,'format','logicalindices','formatInfo',[]));
s.channelsSave = struct('GuiIDs',{{'channelControlsV4','pcChannelConfig'}},'PropControlData',struct('columnIdx',1,'format','logicalindices','formatInfo',[]));
s.channelsInvert = struct('GuiIDs',{{'channelControlsV4','pcChannelConfig'}},'PropControlData',struct('columnIdx',8,'format','logicalindices','formatInfo',[]));
s.channelsInputRange = struct('GuiIDs',{{'channelControlsV4','pcChannelConfig'}},'PropControlData',struct('columnIdx',3,'format','options'));
s.channelsLUT = struct('Callback','changedChannelsLUT');
s.channelsOffset = struct('GuiIDs',{{'channelControlsV4','pcChannelConfig'}},'PropControlData',struct('columnIdx',4,'format','numeric'));
s.channelsSubtractOffset = struct('GuiIDs',{{'channelControlsV4','pcChannelConfig'}},'PropControlData',struct('columnIdx',5,'format','logical'));
s.channelsAutoReadOffsets = struct('GuiIDs',{{'channelControlsV4','cbAutoReadOffsets'}});

s.channelsMergeColor = struct('GuiIDs',{{'channelControlsV4','pcChannelConfig'}},'PropControlData',struct('columnIdx',6,'format','options','prettyOptions',{{'Green' 'Red' 'Blue' 'Gray' 'None'}}));
s.channelsMergeEnable = struct('GuiIDs',{{'channelControlsV4','cbMergeEnable'}},'Callback','changedChannelsMergeEnable');
s.channelsMergeFocusOnly = struct('GuiIDs',{{'channelControlsV4','cbChannelsMergeFocusOnly'}});

s.loggingEnable = struct('GuiIDs',{{'mainControlsV4','cbAutoSave','configControlsV4','cbAutoSave'}},'Callback','changedLoggingEnable');
s.loggingFileStem = struct('GuiIDs',{{'mainControlsV4' 'baseName'}});
s.loggingFileCounter = struct('GuiIDs',{{'mainControlsV4' 'fileCounter'}});
s.loggingFramesPerFile = struct('GuiIDs',{{'configControlsV4' 'etFramesPerFile'}});
s.autoconvert = struct('GuiIDs',{{'configControlsV4','autoconvert'}});
s.focusSave = struct('GuiIDs',{{'configControlsV4','focusSave'}});
s.autoscaleSavedImages = struct('GuiIDs',{{'configControlsV4','checkbox35'}});

s.mergeAlign = struct('GuiIDs',{{'mainControlsV4','mergeAlign'}});
s.mergeshift = struct('GuiIDs',{{'mainControlsV4' 'mergeshift'}}); % PR2014-11-07

s.triggerOut = struct('GuiIDs',{{'mainControlsV4','triggerOut'}});
s.triggerOutDelay = struct('GuiIDs',{{'mainControlsV4' 'triggerOutDelay'}}); 
s.triggerOutDuration = struct('GuiIDs',{{'mainControlsV4' 'triggerOutDuration'}}); 
s.savedBitdepth = struct('GuiIDs',{{'configControlsV4' 'savedBitdepth'}}); 
s.write2RAM = struct('GuiIDs',{{'configControlsV4' 'write2RAM'}}); 
s.offlineAveraging = struct('GuiIDs',{{'configControlsV4' 'offlineAveraging'}}); 

s.ATnbslices = struct('GuiIDs',{{'motorControlsV4' 'ATnbslices'}}); 
s.ATzrange = struct('GuiIDs',{{'motorControlsV4' 'ATzrange'}}); 
s.ATnbframes = struct('GuiIDs',{{'motorControlsV4' 'ATincrement'}}); 
s.ATduringFocusing = struct('GuiIDs',{{'motorControlsV4' 'ATduringFocusing'}}); 

s.loggingFramesPerFileLock = struct('GuiIDs',{{'configControlsV4' 'cbFramesPerFileLock'}});

s.acqState = struct('Callback','changedAcqState');

s.loopNumRepeats = struct('GuiIDs',{{'mainControlsV4','repeatsTotal'}});
s.loopRepeatPeriod = struct('GuiIDs',{{'mainControlsV4','etRepeatPeriod'}});
s.loopRepeatsDone = struct('GuiIDs',{{'mainControlsV4','repeatsDone'}});

s.secondsCounter = struct('Callback','changedSecondsCounter');

s.shutterDelay = struct('GuiIDs',{{'configControlsV4','etShutterDelay'}});

s.statusString = struct('Callback','changedStatusString');

s.triggerStartTrigSrc  = struct('GuiIDs',{{'triggerControlsV4','etStartTrigSrc'}});
s.triggerStartTrigEdge = struct('GuiIDs',{{'triggerControlsV4','pmStartTrigEdge'}},'PrettyOptions',{{'Rising' 'Falling'}});
s.triggerNextTrigSrc = struct('GuiIDs',{{'triggerControlsV4','etNextTrigSrc'}});
s.triggerNextTrigEdge = struct('GuiIDs',{{'triggerControlsV4','pmNextTrigEdge'}},'PrettyOptions',{{'Rising' 'Falling'}});
s.triggerNextTrigMode = struct('GuiIDs',{{'triggerControlsV4','pmNextTrigNextMode'}},'PrettyOptions',{{'Advance' 'Arm'}});
%s.triggerExtStartTrig = struct('GuiIDs',{{'mainControlsV4','tbExternalTrig'}});
s.triggerExtTrigEnable = struct('GuiIDs',{{'mainControlsV4','tbExternalTrig'}});
s.triggerExtTrigAvailable = struct('Callback','changedTriggerExtTrigAvailable');
s.triggerExtStartTrigTimeout = struct('GuiIDs',{{'triggerControlsV4','etExtTrigTimeout'}});
s.triggerExtStartTrigPreScan = struct('GuiIDs',{{'triggerControlsV4','cbScanWhileWait'}});
s.triggerMaxLoopInterval = struct('GuiIDs',{{'triggerControlsV4','pmMaxLoopTriggerInterval'}});
s.triggerMaxLoopIntervalFrames = struct('GuiIDs',{{'triggerControlsV4','etMaxLoopTriggerIntervalFrames'}});

s.userFunctionsCfg = struct('Callback','changedUserFunctionsCfg');
s.userFunctionsUsr = struct('Callback','changedUserFunctionsUsr');
s.userFunctionsOverride = struct('Callback','changedUserFunctionsOverride');

s.usrFilename = struct('Callback','changedUsrFilename');
s.usrPropListCurrent = struct('Callback','changedUsrPropListCurrent');

s.fastz_cont_amplitude = struct('GuiIDs',{{'fastZControlsV4' 'fastz_cont_amplitude'}}); % PR2015-07-08
s.fastz_cont_nbplanes = struct('GuiIDs',{{'fastZControlsV4' 'fastz_cont_nbplanes'}}); % PR2015-07-08
s.fastz_step_settlingtime = struct('GuiIDs',{{'fastZControlsV4' 'fastz_step_settlingtime'}}); % PR2015-07-08
s.fastz_step_stepsize = struct('GuiIDs',{{'fastZControlsV4' 'fastz_step_stepsize'}}); % PR2015-07-08
s.fastz_step_nbplanes = struct('GuiIDs',{{'fastZControlsV4' 'fastz_step_nbplanes'}}); % PR2015-07-08
s.highVal = struct('GuiIDs',{{'fastZControlsV4','highVal'}});
s.lowVal = struct('GuiIDs',{{'fastZControlsV4','lowVal'}});
s.dutyCycleZ = struct('GuiIDs',{{'fastZControlsV4','dutyCycleZ'}});

s.fastZEnable = struct('GuiIDs',{{'fastZControlsV4','cbEnable'}},'Callback','changedFastZEnable'); % PR2015-07-08

s.exec_after = struct('GuiIDs',{{'fastZControlsV4','exec_after'}}); % PR2015-10
s.offset_directly = struct('GuiIDs',{{'fastZControlsV4','offset_directly'}}); % PR2015-10
s.pockelsZ = struct('GuiIDs',{{'fastZControlsV4','pockelsZ'}}); % PR2015-10
s.pockelsZoffset = struct('GuiIDs',{{'fastZControlsV4','pockelsZoffset'}}); % PR2015-10
s.leftbias = struct('GuiIDs',{{'fastZControlsV4','leftbias'}}); % PR2015-10
s.topbias = struct('GuiIDs',{{'fastZControlsV4','topbias'}}); % PR2015-10

s.fastZScanType = struct('GuiIDs',{{'fastZControlsV4','pmScanType'}},'Callback','changedFastZScanType','PrettyOptions',{{'step' 'sawtooth'}});

s.fastZNumVolumes = struct('GuiIDs',{{'fastZControlsV4','etNumVolumes'}});
s.fastZImageType = struct('GuiIDs',{{'fastZControlsV4','pmImageType'}});
%s.fastZSettlingTime = struct('GuiIDs',{{'fastZControlsV4','etSettlingTime'}});
s.fastZSettlingTime = struct('Callback','changedFastZSettlingTime');
s.fastZDiscardFlybackFrames = struct('GuiIDs',{{'fastZControlsV4','cbDiscardFlybackFrames'}},'Callback','changedFastZDiscardFlybackFrames');
s.fastZFramePeriodAdjustment = struct('GuiIDs',{{'fastZControlsV4','pcFramePeriodAdjust'}});
s.fastZVolumesDone = struct('GuiIDs',{{'fastZControlsV4','etVolumesDone'}});
s.fastZNumDiscardFrames = struct('GuiIDs',{{'fastZControlsV4','etNumDiscardFrames'}});

s.pmtGain = struct('Callback','changedPMTGain');
s.pmtEnable = struct('Callback','changedPMTEnable');

% s.frameAcqFcnDecimationFactor = struct('GuiIDs',{{'configControlsV4' 'etFrameAcqFcnDecimationFactor'}});

propBindings = s;

end

function v = zlclShortenFilename(v)
assert(ischar(v));
[~,v] = fileparts(v);
end

%helper for changedStackStartEndPositionPower
function zlclEnableUIControlBasedOnVal(hUIC,val,enableOn)
if isnan(val)
    set(hUIC,'Enable','off');
else
    set(hUIC,'Enable',enableOn);
end
end

