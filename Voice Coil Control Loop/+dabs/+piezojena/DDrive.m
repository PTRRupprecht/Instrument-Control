classdef DDrive < handle
    %DDRIVE A class encapsulating the d-Drive piezo controller/amplifier system(s) from Piezosystems Jena
    
    properties
        setVerify=true; %Logical value specifying, if true, that the value of device properties will be verified following set commands, causing an error if the actual value does not match that set.
    end
    
    properties (SetAccess = protected)
        comPort; %Specifies COM port to which controller/amplifier is connector
    end
    
    properties (Dependent)
        timeout=2; %Time, in seconds, to allow for serial port send/receive commands before flagging an error condition
    end        
    
    properties (SetAccess=protected,GetObservable) %Read-only device properties
        status; %Status, a 16-bit integer value representing contents of status register
        measuredPosn; %Measured position, in microns
        amplifierTemp; %Amplifier temperature value, in degrees Celsius
        actuatorOpTime; %Operation time of actuator since shipping, in minutes
    end
    
    properties (SetObservable, GetObservable) %Device properties (settable/gettable)
        setPosn; %Commanded position, specified in volts (open-loop) or microns (closed-loop)
        slewRate; %Slew rate, in V/ms
        modulationInputActive; %Logical value, indicating if modulation input to servo controller is enabled
        monitorOutputSrc; %Source of monitor output signal. 0: Position in closed loop, 1: command value, 2: command output voltage, 3: closed loop deviation, 4: absolute closed loop deviation, 5: actuator voltage, 6: position in open loop
        
        closedLoopActive; %Logical value, indicating if closed loop servo control is enabled
        
        servoPCoef; %PID servo proportional coefficient, from 0-1000
        servoICoef; %PID servo integral coefficient, from 0-1000
        servoDCoef; %PID servo differential coefficient, from 0-1000
        
        notchFilterActive; %Logical value, indicating if notch filter is enabled
        notchFilterFreq; %Notch filter frequency, in Hz (0-20000)
        notchFilterBandwidth; %Notch filter bandwidth (-3dB), in Hz (0-20000, up to 2x notch frequcency)
        lowpassFilterActive; %Logical value, indicating if low-pass filter is enabled
        lowpassFilterFreq; %Low-pass filter cut frequency, in Hz (1-20000)
    end
    
    %% PRIVATE/HIDDEN PROPERTIES
    
    properties (Hidden, SetAccess=protected)
        hCom; %Handle to serial port object
    end
    
    properties (Hidden, Dependent)
        propCmdMap; %Map of commands associated with each property
    end
    
    properties (Access=private)
        setPropDirect=false; %Lock var used to allow getting current object property directly, without calling through to DAQmx
        getPropDirect=false; %Lock var used to allow setting current object property directly, without calling through to DAQmx       
    end
    
    properties (Constant)
       type = 'DDrive'; 
    end
            
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = DDrive(comPort,varargin)
            %function obj = DDrive(comPort,varargin)
            %   comPort: An integer value specifying COM port to which controller/amplifier is connected
            %   varargin: Argument pairs specifying property/value -- e.g. 'timeout',5 -- to set following construction of object.
            
            try
                %Parse required input arguments
                numReqArgs = 1;
                for i=1:numReqArgs
                    if nargin < i
                        error(['Argument ''' inputName(1) ''' must be specified']);
                    end
                end               
                                
                %Construct serial port object
                disp(['Opening ' obj.type '...']);
                obj.hCom = serial(['COM' num2str(comPort)], 'BaudRate', 115200, 'Timeout', 2, 'FlowControl','software','Terminator',{17,13});
                obj.comPort = comPort;
                
                %Open the serial port object
                fopen(obj.hCom);
                
                %Bind listeners to observable properties
                mc = metaclass(obj);
                props = mc.Properties;
                getObservableProps = {};
                setObservableProps = {};
                for i=1:length(props)
                    if props{i}.GetObservable
                        getObservableProps{end+1} = props{i}.Name; %#ok<AGROW>
                    end
                    if props{i}.SetObservable
                        setObservableProps{end+1} = props{i}.Name; %#ok<AGROW>
                    end
                end
                addlistener(obj,getObservableProps,'PreGet',@obj.getDriverProperty);
                addlistener(obj,setObservableProps,'PostSet',@obj.setDriverProperty);
                
                %Process optional property/value pairs
                if ~isempty(varargin)
                    if mod(length(varargin),2)
                        error([mfilename ':ArgError'],'Optional arguments must be entered as property/value pairs');
                    else
                        for i=1:2:length(varargin)/2
                           obj.(varargin{2*i-1}) = varargin{2*i};                            
                        end
                    end
                end
            catch ME
                delete(obj);
                rethrow(ME);
            end                           
        end
        
        function delete(obj)
            %Close/delete the serial port object
            try %#ok<TRYNC>
                fclose(obj.hCom);
                delete(obj.hCom);
            end
        end
    end
    
    %% PROPERTY ACCESS
    
    methods (Access=protected)
        function val = getDriverProperty(obj,src,evnt)
            
            if ~obj.getPropDirect
                
                exceptions = {'closedLoopActive' 'setPosn'}; %These are properties that don't conform to the PiezoJena convention, i.e. a firmware or documentation error
                exception = ismember(src.Name,exceptions);
                
                if ~exception
                    %Determine command(code) name for specified property
                    propCmdName = obj.propCmdMap(src.Name);
                    
                    %Send get command
                    fprintf(obj.hCom, propCmdName);
                    
                    %Receive reply
                    [valString,count,msg] = fgetl(obj.hCom);
                    if ~isempty(msg)
                        error([mfilename ':COMReadError'],['COM port error: ' msg]);
                    end
                    
                    %Strip out XOFF at start, and CR/LF at end
                    msgError = false;
                    if valString < 3
                        msgError = true;
                    else
                        valString = valString(2:end-2);
                        if isempty(valString)
                            msgError = true;
                        end
                    end
                    if msgError
                        error([mfilename ':MessageError'], ['Message received from device (' valString ') does not conform to expected standard']);
                    end
                    
                    %Confirm that reply echoes request sent
                    [propNameStr,valString] = strtok(valString,',');
                    if ~strcmpi(propNameStr,propCmdName)
                        error([mfilename ':ReplyMismatch'], 'Reply from device did not match property value set');
                    end
                    
                    %Return value as a number
                    valString = valString(2:end); %Removes comma
                    val = str2double(valString);
                    
                    %Set underlying property
                    obj.setPropDirect = true;
                    obj.(src.Name) = val;
                    obj.setPropDirect = false;
                end
                
            end
        end
        
        function setDriverProperty(obj,src,evnt)
            %(Post-set listener) Send set command over COM port
            
            if ~obj.setPropDirect
                %Get property that was (provisionally) set, to determine value to send over COM port
                obj.getPropDirect=true;
                val = obj.(src.Name);
                obj.getPropDirect=false;
                
                %Send set command over COM port
                try
                    fprintf(obj.hCom, [obj.propCmdMap(src.Name) ',' num2str(val)]);
                catch ME
                    syncProp(src.Name);
                    rethrow(ME);
                end
                
                %Verify command was recieved
                [reply,replyCount] = fgetl(obj.hCom);
                if replyCount ~= 2
                    error([mfilename ':COMSetFailure'], ['Did not receive expected reply from ' obj.type ' device upon setting property']);
                end
                
                %Force underlying property to match

                                
                %Check if value matches that set, if specified
                %TODO: See what reply one obtains following send command -- this may not be required                
                if obj.setVerify     
                    cleanSet = syncProp(src.Name,val);
                    if ~cleanSet                        
                        obj.getPropDirect = true;
                        actVal = obj.(src.Name);
                        obj.getPropDirect = false;
                        
                        warning(['Value actually set (' num2str(actVal) ') does not match value specified (' num2str(val) ')']);
                    end
                end
            end
            
            function tf = syncProp(propName,val)
                %Forces synchronization of property to underlying driver variable; returns true if property was already syncrhronized, false if synchronization was required
                
                %Is value synchronized already?
                actVal = obj.(propName);                
                tf = (nargin == 2) && (actVal == val);
                
                %Force synhronization
                if ~tf
                    obj.setPropDirect=true;
                    obj.(propName) = actVal;
                    obj.setPropDirect=false;
                end
            end
            
        end
    end
    
    methods
        function propCmdMap = get.propCmdMap(obj) %#ok<MANU>
            persistent localMap
            if isempty(localMap)
                mapData = { ...
                    'stat'       'status';
                    'mess'       'measuredPosn';
                    'ktemp'      'amplifierTemp';
                    'rohm'       'actuatorOpTime';
                    'set'        'setPosn';
                    'sr'         'slewRate';
                    'modon'      'modulationInputActive';
                    'monsrc'     'monitorOutputSrc'
                    'cl'         'closedLoopActive';
                    'kp'         'servoPCoef';
                    'ki'         'servoICoef';
                    'kd'         'servoDCoef';
                    'notchon'    'notchFilterActive';
                    'notchf'     'notchFilterFreq';
                    'notchb'     'notchFilterBandwidth';
                    'lpon'       'lowpassFilterActive';
                    'lpf'        'lowpassFilterFreq';};
                
                localMap = containers.Map(mapData(:,2),mapData(:,1));
            end
            propCmdMap = localMap;
        end
        
        %TMW: Some scheme to facilitate drill-down get/set of objects 'associated' with a given class
        function val = get.timeout(obj)
            val = obj.hCom.timeout;
        end
        
        function set.timeout(obj,val)
            obj.hCom.timeout = val;
        end
        
    end
    
    
    
    
end

