classdef MP285 < dabs.interfaces.LSCSerial
    %MP285 Class encapsulating MP-285 device from Sutter Instruments
    
    %TODO: Add set capability for absolute/relative coordinate display.
    %Consider initializing to absolute coordinates in constructor; and
    %switching to relative following zeroSoft() (? - is this a good idea
    %since there's no way to force, via serial interface, the hardware
    %soft-zero operation, it seems)
    %
    % AL: Theoretically this could use serial/BytesAvailableFcnCount, but
    % it seems to be working fine without that.
    
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
        positionDeviceUnits = .04e-6; % .04 microns is default size of (fine) microstep for MP-285
        velocityDeviceUnits = nan;
        accelerationDeviceUnits = nan;
    end
    
    %% ABSTRACT PROPERTY REALIZATIONS (Devices.Interfaces.LSCSerial)    
    properties (Constant)
        availableBaudRates = [1200 2400 4800 9600 19200];
        defaultBaudRate = 9600;
    end
    
    %% CLASS-SPECIFIC PROPERTIES
    properties (Constant,Hidden)        
        postResetDelay = 0.2; %Time, in seconds, to wait following a reset command before proceeding
        initialVelocity = 1300; %Start at max velocity in fine resolution mode       
        maxVelocityFine = 1300; %Max velocity in fine resolution mode
    end
       
    % TODO: These props may be dup-ing hardware state.
    properties (SetAccess=private,Hidden)
        fineVelocity; % cached velocity for resolutionMode = 'fine'
        coarseVelocity; % cached velocity for resolutionMode = 'coarse'        
    end
    
    properties (Hidden,SetAccess=protected)
        resolutionModeMap = getResolutionModeMap();
    end
    
    properties
        resolutionMode;
    end

    properties (Dependent)
        manualMoveMode; %Specifies if 'continuous' or 'pulse' mode is currently configured for manual moves, e.g. joystick or ROE
        inputDeviceResolutionMode; %Specifies if 'fine' or 'coarse' resolutionMode is being used for manual moves, e.g. with joystick or ROE
        displayMode; %Specifies if 'absolute' or 'relative' coordinates, with respect to linear controller itself, are currently being displayed        
    end
    
    properties (Access=private)
        hMoveCompleteListener; % listens to asyncReplyReceived notification from RS232
    end
   
    %% CONSTRUCTOR/DESTRUCTOR
    methods

        function obj = MP285(varargin)
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
                        
            obj.reset(); %Resets the device, preparing it to receive remote commands
            
            % initialize velocity for each of the resolution modes
            resolutionModes = obj.resolutionModeMap.keys;
            for i = 1:numel(resolutionModes)
                resMode = resolutionModes{i};
                resModeVelocity = obj.initialVelocity * obj.resolutionModeMap(resMode);
                obj.([resMode 'Velocity']) = resModeVelocity;
                obj.resolutionMode = resMode;
            end

            obj.resolutionMode = 'coarse';
            
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
        function v = get.infoHardware(obj)
           v = obj.zprpGetStatusProperty('infoHardware');             
        end

        % throws
        function v = get.positionAbsoluteRaw(obj)
            obj.hRS232.sendCommand('c');
            posn = obj.hRS232.readBinaryRaw(3,'int32');
            obj.hRS232.readBinaryRaw(1);
            v = posn(:)';
        end

        % throws
        function v = get.invertCoordinatesRaw(obj)
           v = obj.zprpGetStatusProperty('invertCoordinates'); 
        end
        
        % throws
        function set.velocityRaw(obj,val)
            assert(isscalar(val),'The MP-285 does not support set axis-specific velocities.');
            assert(val <= obj.maxVelocityRaw,'Velocity value provided exceeds maximum permitted value (%.2g)',obj.maxVelocityRaw);
            
            pname = [obj.resolutionMode 'Velocity'];
            obj.(pname) = val;
            obj.zprpSetVelocityAndResolutionOnDevice();
        end
        
        function v = get.velocityRaw(obj)
            pname = [obj.resolutionMode 'Velocity'];
            v = obj.(pname);
        end       
        
        function v = get.accelerationRaw(obj)
            v = nan; % n/a for MP285
        end
       
        function v = get.resolutionRaw(obj)            
            v = obj.resolutionBestRaw .* obj.resolutionModeMap(obj.resolutionMode);
        end
            
        function v = get.maxVelocityRaw(obj)
            v = obj.maxVelocityFine * obj.resolutionModeMap(obj.resolutionMode); 
        end        

        % throws
        function set.resolutionMode(obj,val)
            assert(obj.resolutionModeMap.isKey(val)); %#ok<MCSUP>
            obj.resolutionMode = val;
            obj.zprpSetVelocityAndResolutionOnDevice();
        end
        
        function v = get.manualMoveMode(obj)
           v = obj.zprpGetStatusProperty('manualMoveMode');             
        end
        
        function v = get.inputDeviceResolutionMode(obj)
           v = obj.zprpGetStatusProperty('inputDeviceResolutionMode');             
        end
        
        function v = get.displayMode(obj)
           v = obj.zprpGetStatusProperty('displayMode');             
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
            obj.hRS232.sendCommandNoTerminator('m');
            obj.hRS232.sendCommandAsyncReply(int32(absTargetPosn));
            % hMoveCompleteListener will be listening for reply
        end

        function moveCompleteHook(obj,absTargetPosn)
            obj.hRS232.sendCommandNoTerminator('m');
            obj.hRS232.sendCommandSimpleReply(int32(absTargetPosn),'timeout',obj.moveTimeout);
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
            obj.hRS232.readStringRaw(); % read CR response
        end

        % TODO
        function recoverHook(obj)
            numTries = 15;
            for i = 1:numTries
                try
                    obj.interruptMoveHook();
                catch ME
                    if i < numTries
                        continue;
                    else
                        ME.rethrow();
                    end
                end
                break;
            end
        end
        
        function resetHook(obj)
            % TODO at moment this does not check/clear asyncpending
            obj.hRS232.sendCommand('r');
            pause(obj.postResetDelay);
        end
        
        function zeroHardHook(obj,coords)
            assert(all(coords),'Cannot zeroHard individual dimensions.');
            obj.hRS232.sendCommandSimpleReply('o');
        end
        
    end
    
    %% HIDDEN METHODS
    methods (Hidden)
        
        % throws
        function statusStruct = getStatus(obj,verbose)
            %function getStatus(obj,verbose)
            %   verbose: Indicates if status information should be displayed to command line. If omitted/empty, false is assumed
            %   statusStruct: Structure containing fields indicating various aspects of the device status...
            %           invertCoordinates: Array in format appropriate for invertCoordinates property
            %           displayMode: One of {'absolute' 'relative'} indicating which display mode controller is in
            %           inputDeviceResolutionMode: One of {'fine','coarse'} indicating resolution mode of input device, e.g. ROE or joystick.
            %           resolutionMode: One of {'fine','coarse'} indicating resolution mode of device with respect to its computer interface -- i.e. the 'resolutionMode' of this class
            %
            
            if nargin < 2 || isempty(verbose)
                verbose = false;
            end
            
            obj.hRS232.sendCommand('s');
            status = obj.hRS232.readBinaryRaw(32,'uint8');
            obj.hRS232.readBinaryRaw(1); % trailing CR
            
            %Parsing pertinent values based on status return data table in MP-285 manual
            statusStruct.invertCoordinates = [status(2) status(3) status(4)] - [0 2 4];
            statusStruct.infoHardware = word2str(status(31:32));
            
            flags = dec2bin(uint8(status(1)),8);
            flags2 = dec2bin(uint8(status(16)),8);
            
            if str2double(flags(2))
                statusStruct.manualMoveMode = 'continuous';
            else
                statusStruct.manualMoveMode = 'pulse';
            end
            
            if str2double(flags(3))
                statusStruct.displayMode = 'relative'; %NOTE: This is reversed in the documentation (rev 3.13)
            else
                statusStruct.displayMode = 'absolute'; %NOTE: This is reversed in the documentation (rev 3.13)
            end
            
            if str2double(flags2(6));
                statusStruct.inputDeviceResolutionMode = 'fine';
            else
                statusStruct.inputDeviceResolutionMode = 'coarse';
            end
            
            speedval = 2^8*status(30) + status(29);
            if speedval >= 2^15
                statusStruct.resolutionMode = 'fine';
                speedval = speedval - 2^15;
            else
                statusStruct.resolutionMode = 'coarse';
            end
            statusStruct.resolutionModeVelocity = speedval;
            
            if verbose
                disp(['FLAGS: ' num2str(dec2bin(status(1)))]);
                disp(['UDIRX: ' num2str(status(2))]);
                disp(['UDIRY: ' num2str(status(3))]);
                disp(['UDIRZ: ' num2str(status(4))]);
                
                disp(['ROE_VARI: ' word2str(status(5:6))]);
                disp(['UOFFSET: ' word2str(status(7:8))]);
                disp(['URANGE: ' word2str(status(9:10))]);
                disp(['PULSE: ' word2str(status(11:12))]);
                disp(['USPEED: ' word2str(status(13:14))]);
                
                disp(['INDEVICE: ' num2str(status(15))]);
                disp(['FLAGS_2: ' num2str(dec2bin(status(16)))]);
                
                disp(['JUMPSPD: ' word2str(status(17:18))]);
                disp(['HIGHSPD: ' word2str(status(19:20))]);
                disp(['DEAD: ' word2str(status(21:22))]);
                disp(['WATCH_DOG: ' word2str(status(23:24))]);
                disp(['STEP_DIV: ' word2str(status(25:26))]);
                disp(['STEP_MUL: ' word2str(status(27:28))]);
                
                %I'm not sure what happens to byte #28
                
                %Handle the Remote Speed value. Unlike all the rest...it's big-endian.
                speedval = 2^8*status(30) + status(29);
                if strcmpi(statusStruct.resolutionMode,'coarse')
                    disp('XSPEED RES: COARSE');
                else
                    disp('XSPEED RES: FINE');
                end
                disp(['XSPEED: ' num2str(speedval)]);
                
                disp(['VERSION: ' word2str(status(31:32))]);
            end            
            
            function outstr = word2str(bytePair)
                val = 2^8*bytePair(2) + bytePair(1); %value comes in little-endian
                outstr = num2str(val);
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

