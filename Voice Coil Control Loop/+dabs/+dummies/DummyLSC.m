classdef DummyLSC < dabs.interfaces.LinearStageController
    
    %% ABSTRACT PROPERTY REALIZATION (dabs.interfaces.LinearStageController)
    properties (Constant,Hidden)
        nonblockingMoveCompletedDetectionStrategy = 'callback'; % Either 'callback' or 'poll'
    end
    
    properties (SetAccess=protected,Dependent)
        isMoving;
    end
    
    properties (SetAccess=protected,Dependent,Hidden)
        invertCoordinatesRaw;
        positionAbsoluteRaw; 
        velocityRaw;
        accelerationRaw;
		maxVelocityRaw;        
    end
    
    properties (SetAccess=protected,Hidden)
        resolutionRaw = 1;
    end

    properties (SetAccess=protected)
        infoHardware = 'I am a dummy stage'; %String providing information about the hardware, e.g. firmware version, manufacture date, etc. Information provided is specific to each device type.
    end
    
    properties (SetAccess=protected,Hidden)
        positionDeviceUnits = .04e-6; %Units, in meters, in which the device's position values (as reported by positionAbsoluteRaw) are given
        velocityDeviceUnits = nan; %Units, in meters/sec, in which the device's velocity values (as reported by its hardware interface) are given. Value of NaN implies arbitrary units.
        accelerationDeviceUnits = nan; %Units, in meters/sec^2, in which the device's acceleration values (as reported by its hardware interface) are given. Value of NaN implies arbitrary units.         
    end
    
    %% DEVELOPER PROPERTIES
    properties (Hidden,SetAccess=protected)
        moveDummyTimer;
        positionDummy;
    end
    
    %% CTOR/DTOR
    methods
        function obj = DummyLSC(varargin)
            pvArgs = most.util.filterPVArgs(varargin,{'numDeviceDimensions'});
            if isempty(pvArgs)
                pvArgs = {'numDeviceDimensions' 3};
            end

            obj = obj@dabs.interfaces.LinearStageController(pvArgs{:});  
            obj.positionDummy = zeros(1,obj.numDeviceDimensions);
        end
    end
    
    %% PROPERTY ACCESS
    methods
        
        function val = get.positionAbsoluteRaw(obj)
            val = obj.positionDummy;            
        end
        
        function val = get.resolutionRaw(obj)
            val = 1;
        end
        
        function val = get.isMoving(obj)
            val = ~isempty(obj.moveDummyTimer) && isvalid(obj.moveDummyTimer);
        end        
        
    end
    
    %% ABSTRACT METHOD IMPLEMENTATIONS
    methods (Access=protected,Hidden)

        function moveCompleteHook(obj,targetPosn)
            % simulate a move...
            delta = max(abs(obj.positionDummy - targetPosn));
            pause(delta * 0.01);
            
            obj.positionDummy = targetPosn;
        end   
        
        function moveStartHook(obj,targetPosn)                                                              
            delta = max(abs(obj.positionDummy - targetPosn));
            
            obj.positionDummy = targetPosn;
            
            % setup a timer to set 'isMoving' to false after a brief delay 
            if delta > 0
                obj.moveDummyTimer = timer('Name','DummyLSC Timer','TimerFcn',@obj.moveDummyTimerFcn,'StartDelay',round(delta*0.01),'Period',(delta*0.01),'ExecutionMode','singleShot');
                start(obj.moveDummyTimer);
            end
        end    
        
        function interruptMoveHook(obj)
            stop(obj.moveDummyTimer);
        end           
        
        function recoverHook(obj)
            return;
        end
        
        function resetHook(obj)
            return;
        end
        
        function zeroHardHook(obj,coords)
            assert(all(coords),'Cannot hard-zero individual coordinates.');
            obj.positionDummy = zeros(size(obj.positionDummy));
        end    
    
    end    
    
    %% DEVELOPER METHODS
    
    methods (Access=protected)
        function moveDummyTimerFcn(obj,~,~)
            stop(obj.moveDummyTimer);
            delete(obj.moveDummyTimer);
            obj.moveDone(); %Signal to LSC class that move has been completed
        end        
    end
    
