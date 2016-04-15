function periodTriggeredPulse(src,evnt,pulseWidth,pulseDelay)
%PERIODTRIGGEREDPULSE SI4 user function for generating stimulus pulse synced to ThorLSM period ('line') clock

%   pulseDelay: Time, in seconds, to delay stimulus pulse rising-edge relative to ScanImage Start trigger

persistent hStim pulseDelayLast pulseWidthLast

devName = 'si4-2';
ctrChan = 0;

hSI = evnt.Source; %Handle to ScanImage

switch evnt.EventName
        
    case 'applicationOpen'
        initPulseChan();
        
    case 'applicationWillClose'
        if ~isempty(hStim) && isvalid(hStim)
            hStim.stop();
            delete(hStim);
        end
        
    case 'acquisitionStart'        

        
        if nargin < 3 || isempty(pulseWidth)
            pulseWidth = 10e-6;
        end
        
        if nargin < 4 || isempty(pulseDelay)            
            pulseDelay = 0;                            
        end
        
        if isempty(hStim) || ~isvalid(hStim)            
            warning('SI stim pulse channel incorrectly configured. Recreating Task/Channel.');
            initPulseChan();
        end
            
            
        %Ensure Task is stopped
        hStim.stop();
        
        %Reconfigure delay and/or pulsewidth, if needed
        switch hSI.scanMode
            case 'unidirectional'
                initDelay = hSI.scanLinePeriod/2 + pulseDelay;
            case 'bidirectional'
                initDelay = hSI.scanLinePeriod + pulseDelay;
        end
        
        
        if pulseDelay ~= pulseDelayLast
            hStim.channels(1).set('pulseTimeInitialDelay', initDelay);
            pulseDelayLast = pulseDelay;
        end
        
        if pulseWidth ~= pulseWidthLast
            hStim.channels(1).set('pulseHighTime', pulseWidth);
            pulseWidthLast = pulseWidth;
        end
        
        %Start (arm) Task, to begin on Task's trigger input
        hStim.start();

        
    case {'acquisitionDone' 'acquisitionAborted'}
        %Stop Stim Trigger Task, to allow it to be re-used on next acquisition start
        if ~isempty(hStim) && isvalid(hStim)
            hStim.stop();
        end
        
    otherwise
        assert('User function ''%s'' triggered by unexpected event (''%s'')',mfilename,eventName);    
    
end

    function initPulseChan()        
        
        hSys = dabs.ni.daqmx.System();
        
        if hSys.taskMap.isKey('SI Period Triggered Pulse') %This shouldn't happen in usual operation
            delete(hSys.taskMap('SI Period Triggered Pulse'));
        end
        
        hStim = dabs.ni.daqmx.Task('SI Period Triggered Pulse');
        hStim.createCOPulseChanTime(devName,ctrChan,'',0.1,10e-6,0); %Create counter channel to generate pulse of 10us after stimDelay time following trigger
        hStim.cfgDigEdgeStartTrig(sprintf('PFI%d',hSI.mdfData.extLineClockTerminal));
                
        %Allow retriggering; ensure ctr output period remains shorter than
        %trigger period
        set(hStim,'startTrigRetriggerable',1);
        ctrPeriod = 1/hStim.channels.get('ctrTimebaseRate'); 
        set(hStim.channels(1),'pulseLowTime',2*ctrPeriod);
        
        if ~isempty(hSI.hBeams)
            mpw = hSI.hBeams.get('digEdgeStartTrigDigFltrMinPulseWidth');
            set(hStim,'digEdgeStartTrigDigFltrEnable',1);
            set(hStim,'digEdgeStartTrigDigFltrMinPulseWidth',mpw);
        end
        
        pulseDelayLast = 0;
        pulseWidthLast = 10e-6;
        
    end
        

end

