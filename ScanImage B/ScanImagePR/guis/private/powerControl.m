function varargout = powerControl(varargin)
%POWERCONTROL M-file for powerControl.fig
%      POWERCONTROL, by itself, creates a new POWERCONTROL or raises the existing
%      singleton*.
%
%      H = POWERCONTROL returns the handle to a new POWERCONTROL or the handle to
%      the existing singleton*.
%
%      POWERCONTROL('Property','Value',...) creates a new POWERCONTROL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to powerControl_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      POWERCONTROL('CALLBACK') and POWERCONTROL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in POWERCONTROL.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help powerControl

% Last Modified by GUIDE v2.5 05-Nov-2011 12:06:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @powerControl_OpeningFcn, ...
                   'gui_OutputFcn',  @powerControl_OutputFcn, ...
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


% --- Executes just before powerControl is made visible.
function powerControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for powerControl
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes powerControl wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = powerControl_OutputFcn(hObject, eventdata, handles)
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


% --- Executes on button press in usePowerArray.
function usePowerArray_Callback(hObject, eventdata, handles)
% hObject    handle to usePowerArray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of usePowerArray


% --- Executes on button press in tbRecordPvsZ.
function tbRecordPvsZ_Callback(hObject, eventdata, handles)
% hObject    handle to tbRecordPvsZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbRecordPvsZ


% --- Executes on button press in pbGetPvsZ.
function pbGetPvsZ_Callback(hObject, eventdata, handles)
% hObject    handle to pbGetPvsZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in tbShowPowerBox.
function tbShowPowerBox_Callback(hObject, eventdata, handles)
% hObject    handle to tbShowPowerBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbShowPowerBox


% --- Executes on slider movement.
function beamMenuSlider_Callback(hObject, eventdata, handles)
% hObject    handle to beamMenuSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function beamMenuSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beamMenuSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in beamMenu.
function beamMenu_Callback(hObject, eventdata, handles)
% hObject    handle to beamMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns beamMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from beamMenu


% --- Executes during object creation, after setting all properties.
function beamMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beamMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxPowerText_Callback(hObject, eventdata, handles)
% hObject    handle to maxPowerText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxPowerText as text
%        str2double(get(hObject,'String')) returns contents of maxPowerText as a double


% --- Executes during object creation, after setting all properties.
function maxPowerText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxPowerText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in mW_radioButton.
function mW_radioButton_Callback(hObject, eventdata, handles)
% hObject    handle to mW_radioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mW_radioButton


% --- Executes on button press in percent_radioButton.
function percent_radioButton_Callback(hObject, eventdata, handles)
% hObject    handle to percent_radioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of percent_radioButton


% --- Executes on slider movement.
function maxPower_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to maxPower_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function maxPower_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxPower_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over maxPower_Slider.
function maxPower_Slider_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to maxPower_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cbDirectMode.
function cbDirectMode_Callback(hObject, eventdata, handles)
% hObject    handle to cbDirectMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbDirectMode


% --- Executes on slider movement.
function maxLimit_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to maxLimit_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function maxLimit_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxLimit_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function maxLimit_Callback(hObject, eventdata, handles)
% hObject    handle to maxLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxLimit as text
%        str2double(get(hObject,'String')) returns contents of maxLimit as a double


% --- Executes during object creation, after setting all properties.
function maxLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbSliderDuringFocus.
function cbSliderDuringFocus_Callback(hObject, eventdata, handles)
% hObject    handle to cbSliderDuringFocus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbSliderDuringFocus



function etZLengthConstant_Callback(hObject, eventdata, handles)
% hObject    handle to etZLengthConstant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etZLengthConstant as text
%        str2double(get(hObject,'String')) returns contents of etZLengthConstant as a double


% --- Executes during object creation, after setting all properties.
function etZLengthConstant_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etZLengthConstant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbEnablePvsZ.
function cbEnablePvsZ_Callback(hObject, eventdata, handles)
% hObject    handle to cbEnablePvsZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbEnablePvsZ
