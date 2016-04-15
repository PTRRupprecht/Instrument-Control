classdef LSCSerial < dabs.interfaces.LinearStageController

    %% ABSTRACT PROPERTIES
    properties (Abstract,Constant)
        availableBaudRates;
        defaultBaudRate;
    end
    
    %% HIDDEN PROPERTIES   
    properties (Hidden)
        % This property is a scalar handle to an object of class
        % dabs.interfaces.RS232DeviceBasic. This object is used for
        % serial-port communication with the physical device. Subclasses of
        % LSCSerial may configure the properties of hRS232 directly as
        % appropriate for their device (see the documentation for
        % RS232DeviceBasic for more information). Alternatively, hRS232 may
        % be configured via P-V arguments to the LSCSerial constructor.
        hRS232; 
    end
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = LSCSerial(varargin)
            % obj = LSCSerial(p1,v1,p2,v2,...)
            %
            % P-V options:
            % comPort: (REQUIRED) Integer specifying COM port of serial device
            % baudRate: (OPTIONAL) Integer etc.
            %
            % See constructor documentation for
            % dabs.interfaces.RS232DeviceBasic and
            % dabs.interfaces.LinearStageController for other P-V arguments.

            % The LinearStageController ignores unrecognized PVs
            obj = obj@dabs.interfaces.LinearStageController(varargin{:});
            
            % validation for baudRate
            ip = most.util.InputParser;
            ip.addRequiredParam('comport',@(x)isscalar(x) && isnumeric(x));
            ip.addOptional('baudrate',obj.defaultBaudRate,@(x)ismember(x,obj.availableBaudRates));
            ip.parse(varargin{:});
            
            comportAndBaudRatePV = most.util.structPV2cellPV(ip.Results);

            % for now, hardcode P-V args accepted by RS232. best way to
            % handle this unclear
            rs232OptionalArgs = {'skipTerminatorOnSend';'deviceErrorResp';...
                'deviceSimpleResp';'defaultTerminator';'defaultTimeout'};
            remainderPV = ip.Unmatched;
            remainderPV = most.util.restrictField(remainderPV,rs232OptionalArgs);
            remainderPV = most.util.structPV2cellPV(remainderPV);
                        
            obj.hRS232 = dabs.interfaces.RS232DeviceBasic(comportAndBaudRatePV{:},remainderPV{:});
        end
        
        function delete(obj)
            if ~isempty(obj.hRS232)
                delete(obj.hRS232);
                obj.hRS232 = [];
            end
        end
        
    end    
    
end
