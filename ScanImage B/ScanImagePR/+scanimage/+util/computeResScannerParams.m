function s = computeResScannerParams(freq,pixelsPerLine,varargin)
%COMPUTERESSCANNERPARAMS Compute parameters associated with resonant scanning
%
%    freq: Frequency of res scanner, in Hz
%    pixelsPerLine: Number of pixels to use per line
%    varargin: prop-value pairs
%    s: structure of computed parameters
%
%    PV Pairs:
%      REQUIRED (one or the other)
%        'spatialFF': Spatial fill-fraction, value from 0 to 1
%        'temporalFF': Temporal fill-fraction, value from 0 to 1
%
%      OPTIONAL
%        'pixelMode': <One of {'spanPeriod' 'spanFF' 'spanPeriodAdjustParams'}; Default='spanPeriod'> 
%               If 'spanFF', the specified pixelsPerLine span the specified fill fraction. 
%               If 'spanPeriod'/'spanPeriodAdjustParams', the spec'd pixelsPerLine span the entire period. 
%               If 'spanPeriodAdjustParams' is selected, the computed total/min/max/mean pixel times pertain only to those pixels within the spec'd fill fraction.
%        'outputSpaceTimeData': <Default=false> If true, the computed arrays of pixel time and normalized spatial coordinate values are included in the output structure
%        'showDwellTimePlot': <Default=false> If true, a plot of dwell time vs pixel number is shown
%
% NOTES
%    This function assumes that bidirectional imaging is employed, i.e. that pixels are collected in both directions of the sinusoidal period
%

s = struct();

%Process PV args
pv = most.util.cellPV2structPV(varargin);

if isfield(pv,'spatialFF') && ~isfield(pv,'temporalFF')
    s.spatialFF = pv.spatialFF;
elseif isfield(pv,'temporalFF') && ~isfield(pv,'spatialFF')
    s.temporalFF = pv.temporalFF;
else
    error('One, but not both, of {''temporalFF'', ''spatialFF''} must be specifed');
end

%Fill in defaults
pvFields = {'pixelMode' 'showDwellTimePlot' 'outputSpaceTimeData'};
pvDefaultVals = {'spanPeriod' false false};
for i=1:length(pvFields)
    if ~isfield(pv,pvFields{i})
        pv.(pvFields{i}) = pvDefaultVals{i};
    end
end

%Verify PV args
assert(ismember(pv.pixelMode,{'spanPeriod' 'spanFF' 'spanPeriodAdjustParams'}),'Unexpected value for supplied ''pixelMode'' argument');

%Compute spatial or temporal trajectory
w = 2*pi*freq;

if isfield(pv,'spatialFF') %spatial FF supplied
    
    znstComputePixelDwellTimes(pv.spatialFF);
    s.temporalFF = s.totalPixelTime * freq * 2; %Determine fraction of half-period
    
else %temporal FF supplied
    
    tRadians = pv.temporalFF * pi/2;
    s.spatialFF = sin(tRadians);
    
    znstComputePixelDwellTimes(s.spatialFF);
    
    if strcmpi(pv.pixelMode,'spanPeriodAdjustParams')
        assert(abs(s.temporalFF - s.totalPixelTime * freq * 2) < .05, 'Greater than 5% discrepancy between supplied temporal FF and that computed after processing');
    elseif strcmpi(pv.pixelMode,'spanPeriod')
        assert(abs(1 - s.totalPixelTime * freq * 2) < .01, 'Greater than 1% discrepancy between supplied temporal FF and that computed after processing');
    elseif strcmpi(pv.pixelMode,'spanFF')
        assert(abs(s.temporalFF - s.totalPixelTime * freq * 2) < .01, 'Greater than 1% discrepancy between supplied temporal FF and that computed after processing');

    end
end

    function znstComputePixelDwellTimes(spatialFF)
        switch pv.pixelMode
            case 'spanFF'
                xAmp = spatialFF;
            case {'spanPeriod' 'spanPeriodAdjustParams'}
                xAmp = 1;
        end

        
        dx = (2*xAmp)/pixelsPerLine;
        x = (-xAmp+dx/2):dx:(xAmp-dx/2);
        
        %x = sin(w*t). Compute times for each of the evenly-spaced pixels.
        dx = x(2)-x(1);
        
        if strcmpi(pv.pixelMode,'spanPeriodAdjustParams')
           ignoreNumPix = pixelsPerLine - round(spatialFF * pixelsPerLine);
           if ignoreNumPix > 0
               ignoreNumPix1 = round(ignoreNumPix/2);
               ignoreNumPix2 = ignoreNumPix - ignoreNumPix1;
               
               ignoreIdxs = [1:ignoreNumPix1 pixelsPerLine-ignoreNumPix2+1:pixelsPerLine];
               x(ignoreIdxs) = [];
           end
        end
        
        dt = asin(x+dx/2)/w - asin(x-dx/2)/w;
                
        s.totalPixelTime = sum(dt);
        
        %Compute scan parameters
        s.meanPixelTime = mean(dt);
        s.minPixelTime = min(dt);
        s.maxPixelTime = max(dt);
        
        s.pixelTimeRatio = s.maxPixelTime/s.minPixelTime;
        
        if pv.outputSpaceTimeData
            s.x = x; %Normalized pixel coordinates
            s.dt = dt; %Dwell times
        end
        
        if pv.showDwellTimePlot
            figure;
            plot(x,dt*1e9);
            xlabel('Normalized Pixel Coordinate');
            ylabel('Dwell Time (ns)');
        end
        
    end

end

