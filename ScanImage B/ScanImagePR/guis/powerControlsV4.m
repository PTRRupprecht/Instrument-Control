function varargout = powerControlsV4(varargin)
%POWERCONTROLSV4 M-file for powerControlsV4.fig

% Last Modified by GUIDE v2.5 25-Oct-2011 15:05:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @powerControlsV4_OpeningFcn, ...
                   'gui_OutputFcn',  @powerControlsV4_OutputFcn, ...
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

function powerControlsV4_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
handles.output = hObject;
guidata(hObject, handles);

function varargout = powerControlsV4_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

%% Beam Index Control

function pumBeamIdx_Callback(hObject,eventdata,handles)
handles.hController.beamDisplayIdx = get(hObject,'Value');


function sldBeamIdx_Callback(hObject, eventdata, handles)
handles.hController.beamDisplayIdx = get(hObject,'Value');

%% Beam-Indexed Controls
function etBeamPower_Callback(hObject,eventdata,handles) %#ok<*DEFNU>
handles.hController.changeBeamParams(hObject,eventdata,handles);

function sldBeamPower_Callback(hObject, eventdata, handles)
handles.hController.changeBeamParams(hObject,eventdata,handles);

function etMaxLimit_Callback(hObject, eventdata, handles)
handles.hController.changeBeamParams(hObject,eventdata,handles);

function sldMaxLimit_Callback(hObject, eventdata, handles)
handles.hController.changeBeamParams(hObject,eventdata,handles);

function etZLengthConstant_Callback(hObject, eventdata, handles)
handles.hController.changeBeamParams(hObject,eventdata,handles);

%% Non-Beam-Indexed Controls

function cbLiveAdjust_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

function cbDirectMode_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

function cbPzAdjust_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

function rbPercentBeamPower_Callback(hObject, eventdata, handles)
handles.hController.hModel.beamPowerUnits = 'percent';

function rbMilliwattBeamPower_Callback(hObject, eventdata, handles)
handles.hController.hModel.beamPowerUnits = 'milliwatts';


%% Calibration menu
function mnu_Calibration_CalibrateBeams_Callback(hObject, eventdata, handles)
handles.hController.calibrateBeam();

function mnu_Calibration_ShowCalibrationCurve_Callback(hObject, eventdata, handles)
handles.hController.showCalibrationCurve();

function mnu_Calibration_MeasureCalibrationOffset_Callback(hObject, eventdata, handles)
handles.hController.measureCalibrationOffset();

%% Power Box

% % --- Executes on button press in tbShowPowerBox.
% function tbShowPowerBox_Callback(hObject, eventdata, handles)
% % hObject    handle to tbShowPowerBox (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of tbShowPowerBox

%% Create Fcns

% --- Executes during object creation, after setting all properties.
function sldBeamIdx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldBeamIdx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function pumBeamIdx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pumBeamIdx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function sldBeamPower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldBeamPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function sldMaxLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldMaxLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor',[.9 .9 .9]);
end

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
