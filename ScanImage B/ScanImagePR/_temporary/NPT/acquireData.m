function [result] = acquireData(boardHandle)
% Make an AutoDMA acquisition from dual-ported memory.

%---------------------------------------------------------------------------
%
% Copyright (c) 2008-2013 AlazarTech, Inc.
%
% AlazarTech, Inc. licenses this software under specific terms and
% conditions. Use of any of the software or derivatives thereof in any
% product without an AlazarTech digitizer board is strictly prohibited.
%
% AlazarTech, Inc. provides this software AS IS, WITHOUT ANY WARRANTY,
% EXPRESS OR IMPLIED, INCLUDING, WITHOUT LIMITATION, ANY WARRANTY OF
% MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. AlazarTech makes no
% guarantee or representations regarding the use of, or the results of the
% use of, the software and documentation in terms of correctness, accuracy,
% reliability, currentness, or otherwise; and you rely on the software,
% documentation and results solely at your own risk.
%
% IN NO EVENT SHALL ALAZARTECH BE LIABLE FOR ANY LOSS OF USE, LOSS OF
% BUSINESS, LOSS OF PROFITS, INDIRECT, INCIDENTAL, SPECIAL OR CONSEQUENTIAL
% DAMAGES OF ANY KIND. IN NO EVENT SHALL ALAZARTECH%S TOTAL LIABILITY EXCEED
% THE SUM PAID TO ALAZARTECH FOR THE PRODUCT LICENSED HEREUNDER.
%
%---------------------------------------------------------------------------

% set default return code to indicate failure
result = false;

%call mfile with library definitions
AlazarDefs

% There are no pre-trigger samples in NPT mode
preTriggerSamples = 0;

% TODO: Select the number of post-trigger samples per record 
postTriggerSamples = 4096;

% BLA: number of lines per frame
numberLines = 512;

% BLA: number of frames, must be a multiple of framesPerBuffer
numberFrames = 30*10;

% BLA: number of frames per buffer
framesPerBuffer = 5;

% TODO: Specify the number of records per channel per DMA buffer
recordsPerBuffer = numberLines*framesPerBuffer;

% TODO: Specifiy the total number of buffers to capture
buffersPerAcquisition = numberFrames/framesPerBuffer;			



% if using the RAM for saving the data
% MATRIX = zeros(postTriggerSamples*2*recordsPerBuffer,buffersPerAcquisition,'uint16');

% TODO: Select which channels to capture (A, B, C, D, or all)
channelMask = CHANNEL_A + CHANNEL_B;% + CHANNEL_C + CHANNEL_D;

% TODO: Specify a buffer timeout
% This is the amount of time to wait for each buffer to be filled
bufferTimeout_ms = 3000;

% TODO: Select if you wish to save the sample data to a binary file
saveData = false;

% TODO: Select if you wish to plot the data to a chart
drawData = false;

% Calculate the number of enabled channels from the channel mask 
channelCount = 0;
channelsPerBoard = 2;
for channel = 0:channelsPerBoard - 1
    channelId = 2^channel;
    if bitand(channelId, channelMask)
        channelCount = channelCount + 1;
    end
end

if (channelCount < 1) || (channelCount > channelsPerBoard)
    fprintf('Error: Invalid channel mask %08X\n', channelMask);
    return
end

% Get the sample and memory size
% maxSamplesPerRecord seems to be 128 MB for this board
[retCode, boardHandle, maxSamplesPerRecord, bitsPerSample] = calllib('ATSApi', 'AlazarGetChannelInfo', boardHandle, 0, 0);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarGetChannelInfo failed -- %s\n', errorToText(retCode));
    return
end

samplesPerRecord = preTriggerSamples + postTriggerSamples;
if samplesPerRecord > maxSamplesPerRecord
    fprintf('Error: Too many samples per record %u max %u\n', samplesPerRecord, maxSamplesPerRecord);
    return
end

% Calculate the size of each buffer in bytes
% The manual indicates that for best transfer perfomance, one buffer should be larger than ca. 1 MB
bytesPerSample = floor((double(bitsPerSample) + 7) / double(8)); % = 2 for our board
samplesPerBuffer = samplesPerRecord * recordsPerBuffer * channelCount;
bytesPerBuffer = bytesPerSample * samplesPerBuffer;

% TODO: Select the number of DMA buffers to allocate.
% The number of DMA buffers must be greater than 2 to allow a board to DMA into
% one buffer while, at the same time, your application processes another buffer.
% Peter: 'bytesPerBuffer' should be smaller than 128 MB
bufferCount = uint32(16);

% Create an array of DMA buffers; pbuffer is the address of this buffer
buffers = cell(1, bufferCount);
for j = 1 : bufferCount
    pbuffer = calllib('ATSApi', 'AlazarAllocBufferU16', boardHandle, samplesPerBuffer);
    if pbuffer == 0
        fprintf('Error: AlazarAllocBufferU16 %u samples failed\n', samplesPerBuffer);
        return
    end
    buffers(1, j) = { pbuffer };
end

% Create a data file if required
fid = -1;
if saveData
    fid = fopen('data.bin', 'w');
    % the big W might be important -- http://undocumentedmatlab.com/blog/improving-fwrite-performance/
    % maybe use this for buffering things for 2G stumbling effects ??
    % but perfomance seems to be periodical worse for 'W'
    if fid == -1
        fprintf('Error: Unable to create data file\n');        
    end
end

% Set the record size (posttrigger and pretrigger samples)
retCode = calllib('ATSApi', 'AlazarSetRecordSize', boardHandle, preTriggerSamples, postTriggerSamples);
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
recordsPerAcquisition = recordsPerBuffer * buffersPerAcquisition;
retCode = calllib('ATSApi', 'AlazarBeforeAsyncRead', boardHandle, channelMask, -int32(preTriggerSamples), samplesPerRecord, recordsPerBuffer, recordsPerAcquisition, admaFlags);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarBeforeAsyncRead failed -- %s\n', errorToText(retCode));
    return
end

% Post the buffers to the board
for bufferIndex = 1 : bufferCount
    pbuffer = buffers{1, bufferIndex};
    retCode = calllib('ATSApi', 'AlazarPostAsyncBuffer', boardHandle, pbuffer, bytesPerBuffer);
    if retCode ~= ApiSuccess
        fprintf('Error: AlazarPostAsyncBuffer failed -- %s\n', errorToText(retCode));
        return
    end        
end

% Update status
if buffersPerAcquisition == hex2dec('7FFFFFFF')
    fprintf('Capturing buffers until aborted...\n');
else
    fprintf('Capturing %u buffers ...\n', buffersPerAcquisition);
end

% Arm the board system to wait for triggers
% The manual does not explain what this arming does in reality
retCode = calllib('ATSApi', 'AlazarStartCapture', boardHandle);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarStartCapture failed -- %s\n', errorToText(retCode));
    return
end

% Create a progress window
waitbarHandle = waitbar(0, ...
                        'Captured 0 buffers', ...
                        'Name','Capturing ...', ...
                        'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
setappdata(waitbarHandle, 'canceling', 0);

% this is nothing but book-keeping
startTickCount = tic;
updateTickCount = tic;
updateInterval_sec = 0.1;
buffersCompleted = 0;
captureDone = false;
success = false;

% ok, this should be done in a more flexible way ...
figure(1); colormap(gray)
imagehandle = imagesc(rand(samplesPerRecord*channelsPerBoard/4,recordsPerBuffer),[326e2 327e2]);

% Wait for sufficient data to arrive to fill a buffer, process the buffer,
% and repeat until the acquisition is complete

counter = 0;
while ~captureDone
tic
    counter = counter + 1;
    bufferIndex = mod(buffersCompleted, bufferCount) + 1;
    pbuffer = buffers{1, bufferIndex};
    % Wait for the first available buffer to be filled by the board : this
    % is the central part of the whole program

    [retCode, boardHandle, bufferOut] = ...
        calllib('ATSApi', 'AlazarWaitAsyncBufferComplete', boardHandle, pbuffer, 1);% bufferTimeout_ms);
    if retCode == ApiSuccess 
        % This buffer is full
         bufferFull = true;
        captureDone = false;
    elseif retCode == ApiWaitTimeout 
        % The wait timeout expired before this buffer was filled.
        % The board may not be triggering, or the timeout period may be too short.
        fprintf('Error: AlazarWaitAsyncBufferComplete timeout -- Verify trigger!\n');
        bufferFull = false;
        captureDone = true;
    else
        % The acquisition failed
        fprintf('Error: AlazarWaitAsyncBufferComplete failed -- %s\n', errorToText(retCode));
        bufferFull = false;
        captureDone = true;
    end

    if bufferFull
        % TODO: Process sample data in this buffer.
        %
        % NOTE:
        % While you are processing this buffer, the board is already
        % filling the next available DMA buffer.
        %
        % You must finish processing this buffer before the board fills
        % all of its available DMA buffers and on-board memory.
        %
        % Records are arranged in the buffer as follows:
        % R0A, R1A, R2A ... RnA, R0B, R1B, R2B ...
        %
        % Samples values are arranged contiguously in each record.
        % A 14-bit sample code is stored in the most significant bits of 
        % in each 14-bit sample value.
        %
        % Sample codes are unsigned by default where:
        % - 0x0000 represents a negative full scale input signal;
        % - 0x2000 represents a 0V signal;
        % - 0x3fff represents a positive full scale input signal.

        setdatatype(bufferOut, 'uint16Ptr', 1, samplesPerBuffer);

%         Save the buffer to file, alternatively to a matrix
        if fid ~= -1
%             mat = reshape(bufferOut.Value,[samplesPerRecord*channelsPerBoard recordsPerBuffer]);
%             MATRIX(:,counter) = bufferOut.Value;%  = zeros(postTriggerSamples,recordsPerBuffer,buffersPerAcquisition,'uint16');
            samplesWritten = fwrite(fid, bufferOut.Value, 'uint16');
            if samplesWritten ~= samplesPerBuffer
                fprintf('Error: Write buffer %u failed\n', buffersCompleted);
            end
        end

        % Display the buffer on screen
        if drawData             
            mat = reshape(bufferOut.Value,[samplesPerRecord*channelsPerBoard recordsPerBuffer]);
            set(imagehandle,'Cdata',mat(1:channelsPerBoard*2:end,1:end))

%             figure(1),imagesc(mat(1:channelsPerBoard*8:end,1:end)); drawnow;
            
        end

        % Make the buffer available to be filled again by the board
        retCode = calllib('ATSApi', 'AlazarPostAsyncBuffer', boardHandle, pbuffer, bytesPerBuffer);
        if retCode ~= ApiSuccess
            fprintf('Error: AlazarPostAsyncBuffer failed -- %s\n', errorToText(retCode));
            captureDone = true;
        end        

        % Update progress
         buffersCompleted = buffersCompleted + 1;
        if buffersCompleted >= buffersPerAcquisition
            captureDone = true;
            success = true;
        elseif toc(updateTickCount) > updateInterval_sec
            updateTickCount = tic;

            % Update waitbar progress 
            waitbar(double(buffersCompleted) / double(buffersPerAcquisition), ...
                    waitbarHandle, ...
                    sprintf('Completed %u buffers', buffersCompleted));
                
            % Check if waitbar cancel button was pressed
            if getappdata(waitbarHandle,'canceling')
                break
            end               
        end

    end % if bufferFull
timecounter(counter) = toc;
end % while ~captureDone

% Save the transfer time
transferTime_sec = toc(startTickCount);

% Close progress window
delete(waitbarHandle);

% Abort the acquisition
retCode = calllib('ATSApi', 'AlazarAbortAsyncRead', boardHandle);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarAbortAsyncRead failed -- %s\n', errorToText(retCode));
end

% Close the data file
if fid ~= -1
    fclose(fid);
end

% Release the buffers
for bufferIndex = 1:bufferCount
    pbuffer = buffers{1, bufferIndex};
    retCode = calllib('ATSApi', 'AlazarFreeBufferU16', boardHandle, pbuffer);
    if retCode ~= ApiSuccess
        fprintf('Error: AlazarFreeBufferU16 failed -- %s\n', errorToText(retCode));
    end
    clear pbuffer;
end

% Display results
if buffersCompleted > 0 
    bytesTransferred = double(buffersCompleted) * double(bytesPerBuffer);
    recordsTransferred = recordsPerBuffer * buffersCompleted;

    if transferTime_sec > 0 
        buffersPerSec = buffersCompleted / transferTime_sec;
        bytesPerSec = bytesTransferred / transferTime_sec;
        recordsPerSec = recordsTransferred / transferTime_sec;
    else
        buffersPerSec = 0;
        bytesPerSec = 0;
        recordsPerSec = 0.;
    end

    fprintf('Captured %u buffers in %g sec (%g buffers per sec)\n', buffersCompleted, transferTime_sec, buffersPerSec);
    fprintf('Captured %u records (%.4g records per sec)\n', recordsTransferred, recordsPerSec);
    fprintf('Transferred %u bytes (%.4g  per sec)\n', bytesTransferred, bytesPerSec);   
end

% set return code to indicate success
result = success;
figure(12), plot(timecounter) % should be flat in the ideal case !
% close 1
% close 12
end