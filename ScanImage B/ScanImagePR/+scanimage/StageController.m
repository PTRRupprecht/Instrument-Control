classdef StageController < hgsetget
% LSC + (two-step moves)
%
% API:
%   * Position properties.
%   * Zeroing + relative origin.
%   * Move.
%
% Two-step notes.
%   Configuration of two-step moves is done at construction time, when a
%   number of optional arguments related to two-step moves may be passed
%   in.
%
%   If two-step moves are enabled, then the prevailing values of a subset
%   of LSC properties (the 'two-step properties') are cached /at
%   construction-time/. These values are restored following all move
%   operations (whether one-step or two-step). For sensible behavior, it is
%   assumed that the two-step property values are not changed directly
%   during the lifetime of this LSC wrapper object.
%
%   Strictly speaking, despite this restoration of properties, the state of
%   the LSC after a two-step move is not guaranteed to be identical to its
%   state before a two-step move, since how the LSC handles property
%   setting is its own business. For example, some LSC properties may be
%   indexed by 'resolutionMode', in which case it is possible (albeit a bit
%   pathological) to construct values of
%   twoStepFastPropVals/twoStepSlowPropVals that will lead to the LSC
%   having different state before/after a two-step move. In general,
%   two-step settings must "know their motor" and do the right thing for
%   their specific LSC.
%
%   Two-step moves are implemented by setting an arbitrary subset of
%   properties on the LSC i) before a two-step move (the 'fast' property
%   values) and ii) after the fast stage of a two-step move (to the 'slow'
%   property values)
%
%   One-step moves are used when 1) twoStepEnable is off, or 2) when it's
%   on but move is below a twoStepDistanceThreshold. 
%

    properties (Dependent)
        positionRelative; % Relative stage position, in positionUnits
        positionAbsolute; % Absolute stage position, in positionUnits
        
        moveTimeout; % Timeout for blocking moves
        relativeOrigin; % Software-maintained origin for position coordinates, in positionUnits
        
        analogCmdEnable; % (For LSCAnalogOption type controllers) Logical; if true, analog command signal is in use to control LSC position
    end
    
    properties (Dependent,SetAccess=protected)
        resolution; %Current stage resolution, in positionUnits.
        resolutionBest;  %Best possible stage resolution, in positionUnits.
    end
    
    
    properties
        nonblockingMoveTimeout = 2.0; % Timeout, in seconds, for nonblocking moves
        twoStepDistanceThreshold = 100; %Distance threshold, in positionUnits, below which moves with twoStepEnable=true will be done in only one step (using the 'slow' step). Moves above that threshold will will be done in two steps. (This is only applicable when twoStepMoveEnable is true.)
    end   
    
    properties (SetAccess=private,Hidden)
        hLSC; % The LSC should not be accessed directly. Use lscSet, lscGet, lscFcn.
        lscErrPending = false; % If true, the LSC is in an error state. Callers must call recover() or reset()
         
        % general move state
        nonblockingMovePending; % we can probably get away without this since LSC has a corresponding flag. But there are slim edge cases in twostep moves where it might be safer to have our own flag. This is intended for polling by moveWaitForFinish only.
        nonblockingMoveStartTime; %time reference for start of nonblocking move

        % twostep configuration
        twoStepEnable = false; %Logical value indicating, if true, that large moveCompleteRelative() operations are done in two steps, with the second 'slow' step using one or more distinct properties (velocity, resolutionMode, moveMode) distinct from first step. 
        twoStepSlowPropVals = struct(); % P-Vs to be set on LSC for slow stage of two-step moves. Any position/velocity/acceleration values must be in LSC units.
        twoStepFastPropVals = struct(); % P-Vs to be set on LSC for fast stage of two-step moves. Any position/velocity/acceleration values must be in LSC units.
        
        % twostep move state
        twoStepMoveState = 'none'; % One of {'none' 'fast' 'slow'};
        twoStepPropertyCache; %Struct caching original values of twoStep properties. Used to restore original state of LSCB after two-step move.
        twoStepTargetPosn; % cache of target position for two-step move
        
    end
    
    properties (Hidden)
        debugMode = false; % set to true for verbose moves
    end
    
    properties (Constant)
        twoStepPropNames = {'moveMode' 'resolutionMode' 'velocity'}; %Note this order matters -- it's the order in which the properties will be get/set on cache/restore
        moveCompletePauseInterval = 0.05; %Time in seconds to give to pause() command for tight while loop used in waitForCompletedMove() method. Only applies if moveCompletedStrategy='isMovingPoll'.
    end
    
    %% HIDDEN PROPERTIES
    properties (Hidden,Dependent)
        analogCmdAvailable;
    end    

    
    %% EVENTS 
    events
        LSCError;
    end
    
    
