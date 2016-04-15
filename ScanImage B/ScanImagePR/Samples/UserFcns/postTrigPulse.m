function postTrigPulse(src,evnt,stimDelay,stimPulsewidth)
%POSTTRIGPULSE SI4 user function for generating stimulus pulse at specified time following ScanImage start trigger
%
%   stimDelay: Time, in seconds, to delay stimulus pulse rising-edge relative to ScanImage Start trigger

persistent hStim stimDelayLast stimPulsewidthLast

hSI = evnt.Source; %Handle to ScanImage

switch evnt.EventName
        
    case 'applicationOpen'
        initStimChan();
        
    case 'applicationWillClose'
        if ~isempty(hStim) && isvalid(hStim)
            hStim.stop();
            delete(hStim);
        end
        
    case 'acquisitionStart'        
        if nargin < 3 || isempty(stimDelay)
            stimDelay = 0;
        end
        
        if nargin < 4 || isempty(stimPulsewidth)
            stimPulsewidth = 10e-6;
        end
        
        if isempty(hStim) || ~isvalid(hStim)            
            warning('SI stim pulse channel incorrectly configured. Recreating Task/Channel.');
            initStimChan();
        end
            
            
        %Ensure Task is stopped
        hStim.stop();
        
        %Reconfigure delay and/or pulsewidth, if needed
        if stimDelay ~= stimDelayLast
            hStim.channels(1).set('pulseTimeInitialDelay', stimDelay);
            stimDelayLast = stimDelay;
        end
        
        if stimPulsewidth ~= stimPulsewidthLast
            hStim.channels(1).set('pulseHighTime', stimPulsewidth);
            stimPulsewidthLast = stimPulsewidth;
        end
        
        %Configure triggering
        if hSI.triggerExtTrigEnable
            hStim.cfgDigEdgeStartTrig(sprintf('PFI%d',hSI.triggerStartTrigSrc));
        else %Use self-trigger
            hStim.cfgDigEdgeStartTrig(sprintf('PFI%d',hSI.mdfData.trigSelfTrigDestinationTerminal));
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

    function initStimChan()        
        
        hSys = dabs.ni.daqmx.System();
        
        if hSys.taskMap.isKey('SI Stim Pulse') %This shouldn't happen in usual operation
            delete(hSys.taskMap('SI Stim Pulse'));
        end
        
        hStim = dabs.ni.daqmx.Task('SI Stim Pulse');
        hStim.createCOPulseChanTime('si4-2',0,'',0.1,10e-6,0); %Create channel on Ctr0 to generate pulse of 10us after stimDelay time following trigger
        hStim.cfgDigEdgeStartTrig(sprintf('PFI%d',hSI.triggerStartTrigSrc));
        
        stimDelayLast = 0;
        stimPulsewidthLast = 10e-6;
        
    end
        

end

