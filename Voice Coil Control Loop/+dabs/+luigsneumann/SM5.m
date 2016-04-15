classdef SM5 < dabs.interfaces.LinearStageController & most.MachineDataFile
    
    %% CREDITS
    % Original version contributed by Valentin Stein & Nils Korber, University of Bonn, 5/4/2011
    % Modified by Vijay Iyer 1/2014, for inclusion in ScanImage 3.8.1 & 4.2
    
    %% ABSTRACT PROPERTY REALIZATIONS (dabs.interfaces.LinearStageController)
    properties (Constant,Hidden)
        nonblockingMoveCompletedDetectionStrategy = 'poll';
    end
    
    properties (SetAccess=protected,Dependent)
        positionAbsoluteRaw;
        invertCoordinatesRaw;
        velocityRaw;
        accelerationRaw;
        isMoving;
        maxVelocityRaw;
        infoHardware;
    end
    
    properties (SetAccess=protected,Hidden)
        velocityDeviceUnits = nan;
        accelerationDeviceUnits = nan;
        resolutionRaw = 1;
    end
    
    properties (SetAccess=protected,Hidden)
        positionDeviceUnits = 1e-6; %microns
    end
    
    %% ABSTRACT PROPERTY REALIZATIONS (most.MachineDataFile)
    properties (Constant, Hidden)
        %Value-Required properties
        mdfClassName = mfilename('class');
        mdfHeading = 'Luigs & Neumann SM5';
        
        %Value-Optional properties
        mdfDependsOnClasses; %#ok<MCCPI>
        mdfDirectProp; %#ok<MCCPI>
        mdfPropPrefix; %#ok<MCCPI>
    end
    
    
    %% HIDDEN PROPERTIES
    
    properties (Hidden)
        
        MoveInProgress = false;         % Properties to avoid crossover of commands
        MovingRequest  = true;          % via the isMoving poll
        Serial = [];                    % Serial object for COMmunication
        Timer  = [];                    % Timer object for regular update of connection
        LastAnswer  = [];               % Answer to last Command
        Connected   = false;            % Was it ever connected
        Portopen    = false;            % Port open, might be redundant to connected
        PresentDevice = [];             % Present Devices (Matrix of true and false for 48 possible devices)
        PresentDeviceNumbers = [];      % Numbers of all Devices in the system
        ActualDevice  = uint8(1);       % Device number to talk to, can be direct added in most methods
        Position      = [];             % Postion of a Device in µm,
        PositionOK    = [];             % Is the Position equal to the device display
        StateMotor           = [0 0 0]; % Motor running
        VelocityFast         = []       % Velocity for fast positioning in full steps per s (1:3000) - (associated Command: SM5GoToPosition...)
        
    end
    
    properties (SetAccess=private)
        commandMap = zlclInitCommandMap();        
    end
    
    %% OBJECT LIFE CYCLE
    
    methods 
        function obj = SM5(varargin)
            %global state
            
            pvArgs = most.util.filterPVArgs(varargin,{'comPort' 'numDeviceDimensions'},{'comPort'});           
            
            pvStruct = most.util.cellPV2structPV(pvArgs);
            if ~isfield(pvStruct,'numDeviceDimensions')
                pvArgs = [pvArgs {'numDeviceDimensions' 3}];
            end
            obj = obj@dabs.interfaces.LinearStageController(pvArgs{:});            
            
            %---------------------------------------------------
            % constructor, creates the serial object
            %---------------------------------------------------
            
            oldSerial = instrfind('Tag', 'SM5');
            if ~isempty(oldSerial);
                fclose(oldSerial);
                delete(oldSerial);
                clear('oldSerial');
            end
            
            oldTimer = timerfind('Tag', 'SM5');
            if ~isempty(oldTimer);
                delete(oldTimer);
                clear('oldTimer');
            end
            
            % Create the serial object ons specified com port
            obj.Serial                        = serial(sprintf('COM%d',pvStruct.comPort));               % use connected COM-Port
            obj.Serial.Baudrate               = 38400;
            obj.Serial.Timeout                = 5;
            obj.Serial.Tag                    = 'SM5';
            
            % Create timer object
            % To keep the conncetion alive, something has to be send to the
            % SM5 after 3s. This timer is restarted after every Command send
            % to the SM5, this way no additonal Commands are sent.
            
            obj.Timer                        = timer;
            obj.Timer.Tag                    = 'SM5';
            obj.Timer.Period                 = 2.5;          % call KeepAlive every 2.5s
            obj.Timer.StartDelay             = 2.5;          % 1st call after connect is delayed
            obj.Timer.ExecutionMode          = 'fixedRate';
            obj.Timer.TimerFcn               = @(src,evnt)obj.SM5KeepAlive;
            
            obj.PresentDeviceNumbers = [obj.mdfData.xDevice obj.mdfData.yDevice obj.mdfData.zDevice];
            
            %obj.PresentDeviceNumbers         = [state.motor.xDevice, state.motor.yDevice, state.motor.zDevice];   % from standard.ini
            %obj.VelocityFast                 = state.motor.velocityFast;     % take velocity from INI, all axis have the same speed, we could make the Z axis different
            obj.SM5Connect();
            %             for i = obj.PresentDeviceNumbers
            %                 obj.SM5SetVelocityFast(obj.VelocityFast, i);
            %             end
        end
        
        function delete(obj)                             % Delete handle and close connection
            obj.SM5Disconnect();
            obj.Serial = instrfind('Tag', 'SM5');
            if ~isempty(obj.Serial);
                fclose(obj.Serial);
                delete(obj.Serial);
                clear('obj.Serial');
            end
            stop(obj.Timer);
            obj.Timer = timerfind('Tag', 'SM5');
            if ~isempty(obj.Timer);
                delete(obj.Timer);
                clear('obj.Timer');
            end
        end                
    end
        
        %% HIDDEN METHODS
        methods
        
            function SM5Connect(obj)                            % open the serial and establish the connection
                if ~obj.Connected
                    fopen(obj.Serial);
                    start(obj.Timer);
                    
                    fwrite(obj.Serial, obj.commandMap('Connect'));
                    SM5Power = tic;
                    while obj.Serial.BytesAvailable < 6
                        if toc(SM5Power) > 2
                            error('SM5 is not powered');
                        end
                    end
                    obj.LastAnswer = fread(obj.Serial, 6);
                    obj.Portopen   = true;
                end
            end
            
            function SM5Disconnect(obj)
                if obj.Connected
                    fwrite(obj.Serial,  obj.commandMap('Disconnect'));
                    stop(obj.Timer);                            % keep this order, otherwise you might call KeepAlive, after the port has been closed
                    fclose(obj.Serial);
                    obj.Connected         = false;
                end
            end
            
            function SM5KeepAlive(obj,~,~)
                
                fwrite(obj.Serial, obj.commandMap('KeepAlive'));
                
                while obj.Serial.BytesAvailable < 6
                end
                obj.LastAnswer = fread(obj.Serial, 6);                
            end
            
        end
           
        
        
        %% ABSTRACT PROP ACCESS IMPLEMENTATIONS (dabs.interfaces.LinearStageController)
        methods
            function v = get.positionAbsoluteRaw(obj)
                k = 0;
                for i = obj.PresentDeviceNumbers
                    k = k + 1;
                    obj.SM5GetPosition(i);
                    obj.Position(k) = obj.Position(i);
                end
                v = round(obj.Position.*100)/100;
            end
            
            function tf = get.isMoving(obj)
                if (obj.MovingRequest == true) && (obj.MoveInProgress == false)      % this avoids double call which can cause hard errors
                    obj.MovingRequest = false;
                    obj.SM5GetMainStatusFromOutputStage();
                    obj.MovingRequest = true;
                end
                tf = obj.StateMotor(obj.ActualDevice);
            end
            
            function v = get.infoHardware(obj)
                v = 'L&N SM5';                  % More info might be usefull, e.g. serial number
            end
            
        end
        
        
        %% ABSTRACT METHOD IMPLEMENTATIONS (dabs.interfaces.LinearStageController)
        methods (Access=protected,Hidden)
            
            function moveStartHook(obj,absTargetPosn)
                
                obj.MoveInProgress = true;
                GoTo = absTargetPosn - obj.Position;
                Device = find(abs(GoTo) >= 0.005);      % calls the move only if the distance is bigger than resolution
                Device = obj.PresentDeviceNumbers(Device);
                for i = Device
                    obj.StateMotor(i) = 1;
                    obj.SM5GoToPositionFastRel(GoTo(i),i);
                end
                obj.MoveInProgress = false;
            end
            
            function moveCompleteHook(obj,absTargetPosn)
                GoTo = absTargetPosn - obj.Position;
                Device = find(abs(GoTo) >= 0.005);                     % threshold for minimum movement step
                Device = obj.PresentDeviceNumbers(Device);
                
                for i = Device
                    obj.SM5GoToPositionFastRel(GoTo(i),i);
                end
                
                for i = Device                                          % this is the blocking unit of the blocking move
                    obj.SM5GetMainStatusFromOutputStage(i);
                end
                
                if ~sum(obj.StateMotor)
                    % motor needs double request to ensure switched state recognition
                    % changing status in SM5 seems slow
                    % we might not need this, try to elimnate in future version
                    for i = Device
                        obj.SM5GetMainStatusFromOutputStage(i);
                    end
                end
                
                while sum(obj.StateMotor)
                    for i = Device
                        obj.SM5GetMainStatusFromOutputStage(i);
                    end
                end
                
            end
        end
        
        
        %%  HIDDEN METHODS
        methods (Hidden)
            
            function SM5GetMainStatusFromOutputStage(obj, Device)
                if nargin >= 2
                    obj.ActualDevice = uint8(Device);
                end
                
                command = obj.SM5GenerateCommand('GetMainStatusFromOutputStage',Device);                               
                SM5SendCommand(obj,command,13,false);
                obj.StateMotor(obj.ActualDevice) = obj.LastAnswer(11);
                
                obj.SM5StartKeepAliveTimer();
            end
            
            function SM5GetPosition(obj, Device)
                if nargin >= 2
                    obj.ActualDevice = uint8(Device);
                end
                
                command = obj.SM5GenerateCommand('GetPosition',Device);
                SM5SendCommand(obj,command,10,false);
                obj.Position(obj.ActualDevice) = mexUint8ArrayToSingle(uint8(obj.LastAnswer(5:8))');
                
                obj.SM5StartKeepAliveTimer();                
            end
            
            %        function SM5SetPositionZero (obj, Device)
            %             if nargin >= 2
            %                 obj.ActualDevice = uint8(Device);
            %             end
            %             [msb, lsb, crc] = mexCRC16(obj.ActualDevice, 0);
            %             Command = horzcat(obj.SetPositionZero, obj.ActualDevice, msb, lsb);
            %
            %             stop(obj.Timer);
            %             fwrite (obj.Serial, Command);
            %             while obj.Serial.BytesAvailable < 6
            %             end
            %             obj.LastAnswer = fread(obj.Serial, 6);
            %             obj.Position(obj.ActualDevice) = 0;
            %             stop(obj.Timer);
            %             start(obj.Timer);
            %         end
            
            function SM5GoToPositionFastRel(obj, Position, Device)
                if nargin >= 3
                    obj.ActualDevice = uint8(Device);
                end
                
                TempPos = mexSingleToUint8Array(single(Position));  % convert Positon to an array of Bytes
                
                command = obj.SM5GenerateCommand('GoToPositionFastRel',TempPos);
                SM5SendCommand(obj,command,6,false);
                
                obj.Position(obj.ActualDevice) = obj.Position(obj.ActualDevice) + Position;
                obj.PositionOK(obj.ActualDevice) = false;
                
                obj.SM5StartKeepAliveTimer();
                
            end
            
            function SM5SetVelocityFast(obj, Velocity, Device)                 % 0 < Velocity <= 3000 (full steps per sec)
                if nargin >= 3
                    obj.ActualDevice = uint8(Device);
                end
                TempVel = mexUint16ToUint8Array(uint16(Velocity));
                command = obj.SM5GenerateCommand('SetVelocityFast',TempVel);
                SM5SendCommand(obj,command,6,false);
                
                obj.SM5StartKeepAliveTimer();

            end
            
            function SM5Stop (obj, Device)                                      %stop any Command on the active device
                if nargin >= 2
                    obj.ActualDevice = uint8(Device);
                end
                
                command = SM5GenerateCommand(obj,'Stop');    
                SM5SendCommand(obj,command,6,true);

                obj.SM5StartKeepAliveTimer();

            end
            
           
        end
        
        %% PROTECTED METHODS
        methods  (Access=protected)
            function SM5SendCommand(obj,commandBytes,bytesToRead,insertPause)
                
                if nargin < 4
                   insertPause = false; 
                end                
                
                stop(obj.Timer);
                fwrite(obj.Serial, commandBytes);
                if insertPause
                    pause(1);
                end
                while obj.Serial.BytesAvailable < bytesToRead
                end
                obj.LastAnswer = fread(obj.Serial, bytesToRead);
                
            end
            
            function SM5StartKeepAliveTimer(obj)
                stop(obj.Timer);
                start(obj.Timer);
            end
            
            function command = SM5GenerateCommand(obj,cmdString,cmdArg)                                                
                
                if nargin < 3
                    cmdArg = [];
                end                
                [msb, lsb, crc] = mexCRC16([obj.ActualDevice cmdArg], 0);
                command = horzcat(obj.commandMap('GetPosition'), obj.ActualDevice, cmdArg, msb, lsb);
            end
            
            
        end
end

%% LOCAL FUNCTIONS

function commandMap = zlclInitCommandMap()

commandMap = containers.Map();

commandMap('MaxNumberOfDevices') = 3;                             % 48 posible Devices, 3 for faster connection
commandMap('Connect') = uint8([22, 4, 0,  0, 0, 0]);
commandMap('Disconnect') = uint8([22, 4, 1,  0, 0, 0]);
commandMap('KeepAlive') = uint8([22, 4, 2,  0, 0, 0]);

% Keypad
commandMap('KeyPadon') = uint8([22, 4, 44, 0, 0, 0]);
commandMap('KeyPadoff') = uint8([22, 4, 45, 0, 0, 0]);

% Get information about connected devices
commandMap('OutputStagePresent') = uint8([22, 1, 31, 1]);
commandMap('GetMainStatusFromOutputstage') = ([22, 1, 32, 1]);

% axis activation/deactivation
commandMap('DeactivateAxis') = ([22, 0, 52, 1]);
commandMap('ActivateAxis')   = ([22, 0, 53, 1]);

% Position
commandMap('GetPosition')       = uint8([22, 1, 1, 1]);
commandMap('SetPositionZero')   = uint8([22, 0, 240, 1]);
commandMap('GoToPositionZero')  = uint8([22, 0, 36, 1]);

% Movement
commandMap('GoToPositionFastAbs') = uint8([22, 0, 72, 5]);
commandMap('GoToPositionSlowAbs') = uint8([22, 0, 73, 5]);
commandMap('GoToPositionFastRel') = uint8([22, 0, 74, 5]);
commandMap('GoToPositionSlowRel') = uint8([22, 0, 75, 5]);

commandMap('GoFastPos')           = uint8([22, 0, 18, 1]);
commandMap('GoFastNeg')           = uint8([22, 0, 19, 1]);
commandMap('GoSlowPos')           = uint8([22, 0, 20, 1]);
commandMap('GoSlowNeg')           = uint8([22, 0, 21, 1]);
commandMap('Stop')                = uint8([22, 0, 255, 1]);

% Velocity settings
commandMap('SetVelocitySlow') = uint8([22, 0, 60, 3]);             % for positioning speed (associated Command: SM5GoToPosition...)
commandMap('SetVelocityFast') = uint8([22, 0, 61, 3]);
commandMap('GetVelocityFast') = uint8([22, 1, 96, 1]);
commandMap('GetVelocitySlow') = uint8([22, 1, 97, 1]);

commandMap('SetMoveVelFast')  = uint8([22, 1, 52, 2]);             % for general movement speed (associated Command: SM5Go...)
commandMap('SetMoveVelSlow')  = uint8([22, 1, 53, 2]);
commandMap('GetMoveVelFast')  = uint8([22, 1, 47, 1]);
commandMap('GetMoveVelSlow')  = uint8([22, 1, 48, 1]);

end
