% ia_updatePhotometryValues - Do all calculations and update GUIs for the photometry window.
%
% SYNTAX
%  ia_updatePhotometryValues(hObject)
%  ia_updatePhotometryValues(hObject, channel)
%    hObject - The handle to the photometry window.
%    channel - Force calculations on a specific channel.
%
% USAGE
%
% NOTES
%
% CHANGES
%   5/30/05 - Added Sen's function, `shiftDendriteMax`, with quite a few assorted changes and 
%             support for image registration. -- Tim O'Connor 5/30/05 TO053005A
%   TO080707 - Process photometry across multiple channels, for ratiometric imaging (or whatever your heart desires). -- Tim O'Connor 8/7/07
%   TO090507A - Don't subtract the background from the integral. -- Tim O'Connor 9/5/07
%   TO091707A - Don't subtract the background from the normalization. Don't subtract the minimum pixel value from the integral -- Tim O'Connor 9/17/07
%   TO122209E - The pop-up dialog was too annoying, so just print a message instead. -- Tim O'Connor 12/22/09
%
% Created 2/16/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ia_updatePhotometryValues(hObject, varargin)

hObject = getMain(progmanager, hObject, 'photometryWindow');
allimdata = getMain(progmanager, hObject, 'originalImage');
%TO080707A
if isempty(varargin)
    currentChannel = getMain(progmanager, hObject, 'currentChannel');
else
    currentChannel = varargin{1};
end
imdata = allimdata{currentChannel};
frame = getMain(progmanager, hObject, 'frameNumber');

% imdata = imdata(:, :, getMain(progmanager, hObject, 'frameNumber'));

minimumPixelValue = min(min(imdata(:, :, frame)));
setLocal(progmanager, hObject, 'minimumPixelValue', minimumPixelValue);

backgroundSelection = getLocal(progmanager, hObject, 'backgroundRegion');
if ~isempty(backgroundSelection)
    %TO080707
    if isempty(varargin)
        backgroundChannel = getLocal(progmanager, hObject, 'backgroundChannel');
    else
        backgroundChannel = varargin{1};
    end
    if currentChannel ~= backgroundChannel
        backgroundimdata = allimdata{backgroundChannel};
    else
        backgroundimdata = imdata;
    end
    bgFrame = getLocal(progmanager, hObject, 'backgroundFrame');
    if isempty(bgFrame)
        bgFrame = frame;
    end
    setLocal(progmanager, hObject, 'backgroundFrameDisplay', bgFrame);
    backgroundRegion = carveRegion(hObject, backgroundimdata(:, :, bgFrame), backgroundSelection);
    background = mean2(backgroundRegion);%TO080707A: Do not subtract the min here...% - min(min(backgroundimdata(:, :, bgFrame)));
    setLocal(progmanager, hObject, 'backgroundValue', roundTo(background, 2));
else
    backgroundRegion = 0;
    background = 0;
    setLocal(progmanager, hObject, 'backgroundValue', roundTo(background, 2));
end

normalizationSelection = getLocal(progmanager, hObject, 'normalizationRegion');
if ~isempty(normalizationSelection)
    if getLocal(progmanager, hObject, 'recalculateNormalization')
        %TO080707
        if isempty(varargin)
            normalizationChannel = getLocal(progmanager, hObject, 'normalizationChannel');
        else
            normalizationChannel = varargin{1};
        end
        if currentChannel ~= normalizationChannel
            normalizationImage = allimdata{normalizationChannel};
        else
            normalizationImage = imdata;
        end
        bounds = getLocal(progmanager, hObject, 'normalizationRegion');
        setLocal(progmanager, hObject, 'recalculateNormalization', 0);
        optimizeVoxel = 1;
        if ~getMain(progmanager, hObject, 'optimizePhotometryNormalization')
            voxel2 = getLocal(progmanager, hObject, 'normalizationVoxel');
            if ~isempty(voxel2)
                optimizeVoxel = 0;
            end
        end
        if optimizeVoxel
            x = bounds(1, :);
            y = bounds(2, :);

            x1 = [];
            y1 = [];
            if length(x) < 100 || length(y) < 100
                for i = 2 : length(x)
                    samples = ceil(max(abs(x(i-1)-x(i)), abs(y(i)-y(i-1))));
                    if x(i) ~= x(i - 1)
                        x1(length(x1) + 1 : length(x1) + samples + 1) = x(i - 1) : (x(i) - x(i-1)) / samples : x(i);
                    else
                        x1(length(x1) + 1 : length(x1) + samples + 1) = x(i);
                    end
                    if y(i) ~= y(i - 1)
                        y1(length(y1) + 1 : length(y1) + samples + 1) = y(i - 1) : (y(i) - y(i-1)) / samples : y(i);
                    else
                        y1(length(y1) + 1 : length(y1) + samples + 1) = y(i);
                    end
                end
            else
                x1 = x;
                y1 = y;
            end
