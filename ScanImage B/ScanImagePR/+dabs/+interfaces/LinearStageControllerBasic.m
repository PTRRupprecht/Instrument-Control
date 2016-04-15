classdef LinearStageControllerBasic < most.DClass & most.PDEPProp
    %LINEARSTAGECONTROLLERBASIC Abstract superclass representing general basic linear stage controller device, controlling one or more linear stage assemblies, each containing up to 3 linear stages (one per physical dimension)
    %
    %% NOTES
    %   This class has evolved to become quite specific to Scanimage requirements, and should likely be moved into the ScanImage package
    %
    %   3 types of move operations are supported (i.e. implemented by all subclasses): moveCompleteRelative(), moveStartRelative(), and moveStartCompleteEvent()
    %   Some devices may have different move 'modes', which is specified by the moveMode property.
    %   Some devices may have different resolution 'modes', specified by resolutionMode property.
    %   A 'two-step' move option is allowed for so that moves are carried out in two steps, with a velocity/moveMode/resolutionMode triad set for each step
    %
    %   'Custom' stage capability was added, in a per-dimension manner, but this is not actually used/supported at this time. -- Vijay Iyer 3/16/10
    %
    %   This class nominally supports multiple stage assemblies, but this has not been used/vetted -- some issues remain. For instance, currently there is no provision for stageType per stage assembly. -- Vijay Iyer 3/28/10
    %
    %   Positions returned by this class are always supplied/returned as 3-vectors, even when the number of available and/or specified active dimensions are < 3. 
    %   Values for the unavailable/inactive dimensions are returned as NaN and can be supplied with any arbitrary value
    %   When supplying a value (e.g. move commands), to affect only a subset of the available/active dimensions, then NaN should be supplied for any available/active dimensions to leave unaffected
    %
    %   Subclasses must handle 3-vector position specification requirement in the moveStartHook() abstract method implementation
    %   For position read operations, the superclass handles coercion to 3 vector format
    %
    %   High Priority
    %   TODO: Handle relativeOrigin reset/recompute following zeroHard() operation
    %   
    %   Others
    %   TODO: Handle automatic setPositionVerify for async reply in manner that deals with error appropriately (since it occurs in a callback)
    %   TODO: Perhaps make moveCompletedTimer period a public property
    %   TODO: Consider using genericErrorHandler() scheme akin to RS232DeviceBasic, that resets all flag variables following error.
    %   TODO: Consider whether cleanupAsyncMove code should be moved outside of moveStartHidden() nested function, so that it can be shared with handleErrorCondReset() 
    %
    %% CHANGES
    %   VI040510A: Added handleErrorCondReset(), which basically does an asyncMoveCleanup operation, since async move cruft often remains from previous errors -- Vijay Iyer 4/5/10
    %
    %% CREDITS
    %   Created originally February 2010, by Vijay Iyer
    %% ******************************************************************
    
    %% ABSTRACT PROPERTIES
        
    %Abstract properties MUST be realized in subclasses, generally by copy/pasting these property blocks (sans 'Abstract', with subclass-specific constant/initial values as needed, and possibly with Hidden attribute added/removed), into each concrete subclass.
    %TMW: For case where subclasses are defining subclass-specific constant or intial values, this is reasonable. But documentation inheritance would be nice.
    properties (Abstract, SetAccess=protected, Hidden)
        devicePositionUnits; %Units, in meters, in which the device's position values (as reported by its hardware interface) are given
        deviceVelocityUnits; %Units, in meters/sec, in which the device's velocity values (as reported by its hardware interface) are given. Value of NaN implies arbitrary units.
        deviceAccelerationUnits; %Units, in meters/sec^2, in which the device's acceleration values (as reported by its hardware interface) are given. Value of NaN implies arbitrary units.
        deviceErrorResp;
        deviceSimpleResp;
        
        stageTypeMap; %Map containing property intializations for each of the stage types supported by subclass controller
        resolutionModeMap; %Map containing resolution multipliers for each of the named resolutionModes
    end
    
    properties (Abstract, Constant, Hidden)  %TMW: Combination of 'Abstract' and 'Constant' in superclass works (as it well should), but documentation would suggest otherwise.
        hardwareInterface; %One of {'serial' 'usb' 'tcpip' 'other'}. Indicates type of hardware interface used to control device. NOTE: Other hardware interface types may be supported in the future.
        safeReset; %Logical indicating, if true, that reset() operation (if any) should be considered safe backup to recover() operation, if former fails or doesn't exist. 'Safe' implies that operation has no side-effects and that motor operation can continue following reset() in same state as existed prior to error condition.
        
        maxNumStageAssemblies; %Maximum nuber of stage assemblies supported by device                
        requiredCustomStageProperties; %Cell array of properties that must be set on construction if one or more of the stages is 'custom'
        
        %Identifies strategy that subclass uses to signal move completed event on moveStartXXX() operations
        %   'hardwareInterfaceEvent': Appropriate underlying hardware interface (e.g. RS232DeviceBasic) 'asyncReplyEvent' event will be used
        %   'moveCompletedTimer': A Matlab timer object maintained by this class will periodically poll the isMoving property to determine if move has completed.
        %   <eventNameString>: The subclass is responsible for generating a move-completed event (given by <eventNameString>)
        moveCompletedDetectionStrategy; % One of {'hardwareInterfaceEvent','moveCompletedTimer',<eventNameString>}
        
        % A subclass may implement a hook method which handles moveCompleteXXX() operations. 
        % Otherwise, the 'isMoving' property will be polled in a tight loop until the move has completed.)
        moveCompleteHookFcn; %Optional string specifying class method to use as hook method for moveCompleteXXX operations
    end

    properties (Abstract, Constant)
        moveModes; %Cell array of possible moveModes for particular subclass device type. If only one type of move is supported, mode is 'default'.
    end
    
    %%%%%%%Following are Abstract only for purpose of allowing subclasses to override the Hidden attribute.    
    properties (Abstract)
        zeroHardWarning; %Logical flag indicating, if true, that warning should be given prior to executing zeroHard() operations
    end         
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
           
    %% ABSTRACT PROPERTY REALIZATION (most.PDEPProp)
    properties (Constant, Hidden)
        pdepSetErrorStrategy = 'restoreCached';
    end       
    
    %% USER PROPERTIES
    
    %PDEP Props
    properties (SetObservable,GetObservable)        
                
        stageAssemblyIndex=1; %Integer specifying index of stage assembly currently addressed by this controller. Cannot exceed maxNumStageAssemblies.
        
        moveMode; %String indicating which of the devices's moveModes is currently in effect. If only one mode is supported, this will always be 'default'
        resolutionMode; %String indicating which of the device's named resolutionModes is currently in effect. If only one mode is supported, this will always be 'default'
        invertCoordinates; %Scalar, or 3 element per-dimension array, logical value(s) specifying, if true, to invert position reported in specified dimension(s)
        
        velocity; %Scalar or 3 element array indicating/specifying velocity. If multiple resolutionModes are available, value pertains to current resolutionMode.
        
        %Following may not be applicable for some subclasses
        velocityStart; %Scalar or 3 element array indicating/specifying start velocity to use during moves. If multiple resolutionModes are available, value pertains to current resolutionMode.
        acceleration; %Scalar or 3 element array indicating/specifying acceleration to use (between velocityStart and velocity) during moves. If multiple resolutionModes are available, value pertains to current resolutionMode.

        %%%FOllowing are read-only -- they will defer to PDEPProp default setter
        %TMW: Would prefer to make this SetAccess=protected, but that precludes access by a named /super/ class -- can there be a version of protected that allows this? Alternatively a 'friend' concept. Take back my comment from the meeting..package scope is not enough.
        
        maxVelocity; %Scalar or 3 element per-dimension array containing maximum value that can be set for velocity, in units specified by velocityUnits (if deviceVelocityUnits~=NaN).
        
        infoHardware; %String providing information about the hardware, e.g. firmware version, manufacture date, etc. Information provided is specific to each device type.
        isMoving; %Logical indicating, if true, that stage is currently moving
        limitReached; %3 element per-dimension array of logical values specifying, if true, that stage in given dimension(s) has reached end-of-travel limit
    end      
      
    properties (SetAccess=private, Dependent)
        positionAbsolute; %3-element per-dimension array specifying absolute position of LSC
        positionRelative; %3-element per-dimension array  specifying position of LSC in relative coordinates, relative to 'soft' origin (relativeOrigin) stored by this class. Unless/until zeroSoft() is used, this value equals positionAbsolute.       
        
        numAvailableDimensions;
    end    
    
    properties (SetAccess=protected)
        relativeOrigin=[0 0 0]; %3-element per-dimension array indicating position, in absolute coordinates, stored by this class that serves as current relative origin. Values of 0 indicate that no relative origin is specified for given coordinate.
    end
    
    properties
        setPositionVerifyAutomatic=false; %Logical value indicating, if true, that position is read automatically at end of moveCompleteRelative() calls and when moveComplete event occurs for moveStartCompleteEvent() calls.
        setPositionVerifyAccuracy=0; %Scalar, or 3 element per-dimension array, containing difference between intended and obtained position in positionUnits above which an error will be thrown. Note if resolutionCurrent value is higher, than that difference will be used as error threshold instead.
        %setPositionVerifyManual=false; %Logical value indicating, if true, that verification of set position should occur manually, by calling the verifySetPosition() method, rather than automatically as part of a set position command
        setPositionVerifyAccuracyPerDimension=true; %Logical value indicating, if true, that setPositionVerifyAccuracy is applied per-dimension, i.e. each dimension must fall within specified accuracy. Otherwise, accuracy pertains to vectorial distance between target and actual position.
        setPositionVerifyOnMoveWait=false; %Logical indicating, if true, that position should be read and matched to set position during moveWaitForFinish() operations

        
        %These represent the behavior implemented now by default in ScanImage. Only applies for moveCompleteRelative() operations at this time.
        twoStepMoveEnable=false; %Logical value indicating, if true, that large moveCompleteRelative() operations are done in two steps, with the second 'slow' step using one or more distinct properties (velocity, resolutionMode, moveMode, setPositionVerifyAutomatic) distinct from first step. 
        twoStepMoveAltMode='slow'; % One of {'slow', 'fast'}: determines if 'twoStepMoveAltVelocity/MoveMode/Resolution' are "fast" or "slow".
        twoStepMoveSlowDistance; %If specified, value gives a distance threshold, in units given by positionUnits, below which moves with twoStepMoveEnable=true will be done in only one step (using the 'slow' step). Moves above that threshold will will be done in two steps.
        twoStepMoveAltVelocity; %Value specifying velocity to use when within range of twoStepMoveSlowDistance.
        twoStepMoveAltResolutionMode=''; %Value specifying resolutionMode to use when with range of twoStepMoveSlowDistance. Must be one of available resolutionModes.
        twoStepMoveAltMoveMode=''; %Value specifying moveMode to use when with range of twoStepMoveSlowDistance. Must be one of available moveModes.
        twoStepMoveInProgress=false; %Logical value indicating, if true, that an event-driven two step move is in progress. %ADDED BY DEQ
        twoStepMoveFinalStep=false;%Logical value indicating, if true, that this is the second step in a two step move. %ADDED BY DEQ
        twoStepMoveTarget=[];%Value specifying the target position for an event-driven two step move. %ADDED BY DEQ
        %DEQ20101209 - removed         twoStepMoveAltSetPositionVerifyAutomatic; %Logical value specifing whether setPositionVerifyAutotomatic should be in force during final step of two step moves.
        
        moveTimeout=inf; %Time, in seconds, to allow for moveCompleteXXX() operations before generating a timeout error
        asyncMoveTimeout=inf; %Time, in seconds, to allow for asynchronous move operations (moveStartXXX() and moveStartCompleteEventXXX() operations) before generating error
        
        %blockOnError=true; %Logical indicating, if true, that pertinent commands should be blocked when an error condition has been detected and not reset. %TODO(5AM): SKIP - Consider actually implementing this. Requires that all pertinent methods, including for property access, be wrapped into m
        autoInterruptAsyncMoveOnError=true; %Logical indicating, if true, that any pending asynchronous moves will be 
        %autoRecover=false; %Logical indicating, if true, that recover() operation should be automatically attemped when error condition has been set
        
        generateMoveCompletedEvent=false; % Logical indicating, if true, that an event should be generated for completed move operations.
    end          
                
    %Properties set by user during construction only
    properties (SetAccess=private)
        activeDimensions = [true true true]; %3 element array of logicals indicating which of the physical dimensions X, Y, and Z - in that order - are controlled by this stage controller instance
        numActiveDimensions = 3; %Number of true elements in activeDimensions
        %numAvailableDimensions; %Number of dimensions actually controlled by this LSC. This is the size of array returned by positionAbsoluteRaw reads.
        stageType; %String specifying stage type used for all of the active dimensions, or 3-element string cell array specifying stage type per-axis (empty strings for any inactive dimensions). Can specify 'custom' for one or more stages, which often requires that some properties be initialized on construction. See 'requiredCustomStageProperties'.
    end    
    
    
    %% SUPERUSER PROPERTIES
    
    %PDEP Props
    properties (SetObservable,GetObservable, Hidden)
        positionAbsoluteRaw; %Array indicating position in absolute coordinates, i.e the coordinates maintained by device firmware.            
    end
        
    properties (SetAccess=protected, Hidden)
        
        hHardwareInterface; %Handle to hardware interface which this device complies to. Type depends on 'hardwareInterface'.
        
        resolutionModes; %Cell array of possible resolutionModes for particular subclass device type
        resolutionCurrent; %Specifies resolution, minimum movement size in each dimension specified in positionUnits, that is in force with current resolutionMode        
       
        zeroSoftFlag=[false false false]; %Flag indicating, for each dimension, if a successful zeroSoft() operation has been applied since object was constructed               
    end
    
    %Following are often/generally set by default values for stages, but can be overridden if specified on construction
    properties (SetAccess=protected, Hidden)
        resolution; %Scalar or 3 element per-dimension array containing smallest size move, in units specified by positionUnits, supported by device in each dimension.
    end
    
    properties (Hidden)
        moveCompletePauseInterval=0.01; %Time in seconds to give to pause() command for tight while loop used in waitForCompletedMove() method. Only applies if moveCompletedStrategy='isMovingPoll'.
        moveWaitForFinishPauseInterval=0.01;  %Time in seconds to give to pause()/pauseTight() command for tight while loop used in moveWaitForFinish() method.
        usePauseTight=true; %Logical indicating, if true, to use pauseTight() command, in lieu of built-in pause() command.
        hMoveCompleteHookFcn; % A function handle to the function specified by 'moveCompleteHookFcn'.
        
        velocityFast; % the actual velocity used for 'fast' moves.
        velocitySlow; % the actual velocity used for 'slow' moves.
        resolutionModeFast;
        resolutionModeSlow;
        moveModeFast;
        moveModeSlow;
    end    
    
        
    %% DEVELOPER PROPERTIES
        
    properties (SetAccess=protected,Hidden)      
        setPositionVerifyPositionStore; %Stored position, in absolute coordinates, that was last specified in a position-set command
               
        asyncMovePending=false; %Flag indicating if an async move is in progress
        asyncMoveTimeReference; %Time reference, obtained via tic(), of start of async move

        twoStepMovePropertyStore; %A containers.Map object used to cache property               
        
        numAvailableDimensionsHidden; 
    end
    
