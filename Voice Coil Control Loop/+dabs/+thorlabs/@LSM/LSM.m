classdef LSM < dabs.thorlabs.private.ThorDevice
    %LSM Class encapsulating Laser Scanning Microscopy Devices offered by Thorlabs
    
    
    %% NOTES
    %
    %   TODO: (VI062511) Add framePeriodEstimate dependent property which estimates frame period at current settings
    %   TODO: Currently setLoggingProperty() allows changes to loggingHeadnumChannelsAvailableerString & loggingFileName during live acquisition (though not recommended). However, this is problematic for loggingHeaderString -- a change to just that property would start the current file over wt
    %   TODO: Use some parsing scheme to create and fill-in values for class-added properties listing out options for triggerMode (e.g. 'triggerModes'), and other enumerated properties.
    
    %   TODO: Move accessDeviceCheckoutList to ThorDevice (centralized store of Dabs.Devices)
    
    %% ABSTRACT PROPERTY REALIZATIONS (dabs.thorlabs.private.ThorDevice)
    properties (Constant, Hidden)
%         deviceTypeDescriptorSDK = 'Camera'; %Descriptor used by SDK for device type in function calls, e.g. 'Device', 'Camera', etc.
        prop2ParamMap=zlclInitProp2ParamMap(); %Map of class property names to API-defined parameters names
    end
    
    
    %% ABSTRACT PROPERTY REALIZATIONS (most.APIWrapper)    
    
    %Following MUST be supplied with non-empty values for each concrete subclass
    properties (Constant, Hidden)
        apiPrettyName='Thorlabs LSM';  %A unique descriptive string of the API being wrapped
        apiCompactName='ThorlabsLSM'; %A unique, compact string of the API being wrapped (must not contain spaces)
        
        %Properties which can be indexed by version
        apiDLLNames = 'ThorConfocal'; %Either a single name of the DLL filename (sans the '.dll' extension), or a Map of such names keyed by values in 'apiSupportedVersionNames'
        %apiHeaderFilenames = { 'LSM_SDK_MOD.h' 'LSM_SDK_MOD.h' 'LSM_SDK_MOD.h' 'LSM_SDK.h' 'LSM_SDK.h' 'LSM_SDK.h' 'LSM_SDK.h' 'LSM_SDK.h'}; %Either a single name of the header filename (with the '.h' extension - OR a .m or .p extension), or a Map of such names keyed by values in 'apiSupportedVersionNames'
        apiHeaderFilenames = 'ThorConfocal_proto.m';
        
    end
    
     %% VISIBLE PROPERTIES
    
    %PDEP properties corresponding directly to 'params' defined by API
    properties (SetObservable, GetObservable)

        alazarClockLevel = 57;
        clockFallOrRise = 0; % CLOCK_EDGE_RISING = 0;
        
        
        multiChanAVG = 0; % for imaging using delayed acquisition in multiple channels (currently using ch 1 and 3 or 1-4 for values of 2 and 4
        
        CRSdisable;
        CRScmd;
        PRgalvo;
        frameClock2;
        frameClock;
        PRgalvoPark
        PRgalvoEnable;
        
        triggerMode; %One of {'SW_SINGLE_FRAME', 'SW_MULTI_FRAME', 'SW_FREE_RUN_MODE', 'HW_SINGLE_FRAME', 'HW_MULTI_FRAME_TRIGGER_FIRST'}
        triggerTimeout=inf; %Time, in seconds, within which external start trigger is expected to arrive
        triggerFrameClockWithExtTrigger=true; %<Logical>If true, frame clock signal is generated when external (hardware) triggering is enabled. This adds some latency...
        multiFrameCount; %Number of frames to acquire when using triggerMode='SW_MULTI_FRAME' or 'HW_MULTI_FRAME_TRIGGER_FIRST'
        
        pixelsPerLine; %Number of pixels per line
        linesPerFrame; %Number of lines per frame
        fieldSize=255; %Value from 1-255 setting the field-size
        aspectRatioY; %Value which scales Y amplitude relative to fast X dimension amplitude. Value of 100 matches X dimension amplitude.
        areaMode; %One of {'SQUARE', 'RECTANGLE', 'LINE'}
        offsetX;
        offsetY;
        
        scanMode; %One of {'TWO_WAY_SCAN', 'FORWARD_SCAN', 'BACKWARD_SCAN'}
        bidiPhaseAlignment; %Value from -127-128 allowing bidi scan adjustment ('TWO_WAY_SCAN' mode)
        
        averagingMode; %One of {'AVG_NONE', 'AVG_CUMULATIVE'};
        averagingNumFrames; %Number of frames to average, when averagingMode = 'AVG_CUMULATIVE'
        dataMappingMode; %One of {'POLARITY_INDEPENDENT' 'POLARITY_POSITIVE' 'POLARITY_NEGATIVE'}
        
        inputChannelRange1; %One of the valid input ranges (e.g. 'INPUT_RANGE_20_MV')
        inputChannelRange2; %One of the valid input ranges (e.g. 'INPUT_RANGE_20_MV')
        inputChannelRange3; %One of the valid input ranges (e.g. 'INPUT_RANGE_20_MV')
        inputChannelRange4; %One of the valid input ranges (e.g. 'INPUT_RANGE_20_MV')
        
        clockSource=1; %<1=Internal, 2=External> Specifies clock source for synchronizing to laser pulse train rate
        clockRate=80e6; %Specify clock rate correpsonding to laser pulse train
        
        flybackScannerPeriods; %Number of scanner periods added to each frame, e.g. to allow for galvo (Y) flyback.
        flybackScannerPeriodsSetEnable; %Logical. If true, flybackScannerPeriods value can be set IF galvoEnable=False.
        
        galvoEnable;  %Logical. If true, LSM galvo (Y) mirror is scanned in synchrony with fast (X) resonant-scanned mirror. Setting to false allows line-scanning or independent control of the galvo Y mirror.        
        galvoChanEnable=1; %Logical. Unused at this time - leave value as True.
        
        captureWithoutScanner; %Logical. When true, acquisition occur without scanner being activated. Useful for measuring input voltage offset values.
        
    end
    
    %PDEP properties created by this class
    properties (GetObservable,SetObservable)
        frameCount;          % Total number of frames that have been acquired by LSM (including those that may have been dropped during processing)
        framesAvailable;     % Number of frames currently available to to read from processed data queue, via getData()
        
        circBufferSize=4;  % size of the circular buffer in frames
        
        loggingFileName=''; %Full filename of logging file (but without path)
        loggingAveragingFactor=1; %Number of frames to average before writing to disk (decimating data stream)
        %         loggingFilePath;
        %         loggingFileName='lsm_data';
        %         loggingFileType='tif';  %One of {'tif' 'bin'} %TODO: Actually use this -- or eliminate it!
        
        frameEventDecimationFactor=1; %Decimation factor to use when generating frame acquired events
        
        channelsLogging; %Logical array of channels, of length numChannelsAvailable, indicating which are designated for logging to disk (when logging is enabled)
        channelsViewing; %Logical array of channels, of length numChannelsAvailable, indicating which are designated for access ('viewing') via getData() methods
        
        subtractChannelOffsets; %Logical array of N values, for each of the N numChannelsAvailable. True values indicate that last-measured offset value for that channel will be subtracted from input data, affecting both logged data and frames returned by getData()
        channelOffsets; %Array of N integer values contaning the last-measured offset values for each of the N numChannelsAvailable
    end
    
    
    properties
        % derived from the machine data file
        scanDevice;
        frameClockChannel;
        resScanChannel;
        disableResScan;
        galvoChannel;
        galvoTriggerChannel;
        lineClockChan;
        iLineClockChan;
        iLineClockTrig;
        iLineClockReceive;
        frameClock2Trig;
        frameClock2Chan;
        extFrameClockTerminal;
        
        focusSave = 0;
        framePeriodMeasuredMean=126.04*1e-6; % important if synchronization of the Pockels cell is desired to the frame clock
        galvoOffset = 0;
        beamCmdOutputRate = 5e5; % dummy value
        pockelsSamples = 40; % dummy value. determines how long the frame clock output enables the pockels cell modulation
        framerate_user_check;
        framerate_user;        
        lineScan_delay1;
        lineScan_delay2;
        iLineClock; % indirect lineclock = modified sync signal from the CRS
        lineClock; % dummy task replacing the sync signal from the CRS
        savefast = 1;
        loggingEnable;
        acqState = 'idle';
        scanLinesPerFrame = 512; % dummy value
        scanPixelsPerLine;
        framerate;
        scannerMaxAngularRange;
        scanAngleMultiplierSlow;
        galvoAngle2VoltageFactor;
        crsAngle2VoltageFactor;
        scanZoomFactor;
        
        channelsPerBoard;
        samplesPerRecord;
        startTickCount;
        transferTime_sec;
        recordsPerBuffer;
        updateInterval_sec;
        updateTickCount;
        buffersPerAcquisition;
        bytesPerBuffer;
        samplesPerBuffer;
        fid;
%         waitbarHandle;
        bufferTimeout_ms;
        buffers;
        galvoCmdOutputRate=5e5;
        bufferCount;
        ATSboardHandle;
        
        loggingAutoStart=false; %Flag specifying whether to automatically start logging on start()
        
        frameAcquiredEventFcn; %Function handle
        restartOnParamChange = true; %Logical. If true, any active scan is stopped/restarted on changes to an underlying LSM parameter defined by Thor API.  Setting to false allows property (parameter) changes to be batched up without multiple restarts. The method startAlreadyRunning() can be used to stop/restart an ongoing scan, as needed following such a batch of property/param changes.
    end
    
    %Dependent properties part of public API
    properties (Dependent)
        loggingFrameDelayMax; %Max value of loggingFrameDelay allowed at current settings
        signedData; %Logical indicating whether image data is signed (true) or unsigned (false)
    end
    
    %Read-only
    properties
        framesGotten; %Number of frames retrieved since start of acquisition via getData() method
        
        state = 'idle'; %One of {'idle' 'armed' 'active' 'pointing'}
        logging = false; %Flag indicating whether file logging is currently occurring
    end
    
    
    %Constructor-initialized, read-only
    properties (SetAccess=protected)
        hPMTModule; %PMT module which /must/ be loaded for successful scanner operation
        numChannelsAvailable; %Number of input channels available for this scanner device
    end
    
    %% HIDDEN PROPERTIES
    
    %Hidden PDEP properties corresponding directly to 'params' defined by API
    properties (GetObservable,SetObservable,Hidden)
        channelsActive; %Array identifying which channels are active, e.g. 1, [1 2], etc.
        touchParameter; %Parameter that can be set to force Thor API to recognize a changed parameter on SetupAcquisition call, thereby restarting acq thread on StartAcquisition() call
        
    end
    
    %Hidden PDEP properties created by this class
    properties (GetObservable,SetObservable,Hidden)
        %         droppedFramesTotal;  % async thread MEX dropped frames (single frame buffer)
        %         droppedLogFramesTotal;  % loggng thread MEX dropped frames
        droppedFramesLast;
        droppedLogFramesLast;
        droppedProcessedFramesLast;
        
        frameTagEnable; %Logical. If true, frame tagging is used to identify each frame copied from the LSM.
        
        %Property must be hidden to avoid nested header string
        loggingHeaderString=''; %String containing header information to store as metadata in logging TIF file
    end
    
    properties (Hidden)
        verbose = false;
        loggingOpenModeString='wbn';   % the mode string passed to fopen when opening the log file
    end
    
    properties (SetAccess=protected, Hidden, Dependent)
        numChannelsActive; %Number of channels currently active
        loggingFullFileName;  % the complete path and file name of the file to write to, including extension
    end
    
    %Flag properties
    properties (SetAccess=protected,Hidden)
        paramChangeList={}; %Cell array of properties changed since last call to Thor API StartAcquisition() function
        loggingFileRolloverFlag=false;
        initialized = false;
        allowLogging=false; %Can only be set during start() method calls.
        offsetFrameDataLast; %Previously collected frame by readOffsets() method
    end
    
    properties (Constant, Hidden)       
        %Following are referred to by LSM MEX layer. Values are now Constant: frame tagging is now required for correct frame processing.
        loggingFrameTagEnable = true;
        loggingFrameTagOneBased = true; %If true, frame tags are converted to 1-based indexing
                
        CONFIG_BUFFER_PARAMS = {'pixelsPerLine' 'linesPerFrame' 'channelsLogging' 'channelsViewing' 'circBufferSize' 'loggingAveragingFactor' 'dataMappingMode' 'aspectRatioY' 'areaMode' 'subtractChannelOffsets'};
    end
    
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = LSM(varargin) % varargin is some DeviceID
            
            %Invoke superclass constructor
%             obj = obj@dabs.thorlabs.private.ThorDevice(varargin{:});
            obj = obj@dabs.thorlabs.private.ThorDevice(varargin);
            
            %Construct/identify (required) associated PMT object
            obj.hPMTModule = dabs.thorlabs.PMT();
            
            %Determine number of channels & initialize arrays of length equal to this number
            channelsActiveInfo = 1; %obj.paramInfoMap('channelsActive');
            obj.numChannelsAvailable = 3; %log(3 + 1)/log(2); %log(channelsActiveInfo.paramMax + 1)/log(2);
            obj.channelsLogging = [true; false(obj.numChannelsAvailable-1,1)];
            obj.channelsViewing = [true; false(obj.numChannelsAvailable-1,1)];
            obj.subtractChannelOffsets = false(obj.numChannelsAvailable,1);
            obj.channelOffsets = zeros(obj.numChannelsAvailable,1);
            
            %Activate frame-tagging, if available (Thor API 1.3 and later)
            if ~isempty(obj.frameTagEnable)
                obj.frameTagEnable = true;
            end
            
%             obj.initialize(); % does nothing at all 
        
        end
        
        function initializeHardware(obj)
            %% PR2014: initialize and configure the alazar board
            [boardHandle,result] = obj.PRinitializeAlazar();
            obj.ATSboardHandle = boardHandle;
            if ~result
                fprintf('Error: Alazar board configuration failed\n');
                return
            end
            %% PR2014: initialize and configure the NI DAQ board that drives the galvo
            result = obj.PRinitializeScanBoard();
            if ~result
                fprintf('Error: Galvo control DAQ board configuration failed\n');
                return
            end
             
%             Initialize MEX interface
%             obj.configureFrameAcquiredEvent('initialize'); %% 
%             obj.configureFrameAcquiredEvent('configBuffers');
            
            %Initialize flags
            obj.initialized = true;
            obj.paramChangeList = {''}; %Set to dummy value, so not empty
        end
        
        function delete(obj)
            if(strcmpi(obj.state,'active'))
                obj.stop();
            end            
            
            unloadlibrary ATSApi;
            clear ATSboardHandle
            
%             obj.configureFrameAcquiredEvent('destroy');
%             delete(obj.hPMTModule);            
        end
    end
    
    
   
    %% PROPERTY ACCESSS
    methods
        
        function val = get.numChannelsActive(obj)
            disp('Automatically set numChannelsActive to 2, PR2014-08-27');
%             val =  length(find(obj.channelsActive));
            val =  2;
        end
        
        function fName = get.loggingFullFileName(obj)
            [p,f,e] = fileparts(obj.loggingFileName);
            
            if isempty(p)
                p = pwd();
            end
            
            if isempty(e)
                e = '.tif';
            end
            
            if isempty(f)
                f = 'PetersDummyFile';
            end
            
            fName = fullfile(p,[f e]);
        end
        
        
        function val = get.loggingFrameDelayMax(obj)
%             val = round(obj.circBufferSize/2);
%             disp('dummy value for loggingFrameDelayMax()');
            val = 8192; % dummy value for loggingFrameDelayMax()
        end
        
        function val = get.signedData(obj)
%             switch obj.dataMappingMode
%                 case 'POLARITY_INDEPENDENT'
%                     val = false;
%                 case {'POLARITY_POSITIVE' 'POLARITY_NEGATIVE'}
%                     val = true;
%             end
%             disp('unused value retrieved, blubb, PR2014, via signedData()');
            val = false;
        end               
        
        function set.subtractChannelOffsets(obj,val)
            validateattributes(val,{'logical'},{'vector' 'numel' obj.numChannelsAvailable});
            obj.subtractChannelOffsets = val;
        end
        
        
        function set.loggingAutoStart(obj,val)
            assert(isscalar(val) && (islogical(val) || ismember(val,[0 1])),'Property ''loggingAutoStart'' must be a logical scalar');
            obj.loggingAutoStart = val;
        end
        
        function set.allowLogging(obj,val)
            val = logical(val);
            assert(isscalar(val),'Property ''allowLogging'' must be a scalar logical value');
            obj.allowLogging = val && any(obj.channelsLogging);
        end     
                
        function set.frameAcquiredEventFcn(obj,val)
            obj.frameAcquiredEventFcn = val;
            if(obj.initialized)
                obj.configureFrameAcquiredEvent('configCallback');
            end
        end
        
    end
    
    methods (Hidden)
        
        function val = getMEXProperty(obj,propName)
%             val = obj.configureFrameAcquiredEvent('get',propName);
            val = 0;
        end
        
        function val = getMultiFrameCount(obj)
%             val = obj.getParameterSimple('multiFrameCount');
%             if val >= intmax('int32')
%                 val = inf;
%             end
            val = inf;
        end
        
        function val = getInputChannelRange(obj,propName)
%             rawVal = obj.getParameterSimple(propName);
            
            %Convert raw (numeric) value to corresponding string
%             enumValMapMap = obj.accessAPIDataVar('enumValMapMap');
%             enumValMap = enumValMapMap('InputRange');
            
            val = 0;% enumValMap(rawVal);  %Converts to string corresponding to value
            
        end
        
        function val = getChannelsActive(obj)
            val = 0;
            %Unpack the scalar into a vector
%             scalarVal = obj.apiCall('GetParam', obj.paramCodeMap('channelsActive'),0);
%             val = find(fliplr(dec2bin(scalarVal,obj.numChannelsAvailable))==49);

        end
        
        %         function setChannelsActive(obj,val)
        %             %Pack vector value into a scalar
        %             obj.apiCall('SetParam', obj.paramCodeMap('channelsActive'), sum(2.^(val-1)));
        %
        %             %Dependencies
        %             obj.multiFrameCount = obj.multiFrameCount;
        %         end
        
        function setFrameEventDecimationFactor(obj,val)
%             if obj.initialized
%                 obj.configureFrameAcquiredEvent('configCallbackDecimationFactor');
%             end
        end
        
        function setLoggingProperty(obj,propName,val)
            assert(most.idioms.isstring(val),'The value of ''%s'' must be a string',propName);
            assert(~obj.logging || obj.loggingFileRolloverFlag,'Value of ''%s'' can only be set in idle or armed states, or via the rolloverLogFile() method when active');                     
        end
        
        function setMultiFrameCount(obj,val)
%             val = min(val,intmax('int32'));
%             obj.setParameterSimple('multiFrameCount',val);
        end
        
        function setNumChansProperty(obj,propName,val)
            val = logical(val); %throws if not convertible to logical
            assert(numel(val) == obj.numChannelsAvailable && isvector(val),'Value of %s must be a vector of length %d',propName,obj.numChannelsAvailable);
            
            channelsLoggingVal = obj.channelsLogging;
            channelsViewingVal = obj.channelsViewing;
            
            %Handle initialization case
            if isempty(channelsLoggingVal) || isempty(channelsViewingVal)
                return;
            end
            
            %Determine active channels
            channelsActiveBitMask = channelsLoggingVal | channelsViewingVal;
            channelsActiveVector = find(channelsActiveBitMask);
            
            %Pack vector value into a scalar; set 'channelsActive' param/property
%             obj.apiCall('SetParam', obj.paramCodeMap('channelsActive'), sum(2.^(channelsActiveVector-1)));
            
            %Dependencies
            obj.multiFrameCount = obj.multiFrameCount;
        end
        
        function setPixelationParameter(obj,propName,val)
            ppl = obj.pdepGetDirect('pixelsPerLine');
            lpf = obj.pdepGetDirect('linesPerFrame');
            am = obj.pdepGetDirect('areaMode');
            
            switch propName
                case 'pixelsPerLine'
                    ppl = val;
                case 'linesPerFrame'
                    lpf = val;
                case 'areaMode'
                    am = val;
                otherwise
                    assert(false);
            end
            
            
            
%             obj.setParameterEncoded('areaMode',am);
            
            %             if setLPFFirst
            %                 obj.setParameterSimple('linesPerFrame',lpf);
            %                 pause(1);
            %                 obj.setParameterSimple('pixelsPerLine',ppl);
            %             else
%             obj.setParameterSimple('pixelsPerLine',ppl);
%             obj.setParameterSimple('linesPerFrame',lpf);
            
            %pause(1);
            %end
        end        
        
    end
    
    
    %% PUBLIC METHODS
    
    methods
        
        function rearm(obj)
            %Rearm previously armed/started acquisition.
            %Used to allow hardware-triggered acquisition to be retriggered for a new set of acquired frames.
            
            disp('Function rearm() is now a piece of nothing, formar it has been a simple copy of arm(), PR2014.');
%             obj.arm();
            obj.state = 'armed'; % ...
        end
        
        function arm(obj)
            %Macro method used to arm an acquisition.
            %Calls both PreflightAcquisition() & SetupAcquisition() Thor API functions, prepares log file, resets acquisition flags, etc.
            
            
            if strcmpi(obj.state,'active')
                obj.stop();
            end
            
            if true %~isempty(obj.paramChangeList)
                disp('Now calling preflight, because there are some parameter changes, PR2014.');
                err = obj.PRpreflight();
                if(~err)
                    error('Error occurred during call to obj.preflight().');
                end
                obj.paramChangeList = {};
            end

            obj.state = 'armed';
            
        end
        
        function [data,frameTags] = getData(obj,numFrames)
            %Retrieves available frame image data and frame tag data from LSM, up to specified numFrames
            % numFrames: <Default=inf> Maximum number of available frames to retrieve data from
            % data: Image data, returned as MxNxCxK array representing K frames of MxN pixels and C channels each
            % frameTags: If frameTagEnable=true, an array of Kx1 frame tag values indicating the ordinal frame number stored with each of the retrieved frames.
            %                        If frameTagEnable=false, an empty array is returned
            
            %            disp('LSM.getdata: calling configureFrameAcquiredEvent');
            
%             if nargin < 2 || isinf(numFrames)
%                 data = obj.configureFrameAcquiredEvent('getdata');
%             else
%                 data = obj.configureFrameAcquiredEvent('getdata',numFrames);
%             end
%             
%             frameTags = [];
%             
%             if ~isempty(data)
%                 if iscell(data) %implies frameTagEnable=true
%                     frameTags = data{2} + 1; %Convert to 1-based indexing
%                     data = data{1};
%                 end
%                 
%                 sz = size(data);
%                 
%                 if numel(sz) > 3
%                     obj.framesGotten = obj.framesGotten + sz;
%                 else
%                     obj.framesGotten = obj.framesGotten + 1;
%                 end
%             end
            disp('Function getData() is not yet implemented, PR2014.');
            data = []; frameTags = [];
        end
        
        % This is a semi-temporary fix for SI4.frameAcquiredFcn. This is
        % bad code, it dupes logic from CFAE.
        %
        % if tfSuccess==true, data is an actual frame from CFAE.
        % if tfSuccess=false, data is a dummy placeholder frame.
        function [tfSuccess, data, frameTags] = getDataWithDummyFrame(obj,numFrames)
            tfSuccess = 0; data = []; frameTags = [];
            display('Function getDataWithDummyFrame() does not work & does not do anything yet, PR2014.');

        end
        
        %%
        
        
        
        function start0(obj,allowLogging)
            %Starts scanner and armed acquisition

            assert(strcmpi(obj.state,'armed'),'Acquisition must be armed before it can be started');
            
            if nargin > 1   
                obj.allowLogging = allowLogging;
            end
            
            if obj.loggingAutoStart && any(obj.channelsLogging) && obj.allowLogging
                obj.startLogging(); % does nothing right now
            end
            
%             obj.frameClock.start(); % starts everything, whatsoever
        end
            
        function start1(obj,allowLogging)
            
            AlazarDefs;
            % Save the transfer time
            obj.transferTime_sec = toc(obj.startTickCount);

            % Close progress window
%             delete(obj.waitbarHandle);

            % Abort the acquisition
            retCode = calllib('ATSApi', 'AlazarAbortAsyncRead', obj.ATSboardHandle);
            if retCode ~= ApiSuccess
                fprintf('Error: AlazarAbortAsyncRead failed -- %s\n', errorToText(retCode));
            end

            % Close the data file
            try
                A = obj.fid;
                if allowLogging 
                    if obj.savefast
                        fclose(obj.fid);
                    else
                        obj.fid.close();
                    end
                end
            catch
                A = 0;
            end

            % Release the buffers
            for bufferIndex = 1:obj.bufferCount
                pbuffer = obj.buffers{1, bufferIndex};
                retCode = calllib('ATSApi', 'AlazarFreeBufferU16', obj.ATSboardHandle, pbuffer);
                if retCode ~= ApiSuccess
                    fprintf('Error: AlazarFreeBufferU16 failed -- %s\n', errorToText(retCode));
                end
                clear pbuffer;
            end

            
            obj.state = 'active';
            if exist('obj.CRSdisable')~=0
                obj.CRSdisable.stop
            end
            if exist('obj.CRScmd')~=0
                obj.CRScmd.stop
            end
            if exist('obj.PRgalvo')~=0
                obj.PRgalvo.stop
            end
            if exist('obj.frameClock')~=0
                obj.frameClock.stop
            end
            if exist('obj.PRgalvoPark')~=0
                obj.PRgalvoPark.stop
            end
            obj.stop();
        end
        
        
        function startLogging(obj,frameDelay)
            %Starts file logging, for either an armed or ongoing acquisition
            % frameDelay: Number of frames by which to delay logging. Note that value is capped by (circBufSize/2).
%             
%             assert(~obj.logging,'Logging has already been started');
%             assert(ismember(obj.state,{'armed' 'active'}),'Method can only be called when in ''armed'' or ''active'' state');
%             
%             if nargin < 2
%                 frameDelay = 0;
%             end
%             validateattributes(frameDelay,{'numeric'},{'scalar' 'nonnegative' 'integer' 'finite'},'','frameDelay');
%             
%             maxFrameDelay = obj.loggingFrameDelayMax;
%             if frameDelay > maxFrameDelay
%                 fprintf(2,'WARNING (%s): Frame delay specified (%d) exceeded maximum allowed value (%d) and has been capped at such\n',mfilename('class'),frameDelay,maxFrameDelay);
%                 frameDelay = maxFrameDelay;
%             end
%             
%             obj.configureFrameAcquiredEvent('configLogFile');
%             obj.configureFrameAcquiredEvent('startLogger',frameDelay);
            
%             disp('A function that does startLogging() is missing right now, PR2014.');
            obj.logging = true;
        end
        
        function rolloverLogFile(obj,frameToRollover,varargin)
            disp('Used after parameter changes, the function rolloverLogFile() is right now missing, PR2014.');
        end
        
        function processedFrameQDrops = stop(obj,suppressWarnings)
            %Stop scanning/acquisition/logging immediately -- any queued frames not logged are lost.
            %  suppressWarnings: <Default=false> If true, warning messages that appear when loggingQDrops and/or thorFrameDrops are detected are suppressed
            
            if nargin < 2
                suppressWarnings = false;
            end
            
            processedFrameQDrops = obj.stopOrFinish('stop',suppressWarnings);
        end
        
        function processedFrameQDrops = finish(obj,suppressWarnings)
            %Stop scanning/acquisition immediately. Waits for any queued frames to be logged and then stops logging.
            %  suppressWarnings: <Default=false> If true, warning messages that appear when loggingQDrops and/or thorFrameDrops are detected are suppressed
            
            if nargin < 2
                suppressWarnings = false;
            end
            
            processedFrameQDrops = obj.stopOrFinish('finish',suppressWarnings);
        end
        
        function parkAtCenter(obj)
            
            assert(ismember(obj.state,{'idle' 'armed'}),'Cannot park scanner while it is already active.');
            
            % set amplitude for resonant scanning to zero -- workaround, PR2014-08-24
            writeAnalogData(obj.CRScmd, 0, 1, true, 1);
            samplingFrequency = 5e5;
            obj.PRgalvo.stop();
            obj.PRgalvo.cfgSampClkTiming(samplingFrequency,'DAQmx_Val_FiniteSamps');
            obj.PRgalvo.cfgOutputBuffer(2);
            obj.PRgalvo.set('startTrigRetriggerable',0);
            obj.PRgalvo.writeAnalogData(zeros(2,1),true);
            obj.PRgalvo.start();
            obj.frameClock.stop()
            obj.frameClock.start()
            pause(0.5);
            obj.frameClock.stop()

            
%             obj.scanMode = 'SCAN_MODE_CENTER';
%             obj.triggerMode = 'SW_FREE_RUN_MODE';
%             obj.arm();
            
            %Start LSM, without starting scanner (PMT property)
%             obj.configureFrameAcquiredEvent('start',false); %Starts acquisition thread and LSM acquisition
            
            obj.state = 'active'; % this is somewhat true, PR2014; unclear when to use
        end
        
        function pause(obj,stopScan)
            %Stop scanning/acquisition, but allow it to be subsequently resumed
            %Resumed acquisitions continue logging data to same file
            %  stopScan: <Default=false> If true, stop scanning until resumed. Otherwise scanning is continued, although acquisition is stopped.
            
%             obj.configureFrameAcquiredEvent('pause');
            
%             if nargin > 1 && stopScan
%                 obj.hPMTModule.scanEnable = 0;
%             end
            obj.frameClock.stop();
        end
 
        function pauseFocus(obj)

            obj.CRSdisable.writeDigitalData(true,true);
            % set amplitude for resonant scanning
            CRS_amplitude = 4.5 / (obj.scanZoomFactor);
            writeAnalogData(obj.CRScmd, CRS_amplitude, 1, true, 1);

            if obj.scanAngleMultiplierSlow > 0
%                 amplitude = CRS_amplitude * obj.scanAngleMultiplierSlow/obj.crsAngle2VoltageFactor*obj.galvoAngle2VoltageFactor;
                amplitude = CRS_amplitude * obj.scanAngleMultiplierSlow/obj.crsAngle2VoltageFactor*obj.galvoAngle2VoltageFactor*8/9;
            else
                amplitude = 0;
            end
            
            obj.frameClock.stop();
            obj.PRgalvo.stop();
            
            fprintf('Scanning amplitudes. Galvo: %0.2f V, CRS: %0.2f V.\n',0.01*round(amplitude*100),0.01*round(CRS_amplitude*100));
            samplingFrequency = 5e5;
            numsamples = floor(samplingFrequency/ obj.framerate-10*30/obj.framerate); % empirical value to make sawtooth shorter than a frame
            effectiveFrequency = samplingFrequency/numsamples;
            if obj.galvoOffset ~= 0
                disp('Warning: Galvo offset is not zero.');
            end
            if obj.galvoOffset+amplitude < 10 && obj.galvoOffset-amplitude > -10
                sawtooth1 = linspace(-amplitude,amplitude,numsamples-35)'+obj.galvoOffset; % 35/5e5 is rougly one line (65 us) for the flyback of the galvo
                sawtooth2 = linspace(amplitude,-amplitude,35)'+obj.galvoOffset;
                sawtooth = [sawtooth1; sawtooth2];
            else
                sawtooth1 = linspace(-amplitude,amplitude,numsamples-35)'; % 35/5e5 is rougly one line (65 us) for the flyback of the galvo
                sawtooth2 = linspace(amplitude,-amplitude,35)';
                sawtooth = [sawtooth1; sawtooth2];
                disp('High scanning amplitude >> do not use galvo offset.');
            end
            
            obj.PRgalvo.cfgOutputBuffer(length(sawtooth));
            obj.PRgalvo.cfgSampClkTiming(obj.galvoCmdOutputRate,'DAQmx_Val_FiniteSamps',length(sawtooth));
            obj.PRgalvo.writeAnalogData(sawtooth,false); % false = no autostart

            obj.PRgalvo.start();
            
            
            %Stop scanning/acquisition, but allow it to be subsequently resumed
            %Resumed acquisitions continue logging data to same file
            %  stopScan: <Default=false> If true, stop scanning until resumed. Otherwise scanning is continued, although acquisition is stopped.
            
%             obj.configureFrameAcquiredEvent('pause');
            
%             if nargin > 1 && stopScan
%                 obj.hPMTModule.scanEnable = 0;
%             end
        end

        function resumeFocus(obj)
            if ~isempty(strfind(['focus','grab','loop'],obj.acqState))
                obj.frameClock.stop();
                obj.frameClock.start();
            end
        end

        
        
        function resume(obj)
%             disp('Does nothing right now, PR2014-08-26.');
            %Resumes scanning/acquisition that was previously paused
            %Resumed acquisitions continue logging data to same file
            
            %obj.configureFrameAcquiredEvent('finishLogging');
            %obj.start();
%             if obj.hPMTModule.scanEnable == 0
%                 obj.hPMTModule.scanEnable = 1;
%             end
%             obj.configureFrameAcquiredEvent('resume');
        end
        
        function readOffsets(obj)
            disp('Warning: The function readOffsets is empty (PR2014). It should read out the channel offset for the Alazar DAQ channels.');
        end
        
        function tf = isAcquiring(obj)
            tf =  strcmp('active',obj.state);
        end
        
        function flushData(obj)
            disp('Warning: The function flushData is empty (PR2014)');
        end        
                
    end
    
    %% PRIVATE/PROTECTED METHODS
    
    
    methods (Hidden)
        
        
        function setInputRange(obj,channelsinputrange)
            
            AlazarDefs;
            
            LookupMap1 = [INPUT_RANGE_PM_100_MV INPUT_RANGE_PM_200_MV INPUT_RANGE_PM_400_MV INPUT_RANGE_PM_1_V INPUT_RANGE_PM_2_V INPUT_RANGE_PM_4_V];
            LookupMap2 = [0.1 0.2 0.4 1 2 4];
            LookupMap3 = [CHANNEL_A CHANNEL_B CHANNEL_C CHANNEL_D];
            
            for k = 1:numel(channelsinputrange)
                indix = channelsinputrange{k} == LookupMap2;
                InputRange = LookupMap1(indix);
                channel = LookupMap3(k);
                retCode = ...
                    calllib('ATSApi', 'AlazarInputControl', ...       
                        obj.ATSboardHandle,		...	% HANDLE -- board handle
                        channel,			...	% U8 -- input channel 
                        DC_COUPLING,		...	% U32 -- input coupling id
                        InputRange, ...	% U32 -- input range id
                        IMPEDANCE_50_OHM	...	% U32 -- input impedance id
                        );
                if retCode ~= ApiSuccess
                    fprintf('Error: AlazarInputControl failed -- %s\n', errorToText(retCode));
                    return
                end
            end
            % for delayed channel averaging: Channel 4
            retCode = ...
                calllib('ATSApi', 'AlazarInputControl', ...       
                    obj.ATSboardHandle,		...	% HANDLE -- board handle
                    LookupMap3(4),			...	% U8 -- input channel 
                    DC_COUPLING,		...	% U32 -- input coupling id
                    LookupMap1(1), ...	% U32 -- input range id
                    IMPEDANCE_50_OHM	...	% U32 -- input impedance id
                    );
            if retCode ~= ApiSuccess
                fprintf('Error: AlazarInputControl failed -- %s\n', errorToText(retCode));
                return
            end
            
            
        end
        
        function preflightAcquisition(obj)
            %Direct method to arm acquisition with current settings and resets DAQ board
            %obj.configureFrameAcquiredEvent('configBuffers');

            obj.PRpreflight();
        end
        
        function setupAcquisition(obj)
            %Direct method to arm acquisition with current settings without resetting DAQ board
            %Unlike preflightAcquisition(), setupAcquisition() can be called in midst of ongoing acquisition
            
            disp('This method does not what it is supposed to do yet; PR2014.');
            obj.PRpreflight();
        end
        
        function postflightAcquisition(obj)
            %Stops ongoing acquisition, releasing resources (?)
            obj.frameClock.abort();
            % missing: move galvo to starting position
            obj.PRgalvo.abort();
            obj.PRgalvoPark.abort();
            obj.CRSdisable.writeDigitalData(false,true);
            obj.CRScmd.abort();
            
%             obj.configureFrameAcquiredEvent('postflight');
        end
        
        function status = statusAcquisition(obj)
            %Returns the status of the acquisition
            disp('Not yet implemented 1, PR2014');
%             status = obj.apiCall('StatusAcquisition', 0);
            %TODO: Decode status
        end
        
        function [status, lastCompletedFrameIndex] = statusAcquisitionEx(obj)
            %Returns status of acquisition and frame count maintained by scanner driver
            %   lastCompletedFrameIndex: Index of the last known frame to be available for collection
            
            disp('Not yet implemented 2, PR2014');
            lastCompletedFrameIndex = 0;
%             [status, lastCompletedFrameIndex] = obj.apiCall('StatusAcquisitionEx', 0, 0);
            %TODO: Decode status
        end
        
    end
    
    methods (Access=protected)
        
        function [processedQDrops, loggingQDrops, thorFrameDrops] = stopOrFinish(obj,cmdString,suppressWarnings)
            %   cmdString: One of {'stop' 'finish'}
            %   suppressWarnings: <Default=false> If true, warning messages that appear when loggingQDrops and/or thorFrameDrops are detected are suppressed
            
            assert(ismember(cmdString,{'stop' 'finish'}));

%             obj.configureFrameAcquiredEvent(cmdString); %Stops API from sending further frames
            
            if strcmpi(obj.state,'active') %Calling postflight() when you didn't just complete an acquisition causes issues with subsequent acquisitions (no frame clock appears)
                obj.postflightAcquisition();
                
            end
            if exist('obj.CRSdisable')~=0
                obj.CRSdisable.stop
            end
            if exist('obj.CRScmd')~=0
                obj.CRScmd.stop
            end
            if exist('obj.PRgalvo')~=0
                obj.PRgalvo.stop
            end
            if exist('obj.frameClock')~=0
                obj.frameClock.stop
            end
            if exist('obj.PRgalvoPark')~=0
                obj.PRgalvoPark.stop
            end
%             obj.CRSdisable.clear
%             obj.CRScmd.clear
%             obj.PRgalvo.clear
%             obj.frameClock.clear
%             obj.PRgalvoPark.clear

            
            % dummy output
            processedFrameQDrops = 0;
            processedQDrops =0;
            loggingQDrops = 0;
            thorFrameDrops = 0;
            
            obj.state = 'idle';
            obj.logging = false;
        end
    end
    
    methods
        
        function clearDAQ(obj)

            if strcmpi(obj.state,'active') %Calling postflight() when you didn't just complete an acquisition causes issues with subsequent acquisitions (no frame clock appears)
                obj.postflightAcquisition();
                
            end
            
            obj.CRSdisable.clear();
            obj.CRScmd.clear();
            obj.PRgalvo.clear();
            obj.frameClock.clear();
            obj.frameClock2.clear();
            obj.PRgalvoPark.clear();
%             obj.lineClock.clear();
            obj.iLineClock.clear();
            
            obj.state = 'idle';
            obj.logging = false;
        end
    end
    
    
    methods
       
        function [retCode, retCode2] = changeAlazarDelay(obj)
            % this function sets the trigger phase and such the delay of
            % the clock compared to the laser pulse
            AlazarDefs
%             CLOCK_EDGE_RISING
%             CLOCK_EDGE_FALLING
            retCode = ... %% changed
                calllib('ATSApi', 'AlazarSetCaptureClock', ...
                    obj.ATSboardHandle,		...	% HANDLE -- board handle
                    FAST_EXTERNAL_CLOCK,		...	% U32 -- clock source id
                    SAMPLE_RATE_USER_DEF,...	% U32 -- sample rate id
                    obj.clockFallOrRise,	...	% U32 -- clock edge id
                    0					...	% U32 -- clock decimation 
                    );
                
            retCode2 = ... %% changed
                calllib('ATSApi', 'AlazarSetExternalClockLevel', ...
                    obj.ATSboardHandle,		...	% HANDLE -- board handle
                    round(obj.alazarClockLevel)	...	% U32 -- clock source id
                    );
        end
        
        function [boardHandle,result] = PRinitializeAlazar(obj)
            
            %% taken from AcqDisk.m of 9440/NPT
            
            addpath('C:\ScanImagePR\_PRalazar\Include')

            % Call mfile with library definitions
            AlazarDefs

            % Load driver library 
            if ~alazarLoadLibrary()
                fprintf('Error: ATSApi.dll not loaded\n');
                return
            end

            % TODO: Select a board 
            systemId = int32(1);
            boardId = int32(1);

            % Get a handle to the board
            boardHandle = calllib('ATSApi', 'AlazarGetBoardBySystemID', systemId, boardId);
            setdatatype(boardHandle, 'voidPtr', 1, 1);
            obj.ATSboardHandle = boardHandle;
            if boardHandle.Value == 0
                fprintf('Error: Unable to open board system ID %u board ID %u\n', systemId, boardId);
                return
            end
            
            
            %% configureBoard from 9440/NPT, modified; look in this folder for details
            
            
            % set default return code to indicate failure
            result = false;

            % TODO: Specify the sample rate (see sample rate id below)
            samplesPerSec = 100.e6;

            % TODO: Select clock parameters as required to generate this sample rate.
            retCode = ... %% changed
                calllib('ATSApi', 'AlazarSetCaptureClock', ...
                    obj.ATSboardHandle,		...	% HANDLE -- board handle
                    FAST_EXTERNAL_CLOCK,		...	% U32 -- clock source id
                    SAMPLE_RATE_USER_DEF,...	% U32 -- sample rate id
                    CLOCK_EDGE_RISING,	...	% U32 -- clock edge id
                    0					...	% U32 -- clock decimation 
                    );
%             retCode = ... %% changed
%                 calllib('ATSApi', 'AlazarSetCaptureClock', ...
%                     obj.ATSboardHandle,		...	% HANDLE -- board handle
%                     INTERNAL_CLOCK,		...	% U32 -- clock source id
%                     SAMPLE_RATE_100MSPS,...	% U32 -- sample rate id
%                     CLOCK_EDGE_RISING,	...	% U32 -- clock edge id
%                     0					...	% U32 -- clock decimation 
%                     );
            if retCode ~= ApiSuccess
                fprintf('Error: AlazarSetCaptureClock failed -- %s\n', errorToText(retCode));
                return
            end

            retCode = ...
                calllib('ATSApi', 'AlazarInputControl', ...       
                    obj.ATSboardHandle,		...	% HANDLE -- board handle
                    CHANNEL_A,			...	% U8 -- input channel 
                    DC_COUPLING,		...	% U32 -- input coupling id
                    INPUT_RANGE_PM_1_V, ...	% U32 -- input range id
                    IMPEDANCE_50_OHM	...	% U32 -- input impedance id
                    );
            if retCode ~= ApiSuccess
                fprintf('Error: AlazarInputControl failed -- %s\n', errorToText(retCode));
                return
            end

            retCode = ...
                calllib('ATSApi', 'AlazarInputControl', ...       
                    obj.ATSboardHandle,		...	% HANDLE -- board handle
                    CHANNEL_B,			...	% U8 -- channel identifier
                    DC_COUPLING,		...	% U32 -- input coupling id
                    INPUT_RANGE_PM_1_V,	...	% U32 -- input range id
                    IMPEDANCE_50_OHM	...	% U32 -- input impedance id
                    );
            if retCode ~= ApiSuccess
                fprintf('Error: AlazarInputControl failed -- %s\n', errorToText(retCode));
                return
            end

            retCode = ...
                calllib('ATSApi', 'AlazarInputControl', ...       
                    obj.ATSboardHandle,		...	% HANDLE -- board handle
                    CHANNEL_C,			...	% U8 -- channel identifier
                    DC_COUPLING,		...	% U32 -- input coupling id
                    INPUT_RANGE_PM_1_V,	...	% U32 -- input range id
                    IMPEDANCE_50_OHM	...	% U32 -- input impedance id
                    );
            if retCode ~= ApiSuccess
                fprintf('Error: AlazarInputControl failed -- %s\n', errorToText(retCode));
                return
            end
            
            % set trigger options: use external trigger (line trigger!)
            retCode = ...
                calllib('ATSApi', 'AlazarSetTriggerOperation', ...       
                    obj.ATSboardHandle,		...	% HANDLE -- board handle
                    TRIG_ENGINE_OP_J_OR_K,	...	% U32 -- trigger operation 
                    TRIG_ENGINE_J,		...	% U32 -- trigger engine id
                    TRIG_EXTERNAL,		...	% U32 -- trigger source id
                    TRIGGER_SLOPE_POSITIVE,	... % U32 -- trigger slope id
                    160,				...	% U32 -- trigger level from 0 (-range) to 255 (+range)
                    TRIG_ENGINE_K,		...	% U32 -- trigger engine id
                    TRIG_EXTERNAL,		...	% U32 -- trigger source id for engine K
                    TRIGGER_SLOPE_NEGATIVE, ...	% U32 -- trigger slope id
                    160					...	% U32 -- trigger level from 0 (-range) to 255 (+range)
                    );
            if retCode ~= ApiSuccess
                fprintf('Error: AlazarSetTriggerOperation failed -- %s\n', errorToText(retCode));
                return
            end

            % TODO: Select external trigger parameters as required
            retCode = ...
                calllib('ATSApi', 'AlazarSetExternalTrigger', ...       
                    obj.ATSboardHandle,		...	% HANDLE -- board handle
                    DC_COUPLING,		...	% U32 -- external trigger coupling id
                    ETR_TTL			...	% U32 -- external trigger range id
                    );
            if retCode ~= ApiSuccess
                fprintf('Error: AlazarSetExternalTrigger failed -- %s\n', errorToText(retCode));
                return
            end

            % TODO: Set trigger delay as required. 
            triggerDelay_sec = 0.;
            triggerDelay_samples = uint32(floor(triggerDelay_sec * samplesPerSec + 0.5));
            retCode = calllib('ATSApi', 'AlazarSetTriggerDelay', obj.ATSboardHandle, triggerDelay_samples);
            if retCode ~= ApiSuccess
                fprintf('Error: AlazarSetTriggerDelay failed -- %s\n', errorToText(retCode));
                return;
            end

            % TODO: Set trigger timeout as required. 

            % NOTE:
            % The board will wait for this amount of time for a trigger event. 
            % If a trigger event does not arrive, then the board will automatically 
            % trigger. Set the trigger timeout value to 0 to force the board to wait 
            % forever for a trigger event.
            %
            % IMPORTANT: 
            % The trigger timeout value should be set to zero after appropriate 
            % trigger parameters have been determined, otherwise the 
            % board may trigger if the timeout interval expires before a 
            % hardware trigger event arrives.
            triggerTimeout_sec = 0;
            triggerTimeout_clocks = uint32(floor(triggerTimeout_sec / 10.e-6 + 0.5));
            retCode = ...
                calllib('ATSApi', 'AlazarSetTriggerTimeOut', ...       
                    obj.ATSboardHandle,            ...	% HANDLE -- board handle
                    triggerTimeout_clocks	... % U32 -- timeout_sec / 10.e-6 (0 == wait forever)
                    );
            if retCode ~= ApiSuccess
                fprintf('Error: AlazarSetTriggerTimeOut failed -- %s\n', errorToText(retCode));
                return
            end

            % TODO: Configure AUX I/O connector as required
            %% essential point: use AUX_IN_TRIGGER_ENABLE in later use with frame trigger!! or AUX_OUT_TRIGGER for software trigger (?)
            retCode = ...
                calllib('ATSApi', 'AlazarConfigureAuxIO', ...       
                    obj.ATSboardHandle,		...	% HANDLE -- board handle
                    AUX_IN_TRIGGER_ENABLE,	...	% U32 -- mode 
                    TRIGGER_SLOPE_POSITIVE	...	% U32 -- parameter
                    );	
            if retCode ~= ApiSuccess
                fprintf('Error: AlazarConfigureAuxIO failed -- %s\n', errorToText(retCode));
                return 
            end

            % set return code to indicate success
            result = true;
            
            
        end
        
        
        function result = PRinitializeScanBoard(obj)
            result = false;
            
            import dabs.ni.daqmx.*
            
            % resonant scanning disable and amplitude task
            obj.CRSdisable = Task('PR Task disable CRS');
            obj.CRSdisable.createDOChan(obj.scanDevice,obj.disableResScan); 
            
            obj.CRScmd = Task('PR Task CRS');
            obj.CRScmd.createAOVoltageChan(obj.scanDevice,obj.resScanChannel,sprintf('CRS command'),0,5);
            
            % galvo command voltage control task
            xTask = Task('PR Galvo Control Task');

            obj.PRgalvo = xTask;
            obj.PRgalvo.createAOVoltageChan(obj.scanDevice,obj.galvoChannel);
            obj.galvoCmdOutputRate = 5e5;
            obj.PRgalvo.cfgSampClkTiming(obj.galvoCmdOutputRate,'DAQmx_Val_FiniteSamps',2);
            obj.PRgalvo.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.galvoTriggerChannel));
            obj.PRgalvo.set('startTrigRetriggerable',1);
            
            yTask = Task('PR Galvo Control Park Task');

            obj.PRgalvoPark = yTask;
            obj.PRgalvoPark.createAOVoltageChan(obj.scanDevice,obj.galvoChannel);
            obj.PRgalvoEnable = true;

            % frame clock counter output task
            
            obj.frameClock = Task('Frame clock');
            if isempty(obj.framerate); obj.framerate = 20; end; % dummy frequency, PR2014
            dutyCycle = 0.9995;
            if obj.framerate_user_check
                obj.frameClock.createCOPulseChanFreq(obj.scanDevice, obj.frameClockChannel,[], obj.framerate_user, dutyCycle);
            else
                obj.frameClock.createCOPulseChanFreq(obj.scanDevice, obj.frameClockChannel,[], obj.framerate, dutyCycle);
            end
            obj.frameClock.set('startTrigRetriggerable',1)
            %obj.frameClock.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.iLineClockReceive),'DAQmx_Val_Rising');
            obj.frameClock.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.iLineClockReceive),'DAQmx_Val_Falling');
            
            
            
            
            % temporary simulation of the sync signal from the resonant
            % scanner, PR2014-08-19