end    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  classdef DummyLSC < dabs.interfaces.LinearStageController
    %
    %     %% OTHER CLASS-SPECIFIC PROPERTIES
    %     properties (Hidden)
    %         moveDummyTimer;
    %         positionDummy = [0 0 0]; % we don't have a device for our PDEP 'positionAbsolute' to reference, so shadow it with this.
    %         isMovingDummy = false;
    %     end
    %
    %     properties (Hidden, Constant)
    %
    %     end
    %
    %     %% ABSTRACT PROPERTY REALIZATIONS
    %
    %     properties (Hidden)
    %         zeroHardWarning=false; %Logical flag indicating, if true, that warning should be given prior to executing zeroHard() operations
    %     end
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     %Following are copied/pasted from superclass definition, but with subclass-specific values set/initialized
    %     properties (SetAccess=protected,Hidden)
    %         devicePositionUnits=1e-7;
    %         deviceVelocityUnits=nan;
    %         deviceAccelerationUnits=nan;
    %         deviceErrorResp = '';   % hopefully our dummy doesn't generate errors...
    %         deviceSimpleResp = '';
    %
    %         stageTypeMap = getStageTypeMap();
    %         resolutionModeMap = getResolutionModeMap();
    %     end
    %
    %     properties (Constant,Hidden)
    %         moveModes={};
    %     end
    %
    %     properties (Constant, Hidden)
    %         hardwareInterface='dummy'; % 'One of {'serial' 'dummy'}
    %         safeReset=true;
    %
    %         maxNumStageAssemblies=3;
    %         requiredCustomStageProperties={}; %Cell array of properties that must be set on construction if one or more of the stages is 'custom'
    %
    %         moveCompletedDetectionStrategy = 'moveCompleteTimer';
    %         moveCompleteHookFcn = [];
    %     end
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %     %% CONSTRUCTOR/DESTRUCTOR
    %     methods
    %         function obj = DummyLSC(varargin)
    %             stageType = 'dummy';
    %
    %             %Call superclass constructors
    %             obj = obj@dabs.interfaces.LinearStageController(stageType,'availableBaudRates',[1200 2400 4800 9600 19200], 'standardBaudRate',9600,varargin{:});
    %
    %             %Initialize serial port properties
    %             obj.hHardwareInterface.terminatorDefault = 'CR';
    %
    %             %Verfify that we can communicate with the hardware device
    %             assert(obj.testHardwareConnection(),'Unable to communicate with device');
    %
    %             %Subclass-specific initialization
    % %             obj.velocity = obj.maxVelocity;
    % %
    % %             %Method invoked to (re)initialize property values, applying values to hardware interface
    % %             obj.initializeDefaultValues();
    %         end
    %
    %     end
    %
    %     %% PROPERTY ACCESS METHODS
    %
    %     %%%Pseudo property-access for pseudo-dependent properties
    %     methods (Access=protected)
    %         function pdepPropHandleGetHook(obj,src,evnt)
    %             propName = src.Name;
    %
    %             switch propName
    %                 case {'positionAbsoluteRaw' 'positionAbsolute' 'velocity' 'velocityStart' 'acceleration' 'invertCoordinates' 'isMoving' 'limitReached' 'infoHardware' 'current' 'positionUnitsScaleFactor' 'maxVelocity'}
    %                     obj.pdepPropIndividualGet(src,evnt);
    %                 case {'resolutionMode' 'moveMode' 'stageAssemblyIndex'}
    %                     %Do nothing --> pass-through (shoudl there be a method for this?)
    %                 otherwise %Defer to superclass for default handling (error)
    %                     obj.pdepPropGetDisallow(src,evnt);
    %             end
    %
    %         end
    %
    %         function pdepPropHandleSetHook(obj,src,evnt)
    %             propName = src.Name;
    %
    %             switch propName
    %                 case {'velocity' 'velocityStart' 'acceleration' 'invertCoordinates' 'current' 'positionUnitsScaleFactor'}
    %                     obj.pdepPropIndividualSet(src,evnt);
    %                 case {'resolutionMode' 'moveMode'}
    %                     %Do nothing --> pass-through
    %                 otherwise
    %                     obj.pdepPropSetDisallow(src,evnt);
    %             end
    %         end
    %     end
    %
    %     methods (Hidden)
    %
    % 		function val = getPositionAbsoluteRaw(obj)
    %             val = obj.positionDummy;
    %         end
    %
    %         function val = getPositionAbsolute(obj)
    %             val = obj.positionDummy;
    %         end
    %
    %         function val = getMaxVelocity(obj)
    %             val = 100;
    %         end
    %
    %         function val = getVelocity(obj)
    %             val = obj.velocity;
    %         end
    %
    %         function setVelocity(obj,val)
    %             obj.velocity = val;
    %         end
    %
    %         function val = getAcceleration(obj)
    %             val = obj.acceleration;
    %         end
    %
    %         function setAcceleration(obj,val)
    %             obj.acceleration = val;
    %         end
    %
    %         function val = getLimitReached(obj)
    %             val = false;
    %         end
    %
    %         function tf = getIsMoving(obj)
    %             tf = obj.isMovingDummy;
    %         end
    %
    %         function val = getInfoHardware(obj)
    %             val = 'I am a dummy stage';
    %         end
    %
    %         function val = getInvertCoordinates(obj)
    %            val = 1;
    %         end
    %
    %     end
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %
    %     %% ABSTRACT METHOD IMPLEMENTATIONS
    %     methods (Access=protected,Hidden)
    %
    %         function moveCompleteHook(obj,targetPosn)
    %             obj.isMovingDummy = true;
    %
    %             % simulate a move...
    %             delta = max(abs(obj.positionAbsolute - targetPosn));
    %             pause(delta * 0.01);
    %
    %             obj.positionDummy = targetPosn;
    %             return;
    %         end
    %
    %         function moveStartHook(obj,targetPosn)
    %             obj.isMovingDummy = true;
    %             delta = max(abs(obj.positionAbsolute - targetPosn));
    %
    %             obj.positionDummy = targetPosn;
    %
    %             % setup a timer to set 'isMoving' to false after a brief delay
    %             if delta > 0
    %                 obj.moveDummyTimer = timer('TimerFcn',@obj.moveDummyTimerFcn,'StartDelay',round(delta*0.01),'Period',(delta*0.01),'ExecutionMode','singleShot');
    %                 start(obj.moveDummyTimer);
    %             else
    %                 obj.isMovingDummy = false;
    %             end
    %         end
    %
    %         function isHardwareConnected = testHardwareConnection(obj)
    %             isHardwareConnected = true;
    %         end
    %
    %     end
    %
    %     %% PRIVATE/PROTECTED METHODS
    %     methods (Access=protected)
    %
    %         function moveDummyTimerFcn(obj,~,~)
    %             stop(obj.moveDummyTimer);
    %             delete(obj.moveDummyTimer);
    %
    %             obj.isMovingDummy = false;
    %         end
    %
    %     end
    %
    % end
    %
    % function stageTypeMap = getStageTypeMap()
    %     %Implements a static property containing Map indexed by the valid stageType values supported by this class, and containing properties for each
    %     stageTypeMap = containers.Map();
    %     stageTypeMap('dummy') = struct('resolution', .04);
    % end
    %
    % function resolutionModeMap = getResolutionModeMap()
    %     %Implements a static property containing Map of resolution multipliers to apply for each of the named resolutionModes
    %     resolutionModeMap = containers.Map();
    %     resolutionModeMap('default') = 1;
    % end
