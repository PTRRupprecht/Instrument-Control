function frameTrigMultiplier(src,evnt,varargin)
%FRAMETRIGMULTIPLIER SI4 user function to generate output trigger signal at
%integer multiple of frame trigger, e.g. for synchronized camera frame
%triggering
%
% SYNTAX
%  applicationOpenEvent:
%    frameTrigMultiplier(src,evnt,devName,ctrID)
%      devName: DAQmx device name of board on which output trigger signal should be generated
%      ctrID: <Default=0> Counter channel number on board identi
%
%  acquisitionStartEvent:
%    frameTrigMultiplier(src,evnt,targetFrameRate)
%      targetFrameRate: Target rate, in Hz, of output trigger signal to generate
%
% NOTES
%  Function is assumed to work in SI4 'internal' triggered mode, for which
%  LSM frame clock generation starts after self start trigger is generated/received
%

persistent hFrmClkRpt 

hSI = evnt.Source; %Handle to ScanImage

switch evnt.EventName
        
    case 'applicationOpen'        
        initFrameClockRepeater(varargin{:});
        
    case 'applicationWillClose'                
        if ~isempty(hFrmClkRpt) && isvalid(hFrmClkRpt)
            hStim.stop();
            delete(hFrmClkRpt);
        end
        
    case 'acquisitionStart'        
        
        if isempty(varargin) || isempty(varargin{1})
            targetFrameRate = 100;
        else
            targetFrameRate = varargin{1};
        end
        
        %Configure and start (arm) Task, to begin on first frame clock received
        if isempty(hFrmClkRpt) || ~isvalid(hFrmClkRpt)
            hSys = dabs.ni.daqmx.System();
            if hSys.taskMap.isKey('SI Frame Clock Repeater');
                hFrmClkRpt = hSys.taskMap('SI Frame Clock Repeater');
            else
                initFrameClockRepeater();
            end
        end
        
        hFrmClkRpt.stop(); %just in case
        
        siFramePeriod = hSI.scanFramePeriod;
        cameraTriggerPeriod = 1/targetFrameRate;

        numCameraPeriods = floor(siFramePeriod/cameraTriggerPeriod);
        fprintf(1,'Camera frame trigger multiplication factor: %d\n',numCameraPeriods);
        
        if numCameraPeriods == 1
            warning('Unable to configure camera frame triggering -- ScanImage (camera) frame period too short (long)');
        else
            hFrmClkRpt.cfgImplicitTiming('DAQmx_Val_FiniteSamps',numCameraPeriods);
            pulseHighTime = hFrmClkRpt.channels(1).get('pulseHighTime');
            hFrmClkRpt.channels(1).set('pulseLowTime',cameraTriggerPeriod - pulseHighTime);
            
            hFrmClkRpt.start();
        end
    
        
    case {'acquisitionDone' 'acquisitionAborted'}
        %si4_postStimPulse(src,evnt);
        
        %Stop Frame clock repeat Task
        if ~isempty(hFrmClkRpt) && isvalid(hFrmClkRpt)
            hFrmClkRpt.abort();
        end
        
        
    otherwise
        assert('User function ''%s'' triggered by unexpected event (''%s'')',mfilename,eventName);    
    
end

    function initFrameClockRepeater(varargin)        
        
        assert(nargin>=1);
        
        devName = varargin{1};
        
        if length(varargin) < 2 || isempty(varargin{2})
            ctrID = 0;
        else
            ctrID = varargin{2};
        end
        
        hSys = dabs.ni.daqmx.System();
        
        taskName = 'SI Frame Clock Repeater';
        
        if hSys.taskMap.isKey(taskName) %This shouldn't happen in usual operation
            delete(hSys.taskMap(taskName));
        end
        
        hFrmClkRpt = dabs.ni.daqmx.Task(taskName);
        hFrmClkRpt.createCOPulseChanTime(devName,ctrID,'',10e-6,1e-3,0); %Create channel on Ctr0 to generate pulse of 10us after stimDelay time following trigger55
        hFrmClkRpt.cfgImplicitTiming('DAQmx_Val_FiniteSamps',2); %Multiply ScanImage frame clock rate by 2x (dummy value -- will be overridden at acquisitionStart event)

        hFrmClkRpt.cfgDigEdgeStartTrig(sprintf('PFI%d',hSI.mdfData.extFrameClockTerminal));
        hFrmClkRpt.set('startTrigRetriggerable',1);
        
    end
        

end

