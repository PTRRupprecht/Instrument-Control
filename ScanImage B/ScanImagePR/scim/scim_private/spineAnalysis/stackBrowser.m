function varargout = stackBrowser(varargin)
% STACKBROWSER M-fileNameDisplay for stackBrowser.fig
%      STACKBROWSER, by itself, creates a new STACKBROWSER or raises the existing
%      singleton*.
%
%      H = STACKBROWSER returns the handle to a new STACKBROWSER or the handle to
%      the existing singleton*.
%
%      STACKBROWSER('Property','Value',...) creates a new STACKBROWSER using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to stackBrowser_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      STACKBROWSER('CALLBACK') and STACKBROWSER('CALLBACK',hObject,...) call the
%      local function named CALLBACK in STACKBROWSER.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stackBrowser

% Last Modified by GUIDE v2.5 22-Dec-2009 10:50:42

%% CHANGES
%   VI071310A: Use getRectFromAxes()/getPointsFromAxes for selection of rectangular area & points, respectively -- Vijay Iyer 7/13/10
%
%% **********************************************************

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stackBrowser_OpeningFcn, ...
                   'gui_OutputFcn',  @stackBrowser_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%-------------------------------------------------------------------
% --- Executes just before stackBrowser is made visible.
function stackBrowser_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for stackBrowser
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


%-------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = stackBrowser_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

%-------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function whiteValueText_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%-------------------------------------------------------------------
function updateCLims(hObject, varargin)

if getLocal(progmanager, hObject, 'whiteValue') > 3000
    setLocal(progmanager, hObject, 'whiteValue', 3000);
elseif getLocal(progmanager, hObject, 'whiteValue') < 1
    setLocal(progmanager, hObject, 'whiteValue', 1);
end

if getLocal(progmanager, hObject, 'blackValue') > 2999
    setLocal(progmanager, hObject, 'blackValue', 2999);
elseif getLocal(progmanager, hObject, 'blackValue') < 0
    setLocal(progmanager, hObject, 'blackValue', 0);
end
    
if getLocal(progmanager, hObject, 'whiteValue') <= getLocal(progmanager, hObject, 'blackValue')
    setLocal(progmanager, hObject, 'whiteValue', getLocal(progmanager, hObject, 'blackValue') + 1);
end

setLocalGh(progmanager, hObject, 'primaryView', 'CLim', [getLocal(progmanager, hObject, 'blackValue') getLocal(progmanager, hObject, 'whiteValue')]);
setLocalGh(progmanager, hObject, 'globalView', 'CLim', [getLocal(progmanager, hObject, 'blackValue') getLocal(progmanager, hObject, 'whiteValue')]);

return;

%-------------------------------------------------------------------
function whiteValueText_Callback(hObject, eventdata, handles)

updateCLims(hObject);

return;

%-------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function whiteValueSlider_CreateFcn(hObject, eventdata, handles)

usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%-------------------------------------------------------------------
% --- Executes on slider movement.
function whiteValueSlider_Callback(hObject, eventdata, handles)

updateCLims(hObject);

return;

%-------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function blackValueText_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function blackValueText_Callback(hObject, eventdata, handles)

updateCLims(hObject);

return;

%-------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function blackValueSlider_CreateFcn(hObject, eventdata, handles)

usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%-------------------------------------------------------------------
% --- Executes on slider movement.
function blackValueSlider_Callback(hObject, eventdata, handles)

updateCLims(hObject);

return;

%-------------------------------------------------------------------
function zoomPrimary(hObject, varargin)

for i = 1 : length(varargin)
    if ishandle(varargin{i})
        hObject = varargin{i};
        break;
    end
end

selectZoom(hObject, getLocalGh(progmanager, hObject, 'primaryView'));

return;

%-------------------------------------------------------------------
function zoomGlobal(hObject, varargin)

for i = 1 : length(varargin)
    if ishandle(varargin{i})
        hObject = varargin{i};
        break;
    end
end

selectZoom(hObject, getLocalGh(progmanager, hObject, 'globalView'));

return;

%-------------------------------------------------------------------
function selectZoom(hObject, ax)

rect = getRectFromAxes(ax,'nomovegui',1); %VI071310A

%Keep it square.
span = max(rect(3), rect(4));

if ax == getLocalGh(progmanager, hObject, 'primaryView')
    xLow = getLocal(progmanager, hObject, 'xBoundLow');
    yLow = getLocal(progmanager, hObject, 'yBoundLow');
    if rect(1) < xLow | ...
            rect(2) < yLow | ...
            rect(1) + rect(3) > xLow + getLocal(progmanager, hObject, 'xBoundHigh') | ...
            rect(2) + rect(4) > xLow + getLocal(progmanager, hObject, 'xBoundHigh')
        return;
    end
elseif ax == getLocalGh(progmanager, hObject, 'globalView')
    header = getLocal(progmanager, hObject, 'currentHeader');
    if rect(1) < 1 | ...
            rect(2) < 1 | ...
            any([rect(1) rect(3)] > header.acq.pixelsPerLine) | ...
            any([rect(2) rect(4)] > header.acq.pixelsPerLine)
        return;
    end
end

setLocal(progmanager, hObject, 'xBoundLow', rect(1));
setLocal(progmanager, hObject, 'xBoundHigh', rect(1) + span);
setLocal(progmanager, hObject, 'yBoundLow', rect(2));
setLocal(progmanager, hObject, 'yBoundHigh', rect(2) + span);

header = getLocal(progmanager, hObject, 'currentHeader');
setLocal(progmanager, hObject, 'zoomFactor', roundTo(header.acq.pixelsPerLine / span, 2));

updateImageDisplay(hObject);

return;

%-------------------------------------------------------------------
function updateZoomByBox(hObject, rect)

rect = get(rect, 'Position');

%Keep it square.
span = max(rect(3), rect(4));

header = getLocal(progmanager, hObject, 'currentHeader');
if rect(1) < 1 | ...
        rect(2) < 1 | ...
        any([rect(1) rect(3)] > header.acq.pixelsPerLine) | ...
        any([rect(2) rect(4)] > header.acq.pixelsPerLine)
    return;
end

setLocal(progmanager, hObject, 'xBoundLow', rect(1));
setLocal(progmanager, hObject, 'xBoundHigh', rect(1) + span);
setLocal(progmanager, hObject, 'yBoundLow', rect(2));
setLocal(progmanager, hObject, 'yBoundHigh', rect(2) + span);

header = getLocal(progmanager, hObject, 'currentHeader');
setLocal(progmanager, hObject, 'zoomFactor', roundTo(header.acq.pixelsPerLine / span, 2));

updateImageDisplay(hObject);

return;

%-------------------------------------------------------------------
% --- Executes on button press in zoomButton.
function zoomButton_Callback(hObject, eventdata, handles)

if getGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl')
    return;
end

setGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl', 1);

if getLocal(progmanager, hObject, 'zoomOnPrimaryImage')
    zoomPrimary(hObject);
else
    zoomGlobal(hObject);
end

setGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl', 0);
return;

%-------------------------------------------------------------------
% --- Executes on button press in fullZoomButton.
function fullZoomButton_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'zoomFactor') == 1
    return;
end

header = getLocal(progmanager, hObject, 'currentHeader');

setLocal(progmanager, hObject, 'xBoundLow', 1);
setLocal(progmanager, hObject, 'xBoundHigh', header.acq.pixelsPerLine);
setLocal(progmanager, hObject, 'yBoundLow', 1);
setLocal(progmanager, hObject, 'yBoundHigh', header.acq.linesPerFrame);

setLocal(progmanager, hObject, 'zoomFactor', 1);

updateImageDisplay(hObject);

return;

%-------------------------------------------------------------------
% --- Executes on button press in trackUp.
function trackUp_Callback(hObject, eventdata, handles)

if getGlobal(progmanager, 'trackingLocked', 'StackBrowserControl', 'stackBrowserControl')
    feval(getGlobal(progmanager, 'trackUp', 'StackBrowserControl', 'stackBrowserControl'), ...
        getGlobal(progmanager, 'hObject', 'StackBrowserControl', 'stackBrowserControl'), ...
        getLocal(progmanager, hObject, 'shiftStepSize'));
else
    if getLocal(progmanager, hObject, 'zoomFactor') == 1
        return;
    end
    
    setLocal(progmanager, hObject, 'yBoundLow', getLocal(progmanager, hObject, 'yBoundLow') + getLocal(progmanager, hObject, 'shiftStepSize'));
    setLocal(progmanager, hObject, 'yBoundHigh', getLocal(progmanager, hObject, 'yBoundHigh') + getLocal(progmanager, hObject, 'shiftStepSize'));
    
    updateImageDisplay(hObject);
end

return;

%-------------------------------------------------------------------
% --- Executes on button press in trackDown.
function trackDown_Callback(hObject, eventdata, handles)

if getGlobal(progmanager, 'trackingLocked', 'StackBrowserControl', 'stackBrowserControl')
    feval(getGlobal(progmanager, 'trackDown', 'StackBrowserControl', 'stackBrowserControl'), ...
        getGlobal(progmanager, 'hObject', 'StackBrowserControl', 'stackBrowserControl'), ...
        getLocal(progmanager, hObject, 'shiftStepSize'));
else
    if getLocal(progmanager, hObject, 'zoomFactor') == 1
        return;
    end

    setLocal(progmanager, hObject, 'yBoundLow', getLocal(progmanager, hObject, 'yBoundLow') - getLocal(progmanager, hObject, 'shiftStepSize'));
    setLocal(progmanager, hObject, 'yBoundHigh', getLocal(progmanager, hObject, 'yBoundHigh') - getLocal(progmanager, hObject, 'shiftStepSize'));

    updateImageDisplay(hObject);
end

return;

%-------------------------------------------------------------------
% --- Executes on button press in trackRight.
function trackRight_Callback(hObject, eventdata, handles)

if getGlobal(progmanager, 'trackingLocked', 'StackBrowserControl', 'stackBrowserControl')
    feval(getGlobal(progmanager, 'trackRight', 'StackBrowserControl', 'stackBrowserControl'), ...
        getGlobal(progmanager, 'hObject', 'StackBrowserControl', 'stackBrowserControl'), ...
        getLocal(progmanager, hObject, 'shiftStepSize'));
else
    if getLocal(progmanager, hObject, 'zoomFactor') == 1
        return;
    end
    
    setLocal(progmanager, hObject, 'xBoundLow', getLocal(progmanager, hObject, 'xBoundLow') + getLocal(progmanager, hObject, 'shiftStepSize'));
    setLocal(progmanager, hObject, 'xBoundHigh', getLocal(progmanager, hObject, 'xBoundHigh') + getLocal(progmanager, hObject, 'shiftStepSize'));
    
    updateImageDisplay(hObject);
end

return;

%-------------------------------------------------------------------
% --- Executes on button press in trackLeft.
function trackLeft_Callback(hObject, eventdata, handles)

if getGlobal(progmanager, 'trackingLocked', 'StackBrowserControl', 'stackBrowserControl')
    feval(getGlobal(progmanager, 'trackLeft', 'StackBrowserControl', 'stackBrowserControl'), ...
        getGlobal(progmanager, 'hObject', 'StackBrowserControl', 'stackBrowserControl'), ...
        getLocal(progmanager, hObject, 'shiftStepSize'));
else
    if getLocal(progmanager, hObject, 'zoomFactor') == 1
        return;
    end
    
    setLocal(progmanager, hObject, 'xBoundLow', getLocal(progmanager, hObject, 'xBoundLow') - getLocal(progmanager, hObject, 'shiftStepSize'));
    setLocal(progmanager, hObject, 'xBoundHigh', getLocal(progmanager, hObject, 'xBoundHigh') - getLocal(progmanager, hObject, 'shiftStepSize'));
    
    updateImageDisplay(hObject);
end

return;

%-------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function frameSlider_CreateFcn(hObject, eventdata, handles)

usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%-------------------------------------------------------------------
%TO122209C - Made the slider a little more robust (at least in R2006a). -- Tim O'Connor 12/22/09
% --- Executes on slider movement.
function frameSlider_Callback(hObject, eventdata, handles)

sliderVal = getLocal(progmanager, hObject, 'frameSliderValue');
lastSliderVal  = getLocal(progmanager, hObject, 'lastFrameSliderValue');

increment = 0;
%TO122209C
if sliderVal > 0.5
    increment = 1;
elseif sliderVal < 0.5
    increment = -1;
elseif sliderVal == getLocalGh(progmanager, hObject, 'frameSlider', 'Min')
    increment = -1;
elseif sliderVal == getLocalGh(progmanager, hObject, 'frameSlider', 'Max')
    increment = 1;
elseif sliderVal > lastSliderVal || sliderVal == 100
    %Move up one.
    increment = 1;
elseif sliderVal < lastSliderVal || sliderVal == 1
    %Move down one.
    increment = -1;
end

setLocalBatch(progmanager, hObject, 'lastFrameSliderValue', sliderVal, 'frameSliderValue', 0.5);

if getGlobal(progmanager, 'framesLocked', 'StackBrowserControl', 'stackBrowserControl')
    feval(getGlobal(progmanager, 'frameChange', 'StackBrowserControl', 'stackBrowserControl'), ...
        getGlobal(progmanager, 'hObject', 'StackBrowserControl', 'stackBrowserControl'), ...
        increment);
else
    frames = getLocal(progmanager, hObject, 'numberOfFrames');

    %Watch out for bounds.
    frameNumber = getLocal(progmanager, hObject, 'frameNumber');
    if  frameNumber == frames ...
            && increment > 0
        return;
    elseif frameNumber == 1 ...
            && increment < 0
        return;
    end

    setLocal(progmanager, hObject, 'frameNumber', getLocal(progmanager, hObject, 'frameNumber') + increment);
    displayNewImage(hObject);
end

return;

%-------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function frameEditBox_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%-------------------------------------------------------------------
function frameEditBox_Callback(hObject, eventdata, handles)

frames = getLocal(progmanager, hObject, 'numberOfFrames');
frameNumber = getLocal(progmanager, hObject, 'frameNumber');
if frameNumber < 1
    frameNumber = 1;
    setLocal(progmanager, hObject, 'frameNumber', 1);
elseif frameNumber > frames
    frameNumber = frames;
    setLocal(progmanager, hObject, 'frameNumber', frames);
end

if getGlobal(progmanager, 'framesLocked', 'StackBrowserControl', 'stackBrowserControl')
    stepSize = frameNumber - getLocal(progmanager, hObject, 'lastFrame');
    
    %The controller will change the frame number, via incrementation, so leave this where it was for now.
    setLocal(progmanager, hObject, 'frameNumber', getLocal(progmanager, hObject, 'lastFrame'));
    
    feval(getGlobal(progmanager, 'frameChange', 'StackBrowserControl', 'stackBrowserControl'), ...
        getGlobal(progmanager, 'hObject', 'StackBrowserControl', 'stackBrowserControl'), ...
        stepSize);
