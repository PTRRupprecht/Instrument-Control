% rgbBalanace - Allow users to interactively adjust the look up tables for three channel images.
%
% SYNTAX
%  rgbBalance(rgbImage)
%  rgbBalance(rgbImage, imageH)
%  rgbBalance(rgbImage, copyAsBitmap)
%  rgbBalance(rgbImage, imageH, copyAsBitmap)
%  colorLimits = rgbBalance(...)
%  [colorLimits, balancedImage] = rgbBalance(...)
%   rgbImage - The RGB image to be balanced.
%              This is an M * N * 3 matrix, with dimension three being the red, green, and blue, respectively.
%   imageH - The handle to the displayed image (which will be modified during the operation). If none is provided, one will be created.
%   copyAsBitmap - If this flag is set to non-zero, the image will be copied to the clipboard as a bitmap. Otherwise it will be in an enhanced metafile (EMF) format.
%   colorLimits - A structure containing 3 fields, one for each color. Each field is a 2 element vector, with first the lower limit and then the upper limit.
%                 Example:
%                          .redLims = [10 400]
%                          .greenLims = [0 560]
%                          .blueLims = [0 1]
%   balancedImage - The balanced RGB image, with all values being between 0 and 1.
%
% NOTES
%  This will bring up the rgbBalancer gui/dialog.
%
% CREATED
%  Timothy O'Connor 12/21/09
%  Copyright UC Davis/Northwestern University/Howard Hughes Medical Institute 2009
function varargout = rgbBalance(rgbImage, varargin)
global rgbBalancerGlobal;

rgbBalancerGlobal.originalImage = rgbImage;
rgbBalancerGlobal.emfClipboardType = 1;
if length(varargin) >= 1
    if ishandle(varargin{1})
        if strcmp(get(varargin{1}, 'Type'), 'image')
            rgbBalancerGlobal.imageH = varargin{1};
        else
            rgbBalancerGlobal.emfClipboardType = varargin{1};
        end
    else
        rgbBalancerGlobal.emfClipboardType = varargin{1};
    end
else
    f = figure;
    rgbBalancerGlobal.imageH = imshow(rgbImage);
end
if length(varargin) >= 2
    rgbBalancerGlobal.emfClipboardType = varargin{2};
end

rgbH = rgbBalancer;
% rgbBalancer('redFull_Callback', rgbH, [], guidata(rgbH));
% rgbBalancer('greenFull_Callback', rgbH, [], guidata(rgbH));
% rgbBalancer('blueFull_Callback', rgbH, [], guidata(rgbH));
rgbBalancer('redStdDev_Callback', rgbH, [], guidata(rgbH));
rgbBalancer('greenStdDev_Callback', rgbH, [], guidata(rgbH));
rgbBalancer('blueStdDev_Callback', rgbH, [], guidata(rgbH));

try
    %Run this like a dialog box, wait for completion then return the result(s).
    uiwait(rgbH);
    varargout{2} = rgbBalancerGlobal.balancedImage;
    if nargout >= 1
        struct.redLims = rgbBalancerGlobal.redLims;
        struct.greenLims = rgbBalancerGlobal.greenLims;
        struct.blueLims = rgbBalancerGlobal.blueLims;
        varargout{1} = struct;
    end
    if nargout >= 2
        varargout{2} = rgbBalancerGlobal.balancedImage;
    end
catch
    delete(rgbH);
    delete(rgbBalancer);
    if length(varargin) == 0
        delete(f);
    end
    rethrow(lasterror);
end

delete(rgbBalancer);

if length(varargin) == 0
    delete(f);
end

return;