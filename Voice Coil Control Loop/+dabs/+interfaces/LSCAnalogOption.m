classdef LSCAnalogOption < dabs.interfaces.LinearStageController
    %LSCANALOGOPTION LinearStageController that provides option for controlling position via an analog signal
    %   Class operates directly as a standard LinearStageController by default
    %   When analogCmdEnable is set True, then analog signal is used for position control
    
    
    %% VISIBLE PROPERTIES
    properties  (Dependent)
        analogCmdEnable; %Logical; if true, analog command signal is in use to control LSC position
    end
        
    %% HIDDEN PROPERTIES
    
    %Self-initialized properties
    properties (Hidden, SetAccess=protected)
        analogCmdBoardID;
        analogCmdChanIDs;
        analogSensorBoardID;
        analogSensorChanIDs;
        
        hAOBuffered; %Handle to an AO NI.DAQmx.Task object used for buffered analog control external to this class

        hAOLSC; %Handle to AO NI.DAQmx.Task used by this class for analog LSC operations
        hAILSC; %Handle to AI NI.DAQmx.Task used by this class for analog input operations
        
        analogCmdOutputRange; %2 element array containining [min max] voltage values allowed for FastZ AO control
        analogVoltageOffset; %Measured offset between command and sensor voltage signals
    end        
    
    %% ABSTRACT PROPERTIES
    properties (Abstract,SetAccess=protected,Hidden)        
       analogCmdEnableRaw; %Implements concrete subclass actions, if any, on change of analogCmdEnable
    end
    
    
    %% ABSTRACT PROPERTY REALIZATIONS (dabs.interfaces.LinearStageController)
    
    properties (Dependent,SetAccess=protected)
        isMoving;
    end
    
    properties (Dependent,SetAccess=protected,Hidden)
        positionAbsoluteRaw;
    end
    

    

  %% OBJECT LIFECYCLE    
    methods
        
        function obj = LSCAnalogOption(varargin)       
            % obj = LSCAnalogOption(p1,v1,p2,v2,...)
            %
            % P-V options:
            % analogCmdBoardID: (OPTIONAL) See initializeAnalogOption()
            % analogCmdChanIDs: (OPTIONAL)  See initializeAnalogOption()
            % analogSensorBoardID: (OPTIONAL) See initializeAnalogOption()
            % analogSensorChanIDs: (OPTIONAL)  See initializeAnalogOption()
            % hAOBuffered: (OPTIONAL)  See initializeAnalogOption()
            %            
                        
            % The LinearStageController ignores unrecognized PVs
            obj = obj@dabs.interfaces.LinearStageController(varargin{:});
                        
            pvCell = most.util.filterPVArgs(varargin,{'analogCmdBoardID' 'analogCmdChanIDs' 'hAOBuffered' 'analogSensorBoardID' 'analogSensorChanIDs' });
            pvStruct = struct(pvCell{:});     
            
            %Initialize analog option, if property values are supplied
            analogCmdReqArgs = isfield(pvStruct,{'analogCmdBoardID' 'analogCmdChanIDs'});
            analogSensorReqArgs = isfield(pvStruct,{'analogSensorBoardID' 'analogSensorChanIDs'});
            if any(analogCmdReqArgs) && ~all(analogCmdReqArgs)
                error('The analogCmdBoardID/analogCmdChanIDs properties must either be both provided, or not provided, at construction time.');
            end
            
            if any(analogSensorReqArgs)
                if ~all(analogSensorReqArgs)
                    error('The analogSensorBoardID/analogSensorChanIDs properties must either be both provided, or not provided, at construction time.');
                elseif ~all(analogCmdReqArgs)
                    error('The analogSensor properties can/should only be provided if the analogCmd properties are specified.');
                end
            end                    
                    
            %Initialize analog option directly here if all the required arguments have been provided
            if any(analogCmdReqArgs)
                numActiveDimensions = numel(find(obj.activeDimensions));            
                assert(length(pvStruct.analogCmdChanIDs) == numActiveDimensions,'Number of analog command channels must match the number of active dimensions (%d)',numActiveDimensions);                
                if any(analogSensorReqArgs)
                    assert(length(pvStruct.analogSensorChanIDs) == numActiveDimensions,'Number of analog sensor channels must match the number of active dimensions (%d)',numActiveDimensions);
                end
     
                obj.initializeAnalogOption(varargin{:});
            end
            
            %Property initialization
            if ~isempty(obj.hAOLSC)
                obj.analogCmdEnable = false;
            else
                assert(~obj.analogCmdEnable,'Device of class ''%s'' requires that analogCmdBoardID/analogCmdChanID are specified on construction');
            end    
            
            obj.analogVoltageOffset = zeros(1,obj.numDeviceDimensions);

        end

    end
    
    %% PROPERTY ACCESS 
    methods
        
        function val = get.analogCmdEnable(obj)
            val = obj.analogCmdEnableRaw;                                    
        end
        
        function set.analogCmdEnable(obj,val)
            validateattributes(val,{'numeric' 'logical'},{'binary' 'scalar'});
            
            if val && isempty(obj.hAOLSC) %#ok<MCSUP>
                assert(~val,'No analog output channel has been configured; cannot set analogCmdEnable=true');
            end        
            
            obj.analogCmdEnableRaw = val; %#ok<MCSUP>
        end
        

        
        function val = get.isMoving(obj)
            
            if obj.analogCmdEnable
                val = obj.isMovingAnalogHook();
            else
                val = obj.isMovingDigitalHook();
            end
            
        end
        
        function posn = get.positionAbsoluteRaw(obj)
            
            if obj.analogCmdEnable && ~isempty(obj.hAILSC)
                posn = obj.analogSensorVoltage2Posn(obj.hAILSC.readAnalogData()); %Convert into positions                
            else
                posn = obj.positionAbsoluteRawDigitalHook();
            end
            
        end
          
        
    end

      
    %% ABSTRACT METHOD IMPLEMENTATIONS (dabs.interfaces.LinearStageController)
    
    methods (Access=protected,Hidden)
        
        function moveStartHook(obj,absTargetPosn)            
           
            if obj.analogCmdEnable
                
                %Unreserve external AO Task that shares LSC command channel
                if ~isempty(obj.hAOBuffered)
                    obj.hAOBuffered.control('DAQmx_Val_Task_Unreserve');
                end
                                
                %Write new AO voltage, ensuring it's within AO range
                absTargetPosn(isnan(absTargetPosn)) = [];
                obj.hAOLSC.writeAnalogData(obj.analogCmdPosn2Voltage(absTargetPosn) - obj.analogVoltageOffset);
            else
               obj.moveStartDigitalHook(absTargetPosn); 
            end
            
        end
        
    end 
  
    %% ABSTRACT METHODS
    
    methods (Abstract)
        voltage = analogCmdPosn2Voltage(obj,posn); %Convert LSC position values into analog voltage (scalar function, applies to all dimensions)
        posn = analogSensorVoltage2Posn(obj,voltage); %Convert analog voltage into LSC position values (scalar function, applies to all dimensions) 
    end

    methods (Abstract,Access=protected)        
        posn = positionAbsoluteRawDigitalHook(obj); %Provide default ('digital') readout of LSC's absolute position
        tf = isMovingDigitalHook(obj); %Provide default ('digital') determination of whether LSC is moving when analogCndEnable=false
        moveStartDigitalHook(obj,absTargetPosn); %Provide default ('digital') LSC move behavior when analogCmdEnable=false                        
    end
    
    %'Semi-abstract' methods, with default implementations provided
    methods (Access=protected)
        
        function tf = isMovingAnalogHook(obj) %#ok<MANU>            
                        
            tf = obj.isMovingDigitalHook();                        
            %Subclasses may implement alternative isMoving logic for analog positioning
            
            %             %Verify that final position is within the desired resolution
            %             %before considering the move complete
            %             if ~tf && obj.nonblockingMoveInProgress  && ~isempty(obj.resolution)
            %                 if any(abs(obj.positionAbsolute - obj.lastTargetPosition) > obj.resolution)
            %                     tf = true; %Wait to get closer to desired target position
            %                 end
            %             end
        end                   
        
    end
    
    %% SUPERUSER METHODS
    
    methods (Hidden)
        
        function initializeAnalogOption(obj,varargin)
            %function initializeAnalogOption(obj,p1,v1,p2,v2,...)
            %Initialize the analog command option, configuring an NI DAQmx AO Task to be used for analog control
            %
            % P-V options:
            % analogCmdBoardID: (OPTIONAL) String specifying NI board identifier (e.g. 'Dev1') containing AO channel for LSC control
            % analogCmdChanIDs: (OPTIONAL) Scalar indicating AO channel number (e.g. 0) used for analog LSC control
            % hAOBuffered: (OPTIONAL) Handle to NI.DAQmx AO Task object used by client which also controls same analogCmdBoard/ChannelID for buffered AO operations
            % analogSensorBoardID: (OPTIONAL) String specifying NI board identifier (e.g. 'Dev1') containing AI channel for LSC position sensor
            % analogSensorChanIDs: (OPTIONAL) Scalar indicating AI channel number (e.g. 0) used for analog LSC position sensor
            %
            % offsetNumMeasurements: (Default=20) Number of voltage measurements to take when determining command/sensor offset
            % Notes:
            %   The hAOBuffered option should be provided if the client controls same analogCmdBoard/ChannelID for buffered operations.
            %   This class will ensure those resources are unreserved before issuing LSC commands
                        
            pvCell = most.util.filterPVArgs(varargin,{'analogCmdBoardID' 'analogCmdChanIDs' 'analogSensorBoardID' 'analogSensorChanIDs' 'hAOBuffered'},{'analogCmdBoardID' 'analogCmdChanIDs'});
            pvStruct = most.util.cellPV2structPV(pvCell);
            
            assert(isempty(obj.hAOLSC),'The ''initalizeAnalogOption'' method can only be called once for objects of class ''%''.',mfilename('class'));
            
            %Handle external buffered-AO Task, if provided
            if isfield(pvStruct,'hAOBuffered')
                hTmp = pvStruct.hAOBuffered;
                assert(isa(hTmp,'dabs.ni.daqmx.Task') && ~isempty(hTmp.channels) && strcmpi(hTmp.taskType,'AnalogOutput'),'Property ''hAOBuffered'' must contain a DAQmx.Task object with one AO channel');            
                obj.hAOBuffered = hTmp;
            end            
           
            %Create hAOLSC
            obj.hAOLSC = dabs.ni.daqmx.Task();
            obj.hAOLSC.createAOVoltageChan(pvStruct.analogCmdBoardID,pvStruct.analogCmdChanIDs);                                  
            obj.analogCmdBoardID = pvStruct.analogCmdBoardID;
            obj.analogCmdChanIDs = pvStruct.analogCmdChanIDs;
            
            obj.analogCmdOutputRange = [obj.hAOLSC.channels(1).get('min') obj.hAOLSC.channels(1).get('max')]; %Determine/cache AO range            
            
            %Create hAILSC, if specified
            if isfield(pvStruct,'analogSensorBoardID')
                obj.hAILSC = dabs.ni.daqmx.Task();
                obj.hAILSC.createAIVoltageChan(pvStruct.analogSensorBoardID,pvStruct.analogSensorChanIDs);
                obj.analogSensorBoardID = pvStruct.analogSensorBoardID;
                obj.analogSensorChanIDs = pvStruct.analogSensorChanIDs;
            end
                                                
            %Determine analogVoltageOffset. Offset encompasses any offset on
            %the AO & AI channels, as well as those between the LSC command
            %and monitor signals themselves 
            %
            %NOTE - this does not address any offset variation with position,
            %i.e. due to nonlinearities
            
            if ~isempty(obj.hAILSC)
                assert(~isempty(obj.hAOLSC));
                
                cachedAnalogCmdEnable = obj.analogCmdEnable;
                obj.analogCmdEnable = true;
                
                if isfield(pvStruct,'offsetNumMeasurements')
                    numReadings = pvStruct.offsetNumMeasurements;
                else
                    numReadings = 5000;
                end               

                initialSensorVoltage = mean(obj.hAILSC.readAnalogData(numReadings));                
                obj.hAOLSC.writeAnalogData(initialSensorVoltage);                
                testSensorVoltage = mean(obj.hAILSC.readAnalogData(numReadings));                
                                
                obj.analogVoltageOffset = testSensorVoltage - initialSensorVoltage;
                
                obj.analogCmdEnable = cachedAnalogCmdEnable;
            end

        end
        
        
        
        
    end
    
end

