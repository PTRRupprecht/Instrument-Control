function photonStats = scim_photonStats(varargin)
%SCIM_PHOTONSTATS Compute photon statistics from a ScanImage image file or active channel display window
%
%% SYNTAX
%   photonStats = scim_photonStats(prop1,val1,prop2,val2,...)
%       photonStats: structure of computed photon statistics pertaining to image region(s) analyzed. 
%          structure values are scalars, arrays, or matrices depending on image type
%       
%       Properties:
%           'file': Value specifies full name of file containing image data to analyze.   
%           'channel': Value specifies which single channel to use. Must be specified unless there's only one acquired channel.
%           'userRects': Value (scalar) specifies number of rectangles user will draw. Statistics will be calculated for each of these.
%           'tiledRects: Value (2-element vector) specifies [horizontal vertical] number of tiles to subdivide image area into
%           'frames': Value (scalar or array) specifies frame or frames (to average) to use for analysis. Value of 'inf' means to use the last frame. Only valid when analyzing data from saved file.
%           'darkNoiseCorection': Value is either 1) a scalar specifying mean dark noise, 2) a 2-element array specifying mean & standard deviation of dark noise, or 3) a filename containing image collected under dark conditions
%           
%       Notes:
%           If neither 'userRects' nor 'tiledRects' are specified, then statistics are calculated for whole image
%   
%           Property values are case-sensitive
%                     
%% CREDITS
%   Created 6/8/11, by Vijay Iyer
%% **************************************************


persistent startPath

%argStruct = struct(most.util.filterPVArgs(varargin,{'file' 'channel' 'userRects' 'tiledRects' 'frames'}));
try 
    argStruct = struct(varargin{:});
catch ME
    error('Arguments must be in property/value pair format');
end

imageFile = '';
useChanDisplay = false;

if isfield(argStruct,'file')
    imageFile = argStruct.file;    
     
else
    runningVersion = scim_isRunning();
    if runningVersion > 0
        
        if isfield(argStruct,'channel')
            useChanDisplay = true;
        end
        
        if runningVersion == 4 %ScanImage 4
            siVersion = 4;            
            %TODO: Handle running SI4
        else
            siVersion = 3;
            
            %Use channel display window from live ScanImage session
            global state %#ok<TLEV>
            hdr = state;
            
            if state.acq.numberOfChannelsAcquire == 1
                useChanDisplay = true;
            end
        end
    end
    
    %Prompt for file, if needed        
    if ~useChanDisplay
        if isempty(startPath)
            startPath = most.idioms.startPath();
        end
        
        [f,p] = uigetfile(fullfile(startPath,'*.tif'),'Select ScanImage TIF File');
        
        if isnumeric(f) %selection cancelled
            return;
        else
            startPath = p; %Cache start path for next selection
            imageFile = fullfile(p,f);
        end            
    end
end

if ~isempty(imageFile)
    s = warning('query');
    warning('off');
    hTif = Tiff(imageFile);
    warning(s);
    
    
    pixelsPerLine = hTif.getTag('ImageWidth');
    linesPerFrame = hTif.getTag('ImageLength');
    
    imageDescription = hTif.getTag('ImageDescription');
    if strncmp(imageDescription,'state',5) %SI3            
        hdr = parseHeader(imageDescription); 
        siVersion = 3;
    else 
        hdr = most.util.assignments2StructOrObj(imageDescription);
        if isfield(hdr,'SI4App')
            hdr = hdr.SI4App;
        else
            hdr = hdr.SI4;
        end
        siVersion = 4;
    end
else
    hdr = state;
end

%Extract needed quantities
quantities = {'numberOfChannelsAcquire' 'numberOfFrames'};

switch siVersion
    case 3
        for i=1:length(quantities)
            imageProps.(quantities{i}) = hdr.acq.(quantities{i});
        end
    case 4
        imageProps.numberOfChannelsAcquire = length(hdr.channelsActive);
        imageProps.numberOfFrames = hdr.acqNumFrames;
end


if isfield(argStruct,'channel')
    channel = argStruct.channel;
