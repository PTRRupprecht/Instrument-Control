classdef LinearStageController < dabs.interfaces.LSCSerial
    %LinearStageController Class encapsulating Scientfica linear stage
    %controller, and associated linear stages, which run under their LinLab
    %software (and its corresponding serial command set)
       
    %TODO: Run through to handle cases where < 3 dimensions are used.
    
    %% ABSTRACT PROPERTY REALIZATIONS (Devices.Interfaces.LinearStageController)
    properties (Constant,Hidden)
        nonblockingMoveCompletedDetectionStrategy = 'poll';
    end
    
    properties (SetAccess=protected,Dependent)
        isMoving;
        infoHardware;
    end

    properties (SetAccess=protected,Dependent,Hidden)
        positionAbsoluteRaw;
        velocityRaw;
        accelerationRaw;
        invertCoordinatesRaw;
        resolutionRaw;
    end
    
    properties (SetAccess=protected,Hidden)
        maxVelocityRaw;
    end
    
    properties (SetAccess=protected,Hidden)
        positionDeviceUnits = 1e-7;
        velocityDeviceUnits = nan;
        accelerationDeviceUnits = nan;
    end
   
    %% ABSTRACT PROPERTY REALIZATIONS (Devices.Interfaces.LSCSerial)
    properties (Constant)
        availableBaudRates = 9600;
        defaultBaudRate = 9600;
    end
        
    %% CLASS-SPECIFIC PROPERTIES    
    properties (SetAccess=protected)
        stageType; %Specifies type of stage assembly connected to stage controller, e.g. 'patchstar' or 'mmtp'. Names match that specified in LinLab software.
    end
    
    properties (Dependent)               
        current; %2 element array - [stationaryCurrent movingCurrent], specified as values 1-255. Not typically adjusted from default.
        velocityStart; %Scalar or 3 element array indicating/specifying start velocity to use during moves.
    end
    
    properties (Dependent,Hidden)
        positionUnitsScaleFactor; %These are the UUX/Y/Z properties. %TODO: Determine if there is any reason these should be user-settable to be anything other than their default values (save for inverting). At moment, none can be determined. Perhaps related to steps.
        limitReached;
    end
        
    properties (Hidden)
        defaultCurrent; %Varies based on stage type
        defaultPositionUnitsScaleFactor; %Varies based on stage type. This effectively specifies the resolution of that stage type.
    end   
    
    properties (Hidden, Constant)
        defaultVelocityStart = 5000; %Default value for /all/ stage types
        defaultAcceleration = 500; %Default value for /all/ stage types       
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = LinearStageController(varargin)
            % obj = LinearStageController(p1,v1,p2,v2,...)
            %
            % P-V options:
            % stageType: (REQUIRED) See comment in corresponding property.
            % comPort: (REQUIRED) Integer specifying COM port of serial device
            %
            % See doc for dabs.interfaces.LSCSerial/LSCSerial for
            % other optional P-V arguments.

            lscSerialArgs = {'defaultTerminator','CR','deviceErrorResp','E',...
                             'deviceSimpleResp','A'};
            lscArgs = {'numDeviceDimensions' 3};
            obj = obj@dabs.interfaces.LSCSerial(lscSerialArgs{:},lscArgs{:},varargin{:});
            
            % get stageType
            stageTypePV = most.util.filterPVArgs(varargin,{'stageType'},{'stageType'});
            sType = stageTypePV{2};  
            obj.stageType = sType;
            
            %Initialize to default values 
            obj.ziniInitializeDefaultValues();           
        end

    end
    
    methods (Hidden)
        function ziniInitializeDefaultValues(obj)            
            stageTypeMap = obj.stageTypeMap();
            assert(ischar(obj.stageType) && stageTypeMap.isKey(obj.stageType),'Unrecognized stageType supplied (%s)',obj.stageType);
            stageInfo = stageTypeMap(obj.stageType);
            
            % set stage-dependent props
            obj.maxVelocityRaw = stageInfo.maxVelocityStore;
            obj.defaultCurrent = stageInfo.defaultCurrent;
            obj.defaultPositionUnitsScaleFactor = stageInfo.defaultPositionUnitsScaleFactor;
            
            % Initialize properties
            obj.velocityRaw = obj.maxVelocityRaw;
            obj.accelerationRaw = obj.defaultAcceleration;
            obj.current = obj.defaultCurrent;
            obj.velocityStart = obj.defaultVelocityStart;
            obj.positionUnitsScaleFactor = obj.defaultPositionUnitsScaleFactor;            
            
        end
        
    end
    
    %% PROPERTY ACCESS METHODS 
    methods
        
        function tf = get.isMoving(obj)
            resp = obj.hRS232.sendCommandReceiveStringReply('S');
            tf = obj.processNumericReply(resp) > 0;
        end
        
        function val = get.infoHardware(obj)
            val = deblank(obj.hRS232.sendCommandReceiveStringReply('DATE'));
        end
        
        function val = get.positionAbsoluteRaw(obj)
            val = str2num(obj.hRS232.sendCommandReceiveStringReply('POS')); %#ok<ST2NM>
        end
        
        function val = get.velocityRaw(obj)
            resp = obj.hRS232.sendCommandReceiveStringReply('TOP');
            val = obj.processNumericReply(resp);
        end
        
        function set.velocityRaw(obj,val)
            obj.hRS232.sendCommandSimpleReply(['TOP ' num2str(val)]);
            actVal = obj.velocityRaw;
            if val ~= actVal
                fprintf(2,'WARNING: Actual value differs from set value\n');
            end
        end
        
        function val = get.accelerationRaw(obj)
            resp = obj.hRS232.sendCommandReceiveStringReply('ACC');
            val = obj.processNumericReply(resp);
        end
        
        function set.accelerationRaw(obj,val)
            obj.hRS232.sendCommandSimpleReply(['ACC ' num2str(val)]);
            actVal = obj.accelerationRaw;
            if actVal ~= val
                fprintf(2,'WARNING: Actual value differs from set value\n');
            end
        end
        
        function val = get.invertCoordinatesRaw(obj)
            numDims = obj.numDimensions; % numDeviceDimensions==numDimensions
            resp = zeros(1,numDims);
            for i = 1:numDims
                tmp = obj.hRS232.sendCommandReceiveStringReply(['UU' obj.dimensionNames{i}]);
                resp(i) = obj.processNumericReply(tmp,true);
            end
            val = (resp ./ obj.defaultPositionUnitsScaleFactor) < 0; % inverted-ness is relative to defaultPositionUnitsScaleFactor
        end
        
        % throws (hware). If this happens, the state of invertCoordinates
        % is indeterminate.
        function set.invertCoordinatesRaw(obj,val)
            assert(islogical(val) && (isscalar(val) || numel(val)==obj.numDimensions));
            if isscalar(val)
                val = repmat(val,1,obj.numDimensions); % numDeviceDimensions==numDimensions
            end
            
            % inverted-ness is relative to defaultPositionUnitsScaleFactor
            sgnDefaultPosUnitsSF = sign(obj.defaultPositionUnitsScaleFactor);
            dirMultiplier = (-1).^(double(val)) .* sgnDefaultPosUnitsSF;

            posUnitsSF = obj.positionUnitsScaleFactor;
            assert(isequal(numel(dirMultiplier),numel(posUnitsSF),obj.numDimensions));
            obj.positionUnitsScaleFactor = dirMultiplier.*abs(posUnitsSF);
        end                
        
		function val = get.resolutionRaw(obj)
			val = obj.resolutionBestRaw;
		end	
		
        % throws (hware)
        function val = get.current(obj)
            resp = obj.hRS232.sendCommandReceiveStringReply('CURRENT');
            val = obj.processNumericReply(resp);
        end
        
        % throws (hware)
        function set.current(obj,val)
            obj.hRS232.sendCommandSimpleReply(['CURRENT ' num2str(val)]);
        end

        % throws (hware) 
        function val = get.velocityStart(obj)
            resp = obj.hRS232.sendCommandReceiveStringReply('FIRST');
			val = obj.processNumericReply(resp);
        end
        
        % throws (hware)
        function set.velocityStart(obj,val)
            obj.hRS232.sendCommandSimpleReply(['FIRST ' num2str(val)]);            
            actVal = obj.velocityStart;
            if actVal ~= val
                fprintf(2,'WARNING: Actual value differs from set value\n');
            end
        end

        % throws (hware)
        function val = get.positionUnitsScaleFactor(obj)
            val = zeros(1,obj.numDimensions); % numDimensions==numDeviceDimensions
            for i = 1:obj.numDimensions 
                resp = obj.hRS232.sendCommandReceiveStringReply(['UU' obj.dimensionNames{i}]);
                val(i) = obj.processNumericReply(resp);
            end
        end
        
        % throws (hware). If this happens, the state of the UU (User Units)
        % vars is indeterminate.
        function set.positionUnitsScaleFactor(obj,val)
            assert(isnumeric(val) && (isscalar(val) || numel(val)==obj.numDimensions)); % numDimensions==numDeviceDimensions
            if isscalar(val)
                val = repmat(val,1,obj.numDimensions);
            end
            for i = 1:obj.numDimensions
                obj.hRS232.sendCommandSimpleReply(['UU' obj.dimensionNames{i} ' ' num2str(val(i))]);
            end
        end
        
        function val = get.limitReached(obj)
            %TODO(5AM): Improve decoding of 6 bit (2 byte) data            
            resp = obj.hRS232.sendCommandReceiveStringReply('LIMITS');
            val = zeros(1,obj.numDimensions);
            resp = uint8(hex2dec(deblank(resp)));
            for i = 1:obj.numDimensions
                val(i) =  obj.activeDimensions(i) && (bitget(resp,2*i-1) || bitget(resp,2*i));
            end
        end
        
    end   
    
    %% ABSTRACT METHOD IMPLEMENTATIONS
    methods (Access=protected,Hidden)

        function moveStartHook(obj,absTargetPosn)
            obj.hRS232.sendCommandSimpleReply(['ABS ' num2str(round(absTargetPosn))]); %Should get an 'A' reply immediately upon starting move
        end

        function interruptMoveHook(obj)
            try
                % TODO: This does not seem to work with 2.13 firmware...
                % AL: I don't see this command in my doc
                obj.hRS232.sendCommandSimpleReply('INTERRUPT'); 
            catch ME
                if strfind(ME.identifier,'DeviceErrorReply')
                   obj.DException('','InterruptMoveNotSupported','Device of class %s does not support ''interruptMove()'' operation.',class(obj)); 
                end
                ME.rethrow();
            end
        end
        
        function resetHook(obj)
            %Warn user about reset() operation, if needed
            resp = questdlg('Executing reset() operation will reset the stage controller''s absolute origin and restore default values for speed and current. Proceed?','WARNING!','Yes','No','No');
            if strcmpi(resp,'No')
                return;
            end
            drawnow(); %Address questdlg() bug (service request 1-F1PZKQ)
            
            obj.hRS232.sendCommandReceiveStringReply('RESET');

            %Restore default values of this class (and specifically for
            %stage type specified on construction)
            obj.ziniInitializeDefaultValues();           
        end  
        
        function recoverHook(obj)
           try
               drawnow(); %For good measure
               obj.hRS232.flushInputBuffer();
               obj.hRS232.sendCommandReceiveStringReply('POS'); 
           catch ME              
               error('Unable to recover motor operation');
           end
        end
        
        function zeroHardHook(obj,coords)
            if ~all(coords)
                error('Scientifica:LinearStageController:zeroHardHook',...
                    'It is not possible to perform zeroHard() operation on individual dimensions for device of class %s',class(obj));
            end
            obj.hRS232.sendCommandSimpleReply('ZERO');
        end        
        
        function val = getResolutionBestHook(obj)
            val = 1 ./ abs(obj.defaultPositionUnitsScaleFactor); 
        end
                
    end
    
    
    %% PRIVATE/PROTECTED METHODS
    methods (Access=protected, Static)
        
        function replyArray = processNumericReply(deviceReply,isFloat)
            if nargin < 2 || isempty(isFloat)
                isFloat = false;
            end
            if isFloat
                replyArray = sscanf(deviceReply,'%f'); %TODO: Switch to textscan?
            else
                replyArray = sscanf(deviceReply,'%d'); %TODO: Switch to textscan?
            end
        end      

    end    
    
    %% STATIC METHODS
    methods (Static)
        
        % keys: stageTypes. vals: stage info/props
        function m = stageTypeMap()
            
            m = containers.Map();
            
            m('ums') = struct( ...
                'maxVelocityStore', 40000, ... % maxVelocity, in units of positionDeviceUnits
                'defaultCurrent', [200 100], ... 
                'defaultPositionUnitsScaleFactor', -5.12);
            
            m('ums_2') = struct( ...
                'maxVelocityStore', 40000, ...
                'defaultCurrent', [250 125], ...
                'defaultPositionUnitsScaleFactor', [-4.032 -4.032 -5.12]);
            
            m('mmtp') = struct( ...
                'maxVelocityStore', 40000, ...
                'defaultCurrent', [200 100], ...
                'defaultPositionUnitsScaleFactor', -5.12);
            
            m('slicemaster') = struct( ...
                'maxVelocityStore', 40000, ...
                'defaultCurrent', [200 100], ...
                'defaultPositionUnitsScaleFactor', -5.12);
            
            m('patchstar') = struct( ...
                'maxVelocityStore', 30000, ...
                'defaultCurrent', [230 125], ...
                'defaultPositionUnitsScaleFactor', -6.4);
            
            m('patchstar_2') = struct( ...
                'maxVelocityStore', 30000, ...
                'defaultCurrent', [250 125], ...
                'defaultPositionUnitsScaleFactor', -6.4);
            
            m('mmsp') = struct( ...
                'maxVelocityStore', 30000, ...
                'defaultCurrent', [175 125], ...
                'defaultPositionUnitsScaleFactor', -5.12);
            
            m('mmsp_z') = struct( ...
                'maxVelocityStore', 30000, ...
                'defaultCurrent', [175 125], ...
                'defaultPositionUnitsScaleFactor', -5.12);
            
            m('mmbp') = struct( ...
                'maxVelocityStore', 20000, ...
                'defaultCurrent', [200 125], ...
                'defaultPositionUnitsScaleFactor', [-4.032 -4.032 -6.4]);
            
            m('imtp') = struct( ...
                'maxVelocityStore', 40000, ...
                'defaultCurrent', [175 125], ...
                'defaultPositionUnitsScaleFactor', -5.12);
            
            m('slice_scope') = struct( ...
                'maxVelocityStore', 20000, ...
                'defaultCurrent', [200 125], ...
                'defaultPositionUnitsScaleFactor', [-4.032 -4.032 -6.4]);
            
            m('condenser') = struct( ...
                'maxVelocityStore', 20000, ...
                'defaultCurrent', [200 125], ...
                'defaultPositionUnitsScaleFactor', [-4.032 -4.032 -6.4]);
            
            m('ivm_manipulator') = struct( ...
                'maxVelocityStore', 30000, ...
                'defaultCurrent', [255 125], ...
                'defaultPositionUnitsScaleFactor', -5.12);
        end
        
    end
    
end
