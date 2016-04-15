function tf = verifyNextTriggerFrameBreaks(hSI)
%Function to verify that files separated by next triggers have expected number of frames
%NOTE: Must be called immediately after acquisition

expectedFileBreaks = diff(hSI.loggingFrameBreaks);
measuredFileBreaks = zeros(size(expectedFileBreaks));

fileIndices = (hSI.loggingFileCounter - hSI.loopRepeatsDone) + (0:(hSI.loopRepeatsDone-1));

for i = 1:length(fileIndices)
    fileName = fullfile(hSI.loggingFilePath,sprintf('%s_%03d.tif',hSI.loggingFileStem,fileIndices(i)));
    if expectedFileBreaks(i) > 0 || exist(fileName,'file');                        
        try
            measuredFileBreaks(i)  = length(imfinfo(fileName));
        catch ME
            if strcmpi(ME.identifier, 'MATLAB:tifftagsread:badTiffIfdOffset') && expectedFileBreaks(i) == 0 %Case of empty file, which can occur sometimes during multiple next triggers within a single FastZ volume
                measuredFileBreaks(i) = 0;
            else
                ME.rethrow();
            end
        end
    else
        measuredFileBreaks(i) = 0;
    end
end

tf = all(expectedFileBreaks == measuredFileBreaks(1:length(expectedFileBreaks)));

if ~tf
   fprintf(2,'WARNING: Expected frame breaks: %s\n Actual frame breaks: %s\n',mat2str(expectedFileBreaks), mat2str(measuredFileBreaks));    
end
    
    
