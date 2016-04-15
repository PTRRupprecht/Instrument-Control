function varargout = mainControls(varargin)
%MAINCONTROLS M-file for mainControls.fig
%      MAINCONTROLS, by itself, creates a new MAINCONTROLS or raises the existing
%      singleton*.
%
%      H = MAINCONTROLS returns the handle to a new MAINCONTROLS or the handle to
%      the existing singleton*.
%
%      MAINCONTROLS('Property','Value',...) creates a new MAINCONTROLS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to mainControls_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      MAINCONTROLS('CALLBACK') and MAINCONTROLS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in MAINCONTROLS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mainControls

% Last Modified by GUIDE v2.5 31-Oct-2011 16:14:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mainControls_OpeningFcn, ...
                   'gui_OutputFcn',  @mainControls_OutputFcn, ...
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


% --- Executes just before mainControls is made visible.
function mainControls_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for mainControls
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mainControls wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mainControls_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in focusButton.
function focusButton_Callback(hObject, eventdata, handles)
% hObject    handle to focusButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in grabOneButton.
function grabOneButton_Callback(hObject, eventdata, handles)
% hObject    handle to grabOneButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in startLoopButton.
function startLoopButton_Callback(hObject, eventdata, handles)
% hObject    handle to startLoopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function statusString_CreateFcn(hObject, eventdata, handles)
% hObject    handle to statusString (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pnlAcqSettings_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pnlAcqSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in tbExternalTrig.
function tbExternalTrig_Callback(hObject, eventdata, handles)
% hObject    handle to tbExternalTrig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbExternalTrig


% --- Executes on button press in snapShot.
function snapShot_Callback(hObject, eventdata, handles)
% hObject    handle to snapShot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function numberOfFramesSnap_Callback(hObject, eventdata, handles)
% hObject    handle to numberOfFramesSnap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numberOfFramesSnap as text
%        str2double(get(hObject,'String')) returns contents of numberOfFramesSnap as a double


% --- Executes during object creation, after setting all properties.
function numberOfFramesSnap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numberOfFramesSnap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tbShowConfigGUI.
function tbShowConfigGUI_Callback(hObject, eventdata, handles)
% hObject    handle to tbShowConfigGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbShowConfigGUI


% --- Executes on button press in tbFastConfig1.
function tbFastConfig1_Callback(hObject, eventdata, handles)
% hObject    handle to tbFastConfig1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbFastConfig1


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over tbFastConfig1.
function tbFastConfig1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to tbFastConfig1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in tbFastConfig2.
function tbFastConfig2_Callback(hObject, eventdata, handles)
% hObject    handle to tbFastConfig2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbFastConfig2


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over tbFastConfig2.
function tbFastConfig2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to tbFastConfig2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in tbFastConfig3.
function tbFastConfig3_Callback(hObject, eventdata, handles)
% hObject    handle to tbFastConfig3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbFastConfig3


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over tbFastConfig3.
function tbFastConfig3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to tbFastConfig3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in tbFastConfig4.
function tbFastConfig4_Callback(hObject, eventdata, handles)
% hObject    handle to tbFastConfig4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbFastConfig4


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over tbFastConfig4.
function tbFastConfig4_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to tbFastConfig4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in tbFastConfig5.
function tbFastConfig5_Callback(hObject, eventdata, handles)
% hObject    handle to tbFastConfig5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbFastConfig5


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over tbFastConfig5.
function tbFastConfig5_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to tbFastConfig5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in tbFastConfig6.
function tbFastConfig6_Callback(hObject, eventdata, handles)
% hObject    handle to tbFastConfig6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbFastConfig6


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over tbFastConfig6.
function tbFastConfig6_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to tbFastConfig6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function scanRotationSlider_Callback(hObject, eventdata, handles)
% hObject    handle to scanRotationSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function scanRotationSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scanRotationSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function scanRotation_Callback(hObject, eventdata, handles)
% hObject    handle to scanRotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scanRotation as text
%        str2double(get(hObject,'String')) returns contents of scanRotation as a double


% --- Executes during object creation, after setting all properties.
function scanRotation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scanRotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in zeroRotate.
function zeroRotate_Callback(hObject, eventdata, handles)
% hObject    handle to zeroRotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in left.
function left_Callback(hObject, eventdata, handles)
% hObject    handle to left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in fullfield.
function fullfield_Callback(hObject, eventdata, handles)
% hObject    handle to fullfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function scanShiftSlow_Callback(hObject, eventdata, handles)
% hObject    handle to scanShiftSlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scanShiftSlow as text
%        str2double(get(hObject,'String')) returns contents of scanShiftSlow as a double


% --- Executes during object creation, after setting all properties.
function scanShiftSlow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scanShiftSlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function scanShiftFast_Callback(hObject, eventdata, handles)
% hObject    handle to scanShiftFast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scanShiftFast as text
%        str2double(get(hObject,'String')) returns contents of scanShiftFast as a double


% --- Executes during object creation, after setting all properties.
function scanShiftFast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scanShiftFast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in right.
function right_Callback(hObject, eventdata, handles)
% hObject    handle to right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in down.
function down_Callback(hObject, eventdata, handles)
% hObject    handle to down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in up.
function up_Callback(hObject, eventdata, handles)
% hObject    handle to up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in zero.
function zero_Callback(hObject, eventdata, handles)
% hObject    handle to zero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function ystep_Callback(hObject, eventdata, handles)
% hObject    handle to ystep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ystep as text
%        str2double(get(hObject,'String')) returns contents of ystep as a double


% --- Executes during object creation, after setting all properties.
function ystep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ystep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xstep_Callback(hObject, eventdata, handles)
% hObject    handle to xstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xstep as text
%        str2double(get(hObject,'String')) returns contents of xstep as a double


% --- Executes during object creation, after setting all properties.
function xstep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function zoomhundredsslider_Callback(hObject, eventdata, handles)
% hObject    handle to zoomhundredsslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function zoomhundredsslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoomhundredsslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function zoomtensslider_Callback(hObject, eventdata, handles)
% hObject    handle to zoomtensslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function zoomtensslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoomtensslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function zoomonesslider_Callback(hObject, eventdata, handles)
% hObject    handle to zoomonesslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function zoomonesslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoomonesslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function zoomhundreds_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoomhundreds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function zoomtens_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoomtens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function zoomones_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoomones (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function zoomfracslider_Callback(hObject, eventdata, handles)
% hObject    handle to zoomfracslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function zoomfracslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoomfracslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function zoomfrac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoomfrac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in centerOnSelection.
function centerOnSelection_Callback(hObject, eventdata, handles)
% hObject    handle to centerOnSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cbLineScanEnable.
function cbLineScanEnable_Callback(hObject, eventdata, handles)
% hObject    handle to cbLineScanEnable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbLineScanEnable


% --- Executes during object creation, after setting all properties.
function cbLineScanEnable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cbLineScanEnable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function etScanAngleMultiplierFast_Callback(hObject, eventdata, handles)
% hObject    handle to etScanAngleMultiplierFast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etScanAngleMultiplierFast as text
%        str2double(get(hObject,'String')) returns contents of etScanAngleMultiplierFast as a double


% --- Executes during object creation, after setting all properties.
function etScanAngleMultiplierFast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etScanAngleMultiplierFast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etScanAngleMultiplierSlow_Callback(hObject, eventdata, handles)
% hObject    handle to etScanAngleMultiplierSlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etScanAngleMultiplierSlow as text
%        str2double(get(hObject,'String')) returns contents of etScanAngleMultiplierSlow as a double


% --- Executes during object creation, after setting all properties.
function etScanAngleMultiplierSlow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etScanAngleMultiplierSlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbBase.
function pbBase_Callback(hObject, eventdata, handles)
% hObject    handle to pbBase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in tbShowAlignGUI.
function tbShowAlignGUI_Callback(hObject, eventdata, handles)
% hObject    handle to tbShowAlignGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbShowAlignGUI


% --- Executes on button press in pbRoot.
function pbRoot_Callback(hObject, eventdata, handles)
% hObject    handle to pbRoot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbSetBase.
function pbSetBase_Callback(hObject, eventdata, handles)
% hObject    handle to pbSetBase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbLastLine.
function pbLastLine_Callback(hObject, eventdata, handles)
% hObject    handle to pbLastLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbLastLineParent.
function pbLastLineParent_Callback(hObject, eventdata, handles)
% hObject    handle to pbLastLineParent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function configName_Callback(hObject, eventdata, handles)
% hObject    handle to configName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of configName as text
%        str2double(get(hObject,'String')) returns contents of configName as a double


% --- Executes during object creation, after setting all properties.
function configName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to configName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function repeatsDone_Callback(hObject, eventdata, handles)
% hObject    handle to repeatsDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of repeatsDone as text
%        str2double(get(hObject,'String')) returns contents of repeatsDone as a double


% --- Executes during object creation, after setting all properties.
function repeatsDone_CreateFcn(hObject, eventdata, handles)
% hObject    handle to repeatsDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function repeatsTotal_Callback(hObject, eventdata, handles)
% hObject    handle to repeatsTotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of repeatsTotal as text
%        str2double(get(hObject,'String')) returns contents of repeatsTotal as a double


% --- Executes during object creation, after setting all properties.
function repeatsTotal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to repeatsTotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function baseName_Callback(hObject, eventdata, handles)
% hObject    handle to baseName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baseName as text
%        str2double(get(hObject,'String')) returns contents of baseName as a double


% --- Executes during object creation, after setting all properties.
function baseName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baseName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fileCounter_Callback(hObject, eventdata, handles)
% hObject    handle to fileCounter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileCounter as text
%        str2double(get(hObject,'String')) returns contents of fileCounter as a double


% --- Executes during object creation, after setting all properties.
function fileCounter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileCounter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function slicesDone_Callback(hObject, eventdata, handles)
% hObject    handle to slicesDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slicesDone as text
%        str2double(get(hObject,'String')) returns contents of slicesDone as a double


% --- Executes during object creation, after setting all properties.
function slicesDone_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slicesDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function framesTotal_Callback(hObject, eventdata, handles)
% hObject    handle to framesTotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of framesTotal as text
%        str2double(get(hObject,'String')) returns contents of framesTotal as a double


% --- Executes during object creation, after setting all properties.
function framesTotal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to framesTotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function framesDone_Callback(hObject, eventdata, handles)
% hObject    handle to framesDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of framesDone as text
%        str2double(get(hObject,'String')) returns contents of framesDone as a double


% --- Executes during object creation, after setting all properties.
function framesDone_CreateFcn(hObject, eventdata, handles)
% hObject    handle to framesDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function slicesTotal_Callback(hObject, eventdata, handles)
% hObject    handle to slicesTotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slicesTotal as text
%        str2double(get(hObject,'String')) returns contents of slicesTotal as a double


% --- Executes during object creation, after setting all properties.
function slicesTotal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slicesTotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function userSettingsName_Callback(hObject, eventdata, handles)
% hObject    handle to userSettingsName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of userSettingsName as text
%        str2double(get(hObject,'String')) returns contents of userSettingsName as a double


% --- Executes during object creation, after setting all properties.
function userSettingsName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to userSettingsName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tbCycleControls.
function tbCycleControls_Callback(hObject, eventdata, handles)
% hObject    handle to tbCycleControls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbCycleControls



function etIterationsTotal_Callback(hObject, eventdata, handles)
% hObject    handle to etIterationsTotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etIterationsTotal as text
%        str2double(get(hObject,'String')) returns contents of etIterationsTotal as a double


% --- Executes during object creation, after setting all properties.
function etIterationsTotal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etIterationsTotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etIterationsDone_Callback(hObject, eventdata, handles)
% hObject    handle to etIterationsDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etIterationsDone as text
%        str2double(get(hObject,'String')) returns contents of etIterationsDone as a double


% --- Executes during object creation, after setting all properties.
function etIterationsDone_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etIterationsDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbLoadUsr.
function pbLoadUsr_Callback(hObject, eventdata, handles)
% hObject    handle to pbLoadUsr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbSaveUsr.
function pbSaveUsr_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveUsr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbLoadCfg.
function pbLoadCfg_Callback(hObject, eventdata, handles)
% hObject    handle to pbLoadCfg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbSaveCfg.
function pbSaveCfg_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveCfg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbSetSaveDir.
function pbSetSaveDir_Callback(hObject, eventdata, handles)
% hObject    handle to pbSetSaveDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function etRepeatPeriod_Callback(hObject, eventdata, handles)
% hObject    handle to etRepeatPeriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etRepeatPeriod as text
%        str2double(get(hObject,'String')) returns contents of etRepeatPeriod as a double


% --- Executes during object creation, after setting all properties.
function etRepeatPeriod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etRepeatPeriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function secondsCounter_Callback(hObject, eventdata, handles)
% hObject    handle to secondsCounter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of secondsCounter as text
%        str2double(get(hObject,'String')) returns contents of secondsCounter as a double


% --- Executes during object creation, after setting all properties.
function secondsCounter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to secondsCounter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbAutoSave.
function cbAutoSave_Callback(hObject, eventdata, handles)
% hObject    handle to cbAutoSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbAutoSave



function etNumAvgFramesSave_Callback(hObject, eventdata, handles)
% hObject    handle to etNumAvgFramesSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etNumAvgFramesSave as text
%        str2double(get(hObject,'String')) returns contents of etNumAvgFramesSave as a double


% --- Executes during object creation, after setting all properties.
function etNumAvgFramesSave_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etNumAvgFramesSave (see GCBO)
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


% --- Executes on button press in pbAddSquare.
function pbAddSquare_Callback(hObject, eventdata, handles)
% hObject    handle to pbAddSquare (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbAddLine.
function pbAddLine_Callback(hObject, eventdata, handles)
% hObject    handle to pbAddLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in tbToggleROI.
function tbToggleROI_Callback(hObject, eventdata, handles)
% hObject    handle to tbToggleROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbToggleROI


% --- Executes on button press in pbAddRectangle.
function pbAddRectangle_Callback(hObject, eventdata, handles)
% hObject    handle to pbAddRectangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbAddCenterPoint.
function pbAddCenterPoint_Callback(hObject, eventdata, handles)
% hObject    handle to pbAddCenterPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbAddPoint.
function pbAddPoint_Callback(hObject, eventdata, handles)
% hObject    handle to pbAddPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbAddPoints.
function pbAddPoints_Callback(hObject, eventdata, handles)
% hObject    handle to pbAddPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function etCurrentROIID_Callback(hObject, eventdata, handles)
% hObject    handle to etCurrentROIID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etCurrentROIID as text
%        str2double(get(hObject,'String')) returns contents of etCurrentROIID as a double


% --- Executes during object creation, after setting all properties.
function etCurrentROIID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etCurrentROIID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbGotoOnAdd.
function cbGotoOnAdd_Callback(hObject, eventdata, handles)
% hObject    handle to cbGotoOnAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbGotoOnAdd


% --- Executes on button press in cbSnapOnAdd.
function cbSnapOnAdd_Callback(hObject, eventdata, handles)
% hObject    handle to cbSnapOnAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbSnapOnAdd


% --------------------------------------------------------------------
function mnu_View_RaiseAllWindows_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_View_RaiseAllWindows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_View_ShowAllWindows_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_View_ShowAllWindows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_View_ImageControls_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_View_ImageControls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_View_PowerControls_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_View_PowerControls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_View_MotorControls_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_View_MotorControls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_View_FastZControls_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_View_FastZControls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_View_CycleModeControls_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_View_CycleModeControls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_View_ROIControls_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_View_ROIControls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_View_PosnControls_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_View_PosnControls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_View_Channel1Display_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_View_Channel1Display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_View_Channel2Display_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_View_Channel2Display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_View_Channel3Display_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_View_Channel3Display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_View_Channel4Display_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_View_Channel4Display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_View_Channel1MaxDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_View_Channel1MaxDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_View_Channel2MaxDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_View_Channel2MaxDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_View_Channel3MaxDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_View_Channel3MaxDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_View_Channel4MaxDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_View_Channel4MaxDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_View_ChannelMergeDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_View_ChannelMergeDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_Settings_Beams_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_Settings_Beams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_Settings_Channels_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_Settings_Channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_Settings_Triggers_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_Settings_Triggers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_Settings_ExportedClocks_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_Settings_ExportedClocks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_Settings_FastConfigurations_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_Settings_FastConfigurations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_Settings_UserFunctions_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_Settings_UserFunctions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_Settings_UserSettings_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_Settings_UserSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_File_LoadUserSettings_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_File_LoadUserSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_File_SaveUserSettings_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_File_SaveUserSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_File_SaveUserSettingsAs_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_File_SaveUserSettingsAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_File_LoadConfiguration_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_File_LoadConfiguration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_File_SaveConfiguration_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_File_SaveConfiguration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_File_SaveConfigurationAs_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_File_SaveConfigurationAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_File_FastConfigurations_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_File_FastConfigurations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_File_LoadCycle_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_File_LoadCycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_File_SaveCycle_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_File_SaveCycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_File_SaveCycleAs_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_File_SaveCycleAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_File_SetSavePath_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_File_SetSavePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_File_SaveLastAcqAs_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_File_SaveLastAcqAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_File_ExitScanImage_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_File_ExitScanImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_File_ExitMatlab_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_File_ExitMatlab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
