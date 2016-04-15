function varargout = photometry(varargin)
% PHOTOMETRY M-file for photometry.fig
%      PHOTOMETRY, by itself, creates a new PHOTOMETRY or raises the existing
%      singleton*.
%
%      H = PHOTOMETRY returns the handle to a new PHOTOMETRY or the handle to
%      the existing singleton*.
%
%      PHOTOMETRY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHOTOMETRY.M with the given input arguments.
%
%      PHOTOMETRY('Property','Value',...) creates a new PHOTOMETRY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before photometry_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to photometry_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help photometry

% Last Modified by GUIDE v2.5 03-Jun-2005 18:04:32

% Begin initialization code - DO NOT EDIT

%% CHANGES
%   VI071310A: Use getRectFromAxes()/getPointsFromAxes for selection of rectangular area & points, respectively -- Vijay Iyer 7/13/10
%
%% *********************************************

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @photometry_OpeningFcn, ...
                   'gui_OutputFcn',  @photometry_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


% --- Executes just before photometry is made visible.
function photometry_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to photometry (see VARARGIN)

% Choose default command line output for photometry
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes photometry wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% ------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = photometry_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
        'hObject', hObject, ...
        'minimumPixelValue', 0, 'Class', 'Numeric', 'Gui', 'minimumPixelValue', ...
        'backgroundValue', 0, 'Class', 'Numeric', 'Gui', 'backgroundValue', ...
        'normalizationFactor', 0, 'Class', 'Numeric', 'Gui', 'normalizationFactor', ...
        'intensityIntegral', 0, 'Class', 'Numeric', 'Gui', 'intensityIntegral', ...
        'normalizedBackgroundSubtractedIntegral', 0, 'Class', 'Numeric', 'Gui', 'normalizedBackgroundSubtractedIntegral', ...
        'backgroundRegion', [], ...
        'backgroundFrame', [], ...
        'backgroundFrameDisplay', 1, 'Class', 'Numeric', 'Gui', 'backgroundFrameDisplay', ...
        'normalizationRegion', [], ...
        'normalizationFrame', [], ...
        'normalizationFrameDisplay', 1, 'Class', 'Numeric', 'Gui', 'normalizationFrameDisplay', ...
        'integralRegion', [], ...
        'integralFrame', [], ...
        'integralFrameDisplay', 1, 'Class', 'Numeric', 'Gui', 'integralFrameDisplay', ...
        'backgroundRegionGraphic', [], ...
        'normalizationRegionGraphic', [], ...
        'integralRegionGraphic', [], ...
        'firstDraw', 1, ...
        'showRegions', 0, 'Class', 'Numeric', 'Gui', 'showRegions', ...
        'normalizationRegionGraphic_global', [], ...
        'recalculateNormalization', 1, ...
        'normalizationMethod', 1, 'Class', 'Numeric', 'Gui', 'normalizationMethod', ...
        'backgroundChannel', 1, 'Class', 'Numeric', ...
        'normalizationChannel', 1, 'Class', 'Numeric', ...
        'integralChannel', 1, 'Class', 'Numeric', ...
        'normalizationVoxel', [], ...
        'lastNormalizationChannel', 0, ...
    };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

setMain(progmanager, hObject, 'photometryWindow', hObject);
toggleGuiVisibility(progmanager, hObject, 'photometry', 'Off');

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes on button press in selectBackground.
function selectBackground_Callback(hObject, eventdata, handles)

