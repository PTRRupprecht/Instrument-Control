classdef LinearStageController < hgsetget
    %LINEARSTAGECONTROLLER Stage Controller Abstract Interface
    %
    % LinearStageController is an abstract class representing a stage
    % controller device. Its interface includes:
    %   * Properties for stage position and velocity
    %   * Methods for nonblocking and blocking stage moves
    %   * "Soft" zeroing of position coordiantes using software-maintained
    %   origin
    %
    %% ******************************************************************
                
    %% DEVELOPMENT NOTES
    %
    %   LSC responsiblities
    %   * Standardization of common stage device props and move methods
    %   * Mapping coordinates to/from the device
    %   * Unit conversion from arbitrary device to arbitrary user unit
    %   system
    %   * Maintenance of relative origin, zeroing operations
    %   * Implementation of nonblocking move with callback on finish
    %   (completedDetectionStrategy = 'poll')
    %   * (Overrideable) Default implementation of blocking move via polling

    %% ABSTRACT PROPERTIES 
    properties (Abstract,Constant,Hidden)
        nonblockingMoveCompletedDetectionStrategy; % Either 'callback' or 'poll'. If 'callback', this class guarantees that moveDone() will be called when a nonblocking move is complete. See documentation for moveStartHook().
    end
    
    % The Abstract properties below can be implemented by subclasses in several
    % ways. These include:
    %   * Constant values (effectively), defined in subclass property block
    %   * Dependent property, with get/set methods defined in subclass
    %   * Constructor-initialized value, optional or mandatory, in subclass ctor
    
    properties (Abstract,SetAccess=protected)
        isMoving; %Logical scalar. If true, the stage is currently moving.
        infoHardware; %String providing hardware information, e.g. firmware version, manufacture date, etc. 
    end

    properties (Abstract,SetAccess=protected,Hidden)
        positionAbsoluteRaw; % Absolute stage position, in positionDeviceUnits. Numeric array of size [1 numDeviceDimensions].
        velocityRaw; % Stage velocity, in velocityDeviceUnits. Either a scalar or an array of size [1 numDeviceDimensions].
        accelerationRaw; %Stage acceleration, in accelerationDeviceUnits. Either a scalar or an array of size [1 numDeviceDimensions].

        invertCoordinatesRaw; %Logical array of size [1 numDeviceDimensions]. If invertCoordinatesRaw(i)==true, position values in ith device dimension are inverted.
        maxVelocityRaw; %Maximum stage velocity in velocityDeviceUnits. Either a scalar or array of size [1 numDeviceDimensions].
        
        %The 'resolution' property indicates the fraction of
        %positionAbsoluteRaw values to consider valid to use in
        %setting/interpreting position values. For most devices, it will be
        %read-only; for some devices, it may be a settable property
        %indicating the user-required resolution.
        %
        %TIP: A value of 1 indicates that resolution matches the positionDeviceUnits
        resolutionRaw; %Current stage resolution, in positionDeviceUnits. Either a scalar or array of size [1 numDeviceDimensions].
        
        positionDeviceUnits; %Units, in meters, in which the device's position values (as reported by positionAbsoluteRaw) are given. Either a scalar, or an array of size [1 numDeviceDimensions].
        velocityDeviceUnits; %Units, in meters/sec, in which the device's velocity values (as reported by velocityRaw) are given. Either a scalar, or an array of size [1 numDeviceDimensions]. If scalar, may be nan, indicating dimensionless units.
        accelerationDeviceUnits; %Units, in meters/sec^2, in which the device's acceleration values (as reported by accelerationRaw) are given. Either a scalar, or an array of size [1 numDeviceDimensions]. If scalar, may be nan, indicating dimensionless units.
    end   
                   
    %% VISIBLE PROPERTIES
    
    properties (SetAccess=private,Dependent)
        positionAbsolute; %1-by-numDimensions array specifying absolute stage position, in units of positionUnits. NaNs are returned for dimensions not controlled by the device.
        positionRelative; %1-by-numDimensions array specifying position of stage relative to 'soft' origin (relativeOrigin) maintained by this class, in units of positionUnits. Unless/until zeroSoft() is used, this value equals positionAbsolute. NaNs are returned for dimensions not controlled by the device.
        
        resolutionBest; %Scalar or 1-by-numDimensions array specifying best stage resolution, in positionUnits.
    end    

    properties (Dependent)
        velocity; %Stage velocity, in velocityUnits. Either a scalar, or an array of size [1 numDimensions].
        acceleration; % Stage acceleration, in accelerationUnits. Either a scalar, or an array of size [1 numDimensions].
        invertCoordinates; %1-by-numDimensions numeric array indicating inversion of position coordinates. NaNs are returned for dimensions not controlled by the device.
        maxVelocity; %Maximum stage velocity, in velocityUnits. Either a scalar, or an array of size [1 numDimensions].
        resolution; %Current stage resolution, in positionUnits. Either a scalar or an array of size [1 numDimensions].
    end

    properties (SetAccess=private)
        relativeOrigin = zeros(1,dabs.interfaces.LinearStageController.numDimensions); %Software-maintained 'soft' origin, in absolute coordinates and units of positionUnits.
    end
    
    properties
        moveTimeout = inf; %Number of seconds to allow for blocking move operations.
    end
    
    %% HIDDEN PROPERTIES            

    %Constructor-initialized    
    properties (Hidden,SetAccess=private)
        numDeviceDimensions = dabs.interfaces.LinearStageController.numDimensions; %Size of array returned by positionAbsoluteRaw. Number of physical dimensions controlled by device.
    end          
        
    properties (Hidden, SetAccess=private)              
        zeroSoftFlag = false(1,dabs.interfaces.LinearStageController.numDimensions); %Flag indicating if a successful zeroSoft() operation has been applied since the object was constructed.
        lastTargetPosition; %Last targetPosition, in absolute coordinates, used for either a blocking or nonblocking move operation
        
        % nonblocking move state
        nonblockingMoveInProgress = false; % scalar logical
        hMoveCompletedTimer = []; % polling timer for move completion
        moveCompleteCbkFcn = []; % function to call after move complete
    end
    
    properties (Hidden, SetAccess=private, Dependent)
        activeDimensions; % 1-by-numDimensions array of logicals. If activeDimensions(i) is true, then there exists a device coordinate that maps to ith external coordinate.
        activeDeviceDimensions; % 1-by-numDeviceDimensions array of logicals. If activeDeviceDimensions(i) is true, then the ith device coordinate maps to an external coordinate.
        dimensionMap; % Index array of size [num-active-device-dim 2]. If dimMap(i,:) = [m n], then device coordinate m maps to external coordinate n.
        
        resolutionBestRaw; % Best achievable resolution of device, in positionUnits. Either a scalar or array of size [1 numDeviceDimensions].
    end
        
    properties (Hidden)
        lsc2DeviceDims; %Index array of size [1 numDeviceDimensions] specifying the mapping of device dimensions to the external coordinate system (that specified by numDimensions and dimensionNames). lsc2DeviceDims(i) is the index of the external dimension corresponding to ith device dimension. Nan values are allowed and indicate an inactive device dimension (dimension that is not mapped to an external dimesnsion). 
        zeroHardWarning = true; %Logical flag. If true, warning should be given prior to executing zeroHard() operations.

        positionUnits = 1e-6; %Scalar specifying, in meters, the physical units in which position is reported by this class
        velocityUnits = 1e-6; %Scalar specifying, in meters/s, the physical units in which velocity is reported by this class
        accelerationUnits = 1e-6; %Scalar specifying, in meters/s^2, the physical units in which acceleration is reported by this class
    end                 

    properties (Hidden,Constant)
        % For now these properties are Constant but conceptually they need not be.
        numDimensions = 3; % Size of array returned by positionAbsolute, positionRelative, velocity, etc.
        dimensionNames = {'X' 'Y' 'Z'};
    end
       
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = LinearStageController(varargin)
            % obj = LinearStageController(p1,v1,p2,v2,...)
            %
            % P-V options (see comments for corresponding properties):
            % numDeviceDimensions: (REQUIRED) Number of physical dimensions controlled by device (eg 1, 2, or 3)
            
            args = most.util.filterPVArgs(varargin,{'numDeviceDimensions'},{'numDeviceDimensions'});
            if ~isempty(args)
                obj.set(args(1:2:end),args(2:2:end));
            end
            
            % default val
            obj.lsc2DeviceDims = 1:obj.numDeviceDimensions;
            
            % Since LinearStageController will always be a base class, for
            % convenience we do not warn for unrecognized P-V args.
                                    
            switch obj.nonblockingMoveCompletedDetectionStrategy
                case 'callback' 
                    % none
                case 'poll'
                    obj.hMoveCompletedTimer = timer('TimerFcn',@obj.zzcbkNonblockingTimer,...
                        'StartDelay',0.2,'Period',0.2,'ExecutionMode','fixedRate','Name','moveCompletePoll');
                otherwise
                    assert(false,'Invalid value of ''nonblockingMoveCompletedDetectionStrategy''.');
            end
        end
        
        function delete(obj)
            if ~isempty(obj.hMoveCompletedTimer)
                delete(obj.hMoveCompletedTimer);
                obj.hMoveCompletedTimer = [];
            end       
        end
                            
    end
    
    %% PROPERTY ACCESS        
    methods
                
        function set.numDeviceDimensions(obj,val)
            validateattributes(val,{'numeric'},{'integer' 'positive'});
            obj.numDeviceDimensions = val;
        end
        
        function set.lsc2DeviceDims(obj,val)
            validateattributes(val,{'numeric'},{'vector' 'size' [1 obj.numDeviceDimensions]}); %#ok<MCSUP>
            arrayfun(@(x)assert(isnan(x) || round(x)==x && x > 0 && x<=obj.numDimensions),val);
            assert(~all(isnan(val)));
            assert(numel(unique(val))==numel(val));
            obj.lsc2DeviceDims = val;
            
            % Reset relativeOrigin, zeroSoftFlag, lastTargetPosition
            % In practice lsc2DeviceDims will not be changed on the fly.
            obj.relativeOrigin = zeros(1,obj.numDimensions); %#ok<MCSUP>
            obj.zeroSoftFlag = false(1,obj.numDimensions); %#ok<MCSUP>
            obj.lastTargetPosition = []; %#ok<MCSUP>
        end
        
        function set.positionUnits(obj,val)
            validateattributes(val,{'numeric'},{'scalar' 'real'});
            val = obj.zprvCheckAndWarnForNanDeviceUnits(val,'position'); % positionDeviceUnits should never be nan.
            
            % dependent properties
            currentUnits = obj.positionUnits;
            ucFactor = currentUnits/val;
            obj.relativeOrigin = obj.relativeOrigin*ucFactor; %#ok<MCSUP>
            obj.lastTargetPosition = obj.lastTargetPosition*ucFactor; %#ok<MCSUP>
            
            obj.positionUnits = val;
        end
        
        function val = get.positionUnits(obj)
            if isscalar(obj.positionDeviceUnits) && isnan(obj.positionDeviceUnits)
                % Currently this should never happen
                obj.positionUnits = nan;
            end
            val = obj.positionUnits;            
        end
        
        function set.velocityUnits(obj,val)
            validateattributes(val,{'numeric'},{'scalar' 'real'});
            val = obj.zprvCheckAndWarnForNanDeviceUnits(val,'velocity');
            obj.velocityUnits = val;            
        end
        
        function val = get.velocityUnits(obj)
            if isscalar(obj.velocityDeviceUnits) && isnan(obj.velocityDeviceUnits)
                obj.velocityUnits = nan;
            end
            val = obj.velocityUnits;
        end
        
        function set.accelerationUnits(obj,val)
            validateattributes(val,{'numeric'},{'scalar' 'real'});
            val = obj.zprvCheckAndWarnForNanDeviceUnits(val,'acceleration');
            obj.accelerationUnits = val; 
        end
        
        function val = get.accelerationUnits(obj)
            if isscalar(obj.accelerationDeviceUnits) && isnan(obj.accelerationDeviceUnits)
                obj.accelerationUnits = nan;
            end
            val = obj.accelerationUnits;
        end            
                
        function val = get.positionRelative(obj)
            val = obj.positionAbsolute - obj.relativeOrigin;
        end
        
        function val = get.positionAbsolute(obj)
            val = obj.zprvDevice2ExternalDimSys(obj.positionAbsoluteRaw,false,'position');
        end
        
        function val = get.velocity(obj)
            val = obj.zprvDevice2ExternalDimSys(obj.velocityRaw,true,'velocity');
        end
        
        function set.velocity(obj,val)
            deviceVal = obj.zprvExternal2DeviceDimSys(val,true,'velocity');
            deviceVal = obj.zprvFillInInactiveDeviceDimsIfNecessary(deviceVal,'velocityRaw');
            obj.velocityRaw = deviceVal;
        end

        function val = get.acceleration(obj)
            val = obj.zprvDevice2ExternalDimSys(obj.accelerationRaw,true,'acceleration');
        end
        
        function set.acceleration(obj,val)
            deviceVal = obj.zprvExternal2DeviceDimSys(val,true,'acceleration');
            deviceVal = obj.zprvFillInInactiveDeviceDimsIfNecessary(deviceVal,'accelerationRaw');
            obj.accelerationRaw = deviceVal;
        end
        
        function val = get.invertCoordinates(obj)
            val = obj.zprvDevice2ExternalDimSys(double(obj.invertCoordinatesRaw));
        end
        
        % If there are any inactive dimensions:
        % * If val is logical, its value along those dimensions is disregarded.
        % * If val is numeric, its value must be nan long those dimensions.
        function set.invertCoordinates(obj,val)
            assert( isvector(val) && numel(val)==obj.numDimensions,...
                'Expected a vector with %d elements.',obj.numDimensions);
            assert(islogical(val) || isnumeric(val),'Value must be logical or numeric.');
                    
            if islogical(val)
                val = double(val); % work in numeric for the moment
            elseif isnumeric(val)
                assert(all(isnan(val(~obj.activeDimensions))),'Cannot invert along inactive dimensions.');
            end
            
            % convert to device coord system
            devVal = nan(1,obj.numDeviceDimensions);
            dimMap = obj.dimensionMap;
            devVal(dimMap(:,1)) = val(dimMap(:,2));
            
            % convert to logical
            if any(~obj.activeDeviceDimensions)
                % in this case, devVal will have nans
                logDevVal = obj.invertCoordinatesRaw; % start with current raw value
                logDevVal(obj.activeDeviceDimensions) = logical(devVal(obj.activeDeviceDimensions));
            else
                logDevVal = logical(devVal);
            end
                        
            obj.invertCoordinatesRaw = logDevVal;
        end
        
        function val = get.maxVelocity(obj)
            val = obj.zprvDevice2ExternalDimSys(obj.maxVelocityRaw,true,'velocity');
        end
        
        function set.maxVelocity(obj,val)
            deviceVal = obj.zprvExternal2DeviceDimSys(val,true,'velocity');
            deviceVal = obj.zprvFillInInactiveDeviceDimsIfNecessary(deviceVal,'maxVelocityRaw');
            obj.maxVelocityRaw = deviceVal;
        end
        
        function val = get.resolution(obj)
            val = obj.zprvDevice2ExternalDimSys(obj.resolutionRaw,true,'position');
        end
        
        function set.resolution(obj,val)
            assert(all(val >= obj.resolutionBest),'Cannot set resolution value lower than resolutionBest');
            deviceVal = obj.zprvExternal2DeviceDimSys(val,true,'position');
            deviceVal = obj.zprvFillInInactiveDeviceDimsIfNecessary(deviceVal,'resolutionRaw');
            obj.resolutionRaw = deviceVal;
        end            
        
        function val = get.resolutionBest(obj)
            val = obj.zprvDevice2ExternalDimSys(obj.getResolutionBestHook(),true,'position');
        end
        
        function val = get.activeDimensions(obj)
            val = false(1,obj.numDimensions);
            val(obj.dimensionMap(:,2)) = true;
        end
        
        function val = get.activeDeviceDimensions(obj)
            val = false(1,obj.numDeviceDimensions);
            val(obj.dimensionMap(:,1)) = true;
        end
        
        function val = get.dimensionMap(obj)
            activeDeviceDims = find(~isnan(obj.lsc2DeviceDims));
            externalDims = obj.lsc2DeviceDims(activeDeviceDims);
            val = [activeDeviceDims(:) externalDims(:)];
        end

        function val = get.resolutionBestRaw(obj)
            val = obj.getResolutionBestHook();
        end
        
        function set.moveTimeout(obj,val)
            validateattributes(val,{'numeric'},{'positive' 'scalar' 'real'});
            obj.moveTimeout = val;
        end
        
    end
    
    %% ABSTRACT METHODS    
    
    % This method must be implemented in a concrete subclass.
    methods (Abstract,Access=protected,Hidden)
        
        % Start a nonblocking move and return immediately. absTargetPosn is
        % in the device coordinate system, eg it is directly comparable to
        % positionAbsoluteRaw.
        %
        % Requirements/Expectations:
        % 1. During a move initiated by moveStartHook, the .isMoving
        % property of the object in question must faithfully represent the
        % state of its stage. That is, .isMoving must be true while the
        % move is in progress, and it must become false once the move is
        % complete. Some devices may allow querying the device for this
        % during the move, while others may not.
        % 2. If possible, LinearStageController.moveDone should
        % be called when the nonblocking move is complete. This is
        % optional, but recommended if possible. 
        %
        % If a concrete LinearStageController class can only meet the first
        % requirement, then set its nonblockingMoveCompletedDetectionStrategy
        % to 'poll'. In this case, LinearStageController or its clients may
        % poll the .isMoving property to determine when a nonblocking move
        % is complete. If a concrete LinearStageController class can meet
        % the second (optional) requirement in addition to the first, then
        % set its nonblockingMoveCompletedDetectionStrategy to 'callback'.
        moveStartHook(obj,absTargetPosn);
    end
    
    % These methods have default implementations. Implementation in
    % concrete subclasses is not required, but encouraged where applicable.
    methods (Access=protected,Hidden)

        % Blocking move. Can throw. absTargetPosn is in the device
        % coordinate system, ie it is directly comparable to
        % positionAbsoluteRaw.
        %
        % Requirements:
        % 1. This should error if .moveTimeout is exceeded without the move
        % completing successfully. In this case, the move should be
        % interrupted/stopped if possible.
        %
        % This default implementation starts a nonblocking move and polls
        % the .isMoving property.
        function moveCompleteHook(obj,absTargetPosn)
            
            TIGHT_LOOP_PAUSE_INTERVAL = 0.01;
            tstart = tic;
            
            % we set this flag because, in the case that
            % nonblockingMoveCompletedDetectionStrategy=='callback',
            % moveDone() will be called if/when the nonblocking move
            % completes. moveDone currently asserts that
            % nonblockingMoveInProgress is true, which is plausible thing
            % to do, so we placate it.
            obj.nonblockingMoveInProgress = true;
            try
                obj.moveStartHook(absTargetPosn); % throws (hardware)
            catch ME
                obj.nonblockingMoveInProgress = false;
                ME.rethrow();
            end
            
            % nonblocking move successfully started; poll .isMoving
            while 1
                if ~obj.isMoving 
                    % move successful
                    obj.nonblockingMoveInProgress = false;
                    break;
                elseif toc(tstart) > obj.moveTimeout
                    warnst = warning('off','backtrace');
                    warning('LinearStageController:moveCompleteHook:timeout',...
                        'Blocking move timed out. Attempting to interupt...');
                    warning(warnst);
                    
                    % We call interruptMoveHook() before setting
                    % nonblockingMoveInProgress back to false; see
                    % moveCancel() for the precedent. The theory is that if
                    % the interrupt harderrors, the move may still be
                    % pending.
                    try 
                        obj.interruptMoveHook();
                    catch ME
                        error('LinearStageController:moveCompleteHook:timeout',...
                            'Blocking move timed out (interrupt NOT successful).');
                    end
                                            
                    obj.nonblockingMoveInProgress = false;
                    error('LinearStageController:moveCompleteHook:timeout',...
                        'Blocking move timed out (interrupt successful).');
                end
                pause(TIGHT_LOOP_PAUSE_INTERVAL);
            end                        
        end

        % Interrupt a move. After return, the stage should be ready to
        % accept new commands.
        function interruptMoveHook(obj)
            error([mfilename ':InterruptNotSupported'],'Device of class %s does not support ''interruptMove()'' operation.',class(obj));
        end
        
        % Attempt to recover from an error condition. This is similar in
        % intention but less "severe" than resetHook().
        function recoverHook(obj)
            error([mfilename ':RecoverNotSupported'],'Device of class %s does not support ''recover()'' operation.',class(obj));
        end

        % "Hard reset" of device. 
        function resetHook(obj)
            error([mfilename ':ResetNotSupported'],'Device of class %s does not support ''reset()'' operation.',class(obj));
        end
        
        % Zero position coordinate system on device. coords is a logical
        % vector indicating which dimensions to zero. coords has the same
        % number of elements as positionAbsoluteRaw and is with respect to
        % the same physical dimensions.
        %
        % Zero-ing should have the effect of shifting the values returned
        % by positionAbsoluteRaw. The software origin (relativeOrigin)
        % maintained by LinearStageController will be unaffected.
        function zeroHardHook(obj,coords) %#ok<INUSD>
            error([mfilename ':ZeroHardNotSupported'],'Device of class %s does not support ''zeroHard()'' operation.',class(obj));
        end
        
        %Return value of best (finest) resolution supported by device, in
        %positionDeviceUnits, as a scalar or array of [1 numDeviceDimensions]
        function val = getResolutionBestHook(obj)
            val = ones(size(obj.positionDeviceUnits));
        end

    end
    
    %% PUBLIC METHODS
    methods
        
        function zeroHard(obj,coords)
            %Set current position as absolute origin (maintained by device
            %hardware). coords is a 1-by-numDimensions logical vec. If
            %coords is omitted, ture is assumed for all dimensions.
            %
            %This call also resets the "soft" position origin maintained by
            %this class.
            
            if nargin < 2 || isempty(coords)
                % default: zero along all active dimensions
                coords = false(1,obj.numDimensions);
                coords(obj.activeDimensions) = true;
            else
                coords = logical(coords);
                assert(isvector(coords) && length(coords)==obj.numDimensions,...
                    '''coords'' must be a logical vector of length %d',obj.numDimensions);
            end

            assert(~any(coords & ~obj.activeDimensions),'Cannot explicitly zero along inactive dimension.');
           
            obj.zprvErrIfPendingNonblockingMove();
            
            %Warn user about zeroHard() operation, if needed
            if obj.zeroHardWarning
                resp = questdlg('Executing zeroHard() operation will reset stage controller''s absolute origin. Proceed?','WARNING!','Yes','No','No');
                if strcmpi(resp,'No')
                    return;
                end
            end
            
            % Transform to device coordinate sys. Counterintuitively, for
            % inactive device dimensions, we default to true, ie zeroing.
            % The reason is that some devices are "all or none" in terms of
            % zeroing, ie they cannot zero only certain coordinates. For
            % such a device, defaulting to false for inactive device
            % dimensions will be totally broken, ie zero-ing will be
            % completely impossible.
            %
            % We hope that zeroing hard along an inactive device dimension
            % will be harmless in the vast majority if not all cases. Seems
            % like it would be...
            deviceCoords = true(1,obj.numDeviceDimensions);
            dimMap = obj.dimensionMap;
            deviceCoords(dimMap(:,1)) = coords(dimMap(:,2));
            
            obj.zeroHardHook(deviceCoords); % throws (hardware)
            obj.zeroHardWarning = false; %Do not warn multiple times
            
            % reset software-maintained origin (this is like calling
            % zeroSoft)
            currPosn = obj.positionAbsolute; % throws (hardware)
            obj.relativeOrigin(coords) = currPosn(coords);
            obj.zeroSoftFlag = obj.zeroSoftFlag | coords;
        end
        
        function zeroSoft(obj,coords)
            %Set software-maintained origin (maintained by this class) to
            %the current position. coords is a 1-by-numDimensions
            %logical vec indicating which dimensions to zero. If omitted,
            %all dimensions are assumed.

            if nargin < 2 || isempty(coords)
                % default: zero along all active dimensions
                coords = false(1,obj.numDimensions);
                coords(obj.activeDimensions) = true;
            else
                coords = logical(coords);
                assert(isvector(coords) && length(coords)==obj.numDimensions,...
                    '''coords'' must be a logical vector of length %d',obj.numDimensions);
            end
            
            assert(~any(coords & ~obj.activeDimensions),'Cannot zero along inactive dimensions.');

            obj.zprvErrIfPendingNonblockingMove();            
            
            currPosn = obj.positionAbsolute; % throws (hardware)
            obj.relativeOrigin(coords) = currPosn(coords);
            obj.zeroSoftFlag = obj.zeroSoftFlag | coords;
        end
        
        function absPosn = relativeToAbsoluteCoords(obj,relPosn)
            % relPosn: 1-by-numDimensions relative position
            absPosn = relPosn + obj.relativeOrigin; 
        end
        
        function relPosn = absoluteToRelativeCoords(obj,absPosn)
            % absPosn: 1-by-numDimensions absolute position
            relPosn = absPosn - obj.relativeOrigin;
        end
        
        % Blocking move. absTargetPos is a 1-by-numDimensions absolute
        % position.
        % * error on timeout (.moveTimeout)
        % * use nan in an element of absTargetPos to indicate "don't move
        % in that dimension"
        function moveCompleteAbsolute(obj,absTargetPos)
            obj.zprvErrIfPendingNonblockingMove();
            obj.lastTargetPosition = absTargetPos;
            deviceAbsTargetPos = obj.zprvTargetPosPrep(absTargetPos); % throws (hardware)
            obj.moveCompleteHook(deviceAbsTargetPos); % throws (hardware)
        end
        
        % Blocking move. relPos = a 1-by-numDimensions relative
        % position.
        function moveCompleteRelative(obj,relPos)
            assert(all(isnan(relPos(~obj.activeDimensions))),'Cannot move along inactive dimension.');
            obj.moveCompleteAbsolute(obj.relativeToAbsoluteCoords(relPos));
        end
        
        % Start a nonblocking move. absTargetPos is a 1-by-numDimensions
        % absolute position.
        % * call cbkFcn when done. (set cbkFcn to [] for no callback).
        % * at moment, no timeout.
        function moveStartAbsolute(obj,absTargetPos,cbkFcn)
            if nargin < 3
                cbkFcn = [];
            end
            assert(isequal(cbkFcn,[]) || isa(cbkFcn,'function_handle'));
            obj.zprvErrIfPendingNonblockingMove();
            obj.lastTargetPosition = absTargetPos;
            deviceAbsTargetPos = obj.zprvTargetPosPrep(absTargetPos); % throws (hardware)
            obj.moveCompleteCbkFcn = cbkFcn;
            
            try
                obj.nonblockingMoveInProgress = true; %Must set before starting timer -- in case it gets called

                switch obj.nonblockingMoveCompletedDetectionStrategy
                    case 'poll'
                        assert(strcmp(obj.hMoveCompletedTimer.running,'off'));
                        start(obj.hMoveCompletedTimer);
                        obj.moveStartHook(deviceAbsTargetPos); % throws (hardware)
                    case 'callback'
                        obj.moveStartHook(deviceAbsTargetPos); % throws (hardware)
                end
            catch ME
                obj.zprvResetNonblockingMoveState();
                ME.rethrow();
            end
            
        end
        
        % Start a nonblocking move. relTargetPos is a 1-by-numDimensions
        % relative position.
        function moveStartRelative(obj,relTargetPos,cbkFcn)
            if nargin < 3
                cbkFcn = [];
            end
            assert(all(isnan(relTargetPos(~obj.activeDimensions))),'Cannot move along inactive dimension.');
            obj.moveStartAbsolute(obj.relativeToAbsoluteCoords(relTargetPos),cbkFcn);            
        end
                
        % interrupt/cancel move started by preceding moveStart* call.
        % If this is called without a preceding moveStart* call, or if the
        % preceding moveStart* call has finished, the result is
        % indeterminate.
        function moveCancel(obj)
            % assert(obj.nonblockingMoveInProgress,'No move is pending.');
            obj.interruptMoveHook(); % throws (hardware)
            obj.zprvResetNonblockingMoveState();
        end
                
        function recover(obj)
            %Recover from error condition. This should represent an
            %operation less drastic than reset() that will often allow
            %device to return to good state (or verify that it has done so
            %on its own) following error.
            
            obj.recoverHook(); % throws (hardware)
            obj.zprvResetNonblockingMoveState();
        end
        
        function reset(obj)
            %Reset device. For some devices, this will automatically cause
            %a zeroHard() action to occur.
            
            obj.resetHook(); % throws (hardware)
            obj.zprvResetNonblockingMoveState();
        end
        
    end


    %% HIDDEN METHODS - Methods for subclasses

    methods (Access=protected)
        
        %Method used to signal move completion. Typically called on move
        %completion by subclasses employing
        %nonblockingMoveCompletedDetectionStrategy = 'callback'.
        function moveDone(obj,~,~)
            assert(obj.nonblockingMoveInProgress,'There is no move in progress.');
            fcn = obj.moveCompleteCbkFcn;
            obj.zprvResetNonblockingMoveState();
            
            if ~isempty(fcn)
                feval(fcn);
            end
        end
        
    end
    
    %% PRIVATE METHODS
    
    %Class-Device Dimension/Unit Conversion
    methods (Access=private)
        
        function val = zprvCheckAndWarnForNanDeviceUnits(obj,val,qty)
            assert(ismember(qty,{'position';'velocity';'acceleration'}));
            deviceUnits = obj.(sprintf('%sDeviceUnits',qty));
            if isscalar(deviceUnits) && isnan(deviceUnits) && ~isnan(val)
                warning('LinearStageController:nanDeviceUnits',...
                    'Device reports dimensionless values for %s quantities.',qty);
                val = nan;
            end
        end

        % Take a quantity from device-space to the external space:
        % * (optionally) convert units
        % * remap coordinates
        %
        % xDevice: vector with numDeviceDimensions elements.
        % xExternal: numeric vector with numDimensions elements.
        % tfCanBeScalar (optional): scalar logical. If true, a scalar value
        % of xDevice is not remapped to external dimensions (provided
        % numDeviceDimensions is not equal to 1). Defaults to false.
        % quantity (optional): One of {'position' 'velocity'
        % 'acceleration'}. If present, do unit conversion.
        %
        % Note: xExternal will be nan along any inactive external
        % dimensions.
        function xExternal = zprvDevice2ExternalDimSys(obj,xDevice,tfCanBeScalar,quantity)
            if nargin < 3 || isempty(tfCanBeScalar)
                tfCanBeScalar = false;
            end
            assert(isvector(xDevice) && numel(xDevice)==obj.numDeviceDimensions || ...
                tfCanBeScalar && isscalar(xDevice) );
            
            tfScalarSpecialSituation = isscalar(xDevice) && obj.numDeviceDimensions > 1;

            % Unit conversion
            if nargin == 4
                xDevice = obj.zprvUCHelper(xDevice,quantity,tfScalarSpecialSituation,true);             
            end
            
            % Transform coordinate system
            if tfScalarSpecialSituation
                % No coordinate transformation
                xExternal = xDevice;
            else
                xExternal = nan(1,obj.numDimensions);
                dimMap = obj.dimensionMap;                
                xExternal(dimMap(:,2)) = xDevice(dimMap(:,1));
            end
        end

        % Take a quantity from external-space to device-space.
        % * Assert that the quantity is nan along inactive dimensions.
        % * remap coordinates. 
        % * (optionally) convert units
        %
        % Note: xDevice will be nan along any inactive device dimensions.
        %
        % See zprvDevice2ExternalDimSys.
        function xDevice = zprvExternal2DeviceDimSys(obj,xExternal,tfCanBeScalar,quantity)
            if nargin < 3 || isempty(tfCanBeScalar)
                tfCanBeScalar = false;
            end
            assert(isvector(xExternal) && numel(xExternal)==obj.numDimensions || ...
                tfCanBeScalar && isscalar(xExternal));
            
            tfScalarSpecialSituation = isscalar(xExternal) && obj.numDimensions > 1;
            
            if tfScalarSpecialSituation
                % Special case: don't remap to device dimensions, don't
                % check for nans along inactive dimensions
                xDevice = xExternal;
            else
                assert(all(isnan(xExternal(~obj.activeDimensions))),...
                    'Quantity must be nan along inactive dimensions.');
                
                dimMap = obj.dimensionMap;
                xDevice = nan(1,obj.numDeviceDimensions);
                xDevice(dimMap(:,1)) = xExternal(dimMap(:,2));
            end
            
            if nargin == 4
               xDevice = obj.zprvUCHelper(xDevice,quantity,tfScalarSpecialSituation,false);
            end
        end
        
        % tfDev2Ext: if true, input is in device units, output is in external units. if false, vice versa.
        function x = zprvUCHelper(obj,x,quantity,tfScalarSpecialSitu,tfDev2Ext)
            
            devUnitFld = sprintf('%sDeviceUnits',quantity);
            devUnits = obj.(devUnitFld);
            tfDoUnitConvert = ~(isscalar(devUnits) && isnan(devUnits));
            
            if tfDoUnitConvert
                unitFld = sprintf('%sUnits',quantity);
                units = obj.(unitFld);
                if tfScalarSpecialSitu
                    % In this case, the interpretation is that xIn/xOut
                    % applies to all device dimensions. For now we do the
                    % safest/easiest thing, which is to assert that
                    % devUnits is a scalar.
                    assert(isscalar(devUnits));
                end
                
                % cases covered:
                % * (scalar xDevice) + (scalar devUnits) + scalar units
                % * (vector xDevice) + (scalar devUnits) + scalar units
                % * (vector xDevice) + (vector devUnits) + scalar units
                
                if tfDev2Ext
                    x = x.*devUnits/units;                    
                else % Ext2Dev
                    x = x*units./devUnits;
                end
            end
        end
        
        % deviceVal: either a scalar, or [1 numDeviceDimensions] array. If
        % deviceVal is an array, it must have nans along inactive device
        % coordinates.
        % rawDeviceProp: name of "raw" device prop corresponding to
        % deviceVal.
        %
        % In the case where i) deviceVal is an array, and ii) there are
        % inactive device dims, this method fills deviceVal along inactive
        % dimensions by getting the current raw prop value.
        %
        % The raison detre for this method is to handle the situation when
        % there are inactive device dimensions, and a value coming from the
        % external world is to be set on the (raw) device property. In this
        % case, after zprvExternal2DeviceDimSys transforms the incoming
        % value into the device coord system, it will have nans along the
        % inactive device dimensions. The concrete LSC writer will probably
        % not have written his/her setters to accept nans, and he/she has
        % no control over how lsc2DeviceDims has been set.
        %
        % NOTE: this method assumes that the "special scalar situation" is
        % allowed, ie deviceVal is allowed to be a scalar even if 
        % obj.numDeviceDimensions > 1.
        function deviceVal = zprvFillInInactiveDeviceDimsIfNecessary(obj,deviceVal,rawDeviceProp)
            tfSpecialScalarSituation = isscalar(deviceVal) && obj.numDeviceDimensions > 1;
            if tfSpecialScalarSituation
                % no-op in this case.
                return;
            end
            
            inactiveDevDims = ~obj.activeDeviceDimensions;
            if any(inactiveDevDims)
                % fill in with current device values.                
                assert(all(isnan(deviceVal(inactiveDevDims))));
                currentDevVal = obj.(rawDeviceProp);
                deviceVal(inactiveDevDims) = currentDevVal(inactiveDevDims);
            end            
        end
        
        function zprvResetNonblockingMoveState(obj)
            obj.moveCompleteCbkFcn = [];
            if ~isempty(obj.hMoveCompletedTimer)
                stop(obj.hMoveCompletedTimer);
            end
            obj.nonblockingMoveInProgress = false;    
        end
        
        function zprvErrIfPendingNonblockingMove(obj)
            if obj.nonblockingMoveInProgress
                error('Dabs:LinearStageController',...
                    'A move is pending. Unable to proceed with current command.');
            end
        end
    
        % throws (hardware)
        function deviceAbsTargetPosn = zprvTargetPosPrep(obj,absTargetPos)
            assert(isequal(size(absTargetPos),[1 obj.numDimensions]));
            assert(all(isnan(absTargetPos(~obj.activeDimensions))),...
                'A move was specified in dimension designated as inactive. NaN must be specified for inactive dimensions. ');
            
            deviceAbsTargetPosn = obj.zprvExternal2DeviceDimSys(absTargetPos,false,'position');
            
            %Nans in deviceAbsTargetPosn can occur from i) inactive device
            %dims or ii) explicitly-user-specified nans.
            tfNoMove = isnan(deviceAbsTargetPosn); 
            if any(tfNoMove)
                currentPos = obj.positionAbsoluteRaw;
                assert(isequal(size(currentPos),size(deviceAbsTargetPosn)));
                deviceAbsTargetPosn(tfNoMove) = currentPos(tfNoMove);
            end
        end
                
        function zzcbkNonblockingTimer(obj,~,~)
            assert(obj.nonblockingMoveInProgress,'There is no move in progress.');
            if ~obj.isMoving
                obj.moveDone();
            end
        end
                
    end
    
    
end
