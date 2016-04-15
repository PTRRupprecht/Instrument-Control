function ts = scim_tifSstream(filename, frameWidth, frameHeight, varargin)
%% @scim_tifStream\scim_tifStream: Construct a tifstream object, which allows efficient 'streamed' writing to a TIF file (i.e. writing one frame at a time)
%% SYNTAX
%   ts = scim_tifStream(filename, frameWidth, frameHeight)
%   ts = scim_tifStream(filename, frameWidth, frameHeight, imageDescription)
%   ts = scim_tifStream(filename, frameWidth, frameHeight, imageDescription, Property1, Value1, ...)
%       filename: Valid TIF filename to which frames will be appended
%       frameWidth,frameHeight: The width/heigh, in pixel count, of each frame of this TIF
%       imageDescription: Optional string containing information about Tif file; this will be appended to each frame as its 'ImageDescription' tag. Omit or leave empty to skip this tag.
%       Property1,Value1: Valid property/value pairs for tifstream objets       
%   
%  Settable Properties
%       nominalStripSize: The number of samples per strip (default: 8K)
%       bitsPerSample: One of 8, 16, or 32, determining how frame data will be interpreted (default: 16)
%
%% NOTES
%   This object serves to overcome the limitation of the Matlab imwrite() file for 'streaming' applications. When writing to a TIF file using imwrite(), even with the 'append' option,
%   the file is opened anew for each call, and then the file must be scanned through before the new frame can be appended. Thus, the write time for each frame grows as the file does.
%
%   This object is designed specifically for the situation in ScanImage. The image size of each frame is identical and the same ImageDescription is repeated for each frame. 
%   Thus most of the tag data for each frame can be computed up front, outside of the appendFrame() call which occurs within the 'stream'.
%
%   All optional properties must be set on construction; there is no set() method for this class
%
%% CHANGES
%   VI102609A: File must be closed before it can be deleted -- Vijay Iyer 10/26/09
%   VI012411A: Make computation of number of strips more general/correct -- Vijay Iyer 1/24/11
%   VI012411B: Adjust strip size in case where number of strips is less than 2 with the default or supplied nominalStripSize -- Vijay Iyer 1/24/11
%   VI041111A: Bugfix - VI012411A introduced error in cases where final strip in each frame/image is of different size -- Vijay Iyer 4/11/11
%   
%% CREDITS
%   Created 8/16/08 by Vijay Iyer
%% *************************************

global tifstreamGlobal;

%Process input arguments
imageDescription = '';
propNames = {};
propVals = {};
if ~isempty(varargin)
    if ~ischar(varargin{1})
        error('Frame header must be specified as a string');
    else
        imageDescription = uint8(varargin{1});
        if mod(length(imageDescription),2) %Ensure frameHeader is an even number of bytes
            imageDescription = [imageDescription 0];
        end      
        varargin(1) = [];
    end    
    if ~isempty(varargin)
        if mod(length(varargin),2)
            error('Invalid optional arguments. Must be property/value pairs.');
        else
            propNames = varargin(1:2:end);
            propVals = varargin(2:2:end);
            
            if ~iscellstr(propNames)
                error('Property names must be strings');
            end
        end
    end
end

