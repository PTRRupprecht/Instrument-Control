function [triggerTimes,triggerFrameStartTimes] = verifyLoopTriggerTimes(fileStem,fileCtrIdxs)
%VERIFYLOOPTRIGGERTIMES Extract LOOP mode trigger times for set of recorded files, to allow inspection/analysis

[triggerTimes, triggerFrameStartTimes] = deal(nan(numel(fileCtrIdxs),1));
for i=1:length(fileCtrIdxs)
    fileName = sprintf('%s_%03d.tif',fileStem,fileCtrIdxs(i));
    if ~exist(fileName,'file')
        warning('File ''%s'' not found. Aborting.',fileName);
        break;
    end
    
    h = scim_openTif(fileName);
    triggerTimes(i) = h.SI4.triggerTime;
    triggerFrameStartTimes(i) = h.SI4.triggerFrameStartTime;
end      
    


end

