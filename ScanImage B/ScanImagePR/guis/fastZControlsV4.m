function varargout = fastZControlsV4(varargin)
% FASTZCONTROLSV4 MATLAB code for fastZControlsV4.fig
%      FASTZCONTROLSV4, by itself, creates a new FASTZCONTROLSV4 or raises the existing
%      singleton*.
%
%      H = FASTZCONTROLSV4 returns the handle to a new FASTZCONTROLSV4 or the handle to
%      the existing singleton*.
%
%      FASTZCONTROLSV4('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FASTZCONTROLSV4.M with the given input arguments.
%
%      FASTZCONTROLSV4('Property','Value',...) creates a new FASTZCONTROLSV4 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fastZControlsV4_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fastZControlsV4_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fastZControlsV4

% Last Modified by GUIDE v2.5 17-Mar-2016 16:24:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fastZControlsV4_OpeningFcn, ...
                   'gui_OutputFcn',  @fastZControlsV4_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


% --- Executes just before fastZControlsV4 is made visible.
function fastZControlsV4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fastZControlsV4 (see VARARGIN)

% Choose default command line output for fastZControlsV4
handles.output = hObject;

%Initialize PropControls
handles.pcFramePeriodAdjust = most.gui.control.Spinner(...
                                findobj(hObject,'Tag','sldrFramePeriodAdjust'),...
                                findobj(hObject,'Tag','etFramePeriodAdjust'));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fastZControlsV4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fastZControlsV4_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% Acquisition Control Panel

function cbReturnHome_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

function cbCenteredStack_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

function etZStepPerSlice_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

function etNumZSlices_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

function cbEnable_Callback(hObject, eventdata, handles)
updateModel(handles.hController,hObject,eventdata,handles);

function etNumVolumes_Callback(hObject, eventdata, handles)
updateModel(handles.hController,hObject,eventdata,handles);

%% Fast Z Configuration

function etSettlingTime_Callback(hObject, eventdata, handles)
handles.hController.changeFastZSettlingTimeVar(hObject,eventdata,handles);

% --- Executes on selection change in pmImageType.
function pmImageType_Callback(hObject, eventdata, handles)
updateModel(handles.hController,hObject,eventdata,handles);


function pmScanType_Callback(hObject, eventdata, handles)
updateModel(handles.hController,hObject,eventdata,handles);


function cbDiscardFlybackFrames_Callback(hObject, eventdata, handles)
updateModel(handles.hController,hObject,eventdata,handles);


function sldrFramePeriodAdjust_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);


function etFramePeriodAdjust_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

function etNumDiscardFrames_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

function pbMeasureFramePeriod_Callback(hObject, eventdata, handles)
handles.hModel.scanFramePeriodMeasure();



%% CREATE FCNS

% --- Executes during object creation, after setting all properties.
function etFramePeriod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etFramePeriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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


% --- Executes during object creation, after setting all properties.
function etNumZSlices_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etNumZSlices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etVolumesDone_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etVolumesDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etNumVolumes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etNumVolumes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function etSettlingTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etSettlingTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function pmImageType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmImageType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function pmScanType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmScanType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function sldrFramePeriodAdjust_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldrFramePeriodAdjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes during object creation, after setting all properties.
function etFramePeriodAdjust_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etNumDiscardFrames_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






function fastz_step_nbplanes_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function fastz_step_nbplanes_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fastz_step_stepsize_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function fastz_step_stepsize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fastz_step_settlingtime_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function fastz_step_settlingtime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fastz_cont_nbplanes_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function fastz_cont_nbplanes_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fastz_cont_amplitude_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function fastz_cont_amplitude_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in moveZero.
function moveZero_Callback(hObject, eventdata, handles)
handles.hModel.moveZmirror(0);


% --- Executes on button press in goDown.
function goDown_Callback(hObject, eventdata, handles)
handles.hModel.moveZmirror(-1);


% --- Executes on button press in defZero.
function defZero_Callback(hObject, eventdata, handles)
handles.hModel.defineZeroZ();

% --- Executes on button press in goUp.
function goUp_Callback(hObject, eventdata, handles)
handles.hModel.moveZmirror(1);

function lowVal_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function lowVal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function highVal_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function highVal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function dutyCycleZ_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function dutyCycleZ_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in exec_after.
function exec_after_Callback(hObject, eventdata, handles)
updateModel(handles.hController,hObject,eventdata,handles);


% --- Executes on button press in offset_directly.
function offset_directly_Callback(hObject, eventdata, handles)
updateModel(handles.hController,hObject,eventdata,handles);


% --- Executes on button press in pockelsZ.
function pockelsZ_Callback(hObject, eventdata, handles)
updateModel(handles.hController,hObject,eventdata,handles);



function pockelsZoffset_Callback(hObject, eventdata, handles)
updateModel(handles.hController,hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function pockelsZoffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pockelsZoffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function leftbias_Callback(hObject, eventdata, handles)
updateModel(handles.hController,hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function leftbias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to leftbias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function topbias_Callback(hObject, eventdata, handles)
updateModel(handles.hController,hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function topbias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to topbias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
