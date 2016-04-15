function varargout = stackBrowserUnits(varargin)
% STACKBROWSERUNITS M-file for stackBrowserUnits.fig
%      STACKBROWSERUNITS, by itself, creates a new STACKBROWSERUNITS or raises the existing
%      singleton*.
%
%      H = STACKBROWSERUNITS returns the handle to a new STACKBROWSERUNITS or the handle to
%      the existing singleton*.
%
%      STACKBROWSERUNITS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STACKBROWSERUNITS.M with the given input arguments.
%
%      STACKBROWSERUNITS('Property','Value',...) creates a new STACKBROWSERUNITS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stackBrowserUnits_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stackBrowserUnits_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stackBrowserUnits

% Last Modified by GUIDE v2.5 21-Dec-2004 15:32:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stackBrowserUnits_OpeningFcn, ...
                   'gui_OutputFcn',  @stackBrowserUnits_OutputFcn, ...
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


% --- Executes just before stackBrowserUnits is made visible.
function stackBrowserUnits_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stackBrowserUnits (see VARARGIN)

% Choose default command line output for stackBrowserUnits
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes stackBrowserUnits wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = stackBrowserUnits_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

%NOTE: The main GUI's defaults take precedence over these (see genericStartFcn).
out = {
        'unitaryConversions', 0, 'Class', 'Numeric', 'Gui', 'unitaryConversions', ...
        'xConversionFactor', 0, 'Class', 'Numeric', 'Gui', 'xConversionFactor', ...
        'xUnits', '', 'Class', 'Char', 'Gui', 'xUnits', ...
        'yConversionFactor', 0, 'Class', 'Numeric', 'Gui', 'yConversionFactor', ...
        'yUnits', '', 'Class', 'Char', 'Gui', 'yUnits', ...
        'zConversionFactor', 0, 'Class', 'Numeric', 'Gui', 'zConversionFactor', ...
        'zUnits', '', 'Class', 'Char', 'Gui', 'zUnits', ...
    };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

setMain(progmanager, hObject, 'stackBrowserUnits', hObject);

toggleGuiVisibility(progmanager, hObject, 'stackBrowserUnits', 'On');

updateVariablesFromMainGui(hObject);

return;

% ------------------------------------------------------------------
function updateVariablesFromMainGui(hObject)

localNames = getGUIVariableNames(progmanager, hObject);
mainNames = getGUIVariableNames(progmanager, getMain(progmanager, hObject, 'hObject'));

for i = 1 : length(localNames)
    if ismember(mainNames{i}, localNames)
        %Copy over the setting from the main gui.
        setLocal(progmanager, hObject, mainNames{i}, getMain(progmanager, hObject, mainNames{i}));
    end
end

unitaryConversions_Callback(hObject, [], []);

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

unitaryConversions_Callback(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function xConversionFactor_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function xConversionFactor_Callback(hObject, eventdata, handles)

setMain(progmanager, hObject, 'xConversionFactor', ...
    getLocal(progmanager, hObject, 'xConversionFactor'));

feval(getMain(progmanager, hObject, 'annotationDisplayUpdateFcn'), getMain(progmanager, hObject, 'annotationObject'));

setGlobal(progmanager, 'xConversionFactor', 'stackBrowserControl', 'StackBrowserControl', getLocal(progmanager, hObject, 'xConversionFactor'));

return;

% ------------------------------------------------------------------
function xUnits_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function xUnits_Callback(hObject, eventdata, handles)

setMain(progmanager, hObject, 'xUnits', ...
    getLocal(progmanager, hObject, 'xUnits'));

setLocalGh(progmanager, hObject, 'xConversionFactor', 'TooltipString', sprintf('Pixels/%s in X-dimension.', getLocal(progmanager, hObject, 'xUnits')));

feval(getMain(progmanager, hObject, 'annotationDisplayUpdateFcn'), getMain(progmanager, hObject, 'annotationObject'));

setGlobal(progmanager, 'xUnits', 'stackBrowserControl', 'StackBrowserControl', getLocal(progmanager, hObject, 'xUnits'));

return;

% ------------------------------------------------------------------
function yConversionFactor_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function yConversionFactor_Callback(hObject, eventdata, handles)

setMain(progmanager, hObject, 'yConversionFactor', ...
    getLocal(progmanager, hObject, 'yConversionFactor'));

feval(getMain(progmanager, hObject, 'annotationDisplayUpdateFcn'), getMain(progmanager, hObject, 'annotationObject'));

setGlobal(progmanager, 'yConversionFactor', 'stackBrowserControl', 'StackBrowserControl', getLocal(progmanager, hObject, 'yConversionFactor'));

return;

% ------------------------------------------------------------------
function yUnits_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function yUnits_Callback(hObject, eventdata, handles)

setMain(progmanager, hObject, 'yUnits', ...
    getLocal(progmanager, hObject, 'yUnits'));

setLocalGh(progmanager, hObject, 'yConversionFactor', 'TooltipString', sprintf('Pixels/%s in Y-dimension.', getLocal(progmanager, hObject, 'yUnits')));

feval(getMain(progmanager, hObject, 'annotationDisplayUpdateFcn'), getMain(progmanager, hObject, 'annotationObject'));

setGlobal(progmanager, 'yUnits', 'stackBrowserControl', 'StackBrowserControl', getLocal(progmanager, hObject, 'yUnits'));

return;

% ------------------------------------------------------------------
function zConversionFactor_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function zConversionFactor_Callback(hObject, eventdata, handles)

setMain(progmanager, hObject, 'zConversionFactor', ...
    getLocal(progmanager, hObject, 'zConversionFactor'));

feval(getMain(progmanager, hObject, 'annotationDisplayUpdateFcn'), getMain(progmanager, hObject, 'annotationObject'));

setGlobal(progmanager, 'zConversionFactor', 'stackBrowserControl', 'StackBrowserControl', getLocal(progmanager, hObject, 'zConversionFactor'));

return;

% ------------------------------------------------------------------
function zUnits_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function zUnits_Callback(hObject, eventdata, handles)

setMain(progmanager, hObject, 'zUnits', ...
    getLocal(progmanager, hObject, 'zUnits'));

setLocalGh(progmanager, hObject, 'zConversionFactor', 'TooltipString', sprintf('Pixels/%s in Z-dimension.', getLocal(progmanager, hObject, 'zUnits')));

feval(getMain(progmanager, hObject, 'annotationDisplayUpdateFcn'), getMain(progmanager, hObject, 'annotationObject'));

setGlobal(progmanager, 'zUnits', 'stackBrowserControl', 'StackBrowserControl', getLocal(progmanager, hObject, 'zUnits'));

return;

% ------------------------------------------------------------------
function unitaryConversions_Callback(hObject, eventdata, handles)

unitaryConversions = getLocal(progmanager, hObject, 'unitaryConversions');
if unitaryConversions
    setLocalGh(progmanager, hObject, 'xConversionFactor', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'xUnits', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'yConversionFactor', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'yUnits', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'zConversionFactor', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'zUnits', 'Enable', 'On');
    
    setLocalGh(progmanager, hObject, 'xConversionFactor', 'TooltipString', sprintf('Pixels/%s in X-dimension.', getLocal(progmanager, hObject, 'xUnits')));
    setLocalGh(progmanager, hObject, 'yConversionFactor', 'TooltipString', sprintf('Pixels/%s in Y-dimension.', getLocal(progmanager, hObject, 'yUnits')));
    setLocalGh(progmanager, hObject, 'zConversionFactor', 'TooltipString', sprintf('Pixels/%s in Z-dimension.', getLocal(progmanager, hObject, 'zUnits')));
    
    setMain(progmanager, hObject, 'xConversionFactor', getLocal(progmanager, hObject, 'xConversionFactor'));
    setMain(progmanager, hObject, 'xUnits', getLocal(progmanager, hObject, 'xUnits'));
    
    setMain(progmanager, hObject, 'yConversionFactor', getLocal(progmanager, hObject, 'yConversionFactor'));
    setMain(progmanager, hObject, 'yUnits', getLocal(progmanager, hObject, 'yUnits'));
    
    setMain(progmanager, hObject, 'zConversionFactor', getLocal(progmanager, hObject, 'zConversionFactor'));
    setMain(progmanager, hObject, 'zUnits', getLocal(progmanager, hObject, 'zUnits'));
else
    setLocalGh(progmanager, hObject, 'xConversionFactor', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'xUnits', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'yConversionFactor', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'yUnits', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'zConversionFactor', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'zUnits', 'Enable', 'Off');
    
    setMain(progmanager, hObject, 'xConversionFactor', 1);
    setMain(progmanager, hObject, 'xUnits', 'Pixels');
    
    setMain(progmanager, hObject, 'yConversionFactor', 1);
    setMain(progmanager, hObject, 'yUnits', 'Pixels');
    
    setMain(progmanager, hObject, 'zConversionFactor', 1);
    setMain(progmanager, hObject, 'zUnits', 'Pixels');
end

setMain(progmanager, hObject, 'unitaryConversions', unitaryConversions);

feval(getMain(progmanager, hObject, 'annotationDisplayUpdateFcn'), getMain(progmanager, hObject, 'annotationObject'));

return;