%         normalizationImage = get(getMain(progmanager, hObject, 'globalImage'), 'CData');%Max project first, then maximize in single plane.
%     [voxel, voxelmax, maxint, dx, dy] = shiftDendriteMax(voxel, imdata, 1);%Sen's function.
            voxel = cat(1, y1, x1, frame * ones(size(x1)));
            if ~isempty(voxel) && ~any(any(voxel < 1))
                tform = getMain(progmanager, hObject, 'registrationTransform');
                if ~isempty(tform)
                    %Registered
                    voxel = tformfwd(voxel, tform);
                end
                voxel = shiftDendriteMax(voxel, normalizationImage, 0);%Sen's function.
                setLocal(progmanager, hObject, 'normalizationRegion', voxel([2 1], :));
                voxel2 = normalizationImage(sub2ind(size(normalizationImage), voxel(1, :), voxel(2, :), voxel(3, :)));%TO091707A - Don't subtract background here.
                setLocal(progmanager, hObject, 'normalizationVoxel', voxel2);
            else
                warning('Selected normalization voxel contains out of bounds value(s).');
                voxel = [];
                voxel2 = [];
            end
        end

        normalizationMethod = getLocal(progmanager, hObject, 'normalizationMethod');
        switch normalizationMethod
            case 1
                normalizationFactor = median(voxel2);
            case 2
                normalizationFactor = mean(voxel2);
            case 3
                normalizationFactor = trimmean(voxel2, 10);
            otherwise
                warning('Unrecognized normalization method, using median.');
                normalizationFactor = median(voxel2);
        end
% im = zeros(size(normalizationImage));
% im(sub2ind(size(normalizationImage), voxel(1, :), voxel(2, :), ones(1, size(voxel, 2)) * frame)) = voxel2;
% figure, imagesc(im(:, :, frame), [0 200]); colormap(gray); get(gcf)
% figure, hist(voxel2, 60);
% figure, plot3(voxel(1, :), voxel(2, :), voxel2, '-o'), set(gca, 'XLim', [0 512], 'YLim', [0 512]);, xlabel('X'), ylabel('Y'), zlabel('Z')
% figure, plot3(voxel(1, :), voxel(2, :), voxel(3, :), '-o'), set(gca, 'XLim', [0 512], 'YLim', [0 512]);, xlabel('X'), ylabel('Y'), zlabel('Z')
        setLocal(progmanager, hObject, 'normalizationFactor', roundTo(normalizationFactor, 2));
    else
        normalizationFactor = getLocal(progmanager, hObject, 'normalizationFactor');
        normalizationRegion = getLocal(progmanager, hObject, 'normalizationRegion');
    end
else
    normalizationRegion = 1;
    normalizationFactor = 1;
    setLocal(progmanager, hObject, 'normalizationFactor', roundTo(normalizationFactor, 2));
end

integralSelection = getLocal(progmanager, hObject, 'integralRegion');
if ~isempty(integralSelection)
    %TO080707
    if isempty(varargin)
        integralChannel = getLocal(progmanager, hObject, 'integralChannel');
    else
        integralChannel = varargin{1};
    end
    if integralChannel ~= currentChannel
        integralImage = allimdata{integralChannel};
    else
        integralImage = imdata;
    end
    intFrame = getLocal(progmanager, hObject, 'integralFrame');
    if isempty(intFrame)
        intFrame = frame;
    end
    setLocal(progmanager, hObject, 'integralFrameDisplay', intFrame);
    integralRegion = carveRegion(hObject, integralImage(:, :, intFrame), integralSelection);
    integral = sum(sum(integralRegion));%TO090507A - Don't subtract the background here. TO091707A - Don't subtract the minimum pixel value here.
    setLocal(progmanager, hObject, 'intensityIntegral', roundTo(integral, 0));
    setLocal(progmanager, hObject, 'integralPixelCount', prod(size(integralRegion)));%TO080507D