selectRegion(hObject, 'background');
setLocal(progmanager, hObject, 'showRegions', 1);
setLocalGh(progmanager, hObject, 'storeBackground', 'FontWeight', 'Bold');
ia_updatePhotometryValues(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in selectNormalization.
function selectNormalization_Callback(hObject, eventdata, handles)

%5/30/05 - Added Sen's function, `shiftDendriteMax`, with quite a few assorted changes and 
%          support for image registration. -- Tim O'Connor 5/30/05 TO053005A

% selectRegion(hObject, 'normalization');
if getGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl')
    return;
end

% ax = getMainGh(progmanager, hObject, 'globalView');
frame = getMain(progmanager, hObject, 'frameNumber');
maxProjected = get(getMain(progmanager, hObject, 'globalImage'), 'CData');
cLim = get(getMainGh(progmanager, hObject, 'globalView'), 'CLim');
f = figure;
title('Select Dendrite from Max Projection');
set(f, 'Colormap', gray);

i = imagesc(maxProjected, cLim);
ax = gca;
set(ax, 'YDir', 'normal');

setGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl', 1);

[x y] = getPointsFromAxes(ax,'numberOfPoints',2,'nomovegui',1); %VI071310A

if length(x) < 3 | length(y) < 3
    errordlg('Invalid selection, at least 3 points must be chosen to define a curved line.');
    setGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl', 0);
    return;
end

%Take care of image registration.
tform = getMain(progmanager, hObject, 'registrationTransform');
if isempty(tform)
    %Unregistered
    bounds = x';
    bounds(2, 1:length(y)) = y';
else
    %Registered
    if size(x, 1) < size(x, 2)
        bounds = tforminv(cat(2, x', y'), tform)';
    else
        bounds = tforminv(cat(2, x, y), tform)';
    end
end

setLocal(progmanager, hObject, 'normalizationRegion', bounds);
setLocal(progmanager, hObject, 'normalizationFrame', frame);
setLocal(progmanager, hObject, 'recalculateNormalization', 1);
delete(f);

setGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl', 0);
setLocal(progmanager, hObject, 'showRegions', 1);
setLocalGh(progmanager, hObject, 'storeNormalization', 'FontWeight', 'Bold');
setLocal(progmanager, hObject, 'normalizationVoxel', []);%TO080706A - Force it to optimize the new selection.
setLocal(progmanager, hObject, 'lastNormalizationChannel', getMain(progmanager, hObject, 'currentChannel'));%TO090507B
ia_updatePhotometryValues(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in selectIntensityIntegral.
function selectIntensityIntegral_Callback(hObject, eventdata, handles)

selectRegion(hObject, 'integral');
setLocal(progmanager, hObject, 'showRegions', 1);
setLocalGh(progmanager, hObject, 'storeIntegral', 'FontWeight', 'Bold');
ia_updatePhotometryValues(hObject);

return;

% ------------------------------------------------------------------
function selectRegion(hObject, regionName)

if getGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl')
    return;
end

primaryView = getMainGh(progmanager, hObject, 'primaryView');

setGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl', 1);

set(getParent(primaryView, 'figure'), 'HandleVisibility', 'On');%TO062007C - getline spawns a new figure in Matlab 7 if the HandleVisibility is set to Off. -- Tim O'Connor 6/20/07
[x y] = getPointsFromAxes(primaryView,'numberOfPoints',2,'nomovegui',1); %VI071310A
set(getParent(primaryView, 'figure'), 'HandleVisibility', 'Off');%TO062007C - getline spawns a new figure in Matlab 7 if the HandleVisibility is set to Off. -- Tim O'Connor 6/20/07

%Make sure it's a properly bounded region.
% if ~strcmpi(regionName, 'normalizationRegion')
    if length(x) == 1 | length(y) == 1
        errdlg('You must select a closed region.');
        selectRegion(hObject, regionName);
        return;
    else
        if x(1) ~= x(end) | y(1) ~= y(end)
            x(length(x) + 1) = x(1);
            y(length(y) + 1) = y(1);
        end
    end
% end

% bounds = x';
% bounds(2, 1:length(y)) = y';
%Take care of image registration.
tform = getMain(progmanager, hObject, 'registrationTransform');
if isempty(tform)
    %Unregistered
    bounds = x';
    bounds(2, 1:length(y)) = y';
else
    %Registered
    if size(x, 1) < size(x, 2)
        bounds = tforminv(cat(2, x', y'), tform)';
    else
        bounds = tforminv(cat(2, x, y), tform)';
    end
end

setLocal(progmanager, hObject, [regionName 'Region'], bounds);
setLocal(progmanager, hObject, [regionName 'Frame'], []);

setGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl', 0);

return;

% ------------------------------------------------------------------
% --- Executes on button press in updateCalculations.
function updateCalculations_Callback(hObject, eventdata, handles)

%TO080707A - Update the channels as well as the frames.
frame = getMain(progmanager, hObject, 'frameNumber');
channel = getMain(progmanager, hObject, 'currentChannel');

%TO090507B - Force the regions of interest to be moved to the current channel. -- Tim O'Connor 9/5/07
if getLocal(progmanager, hObject, 'lastNormalizationChannel') ~= channel
    if getMain(progmanager, hObject, 'optimizePhotometryNormalization')
        setLocal(progmanager, hObject, 'recalculateNormalization', 1);
    end
    setLocalBatch(progmanager, hObject, 'recalculateNormalization', 1, 'normalizationVoxel', []);
    setLocal(progmanager, hObject, 'lastNormalizationChannel', channel);
end

setLocalBatch(progmanager, hObject, 'backgroundFrame', frame, 'backgroundChannel', channel);
setLocalBatch(progmanager, hObject, 'normalizationFrame', frame, 'normalizationChannel', channel);
setLocalBatch(progmanager, hObject, 'integralFrame', frame, 'integralChannel', channel);
setLocalGh(progmanager, hObject, 'storeBackground', 'FontWeight', 'Bold');
setLocalGh(progmanager, hObject, 'storeNormalization', 'FontWeight', 'Bold');
setLocalGh(progmanager, hObject, 'storeIntegral', 'FontWeight', 'Bold');

ia_updatePhotometryValues(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in storeBackground.
function storeBackground_Callback(hObject, eventdata, handles)

annotations = getMain(progmanager, hObject, 'annotations');
index = getMain(progmanager, hObject, 'currentAnnotation');
channel = getMain(progmanager, hObject, 'currentChannel');
if isempty(annotations) | isempty(index) | index < 1
    warndlg('You must select an annotation to store this value in.');
    return;
end

%TO080707 - Process photometry across multiple channels, for ratiometric imaging. -- Tim O'Connor 8/7/07
if getMain(progmanager, hObject, 'multichannelPhotometryData')
    %This seems a bit kludgy, recalculating values for all channels on each store operation. But, it seems simple enough to code.
    for i = 1 : getMain(progmanager, hObject, 'numberOfChannels')
        ia_updatePhotometryValues(hObject, i);
        annotations(index).photometry(i).background = getLocal(progmanager, hObject, 'backgroundValue');
        annotations(index).photometry(i).backgroundBounds = getLocal(progmanager, hObject, 'backgroundRegion');
        annotations(index).photometry(i).backgroundFrame = getMain(progmanager, hObject, 'frameNumber');
        annotations(index).photometry(i).backgroundChannel = i;
    end
else
    ia_updatePhotometryValues(hObject);
    annotations(index).photometry(channel).background = getLocal(progmanager, hObject, 'backgroundValue');
    annotations(index).photometry(channel).backgroundBounds = getLocal(progmanager, hObject, 'backgroundRegion');
    annotations(index).photometry(channel).backgroundFrame = getMain(progmanager, hObject, 'frameNumber');
    annotations(index).photometry(channel).backgroundChannel = channel;
end
setLocal(progmanager, hObject, 'backgroundFrame', annotations(index).photometry(channel).backgroundFrame);

setLocalGh(progmanager, hObject, 'storeBackground', 'FontWeight', 'Normal');

setMain(progmanager, hObject, 'annotations', annotations);

setGlobal(progmanager, 'changesMadeSinceLastSave', 'StackBrowserControl', 'stackBrowserControl', 1);

return;

% ------------------------------------------------------------------
% --- Executes on button press in storeNormalization.
function storeNormalization_Callback(hObject, eventdata, handles)

annotations = getMain(progmanager, hObject, 'annotations');
index = getMain(progmanager, hObject, 'currentAnnotation');
channel = getMain(progmanager, hObject, 'currentChannel');
if isempty(annotations) | isempty(index) | index < 1
    warndlg('You must select an annotation to store this value in.');
    return;
end

%TO080707 - Process photometry across multiple channels, for ratiometric imaging. -- Tim O'Connor 8/7/07
if getMain(progmanager, hObject, 'multichannelPhotometryData')
    %This seems a bit kludgy, recalculating values for all channels on each store operation. But, it seems simple enough to code.
    for i = 1 : getMain(progmanager, hObject, 'numberOfChannels')
        setLocal(progmanager, hObject, 'recalculateNormalization', 1);
        ia_updatePhotometryValues(hObject, i);
        annotations(index).photometry(i).normalization = getLocal(progmanager, hObject, 'normalizationFactor');
        annotations(index).photometry(i).normalizationBounds = getLocal(progmanager, hObject, 'normalizationRegion');
        annotations(index).photometry(i).normalizationFrame = getMain(progmanager, hObject, 'frameNumber');
        annotations(index).photometry(i).normalizationMethod = getLocal(progmanager, hObject, 'normalizationMethod');
        annotations(index).photometry(i).normalizationChannel = i;
    end
else
    ia_updatePhotometryValues(hObject);%TO080707A - Why was this being done after the setMain (below)?
    annotations(index).photometry(channel).normalization = getLocal(progmanager, hObject, 'normalizationFactor');
    annotations(index).photometry(channel).normalizationBounds = getLocal(progmanager, hObject, 'normalizationRegion');
    annotations(index).photometry(channel).normalizationFrame = getMain(progmanager, hObject, 'frameNumber');
    annotations(index).photometry(channel).normalizationMethod = getLocal(progmanager, hObject, 'normalizationMethod');
    annotations(index).photometry(channel).normalizationChannel = getMain(progmanager, hObject, 'currentChannel');
    setLocal(progmanager, hObject, 'normalizationFrame', annotations(index).photometry(channel).normalizationFrame);
end

setLocalGh(progmanager, hObject, 'storeNormalization', 'FontWeight', 'Normal');

ia_updatePhotometryValues(hObject);%TO080707A - Why was this being done after the setMain (below)?
setMain(progmanager, hObject, 'annotations', annotations);

setGlobal(progmanager, 'changesMadeSinceLastSave', 'StackBrowserControl', 'stackBrowserControl', 1);

return;

% ------------------------------------------------------------------
% --- Executes on button press in storeIntegral.
function storeIntegral_Callback(hObject, eventdata, handles)

annotations = getMain(progmanager, hObject, 'annotations');
index = getMain(progmanager, hObject, 'currentAnnotation');
channel = getMain(progmanager, hObject, 'currentChannel');
if isempty(annotations) | isempty(index) | index < 1
    warndlg('You must select an annotation to store this value in.');
    return;
end

%TO080707 - Process photometry across multiple channels, for ratiometric imaging. -- Tim O'Connor 8/7/07
if getMain(progmanager, hObject, 'multichannelPhotometryData')
    %This seems a bit kludgy, recalculating values for all channels on each store operation. But, it seems simple enough to code.
    for i = 1 : getMain(progmanager, hObject, 'numberOfChannels')
        ia_updatePhotometryValues(hObject, i);
        annotations(index).photometry(i).integral = getLocal(progmanager, hObject, 'intensityIntegral');
        annotations(index).photometry(i).integralBounds = getLocal(progmanager, hObject, 'integralRegion');
        annotations(index).photometry(i).integralFrame = getMain(progmanager, hObject, 'frameNumber');
        annotations(index).photometry(i).integralChannel = i;
        annotations(index).photometry(i).integralPixelCount = getLocal(progmanager, hObject, 'integralPixelCount');%TO080507D
    end
else
    ia_updatePhotometryValues(hObject);%TO080707A - Why was this being done after the setMain (below)?
    annotations(index).photometry(channel).integral = getLocal(progmanager, hObject, 'intensityIntegral');
    annotations(index).photometry(channel).integralBounds = getLocal(progmanager, hObject, 'integralRegion');
    annotations(index).photometry(channel).integralFrame = getMain(progmanager, hObject, 'frameNumber');
    annotations(index).photometry(channel).integralChannel = getMain(progmanager, hObject, 'currentChannel');
    annotations(index).photometry(channel).integralPixelCount = getLocal(progmanager, hObject, 'integralPixelCount');%TO080507D
end
setLocal(progmanager, hObject, 'integralFrame', annotations(index).photometry(channel).integralFrame);

setLocalGh(progmanager, hObject, 'storeIntegral', 'FontWeight', 'Normal');

setMain(progmanager, hObject, 'annotations', annotations);

setGlobal(progmanager, 'changesMadeSinceLastSave', 'StackBrowserControl', 'stackBrowserControl', 1);

return;

% ------------------------------------------------------------------
% --- Executes on button press in showRegions.
function showRegions_Callback(hObject, eventdata, handles)

ia_updatePhotometryValues(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function backgroundFrameDisplay_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
function backgroundFrameDisplay_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function normalizationFrameDisplay_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


return;

% ------------------------------------------------------------------
function normalizationFrameDisplay_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function integralFrameDisplay_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
function integralFrameDisplay_Callback(hObject, eventdata, handles)


return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function normalizationMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to normalizationMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
% --- Executes on selection change in normalizationMethod.
function normalizationMethod_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'recalculateNormalization', 1);
ia_updatePhotometryValues(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in removeStored.
function removeStored_Callback(hObject, eventdata, handles)

annotations = getMain(progmanager, hObject, 'annotations');
index = getMain(progmanager, hObject, 'currentAnnotation');
if isempty(annotations) | isempty(index) | index < 1
    warndlg('You must select an annotation from which to remove photometry data.');
    return;
end

annotations(index).photometry.background = [];
annotations(index).photometry.backgroundBounds = [];
annotations(index).photometry.backgroundFrame = [];
annotations(index).photometry.normalization = [];
annotations(index).photometry.normalizationBounds = [];
annotations(index).photometry.normalizationFrame = [];
annotations(index).photometry.normalizationMethod = [];
annotations(index).photometry.integral = [];
annotations(index).photometry.integralBounds = [];
annotations(index).photometry.integralFrame = [];
setLocalGh(progmanager, hObject, 'storeBackground', 'FontWeight', 'Bold');
setLocalGh(progmanager, hObject, 'storeNormalization', 'FontWeight', 'Bold');
setLocalGh(progmanager, hObject, 'storeIntegral', 'FontWeight', 'Bold');

setMain(progmanager, hObject, 'annotations', annotations);

ia_updatePhotometryValues(hObject);
setGlobal(progmanager, 'changesMadeSinceLastSave', 'StackBrowserControl', 'stackBrowserControl', 1);

return;