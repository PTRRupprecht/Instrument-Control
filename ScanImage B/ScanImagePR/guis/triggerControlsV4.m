function varargout = triggerControlsV4(varargin)
%TRIGGERCONTROLSV4 M-file for triggerControlsV4.fig
%      TRIGGERCONTROLSV4, by itself, creates a new TRIGGERCONTROLSV4 or raises the existing
%      singleton*.
%
%      H = TRIGGERCONTROLSV4 returns the handle to a new TRIGGERCONTROLSV4 or the handle to
%      the existing singleton*.
%
%      TRIGGERCONTROLSV4('Property','Value',...) creates a new TRIGGERCONTROLSV4 using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to triggerControlsV4_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      TRIGGERCONTROLSV4('CALLBACK') and TRIGGERCONTROLSV4('CALLBACK',hObject,...) call the
%      local function named CALLBACK in TRIGGERCONTROLSV4.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help triggerControlsV4

% Last Modified by GUIDE v2.5 07-Jan-2013 16:34:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @triggerControlsV4_OpeningFcn, ...
                   'gui_OutputFcn',  @triggerControlsV4_OutputFcn, ...
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


% --- Executes just before triggerControlsV4 is made visible.
function triggerControlsV4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for triggerControlsV4
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes triggerControlsV4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = triggerControlsV4_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in pbSaveCFG.
function pbSaveCFG_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveCFG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.cfgSaveConfig();


% --- Executes on button press in cbPureNextTrigger.
function cbPureNextTrigger_Callback(hObject, eventdata, handles)
% hObject    handle to cbPureNextTrigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbPureNextTrigger
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes on selection change in pmNextTrigStopMode.
function pmNextTrigStopMode_Callback(hObject, eventdata, handles)
% hObject    handle to pmNextTrigStopMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmNextTrigStopMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmNextTrigStopMode
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes on selection change in pmStartTrigEdge.
function pmStartTrigEdge_Callback(hObject, eventdata, handles)
% hObject    handle to pmStartTrigEdge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmStartTrigEdge contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmStartTrigEdge
handles.hController.updateModel(hObject,eventdata,handles);



% --- Executes on selection change in pmNextTrigEdge.
function pmNextTrigEdge_Callback(hObject, eventdata, handles)
% hObject    handle to pmNextTrigEdge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmNextTrigEdge contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmNextTrigEdge
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes on selection change in pmNextTrigNextMode.
function pmNextTrigNextMode_Callback(hObject, eventdata, handles)
% hObject    handle to pmNextTrigNextMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmNextTrigNextMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmNextTrigNextMode
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes on button press in cbGapAdvance.
function cbGapAdvance_Callback(hObject, eventdata, handles)
% hObject    handle to cbGapAdvance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbGapAdvance
handles.hController.updateModel(hObject,eventdata,handles);



function etStartTrigSrc_Callback(hObject, eventdata, handles)
% hObject    handle to etStartTrigSrc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etStartTrigSrc as text
%        str2double(get(hObject,'String')) returns contents of etStartTrigSrc as a double
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function etStartTrigSrc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etStartTrigSrc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etNextTrigSrc_Callback(hObject, eventdata, handles)
% hObject    handle to etNextTrigSrc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etNextTrigSrc as text
%        str2double(get(hObject,'String')) returns contents of etNextTrigSrc as a double
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function etNextTrigSrc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etNextTrigSrc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbScanWhileWait.
function cbScanWhileWait_Callback(hObject, eventdata, handles)
% hObject    handle to cbScanWhileWait (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbScanWhileWait
handles.hController.updateModel(hObject,eventdata,handles);



function etExtTrigTimeout_Callback(hObject, eventdata, handles)
% hObject    handle to etExtTrigTimeout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etExtTrigTimeout as text
%        str2double(get(hObject,'String')) returns contents of etExtTrigTimeout as a double
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function etExtTrigTimeout_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etExtTrigTimeout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pmMaxLoopTriggerInterval.
function pmMaxLoopTriggerInterval_Callback(hObject, eventdata, handles)
% hObject    handle to pmMaxLoopTriggerInterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmMaxLoopTriggerInterval contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmMaxLoopTriggerInterval
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function pmMaxLoopTriggerInterval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmMaxLoopTriggerInterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etMaxLoopTriggerIntervalFrames_Callback(hObject, eventdata, handles)
% hObject    handle to etMaxLoopTriggerIntervalFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etMaxLoopTriggerIntervalFrames as text
%        str2double(get(hObject,'String')) returns contents of etMaxLoopTriggerIntervalFrames as a double
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function etMaxLoopTriggerIntervalFrames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etMaxLoopTriggerIntervalFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbLockMLTI.
function cbLockMLTI_Callback(hObject, eventdata, handles)
% hObject    handle to cbLockMLTI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbLockMLTI
handles.hController.updateModel(hObject,eventdata,handles);