%% PROPERTY ACCESS
    methods
        
        function v = get.analogCmdAvailable(obj)
            v = isa(obj.hLSC,'dabs.interfaces.LSCAnalogOption');
        end
        
        function v = get.analogCmdEnable(obj)
            if obj.analogCmdAvailable
                v = obj.lscGet('analogCmdEnable');
            else
                v = [];
            end
        end
        
        function set.analogCmdEnable(obj,v)
            assert(obj.analogCmdAvailable,'Property analogCmdEnable is not defined for objects of class ''%s''.',class(obj));            
            obj.lscSet('analogCmdEnable',v);
        end
        
        function set.debugMode(obj,val)
            validateattributes(val,{'numeric' 'logical'},{'scalar' 'binary'});
            obj.debugMode = val;
        end
        
        % throws (hardware)
        function v = get.positionRelative(obj)
            v = obj.lscGet('positionRelative');
        end
        
        % throws (hardware)
        function v = get.positionAbsolute(obj)
            v = obj.lscGet('positionAbsolute');
        end

        function v = get.moveTimeout(obj)
            v = obj.lscGet('moveTimeout');
        end
        
        function set.moveTimeout(obj,v)
            obj.lscSet('moveTimeout',v);
        end
        
        function v = get.resolution(obj)
            v = obj.lscGet('resolution');
        end
        
        function v = get.resolutionBest(obj)
            v = obj.lscGet('resolutionBest');
        end
        
        function v = get.relativeOrigin(obj)
            v = obj.lscGet('relativeOrigin');
        end
        
        function set.nonblockingMoveTimeout(obj,v)
            validateattributes(v,{'numeric'},{'scalar' 'positive'});
            obj.nonblockingMoveTimeout = v;
        end
        
        function set.twoStepDistanceThreshold(obj,v)
            validateattributes(v,{'numeric'},{'scalar' 'nonnegative'});
            obj.twoStepDistanceThreshold = v;
        end
                
        function set.twoStepEnable(obj,v)
            validateattributes(v,{'logical' 'numeric'},{'binary' 'scalar'});
            obj.twoStepEnable = v;
        end
        
        function set.twoStepSlowPropVals(obj,v)
            v = obj.zprpValidateTwoStepPropVals(v);
            obj.twoStepSlowPropVals = v;
        end
        
        function set.twoStepFastPropVals(obj,v)
            v = obj.zprpValidateTwoStepPropVals(v);
            obj.twoStepFastPropVals = v;
        end        
        
    end
    
    %Prop access helpers
    methods (Hidden)
        
        % Reorder the twoStepPropVals so they are in the order of
        % twoStepPropNames.
        function newv = zprpValidateTwoStepPropVals(obj,v)
            assert(isstruct(v) && all(ismember(fieldnames(v),obj.twoStepPropNames)));
            newv = struct();
            for f = scanimage.StageController.twoStepPropNames(:)'
                if isfield(v,f{1})
                    newv.(f{1}) = v.(f{1});
                end
            end
        end               
    end
    
%% CTOR/DTOR    

    methods
            
        function obj = StageController(lscObj,varargin)
            % obj = StageController(lscObj,p1,v1,...)
            % lscObj (REQUIRED): Concrete instance of LinearStageController
            % 
            % P-V options (see comments for corresponding properties):            
            % twoStepEnable (OPTIONAL)
            % twoStepDistanceThreshold (OPTIONAL)
            % twoStepSlowPropVals (OPTIONAL)
            % twoStepFastPropVals (OPTIONAL)
            
            assert(isa(lscObj,'dabs.interfaces.LinearStageController'),...
                'lscObj must be a LinearStageController object.');
            obj.hLSC = lscObj;

            ip = most.util.InputParser;
            ip.addParamValue('twoStepEnable',obj.twoStepEnable);
            ip.addParamValue('twoStepDistanceThreshold',obj.twoStepDistanceThreshold);
            ip.addParamValue('twoStepFastPropVals',obj.twoStepFastPropVals);
            ip.addParamValue('twoStepSlowPropVals',obj.twoStepSlowPropVals);
            ip.parse(varargin{:});
            
            props = ip.Results;
            assert(isequal(fieldnames(props.twoStepFastPropVals),...
                           fieldnames(props.twoStepSlowPropVals)),...
                   'Fast and slow twostep property names must match.');
            for c = fieldnames(props)'
                obj.(c{1}) = props.(c{1});
            end
            
            % Cache the two-step property values, as needed. Only need to
            % cache if properties differ from the "slow" prop vals.
            if obj.twoStepEnable
                slowPropVals = obj.twoStepSlowPropVals;
                fnames = fieldnames(slowPropVals);
                
                s = struct();               
                cacheTwoStepVals = false;
                                
                for c = 1:numel(fnames)
                    % Don't bother using lscGet here; if these gets fail,
                    % the LSC was never even initted
                    
                    s.(fnames{c}) = obj.hLSC.(fnames{c});
                    
                    if ~cacheTwoStepVals && ~isequal(s.(fnames{c}),slowPropVals.(fnames{c}))
                        cacheTwoStepVals = true;
                    end                                    
                end
                
                if cacheTwoStepVals
                    obj.twoStepPropertyCache = s;
                end                
            end
         
        end
        
        function delete(obj)
            if ~isempty(obj.hLSC)
                delete(obj.hLSC);
                obj.hLSC = [];
            end
        end
        
    end
            
%% USER METHODS    

    %Analog-option API
    methods
        function initializeAnalogOption(obj,varargin)
            assert(obj.analogCmdAvailable,'Stage controller of class ''%s'' does not support analog command option',class(obj));            
            obj.lscFcn('initializeAnalogOption',varargin{:});
        end
        
        function voltage = analogCmdPosn2Voltage(obj,posn)
            assert(obj.analogCmdAvailable,'Stage controller of class ''%s'' does not support analog command option',class(obj));
            voltage = obj.lscFcn('analogCmdPosn2Voltage',posn);
        end
    end
       
    % Zero API
    methods
        
        % throws (hardware)
        function zeroHard(obj,coords)
            obj.lscFcn('zeroHard',coords);
        end
        
        % throws (hardware)
        function zeroSoft(obj,coords)
            obj.lscFcn('zeroSoft',coords);
        end
        
        % throws (hardware)
        function recover(obj,varargin)
            obj.hLSC.recover(varargin{:});
            
            % For now, we assume that if recover goes through without
            % erroring, the error condition is removed.
            obj.lscErrPending = false;
        end
        
        % throws (hardware)
        function reset(obj,varargin)
            obj.hLSC.reset(varargin{:});
            
            % For now, we assume that if reset goes through without
            % erroring, the error condition is removed.
            obj.lscErrPending = false;
        end
    end
    
    % Move API
    methods
        
        % absPosn: absolute target position, in positionUnits.
        % throws (hardware)
        function moveCompleteAbsolute(obj,absPosn)
            moveType = obj.determineMoveType(absPosn);
            switch moveType
                case 'oneStep'
                    obj.oneStepMoveBlocking(absPosn);
                case 'twoStep'
                    obj.twoStepMoveBlocking(absPosn);
            end
        end
        
        % relPosn: relative target position, in positionUnits.
        % throws (hardware)
        function moveCompleteRelative(obj,relPosn)
            absPosn = obj.lscFcn('relativeToAbsoluteCoords',relPosn);
            obj.moveCompleteAbsolute(absPosn);
        end
        
        % incrementPosn: incremental target position, in positionUnits.
        % throws (hardware)
        function moveCompleteIncremental(obj,incrementPosn)
            pos = obj.positionAbsolute;
            assert(isequal(size(pos),size(incrementPosn)),...
                'incremental position has invalid size.');
            pos = pos + incrementPosn;
            obj.moveCompleteAbsolute(pos);
        end
        
        % Start a one-step move (nonblocking). You must follow up with
        % either moveWaitForFinish or moveInterrupt. absPosn: absolute
        % target position, in positionUnits.
        %
        % throws (hardware)
        function moveStartAbsolute(obj,absPosn)
            moveType = obj.determineMoveType(absPosn);
            switch moveType
                case 'oneStep'
                    obj.startOneStepMove(absPosn);
                case 'twoStep'
                    obj.startTwoStepMove(absPosn);
                otherwise
                    assert(false);
            end
            obj.nonblockingMovePending = true;
        end
        
        % Start a one-step move (nonblocking). You must follow up with
        % either moveWaitForFinish or moveInterrupt. relPosn: relative
        % target position, in positionUnits.
        %
        % throws (hardware)
        function moveStartRelative(obj,relPosn)
            absPosn = obj.lscFcn('relativeToAbsoluteCoords',relPosn);
            obj.moveStartAbsolute(absPosn);
        end
        
        % Start a one-step move (nonblocking). You must follow up with
        % either moveWaitForFinish or moveInterrupt. incrementPosn:
        % incremental target position, in positionUnits.
        %
        % throws (hardware)       
        function moveStartIncremental(obj,incrementPosn)
            pos = obj.positionAbsolute;
            assert(isequal(size(pos),size(incrementPosn)),...
                'incremental position has invalid size.');
            pos = pos + incrementPosn;
            obj.moveStartAbsolute(pos);            
        end
        
        % Wait for a nonblocking move to finish.
        % * If move is already complete, this returns immediately.
        % * Otherwise, returns as soon as move is complete, throwing an
        %   error if the time elapsed since the start of the move exceeds a
        %   timeout threshold. Note that this timeout refers to the total
        %   time of the move (start to finish), not the time spent waiting.
        function moveWaitForFinish(obj,timeout)
            if nargin < 2
                timeout = obj.nonblockingMoveTimeout;
            end
            
            % Note that if the move is already complete when this function
            % is entered, the timeout check will not apply. (Caller came
            % back too late and missed his own deadline.)
            
            if obj.hLSC.isMoving()            
                while obj.nonblockingMovePending
                    if toc(obj.nonblockingMoveStartTime) > timeout
                        obj.moveInterrupt();
                        error('scanimage:StageController:moveTimeOut',...
                            'Move failed to complete within specified period (%.2f) s',timeout);
                    end
                    most.idioms.pauseTight(obj.moveCompletePauseInterval);
                end
            end
        end

        % This interrupts even if there is no move pending.
        % xxx what if LSC concrete does not have interrupt?
        % throws (hardware)
        function moveInterrupt(obj)
%             if ~obj.nonblockingMovePending
%                 warning('scanimage:StageController:noMovePending',...
%                 'There is no move pending.');
%             end

            % We do not use lscFcn here although perhaps we should
            obj.hLSC.moveCancel(); % throws (hardware)
            
            % reset all move state
            obj.twoStepMoveFinish();
            obj.nonblockingMovePending = false;
            obj.nonblockingMoveStartTime = [];
        end
                
    end
    
%% HIDDEN METHODS    
    
    % Lower-level move methods
    methods (Hidden)        
            
        % Uses current settings on LSC. absTargetPosn: in positionUnits
        % (StageController units).
        %
        % throws (hardware)
        function oneStepMoveBlocking(obj,absTargetPosn)
            if obj.twoStepEnable
                obj.oneStepPrepare(); %Sets two-step properties to 'slow' vals
            end
            obj.lscFcn('moveCompleteAbsolute',absTargetPosn);
            obj.oneStepMoveFinish();
        end
        
        % throws (hardware). absTargetPosn: in positionUnits
        function twoStepMoveBlocking(obj,absTargetPosn)
            try
                obj.twoStepPrepareFastStep();
                obj.lscFcn('moveCompleteAbsolute',absTargetPosn);
                actualAbsPos = obj.positionAbsolute;
                if ~isequalwithequalnans(actualAbsPos,absTargetPosn) % veej wasn't sure he wanted this
                    obj.twoStepPrepareSlowStep();
                    obj.lscFcn('moveCompleteAbsolute',absTargetPosn);
                end
            catch ME
                obj.twoStepMoveFinish(); % could throw (oh well)
                ME.rethrow();
            end

            obj.twoStepMoveFinish(); % could throw (oh well)
        end
        
        % Uses current settings on LSC. absTargetPos: in positionUnits
        function startOneStepMove(obj,absTargetPos)
            if obj.twoStepEnable
                obj.oneStepPrepare(); %Sets two-step properties to 'slow' vals
            end
            obj.nonblockingMoveStartTime = tic;
            obj.lscFcn('moveStartAbsolute',absTargetPos,@obj.oneStepMoveFinish);
        end
        
        % absTargetPos: in positionUnits
        function startTwoStepMove(obj,absTargetPos)
            try
                obj.nonblockingMoveStartTime = tic;
                obj.twoStepPrepareFastStep(absTargetPos);
                obj.lscFcn('moveStartAbsolute',absTargetPos,@obj.twoStepCbk);
            catch ME
                obj.twoStepMoveFinish(); % could throw (oh well)
                ME.rethrow();
            end
        end
        
    end
    
    % Two-step move utilities
    methods (Hidden)
        
        % moveType: one of {'oneStep' 'twoStep'}. absTargetPosn: absolute
        % target position, in positionUnits
        %
        % throws (hardware)
        function moveType = determineMoveType(obj,absTargetPosn)
            if obj.twoStepEnable
                if isempty(obj.twoStepDistanceThreshold)
                    moveType = 'twoStep';
                else
                    absPos = obj.positionAbsolute;
                    activeDims = obj.lscGet('activeDimensions');
                    assert(all(isnan(absPos(~activeDims))));
                    distanceVec = absTargetPosn(activeDims) - absPos(activeDims);
                    distance = norm(distanceVec(~isnan(distanceVec)));
                    if distance < obj.twoStepDistanceThreshold
                        moveType = 'oneStep';
                    else
                        moveType = 'twoStep';
                    end
                end
            else
                moveType = 'oneStep';
            end
        end
        
        % * cache orig vals of all twostep props from LSC
        % * set twostep props on LSC to fast vals as appropriate
        % * cache twostep target posn (if passed in)
        % * set twoStepMoveState
        %
        % Can throw as it sets props on hLSC. If this happens, some
        % twostep properties may be modified on the LSC.
        %
        % absTargetPosnLSC: in positionUnits (StageController units)
        function twoStepPrepareFastStep(obj,absTargetPosn)
            if nargin < 2
                absTargetPosn = [];
            end
            
            assert(strcmp(obj.twoStepMoveState,'none'));
             
            fastPropVals = obj.twoStepFastPropVals;
            fnames = fieldnames(fastPropVals);
            
            %Set fast property values
            for c = 1:numel(fnames)
                fn = fnames{c};
                obj.lscSet(fn,fastPropVals.(fn)); % throws
            end
            
            obj.twoStepTargetPosn = absTargetPosn;
            obj.twoStepMoveState = 'fast';
            
            if obj.debugMode
                fprintf(1,'twoStepPrepareFast.\n');
                disp(fastPropVals);
            end
        end

        % * set twostep props to slow vals as appropriate
        %
        % Can throw as it sets props on hLSC. If this happens, the state of
        % twostep props on the LSC is indeterminate.
        function twoStepPrepareSlowStep(obj)
            assert(strcmp(obj.twoStepMoveState,'fast'));
            
            slowPropVals = obj.twoStepSlowPropVals;
            fnames = fieldnames(slowPropVals);
            for c = 1:numel(fnames)
                obj.lscSet(fnames{c},slowPropVals.(fnames{c})); % throws
            end
            
            obj.twoStepMoveState = 'slow';
            
            if obj.debugMode
                fprintf(1,'twoStepPrepareSlow.\n');
                disp(slowPropVals);
            end
        end
        
        function oneStepPrepare(obj)
            assert(obj.twoStepEnable);
            
            if ~isempty(obj.twoStepPropertyCache) %If cache is empty -- the prevailing values are assumed to be the slow values
                slowPropVals = obj.twoStepSlowPropVals;
                fnames = fieldnames(slowPropVals);
                for c = 1:numel(fnames)
                    obj.lscSet(fnames{c},slowPropVals.(fnames{c})); % throws
                end
            end
            
            if obj.debugMode
                fprintf(1,'oneStepPrepare.\n');
                disp(slowPropVals);
            end            
        end
        
        
        % * Sets all twostep props to orig vals in cache
        % * Resets all twostep move state
        %
        % Can throw as it sets props on hLSC. If this happens, the state of
        % twostep props on the LSC is indeterminate.
        function twoStepMoveFinish(obj)    
            obj.twoStepTargetPosn = [];
            obj.twoStepMoveState = 'none';
            obj.nonblockingMovePending = false;
            
            obj.zprvRestoreTwoStepProps();        
        end
        
        function oneStepMoveFinish(obj)
            obj.nonblockingMovePending = false;
            if obj.twoStepEnable
                obj.zprvRestoreTwoStepProps();
            end
        end
        
        function twoStepCbk(obj)
            switch obj.twoStepMoveState
                case 'fast'
                    absPos = obj.positionAbsolute;
                    targetPosn = obj.twoStepTargetPosn;
                    assert(~isempty(targetPosn));
                    if ~isequalwithequalnans(absPos,targetPosn) % throws (hardware); veej wasn't sure he wanted this
                        obj.twoStepPrepareSlowStep();
                        obj.lscFcn('moveStartAbsolute',targetPosn,@obj.twoStepCbk);
                    else
                        obj.twoStepMoveFinish();
                    end
                case 'slow'
                    obj.twoStepMoveFinish();
                otherwise
                    assert(false);
            end
        end  
        
        function zprvRestoreTwoStepProps(obj)
            s = obj.twoStepPropertyCache;            
            
            if ~isempty(s) %Could be empty -- if original values matched the 'slow' two-step property values
                fnames = fieldnames(s);
                for c = 1:numel(fnames)
                    obj.lscSet(fnames{c},s.(fnames{c})); % throws
                end
            end
            
        end
        
    end    

    % provide access to LSC.
    methods (Hidden)
        
        function lscSet(obj,propName,val)
            assert(~obj.lscErrPending,...
                'The motor has an error condition. Reset or recover before performing further action.');
            try
                obj.hLSC.(propName) = val;
            catch ME
                obj.lscErrPending = true;
                obj.notify('LSCError');
                ME.rethrow();
            end
        end
        
        function val = lscGet(obj,propName)
            assert(~obj.lscErrPending,...
                'The motor has an error condition. Reset or recover before performing further action.');
            try
                val = obj.hLSC.(propName);
            catch ME
                obj.lscErrPending = true;
                obj.notify('LSCError');
                ME.rethrow();
            end
        end
            
        function varargout = lscFcn(obj,fcnName,varargin)
            assert(~obj.lscErrPending,...
                'The motor has an error condition. Reset or recover before performing further action.');
            try
                [varargout{1:nargout}] = obj.hLSC.(fcnName)(varargin{:});
            catch ME
                obj.lscErrPending = true;
                obj.notify('LSCError');
                ME.rethrow();
            end
        end
        
    end
    
    methods (Static)
        
        function initLSC(hLSC,mtrDimSpec)
            % ScanImage-specific LSC initialization.
            % hLSC: handle to LSC
            % mtrDimSpec: One of {'xyz' 'xy' 'z'}
            
            assert(isscalar(hLSC) && isa(hLSC,'dabs.interfaces.LinearStageController'));
            assert(ischar(mtrDimSpec));
            
            numDevDims = hLSC.numDeviceDimensions;
            errmsg = sprintf('Invalid number of device dimensions (%d) for ''%s'' motor specification.',numDevDims,mtrDimSpec);
            switch mtrDimSpec
                case 'xyz'
                    assert(numDevDims==3,errmsg);
                    hLSC.lsc2DeviceDims = [1 2 3]; % should be LSC default anyway
                case 'xy'
                    assert(ismember(numDevDims,[2 3]),errmsg);
                    lsc2dd = nan(1,numDevDims);
                    lsc2dd(1:2) = [1 2];
                    hLSC.lsc2DeviceDims = lsc2dd; % should be LSC default anyway
                case 'z'
                    assert(ismember(numDevDims,[1 3]),errmsg);
                    lsc2dd = nan(1,numDevDims);
                    lsc2dd(end) = 3;
                    hLSC.lsc2DeviceDims = lsc2dd;
                otherwise
                    assert(false,'Unknown motor dimension spec');
            end
            
        end
        
    end
    
end