%             obj.lineClock = Task('Line clock');
%             dutyCycle = 0.5;
%             obj.lineClock.createCOPulseChanFreq(obj.scanDevice, obj.lineClockChan,[],8e3, dutyCycle);
%             obj.lineClock.cfgImplicitTiming('DAQmx_Val_ContSamps');
%             obj.lineClock.start();
            
            % use CRS sync signal as input; get delayed pulse of width to
            % be determined as output; the width determines the trigger for
            % the flyback. By this procedure, we also know from which
            % direction the CRS comes turns the center (otherwise image
            % would be mirrored randomly ...) -- PR2014-08-19
            %
            % realistic values:
            %   delay : 1-20 us
            %   pulsewidth=highTime : ca. 62.5 + delay, i.e. 1-40 us

            obj.lineScan_delay1 = 10e-6; % = pulseDelay
            lowTime = 1e-6; % does not matter
            obj.lineScan_delay2 = 62.5e-6; % = highTime = pulseWidth
            
            %  chanObjs = createCOPulseChanTime(obj, deviceNames, chanIDs, chanNames, lowTime, highTime, initialDelay, idleState, units)
            
            obj.iLineClock = Task('Delayed Pulse Output');
            obj.iLineClock.createCOPulseChanTime(obj.scanDevice,obj.iLineClockChan,'',lowTime,obj.lineScan_delay2,obj.lineScan_delay1);   % device, counter, ?, pulsewidth/10, pulsewidth,?
            obj.iLineClock.set('startTrigRetriggerable',1)
            set(obj.iLineClock.channels(1),'pulseTimeInitialDelay',obj.lineScan_delay1);
            set(obj.iLineClock.channels(1),'pulseLowTime',lowTime);
            set(obj.iLineClock.channels(1),'pulseHighTime',real(obj.lineScan_delay2));  
            obj.iLineClock.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.iLineClockTrig),'DAQmx_Val_Rising');

            % indirect lineClock starts;
            obj.iLineClock.start();
            
            obj.frameClock2 = Task('Frame clock 2'); % obj.frameClock2Chan
            obj.frameClock2.createCOPulseChanTime(obj.scanDevice,obj.frameClock2Chan,'',1e-3,10e-3,3e-8);   % device, counter, ?, pulsewidth/10, pulsewidth,?
            obj.frameClock2.set('startTrigRetriggerable',1)
            set(obj.frameClock2.channels(1),'pulseTimeInitialDelay',3e-8);
            set(obj.frameClock2.channels(1),'pulseLowTime',3e-8);
            set(obj.frameClock2.channels(1),'pulseHighTime',obj.framePeriodMeasuredMean*obj.scanLinesPerFrame/2-1e-6-1/7e5*3);  
            obj.frameClock2.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.frameClock2Trig),'DAQmx_Val_Rising');
            
            obj.frameClock2.start(); 
            
            result = true;
        end
            
        
        function result = PRpreflight(obj)
            %% PR2014: set tasks for the ScanBoard to be ready to go
            result = false;
            
            import dabs.ni.daqmx.*
            
            % enable resonant scanner
            obj.CRSdisable.writeDigitalData(true,true);
            % set amplitude for resonant scanning
            CRS_amplitude = 4.5 / (obj.scanZoomFactor);
            writeAnalogData(obj.CRScmd, CRS_amplitude, 1, true, 1);
            
            if ~strcmp(obj.acqState,'grab') && ~strcmp(obj.acqState,'loop')
                pause(0.2);
            else
                fprintf('Waiting for the resonant scanner to stabilize (1.5 sec) ...\n');
                pause(1.5);
            end
            
            
            if obj.scanAngleMultiplierSlow > 0
                amplitude = CRS_amplitude * obj.scanAngleMultiplierSlow/obj.crsAngle2VoltageFactor*obj.galvoAngle2VoltageFactor*8/9;
            else
                amplitude = 0;
            end
            
            
            fprintf('Scanning amplitudes. Galvo: %0.2f V, CRS: %0.2f V.\n',0.01*round(amplitude*100),0.01*round(CRS_amplitude*100));
            
            samplingFrequency = 5e5;
            numsamples = floor(samplingFrequency/ obj.framerate-10*30/obj.framerate); % empirical value to make sawtooth shorter than a frame
            effectiveFrequency = samplingFrequency/numsamples;
            if obj.galvoOffset ~= 0
                disp('Warning: Galvo offset is not zero.');
            end
            if obj.galvoOffset+amplitude < 10 && obj.galvoOffset-amplitude > -10
                sawtooth1 = linspace(-amplitude,amplitude,numsamples-35)'+obj.galvoOffset; % 35/5e5 is rougly one line (65 us) for the flyback of the galvo
                sawtooth2 = linspace(amplitude,-amplitude,35)'+obj.galvoOffset;
                sawtooth = [sawtooth1; sawtooth2];
            else
                sawtooth1 = linspace(-amplitude,amplitude,numsamples-35)'; % 35/5e5 is rougly one line (65 us) for the flyback of the galvo
                sawtooth2 = linspace(amplitude,-amplitude,35)';
                sawtooth = [sawtooth1; sawtooth2];
                disp('High scanning amplitude >> do not use galvo offset.');
            end
