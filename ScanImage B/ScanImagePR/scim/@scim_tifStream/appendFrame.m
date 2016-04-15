function appendFrame(this,frameData)
%  @scim_tifStream\appendFrame: Append frame of data to TIF file stream 
%% SYNTAX
%   appendFrame(this,frameData)
%       this: a @tifstream object
%       frameData: A matrix of image data, comprising one 'frame'. Must be of the size specified by the @scim_tifStream's imageHeight and imageWidth proprties. 
%   
%% NOTES
%   Data is converted to the type specified by the @scim_tifStream's pixelDataType property
%
%% CREDITS
%   Created 8/16/08 by Vijay Iyer
%% ************************************************************

global tifstreamGlobal

fid = tifstreamGlobal(this.ptr).fid;
bitsPerSample = tifstreamGlobal(this.ptr).bitsPerSample;

frameOffset = ftell(fid);

%% Checks 
if size(frameData,1) ~= tifstreamGlobal(this.ptr).frameHeight || size(frameData,2) ~= tifstreamGlobal(this.ptr).frameWidth
    delete(this);
    error('Supplied frame is of incorrect size. File stream has been closed & deleted.');
end

%% Data type conversion
switch bitsPerSample
    case 8
        frameData = uint8(frameData);
    case 16
        frameData = uint16(frameData);
    case 32
        frameData = uint32(frameData);
end

% %% Write offset to next IFD
% frameLengthBytes = numel(frameData)* bitsPerSample/8;
% fwrite(fid,frameOffset + 4 + frameLengthBytes,'uint32'); %Include the 4 bytes for this offset data itself
                
%% Append actual frame data
fwrite(fid, frameData',class(frameData));

%% Adjust IFD & Supplemental IFD data 
IFDByteData = tifstreamGlobal(this.ptr).IFDByteData;
suppIFDByteData = tifstreamGlobal(this.ptr).suppIFDByteData;

IFDOffsets = tifstreamGlobal(this.ptr).IFDOffsets;
IFDOffsetVals = tifstreamGlobal(this.ptr).IFDOffsetVals;

suppIFDOffsets = tifstreamGlobal(this.ptr).suppIFDOffsets;
suppIFDOffsetVals = tifstreamGlobal(this.ptr).suppIFDOffsetVals;

for i=1:length(IFDOffsets)
    val = IFDOffsetVals(i) + frameOffset;
    indices = IFDOffsets(i):(IFDOffsets(i)+3);
    
    IFDByteData(indices) = makeByteArray(val,4);
end

for i=1:length(suppIFDOffsets)
    val = suppIFDOffsetVals(i) + frameOffset;
    indices = suppIFDOffsets(i):(suppIFDOffsets(i)+3);
    
    suppIFDByteData(indices) = makeByteArray(val,4);
end


%% Append IFD & Supplementary IFD Data
fwrite(fid, IFDByteData, 'uint8');
fwrite(fid, suppIFDByteData, 'uint8');

end
    
    
  




