classdef RS232DeviceBasic < most.DClass
    %RS232DEVICEBASIC Basic device with RS232 interface.
    %
    %% NOTES
    % RS232DeviceBasic represents a serial port interface and provides
    % utility functions for handling command/response protocols typically
    % used on serial port devices. It handles simple replies acknowledging
    % command receipt/execution and replies indicating device errors; deals
    % with command/response terminators; provides a minimal facility for
    % dealing with 'asynchronous' commands/responses, etc.
    %
    % Note that under the hood, all reads are actually asynchronous as
    % defined by the MATLAB serial port object. This class refers to
    % 'asynchronous' reads when a method is not blocking, and the response
    % is handled via a callback or external polling.
    %
    % For simplicity, properties of the underlying serial port object are
    % reset before every send/receive command in the public API. These
    % default settings can be initialized during construction; they can
    % also be overridden when the command is sent.
    %
    %% ********************************************************************
    
    %% PUBLIC PROPERTIES
    properties (SetAccess=protected)
        skipTerminatorOnSend = false; % If true, the terminator should not be included in send commands.
        deviceErrorResp = ''; % If set, a single char equal to the device's error reply.
        deviceSimpleResp = ''; % If set, a single char equal to the device's acknowledgment reply.

        defaultTerminator = ''; % Default terminator used for every send/receive command (can be overridden when command is given)
        defaultTimeout = 0.5; % Default response timeout used for every receive command
    end    
    
    %% PROTECTED/PRIVATE PROPERTIES    
    properties (SetAccess=private)        
        asyncReplyPending = false; %Logical indicating if an asynchronous reply is pending
    end
    
    properties (Hidden,SetAccess=private)
        hSerial = []; %Handle to underlying Matlab serial port object
    end
    
    properties (Dependent,Access=private)
        % Struct containing default serial property values to set before
        % every send/receive command (these can be overridden when the
        % command is given)
        beforeEverySerialCommandProps;
    end

                   
    %% EVENTS
    events
        asyncReplyReceived; %Event indicating expected asynchronous reply has been received
    end
     
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = RS232DeviceBasic(varargin)
            % obj = RS232DeviceBasic(p1,v1,p2,v2,...)
            %
            % P-V options:
            % comPort: (REQUIRED) Integer specifying COM port of serial device
            % baudRate: (REQUIRED) Integer etc.
            % skipTerminatorOnSend: (OPTIONAL) See comments in public properties.
            % deviceErrorResp: (OPTIONAL) etc
            % deviceSimpleResp: (OPTIONAL)
            % defaultTerminator: (OPTIONAL)
            % defaultTimeout: (OPTIONAL)
            
            ip = most.util.InputParser;
            ip.addRequiredParam('comPort');
            ip.addRequiredParam('baudRate');
            ip.addOptional('skipTerminatorOnSend',obj.skipTerminatorOnSend);
            ip.addOptional('deviceErrorResp',obj.deviceErrorResp);
            ip.addOptional('deviceSimpleResp',obj.deviceSimpleResp);
            ip.addOptional('defaultTerminator',obj.defaultTerminator);
            ip.addOptional('defaultTimeout',obj.defaultTimeout);
            
            ip.parse(varargin{:});
            allPVs = ip.Results;
            
            % warn for unmatched props
            unmatchedPVs = fieldnames(ip.Unmatched);
            if numel(unmatchedPVs)>0
                tmpstr = sprintf('''%s'', ',unmatchedPVs{:});
                tmpstr = tmpstr(1:end-2);
                warning('RS232DeviceBasic:unmatchedPVs',...
                    'Ignoring unknown properties: %s.',tmpstr);
            end
            
            serialPropNames = {'comPort';'baudRate'};
            objPropNames = setdiff(fieldnames(allPVs),serialPropNames);
            
            % Configure properties of this object
            objPVs = most.util.restrictField(allPVs,objPropNames);
            if numel(fieldnames(objPVs))>0
                obj.set(objPVs);
            end                        
                        
            % Configure serial port object
            serialObjectProps = most.util.restrictField(allPVs,serialPropNames);            
            comport = serialObjectProps.comPort;
            serialObjectProps = rmfield(serialObjectProps,'comPort');
            serialObj = serial(['COM' num2str(comport)],serialObjectProps);
            try
                fopen(serialObj);
            catch ME
                delete(serialObj);
                rethrow(ME);
            end
            obj.hSerial = serialObj;
            
            % Unnecessary since we set these before every communication
            % command, but still
            set(obj.hSerial,obj.beforeEverySerialCommandProps);
            
            obj.hSerial.BytesAvailableFcn = @obj.asyncReplyBytesAvailableFcn;
        end
        
        function delete(obj)
            if ~isempty(obj.hSerial)
                fclose(obj.hSerial);
                delete(obj.hSerial);
                obj.hSerial = [];
            end
        end
        
    end
    
    %% PROPERTY ACCESS
    methods
                
        function set.skipTerminatorOnSend(obj,val)
            assert(isscalar(val) && islogical(val));
            obj.skipTerminatorOnSend = val;
        end
            
        function set.deviceErrorResp(obj,val)
            assert(isempty(val) || (ischar(val) && isscalar(val)),'Invalid value specified for ''deviceErrorResp'' property');
            obj.deviceErrorResp = val;
        end
        
        function set.deviceSimpleResp(obj,val)
            assert(isempty(val) || (ischar(val) && isscalar(val)),'Invalid value specified for ''deviceSimpleResp'' property');
            obj.deviceSimpleResp = val;
        end
        
        function set.defaultTerminator(obj,val)
           assert(ischar(val));
           obj.defaultTerminator = val;
        end
        
        function set.defaultTimeout(obj,val)
            validateattributes(val,{'numeric'},{'scalar' 'nonnegative' 'real'});
            obj.defaultTimeout = val;
        end
        
        function val = get.beforeEverySerialCommandProps(obj)
            val = struct('terminator',obj.defaultTerminator,...
                         'timeout',obj.defaultTimeout);
        end
        
    end
    
    %% USER METHODS    
    methods

        % Pre-flushes received buffer. 
        % varargin: addnl options for serial obj.
        %
        % throws (hware)
        function sendCommand(obj,command,varargin)
            obj.asyncReplyPendingCheck('warning');
            obj.flushInputBuffer;
            obj.setSerialObjectProps(varargin{:});
            obj.sendCommandRaw(command);
        end
        
        % Pre-flushes received buffer. 
        % varargin: addnl options for serial obj.
        %
        % throws (hware)
        function sendCommandNoTerminator(obj,command,varargin)
            obj.asyncReplyPendingCheck('warning');
            obj.flushInputBuffer;
            obj.setSerialObjectProps(varargin{:});
            obj.sendCommandRawNoTerminator(command);
        end
        
        % Synchronous (blocking) send/receive combo
        function resp = sendCommandReceiveStringReply(obj,command,varargin)
            obj.asyncReplyPendingCheck('warning');
            obj.flushInputBuffer;
            obj.setSerialObjectProps(varargin{:});
            assert(~isempty(obj.hSerial.Terminator));

            obj.sendCommandRaw(command); % throws (hware)
            resp = obj.readStringRaw(); % throws (hware)
            obj.detectGeneralRS232Error(resp);
        end        
        
        % Synchronous (blocking) send/receive, with check for 'simple
        % response" return val
        function sendCommandSimpleReply(obj,command,varargin)
            resp = obj.sendCommandReceiveStringReply(command,varargin{:});
            obj.validateSimpleRS232Reply(resp);
        end
            
    end
    
    % Asynchronous (nonblocking) send/receive
    methods
        
        function sendCommandAsyncReply(obj,command,varargin)
            % Send a command to the device and return control to
            % commandline. If/when there is a response, the
            % asyncReplyReceived event will fire.

            obj.asyncReplyPendingCheck('warning');
            obj.flushInputBuffer();
            obj.setSerialObjectProps(varargin{:});
            
            obj.asyncReplyPending = true;

            try                       
                obj.sendCommandRaw(command);
            catch ME
                obj.asyncReplyCleanup();
                ME.throwAsCaller();
            end
        end
        
        % Clears any pending async command. You have to know what you are
        % doing to call this.
        function resetAsync(obj)
            if ~obj.asyncReplyPending
                warning('Dabs:RS232DeviceBasic:noAsyncReplyPending',...
                    'There is no async reply pending.');
            end
            obj.asyncReplyCleanup();
        end
        
        function tf = isAwaitingReply(obj)
            tf = obj.asyncReplyPending;                                  
        end
        
    end
    
    %% SUPERUSER METHODS
    
    % Direct read/write operations. These can throw, eg read operations
    % that timeout waiting for the expected number of bytes.
    %
    % These methods do not first call setSerialObjectProps.
    methods (Hidden)
        
        % Does not pre-flush received buffer. Theoretically can throw (eg
        % on timeout)
        function sendCommandRawNoTerminator(obj,command)
            if ischar(command)
                fprintf(obj.hSerial,'%s',command); % does not send terminator
            else % numeric vector
                precision = class(command);
                fwrite(obj.hSerial,command,precision);
            end
        end

        % Does not pre-flush received buffer. Theoretically can throw (eg
        % on timeout)
        function sendCommandRaw(obj,command)
            obj.sendCommandRawNoTerminator(command);            
            if ~obj.skipTerminatorOnSend && ~isempty(obj.hSerial.Terminator)
                fprintf(obj.hSerial,'');
            end
        end
           
        % Blocking, throws.
        function resp = readBinaryRaw(obj,varargin)
            [resp,~,msg] = fread(obj.hSerial,varargin{:});
            if ~isempty(msg)
                error(msg);
            end                       
        end
        
        % Blocking, throws.
        function resp = readStringRaw(obj)
            [resp,~,msg] = fgetl(obj.hSerial);
            if ~isempty(msg)
                error(msg);
            end
        end
        
    end
    
    %% DEVELOPER METHODS
    
    methods (Access=private)
        
        function asyncReplyBytesAvailableFcn(obj,~,~)
            % We avoid setting/resetting the hSerial.BytesAvailableFcn. In
            % complicated multiple-callback scenarios, this can lead to
            % harderrors in instrcb line 39, where instrcb tries to
            % cell-index an empty value.
            %
            % Instead of setting/resetting BytesAvailableFcn, we leave
            % asyncReplyBytesAvailableFcn as the callback, but use the
            % asyncReplyPending flag to determine whether we should do
            % anything.
            
            if obj.asyncReplyPending
                obj.asyncReplyCleanup();
                obj.flushInputBuffer(); % for now, we do not save the returned results
                notify(obj,'asyncReplyReceived');
            end
        end        
                        
        function asyncReplyPendingCheck(obj,mode)
            %Cleans up any pending async reply during time of issued
            %command. Depending on mode, may issue warning or generate
            %exception.
            %   mode: One of {'warning', 'error', 'silent'}
            
            if obj.asyncReplyPending
                switch mode
                    case 'error'
                        %Generating exception will lead to genericErrorHandler() to clean things up
                        throwAsCaller(MException([obj.classNameShort ':InvalidCommandDuringPendingAsyncResponse'], 'Command issued cannot proceed while an asynchronous response from device remains pending.'));
                    case 'warning'
                        fprintf(2,'WARNING(%s): An asynchronous reply remained pending, but has been aborted. Previously received data is lost\n',mfilename('class'));
                end                
                obj.asyncReplyCleanup();
                obj.flushInputBuffer();
            end
        end
        
        function asyncReplyCleanup(obj)
            obj.asyncReplyPending = false;
        end      

    end
    
    methods
        
        % varargin: PV pairs to be set on serial object
        function setSerialObjectProps(obj,varargin)
            assert(iscell(varargin) && iscellstr(varargin(1:2:end)) && mod(numel(varargin),2)==0,...
                'Expected varargin to be PV pairs.');

            setProps = unique(lower(varargin(1:2:end)));
            settableProps = fieldnames(obj.beforeEverySerialCommandProps);
            assert(all(ismember(setProps,settableProps)),'Unknown or unsettable property(ies).');

            set(obj.hSerial,obj.beforeEverySerialCommandProps);
            if ~isempty(varargin)
                % edge case in set, if varargin is empty you get a disp
                set(obj.hSerial,varargin{:});
            end
        end
        
        function flushInputBuffer(obj)
            if obj.hSerial.BytesAvailable > 0
                obj.readBinaryRaw(obj.hSerial.BytesAvailable);
            end
        end

    end
        
    methods (Access=private)
                                             
        function detectGeneralRS232Error(obj,resp)
        % Checks if the device's 'error symbol' was received
            if ~isempty(obj.deviceErrorResp) && strcmpi(resp(1),obj.deviceErrorResp)   
                obj.DError('','DeviceErrorReply','Reply from RS232 device indicates error -- this typically indicates an invalid or unexpected command was sent');            
            end 
        end
       
        function validateSimpleRS232Reply(obj,resp)
        % Checks if the device's 'simple reply' symbol was received
            if ~isempty(obj.deviceSimpleResp) && ~strcmpi(resp,obj.deviceSimpleResp)   
                obj.DError('','UnexpectedReply','Received unexpected reply from RS232 device');
            end
        end 
                
    end    
 
end

