function varargout = stackBrowserOptions(varargin)
% STACKBROWSEROPTIONS M-file for stackBrowserOptions.fig
%      STACKBROWSEROPTIONS, by itself, creates a new STACKBROWSEROPTIONS or raises the existing
%      singleton*.
%
%      H = STACKBROWSEROPTIONS returns the handle to a new STACKBROWSEROPTIONS or the handle to
%      the existing singleton*.
%
%      STACKBROWSEROPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STACKBROWSEROPTIONS.M with the given input arguments.
%
%      STACKBROWSEROPTIONS('Property','Value',...) creates a new STACKBROWSEROPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stackBrowserOptions_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stackBrowserOptions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stackBrowserOptions

% Last Modified by GUIDE v2.5 08-Aug-2007 17:29:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stackBrowserOptions_OpeningFcn, ...
                   'gui_OutputFcn',  @stackBrowserOptions_OutputFcn, ...
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

% ------------------------------------------------------------------
% --- Executes just before stackBrowserOptions is made visible.
function stackBrowserOptions_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = stackBrowserOptions_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

%NOTE: The main GUI's defaults take precedence over these (see genericStartFcn).
out = {
        'primaryViewZoomSelection', 1, 'Class', 'Numeric', 'Gui', 'primaryViewZoomSelection', ...
        'globalViewZoomSelection', 0, 'Class', 'Numeric', 'Gui', 'globalViewZoomSelection', ...
        'emfClipboardType', 1, 'Class', 'Numeric', 'Gui', 'emfClipboardType', ...
        'autoSubtractImageMin', 0, 'Class', 'Numeric', 'Gui', 'autoSubtractImageMin', ...
        'filterWindowSize', 3, 'Class', 'Numeric', 'Gui', 'filterWindowSize', ...
        'switchFrameOnSelection', 1, 'Class', 'Numeric', 'Gui', 'switchFrameOnSelection', ...
        'allowCorrelationIDCollisions', 0, 'Class', 'Numeric', 'Gui', 'allowCorrelationIDCollisions', ...
        'insertFilenameInCopiedImages', 1, 'Class', 'Numeric', 'Gui', 'insertFilenameInCopiedImages', ...
        'multichannelPhotometryData', 0, 'Class', 'Numeric', 'Gui', 'multichannelPhotometryData', ...
        'optimizePhotometryNormalization', 1, 'Class', 'Numeric', 'Gui', 'optimizePhotometryNormalization', ...
        'loadPhotometryRegions', 0, 'Class', 'Numeric', 'Gui', 'loadPhotometryRegions', ...
    };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

toggleGuiVisibility(progmanager, hObject, 'stackBrowserOptions', 'Off');

setMain(progmanager, hObject, 'optionsObject', hObject);
% 
% localNames = getGUIVariableNames(progmanager, hObject);
% mainNames = getGUIVariableNames(progmanager, getMain(progmanager, hObject, 'hObject'));
% 
% for i = 1 : length(localNames)
%     if ismember(mainNames{i}, localNames)
%         %Copy over the setting from the main gui.
%         setLocal(progmanager, hObject, mainNames{i}, getMain(progmanager, hObject, mainNames{i}));
%     end
% end

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function version = getVersion(hObject, eventdata, handles)

version = 0.1;

return;

% ------------------------------------------------------------------
function genericSaveSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes on button press in projectAnnotations.
function projectAnnotations_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'projectAnnotations', getLocal(progmanager, hObject, 'projectAnnotations'));

browsers = ia_getActiveStackBrowsers(hObject);
for i = 1 : length(browsers)
    ia_setLineVisibilities(getMain(progmanager, browsers(i), 'hObject'));
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in primaryViewZoomSelection.
function primaryViewZoomSelection_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'zoomOnPrimaryImage', 1);

setLocal(progmanager, hObject, 'primaryViewZoomSelection', 1);
setLocal(progmanager, hObject, 'globalViewZoomSelection', 0);

browsers = ia_getActiveStackBrowsers(hObject);
for i = 1 : length(browsers)
    set(getLocalgh(progmanager, browsers(i), 'primaryViewZoomSelection'), 'Enable', 'inactive');
    set(getLocalgh(progmanager, browsers(i), 'globalViewZoomSelection'), 'Enable', 'On');
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in globalViewZoomSelection.
function globalViewZoomSelection_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'zoomOnPrimaryImage', 0);

setLocal(progmanager, hObject, 'primaryViewZoomSelection', 0);
setLocal(progmanager, hObject, 'globalViewZoomSelection', 1);

browsers = ia_getActiveStackBrowsers(hObject);
for i = 1 : length(browsers)
    set(getLocalgh(progmanager, browsers(i), 'primaryViewZoomSelection'), 'Enable', 'On');
    set(getLocalgh(progmanager, browsers(i), 'globalViewZoomSelection'), 'Enable', 'inactive');
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in emfClipboardType.
function emfClipboardType_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'emfClipboardType', getLocal(progmanager, hObject, 'emfClipboardType'));

return;

% ------------------------------------------------------------------
% --- Executes on button press in autoSubtractImageMin.
function autoSubtractImageMin_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'autoSubtractImageMin', getLocal(progmanager, hObject, 'autoSubtractImageMin'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function filterWindowSize_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function filterWindowSize_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'filterWindowSize', getLocal(progmanager, hObject, 'filterWindowSize'));

return;

% ------------------------------------------------------------------
% --- Executes on button press in switchFrameOnSelection.
function switchFrameOnSelection_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'switchFrameOnSelection', getLocal(progmanager, hObject, 'switchFrameOnSelection'));

return;

% ------------------------------------------------------------------
function allowCorrelationIDCollisions_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'allowCorrelationIDCollisions', getLocal(progmanager, hObject, 'allowCorrelationIDCollisions'));

return;

% ------------------------------------------------------------------
function updateMainProgramVariables(hObject, eventdata, handles)

localNames = getGUIVariableNames(progmanager, hObject);
mainNames = getGUIVariableNames(progmanager, getMain(progmanager, hObject, 'hObject'));

for i = 1 : length(localNames)
    if ismember(localNames{i}, mainNames)
        %Copy over the setting from the main gui.
        setMain(progmanager, hObject, localNames{i}, getLocal(progmanager, hObject, localNames{i}));
    end
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in insertFilenameInCopiedImages.
function insertFilenameInCopiedImages_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'insertFilenameInCopiedImages', getLocal(progmanager, hObject, 'insertFilenameInCopiedImages'));

return;

% ------------------------------------------------------------------
% --- Executes on button press in multichannelPhotometryData.
%TO080707 - Process photometry across multiple channels, for ratiometric imaging. -- Tim O'Connor 8/7/07
function multichannelPhotometryData_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'multichannelPhotometryData', getLocal(progmanager, hObject, 'multichannelPhotometryData'));
browsers = ia_getActiveStackBrowsers(hObject);
for i = 1 : length(browsers)
    ia_updatePhotometryValues(browsers(i));
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in optimizePhotometryNormalization.
%TO080707A
function optimizePhotometryNormalization_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'optimizePhotometryNormalization', getLocal(progmanager, hObject, 'optimizePhotometryNormalization'));

return;

% ------------------------------------------------------------------
% --- Executes on button press in loadPhotometryRegions.
%TO080707A
function loadPhotometryRegions_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'loadPhotometryRegions', getLocal(progmanager, hObject, 'loadPhotometryRegions'));

return;