%     properties (SetAccess=private,Hidden)
%         initialized=false;
%     end
    
    properties (Constant, Hidden)
        maxNumDimensions=3; %Maximum number of dimensions per stage assembly
        dimensionNames={'X' 'Y' 'Z'}; %Cell array of elements 'X', 'Y', and 'Z', specified in order in which they appear in other properties
        positionUnits=1e-6; %Value specifying, in meters, the physical units (if available) in which 'resolution' and 'position' properties are specified by this class
        velocityUnits=1e-6; %Value specifying, in meters/sec, the physical units (if available) in which velocity property(s) are specified by this class
        accelerationUnits=1e-6; %Value specifying, in meters/sec^2, the physical units (if available) in which acceleration property(s) are specified by this class
                
        %Properties which can be overridden for second and/or slow step when two-step move is enabled
        %NOTE: Order of this list is order in which properties are set in changing between fast/slow set of properties. This order works for all known subclasses at this time. -- Vijay Iyer 3/20/10        
        twoStepMoveProperties = {'moveMode' 'resolutionMode' 'velocity'};  % DEQ20101209 - removed 'setPositionVerifyAutomatic'
        
    end
    
    
    %% EVENTS
    events (NotifyAccess=protected)
        moveCompletedEvent;
    end
    
   
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = LinearStageControllerBasic(stageType,varargin)
            %import Programming.Utilities.*
            
            if nargin == 0
                return;
            end
            
            %Add listener to superclass-generated event
            addlistener(obj, 'errorCondReset',@obj.handleErrorCondReset);           
            
            %Determine number of active dimensions
            pvargs = obj.filterPropValArgs(varargin,{'activeDimensions'});                        
            if ~isempty(pvargs)
                obj.set(pvargs(1:2:end),pvargs(2:2:end));
            end
            
            %Handle multi-stage-assembly possibility
            if obj.maxNumStageAssemblies > 1
                pvargs = obj.filterPropValArgs(varargin,{'stageAssemblyIndex'});
                if ~isempty(pvargs) %TMW: Annoying this can't be done via abstract superclass or separate function for private/protected properties
                    obj.set(pvargs(1:2:end),pvargs(2:2:end));
                end
            end
            
            %Initialize stage type, handling possibility of custom stages
            %NOTE: The 'custom' stage possibility is largely unused at this time; biggest application is MP-285 and mainly this is handled by initializing the 'resolution' property on construction
            obj.stageType = stageType;
            if ischar(stageType)
                if strcmpi(stageType,'custom') %all active dimensions are custom
                    customDimensions = find(obj.activeDimensions);
                    initializedStageType = [];
                else
                    customDimensions = [];
                    initializedStageType = stageType;
                end
            elseif iscellstr(stageType)
                nonCustomStageTypes = setdiff(stageType,'custom');
                
                %For now -- only allow one type of non-custom stage type. Covers all immediate use cases.
                assert(length(nonCustomStageTypes) <= 1, 'At this time, only one non-custom stage type can be specified for a given linear stage assembly');
                
                [~,customStageIndices] = ismember('custom',stageType);
                customDimensions = intersect(obj.activeDimensions,customStageIndices);
            end
            obj.initializeStageType(initializedStageType); %Initialize the one and only one (for now) non-custom stage type specified
            
            %Handle custom stages - initialize properties that must be specified to override defaults.
            if ~isempty(customDimensions)
                if ~isempty(obj.requiredCustomStageProperties)
                    pvargs = filterPropValArgs(varargin,obj.requiredCustomStageProperties, obj.requiredCustomStageProperties);
                    
                    if ischar(customDimensions) %all dimensions are custom
                        obj.set(pvargs(1:2:end),pvargs(2:2:end)); %TMW: Annoying this can't be done via abstract superclass or separate function for private/protected properties
                    else %only some dimensions are custom
                        for i=1:(length(pvargs)/2)
                            val = obj.get(pvargs{2*i-1}); %current value (as initialized)
                            val(customDimensions) = pvargs{2*i}(customDimensions);
                            obj.set(pvargs{2*i-1}, val);
                        end
                    end
                end
            end
            
            %Initialize default values, in 'passive' mode, so that hardware interface is not invoked yet.
            obj.initializeDefaultValues(true);
            
            % Validate 'moveCompletedDetectionStrategy' and register a listener, if necessary
            if ~ismember(obj.moveCompletedDetectionStrategy,{'hardwareInterfaceEvent' 'moveCompletedTimer'})
               assert(ischar(obj.moveCompletedDetectionStrategy) && isvector(obj.moveCompletedDetectionStrategy),'''moveCompletedDetectionStrategy'' does not represent a valid event name.');
               
               % TODO: verify that the subclass actually defines this event?
            end
            
            % Create a function handle for 'moveCompleteHookFcn', if necessary.
            if ~isempty(obj.moveCompleteHookFcn)
               obj.hMoveCompleteHookFcn = eval(['@(obj,targetPosn)' obj.moveCompleteHookFcn '(obj,targetPosn)']);
            end
            
            %Handle device interface type intialization
            switch obj.hardwareInterface
                case 'serial'                    
                    % Construct and initialize the RS232DeviceBasic 'mixin'
                    obj.hHardwareInterface = dabs.interfaces.RS232DeviceBasic(varargin{:}, 'deviceErrorResp', obj.deviceErrorResp, 'deviceSimpleResp', obj.deviceSimpleResp);
%                    obj.hHardwareInterface.initialize(varargin{:});
                    
                    if ~obj.testHardwareConnection()
                        delete(obj.hHardwareInterface);
                        error('Unable to communicate with device.');
                    end
                    %Add listeners for serial interface events
                    addlistener(obj.hHardwareInterface,'errorCondSet',@obj.interfaceErrorCondSet);
                otherwise 
                    %At moment, no generic superclass handling for any of the other generic connection types
                    obj.hHardwareInterface = [];
            end                 
           
        end
            
    
            %
            %         function initialize(obj)
            %
            %             if obj.initialized
            %                 return;
            %             end
            %
            %             if  obj.errorCondition && length(obj.errorConditionIdentifiers) == 1
            %                 obj.errorConditionReset();
            %
            %                 obj.numAvailableDimensions = length(obj.positionAbsoluteRaw);
            %
            %                 if obj.numAvailableDimensions < obj.numActiveDimensions
            %                     errorMsg = sprintf('The specified number of active dimensions (%d) exceeds the number of available dimensions (%d)',obj.numActiveDimensions, obj.numAvailableDimensions);
            %                     delete(obj);
            %                     error(errorMsg);
            %                 end
            %
            %                 obj.initialized = true;
            %
            %             else
            %                delete(obj)
            %                error('Unable to initialize object of class ''%s''',class(obj));
            %             end
            %         end
        
        function delete(obj)
            if ~isempty(obj.hHardwareInterface) && (strcmp(class(obj.hHardwareInterface),'dabs.interfaces.RS232DeviceBasic') || strcmp(class(obj.hHardwareInterface),'serial')) && isvalid(obj.hHardwareInterface)
                delete(obj.hHardwareInterface);
            end            

        end
        
    end
    
    %% PROPERTY ACCESS
    
    methods (Access=protected)
        
        function pdepPropHandleGet(obj,src,evnt)                                   
            propName = src.Name;      
            
            obj.blockOnErrorCond();
            try 
                obj.pdepPropHandleGetHook(src,evnt); %Subclass implements the 'real' pdepPropHandleGet() logic, with typical switch-yard                           
            catch ME
                obj.genericErrorHandler(obj.DException('','PropGetFail','Error occurred while attempting to access property %s',propName),true); %Issue callback type exception (warn only)
                ME.rethrow();
            end

        end        
        
        function pdepPropHandleSet(obj,src,evnt)
            propName = src.Name;
            
            obj.blockOnErrorCond();
            obj.blockOnPendingMove(); %Don't allow property sets during pending move.
            
            try              
                obj.pdepPropHandleSetHook(src,evnt); %Subclass implements the 'real' pdepPropHandleSet() logic, with typical switch-yard
            catch ME
                obj.genericErrorHandler(obj.DException('','PropSetFail','Error occurred while attempting to set property %s',propName),true); %Issue callback type exception (warn only)
                ME.throwAsCaller();
            end
        end       
    end
    
    methods        
        
        function val = get.numAvailableDimensions(obj)
            
            val = obj.numAvailableDimensionsHidden;
            
            %We may reconsider putting this into a post-construction initialize() step as it seems part-and-parcel with construction
            %On other hand, it's just error-checking and not fundamental to correct operation            
            if isempty(val)
                obj.numAvailableDimensionsHidden = length(obj.positionAbsoluteRaw);

                if obj.numAvailableDimensionsHidden < obj.numActiveDimensions
                    fprintf(2,'ERROR: The specified number of active dimensions (%d) exceeds the number of available dimensions (%d). Stage object is invalid and has been deleted.\n',obj.numActiveDimensions, obj.numAvailableDimensionsHidden);
                    delete(obj);
                end
                
                val = obj.numAvailableDimensionsHidden;
            end                            
        end

        
        function val = get.positionRelative(obj)
            val = obj.positionAbsolute - obj.relativeOrigin;
        end
        
        function val = get.positionAbsolute(obj)
            rawVal = obj.positionAbsoluteRaw;
            val = nan(1,obj.maxNumDimensions); %VVV: Should this be nan or 0??????
                                    

            %Apply activeDimensinos
            if obj.numAvailableDimensions == obj.maxNumDimensions %A subset of the 3 dimensions is controlled
                val(obj.activeDimensions) = rawVal(obj.activeDimensions);
            else                
                if obj.numActiveDimensions == obj.numAvailableDimensions
                    val(obj.activeDimensions) = rawVal;
                elseif obj.numActiveDimensions < obj.numAvailableDimensions
                    %In general, this case would be ambiguous and require further props to specify mapping of available to active dimensions
                    %However, given maxNumDimensions=3, the only case is where numAvailableDimensions=2
                    %We will assume that available dimensions are either XY or XZ, which disambiguates all cases of activeDimensions
                    
                    activeDimension = find(obj.activeDimensions); %Scalar value, given maxNumDimensions=3
                    
                    available2ActiveDimMap = [1 2 2]; %Assume available dimensions are XY or XZ
                    
                    val(activeDimension) = rawVal(available2ActiveDimMap(activeDimension));
                else
                    assert(false);
                end
            end
        end       

        
        function set.twoStepMoveEnable(obj,val)
            assert(ismember(val,[0 1]),'Value must be a logical -- 0 or 1, true or false');           
               
            if val
                %Verify that various twoStepMove properties pass through set property-access methods without error
                currLock = obj.pdepPropGlobalLock;
                obj.pdepPropGlobalLock = true;
                obj.twoStepMovePrepareFirstStep();
                try
                    for i=1:length(obj.twoStepMoveProperties)
                        prop = obj.twoStepMoveProperties{i};
                        twoStepMovePropVal =  obj.(['twoStepMoveAlt' upper(prop(1)) prop(2:end)]);
                        if ~isempty(twoStepMovePropVal) %Only try setting those that need to be set
                            obj.(prop) = twoStepMovePropVal;
                        end
                    end
                catch ME
                    obj.twoStepMoveFinish();
                    obj.pdepPropGlobalLock = currLock;
                    obj.twoStepMoveEnable = false;
                    error('One or more of the specified twoStepMove ''slow'' properties is either unspecified or incorrectly specified. Cannot enable two-step move.');
                end
                obj.twoStepMoveFinish();
                obj.pdepPropGlobalLock = currLock;
            end
            
            obj.twoStepMoveEnable = val;
        end
        
        function val = get.resolution(obj)
            %Report resolution as a scalar, if it's constant for all dimensions
            if length(unique(obj.resolution)) == 1
                val = obj.resolution(1);
            else
                val = obj.resolution;
            end
        end
        
        function set.resolution(obj,val)
            assert(isscalar(val) || (isvector(val) && length(val) == 3), '''resolution'' must be specified as a scalar or 3-element array of minimum size moves in all or each physical dimension');
            
            if isscalar(val)
                obj.resolution = repmat(val,1,3);
            elseif isvector(val) && length(val) == 3
                obj.resolution = val;
            end
        end
        
        function val = get.resolutionModes(obj)
            val = obj.resolutionModeMap.keys;
        end
        
        function val = get.resolutionCurrent(obj)
            val = obj.resolution .* obj.resolutionModeMap(obj.resolutionMode);
        end
        
        function set.stageAssemblyIndex(obj,val)
            obj.pdepSetAssert(val,isscalar(val) && ismember(val,1:obj.maxNumStageAssemblies),'Value must be an integer ranging from 1 to the maximum number of stage assemblies (%d) allowed for controllers of type %s',obj.maxNumStageAssemblies, class(obj));
            obj.stageAssemblyIndex = val;
        end
        
        function set.resolutionMode(obj,val)
            errMsg = 'Value must be a string specifying one of the available resolutionModes (or can be empty or ''default'' if only one mode is supported)';
            obj.pdepSetAssert(val,ischar(val) && ismember(val,{obj.resolutionModes{:} '' 'default'}) , errMsg);
            
            switch length(obj.resolutionModes)
                case 0
                    obj.resolutionMode = 'default';
                case 1
                    obj.resolutionMode = obj.resolutionModes{1};
                otherwise
                    if ismember(val,{'' 'default'})
                        error(errMsg);
                    else
                        obj.resolutionMode = val;
                    end
            end
        end
        
        function set.moveMode(obj,val)
            obj.pdepSetAssert(val,ischar(val) && ((~isempty(obj.moveModes) && ismember(val,obj.moveModes)) || (isempty(obj.moveModes) && ismember(val,{'' 'default'}))), 'Value must be a string specifying one of the available moveModes (or should be empty or ''default'' if only one mode is supported)'); %TMW: Should the warning about accessing another property from a dependent property's property-access method apply when that other property is Constant??
            obj.moveMode = val;
        end
        
        function set.velocity(obj,val)
            %NOTE - ideally would check to ensure that maxVelocity is not exceeded here. However, this causes issue for MP-285, which has maxVelocity per-resolution-mode.
            %NOTE - the ~isnan check is not ideal, but it allows ScanImage.Adapters.PI.MotionController to work while also preventing value from being actually set to NaN via command-line. 
            if ~isnan(val) 
                obj.pdepSetAssert(val,isnumeric(val) && (isscalar(val) || (isvector(val) && length(val)==3)) && all(val>=0), 'Value must be a non-negative scalar or 3 element per-dimension array of values.');
                obj.velocity = val;
            end
        end
        
        function set.invertCoordinates(obj,val)
            obj.pdepSetAssert(val,(isnumeric(val) || islogical(val)) && (isscalar(val) || (isvector(val) && length(val)==3)), 'Value must be a scalar or 3 element per-dimension array');
            obj.invertCoordinates = val;
        end
        
        function set.activeDimensions(obj,val)
            val = logical(val);
            assert(isvector(val) && length(val)==3, '''activeDimensions'' must be specified as a 3 element vector of logicals');
            obj.activeDimensions = val;
            obj.numActiveDimensions = length(find(obj.activeDimensions)); %#ok<MCSUP>
        end       
        
        function set.twoStepMoveAltMode(obj,val)
            obj.twoStepMoveAltMode = lower(val);
            
            % update all the '<propName>Fast' and '<propName>Slow' properties.
            for propName = obj.twoStepMoveProperties
                obj.zprpTwoStepMoveAltHelper(propName{:});
            end
        end
        
        function set.twoStepMoveAltVelocity(obj,val)
            obj.twoStepMoveAltVelocity = val;        
            obj.zprpTwoStepMoveAltHelper('velocity',val);
        end
        
        function set.twoStepMoveAltResolutionMode(obj,val)
            obj.twoStepMoveAltResolutionMode = val;         
            obj.zprpTwoStepMoveAltHelper('resolutionMode',val);
        end
        
        function set.twoStepMoveAltMoveMode(obj,val)
            obj.twoStepMoveAltMoveMode = val;         
            obj.zprpTwoStepMoveAltHelper('moveMode',val);
        end
        
        function zprpTwoStepMoveAltHelper(obj,propName,val)
            % Updates hidden '<propName>Fast' and '<propName>Slow' properties that are 'dependent' on a given 'twoStepMoveAlt<propName>' property
            
            if nargin < 3 || isempty(val)
                val = obj.(['twoStepMoveAlt' upper(propName(1)) propName(2:end)]);
                if isempty(val)
                    val = obj.(propName); % default to the regular property value
                end
            end
            
           switch obj.twoStepMoveAltMode
               case 'fast'
                   obj.([propName 'Fast']) = val;
                   obj.([propName 'Slow']) = obj.(propName);
               case 'slow'
                   obj.([propName 'Slow']) = val;
                   obj.([propName 'Fast']) = obj.(propName);
           end
        end

    end
    
    %% ABSTRACT METHODS (including 'semi-abstract')

    %Methods that all subclasses MUST define in a subclass-specific way.
    methods (Abstract,Access=protected,Hidden)        
        moveStartHook(obj,targetPosn); %Starts move and returns immediately.         
                
        %Pseudo-dependent property get/set handler logic
        pdepPropHandleGetHook(obj,src,evnt);
        pdepPropHandleSetHook(obj,src,evnt);        
    end
    
    %Semi-abstract methods - generic implementations that are often overridden by subclasses
    methods (Access=protected,Hidden)   
        
        function isHardwareConnected = testHardwareConnection(obj)
            %Tests the device's hardware connection
            assert(false);
        end
        
        function interruptMoveHook(obj)
            obj.DException('','InterruptMoveNotSupported','Device of class %s does not support ''interruptMove()'' operation.',class(obj));
        end
        
        function recoverHook(obj)
            
            %Provide a default recover() behavior for serial port devices, that may help to restore operation
            %Individual subclasses can/should override this recover() behavior if a better mechanism exists for that particular device
            if strcmpi(obj.hardwareInterface,'serial')
                fclose(obj.hHardwareInterface.hSerial);
                fopen(obj.hHardwareInterface.hSerial);
               
                try
                    obj.errorConditionReset();                    
                    posn = obj.positionAbsolute;
                    if obj.errorCondition %See if any error condition was caused during get operation
                        error('dummy');
                    end
                catch 
                    ME = obj.DException('','DefaultSerialRecoveryFailed','Attempted default serial port device recover() operation, but was unsuccessful');
                    obj.errorConditionSet(ME);                                        
                    ME.throw();
                end
            else                          
                obj.DException('','RecoverNotSupported','Device of class %s does not support ''recover()'' operation.',class(obj));
            end
        end
        
        function resetHook(obj)
            obj.DException('','ResetNotSupported','Device of class %s does not support ''reset()'' operation.',class(obj));
        end
        
        function zeroHardHook(obj)
            obj.DException('','ZeroHardNotSupported','Device of class %s does not support ''zeroHard()'' operation.',class(obj));
        end
        
        
    end
    
    
    %% PUBLIC METHODS
    methods
        function defaultInitialize(obj)
            %Method containing typical initializations to do at end of constructing concrete linear stage controller class
            %This method can be invoked by concrete subclass constructor
            
            %Other initializations
            obj.velocity = obj.maxVelocity; %Initialize velocity to maximum velocity
        end
        
        function reset(obj)
            %Reset device. For some devices, this will automatically cause a zeroHard() action to occur
            
            try
                obj.resetHook(); 
            catch ME
                if ~strcmpi(ME.message,'ResetNotSupported') && ~obj.errorCondition %Just pass through if reset not supported, and no error exists
                    return;
                else
                    ME.rethrow();
                end
            end 
            
            %If successful, reset error flag
            obj.errorConditionReset();
        end
        
        function recover(obj)
            %Recover from error condition. This should represent an operation less drastic than reset() that will often allow device to return to good state (or verify that it has done so on its own) following error.                    

            try
                obj.recoverHook(); 
            catch ME
                ME.rethrow();
            end
            
            %If successful, reset error flag
            obj.errorConditionReset();
        end

 
        function interruptMove(obj)
            %Attempt to interrupt (cancel) pending move, if any
            
            if obj.asyncMovePending
                %%%DEQ20101124
                if strcmp(obj.hardwareInterface,'serial') && obj.hHardwareInterface.asyncReplyPending
                    obj.hHardwareInterface.abortAsyncReply();
                end
                
                obj.interruptMoveHook(); %Attempt 'hard' interrupt of move

                %If successful, reset asyncMovePending flag. This allows new move to be started (even if timer from last move continues).
                obj.asyncMovePending = false;
            end
        end
        
        function zeroHard(obj,coords)
            %Set current position as absolute origin (maintained by device hardware). Argument 'coords' specifies 3 element logical array indicating which dimensions to zero. If omitted, [1 1 1] is assumed (all dimensions).

            %Check if command should proceed
            obj.blockOnErrorCond();
            obj.blockOnPendingMove();               
            
            %Do argument checking/processing %TMW: This is identical to that in zeroSoft(), but messy to do as a helper function. Inline functions would be handy.
            if nargin < 2 || isempty(coords)
                coords = ones(1,obj.maxNumDimensions);
            else
                assert(isnumeric(coords) && isvector(coords) && length(coords)==obj.maxNumDimensions && all(ismember(coords,[0 1])), 'Argument ''coords'' must be a logical vector consisting of %d elements -- one per dimension',obj.maxNumDimensions);
            end
            
            %Warn user about zeroHard() operation, if needed
            if obj.zeroHardWarning
                resp = questdlg('Executing zeroHard() operation will reset stage controller''s absolute origin. Proceed?','WARNING!','Yes','No','No');
                if strcmpi(resp,'No')
                    return;
                end
            end
            
            %Execute zeroHard() operation in subclass-specific manner; reset the zeroHardWarning flag
            obj.zeroHardHook(coords); %Pass on to subclass concrte method implementation
            obj.zeroHardWarning = false; %Do not warn multiple times %TODO(?): Consider means of only resetting if a 'Do Not Warn Again' option is selected.
            
            %TODO: Handle relativeOrigin reset or recomputation following zeroHard() operation!
            
        end
        
        function zeroSoft(obj,coords)
            %Set current position to software-maintained origin (maintained by this class). Argument 'coords' specifies 3 element logical array indicating which dimensions to zero. If omitted, [1 1 1] is assumed (all dimensions).
            
            %Check if command should proceed
            obj.blockOnErrorCond();
            obj.blockOnPendingMove();   
            
            %Do argument checking/processing %TMW: This is identical to that in zeroHard(), but messy to do as a helper function. Inline functions would be handy.
            if nargin < 2 || isempty(coords)
                coords = ones(1,obj.maxNumDimensions);
            else
                assert((islogical(coords) || isnumeric(coords)) && isvector(coords) && length(coords)==obj.maxNumDimensions && all(ismember(coords,[0 1])),...
                    'Argument ''coords'' must be a logical vector consisting of %d elements -- one per dimension',obj.maxNumDimensions);
            end
            coords = logical(coords);
            
            currPosn = obj.positionAbsolute;
            obj.relativeOrigin(coords) = currPosn(coords);
            
            %Set flag indicating successful zeroSoft() action has occurred
            obj.zeroSoftFlag = obj.zeroSoftFlag | logical(coords);
        end
        
        function moveCompleteRelative(obj, targetPosn)
            %Starts move to targetPosn, specified in relative coordinates, and blocks command execution until move is completed. If setPositionVerify is true, final position is checked before returning.                        
            obj.moveCompleteHidden(targetPosn,false);
        end
        
        function moveCompleteAbsolute(obj,targetPosn)
            %Starts move to targetPosn, specified in absolute coordinates, and blocks command execution until move is completed. If setPositionVerify is true, final position is checked before returning.
            obj.moveCompleteHidden(targetPosn,true);
        end
        
        function moveCompleteIncremental(obj, increment)
            
            assert(length(increment) == obj.maxNumDimensions,'Specified increment value must contain %d elements', obj.maxNumDimensions);
            
            %Check if move is pending (BEFORE reading positionAbsolute)
            obj.blockOnPendingMove();
            
            %Starts incremental move and blocks command execution until move is completed. If setPositionVerify is true, final position is checked before returning.
            currPosn = obj.positionAbsolute();
            obj.moveCompleteAbsolute(currPosn + increment);
        end
   
        function moveStartRelative(obj,targetPosn)
            %Starts relative move and returns immediately. Can check for move completion via isMoving().            
            obj.moveStartHidden(targetPosn, false);
        end
        
        function moveStartAbsolute(obj,targetPosn)
            %Starts move, specified in absolute coordinates, and returns immediately. Can check for move completion via isMoving().            
            obj.moveStartHidden(targetPosn, true);
        end   
        
        function moveStartIncremental(obj,increment)
            
            assert(length(increment) == obj.maxNumDimensions,'Specified increment value must contain %d elements', obj.maxNumDimensions);
            
            %Check if move is pending (BEFORE reading positionAbsolute)
            obj.blockOnPendingMove();
            
            %Starts incremental move and returns immediately. Can check for move completion via isMoving().
            currPosn = obj.positionAbsolute();
            obj.moveStartAbsolute(currPosn + increment);
        end  
        
        function moveFinish(obj)
            %Manually signal end-of-move following a (one-step) moveStartXXX() command (not a moveStartGenerateEvent()). This is required to clear asyncMovePending flag before subsequent asynchronous moves can be started. 
            %This should be done before the asyncMoveTimeout period, if specified, has expired, or timeout error will occur (even if move has physically completed).
            
            %Check if command should proceed
            obj.blockOnErrorCond();
            if ~obj.asyncMovePending
                return;
            end
            
            %Reset asyncMovePending flag if not moving
            if obj.isMoving
                obj.genericErrorHandler(obj.DException('','CannotFinishWhileMoving','The device of class %s appears to still be moving, so asynchronous move cannot be deemed finished.'),class(obj));
            else
                obj.asyncMovePending = false;
            end
        end       
        
        function moveWaitForFinish(obj,pauseInterval)
            %Wait for end-of-move following a (one-step) moveStartRelative() command (not a moveStartGenerateEvent()). This method polls the isMoving property in a tight loop with pause() statement -- blocking Matlab execution, but allowing callbacks to fire.
            %   pauseInterval: Time, in seconds, to use in pause() or pauseTight() command in tight loop. If omitted, the value given by the 'moveWaitForFinishPauseInterval' property is used.
            %
            %NOTES
            %   The usePauseTight property determines if pauseTight() is used, in lieu of built-in pause commadn            
           
            if nargin < 2 || isempty(pauseInterval)
                pauseInterval = obj.moveWaitForFinishPauseInterval;
            end                                           
            
            %Check if command should proceed
            obj.blockOnErrorCond();
            if ~obj.asyncMovePending
                return;
            end
            
            try                              
                
                %Wait in tight loop for isMoving flag to be reset and/or final position to be reached
                %Relies on asyncMoveTimeout mechanism to signal if timeout occurs
                while obj.isMoving || (obj.setPositionVerifyOnMoveWait && ~obj.zprvVerifySetPositionHidden())
                    if obj.errorCondition %Handle case where error occurs while waiting -- in particular, asyncMoveTimeout
                        throw(obj.errorConditionArray(end));
                    end
                    if toc(obj.asyncMoveTimeReference) > obj.asyncMoveTimeout
                        throw(obj.DException('','AsyncMoveTimeout','Move failed to complete within specified ''asyncMoveTimeout'' period (%d s)',obj.asyncMoveTimeout));
                    end
                    
                    if obj.usePauseTight
                        most.idioms.pauseTight(pauseInterval);
                    else
                        pause(pauseInterval);
                    end

                end
                
             
                obj.moveFinish(); %Signals that move is complete
                
            catch ME
                obj.genericErrorHandler(ME);
            end
            

        end
        
        
        function verifySetPosition(obj)
            
            %Check if command should proceed
            obj.blockOnErrorCond();
            obj.blockOnPendingMove();
            
            %Actually verify that current position matches the set position
            generateException = ~obj.zprvVerifySetPositionHidden();
            
            %Reset the stored position
            obj.setPositionVerifyPositionStore = [];
            
            if generateException
                %error([mfilename('class') ':SetPositionMismatch'],'Final obtained position does not match the intended position within required accuracy');
                error('Final obtained position does not match the intended position within required accuracy'); %TMW: For some reason, the message identifier, not message string appears as the error message. Not in a try/catch block, but error originates from property access method.
            end
        end
        
    end
    
    
    %% DEVELOPER METHODS
    
    methods (Hidden,Access=protected)
    
        function targetPosn = reduceTargetPosn(obj,targetPosn)
            %Method subclasses can use to reduce targetPosn 3-vector to size appropriate for particular LSC device
            
            %For LSC, targetPosn is always returned and specified as a 3-vector
            %However, for some devices,  the underlying move operation requires a 1 or 2 vector
            %This method can be used in subclass moveStartHook() method implementations to reduce targetPosn to correct dimensions
            
            if length(targetPosn) > obj.numAvailableDimensions
                targetPosn(targetPosn==0) = []; %Eliminate zero values -- moveHidden() replaces unused dimension values with 0
                if isempty(targetPosn) %Ensure there's at least one value (the desire
                    targetPosn = zeros(1,obj.numAvailableDimensions);
                end     
            elseif length(targetPosn) == obj.numAvailableDimensions
                return;
            else
                assert(false);
            end
            
        end
        
        
        
        function tf = zprvVerifySetPositionHidden(obj)

            try 
                assert(~isempty(obj.setPositionVerifyPositionStore),'No recently set position is stored. Unable to verify set position accuracy.');
                
                
                currPosn = obj.positionAbsolute(obj.activeDimensions);
                targetPosn = obj.setPositionVerifyPositionStore(obj.activeDimensions);
                
                if obj.setPositionVerifyAccuracyPerDimension
                    tf = ~any(abs(currPosn - targetPosn) > obj.setPositionVerifyAccuracy); %VI042011A
                else
                    tf = norm(currPosn-targetPosn) <= obj.setPositionVerifyAccuracy; %VI042011A
                end
            catch ME
                ME.throwAsCaller();
            end
        end
        
        function blockOnPendingMove(obj)
            %Method which blocks subsequent action on pending move   
            if obj.asyncMovePending
                throwAsCaller(obj.DException('','BlockOnPendingMove','A move is pending. Unable to proceed with current command.'));                
            end
        end
        
        function blockOnErrorCond(obj)
            %Blocks subsequent action if error condition is present
            
            if obj.errorCondition
                throwAsCaller(obj.DException('','BlockOnError','An error condition exists for device of class %s. Unable to proceed with current command.',class(obj)));
                %                 if ~obj.initialized
                %                     throwAsCaller(obj.DException('','Uninitialized','Objects of class ''%s'' must be initialized before accessing properties or methods', class(obj)));
                %                 else
                %                     throwAsCaller(obj.DException('','BlockOnError','An error condition exists for device of class %s. Unable to proceed with current command.',class(obj)));
                %                 end
            end
        end        
      
    end
    
    
    methods (Hidden,Access=private)
        
        function moveCompleteHidden(obj,targetPosn,isAbsolute)
            % Intermediary moveComplete function in charge of handling two-step move logic.
                       
            %Check if command should proceed
            obj.blockOnErrorCond();
            assert(length(targetPosn) == obj.maxNumDimensions,'Specified targetPosn value must contain %d elements', obj.maxNumDimensions); %VI042111A
            obj.blockOnPendingMove();
            
            
            moveType = obj.determineMoveType(targetPosn);
            
            if strcmpi(moveType,'oneStep')
                obj.moveHidden(targetPosn,true,isAbsolute);  %Move to target position at current velocity/resolution settings
            else
                obj.twoStepMovePrepareFirstStep(); %Caches initial properties (after verifying slow-step settings are OK)
                try
                    switch moveType
                        case 'oneStepSlow' %Move to target position at slow velocity/resolution settings
                            obj.twoStepMovePrepareSlowStep(); %Skip to second step
                            obj.moveHidden(targetPosn,true,isAbsolute);
                        case 'twoStep' %Use two steps to move to target position
                            %Do first move at current velocity/resolution settings, and without checking position
                            verifyTemp = obj.setPositionVerifyAutomatic; % Cache the current value before disabling it...
                            obj.setPositionVerifyAutomatic = false;
                            obj.moveHidden(targetPosn,true,isAbsolute);
                            obj.setPositionVerifyAutomatic = verifyTemp; % ...restore the cached value.
                            
                            %Do second move at 'alt' velocity/resolution settings
                            if ~all(obj.positionAbsolute == targetPosn) %TODO: Should we do this check? Or just forcibly do second move anyway?
                                obj.twoStepMovePrepareSlowStep();
                                obj.moveHidden(targetPosn,true,isAbsolute);
                            end
                    end
                    %Restore initial properties
                    obj.twoStepMoveFinish();
                catch ME
                    obj.setPositionVerifyPositionStore = [];
                    obj.twoStepMoveFinish();
                    ME.throwAsCaller()
                end
            end
            
        end
        
        
        function moveStartHidden(obj,targetPosn,isAbsolute)
            
            %Check if command should proceed
            obj.blockOnErrorCond();
            assert(length(targetPosn) == obj.maxNumDimensions,'Specified targetPosn value must contain %d elements', obj.maxNumDimensions); %VI042111A
            obj.blockOnPendingMove();            
             
            moveType = obj.determineMoveType(targetPosn);
            if strcmpi(moveType,'oneStep')
                obj.twoStepMoveInProgress = false;
                obj.twoStepMoveFinalStep = true;
            else
                obj.twoStepMoveInProgress = true; %Flags that twoStep is enabled, whether used or not, and that cached properties must be restored
                obj.twoStepMovePrepareFirstStep(); %Caches initial properties (after verifying slow-step settings are OK)
                
                switch moveType
                    case 'oneStepSlow' %Move to target position at slow velocity/resolution settings
                        obj.twoStepMovePrepareSlowStep(); %Skip to second step
                        obj.twoStepMoveFinalStep = true;
                    case 'twoStep' %Use two steps to move to target position
                        obj.twoStepMoveFinalStep = false;
                end
            end
            
            obj.moveHidden(targetPosn,false,isAbsolute,moveType);
        end
     

        function moveHidden(obj,targetPosn,isCompleteMove,isAbsolute,moveType)            
                
            if nargin < 5 || isempty(moveType)
               moveType = 'oneStep'; 
            end       
            
            %Ensure targetPosn only pertains to active dimensions
            if obj.numActiveDimensions < obj.maxNumDimensions
                assert(all(arrayfun(@(x)isnan(x) || x==0, targetPosn(~obj.activeDimensions))), ...
                    'A move was specified in dimension designated as inactive');
            end
            
                 
            %Convert targetPosn to absolute coordinates, if needed
            if ~isAbsolute
               targetPosn = targetPosn + obj.relativeOrigin; 
            end
            
            % Replace any NaNs and inactive dimesions with the value of the current position, if needed
            nonMoveIndices = isnan(targetPosn) | ~obj.activeDimensions;
            if any(nonMoveIndices) 
               targetPosn(nonMoveIndices) = 0; %VVV: Use 0 as marker of non-moving index for now -- is this needed for set position verification?? otherwise we might as well use NaN
               
               if obj.numAvailableDimensions > (obj.maxNumDimensions - length(find(nonMoveIndices)))                   
                   %VI: This works in case where positionAbsoluteRaw is either scalar or of full length 3. Have not handled case where it might be a 2-vector.
                   targetPosn = targetPosn + nonMoveIndices.*obj.positionAbsoluteRaw;
               end                   
            end
                        
            
            %Store target position, for manual setPositionVerify call
            if ~obj.setPositionVerifyAutomatic
                obj.setPositionVerifyPositionStore = targetPosn;
            end
     
            if isCompleteMove % Synchronous (blocking) move    
                moveCompleteReal(targetPosn);
                waitForCompletedMove();

                %Verify final position, if needed
                if obj.setPositionVerifyAutomatic
                    obj.verifySetPosition();
                end
            else % Asynchronous (non-blocking) move
                shouldDetectMoveComplete = obj.generateMoveCompletedEvent || strcmpi(moveType,'twoStep');
                useHardwareEvent = shouldDetectMoveComplete && strcmpi(obj.moveCompletedDetectionStrategy,'hardwareInterfaceEvent');
                useSubclassEvent = shouldDetectMoveComplete && ~ismember(obj.moveCompletedDetectionStrategy, {'hardwareInterfaceEvent' 'moveCompletedTimer'});
                useMoveCompletedTimer = shouldDetectMoveComplete && strcmpi(obj.moveCompletedDetectionStrategy,'moveCompletedTimer');
                
                %Create Timer objects, as needed
                if useMoveCompletedTimer
                    %Timer that polls for move completion without blocking command line
                    hMoveCompletedTimer = timer('TimerFcn',@moveCompletedTimerFcn,'StartDelay',0.2,'Period',0.2,'ExecutionMode','fixedRate','Name','moveCompletePoll');
                else
                    hMoveCompletedTimer = [];
                end

                if ~isinf(obj.asyncMoveTimeout) && shouldDetectMoveComplete
                    %Timer that will fire if event-generating async move times out
                    %If no event is generated, the moveWaitForFinish() method determines asyncMoveTimeout 
                    hAsyncMoveTimeoutTimer = timer('TimerFcn',@handleAsyncMoveTimeout,'StartDelay',obj.asyncMoveTimeout,'Name','asyncMoveTimeoutCheck'); %single-shot timer
                else
                    hAsyncMoveTimeoutTimer = [];
                end

                %Register appropriate event listener, if needed
                asyncMoveCompleteDetectListener = [];
                if useHardwareEvent
                    asyncMoveCompleteDetectListener = addlistener(obj.hHardwareInterface,'asyncReplyReceived',@handleMoveCompleteDetect);
                elseif useSubclassEvent
                    asyncMoveCompleteDetectListener = addlistener(obj,obj.moveCompletedDetectionStrategy,@handleMoveCompleteDetect);
                end

                %Start move
                moveStartReal();
                obj.asyncMoveTimeReference = tic();
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%Nested helper functions - synchronous move%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            function moveCompleteReal(targetPosn)
                
               if ~isempty(obj.hMoveCompleteHookFcn)
                   feval(obj.hMoveCompleteHookFcn,obj,targetPosn); 
               else
                   obj.moveStartHook(targetPosn); 
               end
            end
            
            function waitForCompletedMove()                
                %Handler for case where underlying move command is not blocking..we do blocking/timeout detection here  
                
                t = tic();
                while obj.isMoving || (obj.setPositionVerifyOnMoveWait && ~obj.zprvVerifySetPositionHidden())
                    if toc(t) > obj.moveTimeout
                        throwAsCaller(obj.DException('','MoveTimeout','Move failed to complete within specified ''moveTimeout'' period (%d s)',obj.moveTimeout));
                    end
                    
                    if obj.usePauseTight
                        most.idioms.pauseTight(obj.moveCompletePauseInterval);
                    else
                        pause(obj.moveCompletePauseInterval);
                    end
                end
                
                % DEQ20101209 - calling moveFinish() from this function shouldn't have any effects...
                %Signal end of any async move. Harmless if none was used.
                %obj.moveFinish();
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%Nested helper functions - asynchronous move%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            function moveStartReal()
                %Dispatch of actual moveStart operation, and start of required timer objects
               
                obj.asyncMovePending = true;
                obj.moveStartHook(targetPosn); 
                
                %Start moveCompletedTimer, if needed
                if useMoveCompletedTimer && shouldDetectMoveComplete
                    start(hMoveCompletedTimer);
                end
                
                %Start asyncMoveTimeoutTimer, if needed
                if ~isempty(hAsyncMoveTimeoutTimer)
                    start(hAsyncMoveTimeoutTimer);
                end
                            
            end
            
            function asyncMoveStopTimers()
                %Stop timers..but don't delete them, as they may be used again
                
                if ~isempty(hMoveCompletedTimer)
                    stop(hMoveCompletedTimer);
                end
                
                if ~isempty(hAsyncMoveTimeoutTimer)
                    stop(hAsyncMoveTimeoutTimer);
                end                               
            end
            
            function asyncMoveCleanup()            
                %Stop & Delete timer resources
                
                timers = [hMoveCompletedTimer hAsyncMoveTimeoutTimer];
                for i=1:length(timers)
                    if ~isempty(timers(i))
                        stop(timers(i));
                        delete(timers(i));
                    end
                end
                %Delete listerner resources
                if ~isempty(asyncMoveCompleteDetectListener) 
                    delete(asyncMoveCompleteDetectListener);
                end
                
                %Restore initial properties, if changed
                if obj.twoStepMoveInProgress 
                    obj.twoStepMoveFinish();                    
                end
                
                %Reset flags
                obj.asyncMovePending = false;   
            end
            
            function moveCompletedTimerFcn(~,~)
                %Timer function that polls to see if motor is still moving
                
                if obj.asyncMovePending %Move completed before timeout
                    if ~obj.isMoving
                        handleMoveCompleteDetect();
                    end
                else %Move may have been interrupted
                    asyncMoveCleanup();
                end
            end
                          
            function handleAsyncMoveTimeout(~,~)
                if obj.asyncMovePending %timeout occurred before move complete was detected (or manually specified) 
                    obj.genericErrorHandler(obj.DException('','AsyncMoveTimeout', 'Move failed to complete within specified ''asyncMoveTimeout'' period (%d s)',obj.asyncMoveTimeout),true); %Warn only, as this is a callback
                else %Move may have been previously interrupted
                    asyncMoveCleanup();
                end
            end 
            
            function handleMoveCompleteDetect(~,~)
                
                %Move may have been interrupted
                if ~obj.asyncMovePending
                    asyncMoveCleanup();
                    return;
                end
                
                obj.asyncMovePending = false; 
                asyncMoveStopTimers(); %This stops asyncMoveTimeoutTimer, as move complete came before timeout
                
                if obj.twoStepMoveInProgress && ~obj.twoStepMoveFinalStep
                    obj.twoStepMovePrepareSlowStep(); 
                    obj.twoStepMoveFinalStep = true;                    
                    if ~obj.generateMoveCompletedEvent %Don't detect final move-completion if not generating event
                        delete(asyncMoveCompleteDetectListener);
                        shouldDetectMoveComplete = false;
                    end
                    moveStartReal();                    
                else
                    try                                             
                        %Verify set position accuracy, if indicated
                        if obj.setPositionVerifyAutomatic
                            obj.verifySetPosition();
                        end
                        
                        asyncMoveCleanup(); %Delete all resources related to async move
                        
                        if obj.generateMoveCompletedEvent
                            obj.notify('moveCompletedEvent');
                        end
                        
                    catch ME
                        asyncMoveCleanup();
                        ME.rethrow();
                    end
                 end
            end

        end % moveHidden()        
        
        
        function moveType = determineMoveType(obj,targetPosnAbs)
            %Determine type of move to use
            if obj.twoStepMoveEnable
                if isempty(obj.twoStepMoveSlowDistance)
                    moveType = 'twoStep';
                else
                    distance = norm(targetPosnAbs(obj.activeDimensions) - obj.positionAbsolute(obj.activeDimensions)); %VI042011A
                    if distance < obj.twoStepMoveSlowDistance
                        moveType = 'oneStepSlow';
                    else
                        moveType = 'twoStep';
                    end
                end
            else
                moveType = 'oneStep';
            end            
        end
        
        
        %%%VI040510A
        function handleErrorCondReset(obj,~,~)
            %Cleanup anything that might be in wrong state following a previous error

            obj.asyncMovePending = false; 
            timers = [timerfindall('Name','moveCompletePoll') timerfindall('Name','asyncMoveTimeoutCheck')];
            if ~isempty(timers)
                stop(timers);
                delete(timers);
            end
        end
        
        function twoStepMovePrepareFirstStep(obj)            
            %Initialize twoStepMovePropertyStore, if needed
            if isempty(obj.twoStepMovePropertyStore)
                obj.twoStepMovePropertyStore = containers.Map();
            end
            
            %Clear twoStepMovePropertyStore
            propStore = obj.twoStepMovePropertyStore;
            propStore.remove(propStore.keys());
            
            for i=1:length(obj.twoStepMoveProperties)
                propName = obj.twoStepMoveProperties{i};
                slowPropVal = obj.([propName 'Slow']);
                if ~isempty(slowPropVal)
                    obj.twoStepMovePropertyStore(propName) = obj.(propName);
                end
            end
            
            % Set all two-step move properties to the value stored in '<propName>Fast'.
            for propName = obj.twoStepMoveProperties
                fastPropVal = obj.([propName{:} 'Fast']);
                if ~isempty(fastPropVal)
                    obj.(propName{:}) = fastPropVal;
                end
            end
            
        end
        
        function twoStepMovePrepareSlowStep(obj)            
            assert(logical(obj.twoStepMoveEnable),'Two step move operation occurred despite being disabled. Suggests logical programming error.');
            
            try
                for i=1:length(obj.twoStepMoveProperties)
                    propName = obj.twoStepMoveProperties{i};
                    slowPropVal = obj.([propName 'Slow']);
                    if ~isempty(slowPropVal)
                        obj.(propName) = slowPropVal;
                    end
                end
            catch ME
                obj.twoStepMoveFinish(); %Try to restore properties
                ME.rethrow();
            end
        end
        
        function twoStepMoveFinish(obj)
            %assert(obj.twoStepMoveEnable,'Two step move operation occurred despite being disabled. Suggests logical programming error.');
            
            propStore = obj.twoStepMovePropertyStore;
            propStoreVars = propStore.keys();
            for i=1:length(propStoreVars)
                obj.(propStoreVars{i}) = obj.twoStepMovePropertyStore(propStoreVars{i});
            end
        end
        
        function interfaceErrorCondSet(obj,~,~)
            %Listener for hardware interface errors
            %At moment, just issue warning. Not sure if this handler is ever really useful/desirable.
            
            %Don't use generic error handler -- this will lead to more attempts to interrupt, and can get into infinite loop
            %obj.genericErrorHandler(obj.DException('','HardwareInterfaceError','Hardware interface error detected.'),true); %Warn only, as this is a callback           
            
            fprintf(2,'WARNING(%s): Error has occurred on hardware interface of class %s:\n\t%s\n',class(obj),class(obj.hHardwareInterface),obj.hHardwareInterface.errorConditionMessages{end});            
        end
        
        function genericErrorHandler(obj,ME,warnOnly)
            %ME: MException object, passed on from the source of the error
            %warnOnly: Flag indicating that warning, instead of error, should be given. This is often appropriate from a callback, since error does not block operation and warning would appear anyway. 
            
            if nargin < 3 || isempty(warnOnly)
                warnOnly = false;
            end
            
            %Attempt to stop async move, if one is pending
            interruptFailNotice = false;
            if obj.asyncMovePending  && obj.autoInterruptAsyncMoveOnError          
                try 
                    obj.interruptMove(); %Does both 'soft' and attempt of 'hard' cleanup of async move
                catch ME2
                    interruptFailNotice = true;
                end
            end
            
            %Signal error
            obj.errorConditionSet(ME);

            %Reset variables
            obj.setPositionVerifyPositionStore = [];
            
            if interruptFailNotice
                fprintf(2,'WARNING(%s): Attempted to interrupt move but was unsuccessful. Motor may remain in motion.\n',class(obj));
            end

            %Throw/display errors/warnings
            if warnOnly
                fprintf(2,'WARNING(%s): %s\n',class(obj),ME.message);
            else
                ME.throwAsCaller();
            end            

        end
    end
    
    methods (Access=protected)
        

        
        function val = device2ClassUnits(obj,val,quantity)
            deviceQuantity = obj.(['device' upper(quantity(1)) lower(quantity(2:end)) 'Units']);
            
            if ~all(isnan(deviceQuantity))
                classQuantity = obj.([lower(quantity) 'Units']);
                val = val(:) .* (deviceQuantity(:)./classQuantity(:));                
            end
        end
        
        function val = class2DeviceUnits(obj,val,quantity)
            % Converts from class units to device units.
            
            deviceQuantity = obj.(['device' upper(quantity(1)) lower(quantity(2:end)) 'Units']);
            
            if ~all(isnan(deviceQuantity))
                classQuantity = obj.([lower(quantity) 'Units']);
                val = val(:) .* (classQuantity(:)./deviceQuantity(:));
            end
        end
        
        function initializeStageType(obj,stageType)
            
            currLockVal = obj.pdepPropGlobalLock;
            obj.pdepPropGlobalLock = true; %Disable listeners for pseudo-dependent properties
            
            try                
                if ~obj.stageTypeMap.isKey(lower(stageType))
                    error(['Unrecognized stage type: ' stageType]);
                else
                    obj.stageType = lower(stageType);
                    props = fieldnames(obj.stageTypeMap(obj.stageType));
                    
                    %Initialize object properties based on stageType
                    cellfun(@(x)set(obj,x,obj.stageTypeMap(obj.stageType).(x)),props);
                end
                
                obj.pdepPropGlobalLock = currLockVal;
            catch ME
                obj.pdepPropGlobalLock = currLockVal;
                ME.throwAsCaller();
            end
        end
        
        function initializeDefaultValues(obj,passive)
            %Utility function for subclasses to initialize property values in various ways - including based on hidden properties of same name, but starting with 'default'
            %Typically subclasses will use this in their constructors; sometimes first in 'passive' mode and later in 'active' mode
            %Not all subclasses may do this and different subclasses may need to do this following other initialization - hence this is not coded into this abstract class's constructor
            
            if nargin < 2 || isempty(passive)
                passive = false;
            end
            
            currLockVal = obj.pdepPropGlobalLock;
            
            try
                %If in passive mode, lock out property get/set listeners, allowing properties to be directly set
                if passive
                    obj.pdepPropGlobalLock = true;
                end
                
                %Determine property names for class
                mc = metaclass(obj);
                props = mc.Properties;
                propNames = cellfun(@(x)x.Name,props,'UniformOutput',false);
                defaultPropNames = propNames(cellfun(@(x)~isempty(x) && x(1)==1,strfind(propNames,'default')));
                
                %Initialize modes, if not done so by the subclass property block.
                modeTypes = {'resolutionMode' 'moveMode'};
                for i=1:length(modeTypes)
                    if isempty(obj.(modeTypes{i})) && ~ismember(lower(['default' modeTypes{i}]),lower(defaultPropNames))
                        if isempty(obj.([modeTypes{i} 's']))
                            obj.(modeTypes{i}) = 'default'; %Use 'default' as placeholder mode value
                        else
                            obj.(modeTypes{i}) = obj.([modeTypes{i} 's']){1};
                        end
                    end
                end
                
                %propNames = properties(obj); %TMW: No access to hidden props this way
                for i=1:length(defaultPropNames)
                    actPropName = defaultPropNames{i}(8:end); %strip off 'default'
                    actPropName = propNames(strcmpi(actPropName,propNames));
                        
                    if obj.errorCondition
                        obj.DError('','InitDefaultsFail','Error condition prevents completion of object initialization');
                    end                    
                    obj.(actPropName{1}) = obj.(defaultPropNames{i});                                        

                end
                
                %Restore global lock on property get/set listeners to initial value
                if passive
                    obj.pdepPropGlobalLock = currLockVal;
                end
                
            catch ME
                obj.pdepPropGlobalLock = currLockVal;
                ME.rethrow();
            end
        end
        
    end
    
end