if isempty(tifstreamGlobal)
    try 
        tifstreamGlobal = struct();
        
        %Create TIF file
        try
            fid = createTifFile(); 
        catch
            error('Unable to construct %s instance: %s',mfilename('class'),lasterr);
        end
        
        %Initialize some class properties
        tifstreamGlobal.fid = fid;
        tifstreamGlobal.filename = filename;
        tifstreamGlobal.nominalStripSize = 8*1024; %Determines target number of pixels to place in the strips comprising each frame
        tifstreamGlobal.bitsPerSample = 16;
        tifstreamGlobal.frameWidth = frameWidth;
        tifstreamGlobal.frameHeight = frameHeight;
        tifstreamGlobal.imageDescriptionLength = length(imageDescription); %store this so that offset to 'stripOffsets' tag data can be computed
        
        if ~isempty(propNames)
            for i=1:length(propNames)
                if ismember(lower(propNames{i}),{'nominalstripsize' 'bitspersample'})                              
                    tifstreamGlobal.(propNames{i}) = propVals{i}; %no error checking done on the value itself -- too much work!
                else
                    fprintf(2,['WARNING: Invalid property name (''' propNames{i} ''') ignored.']);
                end
            end
        end                              
        

        [IFDByteData suppIFDByteData IFDOffsets IFDOffsetVals suppIFDOffsets suppIFDOffsetVals] = computeIFDByteData();
        tifstreamGlobal.IFDByteData = IFDByteData;
        tifstreamGlobal.suppIFDByteData = suppIFDByteData;
        tifstreamGlobal.IFDOffsets = IFDOffsets;
        tifstreamGlobal.IFDOffsetVals = IFDOffsetVals;               
        tifstreamGlobal.suppIFDOffsets = suppIFDOffsets;
        tifstreamGlobal.suppIFDOffsetVals = suppIFDOffsetVals;

    catch
        tifstreamGlobal = [];
        error(['Unable to initialize ' mfilename ' object: ' lasterr sprintf('\n') getLastErrorStack]);
    end
else  %This is a singleton class (for now)
    error(['There can only be one ' mfilename ' at a time. Close or delete existing ' mfilename ' before creating new one.']);
end

%Create actual class object
ts.ptr = 1;
ts.serialized = [];

ts = class(ts,'scim_tifStream');       

    function fid = createTifFile()

        [path,fname,ext] = fileparts(filename);
        nonTifExt = false;
        if isempty(ext)
            filename = [filename '.tif'];
        elseif ~strcmpi(ext,'.tif')
            nonTifExt = true;
        end

        if exist(filename,'file')
            error(['File ' filename ' already exists. A ''scim_tifStream'' object can only be created for a new file.']);
        end

        fid = fopen(filename,'w');
        if fid < 0
            error(['Failed to create file ' filename '. Could not construct ' mfilename ' object.']);
        end
        if nonTifExt
            fprintf(2,['File '  fname ext ' does not have a TIF extension, but is a TIF file nonethless.']);
        end

        %Write TIF header data
        fwrite(fid,uint8('II')); %Specifies that little-endian byte-ordering is used
        fwrite(fid,42,'uint16'); %Specifies TIFF format version           
    end

    function [IFDByteData suppIFDByteData IFDOffsets IFDOffsetVals suppIFDOffsets suppIFDOffsetVals] = computeIFDByteData()
       
        %Fixed Tag values
        compression = 1; %no compression
        photometricInterpretation = 1; %blackIsZero
        orientation = 1; %topLeft
        samplesPerPixel = 1; 
        xResolution = [72*16^6 1*16^6]; %resolution = 72
        yResolution = [72*16^6 1*16^6]; %resolution = 72
        planarConfig = 1; %'chunky'
        resolutionUnit = 2; %inches                
       
        %Computed tag values       
        imageWidth = tifstreamGlobal.frameWidth;
        imageLength = tifstreamGlobal.frameHeight;
        bitsPerSample = tifstreamGlobal.bitsPerSample;

        nominalStripSize = tifstreamGlobal.nominalStripSize;        
        
        rowsPerStrip = round(nominalStripSize/imageWidth);  
        
        computeNumStrips = @(imageLength,rowsPerStrip) floor((imageLength + rowsPerStrip - 1)/rowsPerStrip); %VI012411A        
        numStrips = computeNumStrips(imageLength,rowsPerStrip); %VI012411A
        
        if numStrips < 2
            %%%VI012411B%%%%
            nominalStripSize = floor((imageLength * imageWidth)/2); %NOTE: In ScanImage, imageWidth is always a power-of-2, so rounding is actually unneeded
            
            rowsPerStrip = round(nominalStripSize/imageWidth);            
            numStrips = computeNumStrips(imageLength,rowsPerStrip);
            %%%%%%%%%%%%%%%%%
                        
            if numStrips < 2 %VI012411B                
                fclose(fid); %VI102609A
                delete(filename);
                error('Unable to compute appropriate strip size for requested image size. Image size likely too small.'); %Can add this support later, if needed
            else
                tifstreamGlobal.nominalStripSize = nominalStripSize;
            end
        end
        
        stripByteCounts = repmat(imageWidth*min(rowsPerStrip,imageLength)*bitsPerSample/8,1,numStrips);
        finalStripRows = mod(imageLength,rowsPerStrip);
        if finalStripRows
            %numStrips = numStrips+1; %VI041111A: Removed
            %stripByteCounts = [stripByteCounts imageWidth*finalStripRows*bitsPerSample/8]; %VI041111A: Removed
            stripByteCounts(end) = imageWidth*finalStripRows*bitsPerSample/8; %VI041111A
        end
             
        %Useful values 
        bytesPerImage = imageWidth*imageLength*(bitsPerSample/8);       
        
        %Initialize IFD Byte Data
        IFDByteData = uint8([]);
        if ~isempty(imageDescription)
            numTags = 15;
        else
            numTags = 14;
        end
        IFDByteData = [IFDByteData makeByteArray(numTags,2)];
                        
        %Append tags in sequence
        suppIFDByteData = uint8([]);
        IFDOffsets = [];
        IFDOffsetVals = [];
        
        appendValueTag(256,3,1,imageWidth);
        appendValueTag(257,3,1,imageLength);
        appendValueTag(258,3,1,bitsPerSample);
        appendValueTag(259,3,1,compression);
        appendValueTag(262,3,1,photometricInterpretation); 
        if ~isempty(imageDescription)
            appendOffsetTag(270,2,length(imageDescription),imageDescription);
        end
        appendOffsetTag(273,4,length(stripByteCounts),repmat(0,1,length(stripByteCounts))); %stripOffsets tag -- use placeholder value (0) here. Actual value filled in during appendFrame().             
        appendValueTag(274,3,1,orientation);
        appendValueTag(277,3,1,samplesPerPixel);
        appendValueTag(278,3,1,rowsPerStrip);
        appendOffsetTag(279,4,length(stripByteCounts),stripByteCounts);
        appendOffsetTag(282,5,1,xResolution);
        appendOffsetTag(283,5,1,yResolution);
        appendValueTag(284,3,1,planarConfig);
        appendValueTag(296,3,1,resolutionUnit);
        
        %Write offset to first IFD
        fwrite(tifstreamGlobal.fid,8+bytesPerImage,'uint32');
        
        %Add offset to next IFD at end of IFD
        IFDOffsets = [IFDOffsets length(IFDByteData)+1];
        IFDByteData = [IFDByteData makeByteArray(0,4)]; %place-holder vale. Actual value filled in during appendFrame()
        IFDOffsetVals = [IFDOffsetVals 2*bytesPerImage+length(IFDByteData)+length(suppIFDByteData)]; %value should be augmented by frameOffset for each frame
        
        %Determine supplementary IFD offset locations and values -- these values should be augmented by frameOffset for each frame 
        suppIFDOffsets = [1:4:(4*(length(stripByteCounts)-1)+1)] + length(imageDescription);
        suppIFDOffsetVals = cumsum(stripByteCounts)-stripByteCounts(1); 
                     
        %Append tag data for cases where data fits into 4 bytes
        function appendValueTag(tagID,type,count,data)
            tagID = makeByteArray(tagID, 2);
            type = makeByteArray(type,2);
            count = makeByteArray(count,4);
            data = makeByteArray(data,4);
            
            IFDByteData = [IFDByteData tagID type count data];                                  
        end

        %Append tag data for cases where data runs beyond 4 bytes
        function appendOffsetTag(tagID,type,count,data)
            
            switch type
                case 2
                    tagData = uint8(data);
                    numBytes = 1;
                case 3
                    tagData = uint16(data);
                    numBytes = 2;
                case 4
                    tagData = uint32(data);
                    numBytes =4;
                case 5
                    if mod(length(data),2)
                        error('Rational tag data must be supplied as pairs of values');
                    end
                    tagData = uint32([]);
                    for i=1:length(data)/2
                        tagData = [tagData uint32(data(2*i-1)) uint32(data(2*i))];
                        data(2*i-1:2*i) = [];
                    end
                    numBytes = 4;
                otherwise
                    error('Invalid TIF tag data type');
            end

            %Make Byte Data
            tagID = makeByteArray(tagID, 2);
            type = makeByteArray(type,2);
            count = makeByteArray(count,4);  
            IFDByteData = [IFDByteData tagID type count];
            
            IFDOffsets = [IFDOffsets length(IFDByteData)+1]; %Relative offset of offset to adjust
            IFDOffsetVals = [IFDOffsetVals length(suppIFDByteData) + numTags*12 + 6 + bytesPerImage];
                
            offset = makeByteArray(0,4); %Placeholder value -- actual value will be computed during appendFrame()
            IFDByteData = [IFDByteData offset];

            suppIFDByteData = [suppIFDByteData makeByteArray(tagData,numBytes)];
        end
        
    end

end





