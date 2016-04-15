function binary2tif_uint16(filename,width,height,cleanUp)

fclose('all');
bytesPerPixel = 2; % for uint16

% open writing file, delete if already existent
if exist(strcat(filename,'_','.tif'),'file') == 2
     delete(strcat(filename,'_','.tif'));
end
ts = TifStream(strcat(filename,'_','.tif'),width,height);

% open reading file
fid = fopen(strcat(filename,'.tif'),'r');

% look out for end of file (eof)
fseek(fid,0,'eof');
THEeND = ftell(fid);

% read & write; ca. 8-10 ms for a 512x512 frame
fseek(fid,0,'bof');
position_offset = 0;
while ftell(fid) < THEeND
    fseek(fid,width*height*position_offset*bytesPerPixel,'bof');
    A=fread(fid,width*height,'uint16');
    A = reshape(A,width,height);
    ts.appendFrame(A);
    
    position_offset = position_offset + 1;
    if mod(position_offset,50) == 0
        fprintf('%d frames written.\n',position_offset);
    end
end
% close pipes
ts.close();
state = fclose(fid);

if state == 0 && cleanUp % closing of file succesful
    delete(strcat(filename,'.tif'));
end

