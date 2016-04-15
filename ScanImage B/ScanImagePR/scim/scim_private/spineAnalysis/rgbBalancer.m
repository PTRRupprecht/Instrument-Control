function varargout = rgbBalancer(varargin)
% RGBBALANCER M-file for rgbBalancer.fig
%      RGBBALANCER, by itself, creates a new RGBBALANCER or raises the existing
%      singleton*.
%
%      H = RGBBALANCER returns the handle to a new RGBBALANCER or the handle to
%      the existing singleton*.
%
%      RGBBALANCER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RGBBALANCER.M with the given input arguments.
%
%      RGBBALANCER('Property','Value',...) creates a new RGBBALANCER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rgbBalancer_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rgbBalancer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rgbBalancer

% Last Modified by GUIDE v2.5 21-Dec-2009 16:21:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rgbBalancer_OpeningFcn, ...
                   'gui_OutputFcn',  @rgbBalancer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before rgbBalancer is made visible.
function rgbBalancer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rgbBalancer (see VARARGIN)

% Choose default command line output for rgbBalancer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rgbBalancer wait for user response (see UIRESUME)
% uiwait(handles.figure1);
return;

%--------------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = rgbBalancer_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

return;

%--------------------------------------------------------------------------
function redHigh_Callback(hObject, eventdata, handles)

updateBalancedImage(hObject);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function redHigh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

return;

%--------------------------------------------------------------------------
function greenHigh_Callback(hObject, eventdata, handles)

updateBalancedImage(hObject);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function greenHigh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

return;

%--------------------------------------------------------------------------
function blueHigh_Callback(hObject, eventdata, handles)

updateBalancedImage(hObject);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function blueHigh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

return;

%--------------------------------------------------------------------------
function redLow_Callback(hObject, eventdata, handles)

updateBalancedImage(hObject);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function redLow_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

return;

%--------------------------------------------------------------------------
function greenLow_Callback(hObject, eventdata, handles)

updateBalancedImage(hObject);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function greenLow_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

return;

%--------------------------------------------------------------------------
function blueLow_Callback(hObject, eventdata, handles)

updateBalancedImage(hObject);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function blueLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blueLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

return;

%--------------------------------------------------------------------------
% --- Executes on button press in copyToClipboard.
function copyToClipboard_Callback(hObject, eventdata, handles)
global rgbBalancerGlobal;

f = getParent(rgbBalancerGlobal.imageH, 'figure');

if rgbBalancerGlobal.emfClipboardType
    print(f, '-dmeta');
else
    print(f, '-dbitmap');
end

return;

%--------------------------------------------------------------------------
% --- Executes on button press in closeWindow.
function closeWindow_Callback(hObject, eventdata, handles)
global rgbBalancerGlobal;

if isfield(rgbBalancerGlobal, 'internalFigure')
    if ishandle(rgbBalancerGlobal.internalFigure)
        delete(rgbBalancerGlobal.internalFigure);
    end
end

delete(getParent(hObject, 'figure'));

return;

%--------------------------------------------------------------------------
% --- Executes on button press in redFull.
function redFull_Callback(hObject, eventdata, handles)

fullRange(hObject, 1);

return;

%--------------------------------------------------------------------------
% --- Executes on button press in greenFull.
function greenFull_Callback(hObject, eventdata, handles)

fullRange(hObject, 2);

return;

%--------------------------------------------------------------------------
% --- Executes on button press in blueFull.
function blueFull_Callback(hObject, eventdata, handles)

fullRange(hObject, 3);

return;

%--------------------------------------------------------------------------
% --- Executes on button press in redStdDev.
function redStdDev_Callback(hObject, eventdata, handles)

stdDev(hObject, 1);

return;

%--------------------------------------------------------------------------
% --- Executes on button press in greenStdDev.
function greenStdDev_Callback(hObject, eventdata, handles)

stdDev(hObject, 2);

return;

%--------------------------------------------------------------------------
% --- Executes on button press in blueStdDev.
function blueStdDev_Callback(hObject, eventdata, handles)

stdDev(hObject, 3);

return;

%--------------------------------------------------------------------------
function updateBalancedImage(hObject)
global rgbBalancerGlobal;

if ~isfield(rgbBalancer, 'balancedImage')
    rgbBalancerGlobal.balancedImage = zeros(size(rgbBalancerGlobal.originalImage));
end

handles = guidata(getParent(hObject, 'figure'));

redHigh = str2num(get(handles.redHigh, 'String'));
redHigh = max(redHigh, 1);
set(handles.redHigh, 'String', num2str(redHigh));
redLow = str2num(get(handles.redLow, 'String'));
redLow = max(min(redLow, redHigh - 1), 0);
set(handles.redLow, 'String', num2str(redLow));
if ~all(rgbBalancerGlobal.originalImage(:, :, 1) == 0)
    rgbBalancerGlobal.balancedImage(:, :, 1) = max(0, (rgbBalancerGlobal.originalImage(:, :, 1) - redLow)) / (redHigh - redLow);
end

