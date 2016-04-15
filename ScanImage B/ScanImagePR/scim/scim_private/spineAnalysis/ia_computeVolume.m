%% CHANGES 
%   VI071310A: Use getRectFromAxes() for selection of rectangular area -- Vijay Iyer 7/13/10
%

function volume = ia_computeVolume(varargin);

hObject = varargin{3};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Tuning parameters.
% setLocal(progmanager, hObject, 'volumeDistanceMaskThreshold', [.6]);
% setLocal(progmanager, hObject, 'volumeDistanceMaskThresholdFactor', [0]);
% setLocal(progmanager, hObject, 'volumeDistanceFactor', 2);
% 
% setLocal(progmanager, hObject, 'volumeWeightDistanceMask', 1);
% setLocal(progmanager, hObject, 'volumeWeightEdgeMask', 1);
% setLocal(progmanager, hObject, 'volumeWeightProfileMask', 1);
% 
% setLocal(progmanager, hObject, 'volumeEdgeFilterStrength', 5);
% 
% setLocal(progmanager, hObject, 'volumeRegionSizeFactor', 2);
% 
% setLocal(progmanager, hObject, 'volumeBinarizeDistanceMask', 0);
% 
% setLocal(progmanager, hObject, 'volumeProfileRadiusFactor', 10);
% setLocal(progmanager, hObject, 'volumeProfileCenterWeight', .5);
% setLocal(progmanager, hObject, 'volumeProfileThresholds', [1 2]);
% setLocal(progmanager, hObject, 'volumeProfileValues', [1 .5]);
% 
% setLocal(progmanager, hObject, 'volumeThresholdFactor', 0.1);
% 
% setLocal(progmanager, hObject, 'volumeFrameWindow', 6);
% setLocal(progmanager, hObject, 'volumeAutoSelectRegion', 0);
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

annotations = getLocal(progmanager, hObject, 'annotations');
index = getLocal(progmanager, hObject, 'currentAnnotation');
im = getLocal(progmanager, hObject, 'primaryImage');
imdata = getLocal(progmanager, hObject, 'originalImage');
imdata = imdata{getLocal(progmanager, hObject, 'currentChannel')};

annotation = annotations(index);
len = sqrt(abs(diff(annotation.x))^2 + abs(diff(annotation.y))^2);
    
if ~getLocal(progmanager, hObject, 'volumeAutoSelectRegion')
    if getGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl')
        return;
    end    
    setGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl', 1);
    rect = getRectFromAxes(getLocalGh(progmanager, hObject, 'primaryView'),'nomovegui',1); %VI071310A
    
    setGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl', 0);
    
    %Convert the rect coordinates into region bounds, enforce the image size.
    xMin = max([1 floor(rect(1))]);
    xMax = min([size(imdata, 2) (xMin + ceil(rect(3)))]);
    yMin = max([1 floor(rect(2))]);
    yMax = min([size(imdata, 2) (yMin + ceil(rect(4)))]);
    
    %Watch out for things crossing out of the box's bounds.
    if annotation.x(1) < xMin
        annotation.x(1) = xMin;
    end
    if annotation.x(2) < xMin
        annotation.x(2) = xMin;
    end
    if annotation.x(1) > xMax
        annotation.x(1) = xMax;
    end
    if annotation.x(2) > xMax
        annotation.x(2) = xMax;
    end
    if annotation.y(1) < yMin
        annotation.y(1) = yMin;
    end
    if annotation.y(2) < yMin
        annotation.y(2) = yMin;
    end
    if annotation.y(1) > yMax
        annotation.y(1) = yMax;
    end
    if annotation.y(2) > yMax
        annotation.y(2) = yMax;
    end
else
    %Find the bounds for a region of interest, based on this annotation.
    regionSizeFactor = getLocal(progmanager, hObject, 'volumeRegionSizeFactor');
    xMin = floor(max([(min(annotation.x) - 1 / regionSizeFactor * len) 1]));
    xMax = min([ceil(xMin + regionSizeFactor * len) size(imdata, 1)]);
    yMin = floor(max([(min(annotation.y) - 1 / regionSizeFactor * len) 1]));
    yMax = min([ceil(yMin + regionSizeFactor * len) size(imdata, 1)]);
end

