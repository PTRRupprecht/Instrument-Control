classdef LinearStageController < dabs.interfaces.LSCAnalogOption
    %LinearStageController Class adapting an npoint controller
    %to dabs.interfaces.LSCAnalogOption interface
    
    %% ABSTRACT PROPERTY REALIZATION (dabs.interfaces.LinearStageController)
    properties (Constant,Hidden)
        % Either 'callback' or 'poll'. If 'callback', this class guarantees
        % that moveDone() will be called when a nonblocking move is
        % complete. See documentation for moveStartHook().
        nonblockingMoveCompletedDetectionStrategy = 'poll'; 
    end
    
    properties (SetAccess=protected,Dependent)
        infoHardware;
    end

    properties (SetAccess=protected,Dependent,Hidden)
              
        %Unsupported properties -- no prop getters/setters defined, will
        %simply error
        invertCoordinatesRaw;
        velocityRaw;
        maxVelocityRaw;  
        accelerationRaw;
    end
    
    properties (SetAccess=protected, Hidden)
        resolutionRaw;
        % All units in microns.
        positionDeviceUnits = 1e-6;
        velocityDeviceUnits = 1e-6;
        accelerationDeviceUnits = 1e-6;
    end
   
    
    %% ABSTRACT PROPERTY REALIZATION (dabs.interfaces.LSCAnalogOption)
    
    properties (SetAccess=protected,Hidden)
        analogCmdEnableRaw = false;
    end        
    
    
    %% DEVELOPER PROPERTIES
    

    properties (Hidden,SetAccess=protected)
       hSub; %Handle to specific npoint controller type
       analogCmdEnableProp = ''; 
    end
   
    %% OBJECT LIFECYCLE    
    methods
        function obj = LinearStageController(varargin)
            % obj = LinearStageController(p1,v1,p2,v2,...)
            %
            % PV Args:
            %    controllerType: <REQUIRED> One of {'LC40x'}
            %    comPort: <REQUIRED, if using RS232> Number specifiying COM port to which linear stage controller is connected
            %    baudRate: <REQUIRED, if using RS232> Specify baud rate to use during communication. Must match that set on hardware.
            %    resolutionBest: <OPTIONAL> Specify resolutionBest, in um, for device, which will be enforced as minimum tolerance for analog move completion determination

            %Process input args
            pvCell = most.util.filterPVArgs(varargin,{'controllerType' 'numDeviceDimensions' 'resolutionBest'},{'controllerType'});
            pvStruct = most.util.cellPV2structPV(pvCell);            
            controllerType = pvStruct.controllerType;
            
            %Construct npoint motion controller device
            rootPackageName = 'dabs.npoint';
            mp = meta.package.fromName(rootPackageName);            
            classNames = cellfun(@(x)x.Name,mp.Classes,'UniformOutput',0);
            
            [tf,idx] = ismember(lower(sprintf('%s.%s',rootPackageName,controllerType)),lower(classNames));
            if tf
                hSub_ = feval(classNames{idx},varargin{:}); 
            else
                error('Specified controller type (''%s'') not supported', controllerType);
            end       
            
            %Construct superclass            
            obj = obj@dabs.interfaces.LSCAnalogOption('numDeviceDimensions', hSub_.numChannelsConnected,...
                                                        varargin{:});
            
            %Property initialization             
            obj.hSub = hSub_;            
            obj.hSub.servoControlMode = true;
            
            if isfield(pvStruct,'resolutionBest')
                obj.resolutionBest = pvStruct.resolutionBest;
            end
            
            if isempty(obj.resolution)
                obj.resolution = obj.resolutionBest;
            end

        end        
    end
    
    %% PROPERTY ACCESS METHODS
    
    methods
        function val = get.analogCmdEnableRaw(obj)
            val = obj.analogCmdEnableRaw;            
        end
        
        function set.analogCmdEnableRaw(obj,val)               
            obj.analogCmdEnableRaw = val;                                   
        end
            
        function val = get.infoHardware(~)
            val = ''; %TODO?            
        end
        
        function val = get.invertCoordinatesRaw(~)
            val = nan;
        end        
        
        function val = get.maxVelocityRaw(~)                                              
            val = nan;            
        end
                    
        function val = get.velocityRaw(~)
            val = nan;
        end
        
        function val = get.accelerationRaw(~)
            val = nan;
        end
        
        function val = get.resolutionRaw(obj)
            if isempty(obj.resolutionRaw)           
                val = obj.resolutionBestRaw; %Use value set upon construction
            else
                val = obj.resolutionRaw;
            end               
        end        
        
    end
    
    %% ABSTRACT METHOD IMPLEMENTATIONS (dabs.interfaces.LSCAnalogOption)
    
    methods (Access=protected,Hidden)
        
        function moveStartDigitalHook(obj,targetPosn)
            obj.hSub.positionCommand = targetPosn;            
            %             obj.hSub.moveFinishForce(); %Force reset of NPoint.MotionController asyncMove flag -- relying on asyncMovePending flag in LSC instead
            %             obj.hSub.moveStart(targetPosn);
        end
        
        function tf = isMovingDigitalHook(obj)
            tf = abs(obj.hSub.positionError) > obj.hSub.MAX_RESOLUTION_MICRONS;
        end
        
        function posn = positionAbsoluteRawDigitalHook(obj)
            posn = obj.hSub.positionReading;
        end
        
    end
    
    methods
        function voltage = analogCmdPosn2Voltage(obj,posn)            
            voltage = posn * (obj.hSub.MAX_COMMAND_VOLTAGE/(obj.hSub.range/2));
        end
        
        function posn = analogSensorVoltage2Posn(obj,voltage)            
            posn = voltage * (obj.hSub.range/2)/obj.hSub.MAX_COMMAND_VOLTAGE;      
        end
    end
    
    %% ABSTRACT METHOD IMPLEMENTATIONS (dabs.interfaces.LinearStageController)
    
    methods (Access=protected,Hidden)        
        function recoverHook(~)
            %Do nothing
        end
        
        function val = getResolutionBestHook(obj)
            %Return scalar value identifying best possible resolution that
            %can be expected, in positionDeviceUnits (microns)
            
            val = obj.hSub.MAX_RESOLUTION_MICRONS;            
        end                
    end
end
  


    