else
    displayNewImage(hObject);
end

return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'roiCoordinates', [0 0 1 1], ...
       'filePath', pwd, 'Class', 'char', ...
       'fileName', '', 'Class', 'char', ...
       'frameNumber', 1, 'Class', 'Numeric', 'Gui', 'frameEditBox', ...
       'whiteValue', 200, 'Class', 'Numeric', 'Min' 0, 'Max', 2000, 'Gui', 'whiteValueSlider', 'Gui', 'whiteValueText', ...
       'blackValue', 0, 'Class', 'Numeric', 'Min' 0, 'Max', 2000, 'Gui', 'blackValueSlider', 'Gui', 'blackValueText', ...
       'fileNameDisplay', '', 'Class', 'char', 'Gui', 'fileNameDisplay'...
       'roiBoxHandle', [], ...
       'zoomFactor', 1, 'Class', 'Numeric', 'Gui', 'zoomFactorEditbox', ...
       'currentChannel', 1, 'Class', 'Numeric', 'Gui', 'currentChannel', ...
       'frameSliderValue', 0.5, 'Class', 'Numeric', 'Gui', 'frameSlider', 'Min', 0, 'Max', 1, ...
       'lastFrameSliderValue', 0.5, 'Class', 'Numeric', ...
       'roiRectangle', [], ...
       'shiftStepSize', 50, 'Class', 'Numeric', 'Gui', 'shiftStepSize', ...
       'zoomSliderValue', 1, 'Class', 'Numeric', 'Gui', 'zoomFactorSlider', 'Min', 0, 'Max', 1, ...
       'lastZoomSliderValue', 1, 'Class', 'Numeric', ...
       'autoScaleStepSize', 1, 'Class', 'Numeric', 'Gui', 'autoScaleStepSize', ...
       'filterType', '', 'Class', 'char', ...
       'primaryImage', [], ...
       'globalImage', [], ...
       'tagCounter', 1, 'Class', 'Numeric', ...
       'updateImageDisplay', @updateImageDisplay, ...
       'displayNewImage', @displayNewImage, ...
       'annotateCallback', @annotate_Callback, ...
       'annotateCallback', @fiducialPoint_Callback, ...
       'updateBoundsByZoomFactor', @updateBoundsByZoomFactor, ...
       'centerOnAnnotation', @centerOnAnnotation, ...
       'hObject', hObject, ...
       'cancelWaitbar', 0, 'Class', 'Numeric', ...
       'lastFrame', 1, 'Class', 'Numeric', ...
       'annotations', [], ...
       'annotationGraphics', [], ...
       'showAnnotation', 0, ...
       'annotationObject', [], ...
       'currentAnnotation', 0, ...
       'projectAnnotations', 1, ...
       'zoomOnPrimaryImage', 1, ...
       'fiducialOnPrimary', 1, ...
       'fiducialOnGlobal', 1, ...
       'xBoundLow', 1, ...
       'xBoundHigh', 512, ...
       'yBoundLow', 1, ...
       'yBoundHigh', 512, ...
       'numberOfFrames', 0, ...
       'projectFrom', 1, 'Gui', 'projectFrom', 'Class', 'numeric', ...
       'projectTo', 1, 'Gui', 'projectTo', 'Class', 'numeric', ...
       'registrationTransform', [], 'Class', 'Numeric', ...
       'correlatedAnnotations', [], 'Class', 'Numeric', ...
       'showTextLabelsPrimary', 1, 'Class', 'Numeric', ...
       'showTextLabelsGlobal', 1, 'Class', 'Numeric', ...
       'applyTransform', @applyTransform, ...
       'removeTransform', @removeTransform, ...
       'unregistered', [], ...
       'lastSelectColored', -1, 'Class', 'Numeric', ...
       'polylinesOnPrimary', 1, 'Class', 'Numeric', ...
       'polylinesOnGlobal', 1, 'Class', 'Numeric', ...
       'dataLoadedFcn', @dataLoadedFcn, ...
       'emfClipboardType', 1, 'Class', 'Numeric', ...
       'autoSubtractImageMin', 0, 'Class', 'Numeric', ...
       'originalImage', [], ...
       'filterWindowSize', 3, 'Class', 'Numeric', ...
       'switchFrameOnSelection', 1, 'Class', 'Numeric', ...
       'allowCorrelationIDCollisions', 0, 'Class', 'Numeric', ...
       'unitaryConversions', 0, 'Class', 'Numeric', ...
       'xConversionFactor', 1, 'Class', 'Numeric', ...
       'xUnits', 'Pixels', 'Class', 'Char', ...
       'yConversionFactor', 1, 'Class', 'Numeric', ...
       'yUnits', 'Pixels', 'Class', 'Char', ...
       'zConversionFactor', 1, 'Class', 'Numeric', ...
       'zUnits', 'Pixels', 'Class', 'Char', ...
       'importedData', [], ...
       'importedDataType', '', ...
       'importPath', '', ...
       'volumeDistanceFactor', 2, 'Class', 'Numeric', ...
       'volumeDistanceMaskThreshold', [0.6], 'Class', 'Array', ...
       'volumeDistanceMaskThresholdFactor', [0], 'Class', 'Array', ...
       'volumeWeightDistanceMask', 1, 'Class', 'Numeric', ...
       'volumeWeightEdgeMask', 1, 'Class', 'Numeric', ...
       'volumeWeightProfileMask', 1, 'Class', 'Numeric', ...
       'volumeEdgeFilterStrength', 5, 'Class', 'Numeric', ...
       'volumeRegionSizeFactor', 2, 'Class', 'Numeric', ...
       'volumeBinarizeDistanceMask', 0, 'Class', 'Numeric', ...
       'volumeProfileRadiusFactor', 10, 'Class', 'Numeric', ...
       'volumeThresholdFactor', 0.1, 'Class', 'Numeric', ...
       'volumeProfileCenterWeight', .5, 'Class', 'Numeric', ...
       'volumeProfileThresholds', [1 2], 'Class', 'Array', ...
       'volumeProfileValues', [1 .5], 'Class', 'Array', ...
       'currentHeader', [], ...
       'volumeFrameWindow', 3, 'Class', 'Numeric', 'Min', 0, ...
       'volumeAutoSelectRegion', 1, 'Class', 'Numeric', 'Min', 0, 'Max', 1, ...
       'volumeAutoScanFrames', 1, 'Class', 'Numeric', 'Min', 0, 'Max', 1, ...
       'volumeDisplayCalculations', 1, 'Class', 'Numeric', 'Min', 0, 'Max', 1, ...
       'gridLines', [], ...
       'gridLineSpacing', 50, 'Class', 'Numeric', ...
       'gridLinesVisible', 0, 'Class', 'Numeric', ...
       'cacheOriginalImage', 1, 'Class', 'Numeric', ...
       'cacheUnregisteredImage', 1, 'Class', 'Numeric', ...
       'currentImage', [], ...
       'gridLinesOnGlobal', [], ...
       'gridLinesVisibleOnGlobal', 0, 'Class', 'Numeric', ...
       'stackBrowserUnits', [], ...
       'showAnnotationsOnPrimary', 1, 'Class', 'Numeric', ...
       'showAnnotationsOnGlobal', 1, 'Class', 'Numeric', ...
       'insertFilenameInCopiedImages', 1, ...
       'photometryWindow', [], ...
       'lockAnnotationsToChannel', 1, ...
       'numberOfChannels', 1, ...
       'multichannelPhotometryData', 0, ...
       'optimizePhotometryNormalization', 1, ...
       'loadPhotometryRegions', 0, ...
       'integralPixelCount', 0, ...
   };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

% makeGenericallyResizeable(getParent(hObject, 'figure'));

primary = getLocalGh(progmanager, hObject, 'primaryView');
globalView = getLocalGh(progmanager, hObject, 'globalView');

annotationGraphics.primaryLine = [];
annotationGraphics.primaryLineDirection = [];
annotationGraphics.globalLine = [];
annotationGraphics.primaryFidPoint = [];
annotationGraphics.globalFidPoint = [];
annotationGraphics.polyLinePrimary = [];
annotationGraphics.polyLineGlobal = [];
annotationGraphics.primaryText = [];
annotationGraphics.globalText = [];
setLocal(progmanager, hObject, 'annotationGraphics', annotationGraphics);

axis([primary globalView], 'image');

setLocal(progmanager, hObject, 'hObject', hObject);

%Add context menus.
cMenu = uicontextmenu('Parent', getParent(primary, 'figure'));
set(cMenu, 'Tag', 'primaryViewContextMenu');
uimenu(cMenu, 'Label', 'Annotate', 'Callback', {@annotate_Callback, hObject}, 'Tag', 'primaryViewContextMenu_Annotate');
uimenu(cMenu, 'Label', 'Fiducial', 'Callback', {@fiducialPoint_Callback, hObject}, 'Tag', 'primaryViewContextMenu_Fiducial');
uimenu(cMenu, 'Label', 'Zoom', 'Callback', {@zoomButton_Callback, hObject}, 'Tag', 'primaryViewContextMenu_Zoom');
uimenu(cMenu, 'Label', 'Zoom In', 'Callback', ...
    'setLocal(progmanager, gcbf, ''zoomFactor'', max(1, round(getLocal(progmanager, gcbf, ''zoomFactor'') + 1))); feval(getLocal(progmanager, gcbf, ''updateBoundsByZoomFactor''), gcbf); feval(getLocal(progmanager, gcbf, ''updateImageDisplay''), gcbf);', 'Tag', 'primaryViewContextMenu_Zoom_In');
uimenu(cMenu, 'Label', 'Zoom Out', 'Callback', ...
    'setLocal(progmanager, gcbf, ''zoomFactor'', max(1, round(getLocal(progmanager, gcbf, ''zoomFactor'') - 1))); feval(getLocal(progmanager, gcbf, ''updateBoundsByZoomFactor''), gcbf); feval(getLocal(progmanager, gcbf, ''updateImageDisplay''), gcbf);', 'Tag', 'primaryViewContextMenu_Zoom_Out');
uimenu(cMenu, 'Label', 'Histogram', 'Callback', {@displayHistogram, primary}, 'Tag', 'displayPrimaryHistogram');%TO122209D
uimenu(cMenu, 'Label', 'Copy', 'Callback', {@copyAxesToClipboard, primary}, 'Tag', 'copyPrimaryView2Clipboard');
uimenu(cMenu, 'Label', 'Copy RGB', 'Callback', {@copyRGBToClipboard, primary}, 'Tag', 'copyRGB2Clipboard');%TO122109C
set(primary, 'UIContextMenu', cMenu);

gcMenu = uicontextmenu('Parent', getParent(globalView, 'figure'));
set(gcMenu, 'Tag', 'globalViewContextMenu');
uimenu(gcMenu, 'Label', 'Zoom', 'Callback', {@zoomGlobal, hObject}, 'Tag', 'primaryViewContextMenu_Zoom');
uimenu(gcMenu, 'Label', 'Zoom In', 'Callback', ...
    'setLocal(progmanager, gcbf, ''zoomFactor'', max(1, round(getLocal(progmanager, gcbf, ''zoomFactor'') + 1))); feval(getLocal(progmanager, gcbf, ''updateBoundsByZoomFactor''), gcbf); feval(getLocal(progmanager, gcbf, ''updateImageDisplay''), gcbf);', 'Tag', 'primaryViewContextMenu_Zoom_In');
uimenu(gcMenu, 'Label', 'Zoom Out', 'Callback', ...
    'setLocal(progmanager, gcbf, ''zoomFactor'', max(1, round(getLocal(progmanager, gcbf, ''zoomFactor'') - 1))); feval(getLocal(progmanager, gcbf, ''updateBoundsByZoomFactor''), gcbf); feval(getLocal(progmanager, gcbf, ''updateImageDisplay''), gcbf);', 'Tag', 'primaryViewContextMenu_Zoom_Out');
uimenu(gcMenu, 'Label', 'Histogram', 'Callback', {@displayHistogram, globalView}, 'Tag', 'displayGlobalHistogram');%TO122209D
uimenu(gcMenu, 'Label', 'Copy', 'Callback', {@copyAxesToClipboard, globalView}, 'Tag', 'copyGlobalView2Clipboard');
uimenu(gcMenu, 'Label', 'Copy RGB', 'Callback', {@copyRGBToClipboard, globalView}, 'Tag', 'copyGlobalViewRGB2Clipboard');%TO122109C
set(globalView, 'UIContextMenu', gcMenu);

set(getParent(hObject, 'figure'), 'KeyPressFcn', @keyPressFcn);

%Pick up the "default" units from the controller.
setLocal(progmanager, hObject, 'xConversionFactor', getGlobal(progmanager, 'xConversionFactor', 'StackBrowserControl', 'stackBrowserControl'));
setLocal(progmanager, hObject, 'xUnits', getGlobal(progmanager, 'xUnits', 'StackBrowserControl', 'stackBrowserControl'));
setLocal(progmanager, hObject, 'yConversionFactor', getGlobal(progmanager, 'yConversionFactor', 'StackBrowserControl', 'stackBrowserControl'));
setLocal(progmanager, hObject, 'yUnits', getGlobal(progmanager, 'yUnits', 'StackBrowserControl', 'stackBrowserControl'));
setLocal(progmanager, hObject, 'zConversionFactor', getGlobal(progmanager, 'zConversionFactor', 'StackBrowserControl', 'stackBrowserControl'));
setLocal(progmanager, hObject, 'zUnits', getGlobal(progmanager, 'zUnits', 'StackBrowserControl', 'stackBrowserControl'));

updateVariablesFromController(hObject);

return;

% ------------------------------------------------------------------
function updateVariablesFromController(hObject)

optionsObject = getGlobal(progmanager, 'optionsObject', 'stackBrowserControl', 'StackBrowserControl');
displayOptionsObject = getGlobal(progmanager, 'displayOptionsObject', 'stackBrowserControl', 'StackBrowserControl');
featureRecognitionOptionsObject = getGlobal(progmanager, 'featureRecognitionOptionsObject', 'stackBrowserControl', 'StackBrowserControl');

setLocal(progmanager, hObject, 'filterType', getGlobal(progmanager, 'defaultFilter', 'stackBrowserControl', 'StackBrowserControl'));

setLocal(progmanager, hObject, 'primaryViewZoomSelection', getLocal(progmanager, optionsObject, 'primaryViewZoomSelection'));
setLocal(progmanager, hObject, 'globalViewZoomSelection', getLocal(progmanager, optionsObject, 'globalViewZoomSelection'));
setLocal(progmanager, hObject, 'emfClipboardType', getLocal(progmanager, optionsObject, 'emfClipboardType'));
setLocal(progmanager, hObject, 'insertFilenameInCopiedImages', getLocal(progmanager, optionsObject, 'insertFilenameInCopiedImages'));
setLocal(progmanager, hObject, 'autoSubtractImageMin', getLocal(progmanager, optionsObject, 'autoSubtractImageMin'));
setLocal(progmanager, hObject, 'filterWindowSize', getLocal(progmanager, optionsObject, 'filterWindowSize'));
setLocal(progmanager, hObject, 'switchFrameOnSelection', getLocal(progmanager, optionsObject, 'switchFrameOnSelection'));
setLocal(progmanager, hObject, 'allowCorrelationIDCollisions', getLocal(progmanager, optionsObject, 'allowCorrelationIDCollisions'));
setLocal(progmanager, hObject, 'multichannelPhotometryData', getLocal(progmanager, optionsObject, 'multichannelPhotometryData'));

setLocal(progmanager, hObject, 'projectAnnotations', getLocal(progmanager, displayOptionsObject, 'projectAnnotations'));
setLocal(progmanager, hObject, 'showAnnotationsOnPrimary', getLocal(progmanager, displayOptionsObject, 'showAnnotationsOnPrimary'));
setLocal(progmanager, hObject, 'fiducialOnPrimary', getLocal(progmanager, displayOptionsObject, 'fiducialOnPrimary'));
setLocal(progmanager, hObject, 'fiducialOnGlobal', getLocal(progmanager, displayOptionsObject, 'fiducialOnGlobal'));
setLocal(progmanager, hObject, 'showTextLabelsPrimary', getLocal(progmanager, displayOptionsObject, 'showTextLabelsPrimary'));
setLocal(progmanager, hObject, 'showTextLabelsGlobal', getLocal(progmanager, displayOptionsObject, 'showTextLabelsGlobal'));
setLocal(progmanager, hObject, 'polylinesOnPrimary', getLocal(progmanager, displayOptionsObject, 'polylinesOnPrimary'));
setLocal(progmanager, hObject, 'polylinesOnGlobal', getLocal(progmanager, displayOptionsObject, 'polylinesOnGlobal'));
setLocal(progmanager, hObject, 'gridLineSpacing', getLocal(progmanager, displayOptionsObject, 'gridLineSpacing'));
setLocal(progmanager, hObject, 'gridLinesVisible', getLocal(progmanager, displayOptionsObject, 'gridLinesVisible'));
setLocal(progmanager, hObject, 'gridLinesVisibleOnGlobal', getLocal(progmanager, displayOptionsObject, 'gridLinesVisibleOnGlobal'));

setLocal(progmanager, hObject, 'volumeDistanceFactor', getLocal(progmanager, featureRecognitionOptionsObject, 'volumeDistanceFactor'));
setLocal(progmanager, hObject, 'volumeDistanceMaskThreshold', getLocal(progmanager, featureRecognitionOptionsObject, 'volumeDistanceMaskThreshold'));
setLocal(progmanager, hObject, 'volumeDistanceMaskThresholdFactor', getLocal(progmanager, featureRecognitionOptionsObject, 'volumeDistanceMaskThresholdFactor'));
setLocal(progmanager, hObject, 'volumeWeightDistanceMask', getLocal(progmanager, featureRecognitionOptionsObject, 'volumeWeightDistanceMask'));
setLocal(progmanager, hObject, 'volumeWeightEdgeMask', getLocal(progmanager, featureRecognitionOptionsObject, 'volumeWeightEdgeMask'));
setLocal(progmanager, hObject, 'volumeWeightProfileMask', getLocal(progmanager, featureRecognitionOptionsObject, 'volumeWeightProfileMask'));
setLocal(progmanager, hObject, 'volumeEdgeFilterStrength', getLocal(progmanager, featureRecognitionOptionsObject, 'volumeEdgeFilterStrength'));
setLocal(progmanager, hObject, 'volumeRegionSizeFactor', getLocal(progmanager, featureRecognitionOptionsObject, 'volumeRegionSizeFactor'));
setLocal(progmanager, hObject, 'volumeBinarizeDistanceMask', getLocal(progmanager, featureRecognitionOptionsObject, 'volumeBinarizeDistanceMask'));
setLocal(progmanager, hObject, 'volumeProfileRadiusFactor', getLocal(progmanager, featureRecognitionOptionsObject, 'volumeProfileRadiusFactor'));
setLocal(progmanager, hObject, 'volumeThresholdFactor', getLocal(progmanager, featureRecognitionOptionsObject, 'volumeThresholdFactor'));
setLocal(progmanager, hObject, 'volumeProfileCenterWeight', getLocal(progmanager, featureRecognitionOptionsObject, 'volumeProfileCenterWeight'));
setLocal(progmanager, hObject, 'volumeProfileThresholds', getLocal(progmanager, featureRecognitionOptionsObject, 'volumeProfileThresholds'));
setLocal(progmanager, hObject, 'volumeProfileValues', getLocal(progmanager, featureRecognitionOptionsObject, 'volumeProfileValues'));
setLocal(progmanager, hObject, 'volumeFrameWindow', getLocal(progmanager, featureRecognitionOptionsObject, 'volumeFrameWindow'));
setLocal(progmanager, hObject, 'volumeAutoSelectRegion', getLocal(progmanager, featureRecognitionOptionsObject, 'volumeAutoSelectRegion'));
setLocal(progmanager, hObject, 'volumeAutoScanFrames', getLocal(progmanager, featureRecognitionOptionsObject, 'volumeAutoScanFrames'));
setLocal(progmanager, hObject, 'volumeDisplayCalculations', getLocal(progmanager, featureRecognitionOptionsObject, 'volumeDisplayCalculations'));

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

updateVariablesFromController(hObject);

% createAnnotationGraphics(hObject, eventdata, handles);
ia_createAnnotationGraphics(hObject);

%Update the display.
feval(getLocal(progmanager, hObject, 'annotationDisplayUpdateFcn'), getLocal(progmanager, hObject, 'annotationObject'));

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

if ~isempty(getLocal(progmanager, hObject, 'currentImage')) & ...
        getGlobal(progmanager, 'changesMadeSinceLastSave', 'StackBrowserControl', 'stackBrowserControl')
    yesOrNo = questdlg(sprintf('Do you wish to save the changes you have made to your analysis?\n\n%s', ... 
        'Choosing ''No'' will discard any changes made to the current image since the previous save.'), 'Save Changes', 'Yes');
    if strcmpi(yesOrNo, 'Yes')
        feval(getGlobal(progmanager, 'saveMenuItem_Callback', 'StackBrowserControl', 'stackBrowserControl'), ...
            getGlobal(progmanager, 'hObject', 'StackBrowserControl', 'stackBrowserControl'), hObject);
    end
end

feval(getGlobal(progmanager, 'browserCloseEvent', 'StackBrowserControl', 'stackBrowserControl'), ...
    getGlobal(progmanager, 'hObject', 'StackBrowserControl', 'stackBrowserControl'), hObject);

return;

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.1;

return;

%-------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function fileNameDisplay_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%-------------------------------------------------------------------
function fileNameDisplay_Callback(hObject, eventdata, handles)

fNameHandle = getLocalGh(progmanager, hObject, 'fileNameDisplay');

if exist(getLocal(progmanager, hObject, 'fileNameDisplay'), 'file') == 2
    set(fNameHandle, 'ForegroundColor', [0 0 0]);
else
    set(fNameHandle, 'ForegroundColor', [1 0 0]);
    fprintf(2, '''%s'' is not a valid file and can not be loaded.', getLocal(progmanager, hObject, 'fileNameDisplay'));
    return;
end

loadImage(hObject);

return;

%-------------------------------------------------------------------
%TO122109D - Cached path.
% --- Executes on button press in fileBrowseButton.
function fileBrowseButton_Callback(hObject, eventdata, handles)
%TO080707A - Cleaned up to be more user friendly, not changing directory or any nonsense anymore.
% if isdir(getGlobal(progmanager, 'filePath', 'StackBrowserControl', 'stackBrowserControl'))
%     browsePath = getGlobal(progmanager, 'filePath', 'StackBrowserControl', 'stackBrowserControl');
% elseif isdir(getLocal(progmanager, hObject, 'filePath'))
%     browsePath = getLocal(progmanager, hObject, 'filePath');
% else
%     browsePath = getDefaultCacheDirectory(progmanager, 'stackBrowserImage');%TO122109D
% end
browsePath = getDefaultCacheDirectory(progmanager, 'stackBrowserImage');%TO122109D

[filename, pathname] = uigetfile({'*.tif; *.tiff; *.rif', 'TIFF encoded images (*.tif, *.tiff, *.rif)'; fullfile(browsePath, '*.*'), 'All files (*.*)'}, ...
    'Choose an image to load.', browsePath);
if isequal(filename, 0) | isequal(pathname, 0)
    return;
else
    setLocal(progmanager, hObject, 'filePath', pathname);
end

setLocal(progmanager, hObject, 'fileNameDisplay', fullfile(pathname, filename));
setGlobal(progmanager, 'filePath', 'StackBrowserControl', 'stackBrowserControl', pathname);

setDefaultCacheValue(progmanager, 'stackBrowserImage', pathname);

loadImage(hObject);

return;

%-------------------------------------------------------------------
function loadImage(hObject, varargin)

try
    if ~isempty(getLocal(progmanager, hObject, 'currentImage'))
        yesOrNo = questdlg(sprintf('Do you wish to save any changes you may have made to your analysis?\n\n%s', ... 
            'Choosing ''No'' will discard any changes made to the current image since the previous save.'), 'Save Changes', 'Yes');
        if strcmpi(yesOrNo, 'Yes')
            feval(getGlobal(progmanager, 'saveMenuItem_Callback', 'StackBrowserControl', 'stackBrowserControl'), ...
                getGlobal(progmanager, 'hObject', 'StackBrowserControl', 'stackBrowserControl'), [], []);
        elseif strcmpi(yesOrNo, 'Cancel')
            return;
        end
    end
   
    fileNameDisplay = getLocal(progmanager, hObject, 'fileNameDisplay');

    if endsWithIgnoreCase(fileNameDisplay, '.xml')
        im = openPrairieImage(fileNameDisplay);
        if ~iscell(im)
            im = {im};
        end
        imheader = [];
        if isempty(im)
            %Something went wrong...
            warning('`openPrairieImage` returned an empty image object for file: %s', fileNameDisplay); %VI040809A
            errordlg('Image contains no data.', 'Empty Image', 'modal');
            return;
        end
    else
        %[im, imheader] = genericOpenTif(fileNameDisplay, 'splitIntoCellArray', 1); %VI040809A
        [imheader, im] = scim_openTif(fileNameDisplay,'cell'); %VI040809A
        if isempty(im)
            %Something went wrong...
            warning('`scim_openTif` returned an empty image object for file: %s', fileNameDisplay); %VI040809A
            errordlg('Image contains no data.', 'Empty Image', 'modal');
            return;
        end
    end

    if iscell(im)
        for i = 1 : length(im)
            channelArray{i} = sprintf('Channel %s', num2str(i));
        end
        setLocalGh(progmanager, hObject, 'currentChannel', 'String', channelArray);
    end
    
catch
    warning('Failed to open image file: %s - %s', getLocal(progmanager, hObject, 'fileNameDisplay'), lasterr);
    return;
end

currentChannel = max(min(getLocal(progmanager, hObject, 'currentChannel'), length(im)), 1);
setLocalBatch(progmanager, hObject, 'currentChannel', currentChannel, 'numberOfChannels', length(im));%TO080707A

photometryWindow = getLocal(progmanager, hObject, 'photometryWindow');
setLocal(progmanager, photometryWindow, 'backgroundRegion', []);
setLocal(progmanager, photometryWindow, 'backgroundFrame', []);
setLocal(progmanager, photometryWindow, 'backgroundFrameDisplay', 1);
setLocal(progmanager, photometryWindow, 'backgroundChannel', currentChannel);
delete(getLocal(progmanager, photometryWindow, 'backgroundRegionGraphic'));
setLocal(progmanager, photometryWindow, 'backgroundRegionGraphic', []);

setLocal(progmanager, photometryWindow, 'normalizationRegion', []);
setLocal(progmanager, photometryWindow, 'normalizationFrame', []);
setLocal(progmanager, photometryWindow, 'normalizationFrameDisplay', 1);
setLocal(progmanager, photometryWindow, 'normalizationChannel', currentChannel);
delete(getLocal(progmanager, photometryWindow, 'normalizationRegionGraphic'));
delete(getLocal(progmanager, photometryWindow, 'normalizationRegionGraphic_global'));
setLocal(progmanager, photometryWindow, 'normalizationRegionGraphic', []);
setLocal(progmanager, photometryWindow, 'normalizationRegionGraphic_global', []);
setLocal(progmanager, photometryWindow, 'recalculateNormalization', 1);

setLocal(progmanager, photometryWindow, 'integralRegion', []);
setLocal(progmanager, photometryWindow, 'integralFrame', []);
setLocal(progmanager, photometryWindow, 'integralFrameDisplay', 1);
setLocal(progmanager, photometryWindow, 'integralChannel', currentChannel);
delete(getLocal(progmanager, photometryWindow, 'integralRegionGraphic'));
setLocal(progmanager, photometryWindow, 'integralRegionGraphic', []);

processNewImage(hObject, im, imheader);
% toggleGuiVisibility(progmanager, getGlobal(progmanager, 'hObject', 'StackBrowserControl', 'stackBrowserControl'), 'stackBrowserOptions', 'On');
updateUnits(hObject);

return;
    
%-------------------------------------------------------------------
function processNewImage(hObject, im, imheader)

fileNameDisplay = getLocal(progmanager, hObject, 'fileNameDisplay');

%TO081004d Tim O'Connor 8/10/04 - Insert dummy values into the header for non-ScanImage images.
forgeHeaders = 0;
if isempty(imheader)
    forgeHeaders = 1;
else
    if ~isfield(imheader, 'acq')
        forgeHeaders = 1;
    end
end

if forgeHeaders
    %         %Rescale the image, since it gets darkened by the `rgb2ind` conversion.
    %         %This is a bit klugy, the ultimate fix should go in `genericOpenTif`.
    %         im{1} = im{1} * 10;
    imheader.acq.pixelsPerLine = size(im{1}, 1);
    imheader.acq.linesPerFrame = size(im{1}, 2);
    imheader.acq.numberOfZSlices = size(im{1}, 3);
    if ~isempty(fileNameDisplay)
        fileInfo = dir(fileNameDisplay);
        imheader.internal.triggerTime = datenum(fileInfo.date);
        imheader.internal.triggerTimeString = fileInfo.date;
    else
        fileInfo = [];
        imheader.internal.triggerTime = clock;
        imheader.internal.triggerTimeString = datestr(clock);
    end
end

% delete(getLocal(progmanager, hObject, 'gridLines'));
setLocal(progmanager, hObject, 'gridLines', []);
setLocal(progmanager, hObject, 'gridLinesOnGlobal', []);

updateUnits(hObject);

%TO042407A - Rescale high aspect ratio images for clarity. For now it's just hardcoded to work on a factor of 4. -- Tim O'Connor 4/24/07
%TO062007C - Changed condition to be based on two ratios. -- Tim O'Connor 6/20/07
if ((imheader.acq.linesPerFrame / imheader.acq.pixelsPerLine) > 3) || ((imheader.acq.pixelsPerLine / imheader.acq.linesPerFrame) > 3)
    rescaleAnswer = questdlg('This image may be easier to look at if forced to be square. Interpolate image (photometry will be skewed)?', 'Interpolate?', 'Yes', 'No', 'Yes');
    if strcmpi(rescaleAnswer, 'Yes')
        %TO080707 - Process photometry across multiple channels, for ratiometric imaging. -- Tim O'Connor 8/7/07
        for j = 1 : length(im)
            temp_im = im{j};
            im{j} = zeros(imheader.acq.pixelsPerLine, imheader.acq.pixelsPerLine, size(temp_im, 3));
            for i = 1 : 4
                im{j}(i : 4 : imheader.acq.pixelsPerLine - 4 + i, :, :) = temp_im(:, :, :);
            end
        end
        imheader.acq.linesPerFrame = imheader.acq.pixelsPerLine;
    end
end

if getLocal(progmanager, hObject, 'cacheOriginalImage')
    setLocal(progmanager, hObject, 'originalImage', im);
end
filterType = getGlobal(progmanager, 'defaultFilter', 'StackBrowserControl', 'stackBrowserControl');
setLocal(progmanager, hObject, 'filterType', filterType);

[fpath fname ext] = fileparts(fileNameDisplay);
setLocal(progmanager, hObject, 'filePath', fpath);
setLocal(progmanager, hObject, 'fileName', [fname ext]);

setGlobal(progmanager, 'filePath', 'StackBrowserControl', 'stackBrowserControl', fpath);

setLocal(progmanager, hObject, 'currentImage', im);
setLocal(progmanager, hObject, 'currentHeader', imheader);

hP = getLocalGh(progmanager, hObject, 'primaryView');
hG = getLocalGh(progmanager, hObject, 'globalView');

delete(get(hP, 'Children'));
delete(get(hG, 'Children'));
%     ia_clearAnnotationGraphics(hObject);
%     annotationGraphics.primaryLine = [];
%     annotationGraphics.primaryLineDirection = [];
%     annotationGraphics.globalLine = [];
%     annotationGraphics.primaryFidPoint = [];
%     annotationGraphics.globalFidPoint = [];
%     annotationGraphics.polyLinePrimary = [];
%     annotationGraphics.polyLineGlobal = [];
%     annotationGraphics.text = [];
%     setLocal(progmanager, hObject, 'annotationGraphics', annotationGraphics);
setLocal(progmanager, hObject, 'primaryImage', []);
setLocal(progmanager, hObject, 'globalImage', []);
setLocal(progmanager, hObject, 'unregistered', []);

set(get(hP, 'Parent'), 'Colormap', gray);
set(get(hG, 'Parent'), 'Colormap', gray);

setLocalGh(progmanager, hObject, 'primaryView', 'xLim', [1 imheader.acq.pixelsPerLine]);
setLocalGh(progmanager, hObject, 'primaryView', 'yLim', [1 imheader.acq.linesPerFrame]);
setLocalGh(progmanager, hObject, 'primaryView', 'YDir', 'reverse'); %VI041309A
setLocalGh(progmanager, hObject, 'globalView', 'xLim', [1 imheader.acq.pixelsPerLine]);
setLocalGh(progmanager, hObject, 'globalView', 'yLim', [1 imheader.acq.linesPerFrame]);
setLocalGh(progmanager, hObject, 'globalView', 'YDir', 'reverse'); %VI041309A

setLocal(progmanager, hObject, 'zoomFactor', getGlobal(progmanager, 'defaultZoom', 'StackBrowserControl', 'stackBrowserControl'));
updateBoundsByZoomFactor(hObject);
% setLocal(progmanager, hObject, 'xBoundLow', 1);
% setLocal(progmanager, hObject, 'xBoundHigh', imheader.acq.pixelsPerLine);
% setLocal(progmanager, hObject, 'yBoundLow', 1);
% setLocal(progmanager, hObject, 'yBoundHigh', imheader.acq.linesPerFrame);
setLocal(progmanager, hObject, 'frameNumber', 1);

setLocal(progmanager, hObject, 'zoomFactor', 1);
% setLocal(progmanager, hObject, 'currentChannel', 1);

%On the test data I used, the number of frames was wrong in the header.
%Therefore, let's count the number of frames available.
index = find(~isempty(im));
if length(index) > 1
    index = index(1);
end
setLocal(progmanager, hObject, 'numberOfFrames', size(im{index}, 3));
setLocalGh(progmanager, hObject, 'ofFramesLabel', 'String', ['of ' num2str(size(im{index}, 3)) ' frames.']);

setLocal(progmanager, hObject, 'projectFrom', 1);
setLocal(progmanager, hObject, 'projectTo', size(im{index}, 3));

setLocal(progmanager, hObject, 'importedData', []);
setLocal(progmanager, hObject, 'importedDataType', '');

im = im{getLocal(progmanager, hObject, 'currentChannel')};
if isempty(im)
    fprintf(2, 'No image data available.\n');
    return;
end

setLocal(progmanager, hObject, 'registrationTransform', []);

setLocal(progmanager, hObject, 'annotations', []);
displayNewImage(hObject);

% ia_importData(hObject);

%Autoload the data.
dataLoadedFcn(hObject);

maxProjectGlobal(hObject);

feval(getGlobal(progmanager, 'fileLoadedFcn', 'StackBrowserControl', 'stackBrowserControl'), ...
    getGlobal(progmanager, 'hObject', 'StackBrowserControl', 'stackBrowserControl'));

ia_drawGridLines(hObject);

if ~isempty(filterType) & ~strcmpi(filterType, 'none')
    applyFilter(hObject);
end

return;

%-------------------------------------------------------------------
function removeTransform(hObject)

im = getLocal(progmanager, hObject, 'unregistered');
if isempty(im) | isempty(getLocal(progmanager, hObject, 'registrationTransform'))
    return;
end

setLocal(progmanager, hObject, 'currentImage', im);
setLocal(progmanager, hObject, 'registrationTransform', []);
setLocal(progmanager, hObject, 'unregistered', []);

%MaxProject will handle this
% ia_transformAnnotationGraphics(hObject);

maxProjectGlobal(hObject);
displayNewImage(hObject);

return;

%-------------------------------------------------------------------
function applyTransform(hObject)

img = getLocal(progmanager, hObject, 'currentImage');

if isempty(img)
    return;
end

if isempty(getLocal(progmanager, hObject, 'unregistered')) & getLocal(progmanager, hObject, 'cacheUnregisteredImage')
    setLocal(progmanager, hObject, 'unregistered', img);
end

tform = getLocal(progmanager, hObject, 'registrationTransform');
if isempty(tform)
    return;
end

udata.hObject = hObject;
for j = 1 : length(img)
    if ~isempty(img{j})
        im = img{j};
        wb = waitbarWithCancel(0, sprintf('Applying coordinate transform to channel %s...', num2str(j)), 'UserData', udata, 'Tag', 'applyTransformWaitBar');
        
        for i = 1 : size(im, 3)
            waitbar(i / size(im, 3), wb);
            im(:, :, i) = imtransform(im(:, :, i), tform, 'Size', size(im(:, :, i)), 'XYScale', 1, 'XData', [1 size(im, 2)], 'YData', [1 size(im, 1)]);
            
            if isWaitbarCancelled(wb)
                delete(wb);
                return;
            end
        end

        img{j} = im;
    end
end
delete(wb);

setLocal(progmanager, hObject, 'currentImage', img);

%The maxProjectGlobal function will recreate the annotation objects, so no transform is necessary.
% ia_transformAnnotationGraphics(hObject);

displayNewImage(hObject);
maxProjectGlobal(hObject);

return;

%-------------------------------------------------------------------
function displayNewImage(hObject)

im = getLocal(progmanager, hObject, 'currentImage');
if isempty(im)
    return;
end

im = im{getLocal(progmanager, hObject, 'currentChannel')};
if isempty(im)
    fprintf(2, 'No image data available.\n');
    errordlg('No image data available.', 'Empty Image', 'modal');
    return;
end

frameNumber = getLocal(progmanager, hObject, 'frameNumber');
frames = getLocal(progmanager, hObject, 'numberOfFrames');
if frameNumber > frames
    setLocal(progmanager, hObject, 'frameNumber', frames);
    frameNumber = frames;
elseif frameNumber < 1
    setLocal(progmanager, hObject, 'frameNumber', 1);
    frameNumber = 1;
end
setLocal(progmanager, hObject, 'lastFrame', frameNumber);
im = im(:, :, frameNumber);

%Display the whole thing, set the XLim and YLim to zoom.
cLims = [getLocal(progmanager, hObject, 'blackValue') getLocal(progmanager, hObject, 'whiteValue')];
primaryImage = getLocal(progmanager, hObject, 'primaryImage');
globalImage = getLocal(progmanager, hObject, 'globalImage');

%Draw the image.
if isempty(primaryImage)
    primaryImage = imagesc('Parent', getLocalGh(progmanager, hObject, 'primaryView'), 'CData', im, cLims);
    set(primaryImage, 'Tag', 'stackBrowser-primaryImage');

%     globalImage = imagesc('Parent', getLocalGh(progmanager, hObject, 'globalView'), 'CData', im, cLims);
%     set(globalImage, 'Tag', 'stackBrowser-globalImage');
else
    set(primaryImage, 'CData', im);
%     set(globalImage, 'CData', im);
end

%Store the image handles.
setLocal(progmanager, hObject, 'primaryImage', primaryImage);
setLocal(progmanager, hObject, 'globalImage', globalImage);

set(primaryImage, 'UIContextMenu', get(getLocalGh(progmanager, hObject, 'primaryView'), 'UIContextMenu'));

ia_setLineVisibilities(hObject);

updateImageDisplay(hObject);

ia_updatePhotometryValues(getLocal(progmanager, hObject, 'photometryWindow'));

return;

%-------------------------------------------------------------------
%Ignores the varargin, which is there just to allow this to be used in a callback.
function updateImageDisplay(hObject, varargin)

%These'll get used a lot, so cache them.
xBoundLow = getLocal(progmanager, hObject, 'xBoundLow');
xBoundHigh = getLocal(progmanager, hObject, 'xBoundHigh');
yBoundLow = getLocal(progmanager, hObject, 'yBoundLow');
yBoundHigh = getLocal(progmanager, hObject, 'yBoundHigh');
header = getLocal(progmanager, hObject, 'currentHeader');
span = max(xBoundHigh - xBoundLow, yBoundHigh - yBoundLow);

%Make sure it has the same span in each dimension (it's square).
if (xBoundHigh - xBoundLow) ~= span
    xBoundHigh = xBoundLow + span;
end
if (yBoundHigh - yBoundLow) ~= span
    yBoundHigh = yBoundLow + span;
end

%Make sure the boundaries of the ROI are legal.
if xBoundLow < 1 | xBoundHigh < span
    xBoundLow = 1;
    xBoundHigh = span;
elseif xBoundHigh > header.acq.pixelsPerLine | xBoundLow > (header.acq.pixelsPerLine - span)
    xBoundLow = max(1, header.acq.pixelsPerLine - span);
    xBoundHigh = header.acq.pixelsPerLine;
end

if yBoundLow < 1 | yBoundHigh < span
    yBoundLow = 1;
    yBoundHigh = span;
elseif yBoundHigh > header.acq.linesPerFrame | yBoundLow > (header.acq.linesPerFrame - span)
    yBoundLow = max(1, header.acq.linesPerFrame - span);
    yBoundHigh = header.acq.linesPerFrame;
end

%Set the corrected positions in the program manager.
setLocal(progmanager, hObject, 'xBoundLow', xBoundLow);
setLocal(progmanager, hObject, 'xBoundHigh', xBoundHigh);
setLocal(progmanager, hObject, 'yBoundLow', yBoundLow);
setLocal(progmanager, hObject, 'yBoundHigh', yBoundHigh);

% fprintf(1, '--updateImageDisplay\n xBoundLow: %s\n xBoundHigh: %s\n yBoundLow: %s\n yBoundHigh: %s\n span: %s\n', num2str(xBoundLow), ...
%     num2str(xBoundHigh), num2str(yBoundLow), num2str(yBoundHigh), num2str(span));

%Set the proper zoom.
setLocal(progmanager, hObject, 'zoomFactor', roundTo(header.acq.pixelsPerLine / span, 2));
setLocalGh(progmanager, hObject, 'primaryView', 'XLim', [xBoundLow xBoundHigh], 'YLim', [yBoundLow yBoundHigh]);

%Set the proper look up table.
setLocalGh(progmanager, hObject, 'primaryView', 'CLim', [getLocal(progmanager, hObject, 'blackValue') getLocal(progmanager, hObject, 'whiteValue')]);
setLocalGh(progmanager, hObject, 'globalView', 'CLim', [getLocal(progmanager, hObject, 'blackValue') getLocal(progmanager, hObject, 'whiteValue')]);

%Draw the ROI.
rect = getLocal(progmanager, hObject, 'roiRectangle');
if isempty(rect) | ~ishandle(rect)
%     rect = rectangle('Parent', getLocalGh(progmanager, hObject, 'globalView'), 'Position', [xBoundLow ...
%             (xBoundLow + xBoundHigh) (yBoundLow + yBoundHigh) ...
%             getLocal(progmanager, hObject, 'yBoundLow')], 'FaceColor', 'None', 'EdgeColor', [1 0 0]);
    rect = rectangle('Parent', getLocalGh(progmanager, hObject, 'globalView'), 'Position', ...
        [(xBoundLow) (yBoundLow) span span], ...
        'FaceColor', 'None', 'EdgeColor', [1 0 0], 'LineWidth', 2, 'Tag', 'roiRectangle');
else
    set(rect, 'Position', [(xBoundLow) (yBoundLow) span span], 'LineWidth', 2);
%     set(rect, 'Position', [xBoundLow xBoundHigh yBoundLow yBoundHigh]);
end
makegraphicsobjectmutable(rect, 'Callback', {@updateZoomByBox, hObject, rect}, 'lockToAxes', 1);%TO062007C - Case sensitivity.
set(rect, 'LineWidth', 3);
setLocal(progmanager, hObject, 'roiRectangle', rect);
set(getLocalGh(progmanager, hObject, 'globalView'), 'Layer', 'bottom');

%Implement zoom locking across browsers.
if getGlobal(progmanager, 'zoomsLocked', 'StackBrowserControl', 'stackBrowserControl')
    browsers = ia_getActiveStackBrowsers(hObject);
    setGlobal(progmanager, 'zoomsLocked', 'StackBrowserControl', 'stackBrowserControl', 0);
    for i = 1 : length(browsers)
        if browsers(i) ~= hObject
            try
                setLocal(progmanager, browsers(i), 'zoomFactor', getLocal(progmanager, hObject, 'zoomFactor'));
                updateBoundsByZoomFactor(browsers(i));
%                 setLocal(progmanager, browsers(i), 'xBoundLow', xBoundLow);
%                 setLocal(progmanager, browsers(i), 'xBoundHigh', xBoundHigh);
%                 setLocal(progmanager, browsers(i), 'yBoundLow', yBoundLow);
%                 setLocal(progmanager, browsers(i), 'yBoundHigh', yBoundHigh);
                updateImageDisplay(browsers(i), varargin);
            catch
                warning('Failed to update locked zoom for ''%s''.', getProgramName(browsers(i)));
            end
        end
    end
    setGlobal(progmanager, 'zoomsLocked', 'StackBrowserControl', 'stackBrowserControl', 1);
end

return;

%-------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function zoomFactorSlider_CreateFcn(hObject, eventdata, handles)

usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%-------------------------------------------------------------------
function updateBoundsByZoomFactor(hObject, varargin)

xBoundLow = getLocal(progmanager, hObject, 'xBoundLow');
xBoundHigh = getLocal(progmanager, hObject, 'xBoundHigh');
yBoundLow = getLocal(progmanager, hObject, 'yBoundLow');
yBoundHigh = getLocal(progmanager, hObject, 'yBoundHigh');
header = getLocal(progmanager, hObject, 'currentHeader');

span = max(xBoundHigh - xBoundLow, yBoundHigh - yBoundLow);

%Preserve the image center, as much as possible.
centerX = xBoundLow + .5 * span;
centerY = yBoundLow + .5 * span;

span = header.acq.pixelsPerLine / getLocal(progmanager, hObject, 'zoomFactor');

setLocal(progmanager, hObject, 'xBoundLow', centerX - .5 * span);
setLocal(progmanager, hObject, 'xBoundHigh', centerX + .5 * span);
setLocal(progmanager, hObject, 'yBoundLow', centerY - .5 * span);
setLocal(progmanager, hObject, 'yBoundHigh', centerY + .5 * span);

if getLocal(progmanager, hObject, 'autoScaleStepSize')
    %Never step more than 100 pixels at a time or less than 10 pixels at a time.
    %Keep the value rounded to tens of pixels.
    setLocal(progmanager, hObject, 'shiftStepSize', min(100, max(10, 10 * round(span / 50))));
end

%Let subsequent calls to updateImageDisplay sort out problems with the image boundaries.

return;

%-------------------------------------------------------------------
% --- Executes on slider movement.
function zoomFactorSlider_Callback(hObject, eventdata, handles)


%JL113007B reset slider value to 50 for Matlab 7
sliderVal = getLocal(progmanager, hObject, 'zoomSliderValue');
lastSliderVal  = getLocal(progmanager, hObject, 'lastZoomSliderValue');

increment = 0;
if sliderVal > lastSliderVal | sliderVal == 100
    %Move up one.
    increment = 1;
elseif sliderVal < lastSliderVal | sliderVal == 1
    %Move down one.
    increment = -1;
end
setLocal(progmanager, hObject, 'lastZoomSliderValue', sliderVal);

setLocal(progmanager, hObject, 'zoomFactor', max(1, round(getLocal(progmanager, hObject, 'zoomFactor') + increment)));

updateBoundsByZoomFactor(hObject);

updateImageDisplay(hObject);

return;

%-------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function zoomFactorEditbox_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%-------------------------------------------------------------------
function zoomFactorEditbox_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'zoomFactor', max(roundTo(getLocal(progmanager, hObject, 'zoomFactor'), 2), 1));

updateBoundsByZoomFactor(hObject);

updateImageDisplay(hObject);

return;

%-------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function shiftStepSize_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%-------------------------------------------------------------------
function shiftStepSize_Callback(hObject, eventdata, handles)

%This is just a simple variable, let the program manager do the linking,
%other than that, nothing needs to get done.
return;

% --------------------------------------------------------------------
% --- Executes on button press in autoScaleStepSize.
function autoScaleStepSize_Callback(hObject, eventdata, handles)

%This is just a simple variable, let the program manager do the linking,
%other than that, nothing needs to get done.
return;


% --------------------------------------------------------------------
function loadImage_Callback(hObject, eventdata, handles)

fileBrowseButton_Callback(gcbf);

return;

% --------------------------------------------------------------------
function medianFilter_Callback(hObject, eventdata, handles)

im = getUnfilteredImage(hObject);
if isempty(im)
    return;
end

setLocal(progmanager, hObject, 'filterType', 'median');

setLocal(progmanager, hObject, 'cancelWaitBar', 0);
udata.hObject = hObject;
wb = waitbarWithCancel(0, 'Applying median filter...', 'UserData', udata, ...
    'Tag', 'medianFilterWaitBar');

iterations = 0;
for i = 1 : length(im)
    iterations = iterations + size(im{i}, 3);
end

%Iterate over channels.
for i = 1 : length(im)
    stack = im{i};

    %Iterate over frames.
    for j = 1 : size(stack, 3)
        if isWaitbarCancelled(wb)
            delete(wb);
            return;
        end
        
        %Subtract off the minimum.
        if getLocal(progmanager, hObject, 'autoSubtractImageMin')
            stack(:, :, j) = stack(:, :, j) - min(min(stack(:, :, j)));
        end
        
        windowSize = getLocal(progmanager, hObject, 'filterWindowSize');
        try
            stack(:, :, j) = medfilt2(stack(:, :, j), [windowSize windowSize]);
        catch
            warning('Failed to median filter frame %s: %s', num2str(j), lasterr);
        end
        waitbar((i + j) / iterations, wb);
    end

    im{i} = stack;
end

if isWaitbarCancelled(wb)
    delete(wb);
    return;
end
delete(wb);

%Set the right check marks.
menuItem = getMenuItem(gcbf, 'imageMenu', 'applyFilter', 'medianFilter');
set(get(get(menuItem, 'Parent'), 'Children'), 'Checked', 'Off');
set(menuItem, 'Checked', 'On');

setLocal(progmanager, hObject, 'currentImage', im);

displayNewImage(hObject);
maxProjectGlobal(hObject);

return;

% --------------------------------------------------------------------
function weinerFilter_Callback(hObject, eventdata, handles)

im = getUnfilteredImage(hObject);
if isempty(im)
    return;
end

setLocal(progmanager, hObject, 'filterType', 'wiener');

setLocal(progmanager, hObject, 'cancelWaitBar', 0);
udata.hObject = hObject;
wb = waitbarWithCancel(0, 'Applying adaptive filter...', 'UserData', udata, ...
    'Tag', 'adaptiveFilterWaitBar');

iterations = 0;
for i = 1 : length(im)
    iterations = iterations + size(im{i}, 3);
end

%Iterate over channels.
for i = 1 : length(im)
    stack = im{i};

    %Iterate over frames.
    for j = 1 : size(stack, 3)
        if isWaitbarCancelled(wb)
            delete(wb);
            return;
        end
        
        %Subtract off the minimum.
        if getLocal(progmanager, hObject, 'autoSubtractImageMin')
            stack(:, :, j) = stack(:, :, j) - min(min(stack(:, :, j)));
        end
        
        windowSize = getLocal(progmanager, hObject, 'filterWindowSize');
        stack(:, :, j) = wiener2(stack(:, :, j), [windowSize windowSize]);
        waitbar((i + j) / iterations, wb);
    end

    im{i} = stack;
end

if isWaitbarCancelled(wb)
    delete(wb);
    return;
end
delete(wb);

%Set the right check marks.
menuItem = getMenuItem(gcbf, 'imageMenu', 'applyFilter', 'wienerFilter');
set(get(get(menuItem, 'Parent'), 'Children'), 'Checked', 'Off');
set(menuItem, 'Checked', 'On');

setLocal(progmanager, hObject, 'currentImage', im);

displayNewImage(hObject);
maxProjectGlobal(hObject);

return;


% --------------------------------------------------------------------
function imfilterFilter(hObject, type)

im = getUnfilteredImage(hObject);
if isempty(im)
    return;
end

setLocal(progmanager, hObject, 'filterType', type);

setLocal(progmanager, hObject, 'cancelWaitBar', 0);
udata.hObject = hObject;
wb = waitbarWithCancel(0, sprintf('Applying %s filter...', type), 'UserData', udata, ...
    'Tag', 'imfilterFilterWaitBar');

iterations = 0;
for i = 1 : length(im)
    iterations = iterations + size(im{i}, 3);
end

H = fspecial(type);

%Iterate over channels.
for i = 1 : length(im)
    stack = im{i};

    %Iterate over frames.
    for j = 1 : size(stack, 3)
        if isWaitbarCancelled(wb)
            delete(wb);
            return;
        end
        
        %Subtract off the minimum.
        if getLocal(progmanager, hObject, 'autoSubtractImageMin')
            stack(:, :, j) = stack(:, :, j) - min(min(stack(:, :, j)));
        end
        
        windowSize = getLocal(progmanager, hObject, 'filterWindowSize');
        stack(:, :, j) = imfilter(stack(:, :, j), H);
        waitbar((i + j) / iterations, wb);
    end

    im{i} = stack;
end

if isWaitbarCancelled(wb)
    delete(wb);
    return;
end
delete(wb);

setLocal(progmanager, hObject, 'currentImage', im);

displayNewImage(hObject);
maxProjectGlobal(hObject);

return;

% --------------------------------------------------------------------
function noFiltering_Callback(hObject, eventdata, handles)

im = getUnfilteredImage(hObject);
if isempty(im)
    return;
end

setLocal(progmanager, hObject, 'filterType', 'none');

%Set the right check marks.
menuItem = getMenuItem(gcbf, 'imageMenu', 'applyFilter', 'noFilter');
set(get(get(menuItem, 'Parent'), 'Children'), 'Checked', 'Off');
set(menuItem, 'Checked', 'On');

setLocal(progmanager, hObject, 'currentImage', im);

displayNewImage(hObject);

return;

% --------------------------------------------------------------------
% --- Executes on button press in annotate.
function annotate_Callback(hObject, eventdata, handles)

ia_annotate(hObject);

% feval(getGlobal(progmanager, 'annotationAddedDuringCorrelation', 'stackBrowserControl', 'StackBrowserControl'), ...
%     getGlobal(progmanager, 'hObject', 'stackBrowserControl', 'StackBrowserControl'), hObject);

return;

% --------------------------------------------------------------------
function exportData_Callback(hObject, eventdata, handles)

ia_exportData(hObject);

return;

% --------------------------------------------------------------------
function importData_Callback(hObject, eventdata, handles)

ia_importData(hObject);
% ia_clearAnnotationGraphics(hObject);
% ia_createAnnotationGraphics(hObject);

return;

% --------------------------------------------------------------------
function importDataFrom_Callback(hObject, eventdata, handles)

ia_importDataFrom(hObject);
% ia_clearAnnotationGraphics(hObject);
% ia_createAnnotationGraphics(hObject);

return;

% --------------------------------------------------------------------
function exportToBinary_Callback(hObject, eventdata, handles)

ia_exportToBinary(hObject);

return;

% --------------------------------------------------------------------
function exportToTabDelimited_Callback(hObject, eventdata, handles)


ia_exportToTabDelimited(hObject);

return;

% --------------------------------------------------------------------
function exportDelimited(hObject, fullname, delimiter)

ia_exportDelimited(hObject, fullname, delimiter);

return;

% --------------------------------------------------------------------
function exportToExcel_Callback(hObject, eventdata, handles)

errordlg('Excel exporting is not yet supported.');

return;

% --------------------------------------------------------------------
function exportDataToCommaSeparated_Callback(hObject, eventdata, handles)

ia_exportDataToCommaSeparated(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
% --- Executes on button press in fiducialPoint.
function fiducialPoint_Callback(hObject, eventdata, handles)

if getGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl')
    return;
end

setGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl', 1);

primaryView = getLocalGh(progmanager, hObject, 'primaryView');
globalView = getLocalGh(progmanager, hObject, 'globalView');

[x y] = getPointsFromAxes(primaryView, 'nomovegui', 1); %VI071310A

setGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl', 0);

%Apply the spatial transformation.
tform = getMain(progmanager, hObject, 'registrationTransform');
if ~isempty(tform)
    if size(x, 1) < size(x, 2)
        coords = tforminv(cat(2, x', y'), tform);
    else
        coords = tforminv(cat(2, x, y), tform);
    end
    
    x = coords(:, 1);
    y = coords(:, 2);
end

%Ignore any extra points that were selected.
x = x(1);
y = y(1);

annotations = getMain(progmanager, hObject, 'annotations');
index = length(annotations) + 1;

tagCounter = getLocal(progmanager, hObject, 'tagCounter');
tag = sprintf('Annotation-%s', num2str(tagCounter));
setLocal(progmanager, hObject, 'tagCounter', tagCounter + 1);

annotations(index).type = 'point';
annotations(index).x(1:2) = x;
annotations(index).y(1:2) = y;
annotations(index).z(1:2) = getLocal(progmanager, hObject, 'frameNumber');
annotations(index).tag = tag;
annotations(index).text = '';
annotations(index).autoID = tagCounter;
annotations(index).userID = num2str(tagCounter);
annotations(index).correlationID = ia_getNewCorrelationId;
annotations(index).persistence = 5;
annotations(index).creationTime = clock;
annotations(index).userData.type = '';
annotations(index).filename = getLocal(progmanager, hObject, 'fileName');
%TO080707A
annotations(index).channel = getLocal(progmanager, hObject, 'currentChannel');
for i = 1 : getLocal(progmanager, hObject, 'numberOfChannels')
    annotations(index).photometry(i).background = [];
    annotations(index).photometry(i).backgroundBounds = [];
    annotations(index).photometry(i).backgroundFrame = [];
    annotations(index).photometry(i).normalization = [];
    annotations(index).photometry(i).normalizationBounds = [];
    annotations(index).photometry(i).normalizationFrame = [];
    annotations(index).photometry(i).normalizationMethod = 1;
    annotations(index).photometry(i).integral = [];
    annotations(index).photometry(i).integralBounds = [];
    annotations(index).photometry(i).integralFrame = [];
    annotations(index).photometry(i).backgroundChannel = i;%annotations(index).channel;
    annotations(index).photometry(i).normalizationChannel = i;%annotations(index).channel;
    annotations(index).photometry(i).integralChannel = i;%annotations(index).channel;
end

setLocal(progmanager, hObject, 'currentAnnotation', index);
setLocal(progmanager, hObject, 'annotations', annotations);
feval(getLocal(progmanager, hObject, 'annotationDisplayUpdateFcn'), getLocal(progmanager, hObject, 'annotationObject'));

ia_createAnnotationGraphics(hObject, index);

feval(getGlobal(progmanager, 'annotationAddedFcn', 'StackBrowserControl', 'stackBrowserControl'), ...
    getGlobal(progmanager, 'hObject', 'StackBrowserControl', 'stackBrowserControl'), hObject);

return;

% --------------------------------------------------------------------
% --- Executes on button press in polyLine.
function polyLine_Callback(hObject, eventdata, handles)

if getGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl')
    return;
end
setGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl', 1);

primaryView = getLocalGh(progmanager, hObject, 'primaryView');
globalView = getLocalGh(progmanager, hObject, 'globalView');

set(getParent(primaryView, 'figure'), 'HandleVisibility', 'On');%TO062007C - getline spawns a new figure in Matlab 7 if the HandleVisibility is set to Off. -- Tim O'Connor 6/20/07
[x y] = getPointsFromAxes(primaryView, 'numberOfPoints', 2, 'nomovegui', 1); %VI071310A
set(getParent(primaryView, 'figure'), 'HandleVisibility', 'Off');%TO062007C - getline spawns a new figure in Matlab 7 if the HandleVisibility is set to Off. -- Tim O'Connor 6/20/07

setGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl', 0);

%Apply the spatial transformation.
tform = getMain(progmanager, hObject, 'registrationTransform');
if ~isempty(tform)
    if size(x, 1) < size(x, 2)
        coords = tforminv(cat(2, x', y'), tform);
    else
        coords = tforminv(cat(2, x, y), tform);
    end

    x = coords(:, 1);
    y = coords(:, 2);
end

annotations = getMain(progmanager, hObject, 'annotations');
index = length(annotations) + 1;

tagCounter = getLocal(progmanager, hObject, 'tagCounter');
tag = sprintf('Annotation-%s', num2str(tagCounter));
setLocal(progmanager, hObject, 'tagCounter', tagCounter + 1);

annotations(index).type = 'polyline';
annotations(index).x = x;
annotations(index).y = y;
annotations(index).z(1:length(x)) = getLocal(progmanager, hObject, 'frameNumber');
annotations(index).tag = tag;
annotations(index).text = '';
annotations(index).autoID = tagCounter;
annotations(index).userID = num2str(tagCounter);
annotations(index).correlationID = ia_getNewCorrelationId;
annotations(index).persistence = 5;
annotations(index).creationTime = clock;
annotations(index).userData.type = '';
annotations(index).filename = getLocal(progmanager, hObject, 'fileName');
%TO080707A
annotations(index).channel = getLocal(progmanager, hObject, 'currentChannel');
for i = 1 : getLocal(progmanager, hObject, 'numberOfChannels')
    annotations(index).photometry(i).background = [];
    annotations(index).photometry(i).backgroundBounds = [];
    annotations(index).photometry(i).backgroundFrame = [];
    annotations(index).photometry(i).normalization = [];
    annotations(index).photometry(i).normalizationBounds = [];
    annotations(index).photometry(i).normalizationFrame = [];
    annotations(index).photometry(i).normalizationMethod = 1;
    annotations(index).photometry(i).integral = [];
    annotations(index).photometry(i).integralBounds = [];
    annotations(index).photometry(i).integralFrame = [];
    annotations(index).photometry(i).backgroundChannel = i;%annotations(index).channel;
    annotations(index).photometry(i).normalizationChannel = i;%annotations(index).channel;
    annotations(index).photometry(i).integralChannel = i;%annotations(index).channel;
end

setLocal(progmanager, hObject, 'currentAnnotation', index);
setLocal(progmanager, hObject, 'annotations', annotations);
feval(getLocal(progmanager, hObject, 'annotationDisplayUpdateFcn'), getLocal(progmanager, hObject, 'annotationObject'));

ia_createAnnotationGraphics(hObject, index);

feval(getGlobal(progmanager, 'annotationAddedFcn', 'StackBrowserControl', 'stackBrowserControl'), ...
    getGlobal(progmanager, 'hObject', 'StackBrowserControl', 'stackBrowserControl'), hObject);

return;

% --------------------------------------------------------------------
function keyPressFcn(hObject, varargin)
c = get(getParent(hObject, 'figure'), 'CurrentCharacter');
if isempty(c)
    return;
end

switch c
    case 13
        %Enter

    case 28
        %Left
        trackLeft_Callback(hObject);

    case 29
        %Right
        trackRight_Callback(hObject);

    case 30
        %Up
        trackUp_Callback(hObject);

    case 31
        %Down
        trackDown_Callback(hObject);

    case 31
        %Minus

    case 43
        %+

    case 45
        %-

    case 48
        %0

    case 49
        %1

    case 50
        %2
        trackDown_Callback(hObject);

    case 51
        %3
        setLocal(progmanager, hObject, 'frameNumber', getLocal(progmanager, hObject, 'frameNumber') - 1);
        frameEditBox_Callback(hObject);

    case 52
        %4
        trackLeft_Callback(hObject);

    case 53
        %5

    case 54
        %6
        trackRight_Callback(hObject);

    case 55
        %7

    case 56
        %8
        trackUp_Callback(hObject);

    case 57
        %9
        setLocal(progmanager, hObject, 'frameNumber', getLocal(progmanager, hObject, 'frameNumber') + 1);
        frameEditBox_Callback(hObject);

    case 65
        %a
        annotate_Callback(hObject);

    case 97
        %A
        annotate_Callback(hObject);

    case 69
        %e
        trackUp_Callback(hObject);

    case 101
        %E
        trackUp_Callback(hObject);

    case 70
        %f
        trackRight_Callback(hObject);

    case 102
        %F
        trackRight_Callback(hObject);

    case 83
        %s
        trackLeft_Callback(hObject);

    case 115
        %S
        trackLeft_Callback(hObject);

    case 68
        %d
        trackDown_Callback(hObject);

    case 100
        %D
        trackDown_Callback(hObject);

    case 90
        %Z
        setLocal(progmanager, hObject, 'frameNumber', getLocal(progmanager, hObject, 'frameNumber') - 1);
        frameEditBox_Callback(hObject);

    case 122
        %z
        setLocal(progmanager, hObject, 'frameNumber', getLocal(progmanager, hObject, 'frameNumber') - 1);
        frameEditBox_Callback(hObject);

    case 120
        %x
        setLocal(progmanager, hObject, 'frameNumber', getLocal(progmanager, hObject, 'frameNumber') + 1);
        frameEditBox_Callback(hObject);

    case 88
        %X
        setLocal(progmanager, hObject, 'frameNumber', getLocal(progmanager, hObject, 'frameNumber') + 1);
        frameEditBox_Callback(hObject);
end

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function projectFrom_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --------------------------------------------------------------------
function projectFrom_Callback(hObject, eventdata, handles)

to = getLocal(progmanager, hObject, 'projectFrom');
if to > getLocal(progmanager, hObject, 'numberOfFrames')
    setLocal(progmanager, hObject, 'projectFrom', getLocal(progmanager, hObject, 'numberOfFrames'));
elseif to < 1
    setLocal(progmanager, hObject, 'projectFrom', 1);
end

maxProjectGlobal(hObject);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function projectTo_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --------------------------------------------------------------------
function projectTo_Callback(hObject, eventdata, handles)

to = getLocal(progmanager, hObject, 'projectTo');
if to > getLocal(progmanager, hObject, 'numberOfFrames')
    setLocal(progmanager, hObject, 'projectTo', getLocal(progmanager, hObject, 'numberOfFrames'));
elseif to < 1
    setLocal(progmanager, hObject, 'projectTo', 1);
end

maxProjectGlobal(hObject);

return;

% --------------------------------------------------------------------
function maxProjectGlobal(hObject)

im = getLocal(progmanager, hObject, 'currentImage');
im = im{getLocal(progmanager, hObject, 'currentChannel')};
if isempty(im)
    fprintf(2, 'No image data available.\n');
    return;
end

udata.hObject = hObject;
% wb = waitbarWithCancel(0, 'Calculating Max Projection...', 'UserData', udata, ...
%     'Tag', 'maxProjectWaitBar');

%Max project.
% from = getLocal(progmanager, hObject, 'projectFrom');
% to = getLocal(progmanager, hObject, 'projectTo');
% imMax = im(:, :, from);
% iterations = max(1, getLocal(progmanager, hObject, 'projectTo') - from);
% for i = from : to
%     if isWaitbarCancelled(wb)
%         delete(wb);
%         return;
%     end
%     
%     imMax = max(imMax(:, :), im(:, :, i));
%     
%     waitbar(i / iterations, wb);
% end

imMax = max(im(:, :, getLocal(progmanager, hObject, 'projectFrom') : getLocal(progmanager, hObject, 'projectTo')), [], 3);

if getLocal(progmanager, hObject, 'autoSubtractImageMin')
    im = imMax - min(min(imMax));
else
    im = imMax;
end

% if isWaitbarCancelled(wb)
%     delete(wb);
%     return;
% end
% delete(wb);
% im = mean(im(:, :, getLocal(progmanager, hObject, 'projectFrom') : getLocal(progmanager, hObject, 'projectTo')), 3);

%Transform, if necessary.
% tform = getLocal(progmanager, hObject, 'registrationTransform');
% if ~isempty(tform)
%     im = imtransform(im, tform, 'Size', size(im));
% end

globalImage = getLocal(progmanager, hObject, 'globalImage');
if isempty(globalImage)
    cLims = [getLocal(progmanager, hObject, 'blackValue') getLocal(progmanager, hObject, 'whiteValue')];
    globalImage = imagesc('Parent', getLocalGh(progmanager, hObject, 'globalView'), 'CData', im, cLims);
    set(globalImage, 'Tag', 'stackBrowser-globalImage');
    set(globalImage, 'UIContextMenu', get(getLocalGh(progmanager, hObject, 'globalView'), 'UIContextMenu'));
    setLocal(progmanager, hObject, 'globalImage', globalImage);
else
    set(globalImage, 'CData', im);
end

renderROIRectangle(hObject);
ia_createAnnotationGraphics(hObject);

return;

% --------------------------------------------------------------------
function renderROIRectangle(hObject)

xBoundLow = getLocal(progmanager, hObject, 'xBoundLow');
yBoundLow = getLocal(progmanager, hObject, 'yBoundLow');
span = max(getLocal(progmanager, hObject, 'xBoundHigh') - xBoundLow, getLocal(progmanager, hObject, 'yBoundHigh') - yBoundLow);

%This has to be recreated, to keep it on top?
rect = getLocal(progmanager, hObject, 'roiRectangle');
if ~isempty(rect) & ishandle(rect)
    delete(rect);
end

rect = rectangle('Parent', getLocalGh(progmanager, hObject, 'globalView'), 'Position', ...
    [(xBoundLow) (yBoundLow) span span], ...
    'FaceColor', 'None', 'EdgeColor', [1 0 0], 'Tag', 'roiRectangle', 'LineWidth', 2);
setLocal(progmanager, hObject, 'roiRectangle', rect);
set(getLocal(progmanager, hObject, 'globalImage'), 'UIContextMenu', get(getLocalGh(progmanager, hObject, 'globalView'), 'UIContextMenu'));

return;

% --------------------------------------------------------------------
function centerOnAnnotation(hObject)

current = getLocal(progmanager, hObject, 'currentAnnotation');

if current < 1
    return;
end

annotations = getLocal(progmanager, hObject, 'annotations');

span = abs(getLocal(progmanager, hObject, 'xBoundHigh') - getLocal(progmanager, hObject, 'xBoundLow')) / 2;

x = sort([annotations(current).x(1) annotations(current).x(2)]) + [-1*span span];
y = sort([annotations(current).y(1) annotations(current).y(2)]) + [-1*span span];

if abs(x(1) - x(2)) > 2 * span
    x(2) = x(1) + 2 * span;
end

if abs(y(1) - y(2)) > 2 * span
    y(2) = y(1) + 2 * span;
end

setLocal(progmanager, hObject, 'xBoundLow', x(1));
setLocal(progmanager, hObject, 'xBoundHigh', x(2));
setLocal(progmanager, hObject, 'yBoundLow', y(1));
setLocal(progmanager, hObject, 'yBoundHigh', y(2));

setLocal(progmanager, hObject, 'frameNumber', annotations(current).z(1));

displayNewImage(hObject);

return;

% --------------------------------------------------------------------
function unregisterMenuItem_Callback(hObject, eventdata, handles)

removeTransform(hObject);

return;

% --------------------------------------------------------------------
function dataLoadedFcn(hObject)

persistentData = getGlobal(progmanager, 'persistentData', 'StackBrowserControl', 'stackBrowserControl');

ia_clearAnnotationGraphics(hObject);
annotations = [];
metadata = [];
fileName = getLocal(progmanager, hObject, 'fileName');

if ~isempty(persistentData)
    for i = 1 : size(persistentData, 1)
        if strcmpi(fileName, persistentData{i, 1})
            annotations = persistentData{i, 2};
            metadata = persistentData{i, 3};
            break;
        end
    end
    setLocal(progmanager, hObject, 'currentAnnotation', min(getLocal(progmanager, hObject, 'currentAnnotation'), length(annotations)));%TO062007C - Make sure it's not looking for an annotation that isn't there.
else
    setLocal(progmanager, hObject, 'currentAnnotation', 0);%TO062007C - Make sure it's not looking for an annotation that isn't there.
end
setLocal(progmanager, hObject, 'annotations', annotations);

for i = 1 : length(annotations)
    annotations(i).tag = sprintf('Annotation-%s', num2str(i));
    annotations(i).autoID = i;
end
setLocal(progmanager, hObject, 'annotations', annotations);
if isempty(i)
    i = 0;
end
setLocal(progmanager, hObject, 'tagCounter', i + 1);

if ~isempty(metadata)
    if isfield(metadata, 'units')
        setLocal(progmanager, hObject, 'unitaryConversions', metadata.units.unitaryConversions);
        setLocal(progmanager, hObject, 'xConversionFactor', metadata.units.xConversionFactor);
        setGlobal(progmanager, 'xConversionFactor', 'stackBrowserControl', 'StackBrowserControl', metadata.units.xConversionFactor);
        setLocal(progmanager, hObject, 'xUnits', metadata.units.xUnits);
        setGlobal(progmanager, 'xUnits', 'stackBrowserControl', 'StackBrowserControl', metadata.units.xUnits);
        
        setLocal(progmanager, hObject, 'yConversionFactor', metadata.units.yConversionFactor);
        setGlobal(progmanager, 'yConversionFactor', 'stackBrowserControl', 'StackBrowserControl', metadata.units.yConversionFactor);
        setLocal(progmanager, hObject, 'yUnits', metadata.units.yUnits);
        setGlobal(progmanager, 'yUnits', 'stackBrowserControl', 'StackBrowserControl', metadata.units.yUnits);
        
        setLocal(progmanager, hObject, 'zConversionFactor', metadata.units.zConversionFactor);
        setGlobal(progmanager, 'zConversionFactor', 'stackBrowserControl', 'StackBrowserControl', metadata.units.zConversionFactor);
        setLocal(progmanager, hObject, 'zUnits', metadata.units.zUnits);
        setGlobal(progmanager, 'zUnits', 'stackBrowserControl', 'StackBrowserControl', metadata.units.zUnits);
    end
end

ia_createAnnotationGraphics(hObject);

toggleGuiVisibility(progmanager, hObject, 'stackBrowserUnits', 'On');
ia_updatePhotometryFromAnnotation(hObject);

updateUnits(hObject);

return;

% --------------------------------------------------------------------
function copyAxesToClipboard(varargin)
global f
if length(varargin) == 3
    hObject = varargin{1};
    ax = varargin{3};
elseif length(varargin) == 2
    hObject = varargin{1};
    ax = varargin{2};    
end

f = figure('Visible', 'Off', 'Tag', 'clipBoardPreview');

im = getLocal(progmanager, hObject, 'currentImage');
im = im{getLocal(progmanager, hObject, 'currentChannel')};
xDim = size(im, 1);
yDim = size(im, 2);

nax = copyobj(ax, f);

%Work out the sizes to crop the copied image tightly.
set([f nax], 'Units', 'Pixels');
pos = get(f, 'Position');
pos(3) = max(pos(3), xDim);
pos(4) = max(pos(4), yDim);
if xDim == yDim
    pos(3) = min(pos(3), pos(4));
    pos(4) = pos(3);
end
set(f, 'Position', pos);
set(nax, 'Position', [1 1 pos(3) pos(4)]);

kids = get(nax, 'Children');
for i = 1 : length(kids)
    if strcmpi(get(kids(i), 'Tag'), 'roiRectangle')
        delete(kids(i));
    end
end

set(f, 'ColorMap', get(getParent(ax, 'figure'), 'ColorMap'));

if getLocal(progmanager, hObject, 'insertFilenameInCopiedImages')
    t = text(5, 5, getLocal(progmanager, hObject, 'fileName'), 'Color', [0.8313725490196078 0 0.7843137254901961], 'FontWeight', 'Bold', ...
        'FontSize', 14);
end

if getLocal(progmanager, hObject, 'emfClipboardType')
    print(f, '-dmeta');
else
    set(f, 'Visible', 'On');
    print(f, '-dbitmap');
end

delete(f);

return;

% --------------------------------------------------------------------
%TO122109C - Added an RGB copy, with interactive balancing of color channels.
function copyRGBToClipboard(varargin)
global f

if length(varargin) == 3
    hObject = varargin{1};
    ax = varargin{3};
elseif length(varargin) == 2
    hObject = varargin{1};
    ax = varargin{2};    
end

globalView = getLocalGh(progmanager, hObject, 'globalView');
autoSubtractImageMin = getLocal(progmanager, hObject, 'autoSubtractImageMin');

if ax ~= globalView
    im = getLocal(progmanager, hObject, 'currentImage');
    frame = getLocal(progmanager, hObject, 'frameNumber');
else
    %Max project.
    im = getLocal(progmanager, hObject, 'currentImage');
    frame = 1;
    for i = 1 : length(im)
        im{i} = max(im{i}(:, :, getLocal(progmanager, hObject, 'projectFrom') : getLocal(progmanager, hObject, 'projectTo')), [], 3);
        if autoSubtractImageMin
            im{i} = {im{i} - min(min(im{i}))};
        end
    end
end

rgbIm = zeros([size(im{1}, 1), size(im{1}, 2), 3]);
displayIm = rgbIm;
if length(im) >= 3
    rgbIm(:, :, 3) = im{3}(:, :, frame);%Blue
    displayIm(:, :, 3) = rgbIm(:, :, 3) / max(max(rgbIm(:, :, 3)));
end
if length(im) >= 2
    rgbIm(:, :, 1) = im{2}(:, :, frame);%Red
    displayIm(:, :, 1) = rgbIm(:, :, 1) / max(max(rgbIm(:, :, 1)));
end
rgbIm(:, :, 2) = im{1}(:, :, frame);%Green
displayIm(:, :, 2) = rgbIm(:, :, 2) / max(max(rgbIm(:, :, 2)));

f = figure('Visible', 'On', 'Tag', 'clipBoardPreview');
imObj = imshow(displayIm);
nax = getParent(imObj, 'axes');
set(nax, 'YDir', 'normal');

kids = get(ax, 'Children');
for i = 1 : length(kids)
    if ~strcmpi(get(kids(i), 'Tag'), 'roiRectangle') && ~strcmpi(get(kids(i), 'Type'), 'image')
        copyobj(kids(i), nax);
    end
end

rgbBalance(rgbIm, imObj);

if ishandle(f)
    delete(f);
end

return;

% --------------------------------------------------------------------
function sobelFilter_Callback(hObject, eventdata, handles)

imfilterFilter(hObject, 'sobel');

%Set the right check marks.
menuItem = getMenuItem(gcbf, 'imageMenu', 'applyFilter', 'sobelFilter');
set(get(get(menuItem, 'Parent'), 'Children'), 'Checked', 'Off');
set(menuItem, 'Checked', 'On');

return;

% --------------------------------------------------------------------
function gaussianFilter_Callback(hObject, eventdata, handles)

imfilterFilter(hObject, 'gaussian');

%Set the right check marks.
menuItem = getMenuItem(gcbf, 'imageMenu', 'applyFilter', 'gaussianFilter');
set(get(get(menuItem, 'Parent'), 'Children'), 'Checked', 'Off');
set(menuItem, 'Checked', 'On');

return;

% --------------------------------------------------------------------
function prewittFilter_Callback(hObject, eventdata, handles)

imfilterFilter(hObject, 'prewitt');

%Set the right check marks.
menuItem = getMenuItem(gcbf, 'imageMenu', 'applyFilter', 'prewittFilter');
set(get(get(menuItem, 'Parent'), 'Children'), 'Checked', 'Off');
set(menuItem, 'Checked', 'On');

return;

% --------------------------------------------------------------------
function laplacianFilter_Callback(hObject, eventdata, handles)

imfilterFilter(hObject, 'laplacian');

%Set the right check marks.
menuItem = getMenuItem(gcbf, 'imageMenu', 'applyFilter', 'laplacianFilter');
set(get(get(menuItem, 'Parent'), 'Children'), 'Checked', 'Off');
set(menuItem, 'Checked', 'On');

return;

% --------------------------------------------------------------------
function laplacianOfGaussianFilter_Callback(hObject, eventdata, handles)

imfilterFilter(hObject, 'log');

%Set the right check marks.
menuItem = getMenuItem(gcbf, 'imageMenu', 'applyFilter', 'laplacianOfGaussianFilter');
set(get(get(menuItem, 'Parent'), 'Children'), 'Checked', 'Off');
set(menuItem, 'Checked', 'On');

return;

% --------------------------------------------------------------------
function unsharpFilter_Callback(hObject, eventdata, handles)

imfilterFilter(hObject, 'unsharp');

%Set the right check marks.
menuItem = getMenuItem(gcbf, 'imageMenu', 'applyFilter', 'unsharpFilter');
set(get(get(menuItem, 'Parent'), 'Children'), 'Checked', 'Off');
set(menuItem, 'Checked', 'On');

return;

% --------------------------------------------------------------------
function importNeurolucidaBranches_Callback(hObject, eventdata, handles)

if exist('neurolucida2matlab') ~= 2
    errordlg('The neurolucida2matlab function must be available on the path to use this feature.');
    return;
end

if isdir(getLocal(progmanager, hObject, 'importPath')) & ~isempty(getLocal(progmanager, hObject, 'importPath'))
    cd(getLocal(progmanager, hObject, 'importPath'));
elseif isdir(getGlobal(progmanager, 'filePath', 'StackBrowserControl', 'stackBrowserControl'))
    cd(getGlobal(progmanager, 'filePath', 'StackBrowserControl', 'stackBrowserControl'));
    setLocal(progmanager, hObject, 'importPath', getGlobal(progmanager, 'filePath', 'StackBrowserControl', 'stackBrowserControl'));
elseif isdir(getLocal(progmanager, hObject, 'filePath'))
    cd(getLocal(progmanager, hObject, 'filePath'));
    setLocal(progmanager, hObject, 'importPath', getLocal(progmanager, hObject, 'filePath'));
else
    cd(fullfile(matlabroot, 'work'));
end

try
    nld = neurolucida2matlab;
catch
    warning('Failed to load Neurolucida data...');
end

if isempty(nld)
    return;
end

imSize = ceil(max([max(nld(:, 3) - min(nld(:, 3))) max(nld(:, 4) - min(nld(:, 4)))])) + 1;
originalImage = {ones([imSize imSize]), [], []};
setLocal(progmanager, hObject, 'currentChannel', 1);
processNewImage(hObject, originalImage, []);

%Re-zero??
reZero = 0;
if any(nld(:, 3) < 1)
    nld(:, 3) = nld(:, 3) + abs(min(nld(:, 3))) + 1;
    reZero = 1;
end
if any(nld(:, 4) < 1)
    nld(:, 4) = nld(:, 4) + abs(min(nld(:, 4))) + 1;
    reZero = 1;
end
if any(nld(:, 5) < 1)
    nld(:, 5) = nld(:, 5) + abs(min(nld(:, 5))) + 1;
    reZero = 1;
end
% if reZero
%     warning('The Neurolucida coordinates became negative on at least one axis, so the entire dataset was shifted into the positive regime.');
% end

xFactor = getLocal(progmanager, hObject, 'xConversionFactor');
yFactor = getLocal(progmanager, hObject, 'yConversionFactor');
zFactor = getLocal(progmanager, hObject, 'zConversionFactor');

userdata = [];
wb = waitbarWithCancel(0, 'Converting Neurolucida branch data into annotations...', 'UserData', userdata, 'Tag', 'importNeurolucidaData');

[branches leaves root] = branchAnalyzeNeurolucidaData(nld);
operations = length(branches) + length(leaves);
% cols = {'ID', 'Type', 'X', 'Y', 'Z', 'D', 'Parent'};
for i = 1 : length(branches)
    annotations(i).type = 'Line';
    annotations(i).x = [nld(branches(i).parent, 3) nld(branches(i).id, 3)] / xFactor;
    annotations(i).y = [nld(branches(i).parent, 4) nld(branches(i).id, 4)] / yFactor;
%     annotations(i).z = [nld(branches(i).parent, 5) nld(branches(i).id, 5)] / zFactor;
    annotations(i).z([1 2]) = 1;
    annotations(i).tag = sprintf('Annotation-%s', num2str(branches(i).id));
    annotations(i).text = sprintf('Neurolucida data: %s\nBranch -\nLength: %s\n  ID: %s\n Parent: %s', mat2str(nld(branches(i).id, :)), ...
        num2str(leaves(i).length), num2str(branches(i).id), num2str(branches(i).parent));
    annotations(i).autoID = branches(i).id;
    annotations(i).userID = num2str(branches(i).id);
    annotations(i).correlationID = ia_getNewCorrelationId;
    annotations(i).correlationState = 'unknown';
    annotations(i).persistence = 5;%Stable: 1, Loss: 2, Gain: 3, Transient: 4, Neutral: 5
    annotations(i).creationTime = clock;
    annotations(i).userData.type = 'Neurolucida';
    annotations(i).userData.nldAnalysis = branches(i);
    
    waitbar(i / operations, wb);
    
    if isWaitbarCancelled(wb)
        delete(wb);
        return;
    end
end

operations = length(leaves);

for i = 1 : length(leaves)
    annotations(i + length(branches)).type = 'Line';
    annotations(i + length(branches)).x = [nld(leaves(i).parent, 3) nld(leaves(i).id, 3)] / xFactor;
    annotations(i + length(branches)).y = [nld(leaves(i).parent, 4) nld(leaves(i).id, 4)] / yFactor;
%     annotations(i + length(branches)).z = [nld(leaves(i).parent, 5) nld(leaves(i).id, 5)] / zFactor;
    annotations(i + length(branches)).z([1 2]) = 1;
    annotations(i + length(branches)).tag = sprintf('Annotation-%s', num2str(leaves(i).id));
    annotations(i + length(branches)).text = sprintf('Neurolucida data: %s\Leaf -\nLength: %s\n  ID: %s\n Parent: %s', mat2str(nld(leaves(i).id, :)), ...
        num2str(leaves(i).length), num2str(leaves(i).id), num2str(leaves(i).parent));
    annotations(i + length(branches)).autoID = leaves(i).id;
    annotations(i + length(branches)).userID = num2str(leaves(i).id);
    annotations(i + length(branches)).correlationID = ia_getNewCorrelationId;
    annotations(i + length(branches)).correlationState = 'unknown';
    annotations(i + length(branches)).persistence = 5;%Stable: 1, Loss: 2, Gain: 3, Transient: 4, Neutral: 5
    annotations(i + length(branches)).creationTime = clock;
    annotations(i + length(branches)).userData.type = 'Neurolucida';
    annotations(i + length(branches)).userData.nldAnalysis = leaves(i);
       
    waitbar(i / operations, wb);
    
    if isWaitbarCancelled(wb)
        delete(wb);
        return;
    end
end

delete(wb);

%Store this stuff in its raw form.
importedData = getLocal(progmanager, hObject, 'importedData');
importedData.nld = nld;
importedData.branches = branches;
importedData.leaves = leaves;
setLocal(progmanager, hObject, 'importedData', importedData);
setLocal(progmanager, hObject, 'importedDataType', 'Neurolucida');

setLocal(progmanager, hObject, 'currentAnnotation', length(annotations));
setLocal(progmanager, hObject, 'annotations', annotations);
ia_createAnnotationGraphics(hObject);
setLocal(progmanager, hObject, 'tagCounter', max([getLocal(progmanager, hObject, 'tagCounter') (length(branches) + length(leaves))]) + 1);

feval(getLocal(progmanager, hObject, 'annotationDisplayUpdateFcn'), getLocal(progmanager, hObject, 'annotationObject'));

toggleGuiVisibility(progmanager, getGlobal(progmanager, 'optionsObject', 'StackBrowserControl', 'stackBrowserControl'), 'stackBrowserOptions', 'On');
ia_setOption(getGlobal(progmanager, 'hObject', 'StackBrowserControl', 'stackBrowserControl'), 'allowCorrelationIDCollisions', 1);

return;

% --------------------------------------------------------------------
function updateSessionInfo(hObject)

% session.filePath = getLocal(progmanager, hObject, 'filePath');
% session.fileName = getLocal(progmanager, hObject, 'fileName');
% session.frameNumber = getLocal(progmanager, hObject, 'frameNumber');
% session.whiteValue = getLocal(progmanager, hObject, 'whiteValue');
% session.blackValue = getLocal(progmanager, hObject, 'blackValue');
% session.fileNameDisplay = getLocal(progmanager, hObject, 'fileNameDisplay');
% session.zoomFactor = getLocal(progmanager, hObject, 'zoomFactor');
% session.currentChannel = getLocal(progmanager, hObject, 'currentChannel');
% session.shiftStepSize = getLocal(progmanager, hObject, 'shiftStepSize');
% session.filterType = getLocal(progmanager, hObject, 'filterType');
% session.showAnnotation = getLocal(progmanager, hObject, 'showAnnotation');
% session.currentAnnotation = getLocal(progmanager, hObject, 'currentAnnotation');
% session.projectAnnotations = getLocal(progmanager, hObject, 'projectAnnotations');
% session.zoomOnPrimaryImage = getLocal(progmanager, hObject, 'zoomOnPrimaryImage');
% session.fiducialOnPrimary = getLocal(progmanager, hObject, 'fiducialOnPrimary');
% session.fiducialOnGlobal = getLocal(progmanager, hObject, 'fiducialOnGlobal');
% session.xBoundLow = getLocal(progmanager, hObject, 'xBoundLow');
% session.xBoundHigh = getLocal(progmanager, hObject, 'xBoundHigh');
% session.yBoundLow = getLocal(progmanager, hObject, 'yBoundLow');
% session.yBoundHigh = getLocal(progmanager, hObject, 'yBoundHigh');
% session.projectFrom = getLocal(progmanager, hObject, 'projectFrom');
% session.projectTo = getLocal(progmanager, hObject, 'projectTo');
% session.registrationTransform = getLocal(progmanager, hObject, 'registrationTransform');
% session.polylinesOnPrimary = getLocal(progmanager, hObject, 'polylinesOnPrimary');
% session.polylinesOnGlobal = getLocal(progmanager, hObject, 'polylinesOnGlobal');
% session.emfClipboardType = getLocal(progmanager, hObject, 'emfClipboardType');
% session.autoSubtractImageMin = getLocal(progmanager, hObject, 'autoSubtractImageMin');
% session.filterWindowSize = getLocal(progmanager, hObject, 'filterWindowSize');
% session.switchFrameOnSelection = getLocal(progmanager, hObject, 'switchFrameOnSelection');
% session.allowCorrelationIDCollisions = getLocal(progmanager, hObject, 'allowCorrelationIDCollisions');
% session.unitaryConversions = getLocal(progmanager, hObject, 'unitaryConversions');
% session.xConversionFactor = getLocal(progmanager, hObject, 'xConversionFactor');
% session.xUnits = getLocal(progmanager, hObject, 'xUnits');
% session.yConversionFactor = getLocal(progmanager, hObject, 'yConversionFactor');
% session.yUnits = getLocal(progmanager, hObject, 'yUnits');
% session.zConversionFactor = getLocal(progmanager, hObject, 'zConversionFactor');
% session.zUnits = getLocal(progmanager, hObject, 'zUnits');
% session. = getLocal(progmanager, hObject, 'subPrograms');
% session. = getLocal(progmanager, hObject, 'subPrograms');
% session. = getLocal(progmanager, hObject, 'subPrograms');
% session. = getLocal(progmanager, hObject, 'subPrograms');
% session. = getLocal(progmanager, hObject, 'subPrograms');
% session. = getLocal(progmanager, hObject, 'subPrograms');
% session. = getLocal(progmanager, hObject, 'subPrograms');
% session. = getLocal(progmanager, hObject, 'subPrograms');
% session. = getLocal(progmanager, hObject, 'subPrograms');
% session. = getLocal(progmanager, hObject, 'subPrograms');

%        'volumeDistanceFactor', 2, 'Class', 'Numeric', ...
%        'volumeDistanceMaskThreshold', [0.6], 'Class', 'Array', ...
%        'volumeDistanceMaskThresholdFactor', [0], 'Class', 'Array', ...
%        'volumeWeightDistanceMask', 1, 'Class', 'Numeric', ...
%        'volumeWeightEdgeMask', 1, 'Class', 'Numeric', ...
%        'volumeWeightProfileMask', 1, 'Class', 'Numeric', ...
%        'volumeEdgeFilterStrength', 5, 'Class', 'Numeric', ...
%        'volumeRegionSizeFactor', 2, 'Class', 'Numeric', ...
%        'volumeBinarizeDistanceMask', 0, 'Class', 'Numeric', ...
%        'volumeProfileRadiusFactor', 10, 'Class', 'Numeric', ...
%        'volumeThresholdFactor', 0.1, 'Class', 'Numeric', ...
%        'volumeProfileCenterWeight', .5, 'Class', 'Numeric', ...
%        'volumeProfileThresholds', [1 2], 'Class', 'Array', ...
%        'volumeProfileValues', [1 .5], 'Class', 'Array', ...
%        'currentHeader', [], ...
%        'volumeFrameWindow', 3, 'Class', 'Numeric', 'Min', 0, ...
%        'volumeAutoSelectRegion', 1, 'Class', 'Numeric', 'Min', 0, 'Max', 1, ...
%        'volumeAutoScanFrames', 1, 'Class', 'Numeric', 'Min', 0, 'Max', 1, ...
%        'volumeDisplayCalculations', 1, 'Class', 'Numeric', 'Min', 0, 'Max', 1, ...
%        'gridLines', [], ...
%        'gridLineSpacing', 50, 'Class', 'Numeric', ...
%        'gridLinesVisible', 0, 'Class', 'Numeric', ...
%        'drawGridLines', @drawGridLines, ...
%        'setGridLineVisibility', @setGridLineVisibility, ...

return;

% --------------------------------------------------------------------
function im = getUnfilteredImage(hObject)

filterType = getLocal(progmanager, hObject, 'filterType');
if isempty(filterType) | strcmpi(filterType, 'none')
    im = getLocal(progmanager, hObject, 'currentImage');
else
    im = getLocal(progmanager, hObject, 'originalImage');
end

if isempty(im)
    warndlg('Imaging caching is disabled. In order to change the filter settings, the image must be reloaded.');
end

return;

% --------------------------------------------------------------------
function applyFilter(hObject)

filterType = lower(getLocal(progmanager, hObject, 'filterType'));

switch filterType
    case 'none'
        noFiltering_Callback(hObject, [], []);
    case 'median'
        medianFilter_Callback(hObject, [], []);
    case 'wiener'
        weinerFilter_Callback(hObject, [], []);
    case 'sobel'
        sobelFilter_Callback(hObject, [], []);
    case 'gaussian'
        gaussianFilter_Callback(hObject, [], []);
    case 'prewitt'
        prewittFilter_Callback(hObject, [], []);
    case 'laplacian'
        laplacianFilter_Callback(hObject, [], []);
    case 'log'
        laplacianOfGaussianFilter_Callback(hObject, [], []);
    case 'unsharp'
        unsharpFilter_Callback(hObject, [], []);
    otherwise
        warning('Unrecognized filterType.');
end

return;

% --------------------------------------------------------------------
function updateUnits(hObject)

stackBrowserUnits = getLocal(progmanager, hObject, 'stackBrowserUnits');

xConversionFactor = getGlobal(progmanager, 'xConversionFactor', 'stackBrowserControl', 'StackBrowserControl');
setLocal(progmanager, hObject, 'xConversionFactor', xConversionFactor);
setLocal(progmanager, stackBrowserUnits, 'xConversionFactor', xConversionFactor);

yConversionFactor = getGlobal(progmanager, 'yConversionFactor', 'stackBrowserControl', 'StackBrowserControl');
setLocal(progmanager, hObject, 'yConversionFactor', yConversionFactor);
setLocal(progmanager, stackBrowserUnits, 'yConversionFactor', yConversionFactor);

zConversionFactor = getGlobal(progmanager, 'zConversionFactor', 'stackBrowserControl', 'StackBrowserControl');
setLocal(progmanager, hObject, 'zConversionFactor', zConversionFactor);
setLocal(progmanager, stackBrowserUnits, 'zConversionFactor', zConversionFactor);

xUnits = getGlobal(progmanager, 'xUnits', 'stackBrowserControl', 'StackBrowserControl');
setLocal(progmanager, hObject, 'xUnits', xUnits);
setLocal(progmanager, stackBrowserUnits, 'xUnits', xUnits);

yUnits = getGlobal(progmanager, 'yUnits', 'stackBrowserControl', 'StackBrowserControl');
setLocal(progmanager, hObject, 'yUnits', yUnits);
setLocal(progmanager, stackBrowserUnits, 'yUnits', yUnits);

zUnits = getGlobal(progmanager, 'zUnits', 'stackBrowserControl', 'StackBrowserControl');
setLocal(progmanager, hObject, 'zUnits', zUnits);
setLocal(progmanager, stackBrowserUnits, 'zUnits', zUnits);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function currentChannel_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
% --- Executes on selection change in currentChannel.
function currentChannel_Callback(hObject, eventdata, handles)

channel = getLocal(progmanager, hObject, 'currentChannel');
photometryWindow = getLocal(progmanager, hObject, 'photometryWindow');
setLocal(progmanager, photometryWindow, 'backgroundChannel', channel);
setLocal(progmanager, photometryWindow, 'normalizationChannel', channel);
setLocal(progmanager, photometryWindow, 'integralChannel', channel);

displayNewImage(hObject);

if ~isempty(getLocal(progmanager, hObject, 'registrationTransform'))
    applyTransform(hObject);
end

maxProjectGlobal(hObject);
ia_setLineVisibilities(hObject);

return;


% --------------------------------------------------------------------
%TO080707A - Allow annotations to be imported from other images in the same dataset.
function importAcrossImages_Callback(hObject, eventdata, handles)

persistentData = getGlobal(progmanager, 'persistentData', 'stackBrowserControl', 'stackBrowserControl');

%TO090507B - listdlg returns the index of the selection, not the string.
[index, ok] = listdlg('PromptString','Select an image from which to import annotations...',...
                'SelectionMode','single', ...
                'ListString', {persistentData{:, 1}}, 'Name', 'Import Across Image');
if ~ok
    return;
end

% index = find(strcmp(filename, {persistentData{:, 1}}));

setLocal(progmanager, hObject, 'importedDataType', 'AcrossImage');

setLocal(progmanager, hObject, 'currentAnnotation', length(persistentData{index, 2}));
setLocal(progmanager, hObject, 'annotations', persistentData{index, 2});
ia_createAnnotationGraphics(hObject);
feval(getLocal(progmanager, hObject, 'annotationDisplayUpdateFcn'), getLocal(progmanager, hObject, 'annotationObject'));

ia_updatePhotometryValues(hObject);
photometryWindow = getLocal(progmanager, hObject, 'photometryWindow');
setLocalGh(progmanager, photometryWindow, 'storeBackground', 'FontWeight', 'Bold');
setLocalGh(progmanager, photometryWindow, 'storeNormalization', 'FontWeight', 'Bold');
setLocalGh(progmanager, photometryWindow, 'storeIntegral', 'FontWeight', 'Bold');

%Should the units be updated?

%TO092107A - Try to update the graphics.
ia_createAnnotationGraphics(hObject);
try
    ia_redrawRegions(hObject);
catch
    warning('An error occurred while updating photometry graphics during data import - ''%s''\n', lasterr);
end

return;

% --------------------------------------------------------------------
%TO092107A - New feature.
function ImportPhotometryAcrossImages_Callback(hObject, eventdata, handles)

persistentData = getGlobal(progmanager, 'persistentData', 'stackBrowserControl', 'stackBrowserControl');

%TO090507B - listdlg returns the index of the selection, not the string.
[index, ok] = listdlg('PromptString','Select an image from which to import annotations...',...
                'SelectionMode','single', ...
                'ListString', {persistentData{:, 1}}, 'Name', 'Import Across Image');
if ~ok
    return;
end

annotations = getLocal(progmanager, hObject, 'annotations');
importedAnnotations = persistentData{index, 2};
correlationIDs = [importedAnnotations(:).correlationID];

for i = 1 : length(annotations)
    idx = find(annotations(i).correlationID == correlationIDs);
    if length(idx) > 1
        fprintf(2, 'stackBrowser/ImportPhotometryAcrossImages_Callback - Found multiple instances of correlationID %s, using first occurence.\n', num2str(annotations(i).correlationID));
        idx = idx(1);
    end
    if ~isempty(idx)
    	annotations(i).photometry = importedAnnotations(idx).photometry;
    end
end

setLocal(progmanager, hObject, 'annotations', annotations);

try
    ia_updatePhotometryFromAnnotation(hObject);
    photometryWindow = getLocal(progmanager, hObject, 'photometryWindow');
    setLocal(progmanager, photometryWindow, 'showRegions', 1);
    ia_redrawRegions(photometryWindow);
catch
    warning('An error occurred while updating photometry graphics during photometry data import - ''%s''\n', lasterr);
end

return;

% --------------------------------------------------------------------
%TO122209B - Added cross-channel bleedthrough subtraction.
function bleedthroughSubtractMenuItem_Callback(hObject, eventdata, handles)

answer = inputdlg({'Bleedthrough [%] channel 1 -> channel 2:', 'Bleedthrough [%] channel 2 -> channel 1:'}, 'Cross-channel Bleedthrough Percentages', 1, {'10', '10'});
ia_bleedthroughSubtract(hObject, str2num(answer{1}), str2num(answer{1}));

return;

% --------------------------------------------------------------------
%TO122209D - Added a histogram display.
function displayHistogram(hObject, eventdata, ax)
global f h im
if ax == getLocalGh(progmanager, hObject, 'primaryView')
    im = get(getLocal(progmanager, hObject, 'primaryImage'), 'CData');
else
    im = get(getLocal(progmanager, hObject, 'globalImage'), 'CData');
end

f = figure;
hist(reshape(im, numel(im), 1), 100);

return;