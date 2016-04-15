classdef LC40x < handle & most.DClass 
    %LC40x
    %   Notes:
    %       * positionReading value is 'bipolar': values ranging to or slightly beyond +/- (range/2) are attainable. 
    %       * Command input to controll is sum of positionCommand value and analog signal supplied to controller input 
    %       
    
    %% PUBLIC PROPERTIES
    
    %????? Are these used?!
    properties (GetObservable,SetObservable)
        position;
        identificationString;
        velocity;
        overflowStatus;
        
    end
    
    properties
        rangeType;      % One of {'microns' 'millimeters' 'uradians'}
        positionCommand; % Commanded position of piezo, in microns. Value is added to any analog input. Values between or slightly beyond +/- (range/2) are supported (when analog command is 0V).
        servoState;     % Logical. True if servo circuit enabled, allowing position control via analog signal.       
        currentChannel; % Numeric scalar indicating which piezo channel is being controlled/monitored.
        servoControlMode; % Used by LSCAnalogOption to determine the servo control mode of an axis.           
        
        asyncMovePending = false;  % Used by LSCAnalogOption to determine if the stage is currently in the process of making an asynchronous move.
        asyncMoveTimeReference;
                       
        %         pidProportionalGain;
        %         pidIntegralGain;
        %         pidDerivativeGain;
        
        %         saveConfiguration;
        %         saveWavetable;

        %         % TTL
        %         inputPin1Function;
        %         inputPin2Function;
        %         inputPin3Function;
        %         inputPin4Function;
        %
        %         inputPin1Polarity;
        %         inputPin2Polarity;
        %         inputPin3Polarity;
        %         inputPin4Polarity;
        %
        %         outputPin6Function;
        %         outputPin7Function;
        %         outputPin8Function;
        %         outputPin9Function;
        %
        %         outputPin6Polarity;
        %         outputPin7Polarity;
        %         outputPin8Polarity;
        %         outputPin9Polarity;
        %
        %         outputErrorFunctionTolerance;
        %         outputWaveformIndexCount;
        %         outputLowIndexArrayBaseOffset;
        %         outputHighIndexArrayBaseOffset;
        %
        %         % Wavetable
        %         wavetableEnable;
        %         wavetableIndex;
        %         wavetableCycleDelay;
        %         wavetableEndIndex;
        %         wavetableActive;
        
    end
    
    properties(SetAccess=private)
        numChannelsConnected; %Number of channels physically connected to controller
        %TODO: Fix pid reads, using read array
        %         pidProportionalGain;
        %         pidIntegralGain;
        %         pidDerivativeGain;
        positionReading; %Position of piezo, in microns
        range;
        
        positionError; %Difference between commanded position and current position, in um
    end
    
    %% HIDDEN PROPERTIES
    properties (Hidden,SetAccess=private)
        hSerial; %Handle to MATLAB serial object        
    end
    
    properties (Hidden,Constant)
        CHAN_BASE_ADDRESS = hex2dec('11830000');
        CHAN_OFFSET = hex2dec('1000');
        DIGITAL_MAX_VAL = 524287; %Value is digitally represented by controller over range of +/-DIGITAL_MAX_VAL
        
        MAX_RESOLUTION_MICRONS = 0.1; %When settled, positionError is always less than this value
        MAX_COMMAND_VOLTAGE = 10; %Command voltags from +/- MAX_COMMAND_VOLTAGE map to +/-DIGITAL_MAX_VAL (i.e. +/- range/2)
    end
    
    
    %% LIFECYCLE
    methods
        
        function obj = LC40x(varargin)
            % obj = LC40x(p1,v1,p2,v2,...)
            %
            % P-V options:
            % comPort: (REQUIRED) Integer specifying COM port of serial device
            % baudRate: (OPTIONAL) Integer etc.
            %
            % See constructor documentation for
            % dabs.interfaces.RS232DeviceBasic and
            
            pv = most.util.filterPVArgs(varargin,{'comPort' 'baudRate'},{'comPort'});
            pv = most.util.cellPV2structPV(pv); %convert to struct
            
            if ~isfield(pv,'baudRate')
                pv.baudRate = 9600;
            end
            
            %             obj.hRS232 = dabs.interfaces.RS232DeviceBasic('comPort',pv.comPort,'baudRate',pv.baudRate);
            %             obj.hRS232.defaultTerminator = '7';
            obj.hSerial = serial(sprintf('com%d',pv.comPort),'baudRate',pv.baudRate);
            fopen(obj.hSerial);
            
            %Initializations
            obj.currentChannel = 1;

        end
        
        function delete(obj)
            fclose(obj.hSerial);
            delete(obj.hSerial);
        end
      
    end
    
    %% PROPERTY ACCESS METHODS
    methods
      
        function set.servoControlMode(obj,val)
            validateattributes(val,{'logical'},{'nonempty'});
            obj.servoControlMode = val;
        end


        function set.currentChannel(obj,val)
            validateattributes(val,{'numeric'},{'scalar' 'integer' 'positive'});
            assert(val <= obj.numChannelsConnected,'Invalid channel specified: controller has only %d channels',val); %#ok<*MCSUP>
            obj.currentChannel = val;
        end
       
        % General Addresses
        
        function val = get.numChannelsConnected(obj)
            %TODO: Fix for case of more than 1 channel. Controller uses a bitmask representation.
            val = 255 - obj.zprpReadLocation('118303A0','int32');
        end

        %         function set.saveConfiguration(obj,val)
        %            obj.zprpWriteChannelLocation('11829010',1);
        %            % Read 0x11829010 until value returned is equal to 0.
        %            % If value is 0, then the write to device FLASH EEPROM is complete.
        %
        %         end
        %
        %         function set.saveWavetable(obj,val)
        %             validateattributes(val,{'numeric'},{'scalar' 'integer' 'positive'});
        %             assert(val <= obj.numChannelsConnected,'Invalid channel specified: controller has only %d channels',val); %#ok<*MCSUP>
        %             obj.zprpWriteChannelLocation('11829020',val);
        %         end

        % Static Positioning Addresses
        
        function val = get.positionCommand(obj)
            digVal = obj.zprpReadChannelLocation('218','int32');
            val = (digVal/ obj.DIGITAL_MAX_VAL) * (obj.range / 2);
        end
        
        function set.positionCommand(obj,val)
            obj.zprpWriteChannelLocation('218','int32',(obj.DIGITAL_MAX_VAL * 2 / obj.range) * val);
        end

        function val = get.positionReading(obj)
            digVal = obj.zprpReadChannelLocation('334','int32');            
            val = (digVal / obj.DIGITAL_MAX_VAL) * (obj.range / 2);
        end
        

        % Control Loop Addresses
        
        function val = get.positionError(obj)
            digVal = obj.zprpReadChannelLocation('408','int32');
            val = (digVal/ obj.DIGITAL_MAX_VAL) * (obj.range / 2);
        end
        
        %         function val = get.pidDerivativeGain(obj)
        %             val = obj.zprpReadChannelLocation('730','double');
        %         end
        %
        %         function val = get.pidIntegralGain(obj)
        %             val = obj.zprpReadChannelLocation('728','double');
        %         end
        %
        %         function val = get.pidProportionalGain(obj)
        %             val = obj.zprpReadChannelLocation('720','double');
        %         end

        
        function val = get.range(obj)
            persistent range
            if isempty(range)
                range = obj.zprpReadChannelLocation('78','int32');
            end
            val = range;
        end

        function val = get.rangeType(obj)
           val = obj.zprpReadChannelLocation('44','int32'); 
        end
                
        function val = get.servoState(obj)
            val = obj.zprpReadChannelLocation('84','int32');
        end
                
        function set.servoState(obj,val)
            obj.zprpWriteChannelLocation('84','int32',val);
        end
        
        %         % Digital I/O Trigger Addresses
        %
        %         function set.inputPin1Function(obj,val)
        %             % 0 - none
        %             % 1 - edge triggered start
        %             % 2 - level triggered start
        %             % 3 - edge triggered stop
        %             % 4 - level triggered stop
        %             % 5 - level triggered start and stop
        %             % 6 - edge triggered pause and resume
        %             % 7 - level triggered pause and resume
        %             obj.zprpWriteChannelLocation('94','int32',val);
        %         end
        %
        %         function set.inputPin2Function(obj,val)
        %             obj.zprpWriteChannelLocation('98','int32',val);
        %         end
        %
        %         function set.inputPin3Function(obj,val)
        %             obj.zprpWriteChannelLocation('9C','int32',val);
        %         end
        %
        %         function set.inputPin4Function(obj,val)
        %             obj.zprpWriteChannelLocation('A0','int32',val);
        %         end
        %
        %         function set.inputPin1Polarity(obj,val)
        %             % 0 - rising edge / active high
        %             % 1 - falling edge / active low
        %             obj.zprpWriteChannelLocation('B4','int32',val);
        %         end
        %
        %         function set.inputPin2Polarity(obj,val)
        %             obj.zprpWriteChannelLocation('B8','int32',val);
        %         end
        %
        %         function set.inputPin3Polarity(obj,val)
        %             obj.zprpWriteChannelLocation('BC','int32',val);
        %         end
        %
        %         function set.inputPin4Polarity(obj,val)
        %             obj.zprpWriteChannelLocation('C0','int32',val);
        %         end
        %
        %         function set.outputPin6Function(obj,val)
        %             % 0 - none
        %             % 1 - control loop error
        %             % 2 - waveform index level
        %             % 3 - waveform index pulse
        %             obj.zprpWriteChannelLocation('F4','int32',val);
        %         end
        %
        %         function set.outputPin7Function(obj,val)
        %             obj.zprpWriteChannelLocation('F8','int32',val);
        %         end
        %
        %         function set.outputPin8Function(obj,val)
        %             obj.zprpWriteChannelLocation('FC','int32',val);
        %         end
        %
        %         function set.outputPin9Function(obj,val)
        %             obj.zprpWriteChannelLocation('100','int32',val);
        %         end
        %
        %         function set.outputPin6Polarity(obj,val)
        %             % 0 - rising edge, active high
        %             % 1 - falling edge, active low
        %             obj.zprpWriteChannelLocation('114','int32',val);
        %         end
        %
        %         function set.outputPin7Polarity(obj,val)
        %             obj.zprpWriteChannelLocation('118','int32',val);
        %         end
        %
        %         function set.outputPin8Polarity(obj,val)
        %             obj.zprpWriteChannelLocation('11C','int32',val);
        %         end
        %
        %         function set.outputPin9Polarity(obj,val)
        %             obj.zprpWriteChannelLocation('120','int32',val);
        %         end
        %
        %         function set.outputErrorFunctionTolerance(obj,val)
        %             % Threshhold value is a 20 bit number with the same
        %             % bits per distance scale factor as the Digital Position
        %             % Command.
        %             obj.zprpWriteChannelLocation('154','int32',val);
        %         end
        %
        %         function set.outputWaveformIndexCount(obj,val)
        %             % # of low and high index pairs.
        %             obj.zprpWriteChannelLocation('158','int32',val);
        %         end
        %
        %         function set.outputLowIndexArrayBaseOffset(obj,val)
        %             % base offset for an array of up to 16 waveform indices.
        %             obj.zprpWriteChannelLocation('15C','int32',val);
        %         end
        %
        %         function set.outputHighIndexArrayBaseOffset(obj,val)
        %             % base offset for an array of up to 16 waveform indices.
        %             obj.zprpWriteChannelLocation('19C','int32',val);
        %         end
        %
        %         % Wavetable Addresses
        %         function set.wavetableEnable(obj,val)
        %             % 1 - enables wavetable scanning (BNC analog input disabled)
        %             % 0 - disables wavetable scanning (BNC analog input enabled)
        %             obj.zprpWriteChannelLocation('1F4','int32',val);
        %         end
        %
        %         function set.wavetableIndex(obj,val)
        %             % Index of wavetable point that will be output during
        %             % current clock cycle if the waveform is running.
        %             obj.zprpWriteChannelLocation('1F8','int32',val);
        %         end
        %
        %         function set.wavetableCycleDelay(obj,val)
        %             % Clock cycles to wait before next wavetable point is output.
        %             obj.zprpWriteChannelLocation('200','int32',val);
        %         end
        %
        %         function set.wavetableEndIndex(obj,val)
        %             % Value should be set to # of points in waveform - 1.
        %             % Max is 83,333 points.
        %             obj.zprpWriteChannelLocation('204','int32',val);
        %         end
        %
        %         function set.wavetableActive(obj,val)
        %             % 1 - software trigger to start the wavetable output
        %             %     if wavetable output is also 1.
        %             % 0 - stop wavetable output.
        %             % NOTE: This value can be set to 1 or 0 by TTL I/O triggers.
        %             obj.zprpWriteChannelLocation('208','int32',val);
        %         end
        
    end  


    % *********************************************************************
    % ** Hidden methods:
    % **    Dealing with direct IO with nPoint controller.
    % *********************************************************************
    
    methods (Hidden)

        function val = zprpReadChannelLocation(obj,hexOffset,dataType)         
            hexAddress = hex2dec(hexOffset) + obj.CHAN_BASE_ADDRESS + (obj.currentChannel * obj.CHAN_OFFSET);
            val = obj.zprpReadLocation(dec2hex(hexAddress), dataType);
        end

        
        function val = zprpReadLocation(obj,hexLocation,dataType)

            %Flush input buffer
            ba = obj.hSerial.BytesAvailable;
            if ba > 0
               fread(obj.hSerial,ba);
            end
            
            %Send read command
            fwrite(obj.hSerial,hex2dec('a0'));
            fwrite(obj.hSerial,hex2dec(hexLocation),dataType);
            fwrite(obj.hSerial,hex2dec('55'));

            %Parse reply
            resp = fread(obj.hSerial,1); %acknowledge byte
            assert(strcmpi(dec2hex(resp),'A0'));
            
            resp = fread(obj.hSerial,1,'uint32'); %address echo
            assert(strcmpi(dec2hex(resp),hexLocation));

            val = fread(obj.hSerial,1,dataType); %data payload
            
            resp = fread(obj.hSerial,1); %terminator
            assert(strcmpi(dec2hex(resp),'55'));
        end

        function zprpWriteChannelLocation(obj,hexOffset,dataType,data)
            hexAddress = hex2dec(hexOffset) + obj.CHAN_BASE_ADDRESS + (obj.currentChannel * obj.CHAN_OFFSET);
            obj.zprpWriteLocation(dec2hex(hexAddress), dataType, data);
        end
            

        function zprpWriteLocation(obj,hexLocation,dataType,data)
            %Send write command
            fwrite(obj.hSerial,hex2dec('a2'));
            fwrite(obj.hSerial,hex2dec(hexLocation),dataType);
            fwrite(obj.hSerial,data,dataType);
            fwrite(obj.hSerial,hex2dec('55'));            
        end
        
    end
                
        
        

end