else
    integralRegion = 0;
    integral = 0;
    setLocal(progmanager, hObject, 'intensityIntegral', roundTo(integral, 0));
end

if ~(isempty(integralSelection) | isempty(normalizationSelection) | isempty(backgroundSelection)) & strcmpi(get(getParent(hObject, 'figure'), 'Visible'), 'On') & ...
        getLocal(progmanager, hObject, 'showRegions')
    warnMsg = '';

%     if integral > normalizationFactor * prod(size(integralRegion))
%         warnMsg = sprintf('%s  The normalization region is too dim.\n', warnMsg);
%     end
    if background > normalizationFactor | background > integral
        warnMsg = sprintf('%s  Background level too high.\n', warnMsg);
    end
    
    if ~isempty(warnMsg)
        %warndlg(sprintf('There appear to be errors in the photometry region selections:\n%s', warnMsg));
        fprintf(1, 'ia_updatePhotometryValues Warning: There appear to be errors in the photometry region selections:\n%s\n', warnMsg);%TO122209E
    end
end

calculated = (integral - background * prod(size(integralRegion))) / (normalizationFactor - background);%TO091707A
setLocal(progmanager, hObject, 'normalizedBackgroundSubtractedIntegral', roundTo(calculated, 2));

ia_redrawRegions(hObject);

return;

% ------------------------------------------------------------------
function region = carveRegion(hObject, image, bounds)

if isempty(bounds)
    region = [];
    return;
elseif bounds(1, 1) == bounds(1, end) & bounds(2, 1) == bounds(2, end)
    %Take care of image registration.
    tform = getMain(progmanager, hObject, 'registrationTransform');
    if ~isempty(tform)
        %Registered
        bounds = tformfwd(bounds', tform)';
    end
    
    region = image(find(roipoly(image, bounds(1, :), bounds(2, :)) == 1));
else
% %     x = cat(2, bounds(1, :), floor(bounds(1, size(bounds, 2) : -1 : 1)), ceil(bounds(1, size(bounds, 2) : -1 : 1)));
% %     y = cat(2, bounds(2, :), floor(bounds(2, size(bounds, 2) : -1 : 1)), ceil(bounds(2, size(bounds, 2) : -1 : 1)));
%     x1 = bounds(1, :);
%     y1 = bounds(2, :);
%     x = [];
%     y = [];
%     for i = 1 : 2 : length(x1)
%         xStep = max(0.01, abs(x1(i) - x1(i + 1)));
%         yStep = max(0.01, abs(y1(i) - y1(i + 1)));
%         step = max(xStep, yStep);
% xStep
% yStep
% step
%         if x1(i) < x1(i + 1)
%             x = cat(2, x, x1(i) : 1 : x1(i + 1));
%         else
%             x = cat(2, x, x1(i + 1) : 1  : x1(i));
%         end
%         if y1(i) < y1(i + 1)
%             y = cat(2, y, y1(i) : 1  : y1(i + 1));
%         else
%             y = cat(2, y, y1(i + 1) : 1  : y1(i));
%         end
% %         step = max(abs(x1(i) - x1(i + 1)), abs(y1(i) - y1(i + 1)));
% %         x = cat(2, x, x1(i) : step / abs(x1(i) - x1(i + 1)) : x1(i + 1));
% %         y = cat(2, y, y1(i) : step / abs(y1(i) - y1(i + 1)) : y1(i + 1));
% 
%         x = cat(2, floor(x), floor(x), ceil(x), ceil(x));
%         y = cat(2, floor(y), ceil(y), floor(y), ceil(y));
%     end
% xSize = size(x)
% ySize = size(y)
%         region = image(x, y);
%    
% figure;
% im2 = zeros(size(image));
% im2(x, y) = image(x, y);
% imagesc(im2);
% %         if abs(x1(i) - x1(i + 1)) > abs(y1(i) - y1(i + 1))
% %             if x1(i) < x1(i + 1)
% %                 x = floor(x1(i)) : ceil(x1(i + 1));
% %             else
% %                 x = floor(x1(i + 1)) : ceil(x1(i));
% %             end
% %         else
% %         end
end

return;

% ------------------------------------------------------------------
function contextMenuHide(hObject)

setLocal(progmanager, hObject, 'showRegions', 0);
ia_updatePhotometryValues(hObject);

return;