classdef Chameleon < handle
    %CHAMELEON Class encapsulating Coherent Chameleon laser serial command interface
        
    
    %% VISIBLE PROPERTIES
    
    properties (Dependent)
        shutterOpen; %Logical. If true, laser shutter is open.
        commandWavelength;  %Last commanded laser wavelength, in nanometers
        alignmentMode; %Logical. If true, laser placed in alignment mode.                
    end
    
    %Read-only
    properties (Dependent,SetAccess=protected)
        emissionState; %One of {'standby' 'on' 'error'}
        keyPosition; %Logical indicating, if true, that laser keyswitch is on
        modelockingState; %One of {'standby' 'modelocked' 'cw'}
        tuningState; %One of {'ready' 'tuning' 'modelocking' 'recovering'}        
        status; %String indicating operating status, e.g. 'Starting', 'OK'. Same as on front panel.                
        power; %Laser power in milliwatts
        
        serialNumber; %Serial number of laser        
        versionNums; %Version number of power supply sofwware                       
    end
    
    
    %% HIDDEN PROPERTIES 
    properties (Hidden)
        hRS232; %Handle to dabs.interfaces.RS232DeviceBasic object
        
        prop2CmdMap = zlclProp2CmdMap();
    end
    
      
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        function obj = Chameleon(varargin)
            %Property-value arguments:
            % comPort: Integer specifying serial COM port to which Chameleon is connected
                                    
            obj.hRS232 = dabs.interfaces.RS232DeviceBasic(varargin{:},'defaultTerminator','CR/LF','baudRate',19200);                                                          
            
            obj.hRS232.sendCommandSimpleReply('ECHO=0');
        end                       
        
        function delete(obj)
            
            %Delete associated objects (they don't auto-delete for some reason)
            delete(obj.hRS232);
        end
           
            
    end
    
    %% PROPERTY ACCESS
    methods
        function val = get.alignmentMode(obj)            
            val = logical(obj.zprpSendQueryNumeric('alignmentMode'));                        
        end
        
        function set.alignmentMode(obj,val)
            obj.zprpSendCommandNumeric('alignmentMode',val);
        end
                
        function val = get.commandWavelength(obj)
            val = obj.zprpSendQueryNumeric('commandWavelength');
        end
        
        function set.commandWavelength(obj,val)
            obj.zprpSendCommandNumeric('commandWavelength',val);
        end
        
        function val = get.emissionState(obj)
            resp = obj.zprpSendQueryNumeric('emissionState');
            
            switch resp
                case 0
                    val = 'off (standby)';
                case 1
                    val = 'on';
                case 2
                    val = 'off (fault)';

                otherwise
                    assert(false);
            end
        end
        
        function val = get.keyPosition(obj)
            val = logical(obj.zprpSendQueryNumeric('keyPosition'));
        end
        
        function val = get.modelockingState(obj)
            resp = obj.zprpSendQueryNumeric('modelockingState');
            
            switch resp
                case 0
                    val = 'off (standby)';                    
                case 1
                    val = 'modelocked';                   
                case 2
                    val = 'cw';
            end
                   
        end
        
        function val = get.power(obj)
            val = obj.zprpSendQueryNumeric('power');
        end
        
        function val = get.versionNums(obj)
            val = obj.zprpSendQuery('powerSupplyVersionNum');
        end
        
        function val = get.serialNumber(obj)
            val = obj.zprpSendQueryNumeric('SendQueryNumeric');
        end
        
        function val = get.shutterOpen(obj)
            val = logical(obj.zprpSendQueryNumeric('shutterOpen'));
        end
        
        function set.shutterOpen(obj,val)
            obj.zprpSendCommandNumeric('shutterOpen', val);
        end
        
        function val = get.status(obj)
            val = obj.zprpSendQuery('status');
        end
        
        function val = get.tuningState(obj)
            resp = obj.zprpSendQueryNumeric('tuningState');
            
            switch resp
                case 0
                    val = 'ready';
                case 1
                    val = 'tuning';
                case 2
                    val = 'modelocking';
                case 3
                    val = 'recovering';
                otherwise
                    assert(false);
            end
        end
        
    end
    
    methods (Access=protected)               

        function zprpSendCommandNumeric(obj,propName,commandVal)
           obj.zprpSendCommand(propName,num2str(commandVal));
        end
        
        function resp = zprpSendQueryNumeric(obj,propName)
            resp = str2double(obj.zprpSendQuery(propName));  
        end   
        
        function zprpSendCommand(obj,propName,commandString)
            obj.hRS232.sendCommandSimpleReply([obj.prop2CmdMap(propName) '=' commandString]);
        end        
        
        function resp = zprpSendQuery(obj,propName)
            resp = obj.hRS232.sendCommandReceiveStringReply(['?' obj.prop2CmdMap(propName)]);            
        end 
        
    end
       
    
    
    
end

%% LOCAL FUNCTIONS

function hMap = zlclProp2CmdMap()

hMap = containers.Map();

hMap('shutterOpen') = 'S'; %'SHUTTER'
hMap('commandWavelength') = 'VW'; %'WAVELENGTH'
hMap('alignmentMode') = 'ALIGN';
hMap('emissionState') = 'L'; %'LASER'
hMap('keyPosition') = 'K'; %'KEYSWITCH'
hMap('modelockingState') = 'MDLK'; %'MODELOCKED'
hMap('tuningState') = 'TS'; %'TUNING STATUS'
hMap('serialNumber') = 'SN';
hMap('status') = 'ST';
hMap('power') = 'UF'; %'UF POWER'
hMap('versionNums') = 'SV'; %'SOFTWARE'
               

end

