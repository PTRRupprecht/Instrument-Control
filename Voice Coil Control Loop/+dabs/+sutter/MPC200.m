classdef MPC200 < dabs.interfaces.LSCSerial
    %MPC200 Class encapsulating MPC-200 device from Sutter Instruments    
     
    %% ABSTRACT PROPERTY REALIZATIONS (Devices.Interfaces.LinearStageControllerBasic)    
    properties (Constant,Hidden)
        nonblockingMoveCompletedDetectionStrategy = 'callback';
    end
  
    properties (SetAccess=protected,Dependent)
        isMoving;
        infoHardware;
    end
    
    properties (SetAccess=protected,Dependent,Hidden)
        positionAbsoluteRaw;
        velocityRaw; % scalar value
        accelerationRaw; % n/a for MP285
        invertCoordinatesRaw;
        maxVelocityRaw;
        
        resolutionRaw; %Resolution, in um, in the current resolutionMode
    end    

    properties (SetAccess=protected,Hidden)
        positionDeviceUnits = .0625e-6; % 62.5nm resolution for MPC-200
        velocityDeviceUnits = nan;
        accelerationDeviceUnits = nan;
    end
    
    %% ABSTRACT PROPERTY REALIZATIONS (Devices.Interfaces.LSCSerial)    
    properties (Constant)
        availableBaudRates = [125000,128000];
        defaultBaudRate = 128000;
    end
    
    %% CLASS-SPECIFIC PROPERTIES
    properties
        moveMode = 'accelerated'; %One of {'straightLine' 'accelerated'}
    end
    
    properties (Hidden,SetAccess=private)
        velocity_ = dabs.sutter.MPC200.MAX_VELOCITY; %Internally maintained value from 0-15, affecting moves where moveMode='straightLine'. Value of 15 corresponds to ~1.3mm/s. Each lower step reduces speed by ~2x.        
        hMoveCompleteListener; % listens to asyncReplyReceived notification from RS232
    end      
    
    properties (Hidden,Constant)
        MAX_VELOCITY = 15;
        MAX_NUM_DRIVES = 4;
    end
   
    %% CONSTRUCTOR/DESTRUCTOR
    methods

        function obj = MPC200(varargin)
            % obj = MP285(p1,v1,p2,v2,...)
            %
            % P-V options:
            % comPort: (REQUIRED)
            % positionDeviceUnits: (OPTIONAL)
            %
            % See doc for dabs.interfaces.LSCSerial/LSCSerial for
            % other optional P-V arguments.

            lscArgs = {'numDeviceDimensions',3,'defaultTerminator','CR'};
            obj = obj@dabs.interfaces.LSCSerial(lscArgs{:},varargin{:});
            
            pvArgs = most.util.filterPVArgs(varargin,{'positionDeviceUnits'});
            if ~isempty(pvArgs)
                set(obj,pvArgs(1:2:end),pvArgs(2:2:end));
            end
                        
            obj.hMoveCompleteListener = obj.hRS232.addlistener('asyncReplyReceived',@obj.moveDone);
        end
        
    end
    
    %% PROPERTY ACCESS METHODS
    methods

        % throws
        function tf = get.isMoving(obj)
            tf = obj.hRS232.isAwaitingReply();
        end

        % throws
        function val = get.infoHardware(obj)
            val = [];                       
            
            obj.hRS232.sendCommandNoTerminator('U');
            numDrives = obj.hRS232.readBinaryRaw(1);
            
            driveStatus = false(1,obj.MAX_NUM_DRIVES);
            for i=1:obj.MAX_NUM_DRIVES
                driveStatus(i) = obj.hRS232.readBinaryRaw(1);
            end
            
            obj.hRS232.readBinaryRaw(1); %Final carriage return
            
            obj.hRS232.sendCommandNoTerminator('K');
            activeDrive = obj.hRS232.readBinaryRaw(1);
            majorVersion = obj.hRS232.readBinaryRaw(1);
            minorVersion = obj.hRS232.readBinaryRaw(1);                       
            obj.hRS232.readBinaryRaw(1); %Final carriage return
 
            val = sprintf('Firmware version %d.%d - Drive %d of %d active',majorVersion,minorVersion,activeDrive,numDrives);                                             
               
        end

        % throws
        function v = get.positionAbsoluteRaw(obj)
            obj.hRS232.sendCommandNoTerminator('C');
            obj.hRS232.readBinaryRaw(1);            
            posn = obj.hRS232.readBinaryRaw(3,'int32');
            obj.hRS232.readBinaryRaw(1);
            v = posn(:)';
        end

        % throws
        function v = get.invertCoordinatesRaw(obj)
            v = false(1,obj.numDeviceDimensions);
        end
        
        % throws
        function set.velocityRaw(obj,val)
            validateattributes(val,{'numeric'},{'scalar' 'integer' 'nonnegative' '<' 16});
            obj.velocity_ = val;
        end
        
        function v = get.velocityRaw(obj)
            switch obj.moveMode
                case 'accelerated'
                    v = nan;
                case 'straightLine'
                    v = obj.velocity_;
            end
        end        
        
        function v = get.accelerationRaw(obj)
            v = nan;
        end
        
        function v = get.resolutionRaw(obj)            
            v = obj.resolutionBestRaw;
        end
            
        function v = get.maxVelocityRaw(obj)
             v=obj.MAX_VELOCITY;
        end            
        
    end    
    
    methods (Access=private)
        
        function val = zprpGetStatusProperty(obj,statusProp)
            status = obj.getStatus();
            val = status.(statusProp);
        end
        
        function zprpSetVelocityAndResolutionOnDevice(obj)
            val = obj.([obj.resolutionMode 'Velocity']);
            switch obj.resolutionMode
                case 'fine'
                    commandValue = bitor(val,2^15);
                case 'coarse'
                    commandValue = bitor(val,0);
                otherwise
                    assert(false,'Logical programming error. Should not happen');
            end
            
            obj.hRS232.sendCommand('V','terminator','');
            obj.hRS232.sendCommandSimpleReply(uint16(commandValue));
        end

    end
        
    %% ABSTRACT METHOD IMPLEMENTATIONS
    methods (Access=protected,Hidden)

        function moveStartHook(obj,absTargetPosn)
            switch obj.moveMode
                case 'accelerated'
                    obj.hRS232.sendCommandNoTerminator('M');
                    obj.hRS232.sendCommandAsyncReply(int32(absTargetPosn));
                    % hMoveCompleteListener will be listening for reply
                case 'straightLine'
                    obj.hRS232.sendCommandNoTerminator('S');
                    obj.hRS232.sendCommandNoTerminator(int8(obj.velocity));
                    obj.hRS232.sendCommandAsyncReply(int32(absTargetPosn));
                    % hMoveCompleteListener will be listening for reply
            end
        end
        

        function interruptMoveHook(obj)
            obj.hRS232.flushInputBuffer();

            % we need to turn off the asyncReplyPending flag now, to
            % disable the async BytesAvailable callback.
            if obj.hRS232.asyncReplyPending
                obj.hRS232.resetAsync();
            end

            % not sure what state we are in if there is a harderror in the
            % following.
            obj.hRS232.sendCommandRawNoTerminator(char(3));
            obj.hRS232.setSerialObjectProps('timeout',2);
            obj.hRS232.readBinaryRaw(1);
            %obj.hRS232.readStringRaw(); % read CR response
        end

        % TODO
        function recoverHook(obj)
            numTries = 15;
            for i = 1:numTries
                try
                    obj.interruptMoveHook();
                catch %#ok<CTCH>
                    if i < numTries
                        continue;
                    else
                        throwAsCaller(obj.DException('','RecoverFailed','Recover operation for device of type %s FAILED',class(obj)));
                    end
                end
                break;
            end
        end    
  
    end
    

    
end

function resolutionModeMap = getResolutionModeMap()
    %Implements a static property containing Map of resolution multipliers to apply for each of the named resolutionModes
    resolutionModeMap = containers.Map();
    resolutionModeMap('fine') = 1;
    resolutionModeMap('coarse') = 5;
end