greenHigh = str2num(get(handles.greenHigh, 'String'));
greenHigh = max(greenHigh, 1);
set(handles.greenHigh, 'String', num2str(greenHigh));
greenLow = str2num(get(handles.greenLow, 'String'));
greenLow = max(min(greenLow, greenHigh - 1), 0);
set(handles.greenLow, 'String', num2str(greenLow));
if ~all(rgbBalancerGlobal.originalImage(:, :, 2) == 0)
    rgbBalancerGlobal.balancedImage(:, :, 2) = max(0, (rgbBalancerGlobal.originalImage(:, :, 2) - greenLow)) / (greenHigh - greenLow);
end

blueHigh = str2num(get(handles.blueHigh, 'String'));
blueHigh = max(blueHigh, 1);
set(handles.blueHigh, 'String', num2str(blueHigh));
blueLow = str2num(get(handles.blueLow, 'String'));
blueLow = max(min(blueLow, blueHigh - 1), 0);
set(handles.blueLow, 'String', num2str(blueLow));
if ~all(rgbBalancerGlobal.originalImage(:, :, 3) == 0)
    rgbBalancerGlobal.balancedImage(:, :, 3) = max(0, (rgbBalancerGlobal.originalImage(:, :, 3) - blueLow)) / (blueHigh - blueLow);
end
% figure, hist(rgbBalancerGlobal.originalImage), title('Original');
% figure, hist(rgbBalancerGlobal.balancedImage), title('Balanced');
rgbBalancerGlobal.balancedImage = min(rgbBalancerGlobal.balancedImage, 1);
rgbBalancerGlobal.balancedImage = max(rgbBalancerGlobal.balancedImage, 0);

if ~ishandle(rgbBalancerGlobal.imageH)
    rgbBalancerGlobal.internalFigure = figure;
    rgbBalancerGlobal.imageH = imshow(rgbBalancerGlobal.balancedImage);
else
    set(rgbBalancerGlobal.imageH, 'CData', rgbBalancerGlobal.balancedImage);
end

%Make sure the axes fill the figure.
f = getParent(rgbBalancerGlobal.imageH, 'figure');
ax = getParent(rgbBalancerGlobal.imageH, 'axes');

xDim = size(rgbBalancerGlobal.balancedImage, 1);
yDim = size(rgbBalancerGlobal.balancedImage, 2);
set([f ax], 'Units', 'Pixels');
pos = get(f, 'Position');
pos(3) = max(pos(3), xDim);
pos(4) = max(pos(4), yDim);
if xDim == yDim
    pos(3) = min(pos(3), pos(4));
    pos(4) = pos(3);
end
set(f, 'Position', pos);
set(ax, 'Position', [1 1 pos(3) pos(4)]);

rgbBalancerGlobal.redLims = [redLow, redHigh];
rgbBalancerGlobal.greenLims = [greenLow, greenHigh];
rgbBalancerGlobal.blueLims = [blueLow, blueHigh];

return;

%--------------------------------------------------------------------------
function fullRange(hObject, channel)
global rgbBalancerGlobal;

mn = min(min(rgbBalancerGlobal.originalImage(:, :, channel)));
mx = max(max(rgbBalancerGlobal.originalImage(:, :, channel)));

handles = guidata(getParent(hObject, 'figure'));
if channel == 1
    set(handles.redLow, 'String', num2str(mn));
    set(handles.redHigh, 'String', num2str(mx));
end
if channel == 2
    set(handles.greenLow, 'String', num2str(mn));
    set(handles.greenHigh, 'String', num2str(mx));
end
if channel == 3
    set(handles.blueLow, 'String', num2str(mn));
    set(handles.blueHigh, 'String', num2str(mx));
end

updateBalancedImage(hObject);

return;

%--------------------------------------------------------------------------
function stdDev(hObject, channel)
global rgbBalancerGlobal;

%Only consider data above the noise, the percentage is kind of arbitrarily chosen.
channelData = rgbBalancerGlobal.originalImage(:, :, channel);
mx = max(max(channelData));%med = median(median(channelData));
% mn = min(min(rgbBalancerGlobal.originalImage(:, :, channel)));

% figure, hist(channelData, 50)
if ~isempty(channelData)
    indices = find(channelData(:, :) > 0.7 * mx);
    if ~all(indices == 0)
        avg = mean(mean(channelData(indices)));%Only consider data above the noise, the percentage is kind of arbitrarily chosen.
    else
        avg = 1;
    end
else
    avg = 1;
end

stdDev = std(reshape(rgbBalancerGlobal.originalImage(:, :, channel), ...
    size(rgbBalancerGlobal.originalImage, 1) * size(rgbBalancerGlobal.originalImage, 2), 1));

% mn = roundTo(max(mn, avg - 5 * stdDev), 1);
mn = 0;
mx = roundTo(min(mx, avg + 2 * stdDev), 1);

handles = guidata(getParent(hObject, 'figure'));
if channel == 1
    set(handles.redLow, 'String', num2str(mn));
    set(handles.redHigh, 'String', num2str(mx));
end
if channel == 2
    set(handles.greenLow, 'String', num2str(mn));
    set(handles.greenHigh, 'String', num2str(mx));
end
if channel == 3
    set(handles.blueLow, 'String', num2str(mn));
    set(handles.blueHigh, 'String', num2str(mx));
end

updateBalancedImage(hObject);

return;