%             obj.PRgalvo.cfgSampClkTiming(samplingFrequency,'DAQmx_Val_ContSamps');

            obj.PRgalvo.stop();
            obj.PRgalvo.cfgOutputBuffer(length(sawtooth));
            obj.PRgalvo.cfgSampClkTiming(obj.galvoCmdOutputRate,'DAQmx_Val_FiniteSamps',length(sawtooth));

%             obj.PRgalvo.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.extFrameClockTerminal));
            obj.PRgalvo.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.galvoTriggerChannel));
            obj.PRgalvo.set('startTrigRetriggerable',1);
            obj.PRgalvo.writeAnalogData(sawtooth,false); % false = no autostart
            obj.PRgalvo.start();            

            %% PR2014: set task for the FrameClock to be ready to go (why here?)

            % already done during initialization of the ScanBoard
            
%             obj.frameClock.start(); 
%             obj.frameClock.stop();
            

            %% PR2014: set tasks for the AlazarBoard to be ready to go
            
            %call mfile with library definitions
            AlazarDefs

            % There are no pre-trigger samples in NPT mode
            preTriggerSamples = 0;
            
            
            % disp(obj.acqState);
            %% set number of frames, binningfactor, obj.loggingEnable depending on obj.acqState
            
            
            
            % TODO: Select the number of post-trigger samples per record
            postTriggerSamples = 4096; %obj.scanPixelsPerLine*binningfactor;

            % BLA: number of lines per frame
            numberLines = obj.scanLinesPerFrame;

            % BLA: number of frames, must be a multiple of framesPerBuffer
            switch obj.acqState
                case 'focus'
                    numberFrames = 1e6;
                case 'grab'
                     numberFrames = 1e6;
                case 'loop'
                     numberFrames = 1e6;
                otherwise
                    numberFrames = 1;
                    disp('This should not occur, PR2014.');
            end

            % BLA: number of frames per buffer
            framesPerBuffer = 1; % should be fixed for the start

            % TODO: Specify the number of records per channel per DMA buffer
            obj.recordsPerBuffer = numberLines*framesPerBuffer;

            % TODO: Specifiy the total number of buffers to capture
            obj.buffersPerAcquisition = numberFrames/framesPerBuffer;			



            % if using the RAM for saving the data
            % MATRIX = zeros(postTriggerSamples*2*obj.recordsPerBuffer,obj.buffersPerAcquisition,'uint16');

            % TODO: Select which channels to capture (A, B, C, D, or all)
            channelMask = 0;
            LookUpMask = [CHANNEL_A CHANNEL_B CHANNEL_C];
            if obj.multiChanAVG == 2
                channelMask = CHANNEL_A + CHANNEL_C;
            elseif obj.multiChanAVG == 4
                channelMask = CHANNEL_A + CHANNEL_B + CHANNEL_C + CHANNEL_D;
            elseif sum(obj.channelsLogging | obj.channelsViewing) == 3
                channelMask = CHANNEL_A + CHANNEL_B;
                disp('One should not use more than 2 channels at the same time (speed issue). Check the Channels window, PR2014-10-08.');
            else
                for mm = 1:3
                    if obj.channelsLogging(mm) || obj.channelsViewing(mm)
                        channelMask = channelMask + LookUpMask(mm);
                    end
                end
            end

            % TODO: Specify a buffer timeout
            % This is the amount of time to wait for each buffer to be filled
            obj.bufferTimeout_ms = 10000;

            % Calculate the number of enabled channels from the channel mask
            
            if obj.multiChanAVG ~= 0
                obj.channelsPerBoard = obj.multiChanAVG;
                channelCount = obj.multiChanAVG;
            else
                obj.channelsPerBoard = max(1,sum(obj.channelsLogging | obj.channelsViewing));
                if obj.channelsPerBoard == 3; obj.channelsPerBoard = 2; end; % Alazar does not work with exactly 3 channels
                channelCount = obj.channelsPerBoard;
            end

            if (channelCount < 1) || (channelCount > obj.channelsPerBoard)
                fprintf('Error: Invalid channel mask %08X\n', channelMask);
                return
            end

            % Get the sample and memory size
            % maxSamplesPerRecord seems to be 128 MB for this board
            [retCode, boardHandle, maxSamplesPerRecord, bitsPerSample] = calllib('ATSApi', 'AlazarGetChannelInfo', obj.ATSboardHandle, 0, 0);
            if retCode ~= ApiSuccess
                fprintf('Error: AlazarGetChannelInfo failed -- %s\n', errorToText(retCode));
                return
            end

            obj.samplesPerRecord = preTriggerSamples + postTriggerSamples;
            if obj.samplesPerRecord > maxSamplesPerRecord
                fprintf('Error (?): Too many samples per record %u max %u\n', obj.samplesPerRecord, maxSamplesPerRecord);