%Determine the angle of the annotation (0 degrees == 3 o'clock in the image plane), in pixel coordinates.
if annotation.x(1) < annotation.x(2) & (annotation.y(1) < annotation.y(2) | diff(annotation.x(:)) == 0)
    %++ Quadrant
    phi = 180 / pi * asin(diff(annotation.y) / len);
elseif (annotation.x(1) > annotation.x(2) | diff(annotation.x(:)) == 0) & annotation.y(1) < annotation.y(2)
    %-+ Quadrant
    phi = 180 / pi * asin(-diff(annotation.x) / len) + 90;
elseif annotation.x(1) > annotation.x(2) & (annotation.y(1) > annotation.y(2) | diff(annotation.y(:)) == 0)
    %-- Quadrant
    phi = 90 - (180 / pi * asin(-diff(annotation.x) / len)) + 180;
elseif (annotation.x(1) < annotation.x(2) | diff(annotation.x(:)) == 0) & annotation.y(1) > annotation.y(2)
    %+- Quadrant
    phi = (180 / pi * asin(diff(annotation.x) / len)) + 270;
else
    %How could there be no change in either dimension? That'd be a point, not a line.
    error('Annotations must have some extent, in at least 1 dimension, in order to compute volumes.');
end

%Trim off anything behind the root.
%If you consider it as vertical/horizontal (+/- 25 degrees, for now), the root should be at the middle of one of the edges.
if phi < 25 | phi > 335
    xMin = max([0 (xMin - abs(xMax - ceil(annotation.x(1))))]);
    xMax = ceil(annotation.x(1));
elseif 65 < phi & phi < 115
    yMax = min([size(imdata, 2) (yMax + abs(yMin - floor(annotation.y(1))))]);
    yMin = floor(annotation.y(1));
elseif 155 < phi & phi < 205
    xMax = min([size(imdata, 1) (xMax + abs(xMin - floor(annotation.x(1))))]);
    xMin = floor(annotation.x(1));
elseif 245 < phi & phi < 295
    yMin = min([size(imdata, 2) (yMin - abs(yMax - ceil(annotation.y(1))))]);
    yMax = ceil(annotation.y(1));
else
    %If it's more than 25 degrees off-parallel with an image edge, root it at the corner of the region's rectangle.
    if annotation.x(1) < annotation.x(2)
        xMin = floor(annotation.x(1));
    else
        xMax = ceil(annotation.x(1));
    end
    if annotation.y(1) < annotation.y(2)
        yMin = floor(annotation.y(1));
    else
        yMax = ceil(annotation.y(1));
    end
end

%Carve out the relevant region.
%Note the order of x and y.
% frameNumber = getLocal(progmanager, hObject, 'frameNumber');
frameNumber = annotation.z(1);
region = imdata(yMin : yMax, xMin : xMax, frameNumber);

%Subtract background.
region = region - min(min(region));

%Find the centerpoint of the annotation.
centerWeight = getLocal(progmanager, hObject, 'volumeProfileCenterWeight');

if ceil(annotation.x(2)) > floor(annotation.x(1))
    centerX = annotation.x(1) - xMin  + centerWeight * (annotation.x(2) - annotation.x(1));
else
    centerX = annotation.x(2) - xMin  + centerWeight * (annotation.x(1) - annotation.x(2));
end
if ceil(annotation.y(2)) > floor(annotation.y(1))
    centerY = annotation.y(1) - yMin  + centerWeight * (annotation.y(2) - annotation.y(1));
else
    centerY = annotation.y(2) - yMin  + centerWeight * (annotation.y(1) - annotation.y(2));
end

%Filter it, then threshold it, to bring out edges.
filterStrength = getLocal(progmanager, hObject, 'volumeEdgeFilterStrength');
edgeMask = wiener2(region, [filterStrength filterStrength]);
dynamicRange = max(max(edgeMask)) - min(min(edgeMask));
threshold = getLocal(progmanager, hObject, 'volumeThresholdFactor') * dynamicRange;
edgeMask(find(edgeMask < threshold)) = 0;
edgeMask(find(edgeMask >= threshold)) = 1;

%Make a mask that has highest intensity at the annotation line, and
%falls off as you move away.
distanceMask = region;
distanceMask(:, :) = 0;
xExtent = abs(ceil(annotation.x(2)) - floor(annotation.x(1)));
yExtent = abs(ceil(annotation.y(2)) - floor(annotation.y(1)));
steps = max([xExtent yExtent]);
if ceil(annotation.x(2)) > floor(annotation.x(1))
    xs = round(floor(annotation.x(1)) - xMin  + 1 : xExtent / steps : ceil(annotation.x(2)) - xMin + 1);
else
    xExtent = abs(ceil(annotation.x(1)) - floor(annotation.x(2)));
    xs = round(floor(annotation.x(2)) - xMin + 1 : xExtent / steps : ceil(annotation.x(1)) - xMin + 1);
    xs = xs(end : -1 : 1);
end
if ceil(annotation.y(2)) > floor(annotation.y(1))
    ys = round(floor(annotation.y(1)) - yMin  + 1 : yExtent / steps : ceil(annotation.y(2)) - yMin + 1);
else
    yExtent = abs(ceil(annotation.y(1)) - floor(annotation.y(2)));
    ys = round(floor(annotation.y(2)) - yMin + 1 : yExtent / steps : ceil(annotation.y(1)) - yMin + 1);
    ys = ys(end : -1 :  1);
end

xs2 = xs;
ys2 = ys;

%Thicken the line up, accordingly.
distanceFactor = getLocal(progmanager, hObject, 'volumeDistanceFactor');
if distanceFactor > 1
    for i = 1 : distanceFactor
        xs2 = cat(2, xs2, xs + i);
        ys2 = cat(2, ys2, ys + i);
        xs2 = cat(2, xs2, xs - i);
        ys2 = cat(2, ys2, ys - i);
        xs2 = cat(2, xs2, xs + i);
        ys2 = cat(2, ys2, ys - i);
        xs2 = cat(2, xs2, xs - i);
        ys2 = cat(2, ys2, ys + i);
    end
end

%Watch out for boundaries.
xs2(find(xs2 < 1)) = 1;
xs2(find(xs2 > size(distanceMask, 2))) = size(distanceMask, 2);
ys2(find(ys2 < 1)) = 1;
ys2(find(ys2 > size(distanceMask, 1))) = size(distanceMask, 1);
for i = 1 : length(xs2)
    if ~(size(distanceMask, 2) < xs2(i) & size(distanceMask, 1) < ys2(i))
        distanceMask(ys2(i), xs2(i)) = 1;
    end
end

%Compute a gradient.
distanceMask = bwdist(distanceMask);

%Normalize and invert.
dmMax = max(max(distanceMask));
distanceMask = imabsdiff(distanceMask, dmMax * ones(size(distanceMask)));

%Threshold, as requested.
distanceMaskThreshold = getLocal(progmanager, hObject, 'volumeDistanceMaskThreshold');
distanceMaskThresholdFactor = getLocal(progmanager, hObject, 'volumeDistanceMaskThresholdFactor');
for i = 1 : length(distanceMaskThreshold)
    distanceMask(find(distanceMask < distanceMaskThreshold(i) * dmMax)) = ...
        distanceMaskThresholdFactor(i) * distanceMask(find(distanceMask < distanceMaskThreshold(i) * dmMax));
end

%Binarize, if requested.
if getLocal(progmanager, hObject, 'volumeBinarizeDistanceMask')
    threshold = getLocal(progmanager, hObject, 'volumeThresholdFactor') * (max(max(distanceMask)) - min(min(distanceMask)));
    distanceMask(find(distanceMask < threshold)) = 0;
    distanceMask(find(distanceMask >= threshold)) = 1;
end
distanceMask = distanceMask / max(max(distanceMask));

%Take a cross-sectional profile over the length of the annotation (watershed),
%then use that to compute a radius, and apply a circular mask,
%with an origin at the center of the annotation.
threshold = getLocal(progmanager, hObject, 'volumeThresholdFactor') * (max(max(region)) - min(min(region)));
diameter = 0;
rotated = imrotate(region, phi);
center = round(size(rotated, 2) / 2);
for i = 1 : length(xs)
    col = rotated(i, :);
    luminescent = find(rotated(i, :) > threshold);
    if ~isempty(luminescent)    
        diameter = max([diameter center-luminescent(1) luminescent(end)-center]);
    end
end
radius = diameter * .5 * getLocal(progmanager, hObject, 'volumeProfileRadiusFactor');
profileMask = region;
profileMask(:, :) = 0;

%There's got to be a fast way to do this.
radiusThresholds = getLocal(progmanager, hObject, 'volumeProfileThresholds');
radiusValues = getLocal(progmanager, hObject, 'volumeProfileValues');
for i = 1 : size(profileMask, 1)
    for j = 1 : size(profileMask, 2)
% fprintf('i: %s, j: %s\n', num2str(i), num2str(j));
        t = find((centerY - i)^2 + (centerX - j)^2 < radiusThresholds * radius);
        if ~isempty(t)
            profileMask(i, j) = radiusValues(t(1));
        end
        if (centerY - i)^2 + (centerX - j)^2 < radius
            profileMask(i, j) = 1;
% % fprintf('Radius: %s, Center: %s, Point: %s\n', num2str(radius), num2str([centerX centerY]), num2str([j i]));
        end
    end
end
% centerX
% centerY
% profileMask(:, :) = 0;
% profileMask(round(centerY), round(centerX)) = 3;
% fprintf('ProfileMask: %s - %s\n', num2str(min(min(profileMask))), num2str(max(max(profileMask))));

%Apply weights.
edgeWeight = getLocal(progmanager, hObject, 'volumeWeightEdgeMask');
distanceWeight = getLocal(progmanager, hObject, 'volumeWeightDistanceMask');
profileWeight = getLocal(progmanager, hObject, 'volumeWeightProfileMask');

weightedMask = edgeMask * edgeWeight + ...
    distanceMask * distanceWeight + ...
    profileMask * profileWeight;

% weightedMask = weightedMask / max(max(weightedMask));
weightedMask = weightedMask / (edgeWeight + distanceWeight + profileWeight);
% weightedMask = edgeMask .* distanceMask .* profileMask;
maskedRegion = region .* weightedMask;

edgeMask = edgeMask + getLocal(progmanager, hObject, 'volumeWeightEdgeMask');
distanceMask = distanceMask + getLocal(progmanager, hObject, 'volumeWeightDistanceMask');
profileMask = profileMask + getLocal(progmanager, hObject, 'volumeWeightProfileMask');

% fprintf(' Edge: %s\n Distance: %s\n Profile: %s\n = Weighted: %s', num2str([min(min(edgeMask)) max(max(edgeMask))]), ...
%     num2str([min(min(distanceMask)) max(max(distanceMask))]), num2str([min(min(profileMask)) max(max(profileMask))]), ...
%     num2str([min(min(weightedMask)) max(max(weightedMask))]));

region = imdata(yMin : yMax, xMin : xMax, getLocal(progmanager, hObject, 'frameNumber'));
frameWindow = 0;
if getLocal(progmanager, hObject, 'volumeAutoScanFrames')
    frameWindow = getLocal(progmanager, hObject, 'volumeFrameWindow');
end
maxFrame = -1;
volume = 0;
for i = max([1 (frameNumber - frameWindow)]) : min([(frameNumber + frameWindow) size(imdata, 3)])
    v = sum(sum(imdata(yMin : yMax, xMin : xMax, i) .* weightedMask));
    if v > volume
        volume = v;
        maxFrame = i;
        maskedRegion = imdata(yMin : yMax, xMin : xMax, i) .* weightedMask;
    end
end

resultString = sprintf('Volume: %s [arbitrary units]\n for %s on frame %s', num2str(volume), annotation.tag,  num2str(maxFrame));
fprintf(1, '\n%s\n', resultString);

if getLocal(progmanager, hObject, 'volumeDisplayCalculations')
    %Test code.
    f = figure;
    set(f, 'Name', sprintf('Volume: %s [arbitrary units] for %s on frame %s', num2str(volume), annotation.tag, num2str(maxFrame)));
    set(f, 'Colormap', gray);
    subplot(2, 3, 1), im2 = imagesc(region);
    title('Original Image');
    set(get(im2, 'Parent'), 'CLim', get(get(im, 'Parent'), 'CLim'));
    set(getParent(im2, 'axes'), 'YDir', 'normal');
    
    maskedRegion = round(maskedRegion + 1);
    subplot(2, 3, 6), im3 = imagesc(maskedRegion);
    title('Masked Image');
%     set(get(im3, 'Parent'), 'CLim', [min(min(maskedRegion)) max(max(maskedRegion))]);
    set(get(im3, 'Parent'), 'CLim', get(get(im2, 'Parent'), 'CLim'));
    set(getParent(im3, 'axes'), 'YDir', 'normal');
    
    maskedRegion = edgeMask;
    subplot(2, 3, 2), im4 = imagesc(maskedRegion);
    title('Edge Mask');
    set(get(im4, 'Parent'), 'CLim', [min(min(maskedRegion)) max(max(maskedRegion))]);
    set(getParent(im4, 'axes'), 'YDir', 'normal');
    
    maskedRegion = distanceMask;
    subplot(2, 3, 3), im5 = imagesc(maskedRegion);
    title('Distance Mask');
    set(get(im5, 'Parent'), 'CLim', [min(min(maskedRegion)) max(max(maskedRegion))]);
    set(getParent(im5, 'axes'), 'YDir', 'normal');
    
    maskedRegion = weightedMask;
    subplot(2, 3, 5), im7 = imagesc(maskedRegion);
    title('Weighted Mask');
    set(get(im7, 'Parent'), 'CLim', [min(min(maskedRegion)) max(max(maskedRegion))]);
    set(getParent(im7, 'axes'), 'YDir', 'normal');
    
    maskedRegion = profileMask;
    subplot(2, 3, 4), im6 = imagesc(maskedRegion);
    title('Profile Mask');
    set(get(im6, 'Parent'), 'CLim', [min(min(maskedRegion)) max(max(maskedRegion))]);
    % set(get(im6, 'Parent'), 'CLim', [min([min(min(maskedRegion)) 0]) max(max(maskedRegion))]);
    set(getParent(im6, 'axes'), 'YDir', 'normal');
    % figure, i = imagesc(profileMask);
    % set(get(i, 'Parent'), 'CLim', [ ]);
else
    msgbox(resultString, 'Volume');
end

return;