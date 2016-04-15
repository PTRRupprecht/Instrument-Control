function varargout = motorControls(varargin)
%MOTORCONTROLS M-file for motorControls.fig
%      MOTORCONTROLS, by itself, creates a new MOTORCONTROLS or raises the existing
%      singleton*.
%
%      H = MOTORCONTROLS returns the handle to a new MOTORCONTROLS or the handle to
%      the existing singleton*.
%
%      MOTORCONTROLS('Property','Value',...) creates a new MOTORCONTROLS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to motorControls_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      MOTORCONTROLS('CALLBACK') and MOTORCONTROLS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in MOTORCONTROLS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help motorControls

% Last Modified by GUIDE v2.5 19-Oct-2011 19:52:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @motorControls_OpeningFcn, ...
                   'gui_OutputFcn',  @motorControls_OutputFcn, ...
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


% --- Executes just before motorControls is made visible.
function motorControls_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for motorControls
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes motorControls wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = motorControls_OutputFcn(hObject, eventdata, handles)
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


% --- Executes on button press in pbRecover.
function pbRecover_Callback(hObject, eventdata, handles)
% hObject    handle to pbRecover (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cbLockSliceVals.
function cbLockSliceVals_Callback(hObject, eventdata, handles)
% hObject    handle to cbLockSliceVals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbLockSliceVals


% --- Executes on button press in pbGrabOneStack.
function pbGrabOneStack_Callback(hObject, eventdata, handles)
% hObject    handle to pbGrabOneStack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbSetEnd.
function pbSetEnd_Callback(hObject, eventdata, handles)
% hObject    handle to pbSetEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbSetStart.
function pbSetStart_Callback(hObject, eventdata, handles)
% hObject    handle to pbSetStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function etStackEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etStackEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function etEndPower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etEndPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbClearStartEnd.
function pbClearStartEnd_Callback(hObject, eventdata, handles)
% hObject    handle to pbClearStartEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbClearEnd.
function pbClearEnd_Callback(hObject, eventdata, handles)
% hObject    handle to pbClearEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cbUseStartPower.
function cbUseStartPower_Callback(hObject, eventdata, handles)
% hObject    handle to cbUseStartPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbUseStartPower


% --- Executes on button press in cbOverrideLz.
function cbOverrideLz_Callback(hObject, eventdata, handles)
% hObject    handle to cbOverrideLz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbOverrideLz


% --- Executes during object creation, after setting all properties.
function etStackStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etStackStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function etStartPower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etStartPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etNumberOfZSlices_Callback(hObject, eventdata, handles)
% hObject    handle to etNumberOfZSlices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etNumberOfZSlices as text
%        str2double(get(hObject,'String')) returns contents of etNumberOfZSlices as a double


% --- Executes during object creation, after setting all properties.
function etNumberOfZSlices_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etNumberOfZSlices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbReturnHome.
function cbReturnHome_Callback(hObject, eventdata, handles)
% hObject    handle to cbReturnHome (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbReturnHome


% --- Executes on button press in cbCenteredStack.
function cbCenteredStack_Callback(hObject, eventdata, handles)
% hObject    handle to cbCenteredStack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbCenteredStack



function etZStepPerSlice_Callback(hObject, eventdata, handles)
% hObject    handle to etZStepPerSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etZStepPerSlice as text
%        str2double(get(hObject,'String')) returns contents of etZStepPerSlice as a double


% --- Executes during object creation, after setting all properties.
function etZStepPerSlice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etZStepPerSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tbTogglePosn.
function tbTogglePosn_Callback(hObject, eventdata, handles)
% hObject    handle to tbTogglePosn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbTogglePosn



function etPosnID_Callback(hObject, eventdata, handles)
% hObject    handle to etPosnID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etPosnID as text
%        str2double(get(hObject,'String')) returns contents of etPosnID as a double


% --- Executes during object creation, after setting all properties.
function etPosnID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etPosnID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbAddCurrent.
function pbAddCurrent_Callback(hObject, eventdata, handles)
% hObject    handle to pbAddCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function etStepSizeZZ_Callback(hObject, eventdata, handles)
% hObject    handle to etStepSizeZZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etStepSizeZZ as text
%        str2double(get(hObject,'String')) returns contents of etStepSizeZZ as a double


% --- Executes during object creation, after setting all properties.
function etStepSizeZZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etStepSizeZZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbReadPos.
function pbReadPos_Callback(hObject, eventdata, handles)
% hObject    handle to pbReadPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbAltZeroXY.
function pbAltZeroXY_Callback(hObject, eventdata, handles)
% hObject    handle to pbAltZeroXY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function etPosY_Callback(hObject, eventdata, handles)
% hObject    handle to etPosY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etPosY as text
%        str2double(get(hObject,'String')) returns contents of etPosY as a double


% --- Executes during object creation, after setting all properties.
function etPosY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etPosY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etPosZ_Callback(hObject, eventdata, handles)
% hObject    handle to etPosZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etPosZ as text
%        str2double(get(hObject,'String')) returns contents of etPosZ as a double


% --- Executes during object creation, after setting all properties.
function etPosZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etPosZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etPosX_Callback(hObject, eventdata, handles)
% hObject    handle to etPosX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etPosX as text
%        str2double(get(hObject,'String')) returns contents of etPosX as a double


% --- Executes during object creation, after setting all properties.
function etPosX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etPosX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbAltZeroZ.
function pbAltZeroZ_Callback(hObject, eventdata, handles)
% hObject    handle to pbAltZeroZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbZeroXYZ.
function pbZeroXYZ_Callback(hObject, eventdata, handles)
% hObject    handle to pbZeroXYZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function etPosR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etPosR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbSecZ.
function cbSecZ_Callback(hObject, eventdata, handles)
% hObject    handle to cbSecZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbSecZ



function etPosZZ_Callback(hObject, eventdata, handles)
% hObject    handle to etPosZZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etPosZZ as text
%        str2double(get(hObject,'String')) returns contents of etPosZZ as a double


% --- Executes during object creation, after setting all properties.
function etPosZZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etPosZZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbZeroXY.
function pbZeroXY_Callback(hObject, eventdata, handles)
% hObject    handle to pbZeroXY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbZeroZ.
function pbZeroZ_Callback(hObject, eventdata, handles)
% hObject    handle to pbZeroZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbStepXDec.
function pbStepXDec_Callback(hObject, eventdata, handles)
% hObject    handle to pbStepXDec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbStepXInc.
function pbStepXInc_Callback(hObject, eventdata, handles)
% hObject    handle to pbStepXInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbStepYDec.
function pbStepYDec_Callback(hObject, eventdata, handles)
% hObject    handle to pbStepYDec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbStepYInc.
function pbStepYInc_Callback(hObject, eventdata, handles)
% hObject    handle to pbStepYInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbStepZDec.
function pbStepZDec_Callback(hObject, eventdata, handles)
% hObject    handle to pbStepZDec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbStepZInc.
function pbStepZInc_Callback(hObject, eventdata, handles)
% hObject    handle to pbStepZInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function etStepSizeX_Callback(hObject, eventdata, handles)
% hObject    handle to etStepSizeX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etStepSizeX as text
%        str2double(get(hObject,'String')) returns contents of etStepSizeX as a double


% --- Executes during object creation, after setting all properties.
function etStepSizeX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etStepSizeX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etStepSizeY_Callback(hObject, eventdata, handles)
% hObject    handle to etStepSizeY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etStepSizeY as text
%        str2double(get(hObject,'String')) returns contents of etStepSizeY as a double


% --- Executes during object creation, after setting all properties.
function etStepSizeY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etStepSizeY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etStepSizeZ_Callback(hObject, eventdata, handles)
% hObject    handle to etStepSizeZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etStepSizeZ as text
%        str2double(get(hObject,'String')) returns contents of etStepSizeZ as a double


% --- Executes during object creation, after setting all properties.
function etStepSizeZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etStepSizeZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
