function hantman_stimPulse(eventName,eventData, stimDelay)
%ScanImage 3.8 user function to generate a digital pulse at some fixed time (possibly 0) following the ScanImage Start Trigger
% stimDelay: Time, in seconds, following the trigger, to generate digital pulse
%
% Users basing off this model can/should edit the device ID, pulsewidth, counter channel number, etc in the createCOPulseChanTime() method call, as needed
% Note that Counter output channels 0/1/2/3 correspond to terminals PFI 12/13/14/15 on the BNC breakouts for NI multifunction boards (by default, which is not modified here)

persistent hStim stimDelayLast hSys

global state

switch eventName
    
    case 'acquisitionStart'        
        
        if nargin < 3
            stimDelay = 0;
        end
        
        %Recreate Task if stimDelay value is changed
        if ~isempty(stimDelayLast) && stimDelay ~= stimDelayLast            
            delete(hStim);
            hStim = [];
        end
        
        if isempty(hSys)
            hSys = dabs.ni.daqmx.System();
        end
        
        %Create pulse output channel, trigged by ScanImage Start Trigger
        if isempty(hStim) || ~isvalid(hStim)
            if hSys.taskMap.isKey('Stimulus Trigger') %This shouldn't happen in usual operation
                delete(hSys.taskMap('Stimulus Trigger'));
            end
            hStim = dabs.ni.daqmx.Task('Stimulus Trigger');
            hStim.createCOPulseChanTime('Dev2',0,'',0.1,10e-6,stimDelay); %Create channel on Ctr0 to generate pulse of 10us immediately upon trigger
            hStim.cfgDigEdgeStartTrig(state.init.triggerInputTerminal);
            stimDelayLast = stimDelay;
        end
        
        if ~hStim.isTaskDone()
            fprintf(2,'WARNING: Stimulator trigger Task was found to be active already.\n');
            hStim.stop();
        end
        
        %Arm pulse generation
        hStim.start();

    case {'acquisitionDone' 'abortAcquisitionEnd'}
        
        %Stop Stim Trigger Task, to allow it to be re-used on next acquisition start
        if ~isempty(hStim) && isvalid(hStim)
            hStim.abort();
        end

    %case {'acquisitionDone'}
end