%                 return
            end

            % Calculate the size of each buffer in bytes
            % The manual indicates that for best transfer perfomance, one buffer should be larger than ca. 1 MB
            bytesPerSample = floor((double(bitsPerSample) + 7) / double(8)); % = 2 for our board
            obj.samplesPerBuffer = obj.samplesPerRecord * obj.recordsPerBuffer * channelCount;
            obj.bytesPerBuffer = bytesPerSample * obj.samplesPerBuffer;

            % TODO: Select the number of DMA buffers to allocate.
            % The number of DMA buffers must be greater than 2 to allow a board to DMA into
            % one buffer while, at the same time, your application processes another buffer.
            % Peter: 'bytesPerBuffer' should be smaller than 128 MB
            obj.bufferCount = uint32(16);

            % Create an array of DMA buffers; pbuffer is the p.ointer address of this buffer
            obj.buffers = cell(1, obj.bufferCount);
            for j = 1 : obj.bufferCount
                pbuffer = calllib('ATSApi', 'AlazarAllocBufferU16', obj.ATSboardHandle, obj.samplesPerBuffer);
                if pbuffer == 0
                    fprintf('Error: AlazarAllocBufferU16 %u samples failed\n', obj.samplesPerBuffer);
                    return
                end
                obj.buffers(1, j) = { pbuffer };
            end 

            % Create a data file if required
            if obj.loggingEnable && (obj.focusSave || ~strcmpi(obj.acqState,'focus'))
                if obj.savefast
                    obj.fid = fopen(obj.loggingFileName, 'w');
                else
                    obj.fid = TifStream(obj.loggingFileName,obj.pixelsPerLine,obj.linesPerFrame);
                end
                % the big W might be important -- http://undocumentedmatlab.com/blog/improving-fwrite-performance/
                % maybe use this for buffering things for 2G stumbling effects ??
                % but perfomance seems to be periodical worse for 'W'
                if obj.fid == -1
                    fprintf('Error: Unable to create data file\n');        
                end
            end

            % Set the record size (posttrigger and pretrigger samples)
            retCode = calllib('ATSApi', 'AlazarSetRecordSize', obj.ATSboardHandle, preTriggerSamples, postTriggerSamples);
            if retCode ~= ApiSuccess
                fprintf('Error: AlazarBeforeAsyncRead failed -- %s\n', errorToText(retCode));
                return
            end

            % TODO: Select AutoDMA flags as required
            % ADMA_NPT - Acquire multiple records with no-pretrigger samples
            % ADMA_EXTERNAL_STARTCAPTURE - call AlazarStartCapture to begin the acquisition
            % ADMA_INTERLEAVE_SAMPLES - interleave samples for highest throughput
            admaFlags = ADMA_EXTERNAL_STARTCAPTURE + ADMA_NPT + ADMA_INTERLEAVE_SAMPLES;

            % Configure the board to make an AutoDMA acquisition
            % Set recordsPerAcquisition to 0x7fffffff to acquire until manual abortion
            recordsPerAcquisition = obj.recordsPerBuffer * obj.buffersPerAcquisition;
            retCode = calllib('ATSApi', 'AlazarBeforeAsyncRead', obj.ATSboardHandle, channelMask, -int32(preTriggerSamples), obj.samplesPerRecord, obj.recordsPerBuffer, recordsPerAcquisition, admaFlags);
            if retCode ~= ApiSuccess
                fprintf('Error: AlazarBeforeAsyncRead failed -- %s\n', errorToText(retCode));
                return
            end

            % Post the buffers to the board
            for bufferIndex = 1 : obj.bufferCount
                pbuffer = obj.buffers{1, bufferIndex};
                retCode = calllib('ATSApi', 'AlazarPostAsyncBuffer', obj.ATSboardHandle, pbuffer, obj.bytesPerBuffer);
                if retCode ~= ApiSuccess
                    fprintf('Error: AlazarPostAsyncBuffer failed -- %s\n', errorToText(retCode));
                    return
                end
            end

            % Arm the board system to wait for triggers
            % The manual does not explain what this arming does in reality
            retCode = calllib('ATSApi', 'AlazarStartCapture', obj.ATSboardHandle);
            if retCode ~= ApiSuccess
                fprintf('Error: AlazarStartCapture failed -- %s\n', errorToText(retCode));
                return
            end
            
            % Create a progress window
