function varargout = motorControlsV4(varargin)
%MOTORCONTROLSV4 M-file for motorControlsV4.fig

% Edit the above text to modify the response to help motorControlsV4

% Last Modified by GUIDE v2.5 15-Jan-2015 03:05:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @motorControlsV4_OpeningFcn, ...
                   'gui_OutputFcn',  @motorControlsV4_OutputFcn, ...
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

function motorControlsV4_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

function varargout = motorControlsV4_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

%% Main Subpanel - Position controls
function pbReadPos_Callback(hObject, eventdata, handles) %#ok<*INUSL,*DEFNU>
handles.hController.changedMotorPosition;

function etPosX_Callback(hObject, eventdata, handles)
handles.hController.changeMotorPosition(hObject,1);

function etPosY_Callback(hObject, eventdata, handles)
handles.hController.changeMotorPosition(hObject,2);

function etPosZ_Callback(hObject, eventdata, handles)
handles.hController.changeMotorPosition(hObject,3);

function etPosZZ_Callback(hObject, eventdata, handles)
handles.hController.changeMotorPosition(hObject,4);

function pbZeroXYZ_Callback(hObject, eventdata, handles)
handles.hController.motorZeroAction('motorZeroXYZ');

function pbZeroZ_Callback(hObject, eventdata, handles)
handles.hController.motorZeroAction('motorZeroZ');

function pbZeroXY_Callback(hObject, eventdata, handles)
handles.hController.motorZeroAction('motorZeroXY');

function pbAltZeroXY_Callback(hObject, eventdata, handles)
handles.hController.motorZeroAction('motorZeroXY');

function pbAltZeroZ_Callback(hObject, eventdata, handles)
handles.hController.motorZeroAction('motorZeroZ');

function cbSecZ_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

%% Main Subpanel - Arrow controls

function pbStepXInc_Callback(hObject, eventdata, handles)
handles.hController.motorStepPosition('inc','x');

function pbStepYInc_Callback(hObject, eventdata, handles)
handles.hController.motorStepPosition('inc','y');

function pbStepZInc_Callback(hObject, eventdata, handles)
handles.hController.motorStepPosition('inc','z');

function pbStepXDec_Callback(hObject, eventdata, handles)
handles.hController.motorStepPosition('dec','x');

function pbStepYDec_Callback(hObject, eventdata, handles)
handles.hController.motorStepPosition('dec','y');

function pbStepZDec_Callback(hObject, eventdata, handles)
handles.hController.motorStepPosition('dec','z');

function etStepSizeX_Callback(hObject, eventdata, handles)
handles.hController.motorStepSize(1) = str2double(get(hObject,'String'));

function etStepSizeY_Callback(hObject, eventdata, handles)
handles.hController.motorStepSize(2) = str2double(get(hObject,'String'));

function etStepSizeZ_Callback(hObject, eventdata, handles)
handles.hController.motorStepSize(3) = str2double(get(hObject,'String'));

%% User-defined positions subpanel
function etPositionNumber_Callback(hObject, eventdata, handles)
posnIdx = str2double(get(hObject,'String'));
try
    handles.hController.motorUserPositionIndex = posnIdx;
catch %#ok<*CTCH>
    set(hObject,'String',num2str(handles.hController.motorUserPositionIndex));
end

function pbAddCurrent_Callback(hObject, eventdata, handles)
handles.hController.motorDefineUserPositionAndIncrement();

function tbTogglePosn_Callback(hObject, eventdata, handles)
hPosnGUI = handles.hController.hGUIs.posnControlsV4;
if get(hObject,'Value')
    set(hPosnGUI,'Visible','on');
else
    set(hPosnGUI,'Visible','off');
end

%% Stack subpanel
function pbSetStart_Callback(hObject, eventdata, handles)
handles.hController.stackSetStackStart();

function pbSetEnd_Callback(hObject, eventdata, handles)
handles.hController.stackSetStackEnd();

function pbClearStartEnd_Callback(hObject, eventdata, handles)
handles.hController.stackClearStartEnd();

function pbClearEnd_Callback(hObject, eventdata, handles)
handles.hController.stackClearEnd();

function cbUseStartPower_Callback(hObject,eventdata,handles)
tfUseStartPower = get(hObject,'Value');
if ~tfUseStartPower
    % Using overrideLz without stackUseStartPower is very rare. The SI4
    % API permits this with a warning, but here in UI we help the user out.
    handles.hController.hModel.stackUserOverrideLz = false;
end
handles.hController.hModel.stackUseStartPower = tfUseStartPower;

function cbOverrideLz_Callback(hObject, eventdata, handles)
tfOverrideLz = get(hObject,'Value');
if tfOverrideLz
    % Using overrideLz without stackUseStartPower is very rare. The SI4
    % API permits this with a warning, but here in the UI we help the user out.
    handles.hController.hModel.stackUseStartPower = true;
end
handles.hController.hModel.stackUserOverrideLz = tfOverrideLz;

function etNumberOfZSlices_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

function etZStepPerSlice_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

function cbReturnHome_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

function cbCenteredStack_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

%% The yellow button
function pbRecover_Callback(hObject,eventdata,handles)
handles.hController.motorRecover();

%% CREATE FCNS 

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
function etStepSizeZZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etStepSizeZZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end
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

function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

%% CREATE FCNS


% --- Executes during object creation, after setting all properties.
function pbStepXDec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pbStepXDec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'CData',most.gui.loadIcon('arrow.bmp',16,180,[0 0 1]));


% --- Executes during object creation, after setting all properties.
function pbStepXInc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pbStepXInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'CData',most.gui.loadIcon('arrow.bmp',16,[],[0 0 1]));


% --- Executes during object creation, after setting all properties.
function pbStepYDec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pbStepYDec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'CData',most.gui.loadIcon('arrow.bmp',16,90,[0 0 1]));


% --- Executes during object creation, after setting all properties.
function pbStepYInc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pbStepYInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'CData',most.gui.loadIcon('arrow.bmp',16,270,[0 0 1]));


% --- Executes during object creation, after setting all properties.
function pbStepZDec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pbStepZDec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'CData',most.gui.loadIcon('arrow.bmp',16,90,[0 0 1]));


% --- Executes during object creation, after setting all properties.
function pbStepZInc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pbStepZInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'CData',most.gui.loadIcon('arrow.bmp',16,270,[0 0 1]));


% --- Executes on button press in pbOverrideLz.
function pbOverrideLz_Callback(hObject, eventdata, handles)
% hObject    handle to pbOverrideLz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.beamLengthConstants = handles.hModel.beamComputeOverrideLzs();



function ATzrange_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function ATzrange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ATzrange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ATincrement_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function ATincrement_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ATincrement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton45.
function pushbutton45_Callback(hObject, eventdata, handles)
handles.hModel.ATactive = 1;

temp1 = handles.hModel.write2RAM;
temp2 = handles.hModel.autoscaleSavedImages;
temp3 = handles.hModel.loggingEnable;
temp4 = handles.hModel.channelsSave;
temp5 = handles.hModel.stackNumSlices;
temp6 = handles.hModel.acqNumFrames;
temp7 = handles.hModel.channelsSave;
temp8 = handles.hModel.hLSM.channelsLogging;
temp9 = handles.hModel.hLSM.channelsViewing;
tempA = handles.hModel.stackZStepSize;
tempB = handles.hModel.acqNumFrames;
tempC = handles.hModel.framerate_user_check;
tempD = handles.hModel.framerate_user;

handles.hModel.write2RAM = 1;
handles.hModel.autoscaleSavedImages = 0;
handles.hModel.loggingEnable = 1;
handles.hModel.channelsSave = [];
handles.hModel.stackNumSlices = 1;
handles.hModel.acqNumFrames = handles.hModel.ATnbframes;

handles.hModel.hLSM.channelsLogging = [1 0 0];
handles.hModel.hLSM.channelsViewing = [1 0 0];

if strcmpi(handles.hModel.acqState,'idle')
    handles.hModel.startGrab();
else
    handles.hModel.abort();
end

while ~strcmp(handles.hModel.acqState,'idle')
    pause(0.1);
end
    
handles.hModel.ATrefImage = mean(handles.hModel.BIG_FILE,3);
handles.hModel.BIG_FILE = [];
handles.hModel.ATactive = 1;
handles.hModel.write2RAM = temp1;
handles.hModel.autoscaleSavedImages = temp2;
handles.hModel.loggingEnable = temp3;
handles.hModel.channelsSave = temp4;
handles.hModel.stackNumSlices = temp5;
handles.hModel.acqNumFrames = temp6;
handles.hModel.channelsSave = temp7;
handles.hModel.hLSM.channelsLogging = temp8;
handles.hModel.hLSM.channelsViewing = temp9;
handles.hModel.stackZStepSize = tempA;
handles.hModel.acqNumFrames = tempB;
handles.hModel.framerate_user_check = tempC;
handles.hModel.framerate_user = tempD;

handles.hModel.ATactive = 0;


% --- Executes on button press in ATshowRef.
function ATshowRef_Callback(hObject, eventdata, handles)
LL = handles.hModel.ATrefImage;
figure(999), imagesc(LL'); colormap(gray);% axis off equal

% --- Executes on button press in ATrunAT.
function ATrunAT_Callback(hObject, eventdata, handles)
handles.hModel.ATactive = 1;

temp1 = handles.hModel.write2RAM;
temp2 = handles.hModel.autoscaleSavedImages;
temp3 = handles.hModel.loggingEnable;
temp4 = handles.hModel.channelsSave;
temp5 = handles.hModel.stackNumSlices;
temp6 = handles.hModel.acqNumFrames;
temp7 = handles.hModel.channelsSave;
temp8 = handles.hModel.hLSM.channelsLogging;
temp9 = handles.hModel.hLSM.channelsViewing;
tempA = handles.hModel.stackZStepSize;
tempB = handles.hModel.acqNumFrames;
tempC = handles.hModel.framerate_user_check;
tempD = handles.hModel.framerate_user;

handles.hModel.write2RAM = 1;
handles.hModel.autoscaleSavedImages = 0;
handles.hModel.loggingEnable = 1;
handles.hModel.channelsSave = [];
% handles.hModel.channelsDisplay = channelactiveX;
handles.hModel.stackNumSlices = handles.hModel.ATnbslices;
handles.hModel.acqNumFrames = handles.hModel.ATnbframes;
handles.hModel.stackZStepSize = handles.hModel.ATzrange/(handles.hModel.ATnbslices-1);

relative_positions = linspace(handles.hModel.ATzrange/2,-handles.hModel.ATzrange/2,handles.hModel.ATnbslices);

handles.hModel.hLSM.channelsLogging = [1 0 0];
handles.hModel.hLSM.channelsViewing = [1 0 0];

if strcmpi(handles.hModel.acqState,'idle')
    handles.hModel.startGrab();
else
    handles.hModel.abort();
end

while ~strcmp(handles.hModel.acqState,'idle')
    pause(0.1);
end

SLICES = handles.hModel.BIG_FILE; handles.hModel.BIG_FILE = [];

SLICES = reshape(SLICES,[size(SLICES,1) size(SLICES,2) handles.hModel.ATnbslices handles.hModel.ATnbframes]);

SLICES_AVG = mean(SLICES,4); SLICES = [];
clear maxCorr y_shift x_shift
for k = 1:size(SLICES_AVG,3)
    filterX = [1 2 1; 2 4 2; 1 2 1]/16;
    A = SLICES_AVG(:,:,k); A = A-mean(A(:)); A = A/std(A(:)); A = conv2(A,filterX,'same');
    B = handles.hModel.ATrefImage; B = B-mean(B(:)); B = B/std(B(:));B = conv2(B,filterX,'same');
    [~,~,dY2,dX2,cmax,~]= fcn_calc_relative_offset(A,B);
    y_shift(k) = dY2;
    x_shift(k) = dX2;
    maxCorr(k) = cmax;
%     B = circshift(B,[x_shift(k) y_shift(k)]);
end
[~,k_max] = max(maxCorr);

% figure(31), subplot(2,1,1); imagesc(handles.hModel.ATrefImage); colormap(gray);
% subplot(2,1,2); imagesc(SLICES_AVG(:,:,k_max)); colormap(gray);

disp(strcat('Move',32,num2str(relative_positions(k_max)),',',32,'in z',32,num2str(x_shift(k_max)),32,'in x',',',32,num2str(y_shift(k_max)),32,'in y.'));
handles.hModel.motorPosition = handles.hModel.motorPosition + [handles.hModel.motorscaleX*x_shift(k_max) handles.hModel.motorscaleY*y_shift(k_max) relative_positions(k_max)];

handles.hModel.ATactive = 1;
handles.hModel.write2RAM = temp1;
handles.hModel.autoscaleSavedImages = temp2;
handles.hModel.loggingEnable = temp3;
handles.hModel.channelsSave = temp4;
handles.hModel.stackNumSlices = temp5;
handles.hModel.acqNumFrames = temp6;
handles.hModel.channelsSave = temp7;
handles.hModel.hLSM.channelsLogging = temp8;
handles.hModel.hLSM.channelsViewing = temp9;
handles.hModel.stackZStepSize = tempA;
handles.hModel.acqNumFrames = tempB;
handles.hModel.framerate_user_check = tempC;
handles.hModel.framerate_user = tempD;

handles.hModel.ATactive = 0;



function ATnbslices_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function ATnbslices_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ATnbslices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ATduringFocusing.
function ATduringFocusing_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes on button press in ATcalibratexy.
function ATcalibratexy_Callback(hObject, eventdata, handles)
handles.hModel.ATactive = 1;

temp1 = handles.hModel.write2RAM;
temp2 = handles.hModel.autoscaleSavedImages;
temp3 = handles.hModel.loggingEnable;
temp4 = handles.hModel.channelsSave;
temp5 = handles.hModel.stackNumSlices;
temp6 = handles.hModel.acqNumFrames;
temp7 = handles.hModel.channelsSave;
temp8 = handles.hModel.hLSM.channelsLogging;
temp9 = handles.hModel.hLSM.channelsViewing;
tempA = handles.hModel.stackZStepSize;
tempB = handles.hModel.acqNumFrames;
tempC = handles.hModel.framerate_user_check;
tempD = handles.hModel.framerate_user;

handles.hModel.write2RAM = 1;
handles.hModel.autoscaleSavedImages = 0;
handles.hModel.loggingEnable = 1;
handles.hModel.channelsSave = [];
handles.hModel.stackNumSlices = 1;
handles.hModel.acqNumFrames = handles.hModel.ATnbframes;

handles.hModel.hLSM.channelsLogging = [1 0 0];
handles.hModel.hLSM.channelsViewing = [1 0 0];

if strcmpi(handles.hModel.acqState,'idle')
    handles.hModel.startGrab();
else
    handles.hModel.abort();
end

while ~strcmp(handles.hModel.acqState,'idle')
    pause(0.1);
end
    
Bild1 = mean(handles.hModel.BIG_FILE,3);
handles.hModel.BIG_FILE = [];

handles.hModel.motorPosition = handles.hModel.motorPosition + [17 14 0];

if strcmpi(handles.hModel.acqState,'idle')
    handles.hModel.startGrab();
else
    handles.hModel.abort();
end

while ~strcmp(handles.hModel.acqState,'idle')
    pause(0.1);
end
    
Bild2 = mean(handles.hModel.BIG_FILE,3);
handles.hModel.BIG_FILE = [];

handles.hModel.motorPosition = handles.hModel.motorPosition + [-17 -14 0];

A = Bild1;
B = Bild2;
[~,~,dY2,dX2,cmax,~]= fcn_calc_relative_offset(A,B);
y_shift = dY2;
x_shift = dX2;

handles.hModel.motorscaleX = 17/x_shift;
handles.hModel.motorscaleY = 14/y_shift;

handles.hModel.write2RAM = temp1;
handles.hModel.autoscaleSavedImages = temp2;
handles.hModel.loggingEnable = temp3;
handles.hModel.channelsSave = temp4;
handles.hModel.stackNumSlices = temp5;
handles.hModel.acqNumFrames = temp6;
handles.hModel.channelsSave = temp7;
handles.hModel.hLSM.channelsLogging = temp8;
handles.hModel.hLSM.channelsViewing = temp9;
handles.hModel.stackZStepSize = tempA;
handles.hModel.acqNumFrames = tempB;
handles.hModel.framerate_user_check = tempC;
handles.hModel.framerate_user = tempD;

handles.hModel.ATactive = 0;


