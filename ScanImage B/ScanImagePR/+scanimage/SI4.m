classdef SI4 < most.Model & most.MachineDataFile
    %scanimage.SI4 Class encapsulating all ScanImage 4 capablities
    %
    % ScanImage 4 interfaces with a Thorlabs MPM-SCAN/KIT resonant scanner,
    % and additional controls (all optional) a Pockels Cell, 1 or 2 linear
    % stage controllers, a shutter, and a piezo controller
    
    
    %% ABSTRACT PROPERTY REALIZATIONS  (most.Model)
    properties (Hidden, SetAccess=protected)
        mdlPropAttributes = zlclInitPropAttributes();
        
        %OPTIONAL (Can leave empty)
        mdlHeaderExcludeProps = {'hMotor' 'hMotorZ' 'acqFrameBuffer' 'usrPropListCurrent'}; %String cell array of props to forcibly exclude from header
    end
    
    %% ABSTRACT PROPERTY REALIZATIONS (most.MachineDataFile)
    properties (Constant, Hidden)
        %Value-Required properties
        mdfClassName = mfilename('class');
        mdfHeading = 'ScanImage';
        
        %Value-Optional properties
        mdfDependsOnClasses = {'dabs.thorlabs.private.ThorDevice'};
        mdfDirectProp; %#ok<MCCPI>
        mdfPropPrefix; %#ok<MCCPI>
    end
    
    %% HIDDEN CONSTANTS
    properties (Constant, Hidden)
        channelsMaxNumber=4;
        
        pmtNumPMTs = 3;
        
        fastCfgNumConfigs = 6;
        
        %scanFramePeriodStoreKeyProps = {'scanMode' 'scanLinesPerFrame' 'scanZoomFactor' 'scanAngleMultiplierSlow'};
        triggerHeaderProps = {'triggerClockTimeFirst' 'triggerTime' 'triggerFrameStartTime' 'triggerFrameNumber'};
        scanParamCacheProps = {'scanZoomFactor' 'scanAngleMultiplierSlow'};
        
        % List of props that may/must be included in USR file
        usrAvailableUsrPropList = most.Model.getDefaultConfigProps('scanimage.SI4');
        versionPropNames =  {'versionMajor'; 'versionMinor'; 'versionPRNumber'}; %These props included in USR and CFG files, as well as file header data
        
        % List of props that are included in USR file by default
        usrPropListDefault = {...
            'triggerExtStartTrigTimeout';
            'focusDuration';
            'acqFrameBufferLengthMin';
            ...
            'fastCfgCfgFilenames';'fastCfgAutoStartTf';'fastCfgAutoStartType';
            'beamPzAdjust';'beamDirectMode';'beamLengthConstants';
            'stackUserOverrideLz';
            'userFunctionsUsr';
            'displayShowCrosshair';
            'channelsLUT';
            'channelsMergeColor';'channelsMergeEnable';'channelsMergeFocusOnly';
            'channelsReadOffsetsOnStartup';'channelsAutoReadOffsets';'channelsAutoReadOffsetsOnFocus';'channelsSubtractOffset'
            'scanParamCache';
            'pmtGain';'pmtEnable';
            'loggingFileCounterAutoReset';
            };
        
        userFunctionsEvents = zlclInitUserFunctionsEvents(); % column cellstr of events for user-functions.
        userFunctionsUsrOnlyEvents = zlclInitUserFunctionsUsrOnlyEvents(); % column cellstr of USR-specific events for user-functions
        userFunctionsOverrideFunctions = ...
            {'frameAcquiredFcn';'triggerFcn';'frameTrigCallback'};
        
    end
    
    %% PUBLIC PROPERTIES
    
    properties (Constant)
        versionMajor = 'B';
        versionMinor = '1.0';
        versionPRNumber = Inf; %Prerelease number. Integer value X specifies number of prerelease. Value of X.99 specifies version is between official prereleases. Value of X.N specifies this is attempt # N at the prerelease (shouldn't happen!). Value of Inf specifies that this is an official release (not a prerelease).
    end
    
    properties (SetObservable)
        
        motorscaleY = 1;
        motorscaleX = 1;
        ATduringFocusing = 0;
        ATnbslices = 5;
        ATzrange = 5;
        ATnbframes = 20;
        savedBitdepthX = 16;
        savedBitdepth = 0;
        write2RAM = 0;
        offlineAveraging = 0;
        
        triggerOut = false; 
        triggerOutDelay = 1; 
        triggerOutDuration = 5; 
        
        mergeAlign = false;
        mergeshift = 0;
        
        maxValueShow = 0;
        meanValueShow = 0;
        
        extClockLevel = 57; % used for external clock (laser clock) used as sample clock for the Alazar DAQ board
        extClockEdge = 0;
        
        showMeanLive = false;
        averagedStorage; % for saving averaged files
        framerate_user = 10; % for defining arbitrary scanrates (i.e. slower than at the speed limit)
        framerate_user_check = 0; % yes/no
        frameDecimationFactor = 1;
        lineScan_delay1 = 10; % delay before acquisition after line trigger from CRS in micro-seconds
        lineScan_delay2 = 1/8e3/2*1e6; % delay for bidirectional scan (similar to scan phase) in microseconds
        
        focusDuration = 270; %Time, in seconds, to acquire for FOCUS acquisitions. Value of inf implies to focus indefinitely.
        
        acqNumFrames = 1;
        acqNumAveragedFrames = 1; %Number of frames averaged before storage
        acqFrameBuffer = {}; %Cell array containing most recently acquired acqFrameBufferLength frames
        acqFrameBufferLengthMin = 2; %Minimum number of most-recently acquired frames to store in acqFrameBuffer
        
        %AL: view/display stuff can be broken out of SI4
        displayShowCrosshair = false; %If true, display crosshair overlay on image displays
        displayRollingAverageFactor = 1; %Number of frames averaged (using a simple moving average) for display purposes. Value must be greater or equal to acqNumAveragedFrames.
        displayRollingAverageFactorLock = false; %If true, lock acqNumAveragedFrames = displayRollingAverageFactor
        displayFrameBatchFactor = 1; %The number of frames to batch together for selective or tiled display
        displayFrameBatchSelection = 1; %The frame or frames to display within each frame batch
        displayFrameBatchSelectLast = true; %If true, lock displayFrameBatchFactor = displayFrameBatchSelection
        displayFrameBatchFactorLock = false; %If true, lock displayFrameBatchFacotr = displayRollingAverageFactor
        
        betweenFrames = true;
        beamFlybackBlanking = true; %Logical indicating whether to blank beam outside of fill fraction
        beamFillFracAdjust = 0; %Time, in microseconds, to 'pad' the fill fraction for ON modulation
        onTimeAdjust = 0; %Time, in microseconds ...
        timingAdjustPockels = 0; %Time, in microseconds ...
        beamPowers = 10; %Numeric array containing power values for each beam
        beamPowerLimits = 100; %Numeric array containing power limit for each beam
        beamLiveAdjust = true; %Logical indicating whether beamPowers can be adjusted during scanning. Doing so will disable flyback blanking, if enabled.
        beamDirectMode = false; %Logical indicating that power should be turned on and take effect immediately after all beamPowers adjustments
        beamPowerUnits = 'percent'; %One of {'percent', 'milliwatts'}
        beamPzAdjust = false; %Logical array indicating whether power/z adjustment is enabled for each beam
        beamLengthConstants = inf; %Numeric array containing length constant for each beam, to use for power adjustment during Z stacks
        
        galvoEnable = false; %Logical indicating whether to use ScanImage-controlled galvo(s) for Y or X/Y scan control (latter applies if galvoROIAngles are specified). Galvo scanners must be in series with hLSM  X/Y scanning module
        
        mroiParams = struct('scanShift',{},'scanAngleMultiplierSlow',{},'scanLinesPerFrame',{}); %Nx1 structure array specifying locations and scan parameter for N ROI multi-ROI scan
        mroiZoomFactor = 1; %Scalar zoom factor to apply for each of the N ROIs during multi-ROI imaging
        mroiPixelsPerLine = 512; %Scalar pixels-per-line value to use for each of the N ROIs during multi-ROI imaging
        mroiUpdateMinLines = 200; %Minimum number of lines in LSM frames specified for multi-ROI imaging. Multi-ROI sets will be grouped into each LSM frame as needed to meet this minimum.
        
        %         %Following refers to ScanImage style frame-averaging -- i.e. handled in the ScanImage frame processor
        %         %Any device/scanner-based frame-averaging should be a separate property (e.g. a pass-through property)
        %         frameAveragingEnable=false; %Single logical...maybe could be per-channel?
        %         frameAveragingNumFrames=inf; %Number of frames to average
        
        scanMode='unidirectional'; %One of {'unidirectional' 'bidirectional'}
        scanFOVAngularRangeFast=13.2; %Range, in optical degress, of FOV scan range, peak-peak. Sign determines direction of scan in fast dimension.
        scanFOVAngularRangeSlow=13.2; %Range, in optical degress, of FOV scan range, peak-peak. Sign determines direction of scan in slow dimension.
        scanAngleMultiplierFast=1; %TODO: Implement in relation to a scanAngleReferenceFast/Slow
        scanAngleMultiplierSlow=1; %TODO: Implement in relation to a scanAngleReferenceFast/Slow
        scanShiftFast=0; %Angular shift, in optical degrees, of scanned region in fast dimension
        scanShiftSlow=0; %Angular shift, in optical degrees, of scanned region in slow dimension
        
        scanZoomFactor=1; %Value of zoom, relative to scanFOVAngularRange value(s)
        scanPixelsPerLine=512;
        scanLinesPerFrame=512;
        xCorrChannel='Channel 1';
        scanForceSquarePixelation=true; % logical; if true, scanPixelsPerLine and scanLinesPerFrame are constrained to be equal
        scanForceSquarePixel=true; %logical; if true, pixelation ratio is locked equal to scan angle multiplier ratio, to maintain square pixel aspect ratio
        scanFillFraction=0.66; %<Range 0..1> Specifies fraction of line period during which acquisition occurs
        
        delayedChannelsOn = false;
        nbDelayedChannels = 'Two_channels';
        
        scanParamCache; % Cache for 'Base' value of ROI scan parameters (scanZoomFactor, scanAngleMultiplier, scanOffset, scanRotation). TODO: Ultimately may want this Hidden or protected in some way -- fully public for now for usrFile handling
        
        stackNumSlices=1; %Specifies number of slices, for either traditional stack collection or fastZ volume collection
        stackZStepSize=1; %distance in microns
        stackUseStartPower=false;
        stackUserOverrideLz=false; % logical; if true, override beam Lz values using stackZStart/EndPos, stackStart/EndPower.
        stackReturnHome=true; % if true, motor returns to original z-position after stack
        stackStartCentered=false; % if true, the current z-position is considered the stack center rather than the stack beginning. Applies to Main::Grab only.
        
        %AL: view/display stuff can be broken out of SI4
        %channelsActive=1; %Array of channel indices which are active
        channelsDisplay2 = [1 2 3]; % workaround
        channelsSave = [1 2 3]; % analogy workaround
        channelsInvert = [1 2 3];
        channelsDisplay=[1 2 3]; %Array of channel indices to be displayed % TODO public setting of this prop is currently not supported
%         channelsSave=1; %Array of channel indices to be saved
        channelsInputRange; %Cell array of 2-element arrays
        channelsLUT; %An Nx2 array of min/max values for channel display, one for each of the N channels
        channelsMergeColor = {'green' 'red' 'gray' 'none'}; %String cell array of color names, one of {'red' 'green' blue' 'gray' 'none'}.
        channelsMergeEnable = false; %Scalar logical. If true, the channels merge window is updated.
        channelsMergeFocusOnly = false; %Scalar logical. If true, the channels merge image is not updated during GRAB/LOOP acquisitions.
        channelsSubtractOffset = false; %Logical array of N elements, indicating whether offset value should be subtracted from acquired data that is saved and/or displayed, for each of the N channels
        channelsAutoReadOffsets = false; %Logical. If true, channel offsets are automatically read, updating channelsOffset property, prior to each GRAB/LOOP acquisition.
        channelsAutoReadOffsetsOnFocus = false; %Logical. If true, channelAutoReadOffsets setting applies also to FOCUS acquisitions.
        channelsReadOffsetsOnStartup = false; %Logical. If true, channel offsets are read on ScanImage startup. Useful for typical cases where channel offsets do not drift/vary during an experimental session.
        
        loggingEnable=false;
        loggingFramesPerFile=inf; %Number of frames to store per file
        loggingFramesPerFileLock=false; %Constrain loggingFramePerFile to equal acqNumFrames -- this is typical/useful for collecting a single file per slice
        loggingMaxFileSize; %TODO: allow spec of frames/file in terms of filesize, rather than directly as frames/file
        autoconvert=true;
        focusSave=false;
        autoscaleSavedImages=false;
        
        triggerExtTrigEnable = false; %<Logical> Indicates whether external start and/or next triggering (as configured by other properties) should be used
        triggerExtStartTrigPreScan = true; %<Logical> Indicates, if true, that scanning should be started before external trigger arrives to minimize trigger-to-acquisition latency.
        triggerExtStartTrigTimeout = 30; %Time, in seconds, to wait for external trigger before timing out
        %TODO: Add parameter indicating how long to disable scanning for after acquistions for Looped external triggered acqs...i.e. a hint as to when external trigger will arrive
        
        triggerStartTrigSrc; %Numeric value of PFI source, if any, to use for external start triggering
        triggerStartTrigEdge = 'rising'; %One of {'rising' 'falling'}
        triggerNextTrigSrc; %Numeric value of PFI source, if any, to regard as 'next' trigger
        triggerNextTrigEdge = 'rising'; %One of {'rising' 'falling'}
        triggerNextTrigMode = 'advance'; %One of {'advance' 'arm'}
        %triggerNextTrigAdvanceGap; %<Logical> Indicates, if true and in 'advance' next trigger mode, to advance by stopping acquisition and re-triggering via internal trigger
        triggerMaxLoopInterval = 42.95; %One of {42.95 214.75 42950}. Specifies maximum time, in seconds, to allow between start/next triggers during LOOP acquisitions. Longer intervals result in lower resolution trigger timestamp measurements.
        triggerMaxLoopIntervalFrames = 10000; %Specifies maximum number of frames to allow between start/next triggers during LOOP acquisition. Shorter duration of triggerMaxLoopInterval & triggerMaxLoopIntervalFrames pertains.
        
        userFunctionsCfg = struct('EventName',cell(0,1),'UserFcnName',cell(0,1),'Arguments',cell(0,1),'Enable',cell(0,1)); % Nx1 struct array of CFG user function info structs.
        userFunctionsUsr = struct('EventName',cell(0,1),'UserFcnName',cell(0,1),'Arguments',cell(0,1),'Enable',cell(0,1)); % Mx1 struct array of USR user function info structs.
        userFunctionsOverride = struct('Function',cell(0,1),'UserFcnName',cell(0,1),'Enable',cell(0,1)); % Px1 struct array of user override functions
        
        fastZEnable = false; %If true, FastZ controller is used for any stack acquisitions
        exec_after = false; % if true, execute zero-finding algorithm after acquisition
        offset_directly  = false; % if true, do not use feedback, but set offset voltage for VC directly
        pockelsZ  = false;
        pockelsZoffset  = 0;
        topbias = 0;
        leftbias = 0;
        fastZImageType = 'XY-Z'; %One of {'XY-Z' 'XZ' 'XZ-Y'}
        fastZScanType = 'sawtooth'; %One of {'step' 'sawtooth'}
        fastz_step_nbplanes = 2; % fast voice coil z-scanning
        fastz_step_stepsize = 0.1; % fast voice coil z-scanning
        fastz_step_settlingtime = 30; % fast voice coil z-scanning
        fastz_cont_nbplanes = 3; % fast voice coil z-scanning
        fastz_cont_amplitude = 0.2; % fast voice coil z-scanning
        fastZSettlingTime = 0; %Time, in seconds, for axial position/ramp to settle. If fastZScanType='step', this value may be an array containing settling-time values to use for each step -- on per element in fastZScanRangeSpec.
        fastZNumVolumes = 1; %Number of 'volumes' to collect, i.e. number of times to repeat the fastZ scan. fastZNumVolumes=1 implies 'fast stack' operation.
        fastZDiscardFlybackFrames = false; %Logical indicating whether to discard frames during fastZ scanner flyback
        fastZUseAOControl = true; %Logical indicating whether to use AO control of fastZ hardware during FastZ operations
        fastZFramePeriodAdjustment = -100; %Time, in us, to deduct from the nominal frame period, when determining fastZ sawtooth period used for volume imaging
        fastZAllowLiveBeamAdjust = false; %Logical indicating whether to allow live adjustment of beamPowers during fastZ imaging.
        
        highVal = 0; % high value for fast scanning (speed)
        lowVal = 0; % %% now: number of frames before shutter opens
        dutyCycleZ = 10.0; % duty cycle for fast scanning
        zero_pos_Z = 3.3; % zero position (hall sensor) signal, in V
        current_pos_Z = 3.3; % position (hall sensor) signal, in V
        
        oct15_offset_voltage = 0; % output, in V
        oct15_target_pos = 3.5; % from Hall sensor, in V
        oct15_mode = 1; % 1 = target position, 0 = set offset directly
        
        fastCfgCfgFilenames = repmat({''},scanimage.SI4.fastCfgNumConfigs,1);
        fastCfgAutoStartTf = false(scanimage.SI4.fastCfgNumConfigs,1);
        fastCfgAutoStartType = cell(scanimage.SI4.fastCfgNumConfigs,1);
        
        shutterDelay = 0; %Numeric scalar or array indicating time(s), in milliseconds, to delay opening of shutter(s) from start of acquistion. Value of 0 means to open before acquisition starts.
        
        loopNumRepeats=inf; %Scalar integer specifying number of LOOP Repeats to execute when LOOP button is pressed
        loopRepeatPeriod=10;
        
        motorSecondMotorZEnable = false; % scalar logical. If true, use second motor for stack z-movement. This flag is only interesting when motorDimensionConfiguration is 'xyz-z'. (For other motorDimensionConfigurations, the value of this flag is constrained to a single value.)
        
        pmtGain; %Vector of PMT gain values
        pmtEnable; %Vector of logicals indicating enabled/disabled state of PMTs
        
        maxFrameEventRate = 65; %Maximum rate, in Hz, at which SI4 will process frames for its operations. At higher rates, frames will be decimated from display and other operations.
        
        %Other USR-subset Options
        loggingFileCounterAutoReset=true; %Logical. If true, loggingFileCounter reset to 1 on change of loggingFileStem.
    end
    
    
    properties (SetObservable, Transient)
        loggingFilePath='';
        loggingFileStem='';
        loggingFileCounter=1;
        
        motorMoveTimeout = 5; %Maximum time, in seconds, to allow for stage moves. %TODO: Ideally could anticipate
        motorFastMotionThreshold = 100; %Distance, in um, above which motion will use the 'fast' velocity for controller
        motorUserDefinedPositions = cell(0,1); % Col vec of user-defined motor positions (which are 1x3 vecs)
        
        scanPhaseMap; %Map of scanPhase values, keyed by scanZoomFactor value. Property maintained as memory cache of underlying the file CDF var.
        scanPhaseFineMap; %Map of maps of scanPhaseFine values. Primary map keyed by hLSM.fieldSize. Secondary map keyed by hLSM.pixelsPerLine. Values are 2-vectors containing scanPhaseFine values for 1 channel & multi-channel acquisiton cases.
        scanMinZoomFactor=1; %Minimum value of scanZoomFactor to allow
        
        stackZStartPos=nan; %z-position from Motor::stack panel; does NOT apply to all acqs. This position is _relative to hMotor's relative origin_. It is _not_ in absolute coords.
        stackZEndPos=nan; %z-position from Motor::stack panel; does NOT apply to all acqs. This position is _relative to hMotor's relative origin_. It is _not_ in absolute coords.
        stackStartPower=nan; % beam-indexed
        stackEndPower=nan; % beam-indexed
        
        usrPropListCurrent = scanimage.SI4.usrPropListDefault;
        
    end
    
    properties (Dependent,SetObservable)
        fastZAcquisitionDelay; %Acquisition delay, in seconds, of fastZScanner. Value is exactly 1/2 the fastZSettlingTime.
        
        scanPhase; %Integer in range (0..254) specifying phase of scan at current scanZoomFactor. Correct value eliminates 1) every-other-line misalignment (for bidirectional scanning) and 2) field-of-view scaling errors (when not bidirectional scanning).
        scanPhaseFine; %Integer in range (-128..127) adding fine-control of scanPhase value at current value of (scanZoomFactor,scanPixelsPerLine,hLSM.numChannelsActive)
        
        motorPosition; % 1x3 or 1x4 array specifying motor position (in microns), depending on single vs dual motor, and motorDimensionConfiguration.
        
        galvoAngle2LSMAngleFactor; %Scalar specifying ratio (scaling factor) of SI4 Y galvo max angular range to LSM Y galvo max angular range
    end
    
    properties (Dependent,AbortSet,SetObservable)
        % replaced by frameDecimationFactor, PR2014-08-27
        frameAcqFcnDecimationFactor = 1; %Integer N indicating that only every Nth frame is processed in Matlab in SI4, e.g. reducing display rate, etc.
    end
    
    %Read-only Properties
    
    %Following are technically settable to allow use of DependsOn property metatdata. Setter throws error..
    properties (Dependent,SetObservable)
        scanLinePeriod; %Period, in s, of each scanner line. Depends on scanner frequency and whether bidirectional scanning is used.
        scanFramePeriod; %Estimated frame period, in seconds, with current acquisition settings
        scanFrameRate = 20; %Estimated frame rate, in Hz, with current acquisition settings
        scanFillFractionSpatial; %Spatial fill fraction at current scanFillFraction setting
        scanPixelTimeMean; %Mean time spent dwelling at each pixel, during each line
        scanPixelTimeMaxMinRatio %Ratio of max-to-min time spent dwelling at each pixel across the line scan
        
        fastZNumDiscardFrames; %Number of discarded frames for each period
        
        mroiEnabled; %Logical; if true, multi-ROI scanning enabled for GRAB/LOOP acquisitions (requires galvoEnable=true & mroiParams non-empty)
        
    end
    
    properties (SetAccess=protected, SetObservable)
        acqState='idle'; %One of {'idle' 'focus' 'grab' 'loop' 'loop_wait' 'point'}
        acqFramesDone = 0; %Number of frames already acquired in current slice of current GRAB acquisition or LOOP repeat
        
        channelsOffset; %Nx1 array, where N=channelsNumChannels. Contains digitizer/PMT offset value last measured for each channel.
        
        scanFramesStarted = 0; %Count of frame triggers received, based on the NI frame period counter Task, during an uninterrupted acquisition interval (i.e. between zprvStartFocus/zprvStartAcquisitionSlice() and zprvStopAcquisition()).
        
        stackSlicesDone = 0; %Number of slices acquired in current GRAB acquisition or LOOP repeat
        
        secondsCounter = 0; %current countdown or countup time, in seconds
        
        loopRepeatsDone=0;
        
        fastZPeriod; %Time specification in seconds. Co-varies with stackNumSlices/stackZStepSize. For fastZScanType='sawtooth', specifies period of scan in fastZ dimension. For fastZScanType='step', specifieds time or times (if supplied as vector) to spend at each step (i.e. value per element in fastZScanRangeSpec).;
        fastZFillFraction; %Fraction of frames in acquisition stream during fastZ imaging
        fastZVolumesDone = 0; %Number of volume sweeps completed, during a fastZ scan
    end
    
    properties (SetAccess=protected, Transient, SetObservable)
        cfgFilename = '';
        statusString; % Set this property to update the current SI4 status
    end
    
    properties (SetAccess=protected)
        triggerClockTimeFirst; %Time of first trigger of current acquisition (first Repeat in case of LOOP). For slice acquisitions, only trigger time for first slice is recorded.
        triggerTime; %Last time at which triggers arrived during GRAB or LOOP, relative to first triggerFrameStartTime. For slice acquisitions, only trigger time for first slice is recorded.
        triggerFrameStartTime; %Last time at which triggered acquisition actually started during GRAB or LOOP , relative to first triggerFrameStartTime. First entry is always time 0. For slice cquisitions, only trigger time for first slice is recorded.
        triggerFrameNumber; %First frame acquired in currently logged file (if any). Value is updated at each start or next trigger.
    end
    
    properties (SetAccess=protected, Dependent, SetObservable)
        acqFrameBufferLength; %Length of running buffer used to store most-recently acquired frames
    end
    
    properties (SetAccess=protected, Dependent)
        motorHasMotor; % true if there is a motor
        motorHasSecondMotor; % true if there is a secondary motor. cannot be true if motorHasMotor is false
        
        fastZActive; %true if fastZ scanning is ongoing
        
        channelsDataType; %One of {'int16' 'uint16'}, depending on whether signed data is being used
        
        triggerTimestampResolution; %Resolution, in seconds, of triggerTime(s) property values containing start/next trigger timestamps. Determined by triggerMaxLoopInterval.
    end
    
    
    
    
    
    %% HIDDEN PROPERTIES
    
    properties (Hidden)
        nostatereport = 0;
        ATrefImage = [];
        ATactive = 0;
        BIG_FILE = [];
        savingYes = 0;
        multiChanAVG = 0; % for imaging using delayed acquisition in multiple channels (currently using ch 1 and 3 or 1-4 for values of 2 and 4
        
        overshoot = 0; % counts in grab/slices mode the number of frames that are scanned and written to the buffer, but not used for the current slice
        droppedFrames = 0;
        acqFramesDoneTotally = 0;
        galvoOffset = 0;
        frameCounter; %PR2014
        scanphases = cell(255,1);
        temp_image; % PR2014
        captureDone; % PR2014
        acqDebug=false; % logical scalar. Set to true for some verbosity during acq.
        beamVoltageRanges; %Nbeam x 1 numeric. Maximum voltage for each beam.
        
        %Set of logical flags indicating whether to include tests for
        %reliability/correctness during SI4 operation
        verifyOptions = struct( 'nextTrigCheckFrameBreaks',false,... %Check next trigger frame breaks at end of acquisition to see if file boundaries match up as expected
            'nextTrigAbortOnDroppedFrames',true ... %Abort Loop next-triggered acquisition if dropped frames detected on an acquisition
            );
        
    end
    
    %Fudge-factors
    properties (Hidden)
        beamCalibrationLUTSize = 1e3; % number of steps in calibration LUT
        beamCalibrationNumVoltageSteps = 100; % number of beam voltage steps to use (during beam calibration)
        beamCalibrationNumPasses = 5; % number of voltage sweeps to perform
        beamCalibrationIntercalibrationZeros = 4; % number of zero voltage samples to apply between calibration sweeps
        beamCalibrationOutputRate = 1e5; % output sample rate of beam/beamCal tasks during calibration
        beamCalibrationIntercalibrationPauseTime = 0.2; % (seconds) pause time between calibration sweeps
        beamCalibrationOffsetNumSamples = 1e4; % Number of samples to take when measuring calibration offset
        beamCalibrationNoisyOffsetThreshold = 0.15; % Warning thrown if stddev/mean > (this ratio) while measuring photodiode offset
        beamCalibrationFluctuationThreshold = 0.35; % (dimensionless) warn if the std_dev/max of the beamCal signal exceeds this threshold
        beamCalibrationMinThreshold = 0.15; % (dimensionless) warn if min/max of the beamCal signal exceeds this threshold
        
        scanFramePeriodMeasureTime = 2; %Duration, in seconds, of test scan used to measure frame period values at given scan configuration settings
        
        stackShutterCloseMinZStepSize = 0; %Minimum stackZStepSize, in um, above which shutter will be closed, i.e. to allow for move to complete. For smaller moves, shutter will remain open during stack motor step - i.e. rely on Pockels blanking to limit illumination.
        
        loggingDelay = 0.2; %Time, in seconds, by which to delay logging. This serves to allow next triggering and frames-per-file file rollover operations to work.
    end
    
    %Constructor-initialized
    properties (Hidden,SetAccess=protected)
        % Consider using events instead of initState prop
        initState; % string enum. One of {'construct','init','none'}. initState is 'construct' during construction and 'init' during initialization and 'none' otherwise.
        
        triggerOutputTask;
        
        beamNumBeams;
        fastZAvailable = false; %Logical indicating if fastZ hardware is available
        galvosAvailable = 0; %Integer indicating if 0, 1 (Y), or 2 (X/Y) galvos are available (in series with resonant scanner)
        
        %hInitTimestampCtr; %C
        hFrameClockDelayCtr;  %CI chan measuring edge separation between trigger signals and subsequent frame clock edge
        hTriggerPeriodCtr; %CI chan measuring period between trigger signals
        hFramePeriodCtr; %CI chan measuring period between frame clock signals (and counts the numer of frames) since last start trigger
        hTriggerCallbackCtr;  %CI chan used to generate callback on start/next trigger edges
        xTrigCallback;
        
        hSelfTrig; %DO chan used to self-trigger ScanImage acquisitions/loops
        
        hBeams; %Array of AO Tasks for beam modulation (e.g. with a Pockels cell)
        hBeamsPark; %Same as hBeams -- separate Task used for static power control adjustments
        hBeamCals; %Array of AI Tasks for beam modulation calibratin (e.g. with photodiodes)
        
        hShutters; %Array of shutter DO Tasks
        hTimestampCounters; %Array of counter CI Tasks used for timestamp measurements which run continuously during acquisition mode (presently: hFrameClockDelayCtr & obj.hTriggerPeriodCtr)
        
        hGalvos; %AO Task controlling single Y galvo or X/Y galvos, in series with hLSM resonant scanning module
        hGalvosPark; %Same as hGalvos -- separate non-buffered Task used for parking galvos at center or outside the field-of-view
        
        hMotor; % Warning: It is dangerous to directly zero or modify the relative coordinate system on the motor. This will break stackZStart/EndPos. See motorZeroSoft().
        hMotorZ; % etc.
        
        hFastZ; %Handle to FastZ hardware, may be a LSC object or a PI motion controller
        hFastZAO; %Handle to DAQmx AO Task used for FastZ sweep/step control
        
        hAcqTasks; %Array of all started Tasks during a GRAB acquisition or LOOP repeat -- or slice of either. All of these should be stopped after each such acquisition/Repeat/slice
        hAllTasks; %Array of all (non-transient) DAQmx Tasks created by this class
        
        motorDimensionConfiguration; % one of {'none' 'xy' 'z' 'xyz'} when there is a single motor; one of {'xy-z' 'xyz-z'} when there are two motors
        
        loggingFrameDelay; %Conversion of loggingDelay into num frame units
    end
    
    %Handles
    properties (Hidden,SetAccess=protected)
        hLSM; %Handle to Thor LSM resonant scanning module (X/Y scanner with resonant X scan)
        hPMT; %Handle to PMT controller object
        
        channelsHFig=[];
        channelsHAxes={};
        channelsHImage={};
        
        channelsHMergeFig = [];
        channelsHMergeAx = [];
        channelsHMergeIm = [];
    end
    
    %Internal properties
    properties (Hidden,SetAccess=protected)
        
        acqFramesDoneTotal=0; %Tally of total frames acquired since last start trigger (including trigger of last slice if a stack acquisition).  Value is determined by simply counting executions of frameAcquiredFcn() callback. In fastZmode, value may differ from acqFramesDone.
        
        displayRollingBuffer; %Array used for display averaging computation. Stored as double type.
        
        acqBeamLengthConstants; %Beam power length constants for use in actual acquistion; can differ from beamLengthConstants due to stackOverrideLz, etc
        acqMotorPositionStackStart; %Motor position at last start of stack
        stackCurrentMotorZPos; %z-position of stackZMotor
        
        acqBeamPowersStackStart; %Beam powers at last start of stack
        
        beamFlybackBlankData; %Array of beam output data for each scanner period for flyback blanking mode. Array has one column for each beam.
        beamFlybackBlankDataMask; %Mask representation of beamFlybackBlankData, with 1 values representing beam ON and NaN representing beam OFF.
        beamCalibrationLUT; %beamCalibrationLUTSize x numBeams array. lut(i,j) gives the beam voltage necessary to achieve the fraction (i/beamCalibrationLUTSize) of the maximum beam power for beam j.
        beamCalibrationMinCalVoltage; %1 x numBeams array. Gives the minimum beam calibration voltage encountered during calibration for each beam.
        beamCalibrationMaxCalVoltage; %1 x numBeams array. Gives the maximum beam calibration voltage encountered during calibration for each beam.
        beamCalibrationMinAchievablePowerFrac; % 1 x numBeams array. Gives the minimum achievable power fraction for each beam
        beamCancelCalibration = false; %Logical set/polled if user cancels during beam calibration.
        beamPowersNominal; %Last-set values of beamPowers, which may be at higher precision than calibration-constrained beamPowers value
        
        %cfgPropSetLastLoaded; at moment this is unused; it may be unnecessary
        cfgOneShotLoaded; % scalar logical; if true, a one-shot cfg has been loaded and an acq has not been run
        cfgOneShotRevertPropSet; % if a one-shot config is currently loaded, this contains the struct (propSet) with the original values of all affected props. if there is no one-shot config loaded, this is []
        
        fastZRequireAO = false;
        fastZAODataNormalized; %Array of output data for fastZAO Task, corresponding to one volume period
        fastZAODataSlope; %Slope of fastZAO data during command ramp
        fastZHomePosition; %Cache of the fastZ controller's position at start of acquisition mode, which should be restored at conclusion of acquisition mode
        fastZNextTrigSignal; %Flag signaling that advancing next trigger occurred during fastZ volume imaging -- file & file counter should be updated at start of next volume
        fastZBeamDataBuf; %Buffer of fastZ beam data, maintained if fastZAllowLiveBeamAdjust=true
        
        fastZBeamPowersCache; %Cache of beamPowers data, maintained if fastZAllowLiveBeamAdjust=true
        fastZBeamWriteOffset; %Store the offset to next write to FastZ Beam AO Task
        fastZBeamNumBufferedVolumes = 1; %Number of volumes to buffer. Any changes to beam params will take places with latency of (fastZBeamNumBufferedVolumes-1) volumes
        %fastZAORange; %2 element array containining [min max] voltage values allowed for FastZ AO control
        
        galvoAODataBuf1D; %Buffer of 1D galvo AO data, in optical angles, to be used for FOCUS and single-ROI GRAB/LOOP acqs
        galvoAODataBuf2D; %Buffer of 2D galvo AO data, in optical angles, to be used for multi-ROI GRAB/LOOP acqs
        
        mroiComputedParams = struct('transitNumLines',{},'dispTiling',{},'dispTilingLinesPerRow',{});
        %transitNumLines: Array of integers specifying number of LSM scan lines required to transit to each ROI in currently specified mroiParams property
        %dispTiling: Array [numRows,numCols] specifying tiling for multi-ROI display figures
        %dispTilingLinesPerRow: Array specifying # lines per row in tiled multi-ROI display figures
        
        scanZoomFactorFOV = 1;
        scanPhaseLookupFlag = false;
        scanPhaseSetFlag = false;
        scanPhaseFineSetFlag = false;
        scanSetPixelationPropFlag = false;
        
        stackLastStartEndPositionSet = nan; % Cache of last position set to stackZStartPos/stackZEndPos. Used to throw warning re: running stack with possibly stale start/end pos.
        
        triggerNextTrigOnly; %Indicates if using 'pure' next triggering
        triggerExtTrigTimer; %Timer object handle used to handle external trigger timeouts
        triggerStartTrigTerminal; %Terminal on which start trigger for current acquisition is received.
        
        triggerClockTimeFirstVec; %Date vector representation of time of first trigger of current acquisition (first Repeat in case of LOOP). For slice acquisitions, only trigger time for first slice is recorded. For stack acquisitions, only trigger time for first slice is recorded.
        triggerTimeLast; % Tic value encoding the last trigger time, very  nearly equivalent to: (triggerTimes(end)-triggerTimes(1)) + triggerClockTimeFirst
        triggerTimes; %Time(s) at which triggers arrived during GRAB or LOOP (array value when LOOP), relative to first triggerFrameStartTime. For stack acquisitions, only trigger time for first slice is recorded.
        triggerFrameStartTimes; %Time(s) at which triggered acquisition(s) actually started during GRAB or LOOP (array value when LOOP), relative to first triggerFrameStartTime. First entry is always time 0. For slice acquisitions, only trigger time for first slice is recorded.
        triggerLastArmed; %One of {'start' 'next' 'self'}
        
        userFunctionsCfgListeners; % Column cell array containing listener objects for user functions (CFG). There is a 1-1 correspondence between these objects and the elements of userFunctionsCfg.
        userFunctionsUsrListeners; % Column cell array containing listener objects for user functiosn (USR). There is a 1-1 correspondence between these objects and the elements of userFunctionsUsr.
        userFunctionsOverriddenFcns2UserFcns; % Scalar struct. Fields: currently overridden fcns. vals: user fcns to call instead.
        
        usrPropSetLastLoaded;
        
        loggingFrameCount; %Number of frames started since start of log file. Value determined by counting frame clock ticks recorded by the Frame Period counter channel.
        %loggingFrameTimeReference; %Reference time, for frame period measurements
        loggingFrameTimeLast; %Last recorded frame time, relative to start of first frame
        loggingFrameBreaks; %Array of frame count values identifying start frame for each of the next-triggered files
        %loggingFrameStartTimes; %Time(s) at which frame clocks have arrived since last start trigger
        
        loggingFileSubCounter; %Specifies /next/ file sub-counter to be written to when a finite loggingFramesPerFile is specified, 'chunking' a single acquisition's data into multiple files, e.g. to limit filesize
        
        hListeners; %structure of listeners maintained by this class
        
        headerStringCache = '';
        
        internalSetFlag = false;
        
    end
    
    properties (Hidden,SetAccess=protected,SetObservable)
        scannerPeriodStore; %Store for measured scanner period values
        triggerExtTrigAvailable; %Logical indicating if external triggering capability is availble given current start/next trigger source settings
        usrFilename = '';
    end
    
    properties (Hidden,SetAccess=protected,Dependent)
        acqNumFramesPerTrigger; %Total number of frames to acquire per acquistion trigger (a GRAB acquisition or LOOP repeat, or slice collected within either)
        
        stackZMotor; %handle to motor user for stack z-positioning during acq
        
        beamOnPowerVoltages; %Beam-indexed voltage levels corresponding to power fraction percentages in beamPowers
        beamOffPowerVoltages; %Beam-indexed voltage levels corresponding to minimum achievable beam power fractions
        
        channelsInputRangeValues;  %Nx2 array, with each row representing an allowable range value (2-element arrays, specifying min-max)
        channelsBitDepth;
        channelsNumChannels; %Number of available channels
        channelsLUTRange; %2 element array specifying min-max values allowed for channelsLUT
        
        %         fastZScanStartPositionVolts;
        %         fastZScanRangeSpecVolts;
        
        headerString; %Concatenates headerStringCache with the triggerHeaderProps
        
        fastZNumFramesPerVolume; %Number of frames per volume for current acq & fastZ settings
        
        scannerPeriod; %Last measured scanPeriod, at currently specified scanZoomFactor. Extracted from scannerPeriodStore
        scannerPeriodNearestSmaller; %Nearest smaller scannerPeriod at nearest larger zoom factor with measured scanPeriod. Extracted from scannerPeriodStore.

        scanPeriodsPerFrame; %Number of LSM scanner periods per frame, accounting for scanner periods added for slow/galvo scanner flyback
        scanLinePeriodNominal; %Nominal value of scanLinePeriod, to be sometimes used when scanLinePeriod=NaN
        scanLinePeriodNearestSmaller; %scanLinePeriod val at nearest larger scanZoomFactor, i.e. the nearest smaller scanLinePeriod

        stackStartEndPointsDefined; % logical; if true, stackZStartPos, stackZEndPos are defined (non-nan)
        stackStartEndPowersDefined; % logical; if true, stackZStartPower, stackZEndPower are defined
        
        loggingFullFileName;
        loggingFileName;
        loggingFileNumChunks; %Integer scalar; either 0 (not-chunked) or 2 or greater (chunked)
        
        motorPositionLength; %Length of motorPosition values
        
        mroiLinesPerSet;
        mroiLinesPerLSMFrame;
        mroiSetsPerLSMFrame;
        
        secondsCounterMode; %One of {'up' 'down'} indicating whether this is a count-up or count-down timer
        
        triggerExtStartTrigUsed; %logical; if true, an external start trigger is to be used (is configured and available) on GRAB/LOOP acquisitions
        triggerNextTrigUsed;
        
        usrCfgFileVarName; % varName stored in a USR file for cfg file associated with that USR file
        
    end
    
    %DependsOn properties
    properties (Hidden,Dependent,SetObservable)
        displayShowCrosshairTrue; %Logical indicating if crosshair display is actually active
        scanPixelTimeStats; %Structure of computed pixel dwell time statistics
        scanForceSquarePixel_; %Logical indication if scanForceSquarePixel constraint is in effect
        scanForceSquarePixelation_; %Logical indication if scanForceSquarePixelation constraint is in effect
    end
    
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = SI4()
            
            obj.initState = 'construct';
            obj.statusString = 'Initializing...';
            
            %Initialize & validate CDF
            initValStruct.lastConfigFilePath = most.idioms.startPath();
            initValStruct.lastFastConfigFilePath = most.idioms.startPath();
            initValStruct.scanPhaseStore = containers.Map('KeyType','int32','ValueType','double');
            initValStruct.scanPhaseFineStore = containers.Map('KeyType','double','ValueType','any');
            %initValStruct.scanFramePeriodStore = cell(1,length(obj.scanFramePeriodStoreKeyProps)+1);
            initValStruct.scannerPeriodStore = containers.Map('KeyType','double','ValueType','double');
            
            obj.ensureClassDataFile(initValStruct);
            
            %             if size(obj.getClassDataVar('scanFramePeriodStore'),2) ~= length(obj.scanFramePeriodStoreKeyProps) + 1
            %                 znstResetClassDataVar('scanFramePeriodStore');
            %             end
            
            %             function znstResetClassDataVar(classDataVar)
            %                 obj.setClassDataVar(classDataVar,initValStruct.(classDataVar))
            %             end 
            
            %Initializations
            obj.ziniPrepareLSM(); %Initialize Thor LSM hardware that is required
            obj.ziniPrepareDisplayFigs();
            
            obj.ziniPrepareCoreDAQ(); %Initialize DAQ hardware that is required
            obj.ziniPrepareShutters(); %Initialize optional Shutter hardware
            obj.ziniPrepareBeams(); %Initialize optional hardware for 'beam' modulation (e.g. Pockels), including calibration (e.g. with photodiode)
            obj.ziniPrepareChannels(); %Initialize channel-related properties
            obj.ziniPrepareMotor(); %Initialize optional motor hardware for X/Y/Z motion
            obj.ziniPrepareFastZ(); %Initialize optional fastZ hardware for fast Z motion
            obj.ziniPrepareGalvos(); %Initialize optional control of Y or X/Y galvo scanner(s)in series with LSM scan module
            
            obj.ziniPreparePMT(); %Initialize optional PMT control/monitoring
            
            obj.set_scanphases(); % initialize cell with the two scan phase parameters for each field size; PR2014-08-20
            
            obj.zprvResetTriggerTimes(); %Initializes trigger-time properties
            
            obj.initState = 'none';
            
        end
        
        function initialize(obj)
            obj.initState = 'init';
            
            try
                % register all channel figs with controller
                assert(numel(obj.hController) <= 1); % for now always have a single controller
                if ~isempty(obj.hController)
                    ctrler = obj.hController{1};
                    for c = 1:obj.channelsNumChannels
                        ctrler.registerGUI(obj.channelsHFig(c));
                    end
                    ctrler.registerGUI(obj.channelsHMergeFig);
                end
                
                %Load user file (which adjusts figure positions)
                obj.usrLoadUsr();
                
                %Initialize model, which also calls initialize() on any/all controller(s)
                initialize@most.Model(obj);
                
                %Read channel offsets
                if isprop(obj,'channelsReadOffsetsOnStartup') && obj.channelsReadOffsetsOnStartup
                    btn = questdlg('Read input channel offsets now or later? Input signals should be connected exactly as they will be during imaging - e.g., PMT on with gain set to value used during imaging.','Read Channel Offsets','Now','Later','Now');
                    if strcmpi(btn,'now')
                        obj.channelsReadOffsets();
                    end
                end
                
                obj.initState = 'none';
                obj.statusString = '';
                obj.notify('applicationOpen');
            catch ME
                fprintf(2,'ERROR encountered initializing ''%s'' object. Deleting object. Error information: \n%s\n',class(obj),ME.getReport('basic'));
                delete(obj);
            end
        end
        
        function delete(obj)
            
            %Signal SI close
            obj.notify('applicationWillClose');
             
            %TMW: I don't believe this should be needed -- but somehow these resources aren't automatically deleted when the SI4 is deleted...can't see any other handles to this object to explain this
            obj.hLSM.clearDAQ(); % PR2014
            
            delete(obj.hLSM);
            delete(obj.hAllTasks);
            delete(obj.channelsHFig);
            delete(obj.channelsHMergeFig);
            delete(333333);
        end
        
    end
    
    methods (Hidden, Access=private)
        
        function set_scanphases(obj)
            for ii = 1:numel(obj.scanphases)
                obj.scanphases{ii} = [ii 5.65 62.5]; % dummy values, will be overwritten by cfg file
            end
        end
        
        function zprvMDFScalarExpand(obj,mdfVarName,N)
            if isscalar(obj.mdfData.(mdfVarName))
                obj.mdfData.(mdfVarName) = repmat(obj.mdfData.(mdfVarName),N,1);
            end
        end
        
        function zprvMDFVerify(obj,mdfVarName,validAttribArgs,assertFcn)
            val = obj.mdfData.(mdfVarName);
            try
                if ~isempty(validAttribArgs)
                    validateattributes(val,validAttribArgs{:});
                end
                if ~isempty(assertFcn)
                    assert(assertFcn(val));
                end
            catch ME
                error('SI4:MDFVerify','Invalid value for MachineDataFile variable ''%s''.',mdfVarName);
            end
        end
        
        
        function ziniPrepareDisplayFigs(obj)
            %Initialize channel figure windows
            %startImageData = zeros(obj.scanLinesPerFrame,obj.scanPixelsPerLine,obj.channelsDataType);

            for i=1:obj.channelsNumChannels
                obj.channelsHFig(i) = most.idioms.figureSquare('Name',sprintf('Channel %d',i),...
                    'Visible','off','ColorMap',gray(256),'NumberTitle','off','Menubar','none',...
                    'Tag',sprintf('image_channel%d',i),'CloseRequestFcn',@(src,evnt)set(src,'Visible','off'));
            end
            obj.channelsHMergeFig = most.idioms.figureSquare('Name','Channel Merge',...
                'Visible','off','NumberTitle','off','Menubar','none',...
                'Tag','channel_merge','CloseRequestFcn',@(src,evnt)set(src,'Visible','off'));
            
%            channelsLUTInitVal = repmat([0 obj.channelsLUTRange(2)],obj.channelsNumChannels,1); %Use unipolar LUT range by default, whether data is signed or not
             channelsLUTInitVal = repmat([0 obj.channelsLUTRange(2)],3,1); %Use unipolar LUT range by default, whether data is signed or not
            obj.zprvResetDisplayFigs(1:obj.channelsNumChannels,true,channelsLUTInitVal);
        end
        
        function ziniPrepareLSM(obj)
            obj.hLSM = scanimage.adapters.ThorLSM();

            obj.handParamsToLSM_MDF();
            
            obj.hLSM.initializeHardware();
            
            obj.hLSM.restartOnParamChange = false;
%             obj.hLSM.frameAcquiredEventFcn = @(varargin)obj.zprvOverrideableFunction('frameAcquiredFcn',varargin{:});
            obj.hLSM.circBufferSize = 16;
            obj.hLSM.averagingMode = 'AVG_NONE';
            obj.hLSM.areaMode = 'RECTANGLE';
            
            obj.hLSM.scanZoomFactor = obj.scanZoomFactor;
            obj.hLSM.scannerMaxAngularRange = obj.mdfData.scannerMaxAngularRange;
            obj.hLSM.scanAngleMultiplierSlow = obj.scanAngleMultiplierSlow;
            obj.hLSM.galvoAngle2VoltageFactor = obj.mdfData.galvoAngle2VoltageFactor;
            obj.hLSM.crsAngle2VoltageFactor = obj.mdfData.crsAngle2VoltageFactor;
            obj.hLSM.beamCmdOutputRate = obj.mdfData.beamCmdOutputRate;
            
            obj.hLSM.fastzDevice = obj.mdfData.fastzDevice;
            obj.hLSM.fastzAOChannel = obj.mdfData.fastzAOChannel;
            obj.hLSM.fastzAOPockels = obj.mdfData.fastzAOPockels;
            obj.hLSM.fastzAIHallSensor = obj.mdfData.fastzAIHallSensor;
            
            obj.handParamsToLSM();
            
            
            
            lsmInvert = (isfield(obj.mdfData,'lsmDigitizerInvert') && obj.mdfData.lsmDigitizerInvert) || ...
                (isfield(obj.mdfData,'lsmDigitizerPositive') && ~obj.mdfData.lsmDigitizerPositive);
            if lsmInvert
                obj.hLSM.dataMappingMode = 'POLARITY_NEGATIVE';
            else
                obj.hLSM.dataMappingMode = 'POLARITY_POSITIVE';
            end
            
        end
        
        function ziniDisableShutterFeature(obj)
            if ~isempty(obj.hShutters)
                delete(obj.hShutters);
            end
            obj.hShutters = dabs.ni.daqmx.Task.empty();
        end
        
        function ziniPrepareShutters(obj)
            
            import dabs.ni.daqmx.*
            
            try
                tfShutterFeatureOn = ~isempty(obj.mdfData.shutterDeviceIDs) && ...
                    ~isempty(obj.mdfData.shutterPortIDs) && ...
                    ~isempty(obj.mdfData.shutterLineIDs);
                if ~tfShutterFeatureOn
                    obj.ziniDisableShutterFeature();
                    fprintf(1,'Disabling shutter feature...\n');
                    return;
                end
                
                % shutterLineIDs
                obj.zprvMDFVerify('shutterLineIDs',{{'numeric'},{'integer' 'vector' 'nonnegative'}},[]);
                numShutters = length(obj.mdfData.shutterLineIDs);
                
                % shutterDeviceIDs
                if ischar(obj.mdfData.shutterDeviceIDs)
                    obj.mdfData.shutterDeviceIDs = cellstr(obj.mdfData.shutterDeviceIDs);
                end
                obj.zprvMDFScalarExpand('shutterDeviceIDs',numShutters);
                obj.zprvMDFVerify('shutterDeviceIDs',{},@(x)iscellstr(x)&&numel(x)==numShutters&&all(cellfun(@(y)~isempty(y),x)));
                
                % shutterPortIDs
                obj.zprvMDFScalarExpand('shutterPortIDs',numShutters);
                obj.zprvMDFVerify('shutterPortIDs',{{'numeric'},{'integer' 'vector' 'nonnegative'}},@(x)numel(x)==numShutters);
                
                % shutterOpenLevel
                obj.zprvMDFScalarExpand('shutterOpenLevel',numShutters);
                obj.zprvMDFVerify('shutterOpenLevel',{{'numeric' 'logical'},{'binary' 'vector'}},@(x)numel(x)==numShutters);
                
                % shutterBeforeEOM
                obj.zprvMDFVerify('shutterBeforeEOM',{{'numeric' 'logical'},{'binary' 'scalar'}},[]);
                
                % shutterIDs
                if isempty(obj.mdfData.shutterIDs)
                    obj.mdfData.shutterIDs = arrayfun(@num2str,(1:numShutters)','UniformOutput',false);
                end
                obj.zprvMDFVerify('shutterIDs',{},@(x)iscellstr(x)&&numel(x)==numShutters);
                
                %Create shutter Tasks
                obj.hShutters = Task.empty();
                for i=1:numShutters
                    idString = obj.mdfData.shutterIDs{i};
                    hShutter = obj.zprvDaqmxTask(sprintf('Shutter %s',idString));
                    hShutter.createDOChan(obj.mdfData.shutterDeviceIDs{i},sprintf('port%d/line%d',obj.mdfData.shutterPortIDs(i),obj.mdfData.shutterLineIDs(i)));
                    hShutter.writeDigitalData(double(~obj.mdfData.shutterOpenLevel(i))); %Close shutter
                    obj.hShutters(end+1) = hShutter;
                end
                
            catch ME
                obj.ziniDisableShutterFeature();
                fprintf(2,'Error occurred during shutter initialization. Incorrect MachineDataFile settings likely cause. \n Disabling shutter feature. \n Error stack: \n');
                most.idioms.reportError(ME);
                %throwAsCaller(obj.DException('','InitShuttersErr',' Error stack: \n   %s',ME.getReport()));
            end
            
        end
        
        function ziniPrepareCoreDAQ(obj)
            %Initialization for required ScanImage hardware
            
            import dabs.ni.daqmx.*
            
            %Initialize 'self' trigger
            obj.zprvMDFVerify('trigSelfTrigSourceDeviceID',{{'char'},{'nonempty'}},[]);
            obj.zprvMDFVerify('trigSelfTrigSourceLineID',{{'numeric'},{'scalar' 'integer'}},[]);
            obj.hSelfTrig = obj.zprvDaqmxTask('Self Trigger');
            obj.hSelfTrig.createDOChan(obj.mdfData.trigSelfTrigSourceDeviceID,sprintf('line%d',obj.mdfData.trigSelfTrigSourceLineID));
            
            %Initialize 'initial timestamp' counter
            %                 obj.hInitTimestampCtr = obj.zprvDaqmxTask('Initial Timestamp Counter');
            %                 obj.hInitTimestampCtr.createCOPulseChanFreq(obj.primaryDeviceID,0,[],1e3); %Uses ctr0
            %                 obj.hInitTimestampCtr.cfgSampClkTiming(10e6,'DAQmx_Val_ContSamps',[],'10MHzRefClock'); %assumes X series board
            
            obj.zprvMDFVerify('primaryDeviceID',{{'char'},{'nonempty'}},[]);
            obj.zprvMDFVerify('extFrameClockTerminal',{{'numeric'},{'scalar' 'integer' 'nonnegative' '<=' 16}},[]);
            
            %Initialize 'Frame Clock Delay' counter -- measures delay between trigger and next external frame clock
            obj.hFrameClockDelayCtr = obj.zprvDaqmxTask('Frame Clock Delay Counter');
            obj.hFrameClockDelayCtr.createCITwoEdgeSepChan(obj.mdfData.primaryDeviceID,0); %Uses ctr0
            obj.hFrameClockDelayCtr.cfgImplicitTiming('DAQmx_Val_ContSamps');
            obj.hFrameClockDelayCtr.channels(1).set('twoEdgeSepSecondTerm',...
                sprintf('PFI%d',obj.mdfData.extFrameClockTerminal)); %Set frame clock source as the 'second edge'; assumes rising edge
            
            %Initialize 'Trigger Period' counter -- measures period between triggers (start triggers or next triggers)
            obj.hTriggerPeriodCtr = obj.zprvDaqmxTask('Trigger Period Counter');
            obj.hTriggerPeriodCtr.createCIPeriodChan(obj.mdfData.primaryDeviceID,1); %Uses ctr1
            obj.hTriggerPeriodCtr.cfgImplicitTiming('DAQmx_Val_ContSamps');
            
            %Initialize 'Frame Clock Period' counter -- measures all times between frame clock ticks since start of acquisition mode
            obj.hFramePeriodCtr = obj.zprvDaqmxTask('Frame Clock Period Counter');
            obj.hFramePeriodCtr.createCIPeriodChan(obj.mdfData.primaryDeviceID,2); %Uses ctr2
            obj.hFramePeriodCtr.cfgImplicitTiming('DAQmx_Val_ContSamps');
            obj.hFramePeriodCtr.channels(1).set('periodTerm',...
                sprintf('PFI%d',obj.mdfData.extFrameClockTerminal)); %Set frame clock source as the period source; assumes rising edge
            
            %Initialize 'Trigger Callback' counter -- used to invoke callback function on each start or next trigger input
            %Best (only?) way to do this with a counter/timer appears to be with a 'count edges' CI chan, which uses sample clock timing unlike other CI/CO chan types
            obj.hTriggerCallbackCtr = obj.zprvDaqmxTask('Trigger Callback Counter');
            obj.hTriggerCallbackCtr.createCICountEdgesChan(obj.mdfData.primaryDeviceID,3); %Uses ctr3
            obj.hTriggerCallbackCtr.cfgSampClkTiming(1000, 'DAQmx_Val_HWTimedSinglePoint', [], 'PFI0'); %Sample rate is 'dummy' value. Trigger terminal is a temp value, to be overwritten.
            obj.hTriggerCallbackCtr.registerSignalEvent(@(varargin)obj.zprvOverrideableFunction('triggerFcn',varargin{:}),'DAQmx_Val_SampleClock');
            
            %Initialize 'Trigger Callback' counter -- used to invoke callback function on each start or next trigger input
            %Best (only?) way to do this with a counter/timer appears to be with a 'count edges' CI chan, which uses sample clock timing unlike other CI/CO chan types
            obj.xTrigCallback = obj.zprvDaqmxTask('Trigger Callback Counter 2');
            obj.xTrigCallback.createCICountEdgesChan(obj.mdfData.scanDevice,obj.mdfData.xTrigCtr); %Uses ctr3
            obj.xTrigCallback.cfgSampClkTiming(1000, 'DAQmx_Val_HWTimedSinglePoint', [], 'PFI0'); %Sample rate is 'dummy' value. Trigger terminal is a temp value, to be overwritten.
            obj.xTrigCallback.registerSignalEvent(@(varargin)obj.zprvOverrideableFunction('xTriggerFcn',varargin{:}),'DAQmx_Val_SampleClock');
            
            %obj.hTimestampCounters = [obj.hInitTimestampCtr obj.hFrameClockDelayCtr obj.hTriggerPeriodCtr];
            obj.hTimestampCounters = [obj.hFrameClockDelayCtr obj.hTriggerPeriodCtr];
        end
        
        
        function ziniDisableBeamsFeature(obj)
            obj.beamNumBeams = 0;
            if ~isempty(obj.hBeams)
                delete(obj.hBeams);
            end
            obj.hBeams = dabs.ni.daqmx.Task.empty();
            for i=1:length(obj.hBeamCals)
                if ~isempty(obj.hBeamCals{i})
                    delete(obj.hBeamCals{i});
                end
            end
            obj.hBeamCals = {};
            if ~isempty(obj.hBeamsPark)
                delete(obj.hBeamsPark);
            end
            obj.hBeamsPark = [];
        end
        
        function ziniPrepareBeams(obj)
            import dabs.ni.daqmx.*
            try
                tfBeamsFeatureOn = ~isempty(obj.mdfData.beamDeviceID) && ...
                    ~isempty(obj.mdfData.beamChanIDs);
                if ~tfBeamsFeatureOn
                    obj.ziniDisableBeamsFeature();
                    fprintf(1,'Disabling beams feature...\n');
                    return;
                end
                
                % beamChanIDs
                obj.zprvMDFVerify('beamChanIDs',{{'numeric'},{'integer' 'vector' 'nonnegative'}},[]);
                numBeams = length(obj.mdfData.beamChanIDs);
                obj.beamNumBeams = numBeams;
                
                if numBeams==0
                    return;
                end
                
                % beamDeviceID
                if ischar(obj.mdfData.beamDeviceID)
                    obj.mdfData.beamDeviceID = cellstr(obj.mdfData.beamDeviceID);
                end
                obj.zprvMDFScalarExpand('beamDeviceID',numBeams);
                obj.zprvMDFVerify('beamDeviceID',{},@(x)iscellstr(x)&&numel(x)==numBeams&&all(cellfun(@(y)~isempty(y),x)))
                
                % beamIDs
                if isempty(obj.mdfData.beamIDs)
                    obj.mdfData.beamIDs = arrayfun(@(x)sprintf('Beam %d',x),(1:numBeams)','UniformOutput',false);
                end
                obj.zprvMDFVerify('beamIDs',{},@(x)iscellstr(x)&&numel(x)==numBeams);
                
                % beamVoltageRanges
                obj.zprvMDFScalarExpand('beamVoltageRanges',numBeams);
                obj.zprvMDFVerify('beamVoltageRanges',{{'numeric'},{'real' 'vector' '>=' 0.0}},@(x)numel(x)==numBeams);
                
                % beamCmdOutputRate
                obj.zprvMDFVerify('beamCmdOutputRate',{{'numeric'},{'real' 'scalar'}},[]);
                
                % beamCalInputDeviceIDs
                if ischar(obj.mdfData.beamCalInputDeviceIDs)
                    obj.mdfData.beamCalInputDeviceIDs = cellstr(obj.mdfData.beamCalInputDeviceIDs);
                end
                obj.zprvMDFScalarExpand('beamCalInputDeviceIDs',numBeams);
                obj.zprvMDFVerify('beamCalInputDeviceIDs',{},@(x)iscellstr(x)&&numel(x)==numBeams);
                % beamCalInputDeviceIDs{i} can be empty if beamCalInputChanIDs(i) is nan
                
                % beamCalInputChanIDs
                if isempty(obj.mdfData.beamCalInputChanIDs)
                    obj.mdfData.beamCalInputChanIDs = nan(numBeams,1);
                end
                obj.zprvMDFScalarExpand('beamCalInputChanIDs',numBeams);
                obj.zprvMDFVerify('beamCalInputChanIDs',{{'numeric'},{'vector'}},@(x)numel(x)==numBeams);
                
                % beamCalOffsets
                if isempty(obj.mdfData.beamCalOffsets)
                    obj.mdfData.beamCalOffsets = zeros(numBeams,1);
                end
                obj.zprvMDFVerify('beamCalOffsets',{{'numeric'},{'vector'}},@(x)numel(x)==numBeams);
                
                %%% Initialize model props
                obj.beamVoltageRanges = obj.mdfData.beamVoltageRanges;
                obj.beamCalibrationLUT = nan(obj.beamCalibrationLUTSize,obj.beamNumBeams);
                obj.beamCalibrationMinCalVoltage = nan(1,obj.beamNumBeams);
                obj.beamCalibrationMaxCalVoltage = nan(1,obj.beamNumBeams);
                obj.beamCalibrationMinAchievablePowerFrac = zeros(1,obj.beamNumBeams);
                
                %%% Create Beam/BeamCal/BeamPark Tasks
                obj.hBeams = obj.zprvDaqmxTask('Beam Modulation');
                obj.hBeamCals = cell(obj.beamNumBeams,1);
                obj.hBeamsPark = obj.zprvDaqmxTask('Beam Modulation Park');
                
                for i=1:obj.beamNumBeams
                    idString = obj.mdfData.beamIDs{i};
                    
                    %Create AO chan for beam 'parking' (static AO control)
                    obj.hBeamsPark.createAOVoltageChan(obj.mdfData.beamDeviceID{i},obj.mdfData.beamChanIDs(i),sprintf('%s Park',idString));
                    
                    %Create AO chans for beam
                    obj.hBeams.createAOVoltageChan(obj.mdfData.beamDeviceID{i},obj.mdfData.beamChanIDs(i),idString);
                    
                    %Create AI Task/chan for each beam's calibration
                    beamCalChanID = obj.mdfData.beamCalInputChanIDs(i);
                    if isnan(beamCalChanID)
                        hBeamCal = [];
                    else
                        hBeamCal = obj.zprvDaqmxTask([idString ' Calibration']);
                        hBeamCal.createAIVoltageChan(obj.mdfData.beamCalInputDeviceIDs{i},beamCalChanID);
                        hBeamCal.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.mdfData.trigSelfTrigDestinationTerminal));
                        hBeamCal.set('readReadAllAvailSamp',1); %Paradoxically, this is required for X series AI Tasks to correctly switch between finite acquisitions of varying duration
                    end
                    
                    obj.hBeamCals{i} = hBeamCal;
                end
                
                % Configure Beam modulation Task
                obj.hBeams.set('startTrigRetriggerable',true,'digEdgeStartTrigDigFltrMinPulseWidth',200e-9,'digEdgeStartTrigDigFltrEnable',1);
%                 obj.hBeams.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.mdfData.extLineClockTerminal));
                obj.hBeams.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.mdfData.iLineClockReceive),'DAQmx_Val_Falling');

                obj.hBeams.cfgSampClkTiming(obj.mdfData.beamCmdOutputRate,'DAQmx_Val_FiniteSamps'); %Configure sample clock timing so pause trigger can be configuerd
                
                % PR2014-08-21 this is an interesting gating construct ...
                if obj.betweenFrames
                    obj.hBeams.set('pauseTrigType','DAQmx_Val_DigLvl','digLvlPauseTrigWhen','DAQmx_Val_Low','digLvlPauseTrigSrc',sprintf('PFI%d',obj.mdfData.extFrameClockTerminal));
                else
                    obj.hBeams.set('pauseTrigType','DAQmx_Val_None'); %Disable pause-triggering - there is no slow-mirror flyback to be blanked out
                end
                %  obj.hBeams.set('pauseTrigType','DAQmx_Val_DigPattern','digLvlPauseTrigSrc',[sprintf('PFI%d',obj.mdfData.extLineClockTerminal) sprintf('PFI%d',obj.mdfData.extFrameClockTerminal)]);
                
                % Perform initial calibrations
                for c = 1:obj.beamNumBeams
                    obj.beamsCalibrate(c);
                end
                
            catch ME
                fprintf(2,'Error occurred while initializing ''beams''. Incorrect MachineDataFile settings likely cause. \n Disabling beams feature. \n Error stack: \n');
                most.idioms.reportError(ME);
                obj.ziniDisableBeamsFeature();
            end
        end
        
        function ziniPrepareChannels(obj)
            obj.channelsOffset = nan(obj.channelsNumChannels,1);
            
            %Remainder of properties should be expanded to channelsNumChannels dimensions during initialize() eigensets
        end
        
        function ziniPrepareGalvos(obj)
            obj.galvosAvailable =  length(obj.mdfData.galvoChanIDs) * ~isempty(obj.mdfData.galvoDeviceID);
            if ~obj.galvosAvailable
                return;
            end
            
            try
                obj.zprvMDFVerify('galvoAngle2VoltageFactor',{{'numeric'},{'vector' 'finite' 'positive'}},[]);
                obj.zprvMDFVerify('galvoParkAngles',{{'numeric'},{'vector' 'finite'}},[]);
                
                obj.zprvMDFScalarExpand('galvoParkAngles',obj.galvosAvailable);
                
                obj.hGalvos = obj.zprvDaqmxTask('Galvo Control Task');
                obj.hGalvos.createAOVoltageChan(obj.mdfData.galvoDeviceID,obj.mdfData.galvoChanIDs);
                
                obj.hGalvos.cfgSampClkTiming(obj.mdfData.galvoCmdOutputRate,'DAQmx_Val_FiniteSamps',2);
                obj.hGalvos.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.mdfData.extFrameClockTerminal));
                obj.hGalvos.set('startTrigRetriggerable',1);
                
                obj.hGalvosPark = obj.zprvDaqmxTask('Galvo Control Park Task');
                obj.hGalvosPark.createAOVoltageChan(obj.mdfData.galvoDeviceID,obj.mdfData.galvoChanIDs);
                
                %Enable galvo control by default (if available)
                obj.galvoEnable = true;
                
            catch ME
                fprintf(2,'Error occurred while initializing galvo hardware. Incorrect MachineDataFile settings likely cause. \n Disabling motor feature. \n Error stack: \n  %s \n',ME.getReport());
                
                obj.galvosAvailable = 0;
                
                if ~isempty(obj.hGalvos)
                    delete(obj.hGalvos);
                end
                obj.hGalvos = [];
            end
            
        end
        
        function ziniPrepareFastZ(obj)
            
            obj.fastZAvailable = ~isempty(obj.mdfData.fastZControllerType);
            if ~obj.fastZAvailable
                return;
            end
            
            useMotor2 = false;
            try
                
                %Construct & initialize fastZ object in hardware-specific manner
                if strcmpi(obj.mdfData.fastZControllerType,'useMotor2');
                    useMotor2 = true;
                    
                    controllerType = obj.mdfData.motor2ControllerType;
                    assert(~isempty(controllerType),'FastZ motor controller was configured as ''useMotor2'', but no secondary Z motor was actually specified.');
                    assert(~isempty(obj.hMotorZ),'FastZ motor controller was configured as ''useMotor2'', but secondary Z motor was not successfully configured.');
                    
                    comPort = obj.mdfData.motor2COMPort;
                    baudRate = obj.mdfData.motor2BaudRate;
                else
                    controllerType = obj.mdfData.fastZControllerType;
                    comPort = obj.mdfData.fastZCOMPort;
                    baudRate = obj.mdfData.fastZBaudRate;
                end
                
                if useMotor2
                    obj.hFastZ = obj.hMotorZ;
                end
                
                %Initialize fastZ AO object, if specified & not done so already
                if ~isempty(obj.mdfData.fastZAOChanID) && isempty(obj.hFastZAO)
                    znstInitFastZAO();
                end
                
                switch lower(controllerType)
                    
                    %Handle analog control settings, as needed for particular controllers
                    case {'pi.e816' 'pi.e665' 'npoint.lc40x'} 
                        
                        %Require AO Task be used for FastZ, where available
                        znstRequireFastZAO();
                        
                        %TODO: Make ctor call logic programmatic, based on controllerType string
                        analogCmdArgs = {};
                        if ~useMotor2
                            hLSC = dabs.pi.LinearStageController('controllerType','e816','comPort',comPort,'baudRate',baudRate,analogCmdArgs{:});
                            obj.hFastZ = scanimage.StageController(hLSC);
                        end
                        
                        %Initialize analog command option
                        args = {'analogCmdBoardID', obj.hFastZAO.deviceNames{1},'analogCmdChanIDs',obj.mdfData.fastZAOChanID,'hAOBuffered',obj.hFastZAO};
                        if ~isempty(obj.mdfData.fastZAIChanID) && ~isempty(obj.mdfData.fastZAIDeviceID)
                            args = [args {'analogSensorBoardID' obj.mdfData.fastZAIDeviceID 'analogSensorChanIDs' obj.mdfData.fastZAIChanID}];
                        end
                        obj.hFastZ.initializeAnalogOption(args{:});
                        
                        %Set analog-controllable LSC to use analog mode
                        obj.hFastZ.analogCmdEnable = true;
                        
                    otherwise
                        assert(false,'FastZ controller type specified (''%s'') is unrecognized or presently unsupported',controllerType);
                        
                end
                
                
                %                 %If in all-analog mode, forcibly start FastZ in middle of range
                %                 if obj.hFastZ.analogCmdEnable
                %                     obj.hFastZ.moveToCenter();
                %                 end
                
                
            catch ME
                fprintf(2,'Error occurred while initializing fastZ hardware. Incorrect MachineDataFile settings likely cause. \n Disabling motor feature. \n Error stack: \n  %s \n',ME.getReport());
                
                obj.fastZAvailable = false;
                
                if ~isempty(obj.hFastZ) && ~useMotor2
                    delete(obj.hFastZ);
                end
                
                obj.hFastZ = [];
            end
            
            function znstRequireFastZAO()
                if isempty(obj.mdfData.fastZAOChanID)
                    throwAsCaller(MException('','Analog Output (AO) Task required for specified FastZ hardware type (''%s'')',obj.mdfData.fastZControllerType));
                end
                
                %znstInitFastZAO();
                obj.fastZRequireAO = true;
                obj.fastZUseAOControl = true;
            end
            
            function znstInitFastZAO()
                obj.zprvMDFVerify('fastZAODeviceID',{{'char'},{'nonempty'}},[]);
                obj.zprvMDFVerify('fastZAOChanID',{{'numeric'},{'integer' 'scalar'}},[]);
                obj.zprvMDFVerify('fastZCmdOutputRate',{{'numeric'},{'scalar' 'positive'}},[]);
                
                obj.hFastZAO = obj.zprvDaqmxTask('FastZ AO');
                obj.hFastZAO.createAOVoltageChan(obj.mdfData.fastZAODeviceID,obj.mdfData.fastZAOChanID);
                
                obj.hFastZAO.cfgSampClkTiming(obj.mdfData.fastZCmdOutputRate, 'DAQmx_Val_FiniteSamps');
                obj.hFastZAO.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.mdfData.extFrameClockTerminal));
                obj.hFastZAO.set('startTrigRetriggerable',true);
                
                %                 hChan = obj.hFastZAO.channels(1);
                %                 obj.fastZAORange = [hChan.get('min') hChan.get('max')];
                
                
                %Start AO Task in middle of scanner range
                %                 rMin = obj.hFastZ.hStage.get('rangeLimitMin');
                %                 rMax = obj.hFastZ.hStage.get('rangeLimitMax');
                %
                %                 obj.hFastZAOPark.writeAnalogData(obj.zprvFastZPosn2Voltage(rMin+(rMax-rMin)/2));
                
            end
            
        end
        
        function ziniPreparePMT(obj)
            try
                if obj.mdfData.pmtModuleControl
                    obj.hPMT = obj.hLSM.hPMTModule;
                end
            catch ME
                fprintf(2,'Error occurred while initializing PMT hardware. Incorrect MachineDataFile settings likely cause. \n Disabling PMT feature. \n Error stack: \n  %s \n',ME.getReport());
                obj.hPMT = [];
            end
        end
        
        function ziniPrepareMotor(obj)
            obj.hMotor = [];
            obj.hMotorZ = [];
            
            if isempty(obj.mdfData.motorControllerType)
                if ~isempty(obj.mdfData.motor2ControllerType)
                    error('SI4:motorInitErr',...
                        'A secondary z-dimension motor controller was specified without specifying a primary motor controller. This is not supported.');
                end
                fprintf(1,'No motor controller specified in Machine Data File. Featured disabled.\n');
                return;
            end
            
            timed = 0;
            while isempty(obj.hMotor)
                try
                    [obj.hMotor, mtrDims1] = obj.ziniMotorConfigureAndConstruct('motor',false);
                    if timed
                        fprintf('well done!');
                    end
                catch ME
                    if ~timed
                        fprintf(2,'Error constructing/initializing primary motor:\n%s\n',ME.message);
                        fprintf(2,'You have some seconds to switch on/reset the motor.\n Waiting ..');
                        timed = 1;
                    else
                        fprintf('.');
                    end
                    pause(0.5);
                    
                end
            end
            
            if isempty(obj.hMotor)
                return;
            end
            
            if ~isempty(obj.mdfData.motor2ControllerType)
                try
                    [obj.hMotorZ, mtrDims2] = obj.ziniMotorConfigureAndConstruct('motor2',true);
                catch ME
                    fprintf(2,'Error constructing/initializing secondary motor:\n%s\n',ME.message);
                    fprintf(2,'Disabling secondary motor.\n');
                end
            end
            
            if isempty(obj.hMotorZ)
                obj.motorDimensionConfiguration = mtrDims1;
            else
                obj.motorDimensionConfiguration = sprintf('%s-%s',mtrDims1,mtrDims2);
            end
            
            switch obj.motorDimensionConfiguration
                case {'xyz' 'xy' 'z' 'xyz-z'}
                    obj.motorSecondMotorZEnable = false;
                case {'xy-z'}
                    obj.motorSecondMotorZEnable = true;
            end
            
            if ~isempty(obj.hMotor)
                obj.hMotor.addlistener('LSCError',@(src,evt)obj.zprvMotorErrorCbk(src,evt));
            end
            if ~isempty(obj.hMotorZ)
                obj.hMotorZ.addlistener('LSCError',@(src,evt)obj.zprvMotorErrorCbk(src,evt));
            end
        end
        
        function [motorObj, mtrDims] = ziniMotorConfigureAndConstruct(obj,mdfPrefix,tfIsSecondaryMotor)
            % Get controller type and info
            type = lower(obj.mdfData.(sprintf('%s%s',mdfPrefix,'ControllerType')));
            regInfo = scanimage.MotorRegistry.getControllerInfo(type);
            
            % Construct/init LSC
            [lscObj, mtrDims] = obj.ziniMotorLSCConstruct(regInfo,mdfPrefix,tfIsSecondaryMotor);
            
            % Construct StageController
            motorObj = obj.ziniMotorStageControllerConstruct(regInfo.TwoStep,lscObj,mdfPrefix);
        end
        
        function [lsc, mtrDims] = ziniMotorLSCConstruct(obj,info,mdfPrefix,tfIsSecondaryMotor)
            
            % Compile arguments for LSC construction
            lscArgs = struct();
            
            if ~isempty(info.SubType)
                lscArgs.controllerType = info.SubType;
            end
            
            stageType = obj.mdfData.(sprintf('%s%s',mdfPrefix,'StageType'));
            lscArgs.stageType = stageType;
            
            optionalArgMap = containers.Map({'PositionDeviceUnits' 'COMPort' 'BaudRate'},...
                {'positionDeviceUnits' 'comPort' 'baudRate'});
            for key = optionalArgMap.keys
                mdfOptionalData = obj.mdfData.(sprintf('%s%s',mdfPrefix,key{1}));
                if ~isempty(mdfOptionalData)
                    lscArgs.(optionalArgMap(key{1})) = mdfOptionalData;
                end
            end
            
            if tfIsSecondaryMotor
                mtrDims = 'z';
            else
                mtrDims = lower(obj.mdfData.(sprintf('%s%s',mdfPrefix,'Dimensions')));
                assert(ischar(mtrDims),'Motor dimensions must be a string.');
                if isempty(mtrDims)
                    mtrDims = 'xyz';
                end
            end
            
            % Construct/init LSC
            lscArgsCell = most.util.structPV2cellPV(lscArgs);
            tfErr = false;
            try
                lsc = feval(info.Class,lscArgsCell{:});
                scanimage.StageController.initLSC(lsc,mtrDims);
            catch ME
                tfErr = true;
            end
            
            % For common failures (comPort) provide some guidance
            if tfErr
                if ~isfield(lscArgs,'comPort') || isempty(lscArgs.comPort) || ~isnumeric(lscArgs.comPort)
                    ME.rethrow();
                end
                
                portSpec = sprintf('COM%d',lscArgs.comPort);
                
                % check if our ME matches the case of an open port
                if regexp(ME.message,[portSpec ' is not available'])
                    choice = questdlg(['Motor initialization failed because of an existing serial object for ' portSpec ...
                        '; would you like to delete this object and retry initialization?'], ...
                        'Motor initialization error: port Open','Yes','No','Yes');
                    switch choice
                        case 'Yes'
                            % determine which object to delete
                            hToDelete = instrfind('Port',portSpec,'Status','open');
                            delete(hToDelete);
                            disp('Deleted serial object. Retrying motor initialization...');
                            lsc = feval(info.Class,lscArgsCell{:});
                        case 'No'
                            ME.rethrow();
                    end
                else
                    ME.rethrow();
                end
            end
        end
        
        function scObj = ziniMotorStageControllerConstruct(obj,twoStepInfo,lscObj,mdfPrefix)
            
            scArgs.twoStepEnable = twoStepInfo.Enable;
            if scArgs.twoStepEnable
                
                scArgs.twoStepDistanceThreshold = obj.motorFastMotionThreshold;
                
                % MDF velocity trumps registry velocity. Note that the
                % following may add the field 'velocity' to the
                % FastLSCPropVals, SlowLSCPropVals if it was not there
                % already.
                
                velFast = obj.mdfData.(sprintf('%s%s',mdfPrefix,'VelocityFast'));
                velSlow = obj.mdfData.(sprintf('%s%s',mdfPrefix,'VelocitySlow'));
                if ~isempty(velFast)
                    twoStepInfo.FastLSCPropVals.velocity = velFast;
                end
                if ~isempty(velSlow)
                    twoStepInfo.SlowLSCPropVals.velocity = velSlow;
                end
                
                scArgs.twoStepFastPropVals = twoStepInfo.FastLSCPropVals;
                scArgs.twoStepSlowPropVals = twoStepInfo.SlowLSCPropVals;
                
                %Initialize LSC two-step props to 'slow' values, if specified
                if twoStepInfo.InitSlowLSCProps
                    s = scArgs.twoStepSlowPropVals;
                    props = fieldnames(s);
                    for c=1:numel(props)
                        lscObj.(props{c}) = s.(props{c});
                    end
                end
                
            end
            
            scArgsCell = most.util.structPV2cellPV(scArgs);
            scObj = scanimage.StageController(lscObj,scArgsCell{:});
        end
        
    end
    
    %% PROPERTY ACCESS METHODS
    methods
        

        function handParamsToLSM_MDF(obj) % PR2014-08-27
            % from machine data file
            obj.hLSM.scanDevice = obj.mdfData.scanDevice; 
            obj.hLSM.frameClockChannel = obj.mdfData.frameClockChannel; 
            obj.hLSM.resScanChannel = obj.mdfData.resScanChannel; 
            obj.hLSM.disableResScan = obj.mdfData.disableResScan; 
            obj.hLSM.galvoChannel = obj.mdfData.galvoChannel; 
            obj.hLSM.galvoTriggerChannel = obj.mdfData.galvoTriggerChannel; 
            obj.hLSM.lineClockChan = obj.mdfData.lineClockChan; 
            obj.hLSM.iLineClockChan = obj.mdfData.iLineClockChan; 
            obj.hLSM.iLineClockTrig = obj.mdfData.iLineClockTrig;
            obj.hLSM.frameClock2Trig = obj.mdfData.frameClock2Trig; 
            obj.hLSM.frameClock2Chan = obj.mdfData.frameClock2Chan;
            
            
            obj.hLSM.extFrameClockTerminal = obj.mdfData.extFrameClockTerminal;
            obj.hLSM.iLineClockReceive = obj.mdfData.iLineClockReceive;
            
            obj.hLSM.fastzDevice = obj.mdfData.fastzDevice;
            obj.hLSM.fastzAOChannel = obj.mdfData.fastzAOChannel;
            obj.hLSM.fastzAOPockels = obj.mdfData.fastzAOPockels;
            obj.hLSM.fastzAIHallSensor = obj.mdfData.fastzAIHallSensor;
        end
    
        function handParamsToLSM(obj) % PR2014
            obj.hLSM.focusSave = obj.focusSave;
            obj.hLSM.framerate = obj.scanFrameRate;
            obj.hLSM.scanLinesPerFrame = obj.scanLinesPerFrame;
            obj.hLSM.scanPixelsPerLine= obj.scanPixelsPerLine;
            
            obj.hLSM.fastZEnable = obj.fastZEnable; % PR 2015-07-08
            obj.hLSM.exec_after = obj.exec_after; % PR 2015-10
            obj.hLSM.offset_directly = obj.offset_directly; % PR 2015-10
            obj.hLSM.pockelsZ = obj.pockelsZ; % PR 2015-10
            obj.hLSM.pockelsZoffset = obj.pockelsZoffset; % PR 2015-10
            obj.hLSM.topbias = obj.topbias; % PR 2016-03
            obj.hLSM.leftbias = obj.leftbias; % PR 2016-03
            obj.hLSM.fastZScanType = obj.fastZScanType;
            obj.hLSM.fastz_step_nbplanes = obj.fastz_step_nbplanes;
            obj.hLSM.fastz_step_stepsize =  obj.fastz_step_stepsize;
            obj.hLSM.fastz_step_settlingtime = obj.fastz_step_settlingtime;
            obj.hLSM.fastz_cont_nbplanes = obj.fastz_cont_nbplanes;
            obj.hLSM.fastz_cont_amplitude = obj.fastz_cont_amplitude;

            obj.hLSM.highVal = obj.highVal;
            obj.hLSM.lowVal = obj.lowVal;
            obj.hLSM.dutyCycleZ = obj.dutyCycleZ;
            
            obj.hLSM.restartFrameClock();
        end
        
        
        
        
        function val = get.acqFrameBufferLength(obj)
            val = max(obj.acqFrameBufferLengthMin,obj.displayRollingAverageFactor * (obj.displayFrameBatchFactor / obj.frameAcqFcnDecimationFactor) + 1);
        end
        
        function val = get.acqBeamLengthConstants(obj)
            
            %Empty value acqBeamLengthConstants signals need to recompute (if any beams)
            if isempty(obj.acqBeamLengthConstants) && ~isempty(obj.beamNumBeams)
                obj.acqBeamLengthConstants = inf(obj.beamNumBeams,1);
                obj.acqBeamLengthConstants(logical(obj.beamPzAdjust)) = obj.beamLengthConstants(logical(obj.beamPzAdjust));
                
                if obj.stackUserOverrideLz && obj.stackStartEndPointsDefined && obj.stackStartEndPowersDefined && ~obj.fastZEnable
                    obj.acqBeamLengthConstants = obj.beamComputeOverrideLzs();
                end
            end
            
            val = obj.acqBeamLengthConstants;
        end
        
        
        function val = get.acqNumFramesPerTrigger(obj)
            
            if ~obj.fastZEnable
                val = obj.acqNumFrames;
            else
                switch obj.fastZImageType
                    case {'XY-Z' 'XZ-Y'}
                        val = obj.fastZNumFramesPerVolume * obj.fastZNumVolumes;
                    case {'XZ'}
                        val = obj.fastZNumFramesPerVolume;
                end
            end
        end
        
        function val = get.fastZNumFramesPerVolume(obj)
            switch obj.fastZImageType
                case 'XY-Z'
                    %Discarded frames, if any, apply per-volume
                    val = (obj.acqNumFrames * obj.stackNumSlices + obj.fastZNumDiscardFrames);
                case 'XZ'
                    %Discarded frames, if any, apply per-frame
                    val = obj.acqNumFrames * (1 + obj.fastZNumDiscardFrames);
                case 'XZ-Y'
                    %numSlices taken to mean # of Y slices in this case
                    %Discarded frames, if any, apply per-volume
                    val = (obj.acqNumFrames * obj.stackNumSlices + obj.fastZNumDiscardFrames);
            end
            
        end
        
        function val = get.frameAcqFcnDecimationFactor(obj)
            val = obj.hLSM.frameEventDecimationFactor;
        end
        
        function val = get.stackZMotor(obj)
            if ~obj.motorHasMotor
                val = [];
                return;
            end
            
            if obj.motorSecondMotorZEnable
                assert(obj.motorHasSecondMotor);
                val = obj.hMotorZ;
            else
                val = obj.hMotor;
            end
        end
        
        function val = get.stackCurrentMotorZPos(obj)
            val = obj.stackZMotor.positionRelative(3);
        end
        
        function val = get.beamOnPowerVoltages(obj)
            bmPowers = obj.beamPowers;
            for c = obj.beamNumBeams:-1:1
                val(c) = obj.zprpBeamsPowerFractionToVoltage(c,bmPowers(c)/100.0);
            end
            obj.hLSM.beamOnPowerVoltages = val(1);
            obj.hLSM.beamCalibrationLUT = obj.beamCalibrationLUT;
        end
        
        function val = get.beamOffPowerVoltages(obj)
            for c = obj.beamNumBeams:-1:1
                val(c) = obj.zprpBeamsPowerFractionToVoltage(c,0.0);
            end
        end
        
        function val = get.channelsInputRangeValues(obj)
            val = obj.hLSM.channelsInputRangeValues;
%             val = obj.channelsInputRangeValues;
        end
        
        function val = get.channelsBitDepth(obj)
            val = obj.hLSM.channelsBitDepth;
        end
        
        function val = get.channelsDataType(obj)
            if obj.hLSM.signedData
                val = 'int16';
            else
                val = 'uint16';
            end
        end
        
        function val = get.channelsNumChannels(obj)
            val = obj.hLSM.numChannelsAvailable;
        end
        
        function val = get.channelsOffset(obj)
            if any(~isnan(obj.channelsOffset))
                val = obj.hLSM.channelOffsets;
            else
                assert(all(obj.hLSM.channelOffsets == 0),'Thor LSM object appears to have read channel offsets unbeknownst to ScanImage');
                val = obj.channelsOffset;
            end
        end
        
        function val = get.channelsLUTRange(obj)
            if obj.hLSM.signedData
                n = obj.channelsBitDepth - 1;
                val = [-2^n 2^n-1];
            else
                n = obj.channelsBitDepth;
                val = [0 2^n-1];
            end
        end
        
        function val = get.channelsSubtractOffset(obj)
            val = obj.hLSM.subtractChannelOffsets;
        end
        
        function val = get.displayShowCrosshairTrue(obj)
            val = obj.displayShowCrosshair && numel(obj.displayFrameBatchSelection) <= 1;
        end
        
        function val = get.headerString(obj)
            %val = [obj.headerStringCache char(13) obj.modelGetHeader('include',obj.triggerHeaderProps,15)]; %Use high precision for trigger timestamping header values
            val = [obj.modelGetHeader('include',obj.triggerHeaderProps,15) obj.headerStringCache ]; %Use high precision for trigger timestamping header values
        end
        
        function val = get.loggingFileName(obj)
            [~,val] = obj.loggingFullFileName;
        end
        
        function val = get.loggingFullFileName(obj)
            if isempty(obj.loggingFilePath)
                val = '';
            else
                val = zlclConstructLoggingFullFileName(obj.loggingFilePath,obj.loggingFileStem,obj.loggingFileCounter,obj.loggingFileSubCounter);
            end
        end
        
        function val = get.loggingFileNumChunks(obj)
            val = ceil((obj.acqNumFrames * obj.stackNumSlices * (obj.fastZNumVolumes^obj.fastZEnable)) / (obj.acqNumAveragedFrames * obj.loggingFramesPerFile));
            if val == 1 || isinf(obj.loggingFramesPerFile)
                val = 0;
            end
        end
        
        function val = get.loggingFrameDelay(obj)
            val = min(ceil(obj.loggingDelay/obj.scanFramePeriod),obj.hLSM.loggingFrameDelayMax);
        end
        
        function val = get.motorPosition(obj)
            if ~obj.motorHasMotor
                val = [];
            else
                val = obj.hMotor.positionRelative;
                if obj.motorHasSecondMotor
                    secZPos = obj.hMotorZ.positionRelative(3);
                    switch obj.motorDimensionConfiguration
                        case 'xy-z'
                            val(3) = secZPos;
                        case 'xyz-z'
                            val(4) = secZPos;
                        otherwise
                            assert(false,'Impossible value of motorDimensionconfiguration');
                    end
                end
            end
        end
        
        function val = get.motorPositionLength(obj)
            if ~obj.motorHasMotor
                val = 0;
            elseif ~obj.motorHasSecondMotor || strcmpi(obj.motorDimensionConfiguration,'xy-z')
                val = 3;
            else
                val = 4;
            end
        end
        
        function val = get.motorHasMotor(obj)
            val = ~isempty(obj.hMotor);
        end
        
        function val = get.motorHasSecondMotor(obj)
            val = ~isempty(obj.hMotorZ);
        end
        
        
        function val = get.mroiEnabled(obj)
            val = ~isempty(obj.mroiParams);
        end
        
        function val = get.mroiLinesPerSet(obj)
            if ~isempty(obj.mroiParams)
                val = sum([obj.mroiParams.scanLinesPerFrame]) + sum(obj.mroiComputedParams.transitNumLines);
            else
                val = [];
            end
        end
        
        function val = get.mroiLinesPerLSMFrame(obj)
            if ~isempty(obj.mroiParams)
                if obj.mroiLinesPerSet < obj.mroiUpdateMinLines
                    val = ceil(obj.mroiUpdateMinLines/obj.mroiLinesPerSet) * obj.mroiLinesPerSet;
                else
                    val = obj.mroiLinesPerSet;
                    
                end
                
                val = val + mod(16 - rem(val,16),16); %Augment value to reach multiple of 16
                %TODO: Account for the 'rule of 16' as part of determining roi-set multiplier - you might not need to multiply as much
            else
                val = [];
            end
        end
        
        function val = get.mroiSetsPerLSMFrame(obj)
            val = floor(obj.mroiLinesPerLSMFrame / obj.mroiLinesPerSet);
        end
        
        
        function set.mroiEnabled(obj,val)
            obj.mdlDummySetProp(val,'mroiParams');
        end
        
        function val = get.scanPhase(obj)
%             disp('To be deleted, PR2014-08-20.');
            val = 0;
        end
        
        function val = get.scanPhaseFine(obj)
%             disp('To be deleted, PR2014-08-20.');
            val = 0;
        end
        
        function val = get.pmtEnable(obj)
            if isempty(obj.hPMT)
                val = [];
            else
                val = [obj.hPMT.pmtEnable1 obj.hPMT.pmtEnable2];
            end
        end
        
        function val = get.pmtGain(obj)
            if isempty(obj.hPMT)
                val = [];
            else
                val = [obj.hPMT.pmtGain1 obj.hPMT.pmtGain2];
            end
        end
        
        function val = get.scanPhaseMap(obj)
            
            %Initialize scanPhaseMap value against CDF value, on first use
            if isempty(obj.scanPhaseMap) && isnumeric(obj.scanPhaseMap) %empty double array indicates no value has been set
                obj.scanPhaseMap = obj.getClassDataVar('scanPhaseStore');
                
                if ~isempty(obj.scanPhaseMap)
                    %ECU2 or LSM:
                    if(0 == isempty(obj.hLSM.hPMTModule.scanZoomPos)) 
                        if obj.scanPhaseMap.isKey(obj.hLSM.hPMTModule.scanZoomPos)
                            obj.scanPhase = obj.scanPhaseMap(obj.hLSM.hPMTModule.scanZoomPos);
                        end
                    else
                    if obj.scanPhaseMap.isKey(obj.hLSM.fieldSize)
                        obj.scanPhase = obj.scanPhaseMap(obj.hLSM.fieldSize);
                    end
                    end
                end
            end
            
            val = obj.scanPhaseMap;
        end
        
        function val = get.scanPhaseFineMap(obj)
            
            %Initialize scanPhaseFineMap (and current scanPhaseFine value) against CDF value, on first use
            if isempty(obj.scanPhaseFineMap) && isnumeric(obj.scanPhaseFineMap) %empty double array indicates no value has been set
                obj.scanPhaseFineMap = obj.getClassDataVar('scanPhaseFineStore');
                
                if ~isempty(obj.scanPhaseFineMap)
                    if obj.scanPhaseFineMap.isKey(obj.hLSM.fieldSize)
                        hMap = obj.scanPhaseFineMap(obj.hLSM.fieldSize);
                        if hMap.isKey(obj.hLSM.pixelsPerLine)
                            a = hMap(obj.hLSM.pixelsPerLine);
                        end
                        
                        chanIdx = (obj.hLSM.numChannelsActive > 1) + 1;
                        if ~isnan(a(chanIdx))
                            obj.scanPhaseFine = a(chanIdx);
                        end
                    end
                end
            end
            
            val = obj.scanPhaseFineMap;
        end
        
        function val = get.scanFillFractionSpatial(obj)
            val = sin(obj.scanFillFraction * pi/2);
        end
        
        function val = get.scanPixelTimeStats(obj)
            val = scanimage.util.computeResScannerParams(obj.mdfData.scannerFrequencyNominal,obj.scanPixelsPerLine,'temporalFF',obj.scanFillFraction,'pixelMode','spanPeriodAdjustParams');
        end
        
        function val = get.scanPixelTimeMean(obj)
            val = obj.scanPixelTimeStats.meanPixelTime;
        end
        
        function val = get.scanPixelTimeMaxMinRatio(obj)
            val = obj.scanPixelTimeStats.pixelTimeRatio;
        end
        
        function val = get.scanForceSquarePixel_(obj)
            val = obj.scanForceSquarePixel && obj.scanAngleMultiplierSlow > 0;
        end
        
        function val = get.scanForceSquarePixelation_(obj)
            val = obj.scanForceSquarePixelation && obj.scanAngleMultiplierSlow > 0;
        end
        
        function val = get.scanFrameRate(obj)
            val = 1/obj.scanFramePeriod;
        end
        
        function val = get.scanFramePeriod(obj) 
            val = 1.002*obj.hLSM.framePeriodMeasuredMean * obj.scanPeriodsPerFrame; % RETEPRRRR
        end
        
        function val = get.scannerPeriodStore(obj)
            if isempty(obj.scannerPeriodStore)
                obj.scannerPeriodStore = obj.getClassDataVar('scannerPeriodStore');
            end
            val = obj.scannerPeriodStore;
        end
        
        function val = get.scannerPeriod(obj)
            
            % dummy value for the scan period of the resonant scanner,
            % PR2014. Originally a LUT or sth like this
            val = 125e-6;
%             if ~obj.scannerPeriodStore.isKey(obj.scanZoomFactor);
%                 val = nan;
%             else
%                 val = obj.scannerPeriodStore(obj.scanZoomFactor);
%             end
        end
        
          
        function val = get.scannerPeriodNearestSmaller(obj)
            if ~obj.scannerPeriodStore.isKey(obj.scanZoomFactor);
                scanZoomFactors = sort(cell2mat(obj.scannerPeriodStore.keys()));
                
                [~,idx] = find(scanZoomFactors > obj.scanZoomFactor,1);
                nearestLargerSZF = scanZoomFactors(idx);
                if isempty(nearestLargerSZF)
                    val = nan;
                else
                    val = obj.scannerPeriodStore(nearestLargerSZF);
                end
            else
                val = obj.scannerPeriodStore(obj.scanZoomFactor);
            end
        end
        
        
        function val = get.scanLinePeriod(obj)
            val = obj.zprpGetScanLinePeriodVal(obj.scannerPeriod);
        end        
        
        function val = get.scanLinePeriodNearestSmaller(obj)
            val = obj.zprpGetScanLinePeriodVal(obj.scannerPeriodNearestSmaller);
        end  
        
        function val = get.scanLinePeriodNominal(obj)
            val = obj.zprpGetScanLinePeriodVal(1 / obj.mdfData.scannerFrequencyNominal);            
        end        
        
        function val = get.scanPeriodsPerFrame(obj)
            isBidi = isequal(obj.scanMode,'bidirectional');
            bidiFactor = 2^1; %1 for unidi; 2 for bidi
            
            flybackPeriods = obj.hLSM.flybackScannerPeriodsCurrent;
            
            val = obj.scanLinesPerFrame/bidiFactor + flybackPeriods;
        end
        
        function val = get.secondsCounterMode(obj)
            
            switch obj.acqState
                case {'focus' 'grab'}
                    val = 'up';
                case {'loop' 'loop_wait'}
                    if isinf(obj.loopRepeatPeriod) || obj.triggerExtStartTrigUsed
                        val = 'up';
                    else
                        val = 'down';
                    end
                otherwise
                    val = '';
            end
        end
        
        function val = get.triggerExtStartTrigUsed(obj)
            %val = obj.triggerExtTrigEnable && obj.triggerExtTrigAvailable;
            val = obj.triggerExtTrigEnable && ~isempty(obj.triggerStartTrigSrc);
        end
        
        function val = get.triggerNextTrigUsed(obj)
            val = obj.triggerExtTrigEnable && ~isempty(obj.triggerNextTrigSrc) && (obj.stackNumSlices == 1 || obj.fastZEnable);
        end
        
        function val = get.triggerExtTrigAvailable(obj)
            val = ~isempty(obj.triggerStartTrigSrc) || ~isempty(obj.triggerNextTrigSrc);
        end
        
        function val = get.triggerClockTimeFirst(obj)
            val = datestr(datenum(obj.triggerClockTimeFirstVec),'dd-mm-yyyy HH:MM:SS.FFF'); %Convert to datenum first to handle case of datenum=1
        end
        
        function val = get.triggerTime(obj)
            %val =  sprintf('%#13.6f',obj.triggerTimes(end));
            val = obj.triggerTimes(end);
        end
        
        function val = get.triggerTimestampResolution(obj)
            val = 1/get(obj.hTriggerPeriodCtr.channels(1),'ctrTimebaseRate');
        end
        
        function val = get.triggerFrameStartTime(obj)
            %val =  sprintf('%#13.6f',obj.triggerFrameStartTimes(end));
            val = obj.triggerFrameStartTimes(end);
        end
        
        function val = get.usrCfgFileVarName(obj)
            val = regexprep(sprintf('%s__configFileName',class(obj)),'\.','_');
        end
        
        function set.acqNumFrames(obj,val)
            obj.zprvAssertIdle('acqNumFrames');
            val = obj.validatePropArg('acqNumFrames',val);
            
            %Constrain by fastZEnable
            if isinf(val) && obj.fastZEnable
                obj.modelWarn('Cannot set acqNumFrames to Inf when fastZEnable=true');
                return;
            end
            obj.acqNumFrames = val;
            
            %Enforce FrameAcqFcnDecimationFactor constraint
            obj.acqNumFrames = obj.zprpApplyFAFDecFactorConstraint('acqNumFrames');
            
            %Dependencies
            obj.acqNumAveragedFrames = obj.acqNumAveragedFrames;
            obj.loggingFramesPerFileLock = obj.loggingFramesPerFileLock;
            obj.zprvFastZUpdateAODataNormalized();
        end
        
        
        function set.acqNumAveragedFrames(obj,val)
            obj.zprvAssertIdle('acqNumAveragedFrames');
            val = obj.validatePropArg('acqNumAveragedFrames',val);
            
            %Constrain by acqNumFrames: value must divide evenly into acqNumFrames
            if isinf(obj.acqNumFrames) || rem(obj.acqNumFrames,val)
                if val > 1
                    obj.modelWarn('Value of ''acqNumAveragedFrames'' must be integer sub-multiple of ''acqNumFrames''');
                end
                val = 1;
            end
            
            %Update LSM averaging factor
            obj.hLSM.loggingAveragingFactor = val;
            
            obj.acqNumAveragedFrames = val;
            
            %Apply lock constraint, if applicable
            if obj.displayRollingAverageFactorLock
                obj.zprpLockDisplayRollAvgFactor();
            end
        end
        
        function set.acqDebug(obj,val)
            val = obj.validatePropArg('acqDebug',val);
            obj.acqDebug = val;
        end
        
        function set.acqFrameBufferLengthMin(obj,val)
            obj.zprvAssertIdle('acqFrameBufferLengthMin');
            val = obj.validatePropArg('acqFrameBufferLengthMin',val);
            obj.acqFrameBufferLengthMin = val;
        end

        function set.acqState(obj,val)
            if ~obj.nostatereport
                obj.zprvUpdateStatusStringBasedOnAcqState(val);
            end
            obj.acqState = val;
            obj.hLSM.acqState = val;
            %Side effects
%             switch val
%                 case 'idle'
% %                     if ~isempty(obj.scanPhaseMap) && obj.scanPhaseSetFlag
% %                         obj.setClassDataVar('scanPhaseStore',obj.scanPhaseMap);
% %                         obj.scanPhaseSetFlag = false;
% %                     end
% %                     
% %                     if ~isempty(obj.scanPhaseFineMap) && obj.scanPhaseFineSetFlag
% %                         obj.setClassDataVar('scanPhaseFineStore',obj.scanPhaseFineMap);
% %                         obj.scanPhaseFineSetFlag = false;
% %                     end
%                     
%                 otherwise
%                     %no-op
%             end
        end
        
        function set.displayShowCrosshair(obj,val)
            val = obj.validatePropArg('displayShowCrosshair',val);
            obj.displayShowCrosshair = val;
            
            %Dependencies
            obj.displayShowCrosshairTrue = obj.displayShowCrosshairTrue;
        end
        
        function set.displayShowCrosshairTrue(obj,val)
            
            %TODO: This logic would ideally be in a DependsOn 'callback', rather than in a prop setter, avoiding eigenset operations in all the setters which drive this operation
            %TODO: crosshair + merge
            for i=1:obj.channelsNumChannels
                hFig = obj.channelsHFig(i);
                hAx = obj.channelsHAxes{i}; %Handle to axes(s) associated with current channel
                
                %Delete any existing crosshair objects
                hCross = findall(hFig,'Tag','ImageCrosshair');
                delete(hCross);
                
                if val %Add crosshair
                    
                    %Get normalized axes posn
                    axUnits = get(hAx,'Units');
                    set(hAx,'Units','normalized');
                    axPosnNorm = get(hAx,'Position');
                    set(hAx,'Units',axUnits);
                    
                    %Create annotation spanning size of axes
                    set(0,'CurrentFigure',obj.channelsHFig(i));
                    annotation('line',repmat((axPosnNorm(1) + axPosnNorm(3))/2,1,2), [axPosnNorm(2) axPosnNorm(2) + axPosnNorm(4)],'Tag','ImageCrosshair','Color',[1 1 1],'LineWidth',1); %Vertical line
                    annotation('line', [axPosnNorm(1) axPosnNorm(1) + axPosnNorm(3)],repmat((axPosnNorm(2) + axPosnNorm(4))/2,1,2),'Tag','ImageCrosshair','Color',[1 1 1],'LineWidth',1); %Horizontal line
                end
            end
            
        end
        
        function set.displayRollingAverageFactor(obj,val)
            obj.zprvAssertFocusOrIdle('displayRollingAverageFactor');
            
            %Enforce displayRollingAverageFactorLock constraint
            if obj.displayRollingAverageFactorLock
                allowedVal = obj.zprpLockDisplayRollAvgFactor();
                if val ~= allowedVal
                    return;
                end
            end
            
            %Proceed with set
            val = obj.validatePropArg('displayRollingAverageFactor',val); %allow while running
            
            %Dependencies
            
            if obj.displayFrameBatchFactorLock && obj.displayFrameBatchFactor ~= (val * obj.frameAcqFcnDecimationFactor)
                obj.displayFrameBatchFactor = (val * obj.frameAcqFcnDecimationFactor);
            end
            obj.displayRollingAverageFactor = val;
            
            if ~strcmp(obj.acqState,'idle')
                disp('This might crash for parameter changes during acquisition - not yet implemented, PR2014.');
                % obj.zprvResumeFocus();  %Ensure frame count value is reset
                % obj.zprvResetBuffersIfFocusing();
            end           
        end
        
        function set.displayRollingAverageFactorLock(obj,val)
            val = obj.validatePropArg('displayRollingAverageFactorLock',val); %Allow while running
            obj.displayRollingAverageFactorLock = val;
            
            %Dependencies
            if val
                obj.zprpLockDisplayRollAvgFactor()
            end
        end
        
        function set.displayFrameBatchFactor(obj,val)
            %Enforce displayFrameBatchFactorLock constraint
            if obj.displayFrameBatchFactorLock && val ~= (obj.displayRollingAverageFactor * obj.frameAcqFcnDecimationFactor)
                return;
            end
            
            %Proceed with set
            val = obj.validatePropArg('displayFrameBatchFactor',val);
            obj.displayFrameBatchFactor = val;
            
            %Enforce FrameAcqFcnDecimationFactor constraint
            obj.displayFrameBatchFactor = obj.zprpApplyFAFDecFactorConstraint('displayFrameBatchFactor');
            
            %Dependencies
            if obj.displayFrameBatchSelectLast && ~isequal(val,obj.displayFrameBatchSelection)
                obj.displayFrameBatchSelection = val;
            else
                obj.displayFrameBatchSelection = obj.displayFrameBatchSelection;
            end
        end
        
        function set.displayFrameBatchFactorLock(obj,val)
            val = obj.validatePropArg('displayFrameBatchFactorLock',val);
            obj.displayFrameBatchFactorLock = val;
            
            %Dependencies
            if val && obj.displayFrameBatchFactor ~= (obj.displayRollingAverageFactor * obj.frameAcqFcnDecimationFactor)
                obj.displayFrameBatchFactor = (obj.displayRollingAverageFactor * obj.frameAcqFcnDecimationFactor);
            end
        end
        
        function set.displayFrameBatchSelection(obj,val)
            %Enforce displayFrameBatchSelectLast constraint
            if obj.displayFrameBatchSelectLast && ~isequal(val,obj.displayFrameBatchFactor)
                return;
            end
            
            val = obj.validatePropArg('displayFrameBatchSelection',val);
            
            %Constrain by displayFrameBatchFactor & set
            val(val > obj.displayFrameBatchFactor) = []; %TODO: Ideally use 'Range' attribute with property replacement to 'automatically' enforce this constraint
            
            changeVal = ~isequal(val,obj.displayFrameBatchSelection);
            obj.displayFrameBatchSelection = val;
            
            %Enforce FrameAcqFcnDecimationFactor constraint
            obj.displayFrameBatchSelection = obj.zprpApplyFAFDecFactorConstraint('displayFrameBatchSelection');
            
            %Dependencies
            if changeVal
                obj.zprvResetDisplayFigs(obj.channelsDisplay,obj.channelsMergeEnable);
                obj.displayShowCrosshairTrue = obj.displayShowCrosshairTrue;
                
                obj.zprvResetBuffersIfFocusing();
            end
        end
        
        function set.displayFrameBatchSelectLast(obj,val)
            val = obj.validatePropArg('displayFrameBatchSelectLast',val);
            obj.displayFrameBatchSelectLast = val;
            
            %Dependencies
            if val && ~isequal(obj.displayFrameBatchSelection,obj.displayFrameBatchFactor)
                obj.displayFrameBatchSelection = obj.displayFrameBatchFactor;
            end
        end
        
        function set.stackCurrentMotorZPos(obj,val)
            obj.stackZMotor.moveCompleteRelative([nan nan val]);
        end
        
        function set.beamDirectMode(obj,val)
            obj.zprvAssertIdle('beamDirectMode');
            val = obj.validatePropArg('beamDirectMode',val);
            if obj.beamDirectMode && obj.isIdle && ~val
                obj.beamsStandby();
            end
            obj.beamDirectMode = val;
        end
        
        function set.beamFillFracAdjust(obj,val)
            obj.zprvAssertFocusOrIdle('beamFillFracAdjust');
            val = obj.validatePropArg('beamFillFracAdjust',val); %allow during acq
            obj.beamFillFracAdjust = val;
            
            %Dependencies
            obj.zprvBeamsUpdateFlybackBuffer();
        end
        function set.onTimeAdjust(obj,val)
            obj.zprvAssertFocusOrIdle('onTimeAdjust');
            val = obj.validatePropArg('onTimeAdjust',val); %allow during acq
            obj.onTimeAdjust = val;
            
            %Dependencies
            obj.zprvBeamsUpdateFlybackBuffer();
        end

        function set.timingAdjustPockels(obj,val)
            obj.zprvAssertFocusOrIdle('timingAdjustPockels');
            val = obj.validatePropArg('timingAdjustPockels',val); %allow during acq
            obj.timingAdjustPockels = val;
            
            %Dependencies
            obj.zprvBeamsUpdateFlybackBuffer();
        end

        function set.beamFlybackBlanking(obj,val)
            obj.zprvAssertFocusOrIdle('beamFlybackBlanking');
            val = obj.validatePropArg('beamFlybackBlanking',val); %allow during acq
            obj.beamFlybackBlanking = val;
            
            %Dependencies
            obj.zprvBeamsUpdateFlybackBuffer();
        end
        
        function set.betweenFrames(obj,val)
            obj.zprvAssertFocusOrIdle('betweenFrames');
            val = obj.validatePropArg('betweenFrames',val); %allow during acq
            obj.betweenFrames = val;
            %Dependencies
            obj.scanAngleMultiplierSlow = obj.scanAngleMultiplierSlow;
        end
        
        function set.beamLengthConstants(obj,val)
            obj.zprvAssertFocusOrIdle('beamLengthConstants');
            val = obj.validatePropArg('beamLengthConstants',val);
            val = obj.zprpBeamScalarExpandPropValue(val,'beamLengthConstants');
            obj.beamLengthConstants = val;
            
            %Side effects
            obj.acqBeamLengthConstants = []; %Force recompute on next use
        end
        
        function set.lineScan_delay1(obj,val)
            % the frameClock stops; the frame is filled with remaining lines; the buffer will be full way before the next frame trigger 
            if ~isempty(strfind(['focus','grab','loop'],obj.acqState))
                obj.hLSM.frameClock.stop();
            end
            obj.hLSM.iLineClock.stop();
            val = obj.validatePropArg('lineScan_delay1',val);
            obj.lineScan_delay1 = val;
            obj.hLSM.lineScan_delay1 = val*1e-6;
            
            % update the internal scanphase map for this very zoom value
            obj.scanphases{obj.hLSM.fieldSize}(2) = val;
            
            set(obj.hLSM.iLineClock.channels(1),'pulseTimeInitialDelay',obj.hLSM.lineScan_delay1);
            obj.hLSM.iLineClock.start();
            if ~isempty(strfind(['focus','grab','loop'],obj.acqState))
                obj.hLSM.frameClock.start();
            end
        end
        
        function set.lineScan_delay2(obj,val)
            % the frameClock stops; the frame is filled with remaining lines; the buffer will be full way before the next frame trigger 
            obj.hLSM.iLineClock.stop();
            if ~isempty(strfind(['focus','grab','loop'],obj.acqState))
                obj.hLSM.frameClock.stop();
            end
            val = obj.validatePropArg('lineScan_delay2',val);
            obj.lineScan_delay2 = val;
            obj.hLSM.lineScan_delay2 = val;
            
            % update the internal scanphase map for this very zoom value
            obj.scanphases{obj.hLSM.fieldSize}(3) = val;
            set(obj.hLSM.iLineClock.channels(1),'pulseHighTime',1e-6*real(obj.hLSM.lineScan_delay2));
            obj.hLSM.iLineClock.start();
            if ~isempty(strfind(['focus','grab','loop'],obj.acqState))
                obj.hLSM.frameClock.start();
            end
        end
        
         function set.framerate_user(obj,val)
             val = obj.validatePropArg('framerate_user',val);
             if obj.framerate_user > obj.scanFrameRate
                 disp('Warning: Framerate might be too high for this parameter set. PR2014-08-27.');
             end
             obj.framerate_user = val;
             obj.hLSM.framerate_user = val;
         end
 
         function set.framerate_user_check(obj,val)
             val = obj.validatePropArg('framerate_user_check',val);
             obj.framerate_user_check = val;
             obj.hLSM.framerate_user_check = val;
        end
 
        
        
        function set.beamPowers(obj,val)
            obj.zprvAssertFocusOrIdle('beamPowers');
            val = obj.validatePropArg('beamPowers',val);
            
            liveRefresh = obj.fastZActive && obj.fastZAllowLiveBeamAdjust && (obj.beamFlybackBlanking || obj.beamPzAdjust); %Currently, preliminary support for live power adjustment during FastZ volume imaging is implemented
            
            assert(liveRefresh || ismember(obj.acqState,{'idle' 'focus'}) || ~obj.hLSM.isAcquiring(),'Live power adjustment during non-Focus acquisition is not permitted under current settings');
            
            val = obj.zprpBeamScalarExpandPropValue(val,'beamPowers');
            
            %Set nominal and resolution-constrained value
            val = obj.zprvBeamEnforcePowerLimits(val);
            obj.beamPowersNominal = val;
            
            if strcmpi(obj.beamPowerUnits,'percent')
                factor = obj.beamCalibrationLUTSize/100;
                val = max(round(factor*val),1)/factor; %Only allow precision to 0.1
            end
            obj.beamPowers = val;
            
            %Side effects
            if obj.beamDirectMode && obj.isIdle()
                obj.beamsOn();
            end
            
            if liveRefresh
                tic;
                obj.zprvBeamsRefreshFastZData();
                toc
            else
                obj.zprvBeamsUpdateFlybackBuffer();
            end
        end
        
        function set.beamPowerLimits(obj,val)
            obj.zprvAssertIdle('beamPowerLimits');
            val = obj.validatePropArg('beamPowerLimits',val);
            val = obj.zprpBeamScalarExpandPropValue(val,'beamPowerLimits');
            
            switch obj.beamPowerUnits
                case 'percent'
                    validateattributes(val,{'numeric'},{'>=',0,'<=',100});
                case 'milliwatts'
                    % TODO
            end
            
            obj.beamPowerLimits = val;
            
            %Side-effects
            obj.beamPowers = obj.zprvBeamEnforcePowerLimits(obj.beamPowers);
        end
        
        
        function set.beamPzAdjust(obj,val)
            obj.zprvAssertIdle('beamPzAdjust');
            val = obj.validatePropArg('beamPzAdjust',val);
            val = obj.zprpBeamScalarExpandPropValue(val,'beamPzAdjust');
            obj.beamPzAdjust = val;
            
            %Side effects
            obj.zprvBeamsUpdateFlybackBuffer();
            obj.acqBeamLengthConstants = []; %Force recompute on next use
            
        end
        
        function set.beamVoltageRanges(obj,val)
            obj.zprvAssertIdle('beamVoltageRanges');
            val = obj.validatePropArg('beamVoltageRanges',val);
            val = obj.zprpBeamScalarExpandPropValue(val,'beamVoltageRanges');
            validateattributes(val,{'numeric'},{'>=',0});
            if ~isequal(val,obj.beamVoltageRanges)
                obj.beamVoltageRanges = val;
                switch obj.initState
                    % Don't throw this warning during construction/initialization
                    case 'none'
                        warning('SI4:setBeamVoltageRanges',...
                            'Any beam whose voltage range has changed should be recalibrated.');
                end
            end
        end
        
        function set.channelsAutoReadOffsets(obj,val)
            val = obj.validatePropArg('channelsAutoReadOffsets',val);
            obj.channelsAutoReadOffsets = val;
        end
        
        function set.channelsInputRange(obj,val)
            %TODO: The 'digitizer' should know the number of channels it has
            %             assert(iscell(val) && isvector(val) && length(val)==obj.channelsNumChannels, 'Value must be a vector cell array of length %d',obj.channelsNumChannels);
            %             assert(all(cellfun(@(x)isempty(x) || ismember(x,obj.channelsInputRangeValues,'rows'),val)),'Each cell array element must be empty, or specify a valid channelInputRange value');
            
            obj.zprvAssertFocusOrIdle('channelsInputRange');
            val = obj.validatePropArg('channelsInputRange',val);
            val = obj.zprpEnsureChannelPropSize(val);
            
            %This is the LSM-specific implementation
            obj.channelsInputRange = val;
            
            obj.hLSM.setInputRange(obj.channelsInputRange);
            
            
            %Side-effects
            if  any(~isnan(obj.channelsOffset))
                if obj.isIdle
                    obj.channelsReadOffsets(); %Offset values can change when input range is changed - so update the last-measured values
                elseif any(obj.channelsSubtractOffset)
                    %Abort ongoing Focus, to get a new offset reading
                    obj.abort();
                    if ~obj.channelsAutoReadOffsets || ~obj.channelsAutoReadOffsetsOnFocus
                        obj.channelsReadOffsets();
                    end
                    obj.startFocus();
                end
            end
        end
        
        function set.channelsLUT(obj,val)
            val = obj.validatePropArg('channelsLUT',val);
            
            %Additional validation
            %TODO: This should be handled by validatePropArg
            validateattributes(val,{'numeric'},{'size',[obj.channelsNumChannels 2]});
            assert(all(val(:,1) < val(:,2)),'Black levels (column 1) must be less than white levels (column 2)');
            assert(~any(val(:) < obj.channelsLUTRange(1)) && ~any(val(:) > obj.channelsLUTRange(2)),'Specified value outside of allowed range %s',mat2str(obj.channelsLUTRange)); %TODO: Should specify Range directly in prop metadata table as the channelsLUTRange property, with 'prop replacement'
            
            try
                for i=1:obj.channelsNumChannels
                    chanVisibility = get(obj.channelsHFig(i),'Visible');
                    set(obj.channelsHAxes{i},'CLim',val(i,:),'Visible',chanVisibility);
                end
                
                obj.channelsLUT = val;
            catch ME
                for i=1:obj.channelsNumChannels
                    obj.channelsLUT(:,i) = get(obj.channelsHAxes{i},'CLim');
                end
                ME.rethrow();
            end
            
            obj.zprvUpdateMergeWindowIfNecessary();
        end
        
        function set.channelsMergeColor(obj,val)
            %if ~isequal(val,obj.channelsMergeColor) % setabort %VI20111114: is this setabort construction needed anymore??
            val = obj.validatePropArg('channelsMergeColor',val); %allow during acq
            val = obj.zprpEnsureChannelPropSize(val);
            
            obj.channelsMergeColor = val;
            
            obj.zprvUpdateMergeWindowIfNecessary();
            %end
        end
        
        function set.channelsMergeEnable(obj,val)
            val = obj.validatePropArg('channelsMergeEnable',val); %allow during acq
            obj.channelsMergeEnable = val;
            if val
                obj.zprvResetDisplayFigs([],true); %Resets merge figure, setting up tiling, etc
                obj.zprvUpdateMergeWindowIfNecessary(); %computes merge based on prevailing CData, and displays figure
            else
                set(obj.channelsHMergeFig,'Visible','off');
            end
        end
        
        function set.channelsMergeFocusOnly(obj,val)
            val = obj.validatePropArg('channelsMergeFocusOnly',val);
            obj.channelsMergeFocusOnly = val;
        end
        
        function set.channelsDisplay2(obj,val)
            if obj.delayedChannelsOn && ~isempty(val)
                val = 1;
            end
            obj.zprvAssertIdle('channelsDisplay');
            val = obj.validatePropArg('channelsDisplay',val);
            val = obj.zprpValidateChannelsArray(val,'channelsDisplay');
            %val = intersect(val,obj.channelsActive);

            obj.channelsDisplay2 = val;
            obj.channelsDisplay = obj.channelsDisplay2;
            %Side effects
            chanViewingBitmask = false(obj.channelsNumChannels,1);
            chanViewingBitmask(val) = true;
            obj.hLSM.channelsViewing = chanViewingBitmask;
            obj.zprvResetDisplayFigs(val,obj.channelsMergeEnable);
            
            offChans = setdiff(1:obj.channelsNumChannels,val);
            
            set(obj.channelsHFig(val),'Visible','on');
            set(obj.channelsHFig(offChans),'Visible','off');
            %obj.zprvUpdateMergeWindowIfNecessary();
        end
        
%         function set.channelsSave(obj,val)
%             obj.zprvAssertIdle('channelsDisplay');
%             val = obj.validatePropArg('channelsDisplay',val);
%             val = obj.zprpValidateChannelsArray(val,'channelsDisplay');
%             %val = intersect(val,obj.channelsActive);
%             
%             obj.channels = [1 2];
%             
%             %Side effects
%             chanViewingBitmask = false(obj.channelsNumChannels,1);
%             chanViewingBitmask(val) = true;
%             obj.hLSM.channelsViewing = chanViewingBitmask;
%             
%             obj.zprvResetDisplayFigs(val,obj.channelsMergeEnable);
%             
%             offChans = setdiff(1:obj.channelsNumChannels,val);
%             
%             set(obj.channelsHFig(val),'Visible','on');
%             set(obj.channelsHFig(offChans),'Visible','off');
%             %obj.zprvUpdateMergeWindowIfNecessary();
%             
%         end
        
        function set.channelsDisplay(obj,val)
            obj.zprvAssertIdle('channelsDisplay');
            val = obj.validatePropArg('channelsDisplay',val);
            val = obj.zprpValidateChannelsArray(val,'channelsDisplay');
            %val = intersect(val,obj.channelsActive);
            
            obj.channelsDisplay = val;
            
            %Side effects
            chanViewingBitmask = false(obj.channelsNumChannels,1);
            chanViewingBitmask(val) = true;
            obj.hLSM.channelsViewing = chanViewingBitmask;
            obj.zprvResetDisplayFigs(val,obj.channelsMergeEnable);
            
            offChans = setdiff(1:obj.channelsNumChannels,val);
            
            set(obj.channelsHFig(val),'Visible','on');
            set(obj.channelsHFig(offChans),'Visible','off');
            %obj.zprvUpdateMergeWindowIfNecessary();
            
        end
        
        function set.channelsSave(obj,val)
            if obj.delayedChannelsOn && ~isempty(val)
                val = 1;
            end
            obj.zprvAssertIdle('channelsSave');
            val = obj.validatePropArg('channelsSave',val);
            val = obj.zprpValidateChannelsArray(val,'channelsSave');
            %val = intersect(val,obj.channelsActive);
            
            obj.channelsSave = val;
            
            %Side effects
            chanLoggingBitmask = false(obj.channelsNumChannels,1);
            chanLoggingBitmask(val) = true;
            obj.hLSM.channelsLogging = chanLoggingBitmask;
        end
        
        function set.channelsInvert(obj,val)
            obj.zprvAssertIdle('channelsInvert');
            val = obj.validatePropArg('channelsInvert',val);
            %val = intersect(val,obj.channelsActive);
            
            obj.channelsInvert = val;
        end
        
        function set.channelsSubtractOffset(obj,val)
            val = obj.validatePropArg('channelsSubtractOffset',val);
            val = obj.zprpEnsureChannelPropSize(val);
            
            obj.hLSM.subtractChannelOffsets = logical(val);
            obj.channelsSubtractOffset = val;
        end
        
        
        function set.fastCfgCfgFilenames(obj,val)
            obj.zprvAssertIdle('fastCfgCfgFilenames');
            obj.validatePropArg('fastCfgCfgFilenames',val);
            obj.fastCfgCfgFilenames = val;
        end
        
        function set.fastCfgAutoStartTf(obj,val)
            obj.zprvAssertIdle('fastCfgAutoStartTf');
            obj.validatePropArg('fastCfgAutoStartTf',val);
            obj.fastCfgAutoStartTf = val;
            tfEmptyType = cellfun(@isempty,obj.fastCfgAutoStartType);
            tfAutoStartOnButEmptyType = val & tfEmptyType;
            obj.fastCfgAutoStartType(tfAutoStartOnButEmptyType) = {'grab'}; % default to grab
        end
        
        function set.fastCfgAutoStartType(obj,val)
            obj.zprvAssertIdle('fastCfgAutoStartType');
            
            obj.validatePropArg('fastCfgAutoStartType',val);
            obj.fastCfgAutoStartType = val;
        end
        
        function val = get.fastZActive(obj)
            val = ~ismember(obj.acqState,{'idle' 'focus'}) && obj.fastZEnable && obj.stackNumSlices > 1;
        end
        
        function val = get.fastZAcquisitionDelay(obj)
            val = obj.fastZSettlingTime / 2;
        end
        
        function val = get.fastZNumDiscardFrames(obj)
            
            %Number of discarded frames per-volume for XY-Z, XZ-Y cases and per-frame for XZ case
            
            if obj.fastZDiscardFlybackFrames
                %TODO: Tighten up these computations a bit to deal with edge cases
                %TODO: Could account for maximum slew rate as well, at least when 'velocity' property is available
                
                switch obj.fastZImageType
                    case 'XY-Z'
                        if obj.fastZNumVolumes == 1
                            val = 0;
                            return;
                        end
                    case 'XZ'
                        if obj.acqNumFrames == 1
                            val = 0;
                            return;
                        end
                    case 'XZ-Y'
                        if obj.stackNumSlices == 1 || obj.fastZNumVolumes == 1
                            val = 0;
                            return;
                        end
                end
                
                settlingNumSamples = round(obj.mdfData.fastZCmdOutputRate * obj.fastZSettlingTime);
                frameNumSamples = obj.mdfData.fastZCmdOutputRate * obj.scanFramePeriod;
                
                val = ceil(settlingNumSamples/frameNumSamples);
            else
                val = 0;
            end
        end
        
         function set.fastz_cont_amplitude(obj,val)
             val = obj.validatePropArg('fastz_cont_amplitude',val);
             obj.fastz_cont_amplitude = val;
             obj.hLSM.fastz_cont_amplitude = val;
             if obj.fastZEnable; obj.framerate_user_check = 1; end
%              obj.framerate_user = val;
%              obj.hLSM.framerate_user = val;
         end
         function set.fastz_cont_nbplanes(obj,val)
             val = obj.validatePropArg('fastz_cont_nbplanes',val);
             obj.fastz_cont_nbplanes = val;
             obj.hLSM.fastz_cont_nbplanes = val;
             if obj.fastZEnable; obj.framerate_user_check = 1; end
%              obj.framerate_user = val;
%              obj.hLSM.framerate_user = val;
         end
         
         function set.fastz_step_settlingtime(obj,val)
             val = obj.validatePropArg('fastz_step_settlingtime',val);
             obj.hLSM.fastz_step_settlingtime = val;
             obj.fastz_step_settlingtime = val;
             if obj.fastZEnable; obj.framerate_user_check = 1; end
%              obj.framerate_user = val;
%              obj.hLSM.framerate_user = val;
         end
         function set.fastz_step_stepsize(obj,val)
             val = obj.validatePropArg('fastz_step_stepsize',val);
             obj.fastz_step_stepsize = val;
             obj.hLSM.fastz_step_stepsize = val;
             if obj.fastZEnable; obj.framerate_user_check = 1; end
%              obj.framerate_user = val;
%              obj.hLSM.framerate_user = val;
         end
         
         function set.highVal(obj,val)
             val = obj.validatePropArg('highVal',val);
             obj.highVal = val;
             obj.hLSM.highVal = val;
         end
         function set.lowVal(obj,val)
             val = obj.validatePropArg('lowVal',val);
             obj.lowVal = val;
             obj.hLSM.lowVal = val;
         end
         function set.dutyCycleZ(obj,val)
             val = obj.validatePropArg('dutyCycleZ',val);
             obj.dutyCycleZ = val;
             obj.hLSM.dutyCycleZ = val;
         end
         function set.zero_pos_Z(obj,val)
             obj.zero_pos_Z = val;
             obj.hLSM.zero_pos_Z = val;
         end
         function set.current_pos_Z(obj,val)
             obj.current_pos_Z = val;
             obj.hLSM.current_pos_Z = val;
          end
          function set.fastz_step_nbplanes(obj,val)
             val = obj.validatePropArg('fastz_step_nbplanes',val);
             obj.fastz_step_nbplanes = val;
             obj.hLSM.fastz_step_nbplanes = val;
             if obj.fastZEnable; obj.framerate_user_check = 1; end
         end

         function set.fastZScanType(obj,val)
            obj.zprvAssertIdle('fastZScanType');
            val = obj.validatePropArg('fastZScanType',val);
            
            obj.fastZScanType = val;
            obj.hLSM.fastZScanType = val;
            
            %Side effects
%             obj.zprvFastZUpdateAODataNormalized();
        end
        
        
        function set.fastZEnable(obj,val)
            obj.zprvAssertIdle('fastZEnable');
            val = obj.validatePropArg('fastZEnable',val);
            
            obj.fastZEnable = val;
            obj.hLSM.fastZEnable = val;
            
            %Side effects
            if obj.fastZEnable
                obj.stackNumSlices = 1; %This will call zprvFastZUpdateAODataNormalized()
            else
                obj.stackNumSlices = obj.stackNumSlices; %Allows stack start/end point constraints to be re-applied, if applicable
            end
            
%             obj.acqBeamLengthConstants = []; %Force recompute on next use
        end
        
        function set.exec_after(obj,val)
            obj.zprvAssertIdle('exec_after');
            val = obj.validatePropArg('exec_after',val);
            obj.exec_after = val;
            obj.hLSM.exec_after = val;
        end   
        function set.offset_directly(obj,val)
            obj.zprvAssertIdle('offset_directly');
            val = obj.validatePropArg('offset_directly',val);
            obj.offset_directly = val;
            obj.hLSM.offset_directly = val;
        end   
         function set.pockelsZ(obj,val)
            obj.zprvAssertIdle('pockelsZ');
            val = obj.validatePropArg('pockelsZ',val);
            obj.pockelsZ = val;
            obj.hLSM.pockelsZ = val;
        end   
         function set.pockelsZoffset(obj,val)
            obj.zprvAssertIdle('pockelsZoffset');
            val = obj.validatePropArg('pockelsZoffset',val);
            obj.pockelsZoffset = val;
            obj.hLSM.pockelsZoffset = val;
        end   
         function set.topbias(obj,val)
            obj.zprvAssertIdle('topbias');
            val = obj.validatePropArg('topbias',val);
            obj.topbias = val;
            obj.hLSM.topbias = val;
        end   
         function set.leftbias(obj,val)
            val = obj.validatePropArg('leftbias',val);
            obj.leftbias = val;
            obj.hLSM.leftbias = val;
            obj.zprvBeamsUpdateFlybackBuffer();
        end   
        
        function set.fastZImageType(obj,val)
            obj.zprvAssertIdle('fastZImageType');
            val = obj.validatePropArg('fastZImageType',val);
            
            %For now - force property value to 'xy-z'. The 'xz' and 'xz-y' modes are not supported as of SI 4.1.
            if ~strcmpi(val,'XY-Z')
                fprintf(2,'WARNING: Only ''XY-Z'' mode supported at this time. The ''XZ'' and ''XZ-Y'' modes may be supported in future versions.\n');
                val = 'XY-Z';
            end
            
            obj.fastZImageType = val;
            
            %Side effects
            obj.zprvFastZUpdateAODataNormalized();
        end
        
%         function set.fastZScanType(obj,val)
%             obj.zprvAssertIdle('fastZScanType');
%             val = obj.validatePropArg('fastZScanType',val);
%             
%             %For now - force property value to 'sawtooth'. The 'step' mode not supported as of SI 4.1.
%             if ~strcmpi(val,'sawtooth')
%                 fprintf(2,'WARNING: FastZ Scan Type ''step'' not supported at this time. Forcing value to ''sawtooth''.\n');
%                 val = 'sawtooth';
%             end
%             
%             obj.fastZScanType = val;
%             
%             %Side effects
%             obj.zprvFastZUpdateAODataNormalized();
%         end
  
        function set.fastZAcquisitionDelay(obj,val)
            obj.zprvAssertIdle('fastZAcquisitionDelay');
            val = obj.validatePropArg('fastZSettlingTime',val); %Use same validator as fastZSettlingTime
            obj.fastZSettlingTime = 2 * val;
        end
        
        function set.fastZAllowLiveBeamAdjust(obj,val)
            obj.zprvAssertIdle('fastZAllowLiveBeamAdjust');
            val = obj.validatePropArg('fastZAllowLiveBeamAdjust',val);
            
            if val
                fprintf(2,'WARNING: FastZ Allow Live Beam Adjust beature not supported at this time. Forcing value to false.\n');
                val = false;
            end
            
            obj.fastZAllowLiveBeamAdjust = val;
        end
        
        function set.fastZSettlingTime(obj,val)
            obj.zprvAssertIdle('fastZSettlingTime');
            val = obj.validatePropArg('fastZSettlingTime',val);
            obj.fastZSettlingTime = val;
            
            %Allow 'live' adjustment of fastZ settling time when effectively in Focus mode
            if obj.fastZEnable &&  obj.fastZUseAOControl && obj.stackNumSlices > 1 && ~obj.loggingEnable && ~obj.triggerExtTrigEnable && strcmpi(obj.acqState,'grab')
                
                %                 %The simplest approach!
                %                 obj.abort();
                %                 obj.startGrab();
                
                %Stop and restart scanning
                obj.hAcqTasks.abort();
                obj.hLSM.pause();
                
                %Compute new FastZ AO data
                obj.zprvFastZUpdateAODataNormalized();
                
                %fastZBeamEnable = ismember(obj.hBeams,obj.hAcqTasks);
                fastZBeamRewrite = obj.beamNumBeams > 0 && obj.beamPzAdjust;
                
                if ~isempty(obj.fastZHomePosition)
                    obj.hFastZ.moveCompleteAbsolute([nan nan obj.fastZHomePosition]);
                end
                
                obj.zprvFastZUpdateAOData();
                if fastZBeamRewrite
                    obj.zprvBeamsWriteFastZData();
                end
                
                %obj.zprvResetTriggerTimes();
                obj.zprvResetAcqCounters();
                obj.zprvResetBuffers();
                
                obj.hAcqTasks.start();
                %obj.hLSM.arm();
                obj.hLSM.resume();
                
            else
                %Compute new FastZ AO data
                obj.zprvFastZUpdateAODataNormalized();
            end
        end
        
        function set.fastZDiscardFlybackFrames(obj,val)
            obj.zprvAssertIdle('fastZDiscardFlybackFrames');
            val = obj.validatePropArg('fastZDiscardFlybackFrames',val);
            
            obj.fastZDiscardFlybackFrames = val;
            
            obj.zprvFastZUpdateAODataNormalized();
        end
        
        function set.fastZFramePeriodAdjustment(obj,val)
            obj.zprvAssertIdle('fastZFramePeriodAdjustment');
            val = obj.validatePropArg('fastZFramePeriodAdjustment',val);
            obj.fastZFramePeriodAdjustment = val;
            
            %Side effects
            obj.zprvFastZUpdateAODataNormalized();
        end
        
        function set.fastZUseAOControl(obj,val)
            obj.zprvAssertIdle('fastZUseAOControl');
            val = obj.validatePropArg('fastZUseAOControl',val);
            
            if obj.fastZRequireAO
                val = true;
            end
            obj.fastZUseAOControl = val;
            
            %Side effects
            obj.zprvFastZUpdateAODataNormalized();
        end
        
        function set.fastZNumDiscardFrames(obj,val)
            obj.mdlDummySetProp(val,'fastZNumDiscardFrames');
        end
        
        function set.fastZNumVolumes(obj,val)
            obj.zprvAssertIdle('fastZNumVolumes');
            val = obj.validatePropArg('fastZNumVolumes',val);
            obj.fastZNumVolumes = val;
            
            %Side effects
            obj.zprvFastZUpdateAODataNormalized();
        end
        
        function set.focusDuration(obj,val)
            obj.zprvAssertIdle('focusDuration');
            obj.validatePropArg('focusDuration',val);
            obj.focusDuration = val;
        end
        
        function set.frameAcqFcnDecimationFactor(obj,val)
            val = obj.validatePropArg('frameAcqFcnDecimationFactor',val);
            fafDecFactor = val;
            
            %Side-effects: update attendant LSM property; constrain loggingFramesPerFile and other properties
            if ~isempty(val)
                obj.hLSM.frameEventDecimationFactor = fafDecFactor;
                cellfun(@(x)obj.zprpApplyFAFDecFactorConstraint(x,fafDecFactor),{'loggingFramesPerFile' 'displayFrameBatchFactor' 'displayFrameBatchSelection' 'acqNumFrames' 'stackNumSlices'},'UniformOutput',false);
            end
        end
        
        function set.galvoEnable(obj,val)
            obj.zprvAssertIdle('galvoEnable');
            val = obj.validatePropArg('galvoEnable',val);
            assert(~val || obj.galvosAvailable,'Galvo scanner control has not been configured in the Machine Data File. Galvo control cannot be enabled');
            obj.galvoEnable = val;
            
            %Side-effects
            if obj.scanAngleMultiplierSlow > 0
                obj.hLSM.galvoEnable = ~obj.galvoEnable;
            end
            
            obj.galvosStandby(); %Move galvos to central position or specified Park position, as applicable
        end

        
        function set.mroiParams(obj,val)
            val = obj.validatePropArg('mroiParams',val);
            %TODO: Add additional constraints - i.e. vector, allow empty struct, no change to fields, etc
            % Preserve fields of the struct Also TODO mroiComputedParams
            
            if isempty(val)
                obj.mroiParams(:) = [];
            else
                assert(length(obj.mdfData.galvoChanIDs) > 1,'Two galvoChanIDs must be identified in machine data file (MDF) in order to specify non-empty mroiParams value');
                obj.mroiParams = val;
            end
            
            %Side-effects
            obj.zprpUpdateGalvoProps();
        end
        
        function val = get.galvoAngle2LSMAngleFactor(obj)
            val = obj.mdfData.galvoAngle2LSMAngleFactor;
        end
        
        function set.galvoAngle2LSMAngleFactor(obj,val)
            val = obj.validatePropArg('galvoAngle2LSMAngleFactor',val);
            obj.zprpUpdateMDFVar('galvoAngle2LSMAngleFactor',val);
        end
        
        function set.loggingEnable(obj,val)
            obj.zprvAssertFocusOrIdle('loggingEnable');
            val = obj.validatePropArg('loggingEnable',val);
            obj.loggingEnable = val;
            obj.hLSM.loggingEnable = val; % the latter two shall be fused later in SI4, PR2014
        end
        
        function set.autoconvert(obj,val)
            val = obj.validatePropArg('autoconvert',val);
            obj.autoconvert = val;
        end
        function set.focusSave(obj,val)
            val = obj.validatePropArg('focusSave',val);
            obj.focusSave = val;
        end
        function set.autoscaleSavedImages(obj,val)
            val = obj.validatePropArg('autoscaleSavedImages',val);
            obj.autoscaleSavedImages = val;
            if obj.savedBitdepth == 1
                obj.autoscaleSavedImages = 1;
            end
        end
        
        
        
        function set.delayedChannelsOn(obj,val)
            val = obj.validatePropArg('delayedChannelsOn',val);
            obj.delayedChannelsOn = val;
            obj.nbDelayedChannels = obj.nbDelayedChannels;
        end
        
        function set.nbDelayedChannels(obj,val)
            val = obj.validatePropArg('nbDelayedChannels',val);
            if strcmp(val,'Two_channels') && obj.delayedChannelsOn == 1
                obj.multiChanAVG = 2;
                obj.hLSM.multiChanAVG = 2;
            elseif obj.delayedChannelsOn == 1
                obj.multiChanAVG = 4;
                obj.hLSM.multiChanAVG = 4;
            else
                obj.multiChanAVG = 0;
                obj.hLSM.multiChanAVG = 0;
            end
            obj.nbDelayedChannels = val;
            obj.channelsDisplay2 = [1];
            obj.channelsSave = [1];
        end
        
        
        function set.loggingFilePath(obj,val)
            obj.zprvAssertFocusOrIdle('loggingFilePath');
            val = obj.validatePropArg('loggingFilePath',val);
            assert(isempty(val) || isdir(val),obj.genAssertMsg(val));
            
            %obj.hLSM.loggingFilePath = val;
            
            obj.loggingFilePath = val;
        end
        
        function set.loggingFileStem(obj,val)
            obj.zprvAssertFocusOrIdle('loggingFileStem');
            val = obj.validatePropArg('loggingFileStem',val);
            assert(~any(isspace(val)),obj.genAssertMsg(val));
            
            oldVal = obj.loggingFileStem;
            obj.loggingFileStem = val;
            
            obj.zprpUpdateLSMLoggingFilename();
            if obj.loggingFileCounterAutoReset && ~strcmpi(val,oldVal)
                obj.loggingFileCounter = 1;
            end
        end
        
        function set.loggingFileCounter(obj,val)
            obj.zprvAssertFocusOrIdle('loggingFileCounter');
            val = obj.validatePropArg('loggingFileCounter',val);
            obj.loggingFileCounter = val;
            
            obj.zprpUpdateLSMLoggingFilename();
        end
        
        function set.loggingFileSubCounter(obj,val)
            obj.validatePropArg('loggingFileSubCounter',val);
            obj.loggingFileSubCounter = val;
            
            obj.zprpUpdateLSMLoggingFilename();
        end
        
        function set.loggingFramesPerFile(obj,val)
            obj.zprvAssertFocusOrIdle('loggingFramesPerFile');
            if ~obj.loggingFramesPerFileLock
                val = obj.validatePropArg('loggingFramesPerFile',val);
                obj.loggingFramesPerFile = val;
                
                %Enforce FrameAcqFcnDecimationFactor constraint
                obj.loggingFramesPerFile = obj.zprpApplyFAFDecFactorConstraint('loggingFramesPerFile');
                
            else
                obj.modelWarn('Unable to set ''loggingFramesPerFile'' when ''loggingFramesPerFileLock''=true');
            end
        end
        
        function set.loggingFramesPerFileLock(obj,val)
            obj.zprvAssertFocusOrIdle('loggingFramesPerFileLock');
            val = obj.validatePropArg('loggingFramesPerFileLock',val);
            
            %Dependencies
            if val
                obj.loggingFramesPerFileLock = false; %Force lock off to set value
                obj.loggingFramesPerFile = obj.acqNumFrames;
            end
            
            obj.loggingFramesPerFileLock = val;
        end
        
        function set.loopNumRepeats(obj,val)
            obj.zprvAssertFocusOrIdle('loopNumRepeats');
            val = obj.validatePropArg('loopNumRepeats',val);
            obj.loopNumRepeats = val;
        end
        
        function set.loopRepeatPeriod(obj,val)
            obj.zprvAssertFocusOrIdle('loopRepeatPeriod');
            val = obj.validatePropArg('loopRepeatPeriod',val);
            obj.loopRepeatPeriod = val;
        end
        
        function set.maxFrameEventRate(obj,val)
            obj.zprvAssertIdle('maxFrameEventRate');
            val = obj.validatePropArg('maxFrameEventRate',val);
            obj.maxFrameEventRate = val;
            
            %Side-effects
            obj.zprpUpdateFrameAcqFcnDecimationFactor();
        end
        
        function set.motorMoveTimeout(obj,val)
            obj.zprvAssertIdle('motorMoveTimeout');
            val = obj.validatePropArg('motorMoveTimeout',val);
            
            %Currently a single SI4 moveTimeout property controls the
            %primary and secondary motor move and async-move timeout values
            obj.zprvMotorPropSet('nonblockingMoveTimeout',val);
            obj.zprvMotorPropSet('moveTimeout',val);
            if obj.motorHasSecondMotor
                obj.zprvMotorZPropSet('nonblockingMoveTimeout',val);
                obj.zprvMotorZPropSet('moveTimeout',val);
            end
            obj.motorMoveTimeout = val;
        end
        
        function set.motorFastMotionThreshold(obj,val)
            obj.zprvAssertIdle('motorFastMotionThreshold');
            val = obj.validatePropArg('motorFastMotionThreshold',val);
            obj.zprvMotorPropSet('twoStepDistanceThreshold',val);
            obj.motorFastMotionThreshold = val;
        end
        
        function set.motorSecondMotorZEnable(obj,val)
            if ~obj.motorHasMotor
                obj.zprvMotorThrowNoMotorErrIfMdlInitialized;
                return;
            end
            
            obj.zprvAssertFocusOrIdle('motorSecondMotorZEnable');
            obj.validatePropArg('motorSecondMotorZEnable',val);
            mdc = obj.motorDimensionConfiguration;
            switch mdc
                case {'xyz' 'xy' 'z'}
                    assert(~logical(val),...
                        'Cannot enable second motor when motorDimensionConfiguration is ''%s''.',mdc);
                case 'xy-z'
                    assert(logical(val),...
                        'Second motor must be enabled when motorDimensionConfiguration is ''%s''.',mdc);
                case 'xyz-z'
                    %none
            end
            
            obj.stackClearStartEnd();
            obj.motorSecondMotorZEnable = val;
        end
        
        function set.motorPosition(obj,val)
            if ~obj.motorHasMotor
                obj.zprvMotorThrowNoMotorErrIfMdlInitialized();
                return;
            end
            
            obj.zprvAssertFocusOrIdle('motorPosition');
            val = obj.validatePropArg('motorPosition',val);
            val = val(:)';
            
            if obj.motorHasSecondMotor
                switch obj.motorDimensionConfiguration
                    case 'xy-z'
                        assert(numel(val)==3);
                        
                        currentPos = obj.hMotor.positionRelative(:)';
                        if ~isequal(val(1:2),currentPos(1:2))
                            obj.hMotor.moveCompleteRelative([val(1:2) nan]);
                        end
                        
                        if ~isequal(val(3),obj.hMotorZ.positionRelative(3))
                            obj.hMotorZ.moveCompleteRelative([nan nan val(3)]);
                        end
                    case 'xyz-z'
                        assert(numel(val)==4);
                        
                        if ~isequal(val(1:3),obj.hMotor.positionRelative(:)')
                            obj.hMotor.moveCompleteRelative(val(1:3));
                        end
                        if ~isequal(val(4),obj.hMotorZ.positionRelative(3))
                            obj.hMotorZ.moveCompleteRelative([nan nan val(4)]);
                        end
                    otherwise
                        assert(false);
                end
                %TODO (??): Maybe implement FastZPosnGotoAO() operation
                %here..i.e. go to position using either digital
                %(moveComplete) or analog (FastZPosnGotoAO) operation
            else
                assert(numel(val)==3,'Motor position should have three elements.')
                if ~isequal(val,obj.hMotor.positionRelative) % clause is redundant
                    obj.hMotor.moveCompleteRelative(val);
                end
            end
        end
        
        
        function set.motorUserDefinedPositions(obj,val)
            obj.zprvAssertFocusOrIdle('motorUserDefinedPositions');
            val = obj.validatePropArg('motorUserDefinedPositions',val);
            cellfun(@(v)validateattributes(v,{'numeric'},{'size' [1 obj.motorPositionLength]}), val);  %TODO: Use prop-replacement to directly specify this as part of the property metadata
            obj.motorUserDefinedPositions = val;
        end
        
        function set.pmtEnable(obj,val)
            if isempty(obj.hPMT)
                return;
            end
            obj.zprvAssertFocusOrIdle('pmtEnable');
            val = obj.validatePropArg('pmtEnable',val);
            
            obj.hPMT.pmtEnable1 = val(1);
            obj.hPMT.pmtEnable2 = val(2);
        end
        
        function set.pmtGain(obj,val)
            if isempty(obj.hPMT)
                return;
            end
            obj.zprvAssertFocusOrIdle('pmtGain');
            val = obj.validatePropArg('pmtGain',val);
            
            obj.hPMT.pmtGain1 = val(1);
            obj.hPMT.pmtGain2 = val(2);
        end
        
        function set.scanFramePeriod(obj,val)
            obj.mdlDummySetProp(val,'scanFramePeriod');
        end
        
        function set.scanFrameRate(obj,val)
            obj.mdlDummySetProp(val,'scanFrameRate');
            
            %Side effects
            obj.zprpUpdateFrameAcqFcnDecimationFactor();
            obj.zprvBeamsUpdateFlybackBuffer();
            obj.zprvFastZUpdateAODataNormalized();
        end
        
        function set.scanFOVAngularRangeFast(obj,val)
            obj.zprvAssertIdle('scanFOVAngularRangeFast');
            val = obj.validatePropArg('scanFOVAngularRangeFast',val);
            
            assert(abs(val) <= obj.mdfData.scannerMaxAngularRange,obj.genAssertMsg(val)); %LSM max scan range is fixed by scanner, not by user setting
            
            obj.scanFOVAngularRangeFast = val;
            
            obj.scanZoomFactorFOV =  obj.mdfData.scannerMaxAngularRange / obj.scanFOVAngularRangeFast;
            
            %Fast/slow scan angular ranges are linked
            if obj.scanFOVAngularRangeSlow ~= val
                obj.scanFOVAngularRangeSlow = obj.scanFOVAngularRangeFast;
            end
        end
        
        function set.scanFOVAngularRangeSlow(obj,val)
            obj.zprvAssertIdle('scanFOVAngularRangeSlow');
            val = obj.validatePropArg('scanFOVAngularRangeSlow',val);
            
            assert(abs(val) <= obj.mdfData.scannerMaxAngularRange,obj.genAssertMsg(val)); %LSM max scan range is fixed by scanner, not by user setting
            
            obj.scanFOVAngularRangeSlow = val;
            
            obj.scanZoomFactorFOV =  obj.mdfData.scannerMaxAngularRange / obj.scanFOVAngularRangeSlow;
            
            %Fast/slow scan angular ranges are linked
            if obj.scanFOVAngularRangeFast ~= val
                obj.scanFOVAngularRangeFast = obj.scanFOVAngularRangeSlow;
            end
        end
     
        function set.scanAngleMultiplierSlow(obj,val)
            obj.zprvAssertFocusOrIdle('scanAngleMultiplierSlow');
            val = obj.validatePropArg('scanAngleMultiplierSlow',val);
            
            if ~isempty(obj.hBeams)
                obj.hBeams.stop();
            end
            
            obj.zprvPauseFocus(); % TAPIR
            
            abort = false;
            if val == 0
                obj.scanAngleMultiplierSlow = 0;
                obj.hLSM.scanAngleMultiplierSlow = 0; % PR2014
                %Side effects
                if ~isempty(obj.hBeams)
                    %obj.hBeams.stop();
                    if obj.betweenFrames
                        obj.hBeams.set('pauseTrigType','DAQmx_Val_DigLvl','digLvlPauseTrigWhen','DAQmx_Val_Low','digLvlPauseTrigSrc',sprintf('PFI%d',obj.mdfData.extFrameClockTerminal));
                    else
                        obj.hBeams.set('pauseTrigType','DAQmx_Val_None'); %Disable pause-triggering - there is no slow-mirror flyback to be blanked out
                    end
                    if ~obj.isIdle()
                        obj.hBeams.start();
                    end
                end
                
                obj.hLSM.galvoEnable = 0;
                
            else
                %Handle transition from line-scan to area scan: pixelsPerLine > linesPerFrame & square pixelation constraints apply
                if obj.scanLinesPerFrame > obj.scanPixelsPerLine || (obj.scanForceSquarePixelation && obj.scanPixelsPerLine > obj.scanLinesPerFrame)
                    obj.scanAngleMultiplierSlow = val;
                    obj.hLSM.scanAngleMultiplierSlow = val;
                    obj.scanLinesPerFrame = obj.scanPixelsPerLine; %Will (eigen)set scanAngleMultiplierSlow again - no need for following logic
                    abort = true;
                else
                    aspectRatio = obj.scanLinesPerFrame / obj.scanPixelsPerLine;
                    pixAspectRatio = val / aspectRatio; %Convert SAM to pixel aspect ratio
                    
                    %Apply constraint
                    if obj.scanForceSquarePixel
                        pixAspectRatio =  1;
                    end
                    
                    obj.hLSM.aspectRatioY = max(1,round(pixAspectRatio * 100)); % PR2014 
                    obj.scanAngleMultiplierSlow = (obj.hLSM.aspectRatioY/100) * aspectRatio; %Convert from pixel aspect ratio to SAM
                    obj.hLSM.scanAngleMultiplierSlow = obj.scanAngleMultiplierSlow;
                    %Side-effects
                    if ~isempty(obj.hBeams)
                        %obj.hBeams.stop();
%                         obj.hBeams.set('pauseTrigType','DAQmx_Val_None');% DAQmx_Val_DigLvl'); %Restore pause triggering
                        if obj.betweenFrames
                            obj.hBeams.set('pauseTrigType','DAQmx_Val_DigLvl','digLvlPauseTrigWhen','DAQmx_Val_Low','digLvlPauseTrigSrc',sprintf('PFI%d',obj.mdfData.extFrameClockTerminal));
                        else
                            obj.hBeams.set('pauseTrigType','DAQmx_Val_None'); %Disable pause-triggering - there is no slow-mirror flyback to be blanked out
                        end
                        if ~obj.isIdle()
                            obj.hBeams.start();
                        end
                    end
                    
                    obj.hLSM.galvoEnable = ~obj.galvoEnable;
                    
                end
                
            end
            
            if abort
                return;
            end
            
            %Update galvo scan pattern (stopping galvo scan in
            %process), as applicable
            focusingNow = ~obj.isIdle();
            galvoRestart = focusingNow && obj.galvoEnable;
            
            
            if focusingNow
                %Stop & restart LSM, flushing any queued-up FrameAcquiredFcn calls
                obj.zprvUpdateChannelDisplayRatioAndLims();
                obj.zprvResumeFocus(true); %Calls zprvSetLSMJITParams() & obj.zprpUpdateGalvoProps();
                
                if galvoRestart %Restart galvo Task - waiting on frame trigger
                    obj.hGalvos.start();
                end
            else
                obj.zprvSetLSMJITParams('idle'); % TAPIR
                obj.zprpUpdateGalvoProps();
            end
            
        end
        
        
        function set.scanFillFraction(obj,val)
            obj.zprvAssertFocusOrIdle('scanFillFraction');
            val = obj.validatePropArg('scanFillFraction',val);
            obj.scanFillFraction = val;
            
            %Dependencies
            obj.zprvBeamsUpdateFlybackBuffer();
        end
        
        function set.scanFillFractionSpatial(obj,val)
            obj.mdlDummySetProp(val,'scanFillFractionSpatial');
        end
        
        function set.scanForceSquarePixelation(obj,val)
            obj.validatePropArg('scanForceSquarePixelation',val);
            obj.scanForceSquarePixelation = val;
            
            %Side-effects
            if val && obj.scanLinesPerFrame ~= obj.scanPixelsPerLine && obj.scanAngleMultiplierSlow > 0
                obj.scanLinesPerFrame = obj.scanPixelsPerLine;
            end
        end
        
        
        function set.scanForceSquarePixel(obj,val)
            obj.validatePropArg('scanForceSquarePixel',val);
            obj.scanForceSquarePixel = val;
            
            %Side-effects
            if val && obj.scanAngleMultiplierSlow > 0
                obj.scanAngleMultiplierSlow = obj.scanLinesPerFrame/obj.scanPixelsPerLine;
            end
        end
        
        function set.scanForceSquarePixel_(obj,val)
            obj.mdlDummySetProp(val,'scanForceSquarePixel_');
        end
        
        function set.scanForceSquarePixelation_(obj,val)
            obj.mdlDummySetProp(val,'scanForceSquarePixelation_');
        end
        
        function set.scanMode(obj,val)
            obj.zprvAssertFocusOrIdle('scanMode');
            obj.validatePropArg('scanMode',val);
            assert(ismember(val,{'unidirectional' 'bidirectional'}),obj.genAssertMsg(val));
            
            obj.scanMode = val;
            
            %Dependencies
            %obj.acqNumFrames = obj.acqNumFrames; %#ok<*MCSUP>
            obj.zprvBeamsUpdateFlybackBuffer();
        end
        
        function set.scanLinesPerFrame(obj,val)
%             val = 1
            obj.zprvAssertFocusOrIdle('scanLinesPerFrame');
            val = obj.validatePropArg('scanLinesPerFrame',val);
            
            if obj.scanSetPixelationPropFlag %#ok<*MCSUP>
                obj.scanLinesPerFrame = val;
            else
                obj.zprpSetPixelationProp('scanLinesPerFrame',val);
            end
        end
        
        
        function set.scanPixelsPerLine(obj,val)
            
            obj.zprvAssertFocusOrIdle('scanZoomFactor');
            val = obj.validatePropArg('scanPixelsPerLine',val);
            
            if obj.scanSetPixelationPropFlag
                obj.scanPixelsPerLine = val;
            else
                obj.zprpSetPixelationProp('scanPixelsPerLine',val);
            end
        end
        
        function set.xCorrChannel(obj,val)
            val = obj.validatePropArg('xCorrChannel',val);
            obj.xCorrChannel = val;
        end
        
        function set.scanMinZoomFactor(obj,val)
            obj.zprvAssertIdle('scanMinZoomFactor');
            val = obj.validatePropArg('scanMinZoomFactor',val);
            obj.scanMinZoomFactor = val;
            
            %Dependencies
            obj.scanZoomFactor = obj.scanZoomFactor;
        end
        
        function set.scanZoomFactor(obj,val)
            obj.zprvAssertFocusOrIdle('scanZoomFactor');
            val = obj.validatePropArg('scanZoomFactor',val); %allow during acq
            
            %TODO: This type of constraint -- one property setting range of another -- shoudl be handled automatically by validatePropArg, using property-name 'replacement' in the property metadata
            %Constrain by scanMinZoomFactor
            val = max(obj.scanMinZoomFactor,val);
            focusingNow = ~obj.isIdle();
            if ~isempty(obj.hBeams)
                obj.hBeams.stop();
            end
            
            %Update LSM field-size
            zoomFactorTotal = obj.scanZoomFactorFOV * val;

            fieldSize = obj.hLSM.zoom2FieldSize(zoomFactorTotal);
            
            %Update LSM fieldSize
            obj.hLSM.fieldSize = fieldSize;
            % update scanphases using the scanphase cell (map), PR2014-08-20
            temp_var = obj.scanphases{fieldSize}(2);
            obj.lineScan_delay1 = temp_var;
            temp_var = obj.scanphases{fieldSize}(3);
            obj.lineScan_delay2 = temp_var;
            
            obj.scanZoomFactor = obj.hLSM.fieldSize2Zoom(fieldSize);
            obj.hLSM.scanZoomFactor = obj.scanZoomFactor;

            obj.zprvPauseFocus(); %Stops LSM processing
            

            %Update galvo scan pattern (stopping & re-arming galvo scan), as applicable
            galvoRestart = focusingNow && obj.galvoEnable;
            
            noFrameRate = obj.zprpUpdateGalvoProps();
            
            if noFrameRate
                obj.abort();
                if galvoRestart
                    fprintf(2,'ScanImage: Scan frame rate not measured at newly specified scanZoomFactor. Aborting. \n');
                end
            else
                if galvoRestart  %Restart galvo/beam Tasks - waiting on frame/line  trigger (respectively)
                    obj.hGalvos.start();
                end
                
                if ~isempty(obj.hBeams)
                    obj.hBeams.start();
                end
                
                obj.zprvResumeFocus();
            end
            
            
        end
        
        function scanZoomFactorChangeX(obj,val)
            obj.zprvAssertFocusOrIdle('scanZoomFactor');
            val = obj.validatePropArg('scanZoomFactor',val); %allow during acq
            
            %Constrain by scanMinZoomFactor
            val = max(obj.scanMinZoomFactor,val);
            focusingNow = ~obj.isIdle();
            if ~isempty(obj.hBeams)
                obj.hBeams.stop();
            end
            
            %Update LSM field-size
            zoomFactorTotal = obj.scanZoomFactorFOV * val;

            fieldSize = obj.hLSM.zoom2FieldSize(zoomFactorTotal);
            
            %Update LSM fieldSize
            obj.hLSM.fieldSize = fieldSize;
            % update scanphases using the scanphase cell (map), PR2014-08-20
            temp_var = obj.scanphases{fieldSize}(2);
            obj.lineScan_delay1 = temp_var;
            temp_var = obj.scanphases{fieldSize}(3);
            obj.lineScan_delay2 = temp_var;
            
            obj.scanZoomFactor = obj.hLSM.fieldSize2Zoom(fieldSize);
            obj.hLSM.scanZoomFactor = obj.scanZoomFactor;

            obj.zprvPauseFocus(); %Stops LSM processing
            

            %Update galvo scan pattern (stopping & re-arming galvo scan), as applicable
            galvoRestart = focusingNow && obj.galvoEnable;
            
            noFrameRate = obj.zprpUpdateGalvoProps();
            
            if noFrameRate
                obj.abort();
                if galvoRestart
                    fprintf(2,'ScanImage: Scan frame rate not measured at newly specified scanZoomFactor. Aborting. \n');
                end
            else
                if galvoRestart  %Restart galvo/beam Tasks - waiting on frame/line  trigger (respectively)
                    obj.hGalvos.start();
                end
                
                if ~isempty(obj.hBeams)
                    obj.hBeams.start();
                end
                
                obj.zprvResumeFocus();
            end
            
            
        end
        
        
        
        function set.scanPixelTimeMean(obj,val)
            obj.mdlDummySetProp(val,'scanPixelTimeMean');
        end
        
        function set.scanPixelTimeMaxMinRatio(obj,val)
            obj.mdlDummySetProp(val,'scanPixelTimeMaxMinRatio');
        end
        
        function set.scanPixelTimeStats(obj,val)
            obj.mdlDummySetProp(val,'scanPixelTimeStats');
        end
        
        function set.shutterDelay(obj,val)
            obj.zprvAssertIdle('shutterDelay');
            val = obj.validatePropArg('shutterDelay',val);
            
            %For now - force property value to 0. The shutterDelay feature is not supported as of SI 4.1
            if val > 0
                fprintf(2,'WARNING: Shutter delay values > 0 not supported at this time. Forcing value to 0.\n');
                val = 0;
            end
            
            obj.shutterDelay = val;
        end

        function set.maxValueShow(obj,val)
            obj.zprvAssertFocusOrIdle('stackNumSlices');
            val = obj.validatePropArg('maxValueShow',val);
            if isnan(val); val = 1; end
            obj.maxValueShow = val;
        end
        function set.meanValueShow(obj,val)
            obj.zprvAssertFocusOrIdle('stackNumSlices');
            val = obj.validatePropArg('meanValueShow',val);
            if isnan(val); val = 1; end
            obj.meanValueShow = val;
        end
        
        function set.mergeAlign(obj,val)
            obj.zprvAssertFocusOrIdle('stackNumSlices');
            val = obj.validatePropArg('mergeAlign',val);
            if isnan(val); val = 0; end
            obj.mergeAlign = val;
        end
        function set.mergeshift(obj,val)
            obj.zprvAssertFocusOrIdle('stackNumSlices');
            val = obj.validatePropArg('mergeshift',val);
            if isnan(val); val = 0; end
            obj.mergeshift = val;
        end
        
        function set.extClockLevel(obj,val)
            obj.zprvAssertFocusOrIdle('stackNumSlices');
            val = obj.validatePropArg('extClockLevel',val);
            obj.extClockLevel = val;
            
            obj.hLSM.alazarClockLevel = val;
            obj.hLSM.changeAlazarDelay;
        end
        
        function set.extClockEdge(obj,val)
            obj.zprvAssertFocusOrIdle('stackNumSlices');
            val = obj.validatePropArg('extClockEdge',val);
            obj.extClockEdge = val;
            CLOCK_EDGE_FALLING = 1; % from ATS-SDK
            CLOCK_EDGE_RISING = 0;
            if val
                obj.hLSM.clockFallOrRise = CLOCK_EDGE_FALLING;
            else
                obj.hLSM.clockFallOrRise = CLOCK_EDGE_RISING;
            end
            obj.hLSM.changeAlazarDelay;
        end
        
        function triggerOutSet(obj)
            try
                obj.triggerOutputTask.clear();
            end
            import dabs.ni.daqmx.*
            obj.triggerOutputTask = Task('Trigger Output Task');
            obj.triggerOutputTask.createDOChan(obj.mdfData.scanDevice,sprintf('port%d/line%d',0,4));
            obj.triggerOutputTask.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.mdfData.trigSelfTrigDestinationTerminal));
%             obj.triggerOutputTask.set('startTrigRetriggerable',1);
            obj.triggerOutputTask.cfgSampClkTiming(50,'DAQmx_Val_FiniteSamps',4000);
            obj.triggerOutputTask.cfgOutputBuffer(4000);
            y = [false(obj.triggerOutDelay*50,1)' true(obj.triggerOutDuration*50,1)' false(max(0,4000-obj.triggerOutDuration*50-obj.triggerOutDelay*50),1)']';
            y(end) = false;
            obj.triggerOutputTask.writeDigitalData(y);
        end
        function set.savedBitdepth(obj,val)
            obj.zprvAssertFocusOrIdle('savedBitdepth');
            val = obj.validatePropArg('savedBitdepth',val);
            obj.savedBitdepth = val;
            if val == 1
                obj.savedBitdepthX = 8;
                obj.autoscaleSavedImages = 1;
            else
                obj.savedBitdepthX = 16;
            end
        end
        
        function set.ATnbslices(obj,val)
            obj.zprvAssertFocusOrIdle('ATnbslices');
            val = obj.validatePropArg('ATnbslices',val);
            obj.ATnbslices = val;
        end
        function set.ATzrange(obj,val)
            obj.zprvAssertFocusOrIdle('ATzrange');
            val = obj.validatePropArg('ATzrange',val);
            obj.ATzrange = val;
        end
        function set.ATnbframes(obj,val)
            obj.zprvAssertFocusOrIdle('ATnbframes');
            val = obj.validatePropArg('ATnbframes',val);
            obj.ATnbframes = val;
        end     
        function set.ATduringFocusing(obj,val)
            obj.zprvAssertFocusOrIdle('ATduringFocusing');
            val = obj.validatePropArg('ATduringFocusing',val);
            obj.ATduringFocusing = val;
        end     
                
        function set.write2RAM(obj,val)
            obj.zprvAssertFocusOrIdle('write2RAM');
            val = obj.validatePropArg('write2RAM',val);
            obj.write2RAM = val;
            if obj.write2RAM
                obj.offlineAveraging = 0;
            end
            obj.hLSM.write2RAM = obj.write2RAM;
        end
        function set.offlineAveraging(obj,val)
            obj.zprvAssertFocusOrIdle('offlineAveraging');
            val = obj.validatePropArg('offlineAveraging',val);
            obj.offlineAveraging = val;
            if obj.write2RAM == 1
                obj.offlineAveraging = 0;
            end
        end
        
        function set.savedBitdepthX(obj,val)
            obj.savedBitdepthX = val;
        end
        
        function set.triggerOut(obj,val)
            obj.zprvAssertFocusOrIdle('triggerOut');
            val = obj.validatePropArg('triggerOut',val);
            obj.triggerOut = val;
        end
        function set.triggerOutDelay (obj,val)
            obj.zprvAssertFocusOrIdle('triggerOutDelay');
            val = obj.validatePropArg('triggerOutDelay',val);
            obj.triggerOutDelay = val;
        end
        function set.triggerOutDuration (obj,val)
            obj.zprvAssertFocusOrIdle('triggerOutDuration');
            val = obj.validatePropArg('triggerOutDuration',val);
            obj.triggerOutDuration = val;
            if obj.triggerOut
                obj.triggerOutSet();
            else
                if ~isempty(obj.triggerOutputTask)
                    obj.triggerOutputTask.clear();
                end
            end
        end

        function set.stackNumSlices(obj,val)
            obj.zprvAssertFocusOrIdle('stackNumSlices');
            val = obj.validatePropArg('stackNumSlices',val);
            
            if ~obj.motorHasMotor && ~obj.fastZAvailable
                obj.stackNumSlices = 1;
                return;
            end
            
            if isnan(val)
                val = 1;
            end
            
            obj.stackNumSlices = val;
            
            %Enforce FrameAcqFcnDecimationFactor constraint
            obj.stackNumSlices = obj.zprpApplyFAFDecFactorConstraint('stackNumSlices');
            
            %Side effects
            if obj.stackStartEndPointsDefined && ~obj.fastZEnable && val >= 2
                % Don't set stepsize to Inf if numSlices==1, this is
                % potentially dangerous. Leave it at its previous value.
                stepsize = obj.zprpStackComputeZStepSize();
                if ~isequalwithequalnans(stepsize,obj.stackZStepSize)
                    obj.stackZStepSize = stepsize;
                end
            end
            
            obj.zprvFastZUpdateAODataNormalized();
        end
        
        function set.stackZStepSize(obj,val)
            obj.zprvAssertFocusOrIdle('stackZStepSize');
            val = obj.validatePropArg('stackZStepSize',val);
            
            if ~obj.motorHasMotor && ~obj.fastZAvailable
                obj.stackZStepSize = nan;
                return;
            end
            
            obj.stackZStepSize = val;
            if obj.stackStartEndPointsDefined && ~obj.fastZEnable
                numSlices = obj.zprpStackComputeNumSlices();
                obj.zprvSetInternal('stackNumSlices',numSlices);
            end
            
            obj.zprvFastZUpdateAODataNormalized();
        end
        
        function set.stackZStartPos(obj,val)
            obj.zprvAssertFocusOrIdle('stackZStartPos');
            val = obj.validatePropArg('stackZStartPos',val);
            obj.stackZStartPos = val;
            if obj.stackStartEndPointsDefined && ~obj.fastZEnable && obj.stackNumSlices >= 2
                obj.stackZStepSize = obj.zprpStackComputeZStepSize();
            end
            obj.stackLastStartEndPositionSet = val; % does the right thing if val is nan (val==nan functionally means "clear the starting pos")
            
            %Side effects
            obj.acqBeamLengthConstants = []; %Force recompute on next use
        end
        
        function set.stackZEndPos(obj,val)
            obj.zprvAssertFocusOrIdle('stackZEndPos');
            val = obj.validatePropArg('stackZEndPos',val);
            obj.stackZEndPos = val;
            if obj.stackStartEndPointsDefined && ~obj.fastZEnable && obj.stackNumSlices >= 2
                obj.stackZStepSize = obj.zprpStackComputeZStepSize();
            end
            obj.stackLastStartEndPositionSet = val; % does the right thing if val is nan
            
            %Side effects
            obj.acqBeamLengthConstants = []; %Force recompute on next use
        end
        
        function set.statusString(obj,val)
            obj.validatePropArg('statusString',val);
            obj.statusString = val;
        end
        
        function v = get.stackStartEndPointsDefined(obj)
            v = ~isnan(obj.stackZStartPos) && ~isnan(obj.stackZEndPos);
        end
        
        function v = get.stackStartEndPowersDefined(obj)
            % TODO: this is beam-idxed
            v = ~isnan(obj.stackStartPower) && ~isnan(obj.stackEndPower);
        end
        
        function set.stackStartPower(obj,val)
            obj.zprvAssertFocusOrIdle('stackStartPower');
            val = obj.validatePropArg('stackStartPower',val);
            val = obj.zprpBeamScalarExpandPropValue(val,'stackStartPower');
            obj.stackStartPower = val;
            
            %Side effects
            obj.acqBeamLengthConstants = []; %Force recompute on next use
        end
        
        function set.stackEndPower(obj,val)
            obj.zprvAssertFocusOrIdle('stackEndPower');
            val = obj.validatePropArg('stackEndPower',val);
            val = obj.zprpBeamScalarExpandPropValue(val,'stackEndPower');
            obj.stackEndPower = val;
            
            %Side effects
            obj.acqBeamLengthConstants = []; %Force recompute on next use
        end
        
        function set.showMeanLive(obj,val)
            obj.zprvAssertFocusOrIdle('showMeanLive');
            val = obj.validatePropArg('showMeanLive',val);
            obj.showMeanLive = val;
        end
        function set.stackUseStartPower(obj,val)
            obj.zprvAssertFocusOrIdle('stackUseStartPower');
            val = obj.validatePropArg('stackUseStartPower',val);
            obj.stackUseStartPower = val;
        end
        
        function set.stackUserOverrideLz(obj,val)
            obj.zprvAssertFocusOrIdle('stackUserOverrideLz');
            val = obj.validatePropArg('stackUserOverrideLz',val);
            obj.stackUserOverrideLz = val;
            if val && ~obj.stackUseStartPower
                warning('SI4:stackUserOverrideLzWithoutStackUseStartPower',...
                    'StackUseStartPower is currently false.');
            end
            
            %Side effects
            obj.acqBeamLengthConstants = []; %Force recompute on next use
            
        end
        
        function set.stackReturnHome(obj,val)
            obj.zprvAssertFocusOrIdle('stackReturnHome');
            val = obj.validatePropArg('stackReturnHome',val);
            obj.stackReturnHome = val;
        end
        
        function set.stackStartCentered(obj,val)
            obj.zprvAssertFocusOrIdle('stackStartCentered');
            val = obj.validatePropArg('stackStartCentered',val);
            obj.stackStartCentered = val;
        end
        
        function set.triggerExtTrigEnable(obj,val)
            obj.zprvAssertIdle('triggerExtTrigEnable');
            val = obj.validatePropArg('triggerExtTrigEnable',val);
            obj.triggerExtTrigEnable = val;
            
            obj.zprpUpdateTriggerProps(); %Updates counter channel trigger sources/edges
        end
        
        function set.triggerStartTrigSrc(obj,val)
            obj.zprvAssertIdle('triggerStartTrigSrc');
            val = obj.validatePropArg('triggerStartTrigSrc',val);
            obj.triggerStartTrigSrc = val;
            
            obj.zprpUpdateTriggerProps(); %Updates counter channel trigger sources/edges
        end
        
        function set.triggerStartTrigEdge(obj,val)
            obj.zprvAssertIdle('triggerStartTrigEdge');
            val = obj.validatePropArg('triggerStartTrigEdge',lower(val));
            obj.triggerStartTrigEdge = lower(val);
            
            obj.zprpUpdateTriggerProps(); %Updates counter channel trigger sources/edges
        end
        
        function set.triggerNextTrigSrc(obj,val)
            obj.zprvAssertIdle('triggerNextTrigSrc');
            val = obj.validatePropArg('triggerNextTrigSrc',val);
            obj.triggerNextTrigSrc = val;
            
            obj.zprpUpdateTriggerProps(); %Updates counter channel trigger sources/edges
        end
        
        function set.triggerNextTrigEdge(obj,val)
            obj.zprvAssertIdle('triggerNextTrigEdge');
            val = obj.validatePropArg('triggerNextTrigEdge',lower(val));
            obj.triggerNextTrigEdge = lower(val);
            
            obj.zprpUpdateTriggerProps(); %Updates counter channel trigger sources/edges
        end
        
        function set.triggerNextTrigMode(obj,val)
            obj.zprvAssertIdle('triggerNextTrigMode');
            val = obj.validatePropArg('triggerNextTrigMode',lower(val));
            obj.triggerNextTrigMode = val;
        end
        
        function set.triggerExtStartTrigTimeout(obj,val)
            obj.zprvAssertIdle('triggerExtStartTrigTimeout');
            val = obj.validatePropArg('triggerExtStartTrigTimeout',val);
            obj.hLSM.triggerTimeout = val;
            
            obj.triggerExtStartTrigTimeout = val;
        end
        
        function set.triggerMaxLoopInterval(obj,val)
            obj.zprvAssertIdle('triggerMaxLoopInterval');
            val = obj.validatePropArg('triggerMaxLoopInterval',val);
            obj.triggerMaxLoopInterval = val;
            
            %Re-create hTriggerPeriodCtr Task, if needed
            switch val
                case 42.95
                    clockRate = 100e6;
                case 214.75
                    clockRate = 20e6;
                case 42950
                    clockRate = 100e3;
                otherwise
                    assert(false);
            end
            min = 2/clockRate;
            max = (2^32-1)/clockRate;
            
            assert(~isempty(obj.hTriggerPeriodCtr));
            if get(obj.hTriggerPeriodCtr.channels(1),'min') ~= min
                assert(all(isvalid(obj.hAllTasks)));
                delete(obj.hTriggerPeriodCtr);
                obj.hAllTasks(~isvalid(obj.hAllTasks)) = [];
                
                obj.hTriggerPeriodCtr = obj.zprvDaqmxTask('Trigger Period Counter');
                obj.hTriggerPeriodCtr.createCIPeriodChan(obj.mdfData.primaryDeviceID,1,[],[],min,max); %Uses ctr1
                obj.hTriggerPeriodCtr.cfgImplicitTiming('DAQmx_Val_ContSamps');
                
                obj.hTimestampCounters(end+1) = obj.hTriggerPeriodCtr;
                obj.hTimestampCounters(~isvalid(obj.hTimestampCounters)) = [];
                
                %Ensure trigger source/edge props are set
                obj.zprpUpdateTriggerProps();
                
            end
        end
        
        function set.triggerMaxLoopIntervalFrames(obj,val)
            obj.zprvAssertIdle('triggerMaxLoopIntervalFrames');
            val = obj.validatePropArg('triggerMaxLoopIntervalFrames',val);
            set(obj.hFramePeriodCtr,'bufInputBufSize',val);
            obj.triggerMaxLoopIntervalFrames = val;
        end
        
        function set.userFunctionsCfg(obj,val)
            obj.zprvAssertIdle('userFunctionsCfg');
            if isempty(val)
                val = struct('EventName',cell(0,1),'UserFcnName',[],'Arguments',[],'Enable',[]);
            end
            
            % Validate the new value
            obj.zprpUserFunctionValidate(val,'EventName',obj.userFunctionsEvents);
            
            % Adjust listeners
            obj.zprvUserFunctionsConfigureListeners('userFunctionsCfgListeners',val);
            
            obj.userFunctionsCfg = val;
        end
        
        function set.userFunctionsUsr(obj,val)
            obj.zprvAssertIdle('userFunctionsUsr');
            if isempty(val)
                val = struct('EventName',cell(0,1),'UserFcnName',[],'Arguments',[],'Enable',[]);
            end
            
            % Validate new value
            allEvents = [obj.userFunctionsEvents;obj.userFunctionsUsrOnlyEvents];
            obj.zprpUserFunctionValidate(val,'EventName',allEvents);
            
            % Adjust listeners
            obj.zprvUserFunctionsConfigureListeners('userFunctionsUsrListeners',val);
            
            obj.userFunctionsUsr = val;
        end
        
        function set.userFunctionsOverride(obj,val)
            obj.zprvAssertIdle('userFunctionsOverride');
            if isempty(val)
                val = struct('Function',cell(0,1),'UserFcnName',[],'Enable',[]);
            end
            obj.zprpUserFunctionValidate(val,'Function',obj.userFunctionsOverrideFunctions,false);
            
            % Set up userFunctionsOverriddenFcns2UserFcns
            fcnMap = struct();
            for c = 1:numel(val)
                s = val(c);
                if s.Enable
                    assert(~isfield(fcnMap,s.Function),...
                        'Function ''%s'' is overridden more than once.',s.Function);
                    fcnMap.(s.Function) = s.UserFcnName;
                end
            end
            obj.userFunctionsOverriddenFcns2UserFcns = fcnMap;
            
            obj.userFunctionsOverride = val;
        end
        
        function set.usrPropListCurrent(obj,val)
            obj.zprvAssertIdle('usrPropListCurrent');
            val = obj.validatePropArg('usrPropListCurrent',val);
            
%             if isempty(intersect(obj.usrAvailableUsrPropList,'scanphases')) % Workaround, PR2014-10-06
%             keyboard
%                 [obj.usrPropListCurrent,goodIdxs] = intersect(val,obj.usrAvailableUsrPropList);
%                 obj.usrPropListCurrent{end +1} = 'scanphases';
%             else
                [obj.usrPropListCurrent,goodIdxs] = intersect(val,obj.usrAvailableUsrPropList);
%             end
            if length(goodIdxs) < length(val)-1 % workaround for scanphases property, PR2014-10-06
                warning('SI4:invalidUsrProp',...
                    'Ignoring one or more properties that cannot be saved to a USR file.');
            end
        end
        
        
    end
    
    %Property-access helpers
    methods (Hidden)
        
        function val = zprpGetScanLinePeriodVal(obj,scannerPeriodVal)
            isBidi = isequal(obj.scanMode,'bidirectional');
            bidiFactor = 2^1; %1 for unidi; 2 for bidi
            
            val = scannerPeriodVal/bidiFactor;            
        end
        
        function zprpUpdateMDFVar(obj,mdfVarName,val) %#ok<INUSL>
            mdf = most.MDF.getInstance();
            if mdf.isLoaded
                obj.mdfData.(mdfVarName) = val;
                mdf.writeVarToHeading('ScanImage',mdfVarName,val);
            end
        end
        
        function zprpSetPixelationProp(obj,propName,val)
            if obj.mdlInitialized
                pplOld = obj.scanPixelsPerLine;
                lpfOld = obj.scanLinesPerFrame;
            else
                pplOld = obj.hLSM.pixelsPerLine;
                lpfOld = obj.hLSM.linesPerFrame;
            end
            
            pplNew = pplOld;
            lpfNew = lpfOld;
            [changePPL,changeLPF] = deal(false);
            
            switch propName
                case 'scanPixelsPerLine'
                    pplNew = val;
                    
                    if pplNew ~= pplOld
                        changePPL = true;
                        if obj.scanForceSquarePixelation_
                            lpfNew = val;
                            changeLPF = true;
                        end
                    end
                case 'scanLinesPerFrame'
                    lpfNew = val;
                    
                    if lpfNew ~= lpfOld
                        changeLPF = true;
                        if obj.scanForceSquarePixelation_
                            pplNew = val;
                            changePPL = true;
                        end
                    end
                otherwise
                    assert(false);
            end
            
            if obj.scanAngleMultiplierSlow > 0
                assert(pplNew >= lpfNew,'scanLinesPerFrame > scanPixelsPerLine is not allowed at this time, except for line-scanning');
            end
            
            if ~any([changePPL changeLPF])
                return;
            end
            
            obj.zprvPauseFocus(); %Stops LSM processing
            
            obj.scanSetPixelationPropFlag = true;
            
            obj.scanPixelsPerLine = pplNew; % RETEP, ???
            obj.scanLinesPerFrame = lpfNew;
            
            obj.scanSetPixelationPropFlag = false;
            
            %Set scanAngleMultiplierSlow. This has several side-effects:
            % 1. Calls zprvUpdateChannelDisplayRatioAndLims()
            % 2. Updates Y galvo output waveform, if needed
            % 3. Calls zprvResumeFocus()
            
            if obj.scanForceSquarePixel_
                obj.scanAngleMultiplierSlow = obj.scanLinesPerFrame/obj.scanPixelsPerLine; % RETEP
            else
                obj.scanAngleMultiplierSlow = obj.scanAngleMultiplierSlow;
            end
            
            obj.zprvResetBuffersIfFocusing(); %Clears acqFrameBuffer & displayRollingBuffer
            
        end
        
        function val = zprpValidateChannelsArray(obj,val,propName)
            %Further validation for the channelsSave,channelsDisplay props
            
            val = unique(val);
            assert(all(val) <= obj.channelsNumChannels,'Only channel values from 1-%d are supported',obj.channelsNumChannels);
            
            %Ensure at least one channel is active for saving or display
            if isempty(val)
                switch propName
                    case 'channelsDisplay'
                        otherProp = 'channelsSave';
                    case 'channelsSave'
                        otherProp = 'channelsDisplay';
                    otherwise
                        assert(false);
                end
                
                assert(~isempty(obj.(otherProp)),'One channel must be active for saving and/or display');
            end
        end
        
        function zprpUserFunctionValidate(obj,userFcnInfo,eventFieldName,eventsList,tfArguments) %#ok<MANU>
            if nargin < 5
                tfArguments = true;
            end
            
            % Check that the right struct fields are present
            expectedFields = {eventFieldName;'UserFcnName';'Enable'};
            if tfArguments
                expectedFields = [expectedFields;'Arguments'];
            end
            if ~isstruct(userFcnInfo) || ...
                    ~isequal(sort(fieldnames(userFcnInfo)),sort(expectedFields))
                errStr = sprintf('''%s'', ',expectedFields{:});
                errStr = errStr(1:end-2);
                error('SI4:invalidUserFcnFields',...
                    'Expected value to be a struct with fields %s.',errStr);
            end
            
            % All events must be in the eventsList
            evts = {userFcnInfo.(eventFieldName)}';
            assert(all(ismember(evts,eventsList)),'One or more invalid %s.',eventFieldName);
            
            % Warn if one or more UserFcnNames are not M-files on the path.
            % ! For now, don't do this, it can be annoying. !
            
            %             fcnNames = {userFcnInfo.UserFcnName}';
            %             tfNonemptyFcnDoesntExist = cellfun(@(x)~isempty(x) && exist(x,'file')~=2,fcnNames);
            %             if any(tfNonemptyFcnDoesntExist)
            %                 badFcnList = sprintf('''%s'', ',fcnNames{tfNonemptyFcnDoesntExist});
            %                 badFcnList = badFcnList(1:end-2);
            %                 warning('SI4:cantFindUserFunction',...
            %                     'Cannot find function(s) %s on the current MATLAB path.',badFcnList);
            %             end
            
            % Arguments
            if tfArguments
                args = {userFcnInfo.Arguments}';
                tfArgsOk = cellfun(@(x)iscell(x)&&(isvector(x)||isequal(x,{})),args);
                if any(~tfArgsOk)
                    error('SI4:invalidUserFunctionArguments',...
                        'Arguments for a user function must be a vector cell array.');
                end
            end
            
            % Enable
            enable = {userFcnInfo.Enable}';
            tfEnableOk = cellfun(@(x)isscalar(x)&&(islogical(x)||isnumeric(x)),enable);
            assert(all(tfEnableOk),'Enable field must be a scalar logical.');
        end
        
        function zprpSetCurrZoomProp(obj,propName,val)
            validateattributes(val,{'numeric'},{'scalar'});
            
            arrayPropName = sprintf('%sArray',propName);
            
            %if ~isscalar(obj.(arrayPropName)) %VI032411A: REMOVED
            
            currZoomIdx = min(round(obj.scanZoomFactor), length(obj.(arrayPropName)));
            obj.(arrayPropName)(currZoomIdx) = val;
            
            %end %VI032411A: REMOVED
            
        end
        
        function zprpUpdateLSMLoggingFilename(obj)
            if strcmpi(obj.acqState,'idle')
                obj.hLSM.loggingFileName = obj.loggingFullFileName;
            end
        end
        
        function val = zprpBeamScalarExpandPropValue(obj,val,propName)
            if isscalar(val)
                val = repmat(val,obj.beamNumBeams,1);
            else
                assert(numel(val)==obj.beamNumBeams,...
                    'The ''%s'' value must be a vector of length %d -- one value for each beam',...
                    propName,obj.beamNumBeams);
            end
        end
        
        
        function voltage = zprpBeamsPowerFractionToVoltage(obj,beamIdx,powerFrac)
            % Use the calibration LUT to look up the beam voltage needed to
            % achieve a certain beam power fraction.
            % powerFrac: real number vector on [0,1].
            % voltage: beam voltage vector that will achieve powerFrac
            
            validateattributes(beamIdx,{'numeric'},{'vector','integer','>=',1,'<=',obj.beamNumBeams});
            validateattributes(powerFrac,{'numeric'},{'vector','>=',0});
            
            powerFrac = max(powerFrac,obj.beamCalibrationMinAchievablePowerFrac(beamIdx));
            cappedIdxs = find(powerFrac > 1);
            if ~isempty(cappedIdxs)
                fprintf(2,'WARNING(%s): A power fraction > 1.0 was requested for beam %d (''%s''). Power capped at maximum value determined during last calibration.\n',class(obj),beamIdx,obj.mdfData.beamIDs{beamIdx});
            end
            
            powerFrac = max(powerFrac,obj.beamCalibrationMinAchievablePowerFrac(beamIdx));
            powerFrac(cappedIdxs) = 1.0;
            
            lutIdx = max(1,ceil(powerFrac*obj.beamCalibrationLUTSize)); % use ceil for now, minimum value of 1
            voltage = obj.beamCalibrationLUT(lutIdx,beamIdx);
            %assert(~isnan(voltage)); comment these for now b/c during SI4 construction/initialization, this method is called before the beams are calibrated.
            %assert(voltage <= obj.beamVoltageRanges(beamIdx));
        end
        
        function val = zprpStackComputeZStepSize(obj)
            dz = obj.stackZEndPos - obj.stackZStartPos;
            val = dz/(obj.stackNumSlices-1);
        end
        
        function val = zprpStackComputeNumSlices(obj)
            dz = obj.stackZEndPos - obj.stackZStartPos;
            if dz==0 && obj.stackZStepSize==0
                % edge case
                val = 1;
            else
                val = floor(dz/obj.stackZStepSize)+1;
            end
        end
        
        function zprpUpdateTriggerProps(obj)
            %Handles update to start/next trigger source/edge specification
            
            %Determine trigger source & edge
            if obj.triggerExtStartTrigUsed
                triggerSource = obj.triggerStartTrigSrc;
                triggerEdge = zlclEncodeTriggerEdge(obj.triggerStartTrigEdge);
            else
                triggerSource = obj.mdfData.trigSelfTrigDestinationTerminal;
                triggerEdge = zlclEncodeTriggerEdge('rising');
            end
            triggerSource = sprintf('PFI%d',triggerSource);
            obj.triggerStartTrigTerminal = triggerSource;
            
            %Assign trigger source/edge to counter chans
            %obj.hInitTimestampCtr.cfgDigEdgeStartTrig(triggerSource,triggerEdge);
            obj.hFrameClockDelayCtr.channels(1).set('twoEdgeSepFirstTerm',triggerSource,'twoEdgeSepFirstEdge',triggerEdge);
            obj.hTriggerPeriodCtr.channels(1).set('periodTerm',triggerSource,'periodStartingEdge',triggerEdge);
            obj.hTriggerCallbackCtr.set('sampClkSrc',triggerSource,'sampClkActiveEdge',triggerEdge);
            obj.xTrigCallback.set('sampClkSrc','PFI0','sampClkActiveEdge',triggerEdge);
            %Determine if using 'pure' next triggering
            obj.triggerNextTrigOnly = obj.triggerExtTrigEnable && ...
                ~isempty(obj.triggerStartTrigSrc) && ~isempty(obj.triggerNextTrigSrc) && ...
                obj.triggerStartTrigSrc == obj.triggerNextTrigSrc && ...
                strcmpi(obj.triggerStartTrigEdge,obj.triggerNextTrigEdge);
            
            
            %DEPENDENCIES
            obj.acqNumFrames = obj.acqNumFrames; %Force update of acqNumFrames
            obj.triggerExtTrigAvailable = obj.triggerExtTrigAvailable; %Force update of the trigger external availability property
            
        end
        
        function val = zprpEnsureChannelPropSize(obj,val)
            %Ensure correct size of channel property
            
            numChans = obj.channelsNumChannels;
            if length(val) < numChans
                if iscell(val)
                    [val{end+1:numChans}] = deal(val{end});
                else
                    val(end+1:numChans) = val(end);
                end
            else
                val = val(1:numChans);
            end
            
        end
        
        function zprpUpdateFrameAcqFcnDecimationFactor(obj)
            if isnan(obj.scanFrameRate)
                %Use nominal scanner frequency
                isBidi = isequal(obj.scanMode,'bidirectional');
                bidiFactor = 2^1;
                scanLinePeriodNominal = obj.mdfData.scannerFrequencyNominal * bidiFactor; % PR2014 -- errors in ScanImage
                scanFrameRateVal = scanLinePeriodNominal / obj.scanLinesPerFrame;
            else
                scanFrameRateVal = obj.scanFrameRate;
            end
            obj.frameAcqFcnDecimationFactor = ceil(scanFrameRateVal / obj.maxFrameEventRate); % PR2014 max framerate, to be revised
        end
        
        function val = zprpApplyFAFDecFactorConstraint(obj,constrainVar,fafDecFactor)
            
            if nargin < 3
                fafDecFactor = obj.frameAcqFcnDecimationFactor;
            end
            
            switch constrainVar
                case 'loggingFramesPerFile'
                    if isinf(obj.loggingFramesPerFile)
                        val = inf;
                    else
                        val = round(obj.loggingFramesPerFile / fafDecFactor) * fafDecFactor;
                    end
                case 'displayFrameBatchFactor'
                    val = ceil(obj.displayFrameBatchFactor / fafDecFactor) * fafDecFactor;
                case 'displayFrameBatchSelection'
                    val = unique(ceil(obj.displayFrameBatchSelection ./ fafDecFactor) .* fafDecFactor);
                case 'stackNumSlices'
                    if obj.fastZEnable
                        val = ceil(obj.stackNumSlices / fafDecFactor) * fafDecFactor;
                    else
                        val = obj.stackNumSlices;
                    end
                    constrainVar = 'stackNumSlices';
                case 'acqNumFrames'
                    if ~obj.fastZEnable;
                        val = ceil(obj.acqNumFrames / fafDecFactor) * fafDecFactor;
                    else
                        val = obj.acqNumFrames;
                    end
                    constrainVar = 'acqNumFrames';
                otherwise
                    assert(false);
            end
            
            %Update constrained property if output argument not returned
            if nargout == 0
                obj.(constrainVar) = val;
            end
        end
        
        function val = zprpLockDisplayRollAvgFactor(obj)
            %Identify (and apply or return) constrained displayRollingAverageFactor value - must be an integer multiple of frameAcqFcnDecimationFactor
            
            val = obj.displayRollingAverageFactor;
            
            constrainedRollAvgFactor = (obj.acqNumAveragedFrames / obj.frameAcqFcnDecimationFactor);
            if val ~= constrainedRollAvgFactor
                if constrainedRollAvgFactor == round(constrainedRollAvgFactor)
                    val = constrainedRollAvgFactor;
                else
                    val = 1;
                end
            end
            
            if nargout == 0
                obj.displayRollingAverageFactor = val;
            end
            
        end
        
        
        function noFrameRate = zprpUpdateGalvoProps(obj)
            %Updates Galvo scan pattern for Y or X/Y serial galvo
            %configurations. Stops running galvo scan during live
            %acquisition, if applicable.
            %
            % noFrameRate: True if operation cancelled due to lack of frameRate information at current scanZoomFactor
            
            %TODO: X/Y galvo implementation (only Y done now)
            
            noFrameRate = false;
            
            if ~obj.galvoEnable
                return;
            end
            
            %Stop galvo Task, if needed
            obj.hGalvos.abort();
            
            %Handle case where Frame rate has not been computed at current scanZoomFactor
            if isnan(obj.scanFrameRate)
                noFrameRate = obj.mdlInitialized; %Don't flag 'noFrameRate' if model is not yet initialized
                return;
            end
            
            obj.mroiComputedParams(:) = []; %Clear structure
            
            if ~obj.mroiEnabled
                obj.zprvGalvosUpdateAODataBuf1D();
            else
                obj.zprpUpdateMROIProps();
            end
            
        end
        
        function zprpUpdateMROIProps(obj)
            %TODO - implement galvo analog output waveform for specified angular X/Y coordinates and other mroiParams, in specified order
            %NOTES:
            % * Use mdfdata.galvoAcceleration and mdfdata.MaxVelocity
            % mroiParams = struct('scanShift',{},'scanAngleMultiplierSlow',{},'scanLinesPerFrame',{});
            
            %Compute Y galvo ramp during scanned lines/frame
            numROI = length(obj.mroiParams);
            
            LSMLinePeriodNominal = 1/obj.mdfData.scannerFrequencyNominal;
            lineSamplesNominal = LSMLinePeriodNominal * obj.mdfData.galvoCmdOutputRate;
            
            [xData,yData,transitNumSamplesFirst,roiCenterYFirst,roiRangeYFirst] = deal([]);
            
            %Add transit & dwell time waveforms for each ROI
            for i=1:numROI
                if i==1
                    lastROIIdx = numROI;
                else
                    lastROIIdx = i-1;
                end
                
                %Determine transit angles/time/lines to reach ROI
                transitAngles = obj.mroiParams(i).scanShift - obj.mroiParams(lastROIIdx).scanShift;
                
                roiRangeY = (obj.mdfData.scannerMaxAngularRange / obj.scanZoomFactor) * obj.mroiParams(i).scanAngleMultiplierSlow;
                lastROIRangeY = (obj.mdfData.scannerMaxAngularRange / obj.scanZoomFactor) * obj.mroiParams(lastROIIdx).scanAngleMultiplierSlow;
                
                transitAngles(2) = transitAngles(2) - roiRangeY/2 - lastROIRangeY/2;
                
                transitTime = max(sqrt(2 * abs(transitAngles) / obj.mdfData.galvoAcceleration)); %TODO: Consider initial velocity of Y scanner (maybe) and apply mdfData.galvoMaxVelocity constraint (definitely)
                transitNumLines = ceil(transitTime/LSMLinePeriodNominal);
                transitNumSamples = round(transitNumLines * lineSamplesNominal);
                
                %Append waveform to connect prior ROI to current ROI (transit ramps for both X & Y)
                xData = [xData; linspace(obj.mroiParams(lastROIIdx).scanShift(1),obj.mroiParams(i).scanShift(1),transitNumSamples)'];                                                %#ok<AGROW>
                
                roiCenterY = obj.mroiParams(i).scanShift(2);
                if i == 1
                    yData = zeros(transitNumSamples,1); %to fill in later
                    transitNumSamplesFirst = transitNumSamples;
                    roiCenterYFirst = roiCenterY;
                    roiRangeYFirst = roiRangeY;
                else
                    yData = [yData; linspace(yData(end), roiCenterY - roiRangeY/2, transitNumSamples)']; %#ok<AGROW>
                end
                
                %Append waveform to implement current ROI (constant for X, imaging ramp for Y)
                dwellNumLines = obj.mroiParams(i).scanLinesPerFrame;
                dwellNumSamples = round(dwellNumLines * lineSamplesNominal);
                
                xData = [xData; repmat(obj.mroiParams(i).scanShift(1),dwellNumSamples,1)]; %#ok<AGROW>
                yData = [yData; linspace(roiCenterY - roiRangeY/2, roiCenterY + roiRangeY/2, dwellNumSamples)']; %#ok<AGROW>
                
                obj.mroiComputedParams(1).transitNumLines(i) = transitNumLines;
            end
            
            %Add transit time waveform to 1'st ROI
            yData(1:transitNumSamplesFirst) = linspace(yData(end),roiCenterYFirst - roiRangeYFirst/2,transitNumSamplesFirst)';
            
            
            %TODO: Handle truncation to ensure galvo buffer fits within
            %frame period Should remove same X num samples from the transit
            %time samples of each of the N ROIs to achieve the sample
            %reduction required. Any extra samples (beyond a multiple of N)
            %should be removed from a random subset of the N ROIs.
            %NOTE - this will impact gavoMultiROITransitNumLines array!!
            
            
            figure;plot([xData yData]);
            
            %Determine Multi-ROI Display Tiling parameters
            numCols = ceil(sqrt(numROI));
            numRows = ceil(numROI/numCols);
            obj.mroiComputedParams.dispTiling = [numRows numCols];
            %
            %             rowIdxs = zeros(numROI,2); %Holds starting and ending index for each ROI
            %             colIdxs = zeros(numROI,2); %Holds starting and ending index for each ROI
            %             rowIdx = 1;
            %             colIdx = 1;
            %
            %             for i=1:numROI
            %                %Suboptimal Packing along Y dimension
            %                if (rowIdx+obj.mroiParams(i).scanLinesPerFrame > obj.mroiParams(i).scanLinesPerFrame*numRows)
            %                    rowIdx=1;
            %                else
            %                    rowIdxs(i,1) = rowIdx;
            %                    rowIdxs(i,2) = rowIdx+obj.mroiParams(i).scanLinesPerFrame;
            %                end
            %                %Suboptimal Packing along Y dimension
            %                if (colIdx+obj.scanPixelsPerLine > obj.scanPixelsPerLine*numRows)
            %                    colIdx=1;
            %                else
            %                    colIdxs(i,1) = colIdx;
            %                    colIdxs(i,2) = colIdx+obj.scanPixelsPerLine;
            %                end
            %
            %
            %             end
            obj.mroiComputedParams(1).dispTilingLinesPerRow = zeros(numRows,1);
            for i=1:numRows
                roiIdxs = (i-1) * numCols + (1:numCols);
                obj.mroiComputedParams(1).dispTilingLinesPerRow(i) = max([obj.mroiParams(roiIdxs).scanLinesPerFrame]);
            end
            
            %Update buffer to load to Galvo AO Task when Multi-ROI scanning is in effect
            obj.galvoAODataBuf2D = [xData yData];
        end
        
        
        
    end
    
    %% PUBLIC EVENTS
    
    % Built-in events
    events (NotifyAccess=protected)
        acquisitionStart; % Fires when a GRAB acqusition or LOOP acquisition has been started.
        acquisitionDone; %Fires when a GRAB acquisition, or single iteration of LOOP acquisition, has completed
        acquisitionAborted; %Fires when a GRAB or LOOP acquisition has been aborted
        sliceDone; %Fires when single slice of a multi-slice GRAB/LOOP acquisition has completed
        focusStart; % Fires when a FOCUS acquisition has been started.
        focusDone; %Fires when FOCUS acquisition is completed
        
        stripeAcquired; %Fires when acqusition of stripe has occurred
        frameAcquired; %Fires when acquisition of frame has been completed
        
        startTriggerReceived; %Fires when start trigger is received (only for GRAB/LOOP acquisitions)
        startTriggerProcessed; %Fires when start trigger is fully processed (only for GRAB/LOOP acquisitions)
        nextTriggerReceived; %Fires when a 'next' trigger is received
    end
    
    % Built-in user-only events
    events (NotifyAccess=private) % use private/protected attribute to distinguish usr-only events (arbitrary hack)
        applicationOpen; % Fires when application is finished starting up
        applicationWillClose; % Fires when application is about to close
    end
    
    % User-added events
    events
        %Add any events required by your application here
        %At appropriate point in application code, you must add the line:
        %   notify(appObj,'<event name>');
        %   abortAcquisitionStart; %Fires at start of an abort acquisition operation (for GRAB/LOOP)
        %   abortAcquisitionEnd; %Event at end of an abort acquisition operation (for GRAB/LOOP)
        
        %TODO: Add following events, using regular notify (see DriftComp branch)
        %         executeFocusStart; %Event invoked at start of acquisition function execute<Focus/Grab/Loop>Callback()
        %         executeGrabStart;
        %         executeLoopStart
        %
        
        %TODO: Add following events,  using 'smart' notify (see DriftComp branch, si_notify())
        %         startGrabStart;
        %         startFocusStart;
    end
    
    %% HIDDEN EVENTS
    events (Hidden, NotifyAccess=protected)
        motorPositionUpdate; %Signals that motor position has been, or may have been, updated
    end
    
    
    %% PUBLIC METHODS (Core Operations)
    methods
        function abort(obj)
            %Aborts current acquisition mode (if one is ongoing) NOTE: Can
            %be used to reset/recover in most ScanImage error conditions.
            %If this fails, try the recover() method.
            
            %fprintf(1,'Aborting...\n'); retep
            
            obj.zprvStopAcquisition(true); %signal this is an abort operation
            
            if ismember(obj.acqState,{'grab' 'loop' 'loop_wait'})
                obj.zprvGoHome(); %Go to motor, fastZ, beam home positions/powers, etc
            end
            obj.zprvEndAcquisitionMode(); % PR2014: trigger-related
            
            focusAborted = strcmpi(obj.acqState,'focus');
            
            %Reset LSM scan mode, if needed
            if strcmpi(obj.acqState,'point') %point mode sets LSM scan mode to 'SCAN_MODE_CENTER'
                obj.zprvSetInternal('scanMode',obj.scanMode);  %resets LSM scan mode to that corresponding to SI scan mode
            end
            
            %oldAcqState = obj.acqState;
            obj.acqState = 'idle';
            
            %Update CDF if focus abort
            if focusAborted
                obj.notify('focusDone');
            else
                %eventData.oldAcqState = oldAcqState;
                obj.notify('acquisitionAborted');
            end
            
        end
        
        function channelsReadOffsets(obj)
            %Measure digitizer offset voltage on all channels - with
            %shutter closed, scanner parked, beam blocked. Updates
            %channelsOffset property.
            
            assert(strcmpi(obj.acqState,'idle'),'Cannot read channel offsets during ongoing acquisition');
            
            ME = [];
            try
                obj.hLSM.readOffsets();
                obj.channelsOffset = obj.hLSM.channelOffsets; %Signals possible property change
            catch MEtemp
                ME = MEtemp;
            end
            
            obj.acqState = 'idle';
            
            if ~isempty(ME)
                ME.rethrow();
            end
            
        end
        
        function saveDisplayAs(obj,fname)
            %Save last displayed image(s) on channel display figure(s) to
            %multi-frame TIF file. Typically used to save image acquired
            %using Focus mode.
            
            imageData = zeros(obj.scanLinesPerFrame,obj.scanPixelsPerLine,length(find(obj.channelsDisplay)),obj.channelsDataType);
            chanCount = 1;
            for i=1:length(obj.channelsDisplay)
                chanIdx = obj.channelsDisplay(i);
                imageData(:,:,chanCount) = get(obj.channelsHImage{chanIdx}(1),'CData'); %TODO: Allow saving of tiled displays
                chanCount = chanCount+1;
            end
            
            if nargin < 2 || isempty(fname)
                startPath = obj.loggingFilePath;
                if isempty(startPath)
                    startPath = most.idioms.startPath();
                end
                [f,p] = uiputfile('*.tif','Save Image As...',startPath);
                if isnumeric(f)
                    return;
                end
                
                if exist(fullfile(p,f),'file')
                    resp = questdlg('File already exists. Overwrite?','File Already Exists','Overwrite','Cancel','Cancel');
                    
                    if strcmpi(resp,'Cancel')
                        return;
                    end
                end
            end
            
            %Write the file
            for i=1:length(obj.channelsDisplay)
                if i == 1
                    writeMode = 'Overwrite';
                else
                    writeMode = 'Append';
                end
                
                imwrite(imageData(:,:,i),fullfile(p,f),'WriteMode',writeMode);
            end
            
        end
        
        function scannerPeriodMeasure(obj,stopScanner)
            
            % clear counter for use here;
            obj.xTrigCallback.clear();
            
            CRS_amplitude = 4.5 / (obj.hLSM.scanZoomFactor);
            writeAnalogData(obj.hLSM.CRScmd, CRS_amplitude, 1, true, 1);

            obj.hLSM.CRSdisable.writeDigitalData(true,true);
            pause(obj.hLSM.scanZoomFactor/9+1); % for higher zoom, it takes longer to stabilize the scanning period
            periodCtr = obj.zprvDaqmxTask('Scan Clock Period Counter');
            periodCtr.createCIPeriodChan(obj.mdfData.scanDevice,obj.mdfData.xTrigCtr); %Uses ctr3
            periodCtr.cfgImplicitTiming('DAQmx_Val_ContSamps');
            periodCtr.channels(1).set('periodTerm',sprintf('PFI%d',3)); %Set frame clock source as the period source; assumes rising edge

            periodCtr.start();
            pause(1);
            framePeriodMeasured = periodCtr.readCounterData();
            if stopScanner
                obj.hLSM.CRSdisable.writeDigitalData(false,true);
            end
            periodCtr.stop();
            periodCtr.clear();
            indX = find(~isnan(framePeriodMeasured));
            mittel = mean(framePeriodMeasured(indX));
            stnd = std(framePeriodMeasured(indX));
            fprintf('Mean period of %0.2f us, standard deviation of %0.2f us.\n',[mittel*1e6 stnd*1e6]);

            obj.hLSM.framePeriodMeasuredMean = mittel;
            
            obj.xTrigCallback = obj.zprvDaqmxTask('Trigger Callback Counter 2');
            obj.xTrigCallback.createCICountEdgesChan(obj.mdfData.scanDevice,obj.mdfData.xTrigCtr); %Uses ctr3
            obj.xTrigCallback.cfgSampClkTiming(1000, 'DAQmx_Val_HWTimedSinglePoint', [], 'PFI0'); %Sample rate is 'dummy' value. Trigger terminal is a temp value, to be overwritten.
            obj.xTrigCallback.registerSignalEvent(@(varargin)obj.zprvOverrideableFunction('xTriggerFcn',varargin{:}),'DAQmx_Val_SampleClock');
            obj.xTrigCallback.set('sampClkSrc','PFI0','sampClkActiveEdge',zlclEncodeTriggerEdge('rising'));

        end
        
        function scanPointBeam(obj,beams)
            %Points scanner at center of FOV, opening shutter and with specified beams ON
            
            % SYNTAX
            %   beams: <Optional> Specifies which beams to turn ON. If omitted, all beams are turned ON.
            
            assert(strcmpi(obj.acqState,'idle'),'Unable to complete specified operation in current acquisition state (''%s'')',obj.acqState);
            
            obj.hLSM.parkAtCenter();
            
            obj.beamsOn(); %TODO: beamsOn() should be able to operate on specified beam subset
            obj.shuttersTransition(true);
            
            obj.acqState = 'point';
        end
        
        function offsetGalvoUp(obj)
            obj.galvoOffset = max(min(obj.galvoOffset + 0.1,2),-2);
            obj.hLSM.galvoOffset = obj.galvoOffset;
            obj.scanZoomFactor = obj.scanZoomFactor;
            obj.hLSM.scanZoomFactor = obj.scanZoomFactor;
        end
            
        function offsetGalvoZero(obj)
            obj.galvoOffset = 0;
            obj.hLSM.galvoOffset = 0;
            obj.scanZoomFactor = obj.scanZoomFactor;
            obj.hLSM.scanZoomFactor = obj.scanZoomFactor;
        end
            
        function offsetGalvoDown(obj)
            obj.galvoOffset = max(min(obj.galvoOffset - 0.1,2),-2);
            obj.hLSM.galvoOffset = obj.galvoOffset;
            obj.scanZoomFactor = obj.scanZoomFactor;
            obj.hLSM.scanZoomFactor = obj.scanZoomFactor;
        end
        
        
        function setSavePath(obj,pathDir)
            %Set loggingFilePath property to specified/selected folder path for
            %image file logging during Grab/Loop acquisitions.
            
            if nargin > 1
                assert(exist(pathDir,'dir'),'Specified directory does not exist');
                p = pathDir;
            else
                startPath = obj.loggingFilePath;
                
                if isempty(startPath)
                    startPath = most.idioms.startPath();
                end
                
                p = uigetdir(startPath, 'Select Save Path');
            end
            
            if p
                obj.loggingFilePath=p;
                disp(['*** SAVE PATH = ' p ' ***']);
            end
        end
        
        function startFocus(obj)
            %Start a Focus acquisition used to visualize specimen
            %continuously at current scan settings, without logging images
            %to disk. Used typically while  focusing and/or translating
            %specimen.
            obj.hLSM.savefast = 1;
            if obj.triggerOut
                obj.triggerOut = 0;
                triggerOutTemp = 1;
            else
                triggerOutTemp = 0;
            end
            
            %Ensure logging file is configured, if logging enabled
            obj.loggingFileSubCounter = [];
            if obj.loggingEnable && ~obj.zprvValidateLoggingFile();
                return;
            end
            
            try
                
                %Ensure scanFramePeriod has been measured, if using external galvo control
                if obj.galvoEnable && ~obj.zprvEnsureScannerPeriodMeasured()
                    return;
                end

                obj.zprvResetAcqCounters();
                obj.zprvResetBuffers();
                obj.zprvResetHome(); %Reset motor/fastZ/beam positions/powers (not really needed for Focus, but clear these for good measure)
                
                if obj.channelsAutoReadOffsets && obj.channelsAutoReadOffsetsOnFocus && any(obj.channelsSubtractOffset(:) & obj.channelsDisplay(:))
                    obj.channelsReadOffsets();
                end

                %Updates display limits & aspect ratio.
                %Calls drawnow() - this forces channel offset table
                obj.zprvUpdateChannelDisplayRatioAndLims(); % retep
                
                %                 obj.hLSM.loggingEnable = false;
                obj.hLSM.triggerMode = 'SW_FREE_RUN_MODE';

                obj.zprvResetTriggerTimes()
                %obj.armTriggers();
                if obj.lowVal == 0
                    obj.shuttersTransition(true); % this is too early in my opinion, retep, PR2014; unclear, how long the transition takes
                end
                %Prepare Beam/Galvo analog output buffers, as needed
                obj.zprvBeamsWriteFlybackData();
                obj.zprvGalvosUpdateAOData('1d');

                %Prepare LSM parameters and arm it (calls 'preflight')
                obj.zprvSetLSMJITParams('focus');
                obj.handParamsToLSM();
                obj.acqState = 'focus'; % normally, this appears later, shortly before hLSM.start()
                obj.hLSM.arm();

                %Start acquisition Tasks & LSM
                obj.zprvDaqmxStart([obj.hBeams obj.hFramePeriodCtr]);
                
                if obj.galvoEnable
                    obj.zprvDaqmxStart(obj.hGalvos);
                end
%                 obj.hLSM.start(false);
                obj.triggerClockTimeFirstVec = clock();
                obj.hLSM.start0(false);
                obj.startUnnested(false);
                obj.hFramePeriodCtr.stop();

                if triggerOutTemp
                    obj.triggerOut = 1;
                end
                
%                 %Ensure scanFramePeriod has been measured, if using external galvo control
%                 if obj.galvoEnable && ~obj.zprvEnsureScannerPeriodMeasured()
%                     return;
%                 end
%                 
%                 obj.zprvResetAcqCounters();
%                 obj.zprvResetBuffers();
%                 obj.zprvResetHome(); %Reset motor/fastZ/beam positions/powers (not really needed for Focus, but clear these for good measure)
%                 
%                 if obj.channelsAutoReadOffsets && obj.channelsAutoReadOffsetsOnFocus && any(obj.channelsSubtractOffset(:) & obj.channelsDisplay(:))
%                     obj.channelsReadOffsets();
%                 end
%                 
%                 %Updates display limits & aspect ratio.
%                 %Calls drawnow() - this forces channel offset table
%                 obj.zprvUpdateChannelDisplayRatioAndLims();
%                 
%                 %                 obj.hLSM.loggingEnable = false;
%                 obj.hLSM.triggerMode = 'SW_FREE_RUN_MODE';
%                 
%                 obj.zprvResetTriggerTimes()
%                 %obj.armTriggers();
%                 
%                 obj.shuttersTransition(true); % this is too early in my opinion, retep, PR2014
%                 
%                 %Prepare Beam/Galvo analog output buffers, as needed
%                 obj.zprvBeamsWriteFlybackData();
%                 obj.zprvGalvosUpdateAOData('1d');
%                 
%                 %Prepare LSM parameters and arm it (calls 'preflight')
%                 obj.zprvSetLSMJITParams('focus');
%                 obj.hLSM.arm();
%                 
%                 %Start acquisition Tasks & LSM
%                 obj.zprvDaqmxStart([obj.hBeams obj.hFramePeriodCtr]);
%                 
%                 if obj.galvoEnable
%                     obj.zprvDaqmxStart(obj.hGalvos);
%                 end
%                 
%                 obj.acqState = 'focus';
%                 obj.hLSM.start(false);
%                 
%                 obj.triggerClockTimeFirstVec = clock();
%                 
%                 obj.notify('focusStart');
                
                %                 %TODO: This should eventually be a callback
                %                 obj.acquisitionStartedFcn();
                %
            catch ME
                obj.acqState = 'idle';
                ME.rethrow();
            end
        end
        
        function startUnnested(obj,allowlogging)
            obj.temp_image = zeros(obj.scanPixelsPerLine,obj.scanLinesPerFrame,max(numel(obj.channelsSave),sum(obj.hLSM.channelsViewing)));
%                 obj.hLSM.start0(false);
            obj.hLSM.startTickCount = tic;
            obj.hLSM.updateTickCount = tic;
            obj.hLSM.updateInterval_sec = 0.1;                
            obj.acqFramesDoneTotally = 0;
            buffersCompleted = 0;
            buffersCompleted2 = 0;
            obj.captureDone = 0;
            AlazarDefs;
            obj.averagedStorage = zeros(obj.scanPixelsPerLine,obj.scanLinesPerFrame,max(numel(obj.channelsSave),sum(obj.hLSM.channelsViewing)));

            if strcmp(obj.hLSM.acqState,'focus')
                obj.hLSM.frameClock.start(); % starts everything, whatsoever
            end
            while ~obj.captureDone && ismember(obj.hLSM.acqState,{'focus','grab','loop','periodmeasure'}) 
                if ismember(obj.hLSM.acqState,{'grab','loop'}) && obj.overshoot > 0
                    dropFrames = 1;
                else
                    dropFrames = 0;
                end
                bufferIndex = mod(buffersCompleted2, obj.hLSM.bufferCount) + 1;
                bufferCount = mod(buffersCompleted,obj.acqNumFrames)+1;
                obj.frameAcquiredFcn(bufferIndex,bufferCount,dropFrames);
%                 obj.shuttersTransition(true); % this is too early in my opinion, retep, PR2014; unclear, how long the transition takes

                % Update progress
                if ~dropFrames %~(obj.stackSlicesDone > 0)
                    buffersCompleted = buffersCompleted + 1;
                    buffersCompleted2 = buffersCompleted2 + 1;
                else
                    buffersCompleted2 = buffersCompleted2 + 1;
                    obj.overshoot = obj.overshoot - 1;
                end
                if buffersCompleted2 >= obj.hLSM.buffersPerAcquisition
                    obj.captureDone = true;
                elseif toc(obj.hLSM.updateTickCount) > obj.hLSM.updateInterval_sec
                    obj.hLSM.updateTickCount = tic;
               
%               Update waitbar progress 
                drawnow();
%                 waitbar(double(buffersCompleted) / double(obj.hLSM.buffersPerAcquisition), ...
%                             obj.hLSM.waitbarHandle, ...
%                             sprintf('Completed %u buffers', buffersCompleted));
                end
                
                if ~isinf(obj.triggerTimes(end)) || strcmp(obj.acqState,'focus')
                    zprvUpdateSecondsCounter(obj)
                end
                % timecounter(counter) = toc;
            end % while ~obj.captureDone
            obj.hBeams.stop();
%                 obj.hFramePeriodCtr.stop();
            obj.hLSM.start1(obj.loggingEnable);
            obj.shuttersTransition(false);
            if obj.loggingEnable && obj.savingYes
                tic
                savedImage = 1;
                if obj.offlineAveraging  || obj.write2RAM
                    AVGframes = obj.acqNumAveragedFrames;
                else
                    AVGframes = 1;
                end
                if ~obj.write2RAM && obj.autoconvert
                    obj.statusString = 'Converting to tif ...'; drawnow;
                    binary2tif_db(obj.hLSM.loggingFileName(1:end-4),obj.scanPixelsPerLine,obj.scanLinesPerFrame,true,obj.headerString,obj.autoscaleSavedImages,obj.savedBitdepthX,AVGframes);
                    fprintf('Conversion to tif-files took %f seconds\n',toc);
                elseif ~isempty(obj.BIG_FILE)
                    if ~obj.ATactive
                        obj.statusString = 'Writing from RAM ...';
                        drawnow;
                        if obj.autoscaleSavedImages
                            minimum = min(obj.BIG_FILE(:));
                            maximum = max(obj.BIG_FILE(:));
                            bitdepth = obj.savedBitdepthX;
                            HrString = [obj.headerString, 'scalingFactorAndOffset = [',num2str(maximum-minimum)*AVGframes,' ',num2str(minimum),']'];
                        else
                            minimum = 0; maximum = 1; bitdepth = 0;
                            HrString = [obj.headerString, 'scalingFactorAndOffset = [1 0]'];
                        end
                        ts = TifStream(strcat(obj.hLSM.loggingFileName(1:end-4),'_','.tif'),obj.scanPixelsPerLine,obj.scanLinesPerFrame,obj.savedBitdepthX,HrString);

                        if AVGframes == 1
                            for k = 1:size(obj.BIG_FILE,3)
                                ts.appendFrame((obj.BIG_FILE(:,:,k)'-minimum)/(maximum-minimum)*2^bitdepth);
                            end
                        else
                            B = zeros(size(obj.scanLinesPerFrame,obj.scanPixelsPerLine));
                            for k = 1:size(obj.BIG_FILE,3)
                                if mod(k,AVGframes) == 0
                                    B = B + obj.BIG_FILE(:,:,k);
                                    ts.appendFrame((B'-minimum*AVGframes)/(maximum-minimum)*2^bitdepth/AVGframes);
                                    B = zeros(size(obj.scanLinesPerFrame,obj.scanPixelsPerLine));
                                else
                                    B = B + obj.BIG_FILE(:,:,k);
                                end
                            end
                        end
                        ts.close();
                        obj.BIG_FILE = [];
                        fprintf('Writing from RAM to tif took %f seconds\n',toc);
                    end
                end
                if ~obj.ATactive; obj.statusString = 'Done.'; end
            else
                savedImage = 0;
            end
            % Display results
            if buffersCompleted > 0 
                if obj.hLSM.transferTime_sec > 0 
                    buffersPerSec = buffersCompleted / obj.hLSM.transferTime_sec;
                end
                fprintf('Captured %u buffers in %g sec (%g buffers per sec)\n', buffersCompleted, obj.hLSM.transferTime_sec, buffersPerSec);
            end

            % advance counter for file to save
            if obj.loggingEnable ~= 0 && savedImage
                if obj.stackSlicesDone == 0
                    obj.zprvSetInternal('loggingFileCounter', obj.loggingFileCounter + 1);
                end
            end


        end
        
        function startGrab(obj)
            %Start a Grab acquisition, which collects specified number of
            %frames & slices at current scan settings, logging images to
            %disk if specified.
            
            if max(numel(obj.channelsSave),sum(obj.hLSM.channelsViewing)) > 1 && (obj.write2RAM || obj.offlineAveraging)
                obj.write2RAM = 0;
                obj.offlineAveraging = 0;
                disp('Sorry, but multichannel imaging is not available with offline averaging or RAM writing (could be implemented -> lazy Peter)');
            end
            
            if obj.write2RAM && obj.scanLinesPerFrame*obj.scanPixelsPerLine*obj.acqNumFrames*obj.stackNumSlices < 2^30
                obj.BIG_FILE = zeros(obj.scanPixelsPerLine,obj.scanLinesPerFrame,obj.acqNumFrames*obj.stackNumSlices);
            else
                obj.write2RAM = 0;
            end
            try
                %Boilerplate start of GRAB/LOOP modes
                if ~obj.zprvStartAcquisitionMode('grab')
                    return;
                end
                obj.zprvStartAcquisition('grab');
            catch ME
                obj.acqState = 'idle';
                ME.rethrow();
            end
        end
        
        function startLoop(obj)
            %Start a Loop acquisition, which is a Grab acquisition repeated
            %loopNumRepeats times and/or following supplied external
            %trigger signal(s)
            
            %Boilerplate start of GRAB/LOOP modes
            if ~obj.zprvStartAcquisitionMode('loop')
                return;
            end
            
            znstInitializeLoop();
            
            function znstInitializeLoop()
                obj.loopRepeatsDone = 0;
                obj.zprvStartAcquisition('loop');
            end
            
        end
        
        function recover(obj)
            %Generic method used to attempt recovery from known SI4 failure
            %modes, restoring ScanImage to its default operating state
            
            %Stop any ongoing Tasks
            obj.hAllTasks.stop();
        end
    end
    
    %% PUBLIC METHODS (Beam Operations)
    methods
        function beamsCalibrate(obj,beamIdx)
            % Run calibration of beam modulation device. Sets the properties beamCalibrationLUT,
            % beamCalibrationMin/MaxCalVoltage for beamIdx'th beam.
            
            % Note: This is basically the only safe way to set any of these
            % three properties.
            
            if nargin < 2
                beamIdx = 1:obj.beamNumBeams;
            end
            validateattributes(beamIdx,{'numeric'},{'vector','integer','>=',1,'<=',obj.beamNumBeams});
            
            switch obj.acqState
                case 'idle'
                    % none
                otherwise
                    error('SI4:beamsCalibrate:acquisitionRunning',...
                        'Cannot calibrate beams during acquisition.');
            end
            
            for bIdx = beamIdx(:)'
                if obj.mdfData.shutterBeforeEOM
                    obj.beamsMeasureCalOffset(bIdx,true);
                else
                    % Will use current offset from mdfData. If desired, user
                    % should separately run offset measurement before
                    % calibration.
                end
                
                [tfSuccess beamCalVoltage beamVoltage] = obj.zprvBeamsGetCalibrationData(bIdx);
%                 figure(313), plot(beamCalVoltage)
                if tfSuccess
                    [lut beamCalMinVoltage beamCalMaxVoltage] = ...
                        obj.zprvBeamsProcessCalibrationData(beamVoltage,beamCalVoltage,obj.mdfData.beamCalOffsets(bIdx));
                else
                    fprintf(2,'WARNING: Unable to collect calibration data. Using naive calibration.\n');
                    [lut beamCalMinVoltage beamCalMaxVoltage] = ...
                        obj.zprvBeamsPerformNaiveCalibration(beamVoltage);
                end
                
                %Update beam calibration properties
                obj.zprvBeamsSetCalibrationInfo(bIdx,lut,beamCalMinVoltage,beamCalMaxVoltage);
            end
        end
        
        function offset = beamsMeasureCalOffset(obj,beamIdx,tfWriteToMDF)
            % Measures and updates stored offset value for beam calibration
            % device (e.g. photodiode). Corrects subsequent readings with
            % that device, to improve calibration accuracy.
            
            % Updates obj.mdfData.beamCalOffsets. If tfWriteToMDF is true,
            % this also updates the current MDF.
            
            if nargin < 3
                tfWriteToMDF = false;
            end
            if nargin < 2 && obj.beamNumBeams==1
                beamIdx = 1;
            end
            
            validateattributes(beamIdx,{'numeric'},{'scalar','integer','>=',1,'<=',obj.beamNumBeams});
            
            switch obj.acqState
                case 'idle'
                    % none
                otherwise
                    error('SI4:beamsMeasureCalOffset:acquisitionRunning',...
                        'Cannot calibrate beam during acquisition.');
            end
            
            beamCalTask = obj.hBeamCals{beamIdx};
            beamCalTask.control('DAQmx_Val_Task_Unreserve');
            beamCalTask.cfgSampClkTiming(obj.beamCalibrationOutputRate,'DAQmx_Val_FiniteSamps',obj.beamCalibrationOffsetNumSamples);
            beamCalTask.set('startTrigRetriggerable',false);
            
            sampleTime = obj.beamCalibrationOffsetNumSamples/obj.beamCalibrationOutputRate;
            
            if obj.mdfData.shutterBeforeEOM
                % shutter should probably already be off, but anyway
                obj.shuttersTransition(false);
            else
                uiwait(msgbox(sprintf('Turn off laser for beam index %d.',beamIdx),'Alert','modal'));
            end
            
            % TODO: do we need to turn off other beams as well in a multi-beam situ?
            
            beamCalTask.start;
            obj.hSelfTrig.writeDigitalData([0;1;0],0.2);
            beamCalTask.waitUntilTaskDone();
            data = beamCalTask.readAnalogData();
            beamCalTask.stop();
            
            offset = mean(data);
            sig = std(data);
            if sig/offset > obj.beamCalibrationNoisyOffsetThreshold
                warning('SI4:beamsMeasureCalOffset:noisyPhotodiodeOffset',...
                    'Noisy photodiode offset.');
            end
            
            assert(numel(obj.mdfData.beamCalOffsets)==obj.beamNumBeams);
            obj.mdfData.beamCalOffsets(beamIdx) = offset;
            
            if tfWriteToMDF
                mdf = most.MDF.getInstance();
                if mdf.isLoaded
                    allOffsets = obj.mdfData.beamCalOffsets;
                    allOffsets(beamIdx) = offset;
                    mdf.writeVarToHeading('ScanImage','beamCalOffsets',allOffsets);
                end
            end
        end
        
        function beamsShowCalibrationCurve(obj,beamIdx)
            %Displays figure showing last measured/computed calibration of beam modulation device, for specified beamIdx
            
            validateattributes(beamIdx,{'numeric'},{'scalar','integer','>=',1,'<=',obj.beamNumBeams});
            chart_title = sprintf('Look Up Table (Beam %d)', beamIdx);
            h = figure('NumberTitle','off','DoubleBuffer','On','Name',chart_title,'Color','White');
            a = axes('Parent',h);
            plot(obj.beamCalibrationLUT(:,beamIdx),(1:obj.beamCalibrationLUTSize)'/obj.beamCalibrationLUTSize*100,...
                'Marker','.','MarkerSize',8,'LineStyle','none','Parent',a,...
                'MarkerFaceColor',[0 0 0],'color',[0 0 0]);
            title(chart_title,'FontSize',12,'FontWeight','Bold','Parent',a);
            ylabel('Percent of Maximum Power','Parent',a,'FontWeight','bold');
            xlabel('Modulation Voltage [V]','Parent',a,'FontWeight','bold');
            
            axisRange = axis;
            lblXPos = axisRange(1) + (axisRange(2)-axisRange(1))/3;
            lblYPos = axisRange(3) + (axisRange(4)-axisRange(3))*92/100;
            minCalV = obj.beamCalibrationMinCalVoltage(beamIdx);
            maxCalV = obj.beamCalibrationMaxCalVoltage(beamIdx);
            
            extRatio = maxCalV/minCalV;
            if extRatio > 1000
                extRatio = '>1000';
            end
            
            zlclAddQuantityAnnotations(a,lblXPos,lblYPos,...
                {'Cal. Offset';'Min Cal. Voltage';'Max Cal. Voltage';'Max Extinction Ratio'},...
                {obj.mdfData.beamCalOffsets(beamIdx);minCalV;maxCalV;extRatio},'FontWeight','bold','FontSize',9);
            % TODO are these figHandles going somewhere
        end
        
        function acqLzs = beamComputeOverrideLzs(obj)
            %Displays figure showing last measured raw calibration data
            %obtained for beam modulation device of specified beamIdx
            
            Nbeam = obj.beamNumBeams;
            beamLz = obj.beamLengthConstants;
            assert(isequal(numel(beamLz),numel(obj.stackEndPower),numel(obj.stackStartPower),Nbeam));
            dz = obj.stackZEndPos-obj.stackZStartPos;
            
            acqLzs = inf(Nbeam,1);
            for c = 1:Nbeam
                if obj.beamPzAdjust(c)
                    Pratio = obj.stackEndPower(c)/obj.stackStartPower(c);
                    acqLzs(c) = dz/log(Pratio);
                    fprintf(1,'Beam %d: Lz=%.2f\n',c,acqLzs(c));
                end
            end
        end
        
    end
    
    %% PUBLIC METHODS (Motor Operations)
    methods
        function motorZeroXYZ(obj)
            %Set motor relative origin to current position for X,Y,and Z coordinates.
            
            switch obj.motorDimensionConfiguration
                case 'xy'
                    obj.motorZeroSoft(logical([1 1 0]));
                case 'z'
                    obj.motorZeroSoft(logical([0 0 1]));
                case 'xyz'
                    obj.motorZeroSoft(logical([1 1 1]));
                case 'xy-z'
                    obj.motorZeroSoft(logical([1 1 1]));
                case 'xyz-z'
                    obj.motorZeroSoft(logical([1 1 1 0])); %Do not zero secondary-Z; require motorZeroZ() to do this, with motorSecondMotorZEnable=true
            end
        end
        
        function motorZeroXY(obj)
            %Set motor relative origin to current position for X&Y coordinates.
            
            switch obj.motorDimensionConfiguration
                case 'xy'
                    obj.motorZeroSoft(logical([1 1 0]));
                case 'z'
                    % none
                case 'xyz'
                    obj.motorZeroSoft(logical([1 1 0]));
                case 'xy-z'
                    obj.motorZeroSoft(logical([1 1 0]));
                case 'xyz-z'
                    obj.motorZeroSoft(logical([1 1 0 0]));
            end
        end
        
        function motorZeroZ(obj)
            %Set motor relative origin to current position for Z
            %coordinates. Honor motorSecondMotorZEnable property, if
            %applicable.
            
            switch obj.motorDimensionConfiguration
                case 'xy'
                    % none
                case 'z'
                    obj.motorZeroSoft(logical([0 0 1]));
                case 'xyz'
                    obj.motorZeroSoft(logical([0 0 1]));
                case 'xy-z'
                    obj.motorZeroSoft(logical([0 0 1]));
                case 'xyz-z'
                    if obj.motorSecondMotorZEnable
                        obj.motorZeroSoft(logical([0 0 0 1]));
                    else
                        obj.motorZeroSoft(logical([0 0 1 0]));
                    end
                    
            end
        end
        
        
        
        % motorDefineUserPosition(obj,idx,posn) -- set idx'th
        % user-defined position to posn.
        function motorDefineUserPosition(obj,idx,posn)
            % Add current motor position, or specified posn, to
            % motorUserDefinedPositions array at specified idx
            
            validateattributes(idx,{'numeric'},{'scalar' 'integer' 'positive'});
            if nargin==2
                posn = obj.motorPosition;
            end
            obj.motorUserDefinedPositions{idx,1} = posn;
        end
        
        % Clears all user-defined positions
        function motorClearUserDefinedPositions(obj)
            %Clear motorUserDefinedPositions array
            obj.motorUserDefinedPositions = cell(0,1);
        end
        
        function motorGotoUserDefinedPosition(obj,posnIdx)
            %Move motor to position coordinates stored at specified posnIdx in motorUserDefinedPositions array
            
            udp = obj.motorUserDefinedPositions;
            if posnIdx > numel(udp)
                warning('SI4:motorGotoUserDefinedPosition',...
                    'Position index %d exceeds number of user-defined positions. Motor position unchanged.',posnIdx);
                return;
            end
            
            posn = udp{posnIdx};
            if isempty(posn)
                warning('SI4:motorGotoUserDefinedPosition',...
                    'Position index %d is not defined. Motor position unchanged.',posnIdx);
            else
                % nans in user-defined position vecs mean "don't affect this position component"
                tfNan = isnan(posn);
                currPosn = obj.motorPosition;
                posn(tfNan) = currPosn(tfNan);
                obj.zprvSetInternal('motorPosition', posn);
            end
        end
        
        function motorSaveUserDefinedPositions(obj)
            %Save contents of motorUserDefinedPositions array to a position (.POS) file
            
            [fname, pname]=uiputfile('*.pos', 'Choose position list file'); % TODO starting path
            if ~isnumeric(fname)
                periods=strfind(fname, '.');
                if any(periods)
                    fname=fname(1:periods(1)-1);
                end
                s.positionVectors = obj.motorUserDefinedPositions; %#ok<STRNU>
                save(fullfile(pname, [fname '.pos']),'-struct','s','-mat');
                % TODO setStatusString('...')
            end
        end
        
        function motorLoadUserDefinedPositions(obj)
            %Load contents of a position (.POS) file to the motorUserDefinedPositions array (overwriting any previous contents)
            
            [fname, pname]=uigetfile('*.pos', 'Choose position list file');
            if ~isnumeric(fname)
                periods=strfind(fname,'.');
                if any(periods)
                    fname=fname(1:periods(1)-1);
                end
                s = load(fullfile(pname, [fname '.pos']), '-mat');
                obj.motorUserDefinedPositions = s.positionVectors;
                
                % TODO
                % setStatusString('Position list loaded...');
            end
        end
    end
    
    
    %% PUBLIC METHODS (Scan Parameter Caching)
    methods
        
        function set_global_delay(obj)
                for k = 12:255
                    disp(k)
                    obj.scanZoomFactor = obj.hLSM.fieldSize2Zoom(k);
                    obj.hLSM.scanZoomFactor = obj.hLSM.fieldSize2Zoom(k);
%                     obj.lineScan_delay1 = 2.6;
%                     obj.lineScan_delay2 = 61.4845;
                    obj.lineScan_delay1 = 6;
                    obj.lineScan_delay2 = 64.25;
                    pause(0.05);
                end
        end
        
        function moveZmirror(obj,direction)
           
            switch direction
                case 1
                    if obj.hLSM.fastZEnable
                        if isempty(obj.hLSM.PRvoiceCoil.deviceNames)
                            obj.hLSM.PRvoiceCoil.createAOVoltageChan(obj.hLSM.fastzDevice,[obj.hLSM.fastzAOChannel obj.hLSM.fastzAOPockels]); % fastzAOPockels
                            obj.hLSM.voiceCoilCmdOutputRate = 1e4;
                            obj.hLSM.PRvoiceCoil.cfgSampClkTiming(obj.hLSM.voiceCoilCmdOutputRate,'DAQmx_Val_FiniteSamps',2);
                            obj.hLSM.voiceCoilTriggerChannel = 0;
                            obj.hLSM.PRvoiceCoil.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.hLSM.voiceCoilTriggerChannel)); % this is the frameClock2 input from Counter2 of board Dev1
                            obj.hLSM.PRvoiceCoil.set('startTrigRetriggerable',1);
                        end
                        offsetplus = 1;
                        while offsetplus ~= 0
                            obj.hLSM.PRvoiceCoil_sense.stop();
                            obj.hLSM.PRvoiceCoil_sense.cfgSampClkTiming(1e3,'DAQmx_Val_FiniteSamps',200);
                            obj.hLSM.PRvoiceCoil_sense.start();
                            pause(0.2);
                            A = obj.hLSM.PRvoiceCoil_sense.readAnalogData();
        %                         figure(414); plot(A)
                            current_pos = mean(A);
                            obj.hLSM.PRvoiceCoil_sense.stop();

                            target = obj.lowVal;
                            if abs((current_pos - target)) > 0.01
                                offsetplus = (0.2/(1+exp(-20*((current_pos - target)))) - 0.1);
                            else
                                offsetplus = 0;
                            end
                            obj.statusString = strcat('delta =',32,num2str(round(1000*(current_pos - target))/1000),32,'V');
                            if obj.offset_directly
                                offsetplus = 0;
                            else
                                obj.highVal = obj.highVal + offsetplus/2.5;
                            end
                            obj.hLSM.highVal = obj.highVal;

                            obj.hLSM.PRvoiceCoil.stop();
                            obj.hLSM.PRvoiceCoil.set('startTrigRetriggerable',0);
                            sawtoothVCnb = obj.hLSM.PRvoiceCoil.sampQuantSampPerChan;
                            sawtoothVC = obj.highVal*ones(sawtoothVCnb,1);
                            obj.hLSM.PRvoiceCoil.cfgOutputBuffer(length(sawtoothVC));
                            obj.hLSM.PRvoiceCoil.cfgSampClkTiming(1e4,'DAQmx_Val_FiniteSamps',length(sawtoothVC));
                            obj.hLSM.PRvoiceCoil.disableStartTrig();

                %             obj.PRgalvo.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.extFrameClockTerminal));
                            obj.hLSM.PRvoiceCoil.writeAnalogData([sawtoothVC sawtoothVC],false); % false = no autostart
                            obj.hLSM.PRvoiceCoil.start();
                            if abs((current_pos - target)) > 0.1;
                                pause(0.1);
                            else
                                pause(0.25);
                            end
                            obj.hLSM.PRvoiceCoil.stop();
                            obj.hLSM.PRvoiceCoil.set('startTrigRetriggerable',1);
                           % [ones(size(2:(round(obj.hLSM.voiceCoilCmdOutputRate/2)))) 0]'
                        end
                    else
                        disp('z-scanning is not enabled.');
                    end
                case -1
%                     obj.hLSM.PRvoiceCoil.set('startTrigRetriggerable',0);
%                     obj.hLSM.PRvoiceCoil.control('DAQmx_Val_Task_Unreserve'); %should flush data
%                     obj.hLSM.PRvoiceCoil.cfgSampClkTiming(obj.hLSM.voiceCoilCmdOutputRate,'DAQmx_Val_FiniteSamps',round(obj.hLSM.voiceCoilCmdOutputRate/2));
%                     obj.hLSM.PRvoiceCoil.disableStartTrig();
%                     obj.hLSM.PRvoiceCoil.cfgOutputBuffer(round(obj.hLSM.voiceCoilCmdOutputRate/2));
%                     obj.hLSM.PRvoiceCoil.stop();
%                     obj.hLSM.PRvoiceCoil.writeAnalogData(0.5*[ones(size(2:(round(obj.hLSM.voiceCoilCmdOutputRate/2)))) 0]');
%                     obj.hLSM.PRvoiceCoil.start();
%                     pause(0.8);
%                     obj.hLSM.PRvoiceCoil.stop();
%                     obj.hLSM.PRvoiceCoil.set('startTrigRetriggerable',1);
                case 0
%                     disp('so lala')
            end
            pause(0.5); 
            obj.hLSM.PRvoiceCoil_sense.cfgSampClkTiming(1e2,'DAQmx_Val_FiniteSamps',100);
            obj.hLSM.PRvoiceCoil_sense.start();
            A = mean(obj.hLSM.PRvoiceCoil_sense.readAnalogData());
            obj.hLSM.PRvoiceCoil_sense.stop();
            obj.statusString = strcat(['z-motor at',32,num2str(round(A*100)/100),32,'V']);
                        
        end
        
        function defineZeroZ(obj)
            
            obj.hLSM.PRvoiceCoil_sense.cfgSampClkTiming(1e4,'DAQmx_Val_FiniteSamps',5000);
            obj.hLSM.PRvoiceCoil_sense.start();
            pause(0.5);
            X = mean(obj.hLSM.PRvoiceCoil_sense.readAnalogData());
            obj.hLSM.PRvoiceCoil_sense.stop();
            disp(['The position corresponds to',32,num2str(X),32,'volts (hall sensor).']);
            
        end
        
        function xCorrScanPhase(obj,batchProcess)
            tempLog = obj.loggingEnable;
            tempX = obj.channelsSave;
            tempY = obj.channelsDisplay;
            switch obj.xCorrChannel
                case 'Channel 1'
                    channelactiveX = 1;
                case 'Channel 2'
                     channelactiveX = 2;
                case 'Channel 3'
                    channelactiveX = 3;
            end
            obj.loggingEnable = 0;
            obj.channelsSave = [];
            obj.channelsDisplay = channelactiveX;
            
            tempA = obj.stackNumSlices;
            tempB = obj.acqNumFrames;
            tempC = obj.framerate_user_check;
            tempD = obj.framerate_user;
            temp1 = obj.hLSM.channelsLogging;
            temp2 = obj.hLSM.channelsViewing;
            obj.hLSM.channelsLogging = [1 0 0];
            obj.hLSM.channelsViewing = [1 0 0];
            if batchProcess
                obj.scanZoomFactor = obj.hLSM.fieldSize2Zoom(15); % very high zoom
                obj.hLSM.scanZoomFactor = obj.hLSM.fieldSize2Zoom(15);
                scanphaseAdjust(obj);

%                 scanZoomFactorChangeX(obj,val)
                crounter = 1;
                while obj.scanZoomFactor > 1.0
                    temp = obj.scanZoomFactor;
                    counter = 3;
                    while temp == obj.scanZoomFactor
                        obj.scanZoomFactorChangeX(max(1,temp-counter));
                        counter = counter + 1;
                    end
                    drawnow;
                    disp(obj.scanZoomFactor)
                    out = scanphaseAdjust(obj);
                    temp_zoom(crounter) = obj.scanZoomFactor;
                    temp_fieldsize(crounter) = obj.hLSM.zoom2FieldSize(temp_zoom(crounter));
                    temp_scanphase(crounter) = out;
                    crounter = crounter + 1;
                end
                for jjj = 1:numel(min(temp_fieldsize):max(temp_fieldsize))
                    obj.scanphases{min(temp_fieldsize)-1+jjj}(3) = interp1(temp_fieldsize,temp_scanphase,min(temp_fieldsize)-1+jjj);
                end
            else
                scanphaseAdjust(obj); 
            end 
                    
                function outcome = scanphaseAdjust(obj)
                    obj.triggerExtTrigEnable = 0;
        %             1. switch to LS mode
                    obj.scanAngleMultiplierSlow = 0;
                    obj.hLSM.scanAngleMultiplierSlow = 0;

                    obj.stackNumSlices = 1;
                    obj.acqNumFrames = 70;

        %             2. grab 1 frame, save as matrix
                    obj.startGrab();
                    pause(4);
                    A = obj.temp_image(:,:,1); % use channel 1

                    there = mean(A(:,1:2:end),2);
                    back = mean(A(:,2:2:end),2);

        %             3. crosscorrelation of subsequent lines (averaging)
                    C0 = ifftshift(ifft(conj(fft(there)).*fft(there)));
                    C1 = ifftshift(ifft(conj(fft(there)).*fft(back)));
                    [~,C0max] = max(C0);%(l_there/2-50:l_there/2+50));
                    subpixelCorrection = (log(C0(C0max-1))-log(C0(C0max+1))) / (log(C0(C0max-1)) + log(C0(C0max+1)) - 2*log(C0(C0max))) / 2;
                    C0max = C0max + subpixelCorrection;
                    [~,C1max] = max(C1);%(l_there/2-50:l_there/2+50));
                    subpixelCorrection = (log(C1(C1max-1))-log(C1(C1max+1))) / (log(C1(C1max-1)) + log(C1(C1max+1)) - 2*log(C1(C1max))) / 2;
                    C1max = C1max + subpixelCorrection;
                    
                    C1max = C1max - C0max;
        %             4. change scanphase by 5 us
                    obj.lineScan_delay2 =  obj.lineScan_delay2 + 2;

        %             5. crosscorrelation of subsequent lines (averaging)
                    obj.startGrab();
                    pause(4);
                    B = obj.temp_image(:,:,1); % use channel 1
                    there2 = mean(B(:,1:2:end),2);
                    back2 = mean(B(:,2:2:end),2);
                    C2 = ifftshift(ifft(conj(fft(there2)).*fft(back2)));
                    C2 = C2 - mean(C2);
                    C2 = C2/max(C2);
                    [~,C2max] = max(C2);%(l_there/2-50:l_there/2+50));
                    % subpixel gaussian: 4 9 2 -->> x0 = (log(4)-log(2)) / ( log(2) + log(4) - 2* log(9)) / 2
                    subpixelCorrection = (log(C2(C2max-1))-log(C2(C2max+1))) / (log(C2(C2max-1)) + log(C2(C2max+1)) - 2*log(C2(C2max))) / 2;
                    C2max = C2max + subpixelCorrection;
                    C2max = C2max - C0max;

        %             6. calculate perfect match
                    change = -2*C2max/(C2max-C1max);
        %             7. change scanphase accordingly
                    if obj.lineScan_delay2 + change > 0
                        obj.lineScan_delay2 =  obj.lineScan_delay2 + real(change);
                        outcome = obj.lineScan_delay2;
                    end  
        %             8. switch back to non-line scan

                    pause(0.3);
                    obj.scanParamResetToBase({'scanAngleMultiplierSlow'});
                    if obj.scanAngleMultiplierSlow == 0
                        obj.scanAngleMultiplierSlow = 1;
                        obj.hLSM.scanAngleMultiplierSlow = 1;
                    end
                end
            obj.hLSM.channelsLogging = temp1;
            obj.hLSM.channelsViewing = temp2;
            obj.stackNumSlices = tempA;
            obj.acqNumFrames = tempB; 
            obj.framerate_user_check = tempC;
            obj.framerate_user = tempD;
            obj.channelsSave = tempX;
            obj.channelsDisplay = tempY;
            obj.loggingEnable = tempLog;
            
        end
            

        
        
        function scanParamResetToBase(obj,params)
            % Set ROI scan parameters (zoom,scanAngleMultiplier) to cached
            % values (set via scanParamSetCache()). If no values are
            % cached, restores the scan parameters stored in currently
            % loaded CFG file.
            
            % params: <OPTIONAL> String cell array specifically which parameter(s) to reset to BASE or CFG-file value(s)
            
            if nargin > 1
                cachedProps = params;
                assert(iscellstr(cachedProps) && all(ismember(cachedProps,obj.scanParamCacheProps)));
            else
                cachedProps = obj.scanParamCacheProps;
            end
            
            if ~isempty(obj.scanParamCache)
                for i=1:length(cachedProps)
                    obj.(cachedProps{i}) = obj.scanParamCache.(cachedProps{i});
                end
            else
                cfgfile = obj.cfgFilename;
                
                resetFailProps = {};
                if exist(cfgfile,'file')==2
                    cfgPropSet = obj.mdlLoadPropSetToStruct(cfgfile);
                    
                    for i=1:length(cachedProps)
                        if isfield(cfgPropSet,cachedProps{i})
                            obj.(cachedProps{i}) = cfgPropSet.(cachedProps{i});
                        else
                            resetFailProps{end+1} = cachedProps{i};   %#ok<AGROW>
                        end
                    end
                end
                
                if ~isempty(resetFailProps)
                    warning('SI4:scanParamNotReset',...
                        'One or more scan parameters (%s) were not reset to base or config file value.',most.util.toString(resetFailParams));
                    
                end
            end
        end
        
        function scanParamSetBase(obj)
            %Caches scan parameters (zoom, scan angle multiplier) which can be recalled by scanParamResetToBase() method
            
            cachedProps = obj.scanParamCacheProps;
            for i=1:length(cachedProps)
                obj.scanParamCache.(cachedProps{i}) = obj.(cachedProps{i});
            end
        end
        
    end
    
    %% PUBLIC METHODS (Stack Operations)
    methods
        
        function stackSetStackStart(obj)
            %Save curent motor Z position and beam power level as stack start point
            
            obj.stackZStartPos = obj.stackCurrentMotorZPos;
            obj.stackStartPower = obj.beamPowers;
        end
        
        function stackSetStackEnd(obj)
            %Save curent motor Z position and beam power level as stack end point
            
            obj.stackZEndPos = obj.stackCurrentMotorZPos;
            obj.stackEndPower = obj.beamPowers;
        end
        
        function stackClearStartEnd(obj)
            %Clear any saved stack start & end points
            
            obj.stackZStartPos = nan;
            obj.stackStartPower = nan; % todo multibeam
            obj.stackZEndPos = nan;
            obj.stackEndPower = nan; % todo multibeam
        end
        
        function stackClearEnd(obj)
            %Clear saved stack end point (if set)
            
            obj.stackZEndPos = nan;
            obj.stackEndPower = nan; % todo multibeam
        end
        
    end
    
    %% PUBLIC METHODS (Usr/Cfg/FastCfg File API)
    methods
        
        function usrSaveUsr(obj)
            % Save 1) current values of USR property subset, 2) current GUI
            % layout, and 3) currently loaded CFG file (if any) to
            % currently specified usrFilename
            
            obj.usrSaveUsrAs(obj.usrFilename);
        end
        
        function usrSaveUsrAs(obj,fname,cfgfname)
            % Save 1) current values of USR property subset, 2) current GUI
            % layout, and 3) currently loaded CFG file (if any) to
            % specified or selected USR filename
            
            % fname (optional): usr filename. If unspecified or empty, uiputfile is run.
            % cfgfname (optional): cfg filename to be associated with specified usr file. If empty or not specified, obj.cfgFilename is used.
            
            if nargin < 2
                fname = [];
            end
            if nargin < 3
                cfgfname = obj.cfgFilename;
            end
            
            obj.ensureClassDataFile(struct('lastUsrFile',most.idioms.startPath));
            usrFileName = obj.zprvUserCfgFileHelper(fname,...
                @()uiputfile('%.usr','Save Usr As...',obj.getClassDataVar('lastUsrFile')),...
                @(path,file,fullfile)assert(exist(path,'dir')==7,'Specified directory does not exist.'));
            if isempty(usrFileName) % usr cancelled
                return;
            end
            obj.setClassDataVar('lastUsrFile',usrFileName);
            
            % save usr subset
            obj.mdlSavePropSetFromList([obj.usrPropListCurrent; obj.versionPropNames; 'scanphases'],usrFileName);
            
            % save layout
            if ~isempty(obj.hController)
                assert(isscalar(obj.hController));
                obj.hController{1}.ctlrSaveGUILayout(usrFileName);
            end
            
            % save associated cfgfile
            cfgfileVarname = obj.usrCfgFileVarName;
            tmp.(cfgfileVarname) = cfgfname; %#ok<STRNU>
            save(usrFileName,'-struct','tmp','-mat','-append');
            
            obj.usrFilename = usrFileName;
        end
        
        function usrLoadUsr(obj,fname)
            % Load contents of specifed or selected USR file, updating 1)
            % values of USR property subset, 2) GUI layout, and 3)
            % currently loaded CFG file
            
            if obj.cfgOneShotLoaded
                error('SI4:oneShotCfgLoaded',...
                    'Cannot load user file; a one-shot configuration is pending.');
            end
            
            if nargin < 2
                fname = [];
            end
            
            obj.ensureClassDataFile(struct('lastUsrFile',most.idioms.startPath));
            usrFileName = obj.zprvUserCfgFileHelper(fname,...
                @()uigetfile('%.usr','Load Usr File...',obj.getClassDataVar('lastUsrFile')),...
                @(path,file,fullfile)assert(exist(fullfile,'file')==2,'Specified file does not exist.'));
            if isempty(usrFileName) % usr cancelled
                return;
            end
            obj.setClassDataVar('lastUsrFile',usrFileName);
            
            % load usr propset
            usrPropSetFull = obj.mdlLoadPropSetToStruct(usrFileName);
            usrPropSetApply = rmfield(usrPropSetFull,intersect(fieldnames(usrPropSetFull),obj.versionPropNames));
            
            % set usr* state
            obj.usrFilename = usrFileName;
            obj.usrPropListCurrent = fieldnames(usrPropSetApply);
            obj.usrPropSetLastLoaded = usrPropSetApply;
            
            % load associated cfgfilename
            usrSpecifiedCfgFilename = [];
            s = load(usrFileName,'-mat');
            if isfield(s,obj.usrCfgFileVarName)
                usrSpecifiedCfgFilename = s.(obj.usrCfgFileVarName);
            end
            
            % cfgFile handling
            % * If the usrFile specifies a cfgFile and it exists/loads
            % properly, that cfgfile will be used.
            % * If the usrFile specifies a cfgFile and it either doesn't
            % exist or doesn't load, no cfgFile will be used.
            % * If the usrFile doesn't specify a cfgFile (or specifies an
            % empty cfgFile), the current cfgFile will be used.
            if ~isempty(usrSpecifiedCfgFilename)
                if exist(usrSpecifiedCfgFilename,'file')==2
                    cfgfilename = usrSpecifiedCfgFilename;
                else
                    warning('SI4:fileNotFound',...
                        'Config file ''%s'' specified in usr file ''%s'' was not found.',usrSpecifiedCfgFilename,usrFileName);
                    cfgfilename = '';
                end
            elseif ~isempty(obj.cfgFilename) && exist(obj.cfgFilename,'file')==2
                cfgfilename = obj.cfgFilename;
            else
                % no cfg file associated with USR file; no cfg file currently loaded
                cfgfilename = '';
            end
            
            % apply usr/cfg state
            obj.mdlApplyPropSet(usrPropSetApply);
            if ~isempty(cfgfilename)
                try
                    obj.cfgLoadConfig(cfgfilename);
                catch %#ok<CTCH>
                    warning('SI4:errLoadingConfig',...
                        'Error loading config file ''%s''.',cfgfilename);
                end
            end
            
            % update layout
            if ~isempty(obj.hController)
                assert(isscalar(obj.hController));
                obj.hController{1}.ctlrLoadGUILayout(usrFileName);
            end
        end
        
        function cfgSaveConfig(obj)
            %Save values of (most) publicly settable properties of this class to currently loaded CFG file
            
            obj.cfgSaveConfigAs(obj.cfgFilename);
        end
        
        
        function cfgSaveConfigAs(obj,fname)
            %Save values of (most) publicly settable properties of this class to specified or selected CFG file
            
            % Save configuration to file and update .cfgFilename.
            % * If fname is not specified, uiputfile is called to get a file.
            % * If fname exists, config info is appended/overwritten to fname.
            % * If fname does not exist, it is created.
            
            if nargin < 2
                fname = [];
            end
            
            obj.ensureClassDataFile(struct('lastConfigFilePath',most.idioms.startPath));
            cfgfilename = obj.zprvUserCfgFileHelper(fname,...
                @()uiputfile('*.cfg','Save Config As...',obj.getClassDataVar('lastConfigFilePath')),...
                @(path,file,fullfile)assert(exist(path,'dir')==7,'Specified directory does not exist.'));
            if isempty(cfgfilename) % user cancelled
                return;
            end
            obj.setClassDataVar('lastConfigFilePath',fileparts(cfgfilename));
            
            % save it
            obj.mdlSavePropSetFromList(setdiff([obj.mdlDefaultConfigProps;obj.versionPropNames],obj.usrPropListCurrent), cfgfilename);
            obj.cfgFilename = cfgfilename;
        end
        
        function cfgLoadConfig(obj,fname)
            % Load contents of specifed or selected CFG file, updating
            % values of most publicly settable properties of this class.
            
            % * If fname is not specified, uigetfile is called to get a file.
            % * Config info is appended/overwritten to fname.
            
            if obj.cfgOneShotLoaded
                error('SI4:oneShotCfgLoaded',...
                    'Cannot load configuration; a one-shot configuration is pending.');
            end
            
            if nargin < 2
                fname = [];
            end
            
            obj.ensureClassDataFile(struct('lastConfigFilePath',most.idioms.startPath));
            cfgfilename = obj.zprvUserCfgFileHelper(fname,...
                @()uigetfile('*.cfg','Load Config...',obj.getClassDataVar('lastConfigFilePath')),...
                @(path,file,fullfile)assert(exist(fullfile,'file')==2,'Specified file does not exist.'));
            if isempty(cfgfilename)
                return;
            end
            obj.setClassDataVar('lastConfigFilePath',fileparts(cfgfilename));
            
            % At the moment, this just loads the cfg, ignoring possible
            % need to reload the USR, or parts of the USR.
            cfgPropSet = obj.mdlLoadPropSetToStruct(cfgfilename);
            cfgPropSetApply = rmfield(cfgPropSet,intersect(fieldnames(cfgPropSet),obj.versionPropNames));
            obj.mdlApplyPropSet(cfgPropSetApply);
            obj.cfgFilename = cfgfilename;
        end
        
        
        function cfgLoadConfigOneShot(obj,fname)
            % Load a specified/selected CFG file in 'one-shot' mode.
            % Property values loaded from CFG file are used for precisely
            % one acquisition (Grab or Loop) before restoring properties to
            % values at time of method call.
            
            % * One-shot configurations last through precisely one acquisition
            %   (Loop or Grab). After completion of the first acquisition, the
            %   configuration is "unloaded", ie the values of all properties
            %   set by the config are reverted to their original values.
            % * While one-shot configurations are pending (before acquisition
            %   is run), the user may not load a new usr or cfg file.
            
            if obj.cfgOneShotLoaded
                error('SI4:oneShotCfgLoaded',...
                    'One-shot configuration already loaded.');
            end
            
            if nargin < 2
                fname = [];
            end
            obj.ensureClassDataFile(struct('lastConfigFilePath',most.idioms.startPath));
            cfgfilename = obj.zprvUserCfgFileHelper(fname,...
                @()uigetfile('*.cfg','Load Config...',obj.getClassDataVar('lastConfigFilePath')),...
                @(path,file,fullfile)assert(exist(fullfile,'file')==2,'Specified file does not exist.'));
            if isempty(cfgfilename)
                return;
            end
            obj.setClassDataVar('lastConfigFilePath',fileparts(cfgfilename));
            
            propSet = obj.mdlLoadPropSetToStruct(cfgfilename);
            assert(isempty(obj.cfgOneShotRevertPropSet));
            obj.cfgOneShotRevertPropSet = obj.mdlApplyPropSet(propSet);
            obj.cfgOneShotLoaded = true;
        end
        
        function cfgUnloadConfigOneShot(obj)
            % Unloads a "pending" one-shot configuration (revert all
            % affected properties).
            
            if obj.cfgOneShotLoaded
                assert(~isempty(obj.cfgOneShotRevertPropSet));
                obj.mdlApplyPropSet(obj.cfgOneShotRevertPropSet);
                obj.cfgOneShotLoaded = false;
                obj.cfgOneShotRevertPropSet = [];
            end
        end
        
        
        function fastCfgSetConfigFile(obj,idx,fname)
            % Specify/select a CFG file to a numbered FastCFG,
            % for subsequent rapid (cached) loading with fastCfgLoadConfig()
            
            validateattributes(idx,{'numeric'},{'scalar' 'nonnegative' 'integer' '<=' obj.fastCfgNumConfigs});
            
            if nargin < 3
                fname = [];
            end
            
            obj.ensureClassDataFile(struct('lastFastConfigFilePath',most.idioms.startPath));
            cfgfilename = obj.zprvUserCfgFileHelper(fname,...
                @()uigetfile('*.cfg','Select Config File',obj.getClassDataVar('lastFastConfigFilePath')),...
                @(path,file,fullfile)assert(exist(fullfile,'file')==2,'Specified file does not exist.'));
            if isempty(cfgfilename) % user cancelled
                return;
            end
            obj.setClassDataVar('lastFastConfigFilePath',fileparts(cfgfilename));
            obj.fastCfgCfgFilenames{idx} = cfgfilename;
        end
        
        function fastCfgLoadConfig(obj,idx,tfBypassAutostart)
            %Load CFG file settings cached at a numbered FastCFG, autostarting acquisition if appropriate.
            
            % Load the idx'th fast config and autostart if
            % appropriate.
            % tfBypassAutostart: optional bool, defaults to false. If true, the
            % fastConfiguration is loaded but not autostarted, even if
            % autostart is on.
            switch idx
                case 1
                    obj.scanZoomFactor = 1.5;
                    obj.scanMode = 'unidirectional';
                    obj.displayRollingAverageFactor = 1;
                    obj.channelsDisplay2 = [1 2];
                case 2
                    obj.scanZoomFactor = 4.5;
                    obj.scanMode = 'bidirectional';
                    obj.displayRollingAverageFactor = 5;
                    obj.channelsDisplay2 = [1];
                case 3
                    obj.scanZoomFactor = 15;
                    obj.scanMode = 'bidirectional';
                    obj.displayRollingAverageFactor = 5;
                    obj.channelsDisplay2 = [1];
            end
                
%             
%             if nargin < 3
%                 tfBypassAutostart = false;
%             end
%             validateattributes(idx,{'numeric'},{'scalar' 'nonnegative' 'integer' '<=' obj.fastCfgNumConfigs});
%             validateattributes(tfBypassAutostart,{'logical'},{'scalar'});
%             
%             fname = obj.fastCfgCfgFilenames{idx};
%             if isempty(fname)
%                 error('SI4:fastCfgLoadConfig:noConfigFileLoaded',...
%                     'No config file loaded for fast configuration #%d.',idx);
%             end
%             if exist(fname,'file')~=2
%                 error('SI4:fastCfgLoadConfig:fileNotFound',...
%                     'Config file ''%s'' not found.',fname);
%             end
%             
%             if ~tfBypassAutostart && obj.fastCfgAutoStartTf(idx)
%                 obj.cfgLoadConfigOneShot(fname);
%                 autoStartType = obj.fastCfgAutoStartType{idx};
%                 switch autoStartType
%                     case 'focus'
%                         obj.startFocus();
%                     case 'grab'
%                         obj.startGrab();
%                     case 'loop'
%                         obj.startLoop();
%                     otherwise
%                         obj.cfgUnloadConfigOneShot();
%                         assert(false,'AutoStart type must be set.');
%                 end
%             else
%                 obj.cfgLoadConfig(fname);
%             end
        end
        
        function fastCfgClearConfigFile(obj,idx)
            %Clear CFG file settings cached at a numbered FastCFG
            
            validateattributes(idx,{'numeric'},{'scalar' 'nonnegative' 'integer' '<=' obj.fastCfgNumConfigs});
            obj.fastCfgCfgFilenames{idx} = '';
        end
        
    end
    
    %% PUBLIC METHODS (Misc)
    
    methods
        
        function h = imageHistogram(obj,chanIdx)
            %Compute & display histogram of pixel values for last displayed image acquired at specified chanIdx
            
            validateattributes(chanIdx,{'numeric'},...
                {'scalar' 'integer' 'positive' '<=' obj.channelsNumChannels});
            
            data = obj.zprvChannelDataCurrentDisplay(chanIdx);
            h = figure('DoubleBuffer','on','color','w','NumberTitle','off','Name','Pixel Histogram',...
                'PaperPositionMode','auto','PaperOrientation','landscape');
            hist(double(data(:)),256);
            set(get(gca,'XLabel'),'String','Pixel Intensity','FontWeight','bold','FontSize',12);
            set(get(gca,'YLabel'),'String','Number of Pixels','FontWeight','bold','FontSize',12);
        end
        
        function s = imageStats(obj,chanIdx)
            %Compute & display statistics of pixel values for last displayed image acquired at specified chanIdx
            
            validateattributes(chanIdx,{'numeric'},...
                {'scalar' 'integer' 'positive' '<=' obj.channelsNumChannels});
            
            data = obj.zprvChannelDataCurrentDisplay(chanIdx);
            
            s.mean = mean(data(:));
            s.std = double(std(single(data(:)))); % AL: this double(single(...)) thing is historic. why?
            s.max = max(data(:));
            s.min = min(data(:));
            s.pixels = numel(data);
            
            if nargout == 0
                ImageStats = s;
                assignin('base','ImageStats',ImageStats);
                evalin('base','ImageStats');
            end
        end
        
    end
    
    %% HIDDEN METHODS (Callbacks)
    
    methods (Hidden)
        
        %Callback methods
        function frameAcquiredFcn(obj,bufferIndex,bufferCount,dropFrames)
            if dropFrames ~= 0
                dropFrames
            end
            if obj.lowVal == bufferCount
                obj.shuttersTransition(true);
            end
            if strcmpi(obj.acqState,'idle')
                return;
            end
            pbuffer = obj.hLSM.buffers{1, bufferIndex};

            inverted_channels = ismember([1 2 3],obj.channelsInvert);

            if obj.acqDebug
                fprintf(1,'faf\n');
                fprintf(1,'motor pos: %s\n',mat2str(obj.motorPosition));
                fprintf(1,'power lev: %.4g\n',obj.beamPowers);
            end
            %vvv: For now, there's a shared callback between FOCUS and GRAB/LOOP modes...may make sense to split a-la-SI3.x
            try
                %Get frame data from LSM
                % Wait for the first available buffer to be filled by the board : this
                % is the central part of the whole program
                [retCode, ~, bufferOut] = ...
                    calllib('ATSApi', 'AlazarWaitAsyncBufferComplete', obj.hLSM.ATSboardHandle, pbuffer,obj.hLSM.bufferTimeout_ms);
                if retCode == 512
                    if dropFrames
                        fprintf('Drop frame (still in buffer from last slice) ...\n');
                         % Make the buffer available to be filled again by the board
                        retCode2 = calllib('ATSApi', 'AlazarPostAsyncBuffer', obj.hLSM.ATSboardHandle, pbuffer, obj.hLSM.bytesPerBuffer);
                        if retCode2 ~= 512
                            fprintf('Error: AlazarPostAsyncBuffer failed -- %s\n', errorToText(retCode));
                            obj.captureDone = true;
                        end 
                        return;
                    end
                    % This buffer is full
                     obj.captureDone = false;
                elseif retCode == 579 
                    % The wait timeout expired before this buffer was filled. The board may not be triggering, or the timeout period may be too short.
                    fprintf('Error: AlazarWaitAsyncBufferComplete timeout -- Verify trigger!\n');
                    obj.captureDone = true;
                else
                    % The acquisition failed 
                    fprintf('Error: AlazarWaitAsyncBufferComplete failed -- %s\n', errorToText(retCode));
                    obj.captureDone = true;
                end
                setdatatype(bufferOut, 'uint16Ptr', 1, obj.hLSM.samplesPerBuffer);
%                setdatatype(bufferOut, 'doublePtr', 1, obj.hLSM.samplesPerBuffer);
                % Save the buffer to file, alternatively to a matrix 
                
                nb_processed_channels = sum(obj.hLSM.channelsLogging | obj.hLSM.channelsViewing);
                if nb_processed_channels == 3
                    nb_processed_channels = 2;
                    processed_channels = [1 1 0];
                else
                    processed_channels = (obj.hLSM.channelsLogging | obj.hLSM.channelsViewing)';
                end
                
                if obj.multiChanAVG > 1
                    reshape(bufferOut,4096*nb_processed_channels*obj.multiChanAVG,obj.scanLinesPerFrame); 
                else
                    reshape(bufferOut,4096*nb_processed_channels,obj.scanLinesPerFrame); 
                end
                binning = 4096/obj.scanPixelsPerLine;
                if obj.multiChanAVG > 1
                    A = bufferOut.Value; 
                    obj.temp_image = 2^14-PRmx_delayedChannels_Binning_bidi_db(A,obj.scanLinesPerFrame,obj.scanPixelsPerLine,nb_processed_channels,binning,4,obj.multiChanAVG); % PR2014: MEX function for fast binning with nb of threads in the 2nd last argument
                    nb_processed_channels = 1;
                    processed_channels = [1 0 0];
                elseif nb_processed_channels == 2
                    A = bufferOut.Value;
                    lookingForInvert = find(inverted_channels(processed_channels));
                    if numel(lookingForInvert) == 2
                        if strcmp(obj.scanMode,'bidirectional')
                            obj.temp_image = 2^14-PRmx_multiChannelBinning_bidi_db(A,obj.scanLinesPerFrame,obj.scanPixelsPerLine,nb_processed_channels,binning,4); % PR2014: MEX function for fast binning with nb of threads in the last argument
                        else
                            obj.temp_image = 2^14-PRmx_multiChannelBinning_uni_db(A,obj.scanLinesPerFrame,obj.scanPixelsPerLine,nb_processed_channels,binning,4); % PR2014: MEX function for fast binning with nb of threads in the last argument
                        end
                    else
                        if strcmp(obj.scanMode,'bidirectional')
                            obj.temp_image = PRmx_multiChannelBinning_bidi_db(A,obj.scanLinesPerFrame,obj.scanPixelsPerLine,nb_processed_channels,binning,4); % PR2014: MEX function for fast binning with nb of threads in the last argument
                        else
                            obj.temp_image = PRmx_multiChannelBinning_uni_db(A,obj.scanLinesPerFrame,obj.scanPixelsPerLine,nb_processed_channels,binning,4); % PR2014: MEX function for fast binning with nb of threads in the last argument
                        end
                   end
                    obj.temp_image = reshape(obj.temp_image,obj.scanPixelsPerLine,obj.scanLinesPerFrame,nb_processed_channels);
                    if numel(lookingForInvert) == 1
                        obj.temp_image(:,:,processed_channels(lookingForInvert)) = 2^14 - obj.temp_image(:,:,processed_channels(lookingForInvert));
                    end
                elseif nb_processed_channels == 1
                    A = bufferOut.Value;
                        if inverted_channels(processed_channels)
                            if strcmp(obj.scanMode,'bidirectional')
                                obj.temp_image = 2^14-PRmx_singleChannelBinning_bidi_db(A,obj.scanLinesPerFrame,obj.scanPixelsPerLine,nb_processed_channels,binning,4); % PR2014: MEX function for fast binning with nb of threads in the last argument
                            else
                                obj.temp_image = 2^14-PRmx_singleChannelBinning_uni_db(A,obj.scanLinesPerFrame,obj.scanPixelsPerLine,nb_processed_channels,binning,4); % PR2014: MEX function for fast binning with nb of threads in the last argument
                            end
                        else
                            if strcmp(obj.scanMode,'bidirectional')
                                obj.temp_image = PRmx_singleChannelBinning_bidi_db(A,obj.scanLinesPerFrame,obj.scanPixelsPerLine,nb_processed_channels,binning,4); % PR2014: MEX function for fast binning with nb of threads in the last argument
                            else
                                obj.temp_image = PRmx_singleChannelBinning_uni_db(A,obj.scanLinesPerFrame,obj.scanPixelsPerLine,nb_processed_channels,binning,4); % PR2014: MEX function for fast binning with nb of threads in the last argument
                            end
                        end
                    obj.temp_image = reshape(obj.temp_image,obj.scanPixelsPerLine,obj.scanLinesPerFrame,nb_processed_channels);

                else
                    disp('Error: This should never occur...');
                end
                
                try 
                    saved_channels = nonzeros(processed_channels(obj.channelsSave).*obj.channelsSave);
                catch
                    saved_channels = nonzeros(processed_channels(obj.channelsSave)'.*obj.channelsSave);
                end
                nb_saved_channels = sum(processed_channels(obj.channelsSave));
                try
                    chansToDisp = nonzeros(processed_channels(obj.channelsDisplay).*obj.channelsDisplay);
                catch
                    chansToDisp = nonzeros(processed_channels(obj.channelsDisplay)'.*obj.channelsDisplay);
                end
                obj.savingYes = obj.loggingEnable ~= 0 && (obj.focusSave || ~strcmpi(obj.acqState,'focus'));
                obj.acqFramesDoneTotally = obj.acqFramesDoneTotally + 1;
                if obj.savingYes
                    if obj.write2RAM && ~strcmpi(obj.acqState,'focus')
                        obj.BIG_FILE(:,:,obj.acqFramesDoneTotally) = obj.temp_image;
                    elseif obj.acqNumAveragedFrames == 1 || obj.offlineAveraging
                        if nb_saved_channels < nb_processed_channels
                            if setdiff(nonzeros(processed_channels.*(1:3)),saved_channels) > saved_channels
                                samplesWritten = fwrite(obj.hLSM.fid, obj.temp_image(:,:,1), 'double');
                            else
                                samplesWritten = fwrite(obj.hLSM.fid, obj.temp_image(:,:,2), 'double');
                            end
                        else
                            samplesWritten = fwrite(obj.hLSM.fid, obj.temp_image, 'double');
                        end
                        if samplesWritten ~= obj.scanLinesPerFrame*obj.scanPixelsPerLine*nb_saved_channels
                            fprintf('Error: Write buffer failed\n');
                        end
%                             for i = 1:length(obj.channelsDisplay)
%                                 obj.hLSM.fid.appendFrame(obj.temp_image(:,:,i));
%                             end
                    elseif mod(bufferCount,obj.acqNumAveragedFrames) ~= 0
                        obj.averagedStorage = obj.averagedStorage + obj.temp_image;
                    elseif mod(bufferCount,obj.acqNumAveragedFrames) == 0
                        obj.averagedStorage = obj.averagedStorage + obj.temp_image;
                        if nb_saved_channels < nb_processed_channels
                            if numel(chansToDisp) > saved_channels
%                                 figure(141212); imagesc(obj.averagedStorage(:,:,1)/obj.acqNumAveragedFrames)
                                samplesWritten = fwrite(obj.hLSM.fid, obj.averagedStorage(:,:,1)/obj.acqNumAveragedFrames, 'double');
                            else
                                samplesWritten = fwrite(obj.hLSM.fid, obj.averagedStorage(:,:,2)/obj.acqNumAveragedFrames, 'double');
                            end
                        else
                            samplesWritten = fwrite(obj.hLSM.fid, obj.averagedStorage/obj.acqNumAveragedFrames, 'double');
                        end
                        if samplesWritten ~= obj.scanLinesPerFrame*obj.scanPixelsPerLine*nb_saved_channels
                            fprintf('Error: Write buffer failed\n');
                        end
                        obj.averagedStorage = zeros(size(obj.averagedStorage));
                    end
                end
                obj.acqFrameBuffer{end} = obj.temp_image;
                frameTag = bufferCount;
                %Circular permutation so that first element is most-recent frame %TODO: Handle missed frames
                obj.acqFrameBuffer = [obj.acqFrameBuffer(end);obj.acqFrameBuffer(1:end-1)]; %% PR2014: is this time-expensive ?
                
                %Signal that frame has been acquired
                obj.acqFramesDoneTotal = frameTag;                
                notify(obj,'frameAcquired');
                %Update logging file number, if needed (for case of next triggered, FastZ stacks)
                if obj.fastZNextTrigSignal
                    if obj.triggerFrameNumber > 1 && obj.acqFramesDoneTotal >= (obj.triggerFrameNumber - 1)
                        obj.zprvSetInternal('loggingFileCounter', obj.loggingFileCounter + obj.fastZNextTrigSignal);
                        obj.fastZNextTrigSignal = 0;
                    end
                end
                %Determine current state
                focusingNow = strcmpi(obj.acqState,'focus');
                fastZAcq = obj.fastZEnable && obj.stackNumSlices > 1 && ~focusingNow;
                
                %Update logging file name/number, as needed for loggingFramesPerFile implementation
                if obj.loggingEnable && obj.loggingFileNumChunks && ~focusingNow
                    if obj.stackNumSlices == 1 || obj.fastZEnable
                        nextFileSubCounter = floor(obj.acqFramesDoneTotally / (obj.acqNumAveragedFrames * obj.loggingFramesPerFile)) + 2;
                    else
                        nextFileSubCounter = floor((obj.acqFramesDoneTotally + obj.acqNumFrames * obj.stackSlicesDone) / (obj.acqNumAveragedFrames * obj.loggingFramesPerFile)) + 2;
                    end
                    if obj.acqDebug
                        fprintf(1,'nextFileSubCounter loggingfileSubcounter loggingFileNumChunks: %d %d %d\n',nextFileSubCounter, obj.loggingFileSubCounter, obj.loggingFileNumChunks);
                    end
                    
                    if nextFileSubCounter > obj.loggingFileSubCounter && nextFileSubCounter <= obj.loggingFileNumChunks
                        obj.loggingFileSubCounter = nextFileSubCounter;
                        
                        newFileName = zlclConstructLoggingFullFileName(obj.loggingFilePath,obj.loggingFileStem,obj.loggingFileCounter,nextFileSubCounter);
                        newFileFrameCount = (nextFileSubCounter - 1) * (obj.loggingFramesPerFile * obj.acqNumAveragedFrames) + 1;
                        
                        rolloverLogFile(obj.hLSM,newFileFrameCount,'loggingFileName',newFileName);
                    end
                end
                %Stop acquisition and start motor move to next slice, as needed
                if ~focusingNow && ~obj.fastZEnable && obj.stackNumSlices > 1 && obj.acqFramesDoneTotal >= obj.acqNumFrames
                    if abs(obj.stackZStepSize) > obj.stackShutterCloseMinZStepSize
                        shuttersTransition(obj,false);
                    end
                    obj.stackSlicesDone = obj.stackSlicesDone + 1;
                    if obj.stackSlicesDone < obj.stackNumSlices
                        obj.stackZMotor.moveStartIncremental([0 0 obj.stackZStepSize]);
                        zprvBeamsDepthPowerCorrection(obj,obj.stackZStepSize,obj.acqBeamLengthConstants);
                    end
                    pause(0.2);
                    obj.overshoot = obj.hFramePeriodCtr.get('readTotalSampPerChanAcquired') + 1 - obj.acqFramesDoneTotal;
                    zprvStopAcquisition(obj,false,true); %Stops acquisition in 'pause' mode, allowing it to be resumed, e.g. to support logging to same file-stream    %Stops acquisition, but allows it to be 'resumed' with subsequent zprvResumeAcquisition()
                    obj.notify('sliceDone');
                end
                
                %Update FastZ beam data, if required
                if fastZAcq && obj.fastZAllowLiveBeamAdjust && (obj.beamFlybackBlanking || obj.beamPzAdjust)
                    zprvBeamsRefreshFastZData(obj,1);
                end
                if obj.showMeanLive
                    obj.meanValueShow = mean(obj.temp_image(:))-2^13+200;
                    obj.maxValueShow = max(obj.temp_image(:))-2^13+200;
                end
                %Identify current frame within the acquisition frame buffer
                frameBatchIdx = mod(obj.acqFramesDoneTotal-1,obj.displayFrameBatchFactor) + 1;
                [displayTF, tileIdx] = ismember(frameBatchIdx,obj.displayFrameBatchSelection);
                if displayTF
                    %Handle averaging, as needed
                    %Note that if any frames were missed, then the rolling average will now simply stretch back further in time
                    %A different behavior might be preferable, but probably not worth complicating logic significantly for a hopefully rare case
                    rollAveFactor = obj.displayRollingAverageFactor;
                    if rollAveFactor > 1 %Display averaging enabled

                        selectedFramesDone = ceil(obj.acqFramesDoneTotally/obj.displayFrameBatchFactor);
                        if selectedFramesDone == 1
                            obj.displayRollingBuffer{tileIdx} = double(obj.acqFrameBuffer{1});
                        elseif selectedFramesDone <= rollAveFactor
                            obj.displayRollingBuffer{tileIdx} = ((selectedFramesDone - 1) * obj.displayRollingBuffer{tileIdx} + double(obj.acqFrameBuffer{1})) / selectedFramesDone;
                        else
                            removeIdx = obj.displayRollingAverageFactor * (obj.displayFrameBatchFactor / obj.frameAcqFcnDecimationFactor) + 1;
                            if ~isempty(obj.acqFrameBuffer{removeIdx})
                                obj.displayRollingBuffer{tileIdx} = obj.displayRollingBuffer{tileIdx} + (double(obj.acqFrameBuffer{1}) - double(obj.acqFrameBuffer{removeIdx})) / rollAveFactor;
                            end
                        end
                    end
                    %Handle display, if frame is selected for display
                    if mod(obj.acqFramesDoneTotal-1,obj.frameDecimationFactor) == 0
                        
                        abortUpdate = false;
                        for i=1:length(chansToDisp)
                            chanIdx=chansToDisp(i);
                                if chanIdx ~= 2
                                    reduce_offset = 2^13-200;
                                    if obj.mergeAlign
                                        obj.acqFrameBuffer{1}(:,:,i) = circshift(obj.acqFrameBuffer{1}(:,:,i),[-obj.mergeshift 0 0]);
                                    end
                                else
                                    reduce_offset = 0;
                                end
                            hChan = obj.channelsHImage{chanIdx};
                            if numel(hChan) < tileIdx || ~ishandle(hChan(tileIdx))
                                abortUpdate = true;
                                break;
                            end
                            if obj.mroiEnabled
                                zprvMultiROIDisplayFcn(obj,hChan(tileIdx),tileIdx,i);
                            else
                                if obj.ATduringFocusing
                                   if obj.displayRollingAverageFactor > 1
                                       l1 = size(obj.displayRollingBuffer{tileIdx}(:,:,i)'-reduce_offset,2);
%                                        l2 = zeros(size(obj.displayRollingBuffer{tileIdx}(:,:,i)'-reduce_offset),2);
                                       if mod(30,obj.acqFramesDoneTotal) > 15
                                           ls = 64;
                                       else
                                           ls = 32;
                                       end
                                       range1 = 1:l1;
                                       for gg = 1:(floor(l1/ls)-1)
                                           range1((ls*gg+1):((ls*gg+1)+ls/2-1)) = 0;
                                       end
                                       range1(range1 == 0) = [];
                                       range2 = setdiff(1:l1,range1);
                                       AA = zeros(size(obj.displayRollingBuffer{tileIdx}(:,:,i)'));
                                       AA(:,range2) = obj.displayRollingBuffer{tileIdx}(range2,:,i)'-reduce_offset;
                                       AA(:,range1) = obj.ATrefImage(range1,:)'-reduce_offset;
                                       set(hChan(tileIdx),'CData',AA); %There is no need to convert this to type spec'd by obj.channelsDataType
%                                        obj.acqFramesDoneTotal
%                                        obj.frameDecimationFactor
%                                     if mod(obj.acqFramesDoneTotal-1,obj.frameDecimationFactor+1) == 0
%                                         set(hChan(tileIdx),'CData',obj.displayRollingBuffer{tileIdx}(:,:,i)'-reduce_offset); %There is no need to convert this to type spec'd by obj.channelsDataType
%                                     else
%                                         set(hChan(tileIdx),'CData',obj.ATrefImage'-reduce_offset);
%                                     end
                                   else
                                        if mod(obj.acqFramesDoneTotal-1,obj.frameDecimationFactor+1) == 0
                                            set(hChan(tileIdx),'CData',obj.acqFrameBuffer{1}(:,:,i)'-reduce_offset);
                                        else
                                            set(hChan(tileIdx),'CData',obj.ATrefImage'-reduce_offset);
                                        end
                                   end 
                                elseif mod(bufferCount,obj.acqNumAveragedFrames) ~= 0 && strcmp(obj.acqState,'grab') && obj.acqNumAveragedFrames > obj.displayRollingAverageFactor && ~obj.offlineAveraging && ~obj.write2RAM
                                    set(hChan(tileIdx),'CData',obj.averagedStorage(end:-1:1,:,i)'/mod(bufferCount,obj.acqNumAveragedFrames)-reduce_offset);
%                                     set(hChan(tileIdx),'CData',obj.averagedStorage(:,:,i)'/mod(bufferCount,obj.acqNumAveragedFrames)-reduce_offset);
                                elseif obj.displayRollingAverageFactor > 1
                                    set(hChan(tileIdx),'CData',obj.displayRollingBuffer{tileIdx}(end:-1:1,:,i)'-reduce_offset); %There is no need to convert this to type spec'd by obj.channelsDataType
%                                     set(hChan(tileIdx),'CData',obj.displayRollingBuffer{tileIdx}(:,:,i)'-reduce_offset); %There is no need to convert this to type spec'd by obj.channelsDataType
                                else
                                    set(hChan(tileIdx),'CData',obj.acqFrameBuffer{1}(end:-1:1,:,i)'-reduce_offset);
%                                     set(hChan(tileIdx),'CData',obj.acqFrameBuffer{1}(:,:,i)'-reduce_offset);
                                end % CHANGED IN 2016 to flip left and right sides
                            end
                        end
                        if ~abortUpdate
                            zprvUpdateMergeWindowIfNecessary(obj,tileIdx);
                        end
                    end
                end
                %Update Frame Counters
                if ~focusingNow && obj.loggingEnable  %Account for possible next-triggered file breaks -- count will reflect frames/slices/volumes done since last next trigger
                    framesDoneSinceFileBreak = obj.acqFramesDoneTotally - obj.loggingFrameBreaks(end) + 1; % TAPIR
                else
                    framesDoneSinceFileBreak = obj.acqFramesDoneTotally;
                end
                
                if ~focusingNow && obj.fastZEnable
                    framesPerVolume = obj.fastZNumFramesPerVolume;
                    
                    obj.fastZVolumesDone = floor(framesDoneSinceFileBreak/framesPerVolume);
                    obj.stackSlicesDone = min((framesDoneSinceFileBreak - obj.fastZVolumesDone * framesPerVolume)/obj.acqNumFrames, obj.stackNumSlices);
                    obj.acqFramesDone = min(framesDoneSinceFileBreak - obj.stackSlicesDone * obj.acqNumFrames, obj.acqNumFrames);
                else
%                     obj.stackNumSlices XXXXXXX
%                     obj.stackSlicesDone
%                     obj.acqNumFrames
                    obj.acqFramesDone = framesDoneSinceFileBreak;%- obj.acqNumFrames*obj.stackSlicesDone;
                end


                % Make the buffer available to be filled again by the board
                retCode = calllib('ATSApi', 'AlazarPostAsyncBuffer', obj.hLSM.ATSboardHandle, pbuffer, obj.hLSM.bytesPerBuffer);
                if retCode ~= 512
                    fprintf('Error: AlazarPostAsyncBuffer failed -- %s\n', errorToText(retCode));
                    obj.captureDone = true;
                end 
                %Acquisition mode-specific behavior
                switch obj.acqState
                    case 'focus'
                        if etime(clock, obj.triggerClockTimeFirstVec) >= obj.focusDuration
                            zprvStopAcquisition(obj,true); %effectively an abort operation
                            obj.acqState = 'idle'; %should we do this already here?
                        end
                        
                    case {'grab' 'loop'}
                        %obj.acqFramesDone = evnt.frameCount;
                        
                        %fprintf(1,'%d %d\n',obj.acqFramesDoneTotal,max(0,obj.hLSM.droppedFramesLast));
                        
                        %Generally acqFramesDoneTotal=acqFramesDone, but for 2 special cases - next triggering and fastZ
                        %In both special cases, acqFramesDoneTotal > acqFramesDone
                        %In next triggering case (without FastZ), acquisition should be terminated if acqFramesDone reaches acqNumFramesPerTrigger (acqFramesDone is the number of frames since the last next trigger)
                        %In FastZ case, acquisition should be terminated based on acqFramesDoneTotal value (which counts each of the FastZ slices as separate frames)
                        
                        
                        acqFramesDoneMax = obj.acqNumFramesPerTrigger;
                        if ~focusingNow && obj.fastZEnable
                            acqFramesDoneVal = obj.acqFramesDoneTotal;
                            
                            if ~isempty(obj.loggingFrameBreaks); %FastZ + next triggering combo
                                acqFramesDoneMax = acqFramesDoneMax + obj.loggingFrameBreaks(end) - 1;
                            end
                        else
                            acqFramesDoneVal = obj.acqFramesDone;
                        end
                        
                        if mod(acqFramesDoneVal-1,acqFramesDoneMax) == acqFramesDoneMax - 1
                            if obj.motorHasMotor && obj.stackNumSlices > 1 && ~obj.fastZEnable && obj.stackSlicesDone < obj.stackNumSlices
                                moveWaitForFinish(obj.stackZMotor);
                                notify(obj,'motorPositionUpdate'); % call setter to fire Post-Set event for GUI
                                %Check to see if there's been any abort() calls since the last slice acq was stopped
                                drawnow();
                                if isIdle(obj)
                                    return;
                                end
                                %Start next slice
                                if abs(obj.stackZStepSize) > obj.stackShutterCloseMinZStepSize
                                    shuttersTransition(obj,true,true);
                                end
                                zprvStartAcquisitionSlice(obj);
                                
                            else
                                switch obj.acqState
                                    case 'grab'
                                        zprvEndAcquisition(obj,'idle');
                                        zprvEndAcquisitionMode(obj);
                                    case 'loop'
                                        if obj.triggerNextTrigUsed && strcmpi(obj.triggerNextTrigMode,'advance') %For now - In 'advance' next-triggered mode - acqNumFrames indicates a max number of frames that should never actually be reached between next trigger arrivals. In future, should allow restart by subsequent start trigger arrival.
                                            zprvEndAcquisition(obj,'idle');
                                            zprvEndAcquisitionMode(obj);
                                        else
                                            zprvEndAcquisition(obj,'loop_wait');
                                            zprvIterateLoop(obj);
                                        end
                                end
                                
                            end
                        end
                    case {'idle'}
                        %Do nothing...should this be an error?
                end
%                 f(19) = toc;
%                 tic
            catch ME
                fprintf(2,'Error in frameAcquiredFcn:\n%s\n',most.idioms.reportError(ME));
                %ME.rethrow(); %this doesn't actually work
            end
            
            
%             f(20) = toc;
%             sum(f)
%             figure(141), plot(f)
        end
        
        function zprvMultiROIDisplayFcn(obj,hIm,tileIdx,i)
            
            if obj.displayRollingAverageFactor > 1
                srcImage = obj.displayRollingBuffer{tileIdx}(:,:,i); %There is no need to convert this to type spec'd by obj.channelsDataType
            else
                srcImage = obj.acqFrameBuffer{1}(:,:,i);
            end
            
            numROI = length(obj.mroiParams);
            %             maxIdxyInc = max([obj.mroiParams.scanLinesPerFrame]);
            %             numRowTiles = ceil(sqrt(numROI));
            %             numColTiles = ceil(sqrt(numROI));
            %             numPixelsPerTilePerCol = numRowTiles*maxIdxyInc;
            %             numPixelsPerTilePerRow = numColTiles*obj.scanPixelsPerLine;
            %             im = 255*ones(numPixelsPerTilePerCol,numPixelsPerTilePerRow); % Fit to closest square arrangement i.e. for n ROIs create mxm tiles s.t. m*m > n
            %
            %             startIdxx = 1;
            %             startIdxy = 1;
            %             numROIs = length(obj.mroiParams);
            %             ROIIdx = 1;
            
            
            %             for i=1:numRowTiles
            %                 for j=1:numColTiles
            %                     if (ROIIdx <= numROIs)
            %                         %TEST
            %                         srcImage(obj.mroiTransitNumLines(ROIIdx)+1 : obj.mroiTransitNumLines(ROIIdx)+obj.mroiParams(ROIIdx).scanLinesPerFrame,1:10) = 0;
            %                         srcImage(obj.mroiTransitNumLines(ROIIdx)+1 : obj.mroiTransitNumLines(ROIIdx)+obj.mroiParams(ROIIdx).scanLinesPerFrame,end-10:end) = 0;
            %                         srcImage(obj.mroiTransitNumLines(ROIIdx)+1 , :) = 0;
            %                         srcImage(obj.mroiTransitNumLines(ROIIdx)+obj.mroiParams(ROIIdx).scanLinesPerFrame,:) = 0;
            %
            %                         %TEST
            %
            %                         im(startIdxx:startIdxx+obj.mroiParams(ROIIdx).scanLinesPerFrame-1,startIdxy:startIdxy+obj.scanPixelsPerLine-1) ...
            %                           = srcImage(obj.mroiTransitNumLines(ROIIdx)+1 : obj.mroiTransitNumLines(ROIIdx)+obj.mroiParams(ROIIdx).scanLinesPerFrame,:);
            %                     else
            %                         break;
            %                     end
            %                     ROIIdx = ROIIdx+1;
            %                     startIdxy = startIdxy+obj.scanPixelsPerLine;
            %                 end
            %                 startIdxy = 1;
            %                 startIdxx = startIdxx+maxIdxyInc;
            %             end
            
            dispTiling = obj.mroiComputedParams.dispTiling;
            %tileRows = dispTiling(1);
            tileCols = dispTiling(2);
            
            tilePPL = obj.mroiPixelsPerLine;
            tileLPFs = [obj.mroiComputedParams.dispTilingLinesPerRow]; %Array, element per tiled display row
            
            lsmLineCurrent = 0;
            imageRowCurrent = 0;
            
            %TODO: Consider extracting final ROI set from LSM frame, instead of first one (i.e. to be most recent)
            
            %Transfer one ROI set from the LSM frame to display image (ignoring remainder of ROI sets in frame, if any)
            im = zeros(sum(tileLPFs),tileCols * tilePPL,class(srcImage));
            for i=1:numROI
                tileRow = floor(i/tileCols)+1;%mod(i-1,tileCols) + 1;
                tileCol = rem(i-1,tileCols)+1;
                
                %Advance imageRowStart counter, at start of new row
                if tileCol == 1 && tileRow > 1
                    imageRowCurrent = imageRowCurrent + tileLPFs(tileRow-1);
                end
                
                %Update image
                lsmLinesImaging = obj.mroiParams(i).scanLinesPerFrame;
                lsmLinesTransit = obj.mroiComputedParams.transitNumLines(i);
                
                %Determine target indices in image
                imCols = (1:tilePPL) + (tileCol-1)*tilePPL;
                imRows = imageRowCurrent + (1:lsmLinesImaging);
                
                im(imRows,imCols) = srcImage(lsmLineCurrent + (1:lsmLinesImaging),:);
                
                %Advance LSM line counter
                lsmLineCurrent = lsmLineCurrent + (lsmLinesImaging + lsmLinesTransit);
            end
            
            %Update display image
            set(hIm,'CData',im);
            
            %fprintf('----\n');
        end
        
        function xTriggerFcn(obj,~,~)
            [~,B] = obj.hFramePeriodCtr.readCounterData();
            obj.frameCounter = obj.frameCounter + B;
%             disp(obj.frameCounter)
            if  obj.frameCounter >= obj.acqNumFrames
                obj.hLSM.frameClock.stop();
                drawnow;
                obj.shuttersTransition(false,true);
            end
        end
        
        function triggerFcn(obj,~,~)
            %Callback which fires on each trigger (start or next) during GRAB/LOOP acquisitions
            firstTrig = isinf(obj.triggerTime); %is this first trigger of GRAB/LOOP acq mode?
            nextTrig = ~firstTrig && (obj.triggerNextTrigOnly || strcmpi(obj.triggerLastArmed,'next'));
            startTrig = ~nextTrig;
            nextSlice = obj.stackSlicesDone > 0 && ~obj.fastZEnable;
            recordTrigTime = startTrig || (nextTrig && strcmpi(obj.triggerNextTrigMode,'advance'));
            if ~nextSlice && firstTrig
                %Measure trigger time twice, once with tic() and once with clock() --
                %discrepancy should be <200us according to tests. Using tic() for the
                %countdown timer ensures accuracy
                obj.triggerTimeLast = tic();
                obj.triggerClockTimeFirstVec = clock();
                
                %Record clocked trigger time
                %                 sampsSinceStart = state.init.hInitTimestampCtr.get('writeTotalSampPerChanGenerated');
                %                 roughTime = clock();
                %                 sampsSinceStart = double(sampsSinceStart);
                %                 obj.triggerClockTimeFirstVec = datevec(addtodate(datenum(roughTime),-round(1000*sampsSinceStart/10e6),'millisecond'));
            end

            % Start logging stream, with trigger header info
            if startTrig
                if obj.loggingEnable && obj.stackSlicesDone == 0
                    obj.hLSM.loggingFileName = obj.loggingFullFileName;
                    obj.hLSM.loggingHeaderString = obj.headerString;
                    fprintf('Size headerString: %s\n',mat2str(size(obj.hLSM.loggingHeaderString)));
                    startLogging(obj.hLSM,obj.loggingFrameDelay);
                end
                
                % Stop start trigger callbacks until ready for next acq
                if obj.triggerNextTrigUsed
                    switchToNext =  ~isequal(obj.triggerNextTrigSrc,obj.triggerStartTrigSrc) || ~strcmpi(obj.triggerNextTrigEdge,obj.triggerStartTrigEdge);
                end
                
                if ~obj.triggerNextTrigUsed || switchToNext
                    stop(obj.hTriggerCallbackCtr);
                end
                
                %Initialize logging frame count/time data, referenced to start trigger
                if obj.loggingEnable
                    obj.loggingFrameTimeLast = 0; %mark first frame as time 0
                    obj.loggingFrameCount = 1;
                    obj.loggingFrameBreaks = 1;
                end
                
                %Handle start-to-next trigger transition
                if obj.triggerNextTrigUsed && switchToNext
                    obj.zprvArmTrigCallback(true); %Arm next trigger
                    start(obj.hTriggerCallbackCtr);
                    obj.frameCounter = 0;
                    start(obj.xTrigCallback);
                end
            end
            if obj.triggerExtStartTrigUsed && obj.lowVal == 0
                obj.shuttersTransition(true);
            end
            obj.hLSM.start0(false);
            obj.hLSM.frameClock.stop()
            obj.hLSM.frameClock.start()
            
            if recordTrigTime
                %Read frame clock counter -- there should typically only be one
                %value, but there may be multiple if 1) ext triggers were
                %received (and ignored) during an ongoing acquisition, 2) one
                %or more triggers arrived after the trigger that caused this
                %function to execute, before the code below. If not next
                %triggering or a stack, we assume case #1 is true; if stack or
                %next-triggering acq is  used, we assume case #2. In either
                %case, we warn that our trigger/frame times for this file may
                %be wrong.
                maxExtraTriggers = 99; %Read up to 100 triggers & delays (i.e. in event of multiple triggers).
                  
                frameClockDelays = readCounterData(obj.hFrameClockDelayCtr,maxExtraTriggers + 1,1.0/obj.scanFrameRate); %Delay between this trigger and start of next frame.
                tic;
                while isempty(frameClockDelays) && toc < 4
                    toc
                    pause(0.5);
                    frameClockDelays = readCounterData(obj.hFrameClockDelayCtr,maxExtraTriggers + 1,1.0/obj.scanFrameRate); % try again ...
                end
                if isempty(frameClockDelays)
                    disp('Warning: Frameclockdelay seems to be broken at this point, PR2014. Check later.');
%                     fprintf(2,'ERROR: Failed to capture first frame clock time! Aborting acquisition.\n\tPossible causes: 1) Frame or line clock signal not correctly connected 2) External triggering configured but not correctly wired to LSM scanner.\n');
                    abort(obj);
                    return;
                elseif ~isscalar(frameClockDelays)
                    if (obj.stackNumSlices > 1 && ~obj.fastZEnable) %stack acq
                        frameClockDelay = frameClockDelays(1); %extra triggers are most likely result of a trigger or more slipping in after trigger that initiated this triggerFcn. This should be very unlikely in practical experiments (should not next trigger rapidly in succession).
                    elseif nextTrig
                        frameClockDelay = frameClockDelays(1); %extra triggers are most likely result of a trigger or more slipping in after trigger that initiated this triggerFcn. This should be very unlikely in practical experiments (should not next trigger rapidly in succession).
                        fprintf(2,'WARNING: A highly unexpected occurrence of multiple next trigger events was detected on processing the first of these.\n');
                    else %extra triggers were most likely ignored start triggers during previous loop Repeat's acquisition
                        frameClockDelay = frameClockDelays(end);
                    end
                else %isscalar
                    frameClockDelay = frameClockDelays;
                end
                
                
                %Update triggerTime & triggerFrameStartTime values, to be included in the header
                if ~nextSlice
                    if firstTrig
                        obj.triggerTimes = -frameClockDelay;
                        obj.triggerFrameStartTimes = 0;
                    else
                        try
                            triggerPeriod = readCounterData(obj.hTriggerPeriodCtr,inf,.01); %Delay(s) between this trigger and the previous trigger
                        catch ME %#ok<NASGU>
                            %TODO: Check specifically that error was a timeout..if not, should issue warning message
                            triggerPeriod = nan;
                        end
                        
                        if obj.stackNumSlices > 1 && ~obj.fastZEnable
                            if length(triggerPeriod) ~= obj.stackNumSlices
                                fprintf(2,'WARNING: Measured %d trigger periods since last trigger, but expected to measure %d, equal to number of slices. Possible error in recorded trigger/frame times may result. \n',length(triggerPeriod),obj.stackNumSlices);
                            end
                            
                            triggerPeriod = sum(triggerPeriod); %Assumes most recent trigger is the one associated with this callback (unlike frame clock ctr, we read triggerPeriods every stack not every slice)
                        else
                            if ~isscalar(triggerPeriod) || ~isscalar(frameClockDelays)
                                assert(length(triggerPeriod) == length(frameClockDelays),'Trigger occurred between readout of trigger period and frame clock delay. This case is not yet handled!');
                                fprintf(2,'WARNING: Multiple trigger periods (%d) measured since last trigger, when only one expected. Possible error in recorded trigger/frame times may result.\n',length(triggerPeriod));
                                
                                if nextTrig
                                    triggerPeriod = triggerPeriod(1); %Assumes first trigger is the one associated with this callback
                                else
                                    triggerPeriod = sum(triggerPeriod); %Assumes most recent trigger is the one associated with this callback
                                end
                            end
                        end
                        
                        %Subsequent triggers in LOOP mode
                        obj.triggerTimes(end+1) = obj.triggerTimes(end) + triggerPeriod;
                        obj.triggerFrameStartTimes(end+1) = obj.triggerTimes(end) + frameClockDelay;
                    end
                end
            end
            
            %Stop external trigger timer, if needed
            zprvClearExtTrigTimer(obj);
            
            if startTrig
                obj.notify('startTriggerReceived');
            end  
            
            %Start scanner, if needed!
            if startTrig && (~obj.triggerExtStartTrigUsed || 1) % PR2014 ~obj.triggerExtStartTrigPreScan)
                if obj.stackSlicesDone == 0
                    obj.startUnnested(obj.loggingEnable);
%                     obj.hFramePeriodCtr.stop();
%                     start(obj.hLSM,obj.loggingEnable);
                else
%                     obj.startUnnested(obj.loggingEnable);
                    resume(obj.hLSM); % XXXXXXX
                end
            end
            
            %Store last trigger time -- value is counted relative to start trigger edges,not frame clock edges
            if ~nextSlice && ~firstTrig
                %obj.triggerTimeLast = datevec(addtodate(datenum(obj.triggerTimeLast),round(1000*triggerPeriod),'millisecond'));
                obj.triggerTimeLast = tic();
            end
            
            if startTrig
                obj.notify('startTriggerProcessed');
            end
            
            %Handle next-triggering if applicable
            if nextTrig
                if zprvIterateLoop(obj,true) %signals whether to continue
                    
                    switch obj.triggerNextTrigMode
                        case 'arm'
                            %TODO: Consider whether to implement this 'arm' behavior of stop & restart within zprvIterateLoop() -- via some argument flag
                            %TODO: Should we, in some cases at least, wait for repeat period here??
                            
                            zprvEndAcquisition(obj);
                            drawnow;
                            obj.zprvArmTrigCallback(); %Ensure start trigger (not next trigger) is armed
                            if strcmpi(obj.acqState,'loop')
                                zprvStartAcquisition(obj,'loop');
                            end
                            
                            return;
                            
                        case 'advance'
                            %TODO: Handle possibility of a 'gap' -- i.e. to retrigger the next acquisition
                            
                            %Advance log file counter and start new logging file stream
                            if obj.loggingEnable
                                
                                %Verify no dropped frames have occurred to
                                %this point
                                if obj.verifyOptions.nextTrigAbortOnDroppedFrames
                                    %if obj.hLSM.droppedFramesTotal || obj.hLSM.droppedLogFramesTotal
                                    if obj.hLSM.droppedFramesLast %droppedLogFramesLast is not yet working, so don't check here
                                        abort(obj);
                                        warndlg(sprintf('Frames were dropped during acquisition (after frame #%d). Aborting Loop',obj.loggingFrameCount),'Dropped Frames!','modal');
                                        return;
                                    end
                                end
                                
                                %Update logging frame count and identify count value of first frame which has arrived since next trigger
                                %TODO: Consider reading average frame clock time instead and identifying closest integer multiple of average to determine frame count value (enforce some percentage match).
                                %      This would avoid having to read and sum /all/ values since last next trigger.
                                %      Alternatively, consider calculating roughly the number of frames expected since last frame trigger and using the
                                %      DAQmx_Val_MostRecentSample value for ReadRelativeTo property, adjusting ReadOffset to select a sample range very likely to contain the frame trigger
                                frameClockTimes = cumsum(readCounterData(obj.hFramePeriodCtr,[],[],obj.triggerMaxLoopIntervalFrames)) + obj.loggingFrameTimeLast; %all frame times since last next trigger(!)
                                obj.loggingFrameTimeLast = frameClockTimes(end);
                                newFrameClocks = length(frameClockTimes);
                                obj.loggingFrameCount = obj.loggingFrameCount + newFrameClocks;
                                
                                foundFrameBreak = false;
                                for i=newFrameClocks:-1:1
                                    if abs(obj.triggerFrameStartTimes(end) - frameClockTimes(i)) < max(1e-6,10 * obj.triggerTimestampResolution) %Does frame clock tick coincide with trigger edge?
                                        nextTrigNextFrame = obj.loggingFrameCount - (newFrameClocks - i); %Record frame count value which comes after next trigger
                                        foundFrameBreak = true;
                                        break;
                                    end
                                end
                                
                                if ~foundFrameBreak
                                    fprintf(2,'Failed to identify time of first frame-start following next trigger\n');
                                    fprintf(2,'triggerFrameStartTime: %f10\n',obj.triggerFrameStartTimes(end));
                                    fprintf(2,'frameClockTimes: %s\n',mat2str(flipud(frameClockTimes(end-50:end))));
                                    fprintf(2,'Length frameClockTimes: %d\n',length(frameClockTimes));
                                    return;
                                end
                                
                                
                                % Identify frame break to use for next trigger; implement logging file number update if appropriate
                                if obj.fastZEnable && obj.stackNumSlices > 1
                                    framesPerVolume = obj.acqNumFramesPerTrigger / obj.fastZNumVolumes;
                                    
                                    volumeModVal = mod(nextTrigNextFrame,framesPerVolume);
                                    
                                    if volumeModVal == 0 %
                                        nextTrigNextFrame = nextTrigNextFrame + 1;
                                    elseif volumeModVal > 1
                                        nextTrigNextFrame = nextTrigNextFrame + (framesPerVolume - volumeModVal + 1);
                                    end
                                    fprintf('nextTrigNextFrame: %d\n',nextTrigNextFrame);
                                    
                                    obj.fastZNextTrigSignal = obj.fastZNextTrigSignal + 1; %Signal to frameAcquiredFcn that loggingFileCounter should be incremented, at the appropriate time
                                    newFileName = zlclConstructLoggingFullFileName(obj.loggingFilePath,obj.loggingFileStem,obj.loggingFileCounter + obj.fastZNextTrigSignal);
                                    
                                else
                                    obj.zprvSetInternal('loggingFileCounter', obj.loggingFileCounter + 1);
                                    newFileName = obj.loggingFullFileName;
                                end
                                
                                %Add identified frame break to stored list
                                obj.loggingFrameBreaks(end + 1) = nextTrigNextFrame; %Add count value of trigger-coincident frame clock tick to list
                                
                                % Update triggerFrameNumber for file header and signal to logging thread to actually do the file advance (at appropriate frame count value)
                                obj.triggerFrameNumber = nextTrigNextFrame;
                                rolloverLogFile(obj.hLSM,nextTrigNextFrame,'loggingFileName',newFileName,'loggingHeaderString',obj.headerString);
                                
                            end
                    end
                end
            end
        end
    end
    
    %% HIDDEN METHODS (Beam/Shutter Toggling)
    methods (Hidden)
        function beamsStandby(obj)
            %Turns off beam channel(s) and prepares them for next acquisition
            if obj.beamNumBeams > 0
                obj.beamsOff();
                obj.zprvBeamsWriteFlybackData();
            end
        end
        
        function beamsOn(obj)
            if obj.beamNumBeams > 0
                obj.hBeams.control('DAQmx_Val_Task_Unreserve'); %should flush data
                obj.hBeamsPark.writeAnalogData(obj.beamOnPowerVoltages);
            end
        end
        
        function beamsOff(obj)
            if obj.beamNumBeams > 0
                %obj.hBeams.stop();
                obj.hBeams.control('DAQmx_Val_Task_Unreserve'); %should flush data
                obj.hBeamsPark.writeAnalogData(obj.beamOffPowerVoltages);
            end
        end
        
        function galvosStandby(obj)
            
            %TODO: Account for galvo offset values
            
            if obj.galvoEnable %Move galvos to park position specified in MDF
                obj.hGalvos.control('DAQmx_Val_Task_Unreserve');
                parkVals = obj.mdfData.galvoAngle2VoltageFactor .* obj.mdfData.galvoParkAngles(:)' ./ obj.galvoAngle2LSMAngleFactor;
                
                %Ensure park val does not exceed channel's max absolute value
                parkMaxVal = obj.hGalvosPark.channels(1).get('max');
                if any(abs(parkVals) > parkMaxVal)
                    parkSigns = sign(parkVals);
                    parkVals = parkSigns .* min(abs(parkVals),parkMaxVal);
                    fprintf(2,'WARNING: Galvo park angle exceeds maximum voltage of AO channel (%g). Galvo parked at maximum angle allowed by galvo AO channel.\n',parkMaxVal);
                end
                obj.hGalvosPark.writeAnalogData(parkVals);
            elseif obj.galvosAvailable %Galvos availble, but not enabled - move galvos to central angle
                obj.hGalvos.control('DAQmx_Val_Task_Unreserve');
                obj.hGalvosPark.writeAnalogData(zeros(1,numel(obj.mdfData.galvoChanIDs))); %TODO: Implement shift
            end
            
            obj.zprpUpdateGalvoProps();
            
        end
        
        
        function shuttersTransition(obj,openTF,applyShutterDelay)
            for i=1:length(obj.hShutters)
                if openTF
                    writeDigitalData(obj.hShutters(i),obj.mdfData.shutterOpenLevel(i));
                else
                    writeDigitalData(obj.hShutters(i),~obj.mdfData.shutterOpenLevel(i));
                end
            end
            if nargin < 3
                applyShutterDelay = false;
            end
%             applyShutterDelay = true;
            if openTF && applyShutterDelay && isfield(obj.mdfData,'shutterOpenTime') && obj.mdfData.shutterOpenTime > 0
                most.idioms.pauseTight(obj.mdfData.shutterOpenTime);
            end
        end
    end
    
    %FastZ methods
    methods (Hidden)
        
        %         function fastZPosnSet(obj,targetPosn)
        %             % Using AO control of FastZ controller, go to specified targetPosn
        %             %   targetPosn: Scalar value, specifying position in microns for FastZ controller (in relative coordinates, if FastZController is a linear stage controller object)
        %
        %             %assert(obj.fastZEnable > 0,'FastZ mode is not enabled. Cannot goto position.');
        %             %assert(obj.fastZUseAOControl,'FastZ controller is not configured for AO control. Cannot goto position.');
        %
        %             assert(~isempty(obj.hFastZ),'No FastZ controller is available.');
        %
        %             if obj.fastZUseAOControl
        %                 obj.hFastZAO.control('DAQmx_Val_Task_Unreserve'); %Flush data
        %
        %                 %Write new AO voltage, ensuring it's within AO range
        %                 obj.hFastZAOPark.writeAnalogData(obj.zprvFastZPosn2Voltage(targetPosn));
        %             elseif isa(obj.hFastZ,'dabs.interfaces.LinearStageControllerBasic')
        %                 assert(~obj.fastZForbidDigitalMove,'Unable to set position for FastZ controller');
        %                 obj.hFastZ.moveCompleteRelative(targetPosn);
        %             end
        %
        %         end
        %
        %
        %         function posn = fastZPosnGet(obj)
        %             %Read absolute position of stage connected to FastZ controller
        %             %   posn: Scalar value, in microns, indicating absolute position of stage connected to FastZ controller
        %             %
        %             % NOTE: In case where fastZController is identified as the 'secondary Z' motor controller, then
        %             %       this position is identical to the secondary controller Z position indicated by the motorPosition property
        %
        %             assert(~isempty(obj.hFastZ),'No FastZ controller is available.');
        %
        %             if isa(obj.hFastZ,'dabs.interfaces.LinearStageControllerBasic')
        %                 posn = obj.hFastZ.positionAbsolute(end);
        %             elseif isa(obj.hFastZ,'dabs.pi.private.MotionController')
        %                 posn = obj.hFastZ.position;
        %             end
        %         end
        
        
        %         function fastZStandby(obj,targetPosn)
        %
        %             if obj.fastZUseAOControlDev
        %
        %                 if nargin < 2
        %                     targetPosn = obj.hFastZ.position; %Use current position
        %                 end
        %
        %                 %Update position command
        %                 %TODO: Handle PI device generality -- current implementation is for the E816 controller
        %                 obj.hFastZ.moveComplete(targetPosn); %This should not actually move the controller
        %
        %             end
        %
        %         end
    end
    
    
    %% HIDDEN METHODS (Channel Display)
    
    methods (Static,Hidden)
        
        function mergeData = zprvAddChanDataToMergeData(mergeData,chanData,clr,lut)
            range = lut(2)-lut(1);
            chanDataRescaled = uint8(double(chanData-lut(1))/range * 255);
            switch clr
                case 'red'
                    mergeData(:,:,1) = mergeData(:,:,1) + chanDataRescaled;
                case 'green'
                    mergeData(:,:,2) = mergeData(:,:,2) + chanDataRescaled;
                case 'blue'
                    mergeData(:,:,3) = mergeData(:,:,3) + chanDataRescaled;
                case 'gray'
                    mergeData(:,:,:) = mergeData(:,:,:) + repmat(chanDataRescaled,[1 1 3]);
                case 'none'
                    % no-op
                otherwise
                    assert(false);
            end
        end
    end
    
    methods (Hidden)
        % tileIdx (optional): array of tile indices to update.
        function zprvUpdateMergeWindowIfNecessary(obj,tileIdx)
            if obj.channelsMergeEnable && strcmp(obj.initState,'none') && ...
                    (~obj.channelsMergeFocusOnly || ~any(strcmp(obj.acqState,{'grab' 'loop'})))
                
                if nargin < 2
                    tileIdx = 1:length(obj.displayFrameBatchSelection);
                end
                
                chansToDisp = obj.channelsDisplay;
                mergeColors = obj.channelsMergeColor;
                chanLUTs = obj.channelsLUT;
                sclpf = obj.scanLinesPerFrame;
                sppl = obj.scanPixelsPerLine;
                
                for tIdx = tileIdx(:)'
                    if numel(obj.channelsHMergeIm) < tIdx || ~ishandle(obj.channelsHMergeIm(tIdx))
                        break;
                    end
                    
                    mergeData = zeros(sclpf,sppl,3,'uint8');
                    for chanIdx = chansToDisp(:)'
                        % for now, get chanData from channelsHImage
                        chanData = get(obj.channelsHImage{chanIdx}(tIdx),'CData');
                        mergeData = scanimage.SI4.zprvAddChanDataToMergeData(mergeData,chanData,mergeColors{chanIdx},chanLUTs(chanIdx,:));
                    end
                    
                    set(obj.channelsHMergeIm(tIdx),'CData',mergeData);
                end
            end
        end
        
        % Return the data matrix for the currently-displayed data for the
        % specified channel. (The currently-displayed data is affected by
        % zooming, etc.)
        function data = zprvChannelDataCurrentDisplay(obj,chanIdx)
            hIm = obj.channelsHImage{chanIdx};
            ax = obj.channelsHAxes{chanIdx};
            
            assert(isscalar(ax),'At this time, cannot extract data (for image statistics, etc) from multi-image display figures');
            
            xbounds = get(hIm,'XData');
            ybounds = get(hIm,'YData');
            ximagebounds = round(get(ax,'XLim'));
            yimagebounds = round(get(ax,'YLim'));
            xidxs = intersect(xbounds(1):xbounds(2),ximagebounds(1):ximagebounds(2));
            yidxs = intersect(ybounds(1):ybounds(2),yimagebounds(1):yimagebounds(2));
            
            data = get(hIm,'CData');
            data = data(yidxs,xidxs);
        end
        
        
        
        function zprvResetDisplayFigs(obj,chansToReset,resetMergeTF,channelsLUTVal)
            
            numTiles = length(obj.displayFrameBatchSelection); %Number of tiles to be displayed
            if numTiles > 1
                %Determine optimal tiling
                if numTiles == 2
                    tiling = [2 1];
                elseif numTiles <= 4
                    tiling = [2 2];
                elseif numTiles < 6
                    tiling = [3 2];
                else
                    tilingFactor = 3;
                    
                    while tilingFactor^2 < numTiles
                        tilingFactor = tilingFactor + 1;
                    end
                    
                    tiling = [tilingFactor tilingFactor];
                end
                tileSpans = 1./tiling;
            else
                % these will be unused
                tiling = [];
                tileSpans = [];
            end
            
            startImageData = zeros(obj.scanLinesPerFrame,obj.scanPixelsPerLine,obj.channelsDataType);
            for i=1:length(chansToReset)
                chanNum = chansToReset(i);
                [obj.channelsHAxes{chanNum} obj.channelsHImage{chanNum}] = ...
                    zprvPrepareDisplayAxesImages(obj,obj.channelsHFig(chanNum),numTiles,tiling,tileSpans,startImageData);
            end
            
            if resetMergeTF
                [obj.channelsHMergeAx, obj.channelsHMergeIm] = ...
                    zprvPrepareDisplayAxesImages(obj,obj.channelsHMergeFig,numTiles,tiling,tileSpans,startImageData);
                initialMergeData = zeros(obj.scanLinesPerFrame,obj.scanPixelsPerLine,3,'uint8');
                set(obj.channelsHMergeIm,'CData',initialMergeData);
            end
            
            %Update CLim values for each subplot
            if nargin < 4
                obj.channelsLUT = obj.channelsLUT;
            else
                obj.channelsLUT = channelsLUTVal;
            end
        end
        
        
        
        function [hAx hIm] = zprvPrepareDisplayAxesImages(obj,hFig,numTiles,tiling,tileSpans,startImageData)
            delete(findobj(hFig,'Type','Axes'));
            delete(findall(hFig,'Type','Line'));
            figure(hFig);
            
            hAx = zeros(numTiles,1);
            hIm = zeros(numTiles,1);
            if numTiles > 1
                %Draw annotation lines
                for i=1:(tiling(1)-1) %horizontal lines, separating rows
                    annotation('line',[0 1],[i*tileSpans(1) i*tileSpans(1)],'Color',[0.5 0.5 0.5]);
                end
                for i=1:(tiling(2)-1) %vertical lines, separating columns
                    annotation('line',[i*tileSpans(2) i*tileSpans(2)],[0 1],'Color',[0.5 0.5 0.5]);
                end
                
                %Create subplots (do in separate loop to avoid auto-deletion due to tiny overlaps)
                for tileIdx=1:numTiles
                    hAx(tileIdx) = subplot(tiling(1),tiling(2),tileIdx);
                end
                
                %Configure subplots
                for tileIdx=1:numTiles
                    rowIdx = floor((tileIdx-1)/tiling(2)) + 1; %Count from top
                    colIdx = mod(tileIdx-1,tiling(2)) + 1;  %Count from left
                    set(hAx(tileIdx),'Position',[(colIdx-1)*tileSpans(2) (tiling(1)-rowIdx)*tileSpans(1) tileSpans(2) tileSpans(1)] + [1e-9 1e-9 -2e-9 -2e-9],...
                        'Visible','off','YDir','reverse','XTick',[],'YTick',[],...
                        'YTickLabelMode','manual','XTickLabelMode','manual',...
                        'XTickLabel',[],'YTickLabel',[]);
                    
                    hIm(tileIdx) = image('Parent',hAx(tileIdx),'CData',startImageData,'CDataMapping','Scaled');
                    obj.zprvUpdateChannelDisplayRatioAndLims(hAx(tileIdx)); %Update aspect ratio and limits
                end
            else
                hAx = axes('Parent',hFig,'Position',[0 0 1 1], ...
                    'YDir','reverse', 'DataAspectRatio',[obj.scanPixelsPerLine obj.scanLinesPerFrame 1],...
                    'XTick',[],'YTick',[],...
                    'YTickLabelMode','manual','XTickLabelMode','manual','XTickLabel',[],'YTickLabel',[]);
                hIm = image('Parent',hAx,'CData',startImageData,'CDataMapping','Scaled');
                
                obj.zprvUpdateChannelDisplayRatioAndLims(hAx); %Update aspect ratio and limits
            end
        end
        
        function zprvUpdateChannelDisplayRatioAndLims(obj,hAx)
            if nargin < 2 || isempty(hAx)
                hAx = [obj.channelsHAxes(:);{obj.channelsHMergeAx}];
            elseif ~iscell(hAx)
                hAx = {hAx};
            end
            
            if obj.mroiEnabled
                yRatio = 1;
                
                tileCols = obj.mroiComputedParams.dispTiling(2);
                
                imCols = tileCols * obj.mroiPixelsPerLine;
                imRows = sum([obj.mroiComputedParams.dispTilingLinesPerRow]);
                
            else
                imCols = obj.scanPixelsPerLine;
                imRows = obj.scanLinesPerFrame;
                if obj.scanAngleMultiplierSlow == 0 %Line scan
                    yRatio = 1;
                else
                    yRatio = obj.scanAngleMultiplierSlow;
                end
            end
            
            cellfun(@(x)set(x,'PlotBoxAspectRatio',[1 yRatio 1],...
                'DataAspectRatioMode','auto',...
                'XLim',[-0.5 .5] + [1 imCols],...
                'YLim',[-0.5 .5] + [1 imRows]),hAx);
            
            
            drawnow(); %Ensure all changes take effect before subsequent calls
        end
        
    end
    
    %% HIDDEN METHODS (Usr/Cfg/FastCfg API)
    
    methods (Access=private)
        
        %         function cfgPropSet = cfgLoadConfigFileSafe(obj,fname)
        %             tfSuccessfulLoad = true;
        %             try
        %                 cfgPropSet = obj.mdlLoadPropSetToStruct(fname);
        %             catch %#ok<CTCH>
        %                 tfSuccessfulLoad = false;
        %             end
        %             if tfSuccessfulLoad
        %                 obj.setClassDataVar('lastConfigFilePath',fileparts(fname));
        %                 obj.cfgFilename = fname;
        %             else
        %                 warning('SI4:errorLoadingCfgFile',...
        %                     'Error loading config file ''%s''.',fname);
        %                 cfgPropSet = struct();
        %                 obj.cfgFilename = '';
        %             end
        %         end
        
        
        function fname = zprvUserCfgFileHelper(obj,fname,fileFcn,verifyFcn) %#ok<MANU>
            % Get/preprocess/verify a config filename. Set 'lastConfigFilePath'
            % classdatavar, obj.cfgFilename.
            
            if isempty(fname)
                [f,p] = fileFcn();
                if isnumeric(f)
                    fname = [];
                    return;
                end
                fname = fullfile(p,f);
            else
                [p,f,e] = fileparts(fname);
                if isempty(p)
                    p = cd;
                end
                if isempty(e)
                    e = '.cfg';
                end
                f = [f e];
                fname = fullfile(p,f);
            end
            verifyFcn(p,f,fname);
        end
    end 
    
    %% HIDDEN METHODS (Beam Operations)
    methods (Hidden)
        
        function zprvBeamsUpdateFlybackBuffer(obj)
%             disp('Update beam buffer for pockels cell, PR2014.');
            %Updates beamFlybackBlankData and beamFlybackBlankData mask buffers maintained by this class
            %Except when stop/restarting, the beam AO buffer is also updated (i.e. written to)
            %
            %
            % Flyback buffer depends on:
            %   scanFillFraction, scanLinePeriod, scanMode
            %   beamNumBeams, beamFlybackBlanking, beamFillFracAdjust
            %
            %TODO: If FastZ update is restored in this function, consider providing input argument indicating whether to defer FastZ
            %       update on stopAndRestart, e.g. for prop changes affecting only the FastZBuffer
            
            if obj.beamNumBeams == 0 || ~obj.beamFlybackBlanking
                obj.beamFlybackBlankData = [];
                
                if obj.beamNumBeams == 0
                    return;
                end
            end

            if obj.beamFlybackBlanking

                %Determine beam amplitudes during ON and OFF  times
                switch obj.beamPowerUnits
                    case 'percent'
                        beamOffVoltages = obj.beamOffPowerVoltages(:)';
                        beamOnVoltages = obj.beamOnPowerVoltages(:)';
                    otherwise
                        assert('Only percent-mode power values presently supported');
                end
                %Determine on-time for each line (PR2014)
                if strcmp(obj.scanMode,'bidirectional')
%                     obj.iLineClock.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.iLineClockTrig),'DAQmx_Val_Falling');
%                     beamTask.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.mdfData.trigSelfTrigDestinationTerminal));
%                     obj.hBeams.cfgDigEdgeStartTrig( sprintf('PFI%d',obj.mdfData.trigSelfTrigDestinationTerminal),'DAQmx_Val_Falling'); % XXXXXX
                    lineNumSamples = ceil(obj.scanphases{obj.hLSM.fieldSize}(3)*1e-6*obj.mdfData.beamCmdOutputRate + obj.mdfData.beamCmdOutputRate * 4096/80e6); % PR2014-08-22 : the last one is for going back to zero
                    plusLineNumSamples = round(obj.scanphases{obj.hLSM.fieldSize}(2)*1e-6*obj.mdfData.beamCmdOutputRate); % PR2014-10-18
                    startTimeAdjust = round(obj.beamFillFracAdjust*1e-6*obj.mdfData.beamCmdOutputRate);
                    plusLineNumSamples = startTimeAdjust;

                    onTimeAdjust2 = round(obj.onTimeAdjust*1e-6*obj.mdfData.beamCmdOutputRate);
                    timingAdjustPockels2 = -round(obj.timingAdjustPockels*1e-6*obj.mdfData.beamCmdOutputRate);
                    % obj.hLSM.pockelsSamples = lineNumSamples; % unused
                    onSamples = ceil(obj.mdfData.beamCmdOutputRate * 4096/80e6);
                    offSamples = lineNumSamples - 2*onSamples;
                    onDataMask = [false(max(0,obj.timingAdjustPockels),1);true(onSamples+obj.beamFillFracAdjust,1);false(offSamples-obj.timingAdjustPockels,1);true(onSamples-onTimeAdjust2,1); false(1,1)];
                    onDataMask(end:lineNumSamples+plusLineNumSamples) = false;
%                     onDataMask = onDataMask(1:lineNumSamples+plusLineNumSamples);
                    
%                     onDataMask = circshift(onDataMask,[5 0]);
%                     figure, plot(onDataMask)
%                     onDataMask = false(size(onDataMask));
%                     onDataMask(1:34) = true;
%                     onDataMask(36:72) = true;
%                         onDataMask(71:77) = true;
%                   length(onDataMask)
%                     onDataMask(end) = false;
% %                     length(onDataMask)
%                     length(onDataMask)*obj.mdfData.beamCmdOutputRate
%                     if 1; figure(13111); plot(onDataMask,'-ok'); end; 
                else
                    if length(obj.scanphases{obj.hLSM.fieldSize}) > 2 % workaround for Scanimage start
                        lineNumSamples = ceil(obj.scanphases{obj.hLSM.fieldSize}(3)*1e-6*obj.mdfData.beamCmdOutputRate + obj.mdfData.beamCmdOutputRate * 4096/80e6); % PR2014-08-22 : the last one is for going back to zero
                        plusLineNumSamples = round(obj.scanphases{obj.hLSM.fieldSize}(2)*1e-6*obj.mdfData.beamCmdOutputRate); % PR2014-10-18
                        startTimeAdjust = round(obj.beamFillFracAdjust*1e-6*obj.mdfData.beamCmdOutputRate);
                        onTimeAdjust2 = round(obj.onTimeAdjust*1e-6*obj.mdfData.beamCmdOutputRate);
                        timingAdjustPockels2 = -round(obj.timingAdjustPockels*1e-6*obj.mdfData.beamCmdOutputRate);
                        % obj.hLSM.pockelsSamples = lineNumSamples; % unused
                        onSamples = ceil(obj.mdfData.beamCmdOutputRate * 4096/80e6);
                        offSamples = lineNumSamples - 2*onSamples;
                        onDataMask = [false(plusLineNumSamples-startTimeAdjust,1);true(onSamples+startTimeAdjust-onTimeAdjust2,1);false(offSamples+onTimeAdjust2+timingAdjustPockels2,1);false(onSamples-onTimeAdjust2,1); false(1+onTimeAdjust2-timingAdjustPockels2,1)];
                        onDataMask = onDataMask(1:lineNumSamples+plusLineNumSamples);
                        onDataMask(end) = false;
                    else
                        lineNumSamples = ceil(obj.mdfData.beamCmdOutputRate * 4096/80e6);
                        obj.hLSM.pockelsSamples = lineNumSamples;
                        onDataMask  = [true(lineNumSamples,1); false(1,1)];
                    end
%                     if 1; figure(13111); plot(onDataMask,'-ok'); end; 
                
% lineNumSamples = ceil(obj.mdfData.beamCmdOutputRate * 4096/80e6);
%                     obj.hLSM.pockelsSamples = lineNumSamples;
%                     onDataMask  = [true(lineNumSamples,1); false(1,1)];
                end
               
                if onDataMask(end)
                    onDataMask(end) = false; %Always end with final sample OFF -- this is required for blanking during slow mirror flyback
                end
                offDataMask = ~onDataMask;
                
                %Prepare flyback blanking output data and output data reference
                outData = zeros(length(onDataMask), obj.beamNumBeams);
                outDataMask = nan(length(onDataMask),1);
                
                outDataMask(onDataMask) = 1;
                halfN = round(numel(outData)/2);
                outData_leftbias_multiplier = [linspace(obj.leftbias,-obj.leftbias,halfN), linspace(-obj.leftbias,obj.leftbias,numel(outData)-halfN)]; 
                outData(onDataMask,:) = beamOnVoltages;
                outData(offDataMask,:) = beamOffVoltages;
                outData = (outData-beamOffVoltages).*(1+outData_leftbias_multiplier'/100);
%                 A = circshift(outData,[1 0]);
%                 B = circshift(outData,[2 0]);
%                 C = circshift(outData,[-1 0]);
%                 D = circshift(outData,[-2 0]);
%                 outData = (outData + A + B + C + C)/5;
%                 figure(413); plot(outData);
                obj.beamFlybackBlankData = outData;
                obj.beamFlybackBlankDataMask = outDataMask;
                
            end
            
            
            %Update data in output buffer
            if obj.fastZEnable == 0
                if strcmpi(obj.acqState,'focus') || strcmpi(obj.acqState,'grab')
                    %TODO: Selectively restart only those beams used for Focus
                    obj.hBeams.stop();
                    obj.zprvBeamsWriteFlybackData();
                    obj.hBeams.start();
                else
                    obj.zprvBeamsWriteFlybackData();
                end
            end
            %TODO: Consider whether to update (pre-compute) FastZ buffer here and in what circumstances. For now, leaving out.
        end
        
        function zprvBeamsWriteFlybackData(obj)
            if obj.beamNumBeams > 0
                obj.hBeams.control('DAQmx_Val_Task_Unreserve'); %should flush data
                
                if obj.beamFlybackBlanking
                    outData = obj.beamFlybackBlankData;
                else
                    % Just write a single sample (twice) -- the same value is used throughout
                    % each entire line period, so no long buffer is needed
                    outData = repmat(obj.beamOnPowerVoltages(:)',2,1);
                end
                
                %Ensure even number of samples
                if mod(size(outData,1),2) == 1
                    outData(end+1,:) = outData(end,:);
                end
                
                obj.hBeams.cfgSampClkTiming(obj.mdfData.beamCmdOutputRate,'DAQmx_Val_FiniteSamps',size(outData,1)); %NOTE: This might only be needed if the buffer size has changed
                obj.hBeams.cfgOutputBuffer(size(outData,1));
                
                
                obj.hBeams.reset('writeRelativeTo');
                obj.hBeams.reset('writeOffset');
                obj.hBeams.writeAnalogData(outData);
                % xxx is writeAnalogData smart enough to do the right thing here for multi-beam?
            end
        end
        
        function zprvBeamsWriteFastZData(obj)
            % Compute and write FastZ buffer to beam Task, containing beam flyback/power waveforms for entire volume period
            %
            % NOTES
            %   Function computes and writes FastZ buffer to Task frame-wise, avoiding creation of large memory buffer
            %
            %   TODO: Handle correctly the FastZ buffer case when flyback blanking is disabled
            
            if obj.beamNumBeams == 0
                return;
            end
            
            %Compute 'base' data for one period, using current power specification
            if obj.beamFlybackBlanking
                scanPeriodBase = repmat(obj.beamFlybackBlankDataMask,1,obj.beamNumBeams); %Data mask for one period
            else
                scanPeriodBase = ones(length(obj.beamFlybackBlankDataMask),obj.beamNumBeams);
            end
            periodLength = size(scanPeriodBase,1);
            
            %%Prepare beam Task for FastZ buffer
            switch obj.scanMode
                case 'unidirectional'
                    periodsPerFrame = obj.scanLinesPerFrame / 2; % PR2014-11-04
                case 'bidirectional'
                    periodsPerFrame = obj.scanLinesPerFrame / 2;
            end
            %samplesPerFrame = periodLength * periodsPerFrame;
            if isinf(obj.acqNumFramesPerTrigger)
                framesPerVolume = obj.fastZNumFramesPerVolume;
            else
                framesPerVolume = obj.acqNumFramesPerTrigger / obj.fastZNumVolumes;
            end
            obj.hBeams.control('DAQmx_Val_Task_Unreserve');
            obj.hBeams.cfgSampClkTiming(obj.mdfData.beamCmdOutputRate,'DAQmx_Val_FiniteSamps',periodLength);
            
            volumeBufferLength = periodLength * periodsPerFrame * framesPerVolume;
            if obj.fastZAllowLiveBeamAdjust
                obj.hBeams.cfgOutputBuffer((obj.fastZBeamNumBufferedVolumes + 1) * volumeBufferLength);
            else
                obj.hBeams.cfgOutputBuffer(volumeBufferLength);
            end
            
            %Determine starting position and step-size
            stepsPerVolume = framesPerVolume - obj.fastZNumDiscardFrames;
            stepSize = obj.stackZStepSize;
            stackSize = (stepsPerVolume - 1) * stepSize;
            
            currPosn  = -stepSize/2; %Shift to align start power with center of first or middle stack slice
            
            if obj.stackStartCentered %Shift to align starting power with middle stack slice
                currPosn = currPosn - stackSize/2;
            end
            
            %Compute FastZ buffer, frame-at-a-time, and write to AO Task
            if obj.fastZAllowLiveBeamAdjust
                obj.fastZBeamDataBuf = zeros(volumeBufferLength,1);
                startIdx = 1;
                numBufVolumes = obj.fastZBeamNumBufferedVolumes;
                
            else
                numBufVolumes = 1;
            end
            
            framePosns = repmat(linspace(currPosn,currPosn+stepSize,periodLength*periodsPerFrame)',1,obj.beamNumBeams);
            lengthConstants = repmat(obj.acqBeamLengthConstants,periodLength*periodsPerFrame,1);
            
            scanPeriodBase(isnan(scanPeriodBase(:,1)),:) = 0;
            scanPeriods = repmat(scanPeriodBase,periodsPerFrame,1);
            
            for i = 1:numBufVolumes
                for j = 1:stepsPerVolume
                    beamPowerFactors = exp(framePosns./lengthConstants);
                    framePosns = framePosns + stepSize;
                    
                    dataToAppend = scanPeriods;
                    for k=obj.beamNumBeams:-1:1
                        dataToAppend(:,k) = dataToAppend(:,k) .* obj.zprpBeamsPowerFractionToVoltage(k,obj.beamPowers .* beamPowerFactors / 100.0);
                    end
                    obj.hBeams.writeAnalogData(dataToAppend);
                    
                    if obj.fastZAllowLiveBeamAdjust && i==1
                        endIdx = startIdx + length(dataToAppend) - 1;
                        obj.fastZBeamDataBuf(startIdx:endIdx) = dataToAppend;
                        startIdx = endIdx + 1;
                    end
                end
            end
            
            for j = 1:obj.fastZNumDiscardFrames
                dataToAppend = scanPeriods;
                for k=obj.beamNumBeams:-1:1
                    dataToAppend(:,k) = obj.beamOffPowerVoltages(k);
                end
                obj.hBeams.writeAnalogData(dataToAppend);
            end
            
            %Initialize FastZ beam live adjustability, if needed
            if obj.fastZAllowLiveBeamAdjust
                obj.fastZBeamPowersCache = obj.beamPowers;
                obj.fastZBeamWriteOffset = size(obj.fastZBeamDataBuf * obj.fastZBeamNumBufferedVolumes,1);
            else
                obj.fastZBeamPowersCache = [];
                obj.fastZBeamWriteOffset = [];
            end
            
        end
        
        function zprvBeamsRefreshFastZData(obj,numFrames)
            %Refresh FastZ beam data according to current power levels, as required when fastZAllowLiveBeamAdjust=true
            
            obj.hBeams.set('writeOffset',obj.fastZBeamWriteOffset);
            
            bufLen = size(obj.fastZBeamDataBuf,1); %Length of entire volume
            if isinf(numFrames)
                indices = 1:bufLen;
            else
                samplesPerFrame = bufLen / obj.fastZNumFramesPerVolume; %Should evenly divide
                
                frameIdx = rem(obj.fastZBeamWriteOffset,bufLen)/ samplesPerFrame; %zero-based frame index
                
                indices = (1:(numFrames * samplesPerFrame)) + frameIdx * samplesPerFrame;
            end
            
            if obj.beamNumBeams == 1
                obj.hBeams.writeAnalogData(obj.fastZBeamDataBuf(indices,:) * (obj.beamPowers/obj.fastZBeamPowersCache));
            else
                obj.hBeams.writeAnalogData(obj.fastZBeamDataBuf(indices,:) .* repmat(obj.beamPowers./obj.fastZBeamPowersCache,length(indices),1)); %
            end
            %fprintf('Wrote %d samples at offset %d in %g ms\n',length(indices),obj.fastZBeamWriteOffset,toc()*1000);
            obj.fastZBeamWriteOffset = obj.fastZBeamWriteOffset + length(indices);
            
        end
        
        function [tfSuccess beamCalVoltage beamVoltage] = zprvBeamsGetCalibrationData(obj,beamIdx)
            % tfSuccess: true if calibration successful.
            % beamCalVoltage: (beamCalibrationNumVoltageSteps x
            % beamCalibrationNumPasses) vector of beam cal voltages
            % corresponding to beamVoltage
            % beamVoltage: (beamCalibrationNumVoltageSteps x 1) vector of beam
            % voltages
            
            validateattributes(beamIdx,{'numeric'},{'vector','integer','>=',1,'<=',obj.beamNumBeams});
            
            wb = waitbar(0,sprintf('Calibrating beam %d...', beamIdx),...
                'Name','Calibrating...','CreateCancelBtn','hSI.beamCancelCalibration = true;');
            
            voltageRange = obj.beamVoltageRanges(beamIdx);
            
            %Create array of modulation voltages
            % Add zeros at the end b/c "VI111010A: Add delay between
            % calibration sweeps (allows for case where slow decay in
            % transmission is seen after reaching high voltages) -- Vijay
            % Iyer 11/10/10"
            %
            % Hold each voltage step for 2 samples. We'll record input signal on 2'nd of each pair, to avoid any settling time problems.
            %
            
            voltageSteps = linspace(0,voltageRange,obj.beamCalibrationNumVoltageSteps);
            beamVoltage = [zeros(1,2*numel(voltageSteps))  zeros(1,obj.beamCalibrationIntercalibrationZeros)]';
            for i=1:numel(voltageSteps)
                [beamVoltage(2*i-1) beamVoltage(2*i)] = deal(voltageSteps(i));
            end
            NbeamVoltage = numel(beamVoltage);
            
            %             assert(rem(NbeamVoltage,2)==0,...
            %                 'Input buffer length must be even, to avoid DAQmx error -200692 with some devices (e.g. AO series)');
            %             % Assert from note by Vijay Iyer, 11/24/10
            
            % TODO old code set other beams to output zero during calibration.
            % is this necessary?
            
            %Prepare hBeams and hBeamCals
            beamTask = obj.hBeams(beamIdx);
            assert(isscalar(beamTask));
            beamTask.control('DAQmx_Val_Task_Unreserve');
            beamTask.cfgSampClkTiming(obj.beamCalibrationOutputRate,'DAQmx_Val_FiniteSamps',NbeamVoltage);
            beamTask.cfgOutputBuffer(NbeamVoltage);
            obj.hBeams.set('startTrigRetriggerable',true,'digEdgeStartTrigDigFltrMinPulseWidth',0,'digEdgeStartTrigDigFltrEnable',0);
            beamTask.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.mdfData.trigSelfTrigDestinationTerminal));
            beamTask.set('pauseTrigType','DAQmx_Val_None');
%             beamTask.set('pauseTrigType','DAQmx_Val_DigLvl','digLvlPauseTrigWhen','DAQmx_Val_Low','digLvlPauseTrigSrc',sprintf('PFI%d',obj.mdfData.extFrameClockTerminal));
            beamTask.writeAnalogData(beamVoltage);
            
            beamCalTask = obj.hBeamCals{beamIdx};
            beamCalTask.control('DAQmx_Val_Task_Unreserve');
            beamCalTask.cfgSampClkTiming(obj.beamCalibrationOutputRate,'DAQmx_Val_FiniteSamps',NbeamVoltage);
            beamCalTask.set('startTrigRetriggerable',true);
             
            % calibration loop
            beamCalVoltage = zeros(NbeamVoltage,obj.beamCalibrationNumPasses);
            calibrationPassTime = NbeamVoltage / obj.beamCalibrationOutputRate;
            
            if obj.mdfData.shutterBeforeEOM
                obj.shuttersTransition(true,true);
            end
            
            tfSuccess = false;
            try % Why is this try/catch necessary?
                for c = 1:obj.beamCalibrationNumPasses
                    if obj.beamCancelCalibration
                        znstCancelCleanup();
                        return;
                    end
                    
                    beamTask.start();
                    beamCalTask.start();
                    
                    obj.hSelfTrig.writeDigitalData([0;1;0],0.2);
                    pause(calibrationPassTime*1.1); % AL: beamCalTask.isTaskDone() appears to return false here no matter how long you wait
                    beamCalVoltage(:,c) = beamCalTask.readAnalogData();
                    
                    beamTask.stop();
                    beamCalTask.stop();
                    
                    pause(obj.beamCalibrationIntercalibrationPauseTime);
                    waitbar(c/obj.beamCalibrationNumPasses,wb);
                end
            catch ME %#ok<NASGU>
                %Some error occurred during calibration, most likely while reading calibration data.
                %Leave to caller to generate warning/error message (since tfSuccess=false)
                znstCleanup();
                return;
                %rethrow(ME);
            end
            
            if obj.beamCancelCalibration
                znstCancelCleanup();
                return;
            end
            
            znstCleanup();
            tfSuccess = true;
            
            function znstCleanup()
                
                %Remove intercalibration zeros
                numZeros = obj.beamCalibrationIntercalibrationZeros;
                beamCalVoltage(end-numZeros+1:end,:) = [];
                beamVoltage(end-numZeros+1:end) = [];
                
                %Take second of every pair of beamVoltage/beamCalVoltage values (first sample was for settling)
                beamCalVoltage = beamCalVoltage(2:2:end,:);
                beamVoltage = beamVoltage(2:2:end);
                
                %Clean up Beam DAQ Tasks
                beamTask.stop();
                beamCalTask.stop();
                beamTask.control('DAQmx_Val_Task_Unreserve');
                beamCalTask.control('DAQmx_Val_Task_Unreserve');
                
                %Restore beam Task's calibration (perhaps via cache-and-restore, rather than hard-coded revert to initialized state)
                obj.hBeams.set('startTrigRetriggerable',true,'digEdgeStartTrigDigFltrMinPulseWidth',200e-9,'digEdgeStartTrigDigFltrEnable',1);
                obj.hBeams.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.mdfData.iLineClockReceive),'DAQmx_Val_Falling');
                if obj.betweenFrames
                    obj.hBeams.set('pauseTrigType','DAQmx_Val_DigLvl','digLvlPauseTrigWhen','DAQmx_Val_Low','digLvlPauseTrigSrc',sprintf('PFI%d',obj.mdfData.extFrameClockTerminal));
                else
                    obj.hBeams.set('pauseTrigType','DAQmx_Val_None'); %Disable pause-triggering - there is no slow-mirror flyback to be blanked out
                end
               if obj.mdfData.shutterBeforeEOM
                    obj.shuttersTransition(false);
                end
                delete(wb);
            end
            
            function znstCancelCleanup()
                znstCleanup();
                obj.beamCancelCalibration = false;
            end
        end
        
        
        function [lut beamCalMinVoltage beamCalMaxVoltage] = ...
                zprvBeamsProcessCalibrationData(obj,beamVoltage,beamCalVoltage,beamCalOffset)
            % lut: (beamCalibrationLUTSize x 1) numeric array, where lut(i)
            % gives beam voltage necessary to achieve
            % (i/beamCalibrationLUTSize) fraction of maximum achieved power
            % beamCalMin/MaxVoltage: min/max beam cal voltage (averaged over
            % calibration passes) achieved during calibration sweeps
              
            assert(isvector(beamVoltage) && size(beamCalVoltage,1)==numel(beamVoltage));
            
            bcv_mu = mean(beamCalVoltage,2);
            bcv_mu = bcv_mu - beamCalOffset;
            bcv_mu_raw = bcv_mu; %Store 'raw' value in case we need to display it later (for failed calibrations)
            
            bcv_sd = std(beamCalVoltage,1,2); % Old veej notes: Normalize by the number of calibration passes?
            bcv_mu(bcv_mu<0) = 0; %Identify negative values (likely due to incorrect offset) as 0 TODO: Better way?
            
            [beamCalMinVoltage minIdx] = min(bcv_mu);
            [beamCalMaxVoltage maxIdx] = max(bcv_mu);
            
            avg_dev = mean(bcv_sd/beamCalMaxVoltage);
            minAchievableBeamPowerFraction = max(beamCalMinVoltage/beamCalMaxVoltage, 1/obj.beamCalibrationLUTSize) ; %Enforce maximum dynamic range supported by LUT size % TODO rejected light case
            
            % warnings/failures
            tfFatalFailure = false;
            
            
            if avg_dev > obj.beamCalibrationFluctuationThreshold
                if beamCalMaxVoltage == 0
                    tfFatalFailure = true;
                    fatalWarnStr = 'Beam calibration data appears entirely negative-valued, unexpectedly. Connections or hardware may be faulty.';
                else
                    disp(strcat('WARNING: SI4:zprvBeamsProcessCalibrationData. - ',...
                        ' Beam calibration seems excessively noisy. Typical standard deviation per sample:',...
                        num2str(100*avg_dev)));
                    obj.zprvBeamsShowRawCalibrationData(beamVoltage, bcv_mu_raw);
                    % Continue with regular calibration
                end
            end
            
            if minAchievableBeamPowerFraction > obj.beamCalibrationMinThreshold
                tfFatalFailure = true;
                fatalWarnStr = sprintf('Beam calibration minimum power not less than 15%% of maximum power. Min/max: %s%%',...
                    num2str(100*minAchievableBeamPowerFraction));
            end
            
            % PR2014-09-22 this is exactly what happens at setup A, without
            % being an error >> erase
%             if beamCalMaxVoltage > 0 && minIdx >= maxIdx % TODO rejected light case
%                 tfFatalFailure = true;
%                 fatalWarnStr = '';
%             end
            
            if tfFatalFailure
                znstWarnAndRunNaiveCalibration(fatalWarnStr);
                return;
            end
            
            %Take measurement from rejected light, if necessary.
            %Note: The return values are still in absolute form.
            % TODO
            % rejected = state.init.eom.(['rejected_light' num2str(beam)]);
            % if rejected
            %   photodiode_voltage = 1 - photodiode_voltage;
            % end
            
            lut = zeros(obj.beamCalibrationLUTSize,1);
            bcvNormalized = bcv_mu/beamCalMaxVoltage;
            
            minAchievableBeamPowerLUTIdx = ceil(minAchievableBeamPowerFraction * obj.beamCalibrationLUTSize);
            maxAchievableBeamPowerLUTIdx = ceil(1 * obj.beamCalibrationLUTSize);
            
            lut(1:minAchievableBeamPowerLUTIdx-1) = nan; % These beam power idxs are unachievable; their lut values should never be used
            % For rest of LUT, do interpolation over interval [minIdx,maxIdx]
            
            if minIdx < maxIdx
                x = bcvNormalized(minIdx:maxIdx);
                y = beamVoltage(minIdx:maxIdx);
            else
                x = bcvNormalized(minIdx:-1:maxIdx);
                y = beamVoltage(minIdx:-1:maxIdx);
            end 
            
            % eliminate any flat zeros at beginning (these can be generated since we set all bcvNormalized values less than 0 to be 0)
            tfFlatZero = x==0;
            if any(tfFlatZero)
                flatZeroIdx = find(tfFlatZero);
                if ~isequal(flatZeroIdx,(1:numel(flatZeroIdx))')
                    % expect flat zeros only at the beginning
                    znstWarnAndRunNaiveCalibration('Unexpected flat zeros in beam calibration voltage');
                    return;
                end
                x(flatZeroIdx(1:end-1)) = []; % take last flatzero datapoint (highest beam voltage)
                y(flatZeroIdx(1:end-1)) = [];
            end
            
            x = zlclMonotonicize(x);
            y = zlclMonotonicize(y);

            % TODO on rare occasions this can run into trouble with repeated x values.
            if numel(x) == numel(unique(x))
                lut(minAchievableBeamPowerLUTIdx:obj.beamCalibrationLUTSize) = interp1(x,y,(minAchievableBeamPowerLUTIdx:obj.beamCalibrationLUTSize)/obj.beamCalibrationLUTSize,'pchip',nan);
            else
                lut(minAchievableBeamPowerLUTIdx:obj.beamCalibrationLUTSize) = 0;
            end
            
            
            function znstWarnAndRunNaiveCalibration(warnMsg)
                fprintf(2,'\nWARNING: Beam calibration data appears suspect. Using naive calibration.\n');
                if ~isempty(warnMsg)
                    fprintf(2,'\n Explanation: %s\n',warnMsg);
                end
                obj.zprvBeamsShowRawCalibrationData(beamVoltage,bcv_mu_raw);
                [lut beamCalMinVoltage beamCalMaxVoltage] = ...
                    obj.zprvBeamsPerformNaiveCalibration(beamVoltage);
            end
        end
        
        function [lut beamCalMinVoltage beamCalMaxVoltage] = ...
                zprvBeamsPerformNaiveCalibration(obj,beamVoltage)
            [lut beamCalMinVoltage beamCalMaxVoltage] = obj.zprvBeamsProcessCalibrationData(beamVoltage,beamVoltage,0.0);
        end
        
        function zprvBeamsSetCalibrationInfo(obj,beamIdx,lut,beamCalMinVoltage,beamCalMaxVoltage)
            validateattributes(beamIdx,{'numeric'},{'vector','integer','>=',1,'<=',obj.beamNumBeams});
            validateattributes(lut,{'numeric'},{'size',[obj.beamCalibrationLUTSize 1]});
            
            obj.beamCalibrationLUT(:,beamIdx) = lut;
            obj.beamCalibrationMinCalVoltage(1,beamIdx) = beamCalMinVoltage;
            obj.beamCalibrationMaxCalVoltage(1,beamIdx) = beamCalMaxVoltage;
            
            % round this value to the "resolution" of the LUT
            obj.beamCalibrationMinAchievablePowerFrac(1,beamIdx) = ...
                ceil(beamCalMinVoltage/beamCalMaxVoltage*obj.beamCalibrationLUTSize)/obj.beamCalibrationLUTSize;
            
            obj.beamPowers = obj.zprvBeamEnforcePowerLimits(obj.beamPowers);
        end
        
        function zprvBeamsShowRawCalibrationData(obj,beamVoltages,beamCalVoltages) %#ok<MANU>
            %Displays figure showing last measured raw calibration data obtained for beam modulation device of specified beamIdx
            try
                close 333333
            catch ME
            end
            figure(333333);
            set(gcf, 'color', [1 1 1])
            a = axes('Parent',333333,'FontSize',12,'FontWeight','Bold');
            [beamVoltages,idxs] = sort(beamVoltages);
            plot(beamVoltages,beamCalVoltages(idxs),'Parent',a,'Color',[0 0 0],'LineWidth',2);
            title(sprintf('Raw Calibration Data'),'Parent',a,'FontWeight','bold');
            xlabel('Beam Modulation Voltage [V]','Parent',a,'FontWeight','bold');
            ylabel('Beam Calibration Voltage [V]','Parent',a,'FontWeight','bold');
            %TODO is this figHandle stored somewhere
        end
        
        function zprvBeamsDepthPowerCorrection(obj,zStepSize,lz)
            % Modifies ith beam power according to
            %   newPower(i) = oldPower(i)*exp(zStepSize/lz(i))
            if obj.beamNumBeams > 0
                assert(numel(lz)==obj.beamNumBeams);
                obj.zprvSetInternal('beamPowers', obj.beamPowersNominal.*exp(zStepSize./lz));
            end
        end
        
        function beamPowers = zprvBeamEnforcePowerLimits(obj,beamPowers)
            assert(numel(beamPowers)==obj.beamNumBeams);
            
            % enforce upper limit
            maxPowers = obj.beamPowerLimits;
            switch obj.beamPowerUnits
                case 'percent'
                    beamPowers = min(beamPowers,maxPowers);
                case 'milliwatts'
                    % TODO
            end
            
            % enforce lower limit
            for c = 1:obj.beamNumBeams
                switch obj.beamPowerUnits
                    case 'percent'
                        beamPowers(c) = max(beamPowers(c),obj.beamCalibrationMinAchievablePowerFrac(c)*100);
                    case 'milliwatts'
                        %TODO
                end
            end
        end
        
    end
    
    %% HIDDEN METHODS (FastZ Operations)
    methods (Hidden)
        
        function zprvOverrideableFunction(obj,fcnName,varargin)
            if isfield(obj.userFunctionsOverriddenFcns2UserFcns,fcnName)
                % function is overridden
                userFcn = obj.userFunctionsOverriddenFcns2UserFcns.(fcnName);
                feval(userFcn,obj,varargin{:});
            else
                feval(fcnName,obj,varargin{:});
            end
        end
        
        
        
        %         function voltage = zprvFastZPosn2Voltage(obj,posn)
        %
        %             %TODO: Handle PI device 'generality' (logic now specific to SystemParameterBasicProperties devices, e.g. E-516 & E-816) -- either via adaptor class, or via added MotionController smarts
        %             voltage = (posn / obj.hFastZ.hStage.kSen) + obj.hFastZ.hStage.oSen;
        %
        %             %Ensure voltage fits
        %             voltage = min(max(voltage,obj.fastZAORange(1)),obj.fastZAORange(2));
        %         end
        
        function startPosn = zprvFastZUpdateAOData(obj,startPosn)
            % Updates AO data on device buffer, after shifting 'normalized' data to volume position
            
            if ~obj.fastZUseAOControl
                return;
            end
            
            %Shift voltage range to start position
            %TODO: Handle PI device 'generality' (logic now specific to SystemParameterBasicProperties devices, e.g. E-516 & E-816) -- either via adaptor class, or via added MotionController smarts
            if nargin < 2 || isempty(startPosn)
                startPosn = obj.hFastZ.positionAbsolute(end);
                %startPosn = obj.fastZPosnGet(); %Use current position, read from fastZ controller, as the start position
            end
            
            %Shift start position so starting axial position is located at center of first slice in fast-stack
            startPosn = startPosn - (obj.stackZStepSize)/2;
            
            %Shift start position so starting axial position is located at center of fast stack
            if obj.stackStartCentered
                startPosn = startPosn - ((obj.stackNumSlices-1) * obj.stackZStepSize)/2;
            end
            
            %Convert to voltage data
            startVoltage = obj.hFastZ.analogCmdPosn2Voltage(startPosn);
            fastZAOData = obj.fastZAODataNormalized + startVoltage;
            
            %Detect if command is outside allowable voltage range
            if max(fastZAOData(:)) > obj.hFastZAO.channels(1).get('max')
                maxClamp =  obj.hFastZAO.channels(1).max;
                fastZAOData(fastZAOData > maxClamp) = maxClamp;
                fprintf(2,'WARNING: Computed FastZ AO data exceeds maximum voltage of AO channel (%g). Full range of specified scan will not be achieved.\n',maxClamp);
            end
            
            if min(fastZAOData(:)) < obj.hFastZAO.channels(1).get('min')
                minClamp =  obj.hFastZAO.channels(1).min;
                fastZAOData(fastZAOData < minClamp) = minClamp;
                fprintf(2,'WARNING: Computed FastZ AO data falls below minimum voltage of AO channel (%g). Full range of specified scan will not be achieved.\n',minClamp);
            end
            
            %Shift voltage data to account for acquisition delay
            shiftVoltage = obj.fastZAcquisitionDelay * obj.fastZAODataSlope;
            fastZAOData = fastZAOData + shiftVoltage;
            
            %Update AO Buffer
            obj.hFastZAO.control('DAQmx_Val_Task_Unreserve'); %Flush any previous data in the buffer
            obj.hFastZAO.writeAnalogData(fastZAOData);
            obj.hFastZAO.cfgSampClkTiming(obj.mdfData.fastZCmdOutputRate, 'DAQmx_Val_FiniteSamps', obj.hFastZAO.get('bufOutputBufSize')); %Buffer length equals length of acquisition...no need to repeat
            
        end
        
        function zprvFastZUpdateAODataNormalized(obj)
            % Updates pre-computed buffer of 'normalized' AO data for FastZ operation
            % 'Normalized' data is properly scaled, but needs to be shifted to the stack starting position
            
            if ~obj.fastZAvailable || ~obj.fastZEnable || ~obj.fastZUseAOControl || isnan(obj.scanFramePeriod)
                obj.fastZAODataNormalized = [];
                return;
            end
            
            %Determine voltage range
            %Slice centers span (stackNumSlices - 1) * stackZStepSize, as
            %with a normal (slow) stack; the total span is larger, to cover
            %the first and last half-frames of the first and last slices,
            %respectively
            startVoltage = 0;
            endVoltage = obj.hFastZ.analogCmdPosn2Voltage(obj.stackNumSlices * obj.stackZStepSize);
            
            %Update fastZAODataNormalized property
            switch obj.fastZImageType
                case 'XY-Z'
                    znstFastZUpdateXYZ();
                case 'XZ'
                    znstFastZUpdateXZ();
                case 'XZ-Y'
                    if obj.stackNumSlices == 1
                        znstFastZUpdateXZ(); %Equivalent to XZ
                    else
                        znstFastZUpdateXZY();
                    end
                otherwise
                    assert(false);
            end
            
            
            return;
            
            function znstFastZUpdateXYZ()
                
                switch obj.fastZScanType
                    case 'sawtooth'
                        
                        numFramesImaged = obj.stackNumSlices * obj.acqNumFrames;
                        numFramesTotal = numFramesImaged + obj.fastZNumDiscardFrames;
                        obj.fastZFillFraction = (obj.stackNumSlices * obj.acqNumFrames) / numFramesTotal;
                        obj.fastZPeriod = numFramesTotal * (1/obj.scanFrameRate) + (numFramesTotal * obj.fastZFramePeriodAdjustment * 1e-6);
                        
                        outputRate = obj.mdfData.fastZCmdOutputRate;
                        
                        if obj.fastZDiscardFlybackFrames && obj.fastZNumDiscardFrames > 0
                            %Flyback/settling will occur during the discarded frame(s) at end of each stack frame set
                            
                            %TODO: Deal with negative ramp case
                            %TODO: Detect excessive memory use up front and prevent -- i.e. by warning and disabling FastZ mode
                            
                            totalNumSamples = ceil(obj.fastZPeriod * outputRate);
                            %rampNumSamples = round(((1/obj.scanFrameRate) * numFramesImaged + numFramesImaged * obj.fastZFramePeriodAdjustment * 1e-6) * obj.mdfData.fastZCmdOutputRate); %VI061112A: Arguably should be doing this instead
                            rampNumSamples = round((1/obj.scanFrameRate) * numFramesImaged * outputRate); %VVV061112A: Arguably we should should apply the fastZFramePeriodAdjustment for each frame in determining the length of ramp, as would be done by commented line above. Right now, all accumulated slop is shaved off the flyback time.
                            assert(rampNumSamples > 0);
                            settlingNumSamples = round(obj.fastZSettlingTime * outputRate);
                            
                            flybackNumSamples = totalNumSamples - (rampNumSamples + settlingNumSamples) - 1;
                            
                            rampData = linspace(startVoltage,endVoltage,rampNumSamples);
                            rampSlope = (endVoltage-startVoltage)/(rampNumSamples-1);
                            
                            settlingStartVoltage = startVoltage - rampSlope * settlingNumSamples;
                            
                            flybackData = linspace(endVoltage,settlingStartVoltage,flybackNumSamples+1);
                            flybackData(1) = [];
                            
                            settlingData = linspace(settlingStartVoltage,startVoltage,settlingNumSamples+1);
                            
                            obj.fastZAODataNormalized = [rampData flybackData settlingData]';
                        else
                            %Flyback/settling will occur at start of first frame in each stack frame set
                            %Command signal is simply naive...no shaped flyback or settling period
                            
                            rampNumSamples = outputRate * obj.fastZPeriod;
                            obj.fastZAODataNormalized = linspace(startVoltage,endVoltage,rampNumSamples)';
                        end
                        
                        obj.fastZAODataSlope = (endVoltage-startVoltage)/(rampNumSamples/outputRate);
                        
                    case 'step'
                        %TODO
                        
                end
            end
            
            function znstFastZUpdateXZ()
                %TODO
            end
            
            function znstFastZUpdateXZY()
                %TODO
            end
            
        end
    end
    
    %% HIDDEN METHODS (Galvo Control)
    methods (Hidden)
        
        function zprvGalvosUpdateAODataConditional(obj)
            %Update Galvo data buffer if and as needed before acquisition mode or next slice
            
            if obj.galvoEnable
                if ~obj.mroiEnabled
                    obj.zprvGalvosUpdateAOData('1d');
                else
                    obj.zprvGalvosUpdateAOData('2d');
                end
            end
        end
        
        
        
        function zprvGalvosUpdateAODataBuf1D(obj)
            %Update SI4 galvo control waveform for case of 1D (Y only) galvo control
            
            numGalvos = length(obj.mdfData.galvoChanIDs);
            
            if obj.scanAngleMultiplierSlow > 0
                %Compute Y galvo ramp during scanned lines/frame
                
                yRampPeriod = obj.scanLinePeriod * obj.scanLinesPerFrame;
                yScanPeriod = obj.scanFramePeriod;
                
                %yFactor = obj.mdfData.galvoAngle2VoltageFactor(end) / obj.galvoAngle2LSMAngleFactor;
                %yMaxVoltage = (obj.mdfData.scannerMaxAngularRange * obj.scanAngleMultiplierSlow / (2 * obj.scanZoomFactor)) * yFactor;
                yMaxAngle = obj.mdfData.scannerMaxAngularRange * obj.scanAngleMultiplierSlow / (2 * obj.scanZoomFactor);
                
                yScanNumSamples = floor(0.99 * yScanPeriod * obj.mdfData.galvoCmdOutputRate); %Ensure Y scan waveform is always shorter than actual frame period (accounting for possible frame period variance)
                yRampNumSamples = ceil(yRampPeriod * obj.mdfData.galvoCmdOutputRate);
                
                if yScanNumSamples < yRampNumSamples
                    yScanNumSamples = yRampNumSamples + floor(0.9 * ((yScanPeriod * obj.mdfData.galvoCmdOutputRate) - yRampNumSamples));
                end
                
                if mod(yScanNumSamples,2)
                    yScanNumSamples = yScanNumSamples - 1;
                end
                assert(yScanNumSamples > yRampNumSamples);
                
                yScanData = zeros(yScanNumSamples,1);
                yScanData(1:yRampNumSamples,1) = linspace(-yMaxAngle,yMaxAngle,yRampNumSamples)';
                yScanData(yRampNumSamples+1:end) = linspace(yMaxAngle,-yMaxAngle,yScanNumSamples - yRampNumSamples)';
                
                if numGalvos == 1
                    obj.galvoAODataBuf1D = yScanData;
                else
                    xScanData = zeros(length(yScanData),1); %TODO Account for scan shift
                    obj.galvoAODataBuf1D = [xScanData yScanData];
                end
            else
                obj.galvoAODataBuf1D = zeros(2,numGalvos); %TODO: Use scanShift values instead of assuming zero
            end
        end
        
        function zprvGalvosUpdateAOData(obj,dimSel)
            %dimSel: One of {'1d' '2d'}
            
            if ~obj.galvoEnable
                return;
            end
            
            numGalvos = length(obj.mdfData.galvoChanIDs);
            
            
            obj.hGalvos.control('DAQmx_Val_Task_Unreserve');
            
            switch dimSel
                case '1d'
                    numSamples = size(obj.galvoAODataBuf1D,1);
                case '2d'
                    numSamples = size(obj.galvoAODataBuf2D,1);
                otherwise
                    assert(false);
            end
            
            obj.hGalvos.cfgSampClkTiming(obj.mdfData.galvoCmdOutputRate,'DAQmx_Val_FiniteSamps',numSamples);
            obj.hGalvos.cfgOutputBuffer(numSamples);
            
            
            %Convert to voltages & load to DAQmx Task
            voltFactor = zeros(1,numGalvos);
            voltFactor(1) = obj.mdfData.galvoAngle2VoltageFactor(1) / obj.galvoAngle2LSMAngleFactor;  %Conversion factor from LSM angle to galvo voltage
            if numGalvos > 1
                voltFactor(2) = obj.mdfData.galvoAngle2VoltageFactor(end) / obj.galvoAngle2LSMAngleFactor(end);
            end
            
            if isequal(dimSel,'1d')
                obj.hGalvos.writeAnalogData(obj.galvoAODataBuf1D * voltFactor(1));
            else
                obj.hGalvos.writeAnalogData([obj.galvoAODataBuf2D(:,1) * voltFactor(1) obj.galvoAODataBuf2D(:,2) * voltFactor(2)]);
            end
            
        end
    end
    
    
    %% HIDDEN METHODS (Flow Control)
    methods (Hidden)
        
        function tf = isIdle(obj)
            tf = strcmpi(obj.acqState,'idle');
        end
        
        function tf = isLive(obj)
            tf = ismember(obj.acqState,{'focus' 'grab' 'loop'});
        end
        
        function continueTF = zprvIterateLoop(obj,liveNow)
            %Advances repeat counter & ends or advances to next repeat
            %liveNow: Logical indicating if this call is occuring /during/ an ongoing acquisition
            %
            %If liveNow=true, then next acquisition is not automatically re-started by this function -- this is left to caller
            obj.triggerTimeLast = tic();
            obj.hBeams.stop();
            obj.hFramePeriodCtr.stop();
            obj.hLSM.start1(obj.loggingEnable);

            
            if nargin < 2
                liveNow = false;
            end
            
            continueTF = true;
            
            obj.loopRepeatsDone = obj.loopRepeatsDone + 1;
            
            if obj.loopRepeatsDone >= obj.loopNumRepeats || ...  %finished with repeats
                    (isinf(obj.loopRepeatPeriod) && ~obj.triggerExtStartTrigUsed) %can never get to the next repeat
                
                if liveNow
                    obj.zprvEndAcquisition('idle');
                end
                
                obj.zprvEndAcquisitionMode();
                obj.acqState = 'idle';
                continueTF = false;
            else
                %Start next loop repeat
                
                obj.zprvResetAcqCounters(false); %Reset all but the loopRepeat counter
                %obj.zprvArmTrigCallback(); %Ensure start trigger (not next trigger) is armed
                
                if ~liveNow  %Defer live iteration behavior to elsewhere (i.e. next triggering)
                    
                    if ~obj.triggerExtStartTrigUsed
                        znstWaitRepeatPeriod();
                    end
                    
                    if ~obj.isIdle() %check that acquisition wasn't aborted
                        obj.zprvStartAcquisition(obj.acqState); %state can be either 'loop_wait' or 'loop'
                    end
                end
            end
            
            function znstWaitRepeatPeriod()
                obj.zprvUpdateSecondsCounter();
                if obj.secondsCounter < 0
                    fprintf(2,'Delay too short!\n');
                    drawnow; %This seems required to make sure event queue is flushed and next triggerCallback is honored. TODO: Review this!
                elseif obj.secondsCounter < 1
                    %do nothing
                else
                    while true
                        if obj.secondsCounter < 2
                            pause(obj.secondsCounter - 1);
                            obj.zprvUpdateSecondsCounter();
                            break;
                        else
                            pause(1);
                            obj.zprvUpdateSecondsCounter();
                        end
                        
                        %Test to see if abort occurred
                        if obj.isIdle()
                            break;
                        end
                    end
                end
            end
        end
        
        
        function zprvStopAcquisition(obj,abortTF,pauseMode)
            %Universal activities at end or abort of acquisition - FOCUS or GRAB acquisition, LOOP repeat, or slice of either
            %Shutter is closed, beams are Off, LSM scanner stopped
            %   abortTF: <OPTIONAL;Default=false;Logical> If true, specifies this is an abort operation
            %   pauseMode: <OPTIONAL;Default=false;Logical> If true, file logging is not suspended, so that acquisition can be resumed by subsequent resumeAcquisition() call
            
            %TODO: In case where there's Pockels, but no shutter -- might consider blanking beam before stopping LSM, to limit exposure
            
            if nargin < 2
                abortTF = false;
            end
            
            if nargin < 3
                pauseMode = false;
            end
            
            if pauseMode
                obj.hLSM.pause();
            else
                obj.shuttersTransition(false);
                lostAcquiredFrames = obj.hLSM.finish(abortTF); %Suppress dropped frame warnings if aborting
                
                if lostAcquiredFrames && ~abortTF && ismember(obj.acqState,{'grab' 'loop'})
                    fprintf(2,'WARNING: Dropped acquired frames! Failed to retrieve %d acquired frames from data queue (lost for display and processing).\n', lostAcquiredFrames);
                end
                
            end
            
            %Flush any remaining frameAcquird callbacks
            %drawnow();
            
            %Stop all 'acquisition' NI DAQmx Tasks
            if ~isempty(obj.hAcqTasks)
                
                %Get number of frames started during acquisition
                if ~abortTF %During abort operations, the hFramePeriodCtr may already have been stopped (if abort occurred between stack slices or Loop Repeats)
                    obj.scanFramesStarted = obj.hFramePeriodCtr.get('readTotalSampPerChanAcquired') + 1;
                end
                
                if abortTF
                    obj.hAcqTasks.abort();
                else
                    obj.hAcqTasks.stop();
                end
                obj.hAcqTasks = [];
            end
            
            %TODO: Consider when, if ever, to attempt to stop motor here
            
            
            %Put various hardware in 'standby' mode
            obj.beamsStandby();
            obj.galvosStandby();
            
            obj.hLSM.finish();
            
        end
        
        function zprvEndAcquisition(obj,newState)
            %End a GRAB acquisition or LOOP repeat
            %   newState: <OPTIONAL> New acqState to transition to after stopping acquisition
 
            obj.zprvStopAcquisition();
            
            %Return to original z-position and power, if needed
            obj.zprvGoHome();
            
            %Advance file-counter
            if obj.stackSlicesDone > 0
                obj.zprvSetInternal('loggingFileCounter', obj.loggingFileCounter + 1);
            end
            %Verify that number of frames acquired matches the number scanned
            %if ~ismember(obj.acqFramesDoneTotal + obj.hLSM.droppedFramesTotal, obj.scanFramesStarted + [-1 0]) && ~isinf(obj.hLSM.multiFrameCount) && (obj.stackNumSlices == 1 || obj.fastZEnable)
            if (obj.acqFramesDoneTotal ~= obj.scanFramesStarted) && ~isinf(obj.hLSM.multiFrameCount) && (obj.stackNumSlices == 1 || obj.fastZEnable)
                %fprintf(2,'WARNING: Number of scanned frames (%d) suspiciously differs from the measured number of frame triggers (%d)\n',obj.acqFramesDoneTotal + obj.hLSM.droppedFramesTotal,obj.scanFramesStarted);
%                 fprintf(2,'WARNING: Frame tag of last-acquired frame (%d) suspiciously differs from the measured number of frame triggers (%d)\n',obj.acqFramesDoneTotal + obj.hLSM.droppedFramesLast,obj.scanFramesStarted);
                fprintf(2,'WARNING: Frame tag of last-acquired frame (%d) suspiciously differs from the measured number of frame triggers (%d)\n',obj.acqFramesDoneTotal,obj.scanFramesStarted); % PR2014: droppedFramesLast was []
             
                obj.droppedFrames = obj.scanFramesStarted-obj.acqFramesDoneTotal;
            
            end
            
            if nargin >= 2
                obj.acqState = newState;
            end
            
            obj.notify('acquisitionDone');
            
        end
        
        function zprvEndAcquisitionMode(obj)
            %Handle the end of FOCUS/GRAB/LOOP aquisition mode
            
            %             obj.hLSM.loggingEnable = false; %Should disable logging thread
            obj.hTimestampCounters.stop();
            obj.hTriggerCallbackCtr.stop();
            obj.xTrigCallback.stop();
            
            %Stop external trigger timer, if needed
            obj.zprvClearExtTrigTimer();
            
            if obj.cfgOneShotLoaded
                obj.cfgUnloadConfigOneShot();
            end
            
            %Verify next-trigger frame breaks, if applicable
            if numel(obj.loggingFrameBreaks) > 1 && obj.verifyOptions.nextTrigCheckFrameBreaks
                scanimage.tests.verifyNextTriggerFrameBreaks(obj);
            end
            
            obj.notify('motorPositionUpdate'); %Signal potential motor position update
        end
        
        function zprvStartAcquisition(obj,acqMode)
            
            obj.overshoot = 0;
            
            if obj.triggerOut
                obj.triggerOutSet();
            end
            if obj.showMeanLive
                obj.showMeanLive = 0;
            end
            
            % prevent dumped frames at the end of the acquisition
            if (obj.framerate_user_check && obj.framerate_user > obj.acqNumFrames/0.8) || (~obj.framerate_user_check && obj.hLSM.framerate > obj.acqNumFrames/0.8)
            	obj.framerate_user_check = 1;
                obj.framerate_user = obj.acqNumFrames/0.8;
                disp('Automatically decrease framerate for slicing (not time-limiting factor), PR2014.');
            end
            
            %Starts either a GRAB acquisition or LOOP repeat
            %
            % SYNTAX
            %   zprvStartAcquisition(obj,acqMode)
            %     acqMode: <One of {'grab' 'loop' 'loop_wait'}> Indicates whether a new 'grab' or 'loop' acquisition is being started, or that a new loop Repeat is being started in case 'loop_wait'
            %
            % NOTES
            %   Only called for first slice of a multi-slice GRAB acquisition or LOOP repeat
            %   zprvStartAcquisitionSlice() is called for each slice in a multi-slice acquisition
            
            notify(obj,'acquisitionStart');
            
            
            %Set LSM 'trigger mode' && number of frames
            if obj.acqNumFramesPerTrigger == 1
                if obj.triggerExtStartTrigUsed && obj.triggerExtStartTrigPreScan
                    obj.hLSM.triggerMode = 'HW_SINGLE_FRAME';
                else
                    obj.hLSM.triggerMode = 'SW_SINGLE_FRAME';
                end
            else
                if obj.triggerExtStartTrigUsed && obj.triggerExtStartTrigPreScan
                    obj.hLSM.triggerMode = 'HW_MULTI_FRAME_TRIGGER_FIRST';
                else
                    obj.hLSM.triggerMode = 'SW_MULTI_FRAME';
                end
            end
            
            if obj.triggerNextTrigUsed
                obj.hLSM.multiFrameCount = inf;
            else
                obj.hLSM.multiFrameCount = obj.acqNumFramesPerTrigger;
            end
            
            %Configure multi-slice acquisition, as needed
            obj.zprvResetHome(); %Reset motor/fastZ/beam positions/powers
            
            if obj.stackNumSlices > 1
                
                if obj.fastZEnable %A volume imaging acquisition
                    obj.zprvFastZUpdateAOData();
                    
                    %Prepare beam output buffer, if needed
                    if  (obj.beamFlybackBlanking || obj.beamPzAdjust)
                        obj.zprvBeamsWriteFastZData(); %Overwrites standard beam data written with zprvBeamsWriteFlybackDAta()
                        
                        if obj.fastZAllowLiveBeamAdjust && obj.beamNumBeams > 0
                            obj.hBeams.set('writeRelativeTo','DAQmx_Val_FirstSample');
                        end
                    end
                    
                    if obj.stackReturnHome
                        obj.fastZHomePosition = obj.hFastZ.positionAbsolute(end); %Store original position
                    end
                    
                else  % Taking a motor-driven image stack
                    %Before first slice in stack
                    assert(obj.motorHasMotor);
                    
                    % Deal with return-home
                    if obj.stackReturnHome
                        obj.acqMotorPositionStackStart = obj.motorPosition;
                        obj.acqBeamPowersStackStart = obj.beamPowers;
                    end
                    
                    % Deal with starting zpos
                    preStartZIncrement = []; %#ok<NASGU> % This is the size of the motor move we will execute pre-stack. This is set in the next block.
                    if ~isnan(obj.stackZStartPos)
                        if obj.stackStartCentered
                            warnst = warning('off','backtrace');
                            warning('SI4:ignoringStackStartCentered',...
                                'Starting z-position for stack has been set. Stack will not be centered around the current zposition.');
                            warning(warnst);
                        end
                        
                        % Throw a warning if the current position does
                        % not match stackLastStartEndPositionSet or the
                        % calculated stack final position. When this
                        % condition holds, it is probable that the user
                        % has moved the motor position after setting up
                        % (and possibly running) a stack. In this
                        % situation the stackZStart/EndPos info may
                        % potentially be stale.
                        currStackZPosn = obj.stackCurrentMotorZPos;
                        stackFinalZPos = obj.stackZStartPos + (obj.stackNumSlices-1)*obj.stackZStepSize; % in this codepath, the stack starting pos is obj.stackZStartPos
                        if ~isequal(currStackZPosn,obj.stackLastStartEndPositionSet) && ...
                                ~isequal(currStackZPosn,stackFinalZPos) % this condition is for when stackZStartPos is set last, and stackReturnHome is false.
                            warnst = warning('off','backtrace');
                            warning('SI4:stackWithPotentiallyStaleStartEndPos',...
                                'Motor has moved since last stack start/end position was set.');
                            warning(warnst);
                        end
                        
                        preStartZIncrement = obj.stackZStartPos-currStackZPosn;
                        posn = obj.stackZMotor.positionRelative;
                        posn(3) = obj.stackZStartPos;
                        obj.stackZMotor.moveCompleteRelative(posn);
                    elseif obj.stackStartCentered
                        totalStackdz = (obj.stackNumSlices-1)*obj.stackZStepSize;
                        preStartZIncrement = -totalStackdz/2;
                        posn = obj.stackZMotor.positionRelative;
                        posn(3) = posn(3) + preStartZIncrement;
                        obj.stackZMotor.moveCompleteRelative(posn);
                    else
                        % none; start stack at current zpos
                        preStartZIncrement = 0.0;
                    end
                    obj.notify('motorPositionUpdate'); %Signal potential motor position update
                    
                    % deal with starting power
                    if obj.stackUseStartPower && ~isnan(obj.stackStartPower)
                        % use stack starting power; ignore any
                        % correction due to preStartZIncrement and Lz
                        obj.zprvSetInternal('beamPowers',obj.stackStartPower);
                    else
                        % correct starting power using acquisition Lz (could be overridden, etc)
                        obj.zprvBeamsDepthPowerCorrection(preStartZIncrement,obj.acqBeamLengthConstants);
                    end
                    
                    % throw a warning if the final power will exceed 100%
                    beamPwrs = obj.beamPowers; % beam powers have been initialized to stack-start values
                    totalStackDz = (obj.stackNumSlices-1)*obj.stackZStepSize;
                    finalPwrs = beamPwrs.*exp(totalStackDz./obj.acqBeamLengthConstants); %This line forces acqBeamLengthConstants to be computed, if not done so already
                    if any(finalPwrs(:)>100)
                        warnst = warning('off','backtrace');
                        warning('SI4:beamPowerWillSaturate',...
                            'Beam power correction will cause one or more beams to exceed 100%% power at or before stack end. Beam power will saturate at 100%%.');
                        warning(warnst);
                    end
                end
            end
            
            
            %Handle those start operations that must occur for each slice of a multi-slice acquisition
            obj.zprvStartAcquisitionSlice(acqMode);
        end
        
        
        function zprvStartAcquisitionSlice(obj,acqMode)
            %Start or Resume next slice (including first or only slice) of an individual GRAB acquisition or LOOP repeat
            %
            % NOTES
            %   Method handles start operations that must occur before each slice, in event of motor-based stack acqusition
            resume = nargin < 2;
            
            %Reset frame counter & frame averaging buffer
            obj.acqFramesDone = 0;
            obj.acqFramesDoneTotal = 0;
            obj.zprvResetBuffers();
            % If appropriate, turn off DirectMode
            % VVV: Should setting of beamDirectMode in middle of an acquisition mode be allowed?? If not, this wouldn't be needed, at least not here.
            if obj.beamDirectMode
                obj.zprvSetInternal('beamDirectMode', false); % This resets beam task if needed
            end
            
            %Handle logging file-chunking, as needed
            if obj.loggingFileNumChunks
                obj.loggingFileSubCounter = 1;
            else
                obj.loggingFileSubCounter = [];
            end
            
            if resume
                obj.nostatereport = 1;
                temp = obj.acqState;
                obj.acqState = 'idle';
                obj.scanZoomFactor = obj.scanZoomFactor;
                obj.acqState = temp;
                obj.nostatereport = 0;
                display('Motor settled, resume acquisition, PR2014-10-15.');
                %Refresh galvo AO buffers
                obj.zprvGalvosUpdateAODataConditional();
                %Start acquisition up again, in prevailing acqState
                znstStartAcq(obj.acqState);
                %Force use of self trigger for resume operation
                extStartTriggered = obj.triggerExtStartTrigUsed;
                
                %Start acquisition DAQmx Tasks
                obj.zprvDaqmxStart(obj.hTriggerCallbackCtr);
                obj.frameCounter = 0;
                obj.zprvDaqmxStart(obj.xTrigCallback);
                %For acquisitions with multiple starts of
                %triggerCallbackCtr, e.g. stack and LOOP acquisitions, a
                %pause() or drawnow() is required either before or after
                %subsequent starts to ensure that trigger callback is executed.
                %However, we can skip it because both stack and LOOP
                %acquisitions use pause or drawnow in logic between
                %slices/iterations, respectively.
                
                %drawnow();
                 
                obj.zprvDaqmxStart([obj.hBeams obj.hFramePeriodCtr]);

                if obj.fastZEnable && obj.fastZUseAOControl
                    obj.zprvDaqmxStart(obj.hFastZAO);
                end
                obj.hSelfTrig.writeDigitalData(0,0.2);
                obj.hSelfTrig.writeDigitalData(1,0.2);
                obj.hSelfTrig.writeDigitalData(0,0.2);
                obj.triggerFcn();
            else
                switch acqMode
                    case {'grab' 'loop'} %Either starting a GRAB acq, the first LOOP Repeat, or the next slice within a LOOP repeat
                        znstStartAcq(acqMode);
                        
                    case 'loop_wait'  %Waiting to start next Repeat of LOOP
                        if obj.loopRepeatsDone > 0 %vvv: Shouldn't this always be true in 'loop_wait' case??
                            obj.zprvUpdateSecondsCounter();
                            
                            if ~obj.triggerExtStartTrigUsed
                                pause(obj.secondsCounter - 0.2); %allow fixed time for the startAcq() operation
                            end
                            
                            %obj.secondsCounter = 0; %Ensure that 0 is displayed at end of countdown
                        end
                        
                        znstStartAcq('loop'); %will transition to 'loop' state
                    otherwise
                        assert(false);
                end
                
            end
            
            return;
            
            function znstStartAcq(acqMode)
                %Shared logic for actual start of GRAB acquisition and LOOP repeats, or single slice thereof
                
                extStartTriggered = obj.triggerExtStartTrigUsed;
                
                %Start acquisition DAQmx Tasks
                obj.zprvDaqmxStart(obj.hTriggerCallbackCtr);
                obj.frameCounter = 0;
                obj.zprvDaqmxStart(obj.xTrigCallback);
                
                %For acquisitions with multiple starts of
                %triggerCallbackCtr, e.g. stack and LOOP acquisitions, a
                %pause() or drawnow() is required either before or after
                %subsequent starts to ensure that trigger callback is executed.
                %However, we can skip it because both stack and LOOP
                %acquisitions use pause or drawnow in logic between
                %slices/iterations, respectively.
                
                %drawnow();
                obj.zprvDaqmxStart([obj.hBeams obj.hFramePeriodCtr]);
                if obj.fastZEnable && 0 %obj.fastZUseAOControl
                    obj.zprvDaqmxStart(obj.hFastZAO);
                end
                
                %Arm/start scanner, as needed
                %                 if resume
                %                     obj.hLSM.resume(); %Starts scanning again
                %                 else
                
                if resume
                      obj.hLSM.state = 'armed';
%                     obj.hLSM.rearm(); %TODO: Possibly do not need arm() again, if previous acq was in single-frame mode
%                     obj.hLSM.frameClock.start();
                else
                    obj.acqState = acqMode;
                    obj.handParamsToLSM;
                    obj.hLSM.arm(); %TODO: Possibly do not need arm() again, if previous acq was in single-frame mode
                    if ~extStartTriggered && obj.lowVal == 0
                        obj.shuttersTransition(true,~extStartTriggered);
                    end
                    % ext. Trigger should be configured, PR2014.
                    
                    
                    %Send 'self' trigger, as needed
                    if extStartTriggered
                        if ~isinf(obj.triggerExtStartTrigTimeout)
                            obj.triggerExtTrigTimer = timer('TimerFcn',@(~,~)obj.znstExtTrigTimerFcn,'StartDelay',obj.triggerExtStartTrigTimeout,'Name','External Trigger Timeout Timer');
%                             obj.triggerExtTrigTimer = timer('TimerFcn',@(~,~)obj.znstExtTrigTimerFcn,'StartDelay',2,'Name','External Trigger Timeout Timer');
                            start(obj.triggerExtTrigTimer);
                        end
                        obj.statusString = 'I m ready now!';
%                         disp('I m ready now!');
%                         pause(3);
%                         obj.hSelfTrig.stop()
%                         obj.hSelfTrig.stop()
%                         obj.hSelfTrig.writeDigitalData(0,0);
%                         obj.hSelfTrig.writeDigitalData(1,0);
%                         obj.hSelfTrig.writeDigitalData(0,0);
                    else
                          
                        obj.hSelfTrig.writeDigitalData(0,0.0);
                        obj.hSelfTrig.writeDigitalData(1,0.0);
                        obj.hSelfTrig.writeDigitalData(0,0.0);
%                         obj.hSelfTrig.writeDigitalData([0;1;0],0.2); % TAPIR
                    end
                    
                    %Start scanner now if externally triggered (and pre-scanning enabled)
%                     if extStartTriggered && obj.triggerExtStartTrigPreScan
%                         obj.hLSM.start0(false);
%                         obj.startUnnested(obj.loggingEnable);
%                     end  
                  
                end
                
                %TODO: Implement count-up timer when waiting for external trigger...
                
                %                 obj.hLSM.start();
                %
                %                 %TODO: make acquisitionStartedFcn() used as a callback
                %                 obj.acquisitionStartedFcn();
            end
            
        end

        function znstExtTrigTimerFcn(obj)
%             if obj.hLSM.running %acquisition has been armed or started %
%             check is omitted, PR2014, implement later!
                obj.abort();
                disp('Abort: External trigger timeout, PR2014.');
%             else
%                 delete(obj.triggerExtTrigTimer);
%             end

        end
        
        function continueTF = zprvStartAcquisitionMode(obj,acqMode)
            %Shared boilerplate functionality for start of GRAB/LOOP acquisition modes
            % acqMode: One of {'grab' 'loop'}
            
            %Ensure scanFramePeriod is measured
            continueTF = obj.zprvEnsureScannerPeriodMeasured();
            
            %Update motor position
            obj.notify('motorPositionUpdate');
            
            %Ensure logging file is configured, if logging enabled
            obj.loggingFileSubCounter = [];
            if obj.loggingEnable && ~obj.zprvValidateLoggingFile();
                continueTF = false;
                return;
            end
            
            %Other common functionality
            obj.zprvResetAcqCounters(); %Resets /all/ counters
            obj.zprvResetTriggerTimes();
            obj.zprvArmTrigCallback(); %Ensure start trigger is armed
            %obj.armTriggers();
            
            %Read PMT offsets, if needed
            if obj.channelsAutoReadOffsets && ~isempty(union(obj.channelsDisplay,obj.channelsSave))
                obj.channelsReadOffsets();
            end
            
            %Updates display limits & aspect ratio. Calls drawnow() to
            %flush event queue (forces channel offset table update)
            obj.zprvUpdateChannelDisplayRatioAndLims();
            
            %Cache header data and start logging at Thor LSM MEX level
            tempus = obj.triggerHeaderProps;
            tempus{numel(obj.triggerHeaderProps)+1} = 'averagedStorage'; % workaround PR2014-08-26
            obj.headerStringCache = obj.modelGetHeader('exclude',tempus);% obj.averagedStorage); % TEMPUS
            if obj.loggingEnable
                obj.hLSM.loggingHeaderString = obj.headerString; %Fills in dummy/initial strings for the triggerHeaderProps, as placeholder to maintain fixed header length
            end
            %             obj.hLSM.loggingEnable = obj.loggingEnable; %This starts logging thread
            %NOTE: It might not be necessary to fill in dummy header string...since it appears that LSM Mex file will close and re-open the file...and we never change header of a file in the middle at moment (we start new files every time there's new header information)
            
            %Start DAQmx CI Tasks used for timestamping
            obj.hTimestampCounters.stop();
            obj.hTimestampCounters.start();
            
            %Prepare FastZ acquisition
            obj.fastZNextTrigSignal = 0;
            
            %Prepare External/Multi-ROI Galvo Signal(s), if needed
            obj.zprvGalvosUpdateAODataConditional();
            
            %Prepare LSM parameters
            obj.zprvSetLSMJITParams(acqMode);
        end
        
        function continueTF = zprvEnsureScannerPeriodMeasured(obj)
            %Ensure LSM line period has been measured at current scan settings, initiating measurement if neeed
            %Return false if LSM line period was not previously measured (even if it is measured by this function)
            
            continueTF = ~isnan(obj.scanFramePeriod);
            
            if ~continueTF
                resp = questdlg('Scan Line Period has not been measured for installed scanner parameters, which is required prior to acquisition. Do this now?','Scan Line Period not measured', 'OK','Cancel','OK');
                switch resp
                    case 'OK'
                        obj.scannerPeriodMeasure(true);
                    case 'Cancel'
                        %Do nothing
                end
            end
        end
        
        function zprvSetLSMJITParams(obj,acqMode)
            %Consolidated setter of LSM Params that are set 'just in time' - i.e. depend on acqMode to be entered
            %
            % *Multi-ROI is only supported during GRAB/LOOP acquisitions (not FOCUS)
            isFocus = isequal(acqMode,'focus');
            
            
            % Set flybackScannerPeriods props
            flybackZero = obj.scanAngleMultiplierSlow == 0 || ... %line-scan case
                (~isFocus && obj.galvoEnable && length(obj.mroiParams) > 1); %multi-ROI case
            
            
            if flybackZero
                obj.hLSM.flybackScannerPeriodsSetEnable = true;
                obj.hLSM.flybackScannerPeriods = 0;
            else
                obj.hLSM.flybackScannerPeriodsSetEnable = false;
            end
            
            obj.zprpUpdateGalvoProps(); %Update galvo props nowinitValStruct that flybackScannerPeriods is determined
            
            %Set LSM pixelsPerLine & linesPerFrame according to acqMode
            if obj.mroiEnabled
                ppl = obj.mroiPixelsPerLine; %TODO: Add multi-ROI specific property for pixelsPerLine, apart from the 'main' one
                lpf = obj.mroiLinesPerLSMFrame;
            else
                ppl = obj.scanPixelsPerLine;
                lpf = obj.scanLinesPerFrame;
            end
            
            lpfOld = obj.hLSM.linesPerFrame;
            if ppl > lpfOld
                obj.hLSM.pixelsPerLine = ppl;
                obj.hLSM.linesPerFrame = lpf;
            else
                obj.hLSM.linesPerFrame = lpf;
                obj.hLSM.pixelsPerLine = ppl;
            end
            
        end
        
        function zprvPauseFocus(obj)
            if isequal(obj.acqState,'focus')
                obj.hLSM.pauseFocus();
%                 obj.hLSM.configureFrameAcquiredEvent('stop'); %This stops ThorFrameCopier processing, including frame clocks
            end
        end
        
        function zprvResumeFocus(obj,setLSMJITParams)
            %Restarts LSM acquisition, if acqState=='focus'
            % setLSMJITParams: <Default=false> If true, @zprvSetLSMJITParams is called during restart
            
            if nargin < 2
                setLSMJITParams = false; %for now
            end
            %This pause is sometimes needed, to avoid seg faults, between
            %the LSM parameter changes that typically precede this function
            %and restarting focus. E.g. for scanZoomFactor & scanPhase
            %changes
            pause(0.05);
            
            obj.hLSM.resumeFocus();
        end
        
        
        
    end
    %% HIDDEN METHODS (Motor)
    methods (Hidden)
        
        function motorZeroSoft(obj,coordFlags)
            % Do a soft zero along the specified coordinates, and update
            % stackZStart/EndPos appropriately.
            %
            % SYNTAX
            % coordFlags: a 3- or 4-element logical vec. The number of
            % elements should match motorPositionLength.
            %
            % NOTE: it is a bit dangerous to expose the motor publicly, since
            % zeroing it directly will bypass updating stackZStart/EndPos.
            
            if ~obj.motorHasMotor
                obj.zprvMotorThrowNoMotorErrIfMdlInitialized();
            end
            
            coordFlags = logical(coordFlags);
            assert(numel(coordFlags)==obj.motorPositionLength,...
                'Number of elements in coordFlags must match motorPositionLength.');
            
            if strcmp(obj.motorDimensionConfiguration,'xyz-z') && obj.motorSecondMotorZEnable
                tfRescaleStackZStartEndPos = coordFlags(4);
            else
                tfRescaleStackZStartEndPos = coordFlags(3);
            end
            if tfRescaleStackZStartEndPos
                origZCoord = obj.stackZMotor.positionRelative(3);
            end
            
            switch obj.motorDimensionConfiguration
                case {'xyz' 'xy' 'z'}
                    obj.hMotor.zeroSoft(coordFlags);
                case 'xy-z'
                    obj.hMotor.zeroSoft([coordFlags(1:2) false]);
                    obj.hMotorZ.zeroSoft([false false coordFlags(3)]);
                case 'xyz-z'
                    obj.hMotor.zeroSoft(coordFlags(1:3));
                    if numel(coordFlags)==4
                        obj.hMotorZ.zeroSoft([false false coordFlags(4)]);
                    end
            end
            
            if tfRescaleStackZStartEndPos
                obj.stackZStartPos = obj.stackZStartPos-origZCoord;
                obj.stackZEndPos = obj.stackZEndPos-origZCoord;
            end
        end
        
        function zprvMotorPropSet(obj,prop,val)
            if ~isempty(obj.hMotor)
                obj.hMotor.(prop) = val;
            else
                obj.zprvMotorThrowNoMotorWarningIfMdlInitialized();
            end
        end
        
        function zprvMotorZPropSet(obj,prop,val)
            if ~isempty(obj.hMotorZ)
                obj.hMotorZ.(prop) = val;
            else
                obj.zprvMotorThrowNoMotorZWarning();
            end
        end
        
        function zprvMotorThrowNoMotorErrIfMdlInitialized(obj)
            if obj.mdlInitialized
                error('SI4:noMotor','Motor operation attempted, but no motor is configured.');
            end
        end
        
        function zprvMotorThrowNoMotorWarningIfMdlInitialized(obj)
            if obj.mdlInitialized
                warnst = warning('off','backtrace');
                warning('SI4:noMotor','Motor operation attempted, but no motor is configured.');
                warning(warnst);
            end
        end
        
        function zprvMotorThrowNoMotorZWarning(obj) %#ok<MANU>
            warnst = warning('off','backtrace');
            warning('SI4:noMotorZ','There is no secondary motor.');
            warning(warnst);
        end
        
        function zprvMotorErrorCbk(obj,src,evt) %#ok<INUSD>
            if obj.isLive()
                fprintf(2,'Motor error occurred. Aborting acquisition.\n');
                obj.abort();
            end
        end
        
    end
    
    
    
    %% HIDDEN METHODS (Misc)
    methods (Hidden)
        
        function zprvClearExtTrigTimer(obj)
            if ~isempty(obj.triggerExtTrigTimer) && isvalid(obj.triggerExtTrigTimer)
                stop(obj.triggerExtTrigTimer)
                delete(obj.triggerExtTrigTimer)
            end
        end
        
        function zprvUserFunctionsConfigureListeners(obj,listenerProp,newUserFcnInfo)
            % Configure listeners for user functions.
            % listenerProp: property containing listeners
            % newUserFcnInfo: user function info structs
            %
            % The backend of user functions is implemented using arrays of
            % listener objects that correspond precisely (ie in a 1-1
            % manner) with the userFunction struct arrays. Whenever a
            % userFunction struct array is updated, the corresponding array
            % of listeners is updated accordingly.
            
            Nnew = numel(newUserFcnInfo);
            
            listnrs = obj.(listenerProp);
            
            if numel(listnrs) > Nnew
                % Delete all extra listeners
                for c = Nnew+1:numel(listnrs)
                    delete(listnrs{c});
                end
                listnrs = listnrs(1:Nnew);
            elseif numel(listnrs) < Nnew
                % Pad listener vector with empty array []
                listnrs{Nnew,1} = [];
            end
            assert(numel(listnrs)==Nnew);
            
            % Setup listeners
            for c = 1:Nnew
                if isempty(listnrs{c})
                    listnrs{c} = obj.addlistener(newUserFcnInfo(c).EventName,...
                        @(src,evt)obj.zprvUserFunctionsGenericCallback(newUserFcnInfo(c),src,evt));
                else
                    listnrs{c}.EventName = newUserFcnInfo(c).EventName;
                    listnrs{c}.Callback = @(src,evt)obj.zprvUserFunctionsGenericCallback(newUserFcnInfo(c),src,evt);
                end
                listnrs{c}.Enabled = logical(newUserFcnInfo(c).Enable);
            end
            
            obj.(listenerProp) = listnrs;
        end
        
        function zprvUserFunctionsGenericCallback(obj,userFcnInfo,src,evt) %#ok<MANU>
            feval(userFcnInfo.UserFcnName,src,evt,userFcnInfo.Arguments{:});
        end
        
        
        
        function zprvResetHome(obj)
            %Reset home motor/fastZ/beam positions/powers
            
            obj.acqMotorPositionStackStart = [];
            obj.acqBeamPowersStackStart = [];
            obj.fastZHomePosition = [];
            %obj.acqBeamLengthConstants = [];  % (Beam-idxed) Actual Lzs used during acq. These Lz vals are *always* used during acq; they will be inf for beams that do not have power correction.
        end
        
        function zprvGoHome(obj)
            %Go to home motor/fastZ/beam positions/powers, as applicable
            
            if ~isempty(obj.acqMotorPositionStackStart)
                obj.zprvSetInternal('motorPosition', obj.acqMotorPositionStackStart);
            end
            if ~isempty(obj.acqBeamPowersStackStart)
                obj.zprvSetInternal('beamPowers', obj.acqBeamPowersStackStart);
            end
            if ~isempty(obj.fastZHomePosition)
                obj.hFastZ.moveCompleteAbsolute([nan nan obj.fastZHomePosition]);
            end
        end
        
        function tf = zprvValidateLoggingFile(obj)
            
            import most.idioms.*
            
            %TODO: Find ALL files using existing filestem, so that all can be cleared (useful for file chunkking)
            
            fileName = obj.loggingFullFileName;
            
            tf = false;
            
            %Check that file save path is specified -- provide opportunity if not
            if isempty(obj.loggingFilePath)
                button = questdlg('A Save path has not been selected.','Do you wish to:','Select New Path','Use Current','Cancel','Select New Path');
                if strcmp(button,'Select New Path')
                    obj.setSavePath();
                    if isempty(obj.loggingFilePath) %User may cancel
                        return;
                    end
                elseif strcmp(button,'Use Current')
                    obj.loggingFilePath = pwd();
                elseif strcmp(button,'Cancel')
                    return;
                end
                
            end
            
            %Check that filename stem is specified -- provide opportunity if not
            if isempty(obj.loggingFileStem)
                answer  = inputdlg('Select base name','Choose Base Name for Acquisition',1,{''});
                if ~isempty(answer)
                    try
                        obj.loggingFileStem = answer{1};
                    catch %#ok<CTCH>
                        errordlg('Invalid filename stem specified. Cancelling.');
                        return;
                    end
                else
                    return;
                end
            end
            
            %Check that file doesn't already exist -- provide opportunity to fix
            if exist(fileName,'file')
                
                button = questdlg(sprintf('File Already Exists - ''%s''.  Do you wish to:', fileName), ...
                    'Overwrite warning!',...
                    'Update Filename','Overwrite', 'Cancel', 'Update Filename');
                
                drawnow;  %Mysteriously required to avoid subsequent motor error. Neither drawnow expose/update works -- need full drawnow.
                
                switch button
                    case 'Overwrite'
                        %Clear out old data in advance -- this is required if to save during acquisition
                        recycleFile(fileName);
                        tf = true;
                    case 'Update Filename'
                        
                        answer = inputdlg({'Basename:' 'Acquisition Number:'}, 'Update Basename and/or Acq Number', 1, {obj.loggingFileStem num2str(obj.loggingFileCounter+1)});
                        drawnow; %Mysteriously required to avoid subsequent motor error. Neither drawnow expose/update works -- need full drawnow.
                        
                        try
                            obj.loggingFileStem = answer{1};
                            obj.loggingFileCounter = round(str2double(answer{2}));
                        catch %#ok<CTCH>
                            errordlg('Invalid file stem or counter specified. Cancelling acquisition');
                            return;
                        end
                        
                        if exist(obj.loggingFullFileName,'file')
                            errordlg('Newly specified file stem/number also already exists! Cancelling acquisition.');
                            tf = false;
                            return;
                        end
                        
                        tf = true;
                        
                    case 'Cancel'
                        %do nothing
                end
            else
                tf = true;
            end
            
        end
        
        function zprvUpdateSecondsCounter(obj)
            
            switch obj.acqState
                case 'focus'
                    obj.secondsCounter = etime(clock, obj.triggerClockTimeFirstVec);
                    
                otherwise
                    if isinf(obj.triggerTime)
                        if ~isempty(obj.secondsCounter)
                            obj.secondsCounter = [];
                            
                            if obj.triggerNextTrigUsed && ~obj.triggerNextTrigOnly
                                if length(obj.triggerTimes) <= 1
                                    terminal = obj.triggerStartTrigTerminal;
                                else
                                    terminal = sprintf('PFI%d',obj.triggerNextTrigSrc);
                                end
                            else
                                terminal = obj.triggerStartTrigTerminal;
                            end
                            fprintf(2,'WARNING(%s): Failed to record trigger time at start of current acquisition file. Check start/next trigger connection on terminal ''%s'' of the primaryDeviceID specified in Machine Data File\n',class(obj),terminal);
                        end
                        return;
                    end
                    
                    switch obj.secondsCounterMode
                        case 'up'
                            %obj.secondsCounter = etime(clock, obj.triggerTimeLast);
                            obj.secondsCounter = toc(obj.triggerTimeLast);
                        case 'down'
                            %obj.secondsCounter =  obj.loopRepeatPeriod - etime(clock, obj.triggerTimeLast);
                            obj.secondsCounter = obj.loopRepeatPeriod - toc(obj.triggerTimeLast);
                    end
            end
            
        end
        
        function zprvUpdateStatusStringBasedOnAcqState(obj,acqState)
            switch acqState
                case 'idle'
                    obj.statusString = 'Acquisition idle';
                case 'focus'
                    obj.statusString = 'Acquiring (focus) ...';
                case 'grab'
                    obj.statusString = 'Acquiring (grab) ...';
                case 'loop'
                    obj.statusString = 'Acquiring (loop) ...';
                case 'loop_wait'
            end
        end
        
        function zprvResetTriggerTimes(obj)
            obj.triggerClockTimeFirstVec = datevec(1);
            obj.triggerTimes = -inf;
            obj.triggerFrameStartTimes = -inf;
            
            obj.triggerTimeLast = [];
            
            obj.loggingFrameCount = 0;
            obj.loggingFrameTimeLast = 0;
            obj.loggingFrameBreaks = [];
        end
        
        function zprvResetAcqCounters(obj,resetLoop)
            %resetLoop: <Default=true> If true, reset Loop and total acqFramesDone counters
            
            obj.acqFramesDone = 0;
            obj.stackSlicesDone = 0;
            obj.scanFramesStarted = 0;
            obj.fastZVolumesDone = 0;
            
            obj.triggerFrameNumber = 1;
            
            obj.loggingFileSubCounter = [];
            
            if nargin < 2 || resetLoop
                %                obj.acqFramesDoneOffset = 0;
                %                obj.acqFramesDoneTotal = 0;
                obj.acqFramesDoneTotal = 0;
                obj.loopRepeatsDone = 0;
            end
        end
        
        function zprvResetBuffersIfFocusing(obj)
            %Handle case where buffer reset should occur only during an ongoing Focus
            if strcmpi(obj.acqState,'focus')
                obj.acqFramesDone = 0;
                %obj.acqFramesDoneTotal = 0;
                obj.zprvResetBuffers();
            else
                return;
            end
        end
        
        function zprvResetBuffers(obj)
            
            obj.acqFrameBuffer = cell(obj.acqFrameBufferLength,1);
            
            if obj.displayRollingAverageFactor > 1
                obj.displayRollingBuffer = zeros(obj.scanLinesPerFrame,obj.scanPixelsPerLine,length(obj.channelsDisplay),'double');
                obj.displayRollingBuffer = repmat({obj.displayRollingBuffer},numel(obj.displayFrameBatchSelection),1);
            else
                obj.displayRollingBuffer = [];
            end
        end
        
        
        function zprvAssertIdle(obj,propName)
            assertion = obj.internalSetFlag || strcmpi(obj.acqState,'idle');
            try
                if nargin == 2
                    assert(assertion,'The property ''%s'' can only be set when in idle state',propName);
                else
                    assert(assertion,'The specified property can only be set when in idle state');
                end
            catch ME
                ME.throwAsCaller();
            end
        end
        
        function zprvAssertFocusOrIdle(obj,propName)
            assertion = obj.internalSetFlag || ismember(obj.acqState,{'idle' 'focus'});
            try
                if nargin == 2
                    assert(assertion,'The property ''%s'' can only be set when focusing or idle',propName);
                else
                    assert(assertion,'The specified property can only be set when focusing or idle');
                end
            catch ME
                ME.throwAsCaller();
            end
        end
        
        function zprvAssertNoAcq(obj,propName)
            assertion = obj.internalSetFlag || ismember(obj.acqState,{'idle' 'loop_wait'});
            try
                if nargin == 2
                    assert(assertion,'The property ''%s'' can only be set when in idle state',propName);
                else
                    assert(assertion,'The specified property can only be set when in idle state');
                end
            catch ME
                ME.throwAsCaller();
            end
        end
        
        function zprvSetInternal(obj,propName,val)
            isf  = obj.internalSetFlag;
            obj.internalSetFlag = true;
            ME = [];
            try
                obj.(propName) = val;
            catch MEtemp
                ME = MEtemp;
            end
            obj.internalSetFlag = isf;
            
            if ~isempty(ME)
                ME.rethrow();
            end
        end
        
        function hTask = zprvDaqmxTask(obj,taskName)
            import dabs.ni.daqmx.*
            
            hTask = Task(taskName);
            
            if isempty(obj.hAllTasks)
                obj.hAllTasks = hTask;
            else
                obj.hAllTasks(end+1) = hTask;
            end
        end
        
        
        function zprvDaqmxStart(obj,hTasks)
            %Starts one or more DAQmx Tasks and adds it to the 'acquisition' list
            
            for i=1:length(hTasks)
                hTask = hTasks(i);
                
                if isempty(obj.hAcqTasks)
                    obj.hAcqTasks = hTask;
                else
                    if ~ismember(hTask,obj.hAcqTasks)
                        obj.hAcqTasks(end+1) = hTask;
                    end
                end
            end
            hTasks.stop();
            hTasks.start();
        end
        
        %         function zprvDaqmxRefresh(obj)
        %             %Refresh all DAQmx output Tasks with data to use on next start
        %
        %             obj.zprvBeamsWriteBuffer(); %hBeams Task
        %
        %         end
        
        
        function zprvArmTrigCallback(obj,armNext)
            
            if nargin < 2
                armNext = false;
            end
            
            if ~armNext && obj.triggerExtStartTrigUsed
                obj.hTriggerCallbackCtr.set('sampClkSrc',sprintf('PFI%d',obj.triggerStartTrigSrc),'sampClkActiveEdge',zlclEncodeTriggerEdge(obj.triggerStartTrigEdge));
                obj.triggerLastArmed = 'start';
            elseif armNext && obj.triggerNextTrigUsed
                obj.hTriggerCallbackCtr.set('sampClkSrc',sprintf('PFI%d',obj.triggerNextTrigSrc),'sampClkActiveEdge',zlclEncodeTriggerEdge(obj.triggerNextTrigEdge));
                obj.triggerLastArmed = 'next';
            else
                obj.hTriggerCallbackCtr.set('sampClkSrc',sprintf('PFI%d',obj.mdfData.trigSelfTrigDestinationTerminal),'sampClkActiveEdge','DAQmx_Val_Rising');
                obj.triggerLastArmed = 'self';
            end
            
        end
        
    end
    
    
end

%% LOCAL FUNCTIONS

%VI: Should relocate (a much more polished version) to a Dabs utility -- or perhaps create a Dabs container
%Looks up the value in N'th column after finding row whose first N-1 columns match tupleMapKey
function [val,idx] = zlclTupleMapLookup(tupleMap,tupleMapKey)
val = [];
idx = [];
for i=1:size(tupleMap,1)
    if isequal(tupleMap(i,1:end-1),tupleMapKey)
        idx = i;
        val = tupleMap{i,end};
        break;
    end
end
end

% function m = zlclAverageFrames(c)
% cumsum = double(0);
% for i=1:length(c)
%     cumsum = cumsum + double(c{i});
% end
% m = cumsum/length(c);
% end

% VI: Sometimes a quite-clean calibration will fail this test -- we
% should probably prevent warning in this case. Perhaps warning is never
% needed anymore?
% AL: Clean runs should not fail this test anymore. Is nonmonotonicity a
% failure condition? PR: ...
function x = zlclMonotonicize(x)
assert(isnumeric(x)&&isvector(x));
d = diff(x);
if sum(d(:)) < 0; d = -d; end; % PR2014-09-22 also account for monotonically decreasing stuff
if any(d<=0)
    disp('Warning: SI4:zlclMonotonicize, vector not monotonically increasing.');
end
end

function zlclAddQuantityAnnotations(ax,xPos,yPos,lbls,qtys,varargin)
axes(ax); %#ok<MAXES>

for c = 1:numel(lbls)
    h = text(xPos,yPos,sprintf('%s: ',lbls{c}),'HorizontalAlignment','right',varargin{:});
    qty = qtys{c};
    if isnumeric(qty)
        formatStr = '%.2f';
    else
        formatStr = '%s';
    end
    text(xPos,yPos,sprintf(formatStr,qty),'HorizontalAlignment','left',varargin{:});
    ext = get(h,'Extent');
    dyPos = ext(end);
    yPos = yPos - dyPos;
end

end

function evs = zlclInitUserFunctionsEvents()
mc = ?scanimage.SI4;
allEvents = mc.Events;
tf = cellfun(@(x)isequal(x.DefiningClass,mc)&&strcmp(x.NotifyAccess,'protected'),allEvents);
evs = allEvents(tf);
evs = cellfun(@(x)x.Name,evs,'UniformOutput',false);
end

function evs = zlclInitUserFunctionsUsrOnlyEvents()
mc = ?scanimage.SI4;
allEvents = mc.Events;
tf = cellfun(@(x)isequal(x.DefiningClass,mc)&&strcmp(x.NotifyAccess,'private'),allEvents);
evs = allEvents(tf);
evs = cellfun(@(x)x.Name,evs,'UniformOutput',false);
end

function val = zlclEncodeTriggerEdge(edge)
switch lower(edge)
    case 'rising'
        val = 'DAQmx_Val_Rising';
    case 'falling'
        val = 'DAQmx_Val_Falling';
end
end


function fname = zlclConstructLoggingFullFileName(filePath,fileStem,fileCounter,fileSubCounter)

if isempty(fileStem)
    fname = '';
else
    fname = fileStem;
end

if nargin >= 3 && ~isempty(fileCounter)
    fname = [fname '_' sprintf('%03d',fileCounter)];
end

if nargin == 4 && ~isempty(fileSubCounter)
    fname = [fname '_' sprintf('%03d',fileSubCounter)];
end

fname = fullfile(filePath,[fname '.tif']);

end

function x = zlclVerifyScalarIntegerOrInf(x)
assert(isscalar(x)&&isnumeric(x)&&(most.idioms.isIntegerValued(x)||isinf(x)),...
    'Expected scalar integer or inf.');
end


function s = zlclInitPropAttributes()
%At moment, only application props, not pass-through props, stored here -- we think this is a general rule
%NOTE: These properties are /ordered/..there may even be cases where a property is added here for purpose of ordering, without having /any/ metadata.
%       Properties are initialized/loaded in specified order.
%

s.focusDuration = struct('Range',[1 inf]);

s.beamFillFracAdjust = struct('Range',[-9 9],'Attributes','scalar');
s.onTimeAdjust = struct('Range',[-20 20],'Attributes','scalar');
s.timingAdjustPockels = struct('Range',[-8 8],'Attributes','scalar');
s.beamPowers = struct('Attributes',{{'nonnegative' 'finite' 'vector'}},'AllowEmpty',1);
s.beamPowerLimits = struct('Attributes',{{'nonnegative' 'finite' 'vector'}},'AllowEmpty',1);
s.beamFlybackBlanking = struct('Classes','binaryflex');
s.betweenFrames = struct('Classes','binaryflex');
s.beamDirectMode = struct('Classes','binaryflex','Attributes','scalar');
s.beamPowerUnits = struct('Options',{{'percent' 'milliwatts'}});
s.beamLengthConstants = struct('Attributes',{{'positive' 'vector'}},'AllowEmpty',1);
s.beamPzAdjust = struct('Classes','binarylogical','Attributes','vector','AllowEmpty',1);

s.fastCfgCfgFilenames = struct('Classes','char','List',scanimage.SI4.fastCfgNumConfigs,'AllowEmpty',1);
s.fastCfgAutoStartTf = struct('Classes','binaryflex','Attributes',{{'size',[scanimage.SI4.fastCfgNumConfigs 1]}});
s.fastCfgAutoStartType = struct('Options',{{'focus';'grab';'loop'}},'List',scanimage.SI4.fastCfgNumConfigs,'AllowEmpty',true);

% s.frameAveragingEnable = struct('Classes','binaryflex');
% s.frameAveragingNumFrames = struct('Attributes','integer','Range',[1 inf]);

s.frameDecimationFactor = struct('Attributes',{{'positive' 'integer'}});
s.lineScan_delay1 = struct('Range',[0 25],'Attributes','scalar');
s.lineScan_delay2 = struct('Range',[30 90],'Attributes','scalar');
s.framerate_user = struct('Range',[0.01 300],'Attributes','scalar'); % a framerate over ca. 300 will require smoothed sawtooth scanning
s.framerate_user_check = struct('Classes','binaryflex');
s.scanForceSquarePixelation = struct('Classes','binaryflex');
s.scanForceSquarePixel = struct('Classes','binaryflex');
s.scanForceSquarePixelation_ = struct('DependsOn',{{'scanForceSquarePixelation' 'scanAngleMultiplierSlow'}});
s.scanForceSquarePixel_ = struct('DependsOn',{{'scanForceSquarePixel' 'scanAngleMultiplierSlow'}});
s.scanFOVAngularRangeFast = struct('Classes','numeric');
s.scanFOVAngularRangeSlow = struct('Classes','numeric');
s.scanMode = struct('Classes','string');
s.scanPixelsPerLine = struct('Attributes',{{'positive' 'integer'}},'Options',2.^(4:12)');
s.xCorrChannel = struct('Classes','string');
s.scanLinesPerFrame = struct('Attributes',{{'positive' 'integer'}});
s.scanMinZoomFactor = struct('Range',[1 999]);
s.scanZoomFactor = struct('Range',[1 999]);
s.scanPhase = struct('Range',[0 255],'Attributes',{{'integer' 'scalar'}});
% s.scanPhaseFine = struct('Range',[-127 128],'Attributes',{{'integer' 'scalar'}});
s.scanPhaseMap = struct('Classes','containers.Map');
s.scanPhaseFineMap = struct('Classes','containers.Map');
s.scanLinePeriod = struct('Attributes','positive');

s.showMeanLive =  struct('Classes','binaryflex','Attributes','scalar');
s.maxValueShow = struct('Attributes','scalar');
s.meanValueShow = struct('Attributes','scalar');

s.extClockEdge = struct('Classes','binaryflex','Attributes','scalar');
s.extClockLevel = struct('Range',[0 99],'Attributes','scalar');

s.scanFillFraction = struct('Range',[0 0.95],'Attributes','scalar');
s.scanFillFractionSpatial = struct('DependsOn','scanFillFraction');
s.scanPixelTimeStats = struct('DependsOn',{{'scanFillFraction','scanPixelsPerLine'}});
s.scanPixelTimeMean = struct('DependsOn','scanPixelTimeStats');
s.scanPixelTimeMaxMinRatio = struct('DependsOn','scanPixelTimeStats');
s.scanFramePeriod = struct('DependsOn',{{'scannerPeriodStore' 'scanMode' 'scanLinesPerFrame' 'scanZoomFactor' 'scanAngleMultiplierSlow'}});
s.scanFrameRate = struct('DependsOn','scanFramePeriod');
s.scanAngleMultiplierSlow = struct('Attributes',{{'nonnegative' '<=' 1}}); %TODO: Support linescan (value=0)


s.stackNumSlices = struct('Attributes',{{'positive' 'integer' 'finite'}});
s.stackZStepSize = struct('Attributes','scalar');
s.stackZStartPos = struct('Attributes','scalar');
s.stackZEndPos = struct('Attributes','scalar');
%s.stackStartPower (no attribs)
%s.stackEndPower (no attribs)
s.stackUseStartPower = struct('Classes','binaryflex','Attributes','scalar');
s.stackUserOverrideLz = struct('Classes','binaryflex','Attributes','scalar');
s.stackReturnHome = struct('Classes','binaryflex','Attributes','scalar');
s.stackStartCentered = struct('Classes','binaryflex','Attributes','scalar');

%s.channelsActive = struct('Classes','numeric','Attributes',{{'vector','integer'}},'AllowEmpty',1);
s.channelsDisplay = struct('Classes','numeric','Attributes',{{'vector','integer'}},'AllowEmpty',1);
s.channelsSave = struct('Classes','numeric','Attributes',{{'vector','integer'}},'AllowEmpty',1);
s.channelsInvert = struct('Classes','numeric','Attributes',{{'vector','integer'}},'AllowEmpty',1);
s.channelsMergeColor = struct('Options',{{'green' 'red' 'blue' 'gray' 'none'}},'List','fullVector');
s.channelsMergeEnable = struct('Classes','binaryflex','Attributes','scalar');
s.channelsMergeFocusOnly = struct('Classes','binaryflex','Attributes','scalar');
s.channelsInputRange = struct('Options','channelsInputRangeValues','List','fullVector');
s.channelsLUT = struct('Attributes',{{'finite' 'nonscalar'}}); %TODO: Should specify Range in terms of channelsLUTRange property, with 'prop replacement'
s.channelsSubtractOffset = struct('Classes','binaryflex','Attributes','vector','AllowEmpty',1);
s.channelsAutoReadOffsets = struct('Classes','binaryflex','Attributes','scalar');

s.loggingEnable = struct('Classes','binaryflex','Attributes','scalar');
s.loggingFilePath = struct('Classes','string','AllowEmpty',1);
s.loggingFileStem = struct('Classes','string','AllowEmpty',1);
s.loggingFileCounter = struct('Attributes',{{'positive' 'integer'}},'AllowEmpty',1);
s.loggingFileSubCounter = struct('Attributes','integer','AllowEmpty',1);
s.loggingFramesPerFile = struct('Attributes',{{'positive' 'integer'}},'CustomValidateFcn',@zlclVerifyScalarIntegerOrInf);
s.autoconvert = struct('Classes','binaryflex','Attributes','scalar');
s.focusSave = struct('Classes','binaryflex','Attributes','scalar');
s.autoscaleSavedImages = struct('Classes','binaryflex','Attributes','scalar');
s.savedBitdepth = struct('Classes','binaryflex','Attributes','scalar');

s.write2RAM = struct('Classes','binaryflex','Attributes','scalar');
s.offlineAveraging = struct('Classes','binaryflex','Attributes','scalar');

s.ATnbslices = struct('Attributes',{{'positive' 'integer' 'finite'}});
s.ATzrange = struct('Attributes',{{'scalar','positive'}});
s.ATnbframes = struct('Attributes',{{'positive' 'integer' 'finite'}});
s.ATduringFocusing = struct('Classes','binaryflex','Attributes','scalar');

s.delayedChannelsOn = struct('Classes','binaryflex','Attributes','scalar');
s.nbDelayedChannels = struct('Classes','string');

s.loggingFramesPerFileLock = struct('Classes','binaryflex','Attributes','scalar');

s.loopNumRepeats = struct('Attributes',{{'positive' 'integer'}},'CustomValidateFcn',@zlclVerifyScalarIntegerOrInf);
s.loopRepeatPeriod = struct('Attributes','positive');

s.motorMoveTimeout = struct('Attributes','positive');
s.motorFastMotionThreshold = struct('Attributes',{{'finite' 'positive'}});
s.motorPosition = struct('Classes',{{'numeric'}},'Attributes',{{'vector'}});
s.motorUserDefinedPositions = struct('Classes',{{'numeric'}},'Attributes',{{'real' 'vector'}},'AllowEmpty',1,'List','vector');
s.motorSecondMotorZEnable = struct('Classes','binaryflex','Attributes','scalar');

s.shutterDelay = struct('Attributes',{{'nonnegative' 'scalar' 'finite'}});
s.statusString = struct('Classes','string','AllowEmpty',1);

s.triggerStartTrigSrc  = struct('Range',[0 16], 'Attributes', 'integer','AllowEmpty',1);
s.triggerStartTrigEdge = struct('Options',{{'rising' 'falling'}});
s.triggerNextTrigSrc = struct('Range',[0 16], 'Attributes', 'integer','AllowEmpty',1);
s.triggerNextTrigEdge = struct('Options',{{'rising' 'falling'}});
s.triggerNextTrigMode = struct('Options',{{'advance' 'arm'}});
s.triggerExtTrigEnable = struct('Classes','binaryflex','Attributes','scalar');
s.triggerExtStartTrigTimeout = struct('Attributes','positive');
s.triggerExtStartTrigPreScan = struct('Classes','binaryflex','Attributes','scalar');
s.triggerMaxLoopInterval = struct('Options',[42.95; 214.75; 42950]);
s.triggerMaxLoopIntervalFrames = struct('Attributes',{{'finite' 'positive' 'scalar' 'even'}});

% These three props have a complex, custom validation.
%s.userFunctionsCfg
%s.userFunctionsUsr
%s.userFunctionsOverride

s.mergeAlign = struct('Classes','binaryflex','Attributes','scalar');
s.mergeshift = struct('Range',[-20 20], 'Attributes', 'integer');

s.usrPropListCurrent = struct('Classes','string','List','vector');

s.acqDebug = struct('Classes','binaryflex','Attributes','scalar');
s.acqNumFrames = struct('Attributes',{{'positive' 'integer'}});
s.acqNumAveragedFrames = struct('Attributes',{{'positive' 'integer' 'finite'}});
s.acqFrameBufferLengthMin = struct('Attributes',{{'integer' 'nonnegative' 'finite'}});

s.displayShowCrosshair = struct('Classes','binaryflex','Attributes','scalar');
s.displayRollingAverageFactor = struct('Attributes',{{'positive' 'integer' 'finite'}});
s.displayRollingAverageFactorLock = struct('Classes','binaryflex','Attributes','scalar');
s.displayFrameBatchFactor = struct('Attributes',{{'positive' 'integer' 'finite'}});
s.displayFrameBatchSelection = struct('Attributes',{{'vector' 'positive' 'integer' 'finite'}});
s.displayFrameBatchSelectLast = struct('Classes','binaryflex','Attributes','scalar');
s.displayFrameBatchFactorLock = struct('Classes','binaryflex','Attributes','scalar');

s.triggerOut = struct('Classes','binaryflex','Attributes','scalar');
s.triggerOutDelay = struct('Range',[0 20],'Attributes','scalar');
s.triggerOutDuration = struct('Range',[0.001 100],'Attributes','scalar');

s.pmtGain = struct('Attributes',{{'nonnegative' 'vector' 'finite' 'row'}},'Size','pmtNumPMTs');
s.pmtEnable = struct('Classes','binaryflex','Attributes',{{'vector' 'row'}},'Size','pmtNumPMTs');

s.fastZImageType = struct('Options',{{'XY-Z' 'XZ' 'XZ-Y'}});
s.fastZScanType = struct('Options', {{'step' 'sawtooth'}});
s.fastZSettlingTime = struct('Attributes','nonnegative');
s.fastZPeriod = struct('Attributes', 'nonnegative');
s.fastZNumVolumes = struct('Attributes',{{'positive' 'integer' 'finite'}});
s.fastZUseAOControl = struct('Classes','binaryflex','Attributes','scalar');
s.fastZFramePeriodAdjustment = struct('Range',[-5000 5000]);
s.fastZNumDiscardFrames = struct('DependsOn',{{'fastZNumVolumes' 'acqNumFrames' 'stackNumSlices' 'fastZSettlingTime' 'scanFrameRate' 'fastZDiscardFlybackFrames'}});
s.fastZEnable = struct('Classes','binaryflex','Attributes','scalar');
s.exec_after = struct('Classes','binaryflex','Attributes','scalar');
s.offset_directly = struct('Classes','binaryflex','Attributes','scalar');
s.pockelsZ = struct('Classes','binaryflex','Attributes','scalar'); % PR2015-10
s.pockelsZoffset = struct('Range',[0 1.5],'Attributes','scalar'); % PR2015-10

s.leftbias = struct('Range',[-75 75],'Attributes','scalar'); % PR2016-03
s.topbias = struct('Range',[-0.2 0.2],'Attributes','scalar'); % PR2016-03

s.fastZAllowLiveBeamAdjust = struct('Classes','binaryflex','Attributes','scalar');

s.fastz_cont_amplitude = struct('Range',[0.0 9.5],'Attributes','scalar'); % PR2015-07-08
s.fastz_cont_nbplanes = struct('Attributes',{{'positive' 'integer' 'finite'}});
s.fastz_step_settlingtime =  struct('Range',[0 1000],'Attributes','scalar');
s.fastz_step_stepsize = struct('Range',[0 10],'Attributes','scalar');
s.fastz_step_nbplanes = struct('Attributes',{{'positive' 'integer' 'finite'}});

s.highVal =  struct('Range',[-10 10],'Attributes','scalar');
s.lowVal = struct('Range',[0 500],'Attributes',{{'integer' 'finite'}});
s.dutyCycleZ = struct('Range',[2.5 40],'Attributes','scalar'); % step duration

s.maxFrameEventRate = struct('Attributes',{{'scalar' 'positive' 'finite'}});
s.frameAcqFcnDecimationFactor = struct('Attributes',{{'scalar' 'integer' '>=' 1 'finite'}},'AllowEmpty',1);

s.galvoEnable = struct('Classes','binaryflex','Attributes','scalar');
%s.galvoROIAngles = struct('Attributes',{{'ncols' 2 'finite'}},'AllowEmpty',1);
s.galvoAngle2LSMAngleFactor = struct('Attributes',{{'positive' 'scalar' 'finite'}});

s.mroiParams = struct('Classes','struct','AllowEmpty',1); % Allow empty
s.mroiComputedParams = struct('Classes','struct','AllowEmpty',1);
s.mroiEnabled = struct('Classes','binaryflex','Attributes','scalar');

end