%             obj.waitbarHandle = waitbar(0, ...
%                                     'Captured 0 buffers', ...
%                                     'Name','Capturing ...','Position',[10 40 280 50]);
%             setappdata(obj.waitbarHandle, 'canceling', 0);

            obj.framesGotten = 0;
            
            obj.state = 'armed';
            result = true;
        end        
       
        function restartFrameClock(obj)
            obj.frameClock.clear();

            obj.frameClock = dabs.ni.daqmx.Task('Frame clock');
            if isempty(obj.framerate); obj.framerate = 20; end; % dummy frequency, PR2014
            dutyCycle = 0.9995;
            if obj.framerate_user_check
                obj.frameClock.createCOPulseChanFreq(obj.scanDevice, obj.frameClockChannel,[], obj.framerate_user, dutyCycle);
            else
                obj.frameClock.createCOPulseChanFreq(obj.scanDevice, obj.frameClockChannel,[], obj.framerate, dutyCycle);
            end
            obj.frameClock.set('startTrigRetriggerable',1)
%             obj.frameClock.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.iLineClockReceive),'DAQmx_Val_Rising');
            obj.frameClock.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.iLineClockReceive),'DAQmx_Val_Falling');
            
            obj.frameClock2.clear();
            obj.frameClock2 = dabs.ni.daqmx.Task('Frame clock 2'); % obj.frameClock2Chan
            obj.frameClock2.createCOPulseChanTime(obj.scanDevice,obj.frameClock2Chan,'',1e-3,20e-3,3e-8);   % device, counter, ?, pulsewidth/10, pulsewidth,?
            obj.frameClock2.set('startTrigRetriggerable',1)
            set(obj.frameClock2.channels(1),'pulseTimeInitialDelay',3e-8);
            set(obj.frameClock2.channels(1),'pulseLowTime',3e-8);
            set(obj.frameClock2.channels(1),'pulseHighTime',obj.framePeriodMeasuredMean*obj.scanLinesPerFrame/2-1e-6-1/7e5*3);
            obj.frameClock2.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.frameClock2Trig),'DAQmx_Val_Rising');
            obj.frameClock2.start();
