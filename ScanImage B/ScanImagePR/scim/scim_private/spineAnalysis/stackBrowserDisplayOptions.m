function varargout = stackBrowserDisplayOptions(varargin)
% STACKBROWSERDISPLAYOPTIONS M-file for stackBrowserDisplayOptions.fig
%      STACKBROWSERDISPLAYOPTIONS, by itself, creates a new STACKBROWSERDISPLAYOPTIONS or raises the existing
%      singleton*.
%
%      H = STACKBROWSERDISPLAYOPTIONS returns the handle to a new STACKBROWSERDISPLAYOPTIONS or the handle to
%      the existing singleton*.
%
%      STACKBROWSERDISPLAYOPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STACKBROWSERDISPLAYOPTIONS.M with the given input arguments.
%
%      STACKBROWSERDISPLAYOPTIONS('Property','Value',...) creates a new STACKBROWSERDISPLAYOPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stackBrowserDisplayOptions_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stackBrowserDisplayOptions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stackBrowserDisplayOptions

% Last Modified by GUIDE v2.5 22-Dec-2009 10:16:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stackBrowserDisplayOptions_OpeningFcn, ...
                   'gui_OutputFcn',  @stackBrowserDisplayOptions_OutputFcn, ...
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
% --- Executes just before stackBrowserDisplayOptions is made visible.
function stackBrowserDisplayOptions_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = stackBrowserDisplayOptions_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

%NOTE: The main GUI's defaults take precedence over these (see genericStartFcn).
out = {
        'projectAnnotations', 1, 'Class', 'Numeric', 'Gui', 'projectAnnotations', ...
        'fiducialOnPrimary', 1, 'Class', 'Numeric', 'Gui', 'fiducialOnPrimary', ...
        'fiducialOnGlobal', 1, 'Class', 'Numeric', 'Gui', 'fiducialOnGlobal', ...
        'showTextLabelsPrimary', 1, 'Class', 'Numeric', 'Gui', 'showTextLabelsPrimary', ...
        'showTextLabelsGlobal', 1, 'Class', 'Numeric', 'Gui', 'showTextLabelsGlobal', ...
        'polylinesOnPrimary', 1, 'Class', 'Numeric', 'Gui', 'polylinesOnPrimary', ...
        'polylinesOnGlobal', 1, 'Class', 'Numeric', 'Gui', 'polylinesOnGlobal', ...
        'gridLineSpacing', 50, 'Class', 'Numeric', 'Gui', 'gridlineSpacing', ...
        'gridLinesVisible', 0, 'Class', 'Numeric', 'Gui', 'showGridlines', ...
        'gridLinesVisibleOnGlobal', 0, 'Class', 'Numeric', 'Gui', 'showGridlinesOnGlobal', ...
        'showAnnotationsOnPrimary', 1, 'Class', 'Numeric', 'Gui', 'showAnnotationsOnPrimary', ...
        'showAnnotationsOnGlobal', 1, 'Class', 'Numeric', 'Gui', 'showAnnotationsOnGlobal', ...
        'lockAnnotationsToChannel', 1, 'Class', 'Numeric', 'Gui', 'lockAnnotationsToChannel', ...
    };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

toggleGuiVisibility(progmanager, hObject, 'stackBrowserDisplayOptions', 'Off');

showGridlines_Callback(hObject, eventdata, handles);

ia_setOption(hObject, 'projectAnnotations', getLocal(progmanager, hObject, 'projectAnnotations'));

setMain(progmanager, hObject, 'displayOptionsObject', hObject);
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
% --- Executes on button press in fiducialOnPrimary.
function fiducialOnPrimary_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'fiducialOnPrimary', getLocal(progmanager, hObject, 'fiducialOnPrimary'));

browsers = ia_getActiveStackBrowsers(hObject);
for i = 1 : length(browsers)
    ia_setLineVisibilities(getMain(progmanager, browsers(i), 'hObject'));
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in fiducialOnGlobal.
function fiducialOnGlobal_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'fiducialOnGlobal', getLocal(progmanager, hObject, 'fiducialOnGlobal'));

