function varargout = standardControlsV4(varargin)
%STANDARDCONTROLSV4 M-file for standardControlsV4.fig
%      STANDARDCONTROLSV4, by itself, creates a new STANDARDCONTROLSV4 or raises the existing
%      singleton*.
%
%      H = STANDARDCONTROLSV4 returns the handle to a new STANDARDCONTROLSV4 or the handle to
%      the existing singleton*.
%
%      STANDARDCONTROLSV4('Property','Value',...) creates a new STANDARDCONTROLSV4 using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to standardControlsV4_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      STANDARDCONTROLSV4('CALLBACK') and STANDARDCONTROLSV4('CALLBACK',hObject,...) call the
%      local function named CALLBACK in STANDARDCONTROLSV4.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help standardControlsV4

% Last Modified by GUIDE v2.5 22-Dec-2010 10:56:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @standardControlsV4_OpeningFcn, ...
                   'gui_OutputFcn',  @standardControlsV4_OutputFcn, ...
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


% --- Executes just before standardControlsV4 is made visible.
function standardControlsV4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for standardControlsV4
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes standardControlsV4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = standardControlsV4_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function zStepPerSlice_Callback(hObject, eventdata, handles)
% hObject    handle to zStepPerSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zStepPerSlice as text
%        str2double(get(hObject,'String')) returns contents of zStepPerSlice as a double


% --- Executes during object creation, after setting all properties.
function zStepPerSlice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zStepPerSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numberOfSlices_Callback(hObject, eventdata, handles)
% hObject    handle to numberOfSlices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numberOfSlices as text
%        str2double(get(hObject,'String')) returns contents of numberOfSlices as a double


% --- Executes during object creation, after setting all properties.
function numberOfSlices_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numberOfSlices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numberOfFrames_Callback(hObject, eventdata, handles)
% hObject    handle to numberOfFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numberOfFrames as text
%        str2double(get(hObject,'String')) returns contents of numberOfFrames as a double
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function numberOfFrames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numberOfFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in averageFrames.
function averageFrames_Callback(hObject, eventdata, handles)
% hObject    handle to averageFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of averageFrames


% --- Executes on button press in returnHome.
function returnHome_Callback(hObject, eventdata, handles)
% hObject    handle to returnHome (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of returnHome



function repeatPeriod_Callback(hObject, eventdata, handles)
% hObject    handle to repeatPeriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of repeatPeriod as text
%        str2double(get(hObject,'String')) returns contents of repeatPeriod as a double
handles.hController.updateModel(hObject,eventdata,handles);



% --- Executes during object creation, after setting all properties.
function repeatPeriod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to repeatPeriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etNumRepeats_Callback(hObject, eventdata, handles)
% hObject    handle to etNumRepeats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etNumRepeats as text
%        str2double(get(hObject,'String')) returns contents of etNumRepeats as a double
handles.hController.updateModel(hObject,eventdata,handles);
handles.hController.updateModel(hObject,eventdata,handles);
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function etNumRepeats_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etNumRepeats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
