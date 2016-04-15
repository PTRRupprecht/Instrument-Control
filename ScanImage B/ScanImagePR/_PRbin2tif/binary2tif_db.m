function binary2tif_db(filename,width,height,cleanUp,headerString,autoscale,bitdepth,acqNumAveragedFrames)
% the autoscale option is not yet implemented, PR2014-10-19

fclose('all');
bytesPerPixel = 8; % for double

% check if file exists
if ~exist(strcat(filename,'.tif'),'file')
     return;
end

% open writing file, delete if already existent
if exist(strcat(filename,'_','.tif'),'file') == 2
     delete(strcat(filename,'_','.tif'));
end

% open reading file
fid = fopen(strcat(filename,'.tif'),'r');

% look out for end of file (eof)
fseek(fid,0,'eof');
THEeND = ftell(fid);
 
if autoscale
    % find maximum of stack
    fseek(fid,0,'bof');
    position_offset = 0;
    maximum = 0; minimum = 2^20;
    while ftell(fid) < THEeND
        fseek(fid,width*height*position_offset*bytesPerPixel,'bof');
        A=fread(fid,width*height,'double');
        if ~isempty(A)
            maximum = max(max(A),maximum);
            minimum = min(min(A),minimum);
        end
        position_offset = position_offset + 10;
        if mod(position_offset,100) == 0
            drawnow;
        end
    end
    headerString = [headerString, 'scalingFactorAndOffset = [',num2str(maximum-minimum),' ',num2str(minimum),']'];
else   
    headerString = [headerString, 'scalingFactorAndOffset = [1 0]'];
end
filename_basic = filename;
filename = strcat(filename,'_');
ts = TifStream(strcat(filename,'.tif'),width,height,bitdepth,headerString);

% read & write; ca. 8-10 ms for a 512x512 frame
fseek(fid,0,'bof');
position_offset = 0;
avg_counter = 0;
B = zeros(width,height);
% determine size of array when saved
fseek(fid,width*height*position_offset*bytesPerPixel,'bof');
A = fread(fid,width*height,'double');
XXA = whos('A');
intSize = XXA.bytes/1024^2/4; % in MB
filecounter = 1;
while ftell(fid) < THEeND
    fseek(fid,width*height*position_offset*bytesPerPixel,'bof');
    A = fread(fid,width*height,'double');
    try
        A = reshape(A,width,height);
        if autoscale
            A = (A-minimum)/(maximum-minimum)*2^bitdepth;
        end
    catch
        keyboard
    end
    if acqNumAveragedFrames == 1
        ts.appendFrame(A');
    else
        if mod(avg_counter,acqNumAveragedFrames) == acqNumAveragedFrames - 1
            B = B + A;
            ts.appendFrame(B'/acqNumAveragedFrames);
            B = zeros(size(A));
        else
            B = B + A;
        end
        avg_counter = avg_counter + 1;
    end
    position_offset = position_offset + 1;
    if mod(position_offset,50) == 0
        fprintf('%d frames written (un-averaged).\n',round(position_offset));
        drawnow();
    end
    if position_offset*intSize/acqNumAveragedFrames >= filecounter*4000
        filecounter = filecounter + 1;
        ts.close();
        filename = strcat(filename,'_');
        ts = TifStream(strcat(filename,'.tif'),width,height,bitdepth,headerString);
    end
end
% close pipes
ts.close();
state = fclose(fid);

if state == 0 && cleanUp % closing of file succesful
    delete(strcat(filename_basic,'.tif'));
end