browsers = ia_getActiveStackBrowsers(hObject);
for i = 1 : length(browsers)
    ia_setLineVisibilities(getMain(progmanager, browsers(i), 'hObject'));
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in showTextLabelsPrimary.
function showTextLabelsPrimary_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'showTextLabelsPrimary', getLocal(progmanager, hObject, 'showTextLabelsPrimary'));

browsers = ia_getActiveStackBrowsers(hObject);
for i = 1 : length(browsers)
    ia_setLineVisibilities(getMain(progmanager, browsers(i), 'hObject'));
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in polylinesOnPrimary.
function polylinesOnPrimary_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'polylinesOnPrimary', getLocal(progmanager, hObject, 'polylinesOnPrimary'));

browsers = ia_getActiveStackBrowsers(hObject);
for i = 1 : length(browsers)
    ia_setLineVisibilities(getMain(progmanager, browsers(i), 'hObject'));
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in polylinesOnGlobal.
function polylinesOnGlobal_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'polylinesOnGlobal', getLocal(progmanager, hObject, 'polylinesOnGlobal'));

browsers = ia_getActiveStackBrowsers(hObject);
for i = 1 : length(browsers)
    ia_setLineVisibilities(getMain(progmanager, browsers(i), 'hObject'));
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in showTextLabelsGlobal.
function showTextLabelsGlobal_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'showTextLabelsGlobal', getLocal(progmanager, hObject, 'showTextLabelsGlobal'));

browsers = ia_getActiveStackBrowsers(hObject);
for i = 1 : length(browsers)
    ia_setLineVisibilities(getMain(progmanager, browsers(i), 'hObject'));
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in showGridlines.
function showGridlines_Callback(hObject, eventdata, handles)

gridLinesVisible = getLocal(progmanager, hObject, 'gridLinesVisible');

ia_setOption(hObject, 'gridLinesVisible', getLocal(progmanager, hObject, 'gridLinesVisible'));

if ~gridLinesVisible
    setLocalGh(progmanager, hObject, 'gridlineSpacing', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'showGridlinesOnGlobal', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'text27', 'Enable', 'Off');
else
    setLocalGh(progmanager, hObject, 'gridlineSpacing', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'showGridlinesOnGlobal', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'text27', 'Enable', 'On');
end

browsers = ia_getActiveStackBrowsers(hObject);
for i = 1 : length(browsers)
    ia_drawGridlines(browsers(i));
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in showGridlinesOnGlobal.
function showGridlinesOnGlobal_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'gridLinesVisibleOnGlobal', getLocal(progmanager, hObject, 'gridLinesVisibleOnGlobal'));

browsers = ia_getActiveStackBrowsers(hObject);
for i = 1 : length(browsers)
    ia_drawGridlines(browsers(i));
end

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function gridlineSpacing_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function gridlineSpacing_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'gridLineSpacing', getLocal(progmanager, hObject, 'gridLineSpacing'));

browsers = ia_getActiveStackBrowsers(hObject);
for i = 1 : length(browsers)
    ia_drawGridlines(browsers(i));
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in showAnnotationsOnPrimary.
function showAnnotationsOnPrimary_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'showAnnotationsOnPrimary', getLocal(progmanager, hObject, 'showAnnotationsOnPrimary'));

browsers = ia_getActiveStackBrowsers(hObject);
for i = 1 : length(browsers)
    ia_setLineVisibilities(browsers(i));
end

return;

% ------------------------------------------------------------------
%TO080707A
% --- Executes on button press in lockAnnotationsToChannel.
function lockAnnotationsToChannel_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'lockAnnotationsToChannel', getLocal(progmanager, hObject, 'lockAnnotationsToChannel'));

browsers = ia_getActiveStackBrowsers(hObject);
for i = 1 : length(browsers)
    ia_setLineVisibilities(browsers(i));
end

return;

% ------------------------------------------------------------------
%TO122209A - Implemented showAnnotationsOnGlobal, which must have been left out due to an oversight.
% --- Executes on button press in showAnnotationsOnGlobal.
function showAnnotationsOnGlobal_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'showAnnotationsOnGlobal', getLocal(progmanager, hObject, 'showAnnotationsOnGlobal'));

browsers = ia_getActiveStackBrowsers(hObject);
for i = 1 : length(browsers)
    ia_setLineVisibilities(browsers(i));
end

return;