elseif imageProps.numberOfChannelsAcquire == 1
    if siVersion == 3
        channel = find(arrayfun(@(x)hdr.acq.(['acquiringChannel' num2str(x)]),1:4));
    else
        channel = hdr.channelsActive; %should be a scalar
    end
else
    error('The ''channel'' prop/value must be specified except in case where only one channel is acquired');
end
    
if useChanDisplay
    %TODO: Handle SI4 case
    imageData = state.acq.acquiredData{1}{channel}; %Use most-recent frame
else
    argList = {'channels',channel};
    
    if isfield(argStruct,'frames')
        if isinf(argStruct.frames)
            frames = imageProps.numberOfFrames;
        else
            frames = argStruct.frames;
        end
        
        argList = [argList {'frames' frames}];
    end       
   
    if siVersion == 3
        [~,imageData] = scim_openTif(imageFile,argList{:});
    else
        %TODO: Either use improved (SI4 compliant) scim_openTif OR
        %       more correctly compute image index here (account for slices, averaging, unusual channel assignments/ordering, etc)
        
        idx = imageProps.numberOfChannelsAcquire * (imageProps.numberOfFrames - 1) + channel; %TODO: Fix this to be more universally accurate!
        
        try 
            imageData = imread(imageFile,'Index',idx);
        catch ME
            %Handle case where a frame was skipped 
            if strcmpi(ME.identifier,'MATLAB:rtifc:invalidDirIndex');
                if imageProps.numberOfChannelsAcquire == 1 && idx == imageProps.numberOfFrames
                    idx = idx - 1;
                end
                
                imageData = imread(imageFile,'Index',idx);
            end
        end
            
    end
end

%Determine regions of interest
As = {};
d = [0 0];

if isfield(argStruct,'userRects')
    %TODO!
elseif isfield(argStruct,'tiledRects')
    %Subdivide pixels into tiles
    
    h = argStruct.tiledRects(1);
    v = argStruct.tiledRects(2);
    
    %     pixelsPerLine = hdr.acq.pixelsPerLine;
    %     linesPerFrame = hdr.acq.linesPerFrame;
    
    hBoundaries = round(linspace(1,pixelsPerLine,h+1));
    vBoundaries =  round(linspace(1,linesPerFrame,v+1));
    
    As = cell(v,h);
    for i=1:v
        for j=1:h
            As{i,j} = imageData(vBoundaries(j):vBoundaries(j+1),hBoundaries(i):hBoundaries(i+1));                        
        end                        
    end
    
else
    As = {imageData}; %Use whole image
end

%Determine dark noise data
if isfield(argStruct,'darkNoiseCorection')
    argErrorMsg = 'The ''darkNoiseCorrection'' value must be a scalar, 2-element array, or a valid ScanImage TIF filename';
    dncVal = argStruct.darkNoiseCorrection;
    if isnumeric(dncVal)
        if isscalar(dncVal)
            d = [dncVal 0]; %Just correct for mean
        elseif numel(dncVal) == 2
            d = dncVal; %Mean & std were specified
        else
            error(argErrorMsg);
        end
    elseif ischar(dncVal)
        try
            [~,darkImageData] = scim_openTif(dncVal,argList{:});
        catch ME
            error(argErrorMsg);
        end
        
           
        %TODO: Determine d value(s) from dark image data

        
    else
        error(argErrorMsg);
    end
    
    
    
end
    

%Compute image statistics
statFields = {'mean' 'std' 'photonsPerPixel' 'pixelGain'};
for i=1:length(statFields)    
    photonStats.(statFields{i}) = zeros(size(As));
end

for i=1:numel(As)
    s = computePhotonStats(As{i},d);
    
    for j=1:length(statFields)
        photonStats.(statFields{j})(i) = s.(statFields{j});        
    end    
end


end

function s = computePhotonStats(A,d)
A = double(A);

s.mean = mean(A(:)) - d(1);
s.std = sqrt(std(A(:))^2 - d(2)^2);
s.photonsPerPixel = (s.mean/s.std)^2;
s.pixelGain = (s.std^2/s.mean);
end


    