%             
%             obj.frameClock.clear();
% 
%             obj.frameClock = dabs.ni.daqmx.Task('Frame clock');
%             if isempty(obj.framerate); obj.framerate = 20; end; % dummy frequency, PR2014
%             dutyCycle = 0.9995;
%             if obj.framerate_user_check
%                 obj.frameClock.createCOPulseChanFreq(obj.scanDevice, obj.frameClockChannel,[], obj.framerate_user, dutyCycle);
%             else
%                 obj.frameClock.createCOPulseChanFreq(obj.scanDevice, obj.frameClockChannel,[], obj.framerate, dutyCycle);
%             end
%             obj.frameClock.set('startTrigRetriggerable',1)
%             obj.frameClock.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.iLineClockReceive),'DAQmx_Val_Rising');
%              obj.iLineClock.stop()
%              obj.frameClock2.clear();
%              obj.frameClock2 = dabs.ni.daqmx.Task('Frame clock 2'); % obj.frameClock2Chan
%              obj.frameClock2.createCOPulseChanTicks(obj.scanDevice,obj.frameClock2Chan,'','/Dev1/ao/SampleClock',5,20e5,5);   % device, counter, ?, pulsewidth/10, pulsewidth,?
%              obj.frameClock2.set('startTrigRetriggerable',1)
%              obj.iLineClock.start()
%             obj.frameClock2.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.frameClock2Trig),'DAQmx_Val_Rising');
%             obj.frameClock2.start();
        end
    end
    
    
end


%% HELPERS


function prop2ParamMap = zlclInitProp2ParamMap()

prop2ParamMap = containers.Map('KeyType','char','ValueType','char');

prop2ParamMap('triggerMode') = 'PARAM_TRIGGER_MODE';
prop2ParamMap('multiFrameCount') = 'PARAM_MULTI_FRAME_COUNT';
prop2ParamMap('cameraType') = 'PARAM_CAMERA_TYPE';
prop2ParamMap('pixelsPerLine') = 'PARAM_LSM_PIXEL_X';
prop2ParamMap('linesPerFrame') = 'PARAM_LSM_PIXEL_Y';
prop2ParamMap('fieldSize') = 'PARAM_LSM_FIELD_SIZE';
prop2ParamMap('channelsActive') = 'PARAM_LSM_CHANNEL';
prop2ParamMap('bidiPhaseAlignment') = 'PARAM_LSM_ALIGNMENT';
prop2ParamMap('inputChannelRange1') = 'PARAM_LSM_INPUTRANGE1';
prop2ParamMap('inputChannelRange2') = 'PARAM_LSM_INPUTRANGE2';
prop2ParamMap('inputChannelRange3') = 'PARAM_LSM_INPUTRANGE3';
prop2ParamMap('inputChannelRange4') = 'PARAM_LSM_INPUTRANGE4';
prop2ParamMap('scanMode') = 'PARAM_LSM_SCANMODE';
prop2ParamMap('averagingMode') = 'PARAM_LSM_AVERAGEMODE';
prop2ParamMap('averagingNumFrames') = 'PARAM_LSM_AVERAGENUM';
prop2ParamMap('clockSource') = 'PARAM_LSM_CLOCKSOURCE';
prop2ParamMap('clockRate') = 'PARAM_LSM_EXTERNALCLOCKRATE';
prop2ParamMap('triggerTimeout') = 'PARAM_TRIGGER_TIMEOUT_SEC';
prop2ParamMap('triggerFrameClockWithExtTrigger') = 'PARAM_ENABLE_FRAME_TRIGGER_WITH_HW_TRIG';
prop2ParamMap('areaMode') = 'PARAM_LSM_AREAMODE';
prop2ParamMap('offsetX') = 'PARAM_LSM_OFFSET_X';
prop2ParamMap('offsetY') = 'PARAM_LSM_OFFSET_Y';
prop2ParamMap('aspectRatioY') = 'PARAM_LSM_Y_AMPLITUDE_SCALER';
prop2ParamMap('flybackScannerPeriods') = 'PARAM_LSM_FLYBACK_CYCLE';
prop2ParamMap('frameTagEnable') = 'PARAM_LSM_APPEND_INDEX_TO_FRAME';
prop2ParamMap('dataMappingMode') = 'PARAM_LSM_DATAMAP_MODE';
prop2ParamMap('captureWithoutScanner') = 'PARAM_LSM_CAPTURE_WITHOUT_LINE_TRIGGER';
prop2ParamMap('touchParameter') = 'PARAM_LSM_FORCE_SETTINGS_UPDATE';
prop2ParamMap('galvoEnable') = 'PARAM_LSM_GALVO_ENABLE';
prop2ParamMap('galvoChanEnable') = 'PARAM_LSM_Y_CHANNEL_ENABLE';
prop2ParamMap('flybackScannerPeriodsSetEnable') = 'PARAM_LSM_RESET_FLYBACK_ENABLE';

prop2ParamMap('bidiPhaseAlignmentCoarse1') = 'PARAM_LSM_TWO_WAY_ZONE_1';
prop2ParamMap('bidiPhaseAlignmentCoarse2') = 'PARAM_LSM_TWO_WAY_ZONE_2';
prop2ParamMap('bidiPhaseAlignmentCoarse3') = 'PARAM_LSM_TWO_WAY_ZONE_3';
prop2ParamMap('bidiPhaseAlignmentCoarse4') = 'PARAM_LSM_TWO_WAY_ZONE_4';
prop2ParamMap('bidiPhaseAlignmentCoarse5') = 'PARAM_LSM_TWO_WAY_ZONE_5';
prop2ParamMap('bidiPhaseAlignmentCoarse6') = 'PARAM_LSM_TWO_WAY_ZONE_6';
prop2ParamMap('bidiPhaseAlignmentCoarse7') = 'PARAM_LSM_TWO_WAY_ZONE_7';
prop2ParamMap('bidiPhaseAlignmentCoarse8') = 'PARAM_LSM_TWO_WAY_ZONE_8';
prop2ParamMap('bidiPhaseAlignmentCoarse9') = 'PARAM_LSM_TWO_WAY_ZONE_9';
prop2ParamMap('bidiPhaseAlignmentCoarse10') = 'PARAM_LSM_TWO_WAY_ZONE_10';
prop2ParamMap('bidiPhaseAlignmentCoarse11') = 'PARAM_LSM_TWO_WAY_ZONE_11';
prop2ParamMap('bidiPhaseAlignmentCoarse12') = 'PARAM_LSM_TWO_WAY_ZONE_12';
prop2ParamMap('bidiPhaseAlignmentCoarse13') = 'PARAM_LSM_TWO_WAY_ZONE_13';
prop2ParamMap('bidiPhaseAlignmentCoarse14') = 'PARAM_LSM_TWO_WAY_ZONE_14';
prop2ParamMap('bidiPhaseAlignmentCoarse15') = 'PARAM_LSM_TWO_WAY_ZONE_15';
prop2ParamMap('bidiPhaseAlignmentCoarse16') = 'PARAM_LSM_TWO_WAY_ZONE_16';
prop2ParamMap('bidiPhaseAlignmentCoarse17') = 'PARAM_LSM_TWO_WAY_ZONE_17';
prop2ParamMap('bidiPhaseAlignmentCoarse18') = 'PARAM_LSM_TWO_WAY_ZONE_18';
prop2ParamMap('bidiPhaseAlignmentCoarse19') = 'PARAM_LSM_TWO_WAY_ZONE_19';
prop2ParamMap('bidiPhaseAlignmentCoarse20') = 'PARAM_LSM_TWO_WAY_ZONE_20';
prop2ParamMap('bidiPhaseAlignmentCoarse21') = 'PARAM_LSM_TWO_WAY_ZONE_21';
prop2ParamMap('bidiPhaseAlignmentCoarse22') = 'PARAM_LSM_TWO_WAY_ZONE_22';
prop2ParamMap('bidiPhaseAlignmentCoarse23') = 'PARAM_LSM_TWO_WAY_ZONE_23';
prop2ParamMap('bidiPhaseAlignmentCoarse24') = 'PARAM_LSM_TWO_WAY_ZONE_24';
prop2ParamMap('bidiPhaseAlignmentCoarse25') = 'PARAM_LSM_TWO_WAY_ZONE_25';
prop2ParamMap('bidiPhaseAlignmentCoarse26') = 'PARAM_LSM_TWO_WAY_ZONE_26';
prop2ParamMap('bidiPhaseAlignmentCoarse27') = 'PARAM_LSM_TWO_WAY_ZONE_27';
prop2ParamMap('bidiPhaseAlignmentCoarse28') = 'PARAM_LSM_TWO_WAY_ZONE_28';
prop2ParamMap('bidiPhaseAlignmentCoarse29') = 'PARAM_LSM_TWO_WAY_ZONE_29';
prop2ParamMap('bidiPhaseAlignmentCoarse30') = 'PARAM_LSM_TWO_WAY_ZONE_30';
prop2ParamMap('bidiPhaseAlignmentCoarse31') = 'PARAM_LSM_TWO_WAY_ZONE_31';
prop2ParamMap('bidiPhaseAlignmentCoarse32') = 'PARAM_LSM_TWO_WAY_ZONE_32';
prop2ParamMap('bidiPhaseAlignmentCoarse33') = 'PARAM_LSM_TWO_WAY_ZONE_33';
prop2ParamMap('bidiPhaseAlignmentCoarse34') = 'PARAM_LSM_TWO_WAY_ZONE_34';
prop2ParamMap('bidiPhaseAlignmentCoarse35') = 'PARAM_LSM_TWO_WAY_ZONE_35';
prop2ParamMap('bidiPhaseAlignmentCoarse36') = 'PARAM_LSM_TWO_WAY_ZONE_36';
prop2ParamMap('bidiPhaseAlignmentCoarse37') = 'PARAM_LSM_TWO_WAY_ZONE_37';
prop2ParamMap('bidiPhaseAlignmentCoarse38') = 'PARAM_LSM_TWO_WAY_ZONE_38';
prop2ParamMap('bidiPhaseAlignmentCoarse39') = 'PARAM_LSM_TWO_WAY_ZONE_39';
prop2ParamMap('bidiPhaseAlignmentCoarse40') = 'PARAM_LSM_TWO_WAY_ZONE_40';
prop2ParamMap('bidiPhaseAlignmentCoarse41') = 'PARAM_LSM_TWO_WAY_ZONE_41';
prop2ParamMap('bidiPhaseAlignmentCoarse42') = 'PARAM_LSM_TWO_WAY_ZONE_42';
prop2ParamMap('bidiPhaseAlignmentCoarse43') = 'PARAM_LSM_TWO_WAY_ZONE_43';
prop2ParamMap('bidiPhaseAlignmentCoarse44') = 'PARAM_LSM_TWO_WAY_ZONE_44';
prop2ParamMap('bidiPhaseAlignmentCoarse45') = 'PARAM_LSM_TWO_WAY_ZONE_45';
prop2ParamMap('bidiPhaseAlignmentCoarse46') = 'PARAM_LSM_TWO_WAY_ZONE_46';
prop2ParamMap('bidiPhaseAlignmentCoarse47') = 'PARAM_LSM_TWO_WAY_ZONE_47';
prop2ParamMap('bidiPhaseAlignmentCoarse48') = 'PARAM_LSM_TWO_WAY_ZONE_48';
prop2ParamMap('bidiPhaseAlignmentCoarse49') = 'PARAM_LSM_TWO_WAY_ZONE_49';
prop2ParamMap('bidiPhaseAlignmentCoarse50') = 'PARAM_LSM_TWO_WAY_ZONE_50';
prop2ParamMap('bidiPhaseAlignmentCoarse51') = 'PARAM_LSM_TWO_WAY_ZONE_51';
prop2ParamMap('bidiPhaseAlignmentCoarse52') = 'PARAM_LSM_TWO_WAY_ZONE_52';
prop2ParamMap('bidiPhaseAlignmentCoarse53') = 'PARAM_LSM_TWO_WAY_ZONE_53';
prop2ParamMap('bidiPhaseAlignmentCoarse54') = 'PARAM_LSM_TWO_WAY_ZONE_54';
prop2ParamMap('bidiPhaseAlignmentCoarse55') = 'PARAM_LSM_TWO_WAY_ZONE_55';
prop2ParamMap('bidiPhaseAlignmentCoarse56') = 'PARAM_LSM_TWO_WAY_ZONE_56';
prop2ParamMap('bidiPhaseAlignmentCoarse57') = 'PARAM_LSM_TWO_WAY_ZONE_57';
prop2ParamMap('bidiPhaseAlignmentCoarse58') = 'PARAM_LSM_TWO_WAY_ZONE_58';
prop2ParamMap('bidiPhaseAlignmentCoarse59') = 'PARAM_LSM_TWO_WAY_ZONE_59';
prop2ParamMap('bidiPhaseAlignmentCoarse60') = 'PARAM_LSM_TWO_WAY_ZONE_60';
prop2ParamMap('bidiPhaseAlignmentCoarse61') = 'PARAM_LSM_TWO_WAY_ZONE_61';
prop2ParamMap('bidiPhaseAlignmentCoarse62') = 'PARAM_LSM_TWO_WAY_ZONE_62';
prop2ParamMap('bidiPhaseAlignmentCoarse63') = 'PARAM_LSM_TWO_WAY_ZONE_63';
prop2ParamMap('bidiPhaseAlignmentCoarse64') = 'PARAM_LSM_TWO_WAY_ZONE_64';
prop2ParamMap('bidiPhaseAlignmentCoarse65') = 'PARAM_LSM_TWO_WAY_ZONE_65';
prop2ParamMap('bidiPhaseAlignmentCoarse66') = 'PARAM_LSM_TWO_WAY_ZONE_66';
prop2ParamMap('bidiPhaseAlignmentCoarse67') = 'PARAM_LSM_TWO_WAY_ZONE_67';
prop2ParamMap('bidiPhaseAlignmentCoarse68') = 'PARAM_LSM_TWO_WAY_ZONE_68';
prop2ParamMap('bidiPhaseAlignmentCoarse69') = 'PARAM_LSM_TWO_WAY_ZONE_69';
prop2ParamMap('bidiPhaseAlignmentCoarse70') = 'PARAM_LSM_TWO_WAY_ZONE_70';
prop2ParamMap('bidiPhaseAlignmentCoarse71') = 'PARAM_LSM_TWO_WAY_ZONE_71';
prop2ParamMap('bidiPhaseAlignmentCoarse72') = 'PARAM_LSM_TWO_WAY_ZONE_72';
prop2ParamMap('bidiPhaseAlignmentCoarse73') = 'PARAM_LSM_TWO_WAY_ZONE_73';
prop2ParamMap('bidiPhaseAlignmentCoarse74') = 'PARAM_LSM_TWO_WAY_ZONE_74';
prop2ParamMap('bidiPhaseAlignmentCoarse75') = 'PARAM_LSM_TWO_WAY_ZONE_75';
prop2ParamMap('bidiPhaseAlignmentCoarse76') = 'PARAM_LSM_TWO_WAY_ZONE_76';
prop2ParamMap('bidiPhaseAlignmentCoarse77') = 'PARAM_LSM_TWO_WAY_ZONE_77';
prop2ParamMap('bidiPhaseAlignmentCoarse78') = 'PARAM_LSM_TWO_WAY_ZONE_78';
prop2ParamMap('bidiPhaseAlignmentCoarse79') = 'PARAM_LSM_TWO_WAY_ZONE_79';
prop2ParamMap('bidiPhaseAlignmentCoarse80') = 'PARAM_LSM_TWO_WAY_ZONE_80';
prop2ParamMap('bidiPhaseAlignmentCoarse81') = 'PARAM_LSM_TWO_WAY_ZONE_81';
prop2ParamMap('bidiPhaseAlignmentCoarse82') = 'PARAM_LSM_TWO_WAY_ZONE_82';
prop2ParamMap('bidiPhaseAlignmentCoarse83') = 'PARAM_LSM_TWO_WAY_ZONE_83';
prop2ParamMap('bidiPhaseAlignmentCoarse84') = 'PARAM_LSM_TWO_WAY_ZONE_84';
prop2ParamMap('bidiPhaseAlignmentCoarse85') = 'PARAM_LSM_TWO_WAY_ZONE_85';
prop2ParamMap('bidiPhaseAlignmentCoarse86') = 'PARAM_LSM_TWO_WAY_ZONE_86';
prop2ParamMap('bidiPhaseAlignmentCoarse87') = 'PARAM_LSM_TWO_WAY_ZONE_87';
prop2ParamMap('bidiPhaseAlignmentCoarse88') = 'PARAM_LSM_TWO_WAY_ZONE_88';
prop2ParamMap('bidiPhaseAlignmentCoarse89') = 'PARAM_LSM_TWO_WAY_ZONE_89';
prop2ParamMap('bidiPhaseAlignmentCoarse90') = 'PARAM_LSM_TWO_WAY_ZONE_90';
prop2ParamMap('bidiPhaseAlignmentCoarse91') = 'PARAM_LSM_TWO_WAY_ZONE_91';
prop2ParamMap('bidiPhaseAlignmentCoarse92') = 'PARAM_LSM_TWO_WAY_ZONE_92';
prop2ParamMap('bidiPhaseAlignmentCoarse93') = 'PARAM_LSM_TWO_WAY_ZONE_93';
prop2ParamMap('bidiPhaseAlignmentCoarse94') = 'PARAM_LSM_TWO_WAY_ZONE_94';
prop2ParamMap('bidiPhaseAlignmentCoarse95') = 'PARAM_LSM_TWO_WAY_ZONE_95';
prop2ParamMap('bidiPhaseAlignmentCoarse96') = 'PARAM_LSM_TWO_WAY_ZONE_96';
prop2ParamMap('bidiPhaseAlignmentCoarse97') = 'PARAM_LSM_TWO_WAY_ZONE_97';
prop2ParamMap('bidiPhaseAlignmentCoarse98') = 'PARAM_LSM_TWO_WAY_ZONE_98';
prop2ParamMap('bidiPhaseAlignmentCoarse99') = 'PARAM_LSM_TWO_WAY_ZONE_99';
prop2ParamMap('bidiPhaseAlignmentCoarse100') = 'PARAM_LSM_TWO_WAY_ZONE_100';
prop2ParamMap('bidiPhaseAlignmentCoarse101') = 'PARAM_LSM_TWO_WAY_ZONE_101';
prop2ParamMap('bidiPhaseAlignmentCoarse102') = 'PARAM_LSM_TWO_WAY_ZONE_102';
prop2ParamMap('bidiPhaseAlignmentCoarse103') = 'PARAM_LSM_TWO_WAY_ZONE_103';
prop2ParamMap('bidiPhaseAlignmentCoarse104') = 'PARAM_LSM_TWO_WAY_ZONE_104';
prop2ParamMap('bidiPhaseAlignmentCoarse105') = 'PARAM_LSM_TWO_WAY_ZONE_105';
prop2ParamMap('bidiPhaseAlignmentCoarse106') = 'PARAM_LSM_TWO_WAY_ZONE_106';
prop2ParamMap('bidiPhaseAlignmentCoarse107') = 'PARAM_LSM_TWO_WAY_ZONE_107';
prop2ParamMap('bidiPhaseAlignmentCoarse108') = 'PARAM_LSM_TWO_WAY_ZONE_108';
prop2ParamMap('bidiPhaseAlignmentCoarse109') = 'PARAM_LSM_TWO_WAY_ZONE_109';
prop2ParamMap('bidiPhaseAlignmentCoarse110') = 'PARAM_LSM_TWO_WAY_ZONE_110';
prop2ParamMap('bidiPhaseAlignmentCoarse111') = 'PARAM_LSM_TWO_WAY_ZONE_111';
prop2ParamMap('bidiPhaseAlignmentCoarse112') = 'PARAM_LSM_TWO_WAY_ZONE_112';
prop2ParamMap('bidiPhaseAlignmentCoarse113') = 'PARAM_LSM_TWO_WAY_ZONE_113';
prop2ParamMap('bidiPhaseAlignmentCoarse114') = 'PARAM_LSM_TWO_WAY_ZONE_114';
prop2ParamMap('bidiPhaseAlignmentCoarse115') = 'PARAM_LSM_TWO_WAY_ZONE_115';
prop2ParamMap('bidiPhaseAlignmentCoarse116') = 'PARAM_LSM_TWO_WAY_ZONE_116';
prop2ParamMap('bidiPhaseAlignmentCoarse117') = 'PARAM_LSM_TWO_WAY_ZONE_117';
prop2ParamMap('bidiPhaseAlignmentCoarse118') = 'PARAM_LSM_TWO_WAY_ZONE_118';
prop2ParamMap('bidiPhaseAlignmentCoarse119') = 'PARAM_LSM_TWO_WAY_ZONE_119';
prop2ParamMap('bidiPhaseAlignmentCoarse120') = 'PARAM_LSM_TWO_WAY_ZONE_120';
prop2ParamMap('bidiPhaseAlignmentCoarse121') = 'PARAM_LSM_TWO_WAY_ZONE_121';
prop2ParamMap('bidiPhaseAlignmentCoarse122') = 'PARAM_LSM_TWO_WAY_ZONE_122';
prop2ParamMap('bidiPhaseAlignmentCoarse123') = 'PARAM_LSM_TWO_WAY_ZONE_123';
prop2ParamMap('bidiPhaseAlignmentCoarse124') = 'PARAM_LSM_TWO_WAY_ZONE_124';
prop2ParamMap('bidiPhaseAlignmentCoarse125') = 'PARAM_LSM_TWO_WAY_ZONE_125';
prop2ParamMap('bidiPhaseAlignmentCoarse126') = 'PARAM_LSM_TWO_WAY_ZONE_126';
prop2ParamMap('bidiPhaseAlignmentCoarse127') = 'PARAM_LSM_TWO_WAY_ZONE_127';
prop2ParamMap('bidiPhaseAlignmentCoarse128') = 'PARAM_LSM_TWO_WAY_ZONE_128';
prop2ParamMap('bidiPhaseAlignmentCoarse129') = 'PARAM_LSM_TWO_WAY_ZONE_129';
prop2ParamMap('bidiPhaseAlignmentCoarse130') = 'PARAM_LSM_TWO_WAY_ZONE_130';
prop2ParamMap('bidiPhaseAlignmentCoarse131') = 'PARAM_LSM_TWO_WAY_ZONE_131';
prop2ParamMap('bidiPhaseAlignmentCoarse132') = 'PARAM_LSM_TWO_WAY_ZONE_132';
prop2ParamMap('bidiPhaseAlignmentCoarse133') = 'PARAM_LSM_TWO_WAY_ZONE_133';
prop2ParamMap('bidiPhaseAlignmentCoarse134') = 'PARAM_LSM_TWO_WAY_ZONE_134';
prop2ParamMap('bidiPhaseAlignmentCoarse135') = 'PARAM_LSM_TWO_WAY_ZONE_135';
prop2ParamMap('bidiPhaseAlignmentCoarse136') = 'PARAM_LSM_TWO_WAY_ZONE_136';
prop2ParamMap('bidiPhaseAlignmentCoarse137') = 'PARAM_LSM_TWO_WAY_ZONE_137';
prop2ParamMap('bidiPhaseAlignmentCoarse138') = 'PARAM_LSM_TWO_WAY_ZONE_138';
prop2ParamMap('bidiPhaseAlignmentCoarse139') = 'PARAM_LSM_TWO_WAY_ZONE_139';
prop2ParamMap('bidiPhaseAlignmentCoarse140') = 'PARAM_LSM_TWO_WAY_ZONE_140';
prop2ParamMap('bidiPhaseAlignmentCoarse141') = 'PARAM_LSM_TWO_WAY_ZONE_141';
prop2ParamMap('bidiPhaseAlignmentCoarse142') = 'PARAM_LSM_TWO_WAY_ZONE_142';
prop2ParamMap('bidiPhaseAlignmentCoarse143') = 'PARAM_LSM_TWO_WAY_ZONE_143';
prop2ParamMap('bidiPhaseAlignmentCoarse144') = 'PARAM_LSM_TWO_WAY_ZONE_144';
prop2ParamMap('bidiPhaseAlignmentCoarse145') = 'PARAM_LSM_TWO_WAY_ZONE_145';
prop2ParamMap('bidiPhaseAlignmentCoarse146') = 'PARAM_LSM_TWO_WAY_ZONE_146';
prop2ParamMap('bidiPhaseAlignmentCoarse147') = 'PARAM_LSM_TWO_WAY_ZONE_147';
prop2ParamMap('bidiPhaseAlignmentCoarse148') = 'PARAM_LSM_TWO_WAY_ZONE_148';
prop2ParamMap('bidiPhaseAlignmentCoarse149') = 'PARAM_LSM_TWO_WAY_ZONE_149';
prop2ParamMap('bidiPhaseAlignmentCoarse150') = 'PARAM_LSM_TWO_WAY_ZONE_150';
prop2ParamMap('bidiPhaseAlignmentCoarse151') = 'PARAM_LSM_TWO_WAY_ZONE_151';
prop2ParamMap('bidiPhaseAlignmentCoarse152') = 'PARAM_LSM_TWO_WAY_ZONE_152';
prop2ParamMap('bidiPhaseAlignmentCoarse153') = 'PARAM_LSM_TWO_WAY_ZONE_153';
prop2ParamMap('bidiPhaseAlignmentCoarse154') = 'PARAM_LSM_TWO_WAY_ZONE_154';
prop2ParamMap('bidiPhaseAlignmentCoarse155') = 'PARAM_LSM_TWO_WAY_ZONE_155';
prop2ParamMap('bidiPhaseAlignmentCoarse156') = 'PARAM_LSM_TWO_WAY_ZONE_156';
prop2ParamMap('bidiPhaseAlignmentCoarse157') = 'PARAM_LSM_TWO_WAY_ZONE_157';
prop2ParamMap('bidiPhaseAlignmentCoarse158') = 'PARAM_LSM_TWO_WAY_ZONE_158';
prop2ParamMap('bidiPhaseAlignmentCoarse159') = 'PARAM_LSM_TWO_WAY_ZONE_159';
prop2ParamMap('bidiPhaseAlignmentCoarse160') = 'PARAM_LSM_TWO_WAY_ZONE_160';
prop2ParamMap('bidiPhaseAlignmentCoarse161') = 'PARAM_LSM_TWO_WAY_ZONE_161';
prop2ParamMap('bidiPhaseAlignmentCoarse162') = 'PARAM_LSM_TWO_WAY_ZONE_162';
prop2ParamMap('bidiPhaseAlignmentCoarse163') = 'PARAM_LSM_TWO_WAY_ZONE_163';
prop2ParamMap('bidiPhaseAlignmentCoarse164') = 'PARAM_LSM_TWO_WAY_ZONE_164';
prop2ParamMap('bidiPhaseAlignmentCoarse165') = 'PARAM_LSM_TWO_WAY_ZONE_165';
prop2ParamMap('bidiPhaseAlignmentCoarse166') = 'PARAM_LSM_TWO_WAY_ZONE_166';
prop2ParamMap('bidiPhaseAlignmentCoarse167') = 'PARAM_LSM_TWO_WAY_ZONE_167';
prop2ParamMap('bidiPhaseAlignmentCoarse168') = 'PARAM_LSM_TWO_WAY_ZONE_168';
prop2ParamMap('bidiPhaseAlignmentCoarse169') = 'PARAM_LSM_TWO_WAY_ZONE_169';
prop2ParamMap('bidiPhaseAlignmentCoarse170') = 'PARAM_LSM_TWO_WAY_ZONE_170';
prop2ParamMap('bidiPhaseAlignmentCoarse171') = 'PARAM_LSM_TWO_WAY_ZONE_171';
prop2ParamMap('bidiPhaseAlignmentCoarse172') = 'PARAM_LSM_TWO_WAY_ZONE_172';
prop2ParamMap('bidiPhaseAlignmentCoarse173') = 'PARAM_LSM_TWO_WAY_ZONE_173';
prop2ParamMap('bidiPhaseAlignmentCoarse174') = 'PARAM_LSM_TWO_WAY_ZONE_174';
prop2ParamMap('bidiPhaseAlignmentCoarse175') = 'PARAM_LSM_TWO_WAY_ZONE_175';
prop2ParamMap('bidiPhaseAlignmentCoarse176') = 'PARAM_LSM_TWO_WAY_ZONE_176';
prop2ParamMap('bidiPhaseAlignmentCoarse177') = 'PARAM_LSM_TWO_WAY_ZONE_177';
prop2ParamMap('bidiPhaseAlignmentCoarse178') = 'PARAM_LSM_TWO_WAY_ZONE_178';
prop2ParamMap('bidiPhaseAlignmentCoarse179') = 'PARAM_LSM_TWO_WAY_ZONE_179';
prop2ParamMap('bidiPhaseAlignmentCoarse180') = 'PARAM_LSM_TWO_WAY_ZONE_180';
prop2ParamMap('bidiPhaseAlignmentCoarse181') = 'PARAM_LSM_TWO_WAY_ZONE_181';
prop2ParamMap('bidiPhaseAlignmentCoarse182') = 'PARAM_LSM_TWO_WAY_ZONE_182';
prop2ParamMap('bidiPhaseAlignmentCoarse183') = 'PARAM_LSM_TWO_WAY_ZONE_183';
prop2ParamMap('bidiPhaseAlignmentCoarse184') = 'PARAM_LSM_TWO_WAY_ZONE_184';
prop2ParamMap('bidiPhaseAlignmentCoarse185') = 'PARAM_LSM_TWO_WAY_ZONE_185';
prop2ParamMap('bidiPhaseAlignmentCoarse186') = 'PARAM_LSM_TWO_WAY_ZONE_186';
prop2ParamMap('bidiPhaseAlignmentCoarse187') = 'PARAM_LSM_TWO_WAY_ZONE_187';
prop2ParamMap('bidiPhaseAlignmentCoarse188') = 'PARAM_LSM_TWO_WAY_ZONE_188';
prop2ParamMap('bidiPhaseAlignmentCoarse189') = 'PARAM_LSM_TWO_WAY_ZONE_189';
prop2ParamMap('bidiPhaseAlignmentCoarse190') = 'PARAM_LSM_TWO_WAY_ZONE_190';
prop2ParamMap('bidiPhaseAlignmentCoarse191') = 'PARAM_LSM_TWO_WAY_ZONE_191';
prop2ParamMap('bidiPhaseAlignmentCoarse192') = 'PARAM_LSM_TWO_WAY_ZONE_192';
prop2ParamMap('bidiPhaseAlignmentCoarse193') = 'PARAM_LSM_TWO_WAY_ZONE_193';
prop2ParamMap('bidiPhaseAlignmentCoarse194') = 'PARAM_LSM_TWO_WAY_ZONE_194';
prop2ParamMap('bidiPhaseAlignmentCoarse195') = 'PARAM_LSM_TWO_WAY_ZONE_195';
prop2ParamMap('bidiPhaseAlignmentCoarse196') = 'PARAM_LSM_TWO_WAY_ZONE_196';
prop2ParamMap('bidiPhaseAlignmentCoarse197') = 'PARAM_LSM_TWO_WAY_ZONE_197';
prop2ParamMap('bidiPhaseAlignmentCoarse198') = 'PARAM_LSM_TWO_WAY_ZONE_198';
prop2ParamMap('bidiPhaseAlignmentCoarse199') = 'PARAM_LSM_TWO_WAY_ZONE_199';
prop2ParamMap('bidiPhaseAlignmentCoarse200') = 'PARAM_LSM_TWO_WAY_ZONE_200';
prop2ParamMap('bidiPhaseAlignmentCoarse201') = 'PARAM_LSM_TWO_WAY_ZONE_201';
prop2ParamMap('bidiPhaseAlignmentCoarse202') = 'PARAM_LSM_TWO_WAY_ZONE_202';
prop2ParamMap('bidiPhaseAlignmentCoarse203') = 'PARAM_LSM_TWO_WAY_ZONE_203';
prop2ParamMap('bidiPhaseAlignmentCoarse204') = 'PARAM_LSM_TWO_WAY_ZONE_204';
prop2ParamMap('bidiPhaseAlignmentCoarse205') = 'PARAM_LSM_TWO_WAY_ZONE_205';
prop2ParamMap('bidiPhaseAlignmentCoarse206') = 'PARAM_LSM_TWO_WAY_ZONE_206';
prop2ParamMap('bidiPhaseAlignmentCoarse207') = 'PARAM_LSM_TWO_WAY_ZONE_207';
prop2ParamMap('bidiPhaseAlignmentCoarse208') = 'PARAM_LSM_TWO_WAY_ZONE_208';
prop2ParamMap('bidiPhaseAlignmentCoarse209') = 'PARAM_LSM_TWO_WAY_ZONE_209';
prop2ParamMap('bidiPhaseAlignmentCoarse210') = 'PARAM_LSM_TWO_WAY_ZONE_210';
prop2ParamMap('bidiPhaseAlignmentCoarse211') = 'PARAM_LSM_TWO_WAY_ZONE_211';
prop2ParamMap('bidiPhaseAlignmentCoarse212') = 'PARAM_LSM_TWO_WAY_ZONE_212';
prop2ParamMap('bidiPhaseAlignmentCoarse213') = 'PARAM_LSM_TWO_WAY_ZONE_213';
prop2ParamMap('bidiPhaseAlignmentCoarse214') = 'PARAM_LSM_TWO_WAY_ZONE_214';
prop2ParamMap('bidiPhaseAlignmentCoarse215') = 'PARAM_LSM_TWO_WAY_ZONE_215';
prop2ParamMap('bidiPhaseAlignmentCoarse216') = 'PARAM_LSM_TWO_WAY_ZONE_216';
prop2ParamMap('bidiPhaseAlignmentCoarse217') = 'PARAM_LSM_TWO_WAY_ZONE_217';
prop2ParamMap('bidiPhaseAlignmentCoarse218') = 'PARAM_LSM_TWO_WAY_ZONE_218';
prop2ParamMap('bidiPhaseAlignmentCoarse219') = 'PARAM_LSM_TWO_WAY_ZONE_219';
prop2ParamMap('bidiPhaseAlignmentCoarse220') = 'PARAM_LSM_TWO_WAY_ZONE_220';
prop2ParamMap('bidiPhaseAlignmentCoarse221') = 'PARAM_LSM_TWO_WAY_ZONE_221';
prop2ParamMap('bidiPhaseAlignmentCoarse222') = 'PARAM_LSM_TWO_WAY_ZONE_222';
prop2ParamMap('bidiPhaseAlignmentCoarse223') = 'PARAM_LSM_TWO_WAY_ZONE_223';
prop2ParamMap('bidiPhaseAlignmentCoarse224') = 'PARAM_LSM_TWO_WAY_ZONE_224';
prop2ParamMap('bidiPhaseAlignmentCoarse225') = 'PARAM_LSM_TWO_WAY_ZONE_225';
prop2ParamMap('bidiPhaseAlignmentCoarse226') = 'PARAM_LSM_TWO_WAY_ZONE_226';
prop2ParamMap('bidiPhaseAlignmentCoarse227') = 'PARAM_LSM_TWO_WAY_ZONE_227';
prop2ParamMap('bidiPhaseAlignmentCoarse228') = 'PARAM_LSM_TWO_WAY_ZONE_228';
prop2ParamMap('bidiPhaseAlignmentCoarse229') = 'PARAM_LSM_TWO_WAY_ZONE_229';
prop2ParamMap('bidiPhaseAlignmentCoarse230') = 'PARAM_LSM_TWO_WAY_ZONE_230';
prop2ParamMap('bidiPhaseAlignmentCoarse231') = 'PARAM_LSM_TWO_WAY_ZONE_231';
prop2ParamMap('bidiPhaseAlignmentCoarse232') = 'PARAM_LSM_TWO_WAY_ZONE_232';
prop2ParamMap('bidiPhaseAlignmentCoarse233') = 'PARAM_LSM_TWO_WAY_ZONE_233';
prop2ParamMap('bidiPhaseAlignmentCoarse234') = 'PARAM_LSM_TWO_WAY_ZONE_234';
prop2ParamMap('bidiPhaseAlignmentCoarse235') = 'PARAM_LSM_TWO_WAY_ZONE_235';
prop2ParamMap('bidiPhaseAlignmentCoarse236') = 'PARAM_LSM_TWO_WAY_ZONE_236';
prop2ParamMap('bidiPhaseAlignmentCoarse237') = 'PARAM_LSM_TWO_WAY_ZONE_237';
prop2ParamMap('bidiPhaseAlignmentCoarse238') = 'PARAM_LSM_TWO_WAY_ZONE_238';
prop2ParamMap('bidiPhaseAlignmentCoarse239') = 'PARAM_LSM_TWO_WAY_ZONE_239';
prop2ParamMap('bidiPhaseAlignmentCoarse240') = 'PARAM_LSM_TWO_WAY_ZONE_240';
prop2ParamMap('bidiPhaseAlignmentCoarse241') = 'PARAM_LSM_TWO_WAY_ZONE_241';
prop2ParamMap('bidiPhaseAlignmentCoarse242') = 'PARAM_LSM_TWO_WAY_ZONE_242';
prop2ParamMap('bidiPhaseAlignmentCoarse243') = 'PARAM_LSM_TWO_WAY_ZONE_243';
prop2ParamMap('bidiPhaseAlignmentCoarse244') = 'PARAM_LSM_TWO_WAY_ZONE_244';
prop2ParamMap('bidiPhaseAlignmentCoarse245') = 'PARAM_LSM_TWO_WAY_ZONE_245';
prop2ParamMap('bidiPhaseAlignmentCoarse246') = 'PARAM_LSM_TWO_WAY_ZONE_246';
prop2ParamMap('bidiPhaseAlignmentCoarse247') = 'PARAM_LSM_TWO_WAY_ZONE_247';
prop2ParamMap('bidiPhaseAlignmentCoarse248') = 'PARAM_LSM_TWO_WAY_ZONE_248';
prop2ParamMap('bidiPhaseAlignmentCoarse249') = 'PARAM_LSM_TWO_WAY_ZONE_249';
prop2ParamMap('bidiPhaseAlignmentCoarse250') = 'PARAM_LSM_TWO_WAY_ZONE_250';
prop2ParamMap('bidiPhaseAlignmentCoarse251') = 'PARAM_LSM_TWO_WAY_ZONE_251';

end
