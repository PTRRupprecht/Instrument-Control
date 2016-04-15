classdef TifStream < handle
    %% TIFSTREAM: Construct a tifstream object, which allows efficient 'streamed' writing to a TIF file (i.e. writing one frame at a time)
    %% SYNTAX
    %   ts = tifStream(filename, frameWidth, frameHeight)
    %   ts = tifStream(filename, frameWidth, frameHeight, imageDescription)
    %   ts = tifStream(filename, frameWidth, frameHeight, imageDescription, Property1, Value1, ...)
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
    %% CREDITS
    %   Created 8/16/08 by Vijay Iyer, 
    %   Changed to new style class on 9/28/10 by Jinyang Liu
    %% *************************************
    
    properties
        nominalStripSize; %Determines target number of pixels to place in the strips comprising each frame
        bitsPerSample;
        frameWidth;
        frameHeight;
        imageDescriptionLength; %store this so that offset to 'stripOffsets' tag data can be computed
    end
    
    properties (SetAccess=private)
        fid;
        filename;
        imageDescription;
        
        IFDByteData;
        suppIFDByteData;
        IFDOffsets;
        IFDOffsetVals;
        suppIFDOffsets;
        suppIFDOffsetVals;

    end
    %%Constructor/destructor
    methods
        function obj = TifStream(filename, frameWidth, frameHeight, varargin)
            
            %Process input arguments
            obj.imageDescription = '';
            propNames = {};
            propVals = {};
            if ~isempty(varargin)
                if ~ischar(varargin{1})
                    error('Frame header must be specified as a string');
                else
                    obj.imageDescription = uint8(varargin{1});
                    if mod(length(obj.imageDescription),2) %Ensure frameHeader is an even number of bytes
                        obj.imageDescription = [obj.imageDescription 0];
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
            
            obj.filename = filename;
            %Create TIF file
            try
                obj.createTifFile();
            catch
                error('Unable to construct %s instance: %s',mfilename('class'),lasterr);
            end
            
            %Initialize some class properties
            obj.nominalStripSize = 8*1024; %Determines target number of pixels to place in the strips comprising each frame
            obj.bitsPerSample = 16;
            obj.frameWidth = frameWidth;
            obj.frameHeight = frameHeight;
            obj.imageDescriptionLength = length(obj.imageDescription); %store this so that offset to 'stripOffsets' tag data can be computed
            
            if ~isempty(propNames)
                for i=1:length(propNames)
                    if ismember(lower(propNames{i}),{'nominalstripsize' 'bitspersample'})
                        obj.(propNames{i}) = propVals{i}; %no error checking done on the value itself -- too much work!
                    else
                        fprintf(2,['WARNING: Invalid property name (''' propNames{i} ''') ignored.']);
                    end
                end
            end
            
            
            obj.computeIFDByteData();
            
        end
        
        
        function delete(obj, varargin)
            
            leaveFile = false;
            
            %Process input arguments
            if ~isempty(varargin)
                if strcmpi(varargin{1},'leavefile')
                    leaveFile=true;
                end
            end
            
            %Close file, if it exists and is open
            try
                if ~isempty(obj.fid)
                    fclose(obj.fid);
                end
                
                if ~isempty(obj.filename) && ~leaveFile
                    delete(obj.filename);
                end
            catch
                error(['Error in closing or deleting file, so the file may remain: ' lasterr]);
            end
            
            return;
        end
        
    end
    
    methods
        function value = get(obj, varargin)
            
            names = fieldnames(obj);
            
            if isempty(varargin)
                for i = 1 : length(names)
                    value.(names{i}) = obj.(names{i});
                end
            elseif ~iscellstr(varargin)
                error('Arguments must all be strings, specifying %s property names',mfilename('class'));
            else
                for i=1:length(varargin)
                    [found, idx] = ismember(lower(varargin{i}), lower(names));
                    if ~found
                        error('Invalid property name: ''%s''', varargin{i});
                    else
                        value{i} = obj.(names{idx});
                    end
                end
            end
            
            %Don't return cell array if only one property requested
            if iscell(value) && length(value)==1 %VI042809A
                value = value{1};
            end
        end
        
        function appendFrame(obj,frameData)
            %  Append frame of data to TIF file stream
            %% SYNTAX
            %   hTifStream.appendFrame(frameData)
            %       hTifStream: A handel of the tifStream object
            %       frameData: A matrix of image data, comprising one 'frame'. Must be of the size specified by the @scim_tifStream's imageHeight and imageWidth proprties.
            %
            %% NOTES
            %   Data is converted to the type specified by the @scim_tifStream's pixelDataType property

            
            frameOffset = ftell(obj.fid);
            
            %% Checks 
            if size(frameData,1) ~= obj.frameHeight || size(frameData,2) ~= obj.frameWidth
                obj.delete();
                error('Supplied frame is of incorrect size. File stream has been closed & deleted.');
            end
             
            %% Data type conversion
            switch obj.bitsPerSample
                case 8
                    frameData = uint8(frameData);
                case 16
                    frameData = uint16(frameData);
                case 32
                    frameData = uint32(frameData);
            end
            
            
            %% Append actual frame data
            fwrite(obj.fid, frameData',class(frameData));
            
            %% Adjust IFD & Supplemental IFD data
            
            for i=1:length(obj.IFDOffsets)
                val = obj.IFDOffsetVals(i) + frameOffset;
                indices = obj.IFDOffsets(i):(obj.IFDOffsets(i)+3);
                
                obj.IFDByteData(indices) = obj.makeByteArray(val,4);
            end
            
            for i=1:length(obj.suppIFDOffsets)
                val = obj.suppIFDOffsetVals(i) + frameOffset;
                indices = obj.suppIFDOffsets(i):(obj.suppIFDOffsets(i)+3);
                
                obj.suppIFDByteData(indices) = obj.makeByteArray(val,4);
            end
            
            
            %% Append IFD & Supplementary IFD Data
            fwrite(obj.fid, obj.IFDByteData, 'uint8');
            fwrite(obj.fid, obj.suppIFDByteData, 'uint8');
            
        end
        
        function close(obj)
            % Complete and close the file associated with this @tifstream
            
            lengthSuppIFD = length(obj.suppIFDByteData);
            
            %Adjust the last offset to 'next' IFD to 0000
            fseek(obj.fid,-(lengthSuppIFD+4),'eof');
            fwrite(obj.fid,0,'uint32');
            fclose(obj.fid);
            
            obj.fid = [];
            
            obj.delete('leaveFile'); %This removes the tifstream object
            
            return;
        end
        
    end
    
    methods (Access = private)
        
        function createTifFile(obj)
            
            [path,fname,ext] = fileparts(obj.filename);
            nonTifExt = false;
            if isempty(ext)
                obj.filename = [obj.filename '.tif'];
            elseif ~strcmpi(ext,'.tif')
                nonTifExt = true;
            end
            
            if exist(obj.filename,'file')
                error(['File ' obj.filename ' already exists. A ''scim_tifStream'' object can only be created for a new file.']);
            end
            
            obj.fid = fopen(obj.filename,'w');
            if obj.fid < 0
                error(['Failed to create file ' obj.filename '. Could not construct ' mfilename ' object.']);
            end
            if nonTifExt
                fprintf(2,['File '  fname ext ' does not have a TIF extension, but is a TIF file nonethless.']);
            end
            
            %Write TIF header data
            fwrite(obj.fid,uint8('II')); %Specifies that little-endian byte-ordering is used
            fwrite(obj.fid,42,'uint16'); %Specifies TIFF format version
        end
        
        function computeIFDByteData(obj)
            
            %Fixed Tag values
            compression = 1; %no compression
            photometricInterpretation = 1; %blackIsZero
            orientation = 1; %topLeft
            samplesPerPixel = 1;
            xResolution = [72*16^6 1*16^6]; %resolution = 72
            yResolution = [72*16^6 1*16^6]; %resolution = 72
            planarConfig = 1; %'chunky'
            resolutionUnit = 2; %inches (???)
            
            %Computed tag values
            imageWidth = obj.frameWidth;
            imageLength = obj.frameHeight;
            
            rowsPerStrip = round(obj.nominalStripSize/imageWidth);
            
            numStrips = floor(imageLength/rowsPerStrip);
            if numStrips < 2
                fclose(obj.fid); %VI102609A
                delete(obj.filename);
                error('At this time, images smaller than two strip sizes cannot be supported.'); %Can add this support later, if needed
            end
            
            stripByteCounts = repmat(imageWidth*min(rowsPerStrip,imageLength)*obj.bitsPerSample/8,1,numStrips);
            finalStripRows = mod(imageLength,rowsPerStrip);
            if finalStripRows
                numStrips = numStrips+1;
                stripByteCounts = [stripByteCounts imageWidth*finalStripRows*obj.bitsPerSample/8];
            end
            
            %Useful values
            bytesPerImage = imageWidth*imageLength*(obj.bitsPerSample/8);
            
            %Initialize IFD Byte Data
            obj.IFDByteData = uint8([]);
            if ~isempty(obj.imageDescription)
                numTags = 15;
            else
                numTags = 14;
            end
            obj.IFDByteData = [obj.IFDByteData obj.makeByteArray(numTags,2)];
            
            %Append tags in sequence
            obj.suppIFDByteData = uint8([]);
            obj.IFDOffsets = [];
            obj.IFDOffsetVals = [];
            
            appendValueTag(256,3,1,imageWidth);
            appendValueTag(257,3,1,imageLength);
            appendValueTag(258,3,1,obj.bitsPerSample);
            appendValueTag(259,3,1,compression);
            appendValueTag(262,3,1,photometricInterpretation);
            if ~isempty(obj.imageDescription)
                appendOffsetTag(270,2,length(obj.imageDescription),obj.imageDescription);
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
            fwrite(obj.fid,8+bytesPerImage,'uint32');
            
            %Add offset to next IFD at end of IFD
            obj.IFDOffsets = [obj.IFDOffsets length(obj.IFDByteData)+1];
            obj.IFDByteData = [obj.IFDByteData obj.makeByteArray(0,4)]; %place-holder vale. Actual value filled in during appendFrame()
            obj.IFDOffsetVals = [obj.IFDOffsetVals 2*bytesPerImage+length(obj.IFDByteData)+length(obj.suppIFDByteData)]; %value should be augmented by frameOffset for each frame
            
            %Determine supplementary IFD offset locations and values -- these values should be augmented by frameOffset for each frame
            obj.suppIFDOffsets = [1:4:(4*(length(stripByteCounts)-1)+1)] + length(obj.imageDescription);
            obj.suppIFDOffsetVals = cumsum(stripByteCounts)-stripByteCounts(1);
            
            %Append tag data for cases where data fits into 4 bytes
            function appendValueTag(tagID,type,count,data)
                tagID = obj.makeByteArray(tagID, 2);
                type = obj.makeByteArray(type,2);
                count = obj.makeByteArray(count,4);
                data = obj.makeByteArray(data,4);
                
                obj.IFDByteData = [obj.IFDByteData tagID type count data];
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
                tagID = obj.makeByteArray(tagID, 2);
                type = obj.makeByteArray(type,2);
                count = obj.makeByteArray(count,4);
                obj.IFDByteData = [obj.IFDByteData tagID type count];
                
                obj.IFDOffsets = [obj.IFDOffsets length(obj.IFDByteData)+1]; %Relative offset of offset to adjust
                obj.IFDOffsetVals = [obj.IFDOffsetVals length(obj.suppIFDByteData) + numTags*12 + 6 + bytesPerImage];
                
                offset = obj.makeByteArray(0,4); %Placeholder value -- actual value will be computed during appendFrame()
                obj.IFDByteData = [obj.IFDByteData offset];
                
                obj.suppIFDByteData = [obj.suppIFDByteData obj.makeByteArray(tagData,numBytes)];
            end
            
        end
        
        function byteArray = makeByteArray(obj,val,numBytes)
            % Make an array of bytes of specified length from the specified value
            %% SYNTAX
            %   byteArray = makeByteArray(val,numBytes)
            %       val: Value, or array of values, to be written out
            %       numBytes: Number of bytes to write per value; zeros will be appended if needed
            %       byteArray: Array of bytes (i.e. 'uint8' type) representing value, with zeros appended as required
            %
            %% *************************************************

            
            byteArray = uint8([]);
            for i=1:length(val)
                %Limits checking
                if val(i) > 2^(numBytes*8)-1
                    error(['Value (' val(i) ') exceeds that allowed for specified number of bytes']);
                end
                %val(i) = uint32(i);
                val(i) = double(val(i));

                byteVals = uint8(zeros(1,numBytes));
                byteCount = 0;
                for j=numBytes:-1:1
                    byteVals(j) = uint8(floor(val(i)/(2^(8*(j-1)))));
                    val(i) = val(i) - double(byteVals(j))*2^(8*(j-1));
                    if byteVals(j) ~= 0
                        byteCount = max(byteCount,j);
                    end
                end
                
                byteArray = [byteArray byteVals]; %append to array
                
            end
        end
    end
end

