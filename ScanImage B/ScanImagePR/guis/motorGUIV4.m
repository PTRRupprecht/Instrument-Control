function varargout = motorGUIV4(varargin)
%MOTORGUIV4 M-file for motorGUIV4.fig
%      MOTORGUIV4, by itself, creates a new MOTORGUIV4 or raises the existing
%      singleton*.
%
%      H = MOTORGUIV4 returns the handle to a new MOTORGUIV4 or the handle to
%      the existing singleton*.
%
%      MOTORGUIV4('Property','Value',...) creates a new MOTORGUIV4 using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to motorGUIV4_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      MOTORGUIV4('CALLBACK') and MOTORGUIV4('CALLBACK',hObject,...) call the
%      local function named CALLBACK in MOTORGUIV4.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help motorGUIV4

% Last Modified by GUIDE v2.5 22-Dec-2010 13:37:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @motorGUIV4_OpeningFcn, ...
                   'gui_OutputFcn',  @motorGUIV4_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before motorGUIV4 is made visible.
function motorGUIV4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for motorGUIV4
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes motorGUIV4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = motorGUIV4_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in readPosition.
function readPosition_Callback(hObject, eventdata, handles)
% hObject    handle to readPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in setZeroXYButton.
function setZeroXYButton_Callback(hObject, eventdata, handles)
% hObject    handle to setZeroXYButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in setZeroZButton.
function setZeroZButton_Callback(hObject, eventdata, handles)
% hObject    handle to setZeroZButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in definePosition.
function definePosition_Callback(hObject, eventdata, handles)
% hObject    handle to definePosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in gotoPosition.
function gotoPosition_Callback(hObject, eventdata, handles)
% hObject    handle to gotoPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in setZeroXYZButton.
function setZeroXYZButton_Callback(hObject, eventdata, handles)
% hObject    handle to setZeroXYZButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function distance_Callback(hObject, eventdata, handles)
% hObject    handle to distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of distance as text
%        str2double(get(hObject,'String')) returns contents of distance as a double


% --- Executes on button press in savePositionListButton.
function savePositionListButton_Callback(hObject, eventdata, handles)
% hObject    handle to savePositionListButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in loadPositionListButton.
function loadPositionListButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadPositionListButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbRecover.
function pbRecover_Callback(hObject, eventdata, handles)
% hObject    handle to pbRecover (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function etStackStop_Callback(hObject, eventdata, handles)
% hObject    handle to etStackStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etStackStop as text
%        str2double(get(hObject,'String')) returns contents of etStackStop as a double


% --- Executes during object creation, after setting all properties.
function etStackStop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etStackStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GRAB.
function GRAB_Callback(hObject, eventdata, handles)
% hObject    handle to GRAB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cbStackEndpointsDominate.
function cbStackEndpointsDominate_Callback(hObject, eventdata, handles)
% hObject    handle to cbStackEndpointsDominate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbStackEndpointsDominate


% --- Executes on button press in cbOverrideLz.
function cbOverrideLz_Callback(hObject, eventdata, handles)
% hObject    handle to cbOverrideLz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbOverrideLz
