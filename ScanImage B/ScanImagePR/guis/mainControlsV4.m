function varargout = mainControlsV4(varargin)
%MAINCONTROLSV4 M-file for mainControlsV4.fig
%      MAINCONTROLSV4, by itself, creates a new MAINCONTROLSV4 or raises the existing
%      singleton*.
%
%      H = MAINCONTROLSV4 returns the handle to a new MAINCONTROLSV4 or the handle to
%      the existing singleton*.
%
%      MAINCONTROLSV4('Property','Value',...) creates a new MAINCONTROLSV4 using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to mainControlsV4_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      MAINCONTROLSV4('CALLBACK') and MAINCONTROLSV4('CALLBACK',hObject,...) call the
%      local function named CALLBACK in MAINCONTROLSV4.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mainControlsV4

% Last Modified by GUIDE v2.5 21-Nov-2014 01:52:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mainControlsV4_OpeningFcn, ...
                   'gui_OutputFcn',  @mainControlsV4_OutputFcn, ...
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


% --- Executes just before mainControlsV4 is made visible.
function mainControlsV4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for mainControlsV4
handles.output = hObject;

% Create PropControls
handles.pcZoom = most.gui.control.MultiDigitSpinner( ...
    [findobj(hObject,'Tag','zoomtensslider') findobj(hObject,'Tag','zoomonesslider') findobj(hObject,'Tag','zoomfracslider')], ...
[findobj(hObject,'Tag','zoomtens') findobj(hObject,'Tag','zoomones') findobj(hObject,'Tag','zoomfrac')], ...
    10,-1);        

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mainControlsV4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mainControlsV4_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in focusButton.
function focusButton_Callback(hObject, eventdata, handles)
% hObject    handle to focusButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmpi(handles.hModel.acqState,'idle')
    handles.hModel.startFocus();
else
    handles.hModel.abort();
end


% --- Executes on button press in grabOneButton.
function grabOneButton_Callback(hObject, eventdata, handles)
% hObject    handle to grabOneButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if strcmpi(handles.hModel.acqState,'idle')
    handles.hModel.startGrab();
else
    handles.hModel.abort();
end


% --- Executes on button press in startLoopButton.
function startLoopButton_Callback(hObject, eventdata, handles)
% hObject    handle to startLoopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmpi(handles.hModel.acqState,'idle')
    handles.hModel.startLoop();
else
    handles.hModel.abort();
end

% --- Executes on button press in tbExternalTrig.
function tbExternalTrig_Callback(hObject, eventdata, handles)
% hObject    handle to tbExternalTrig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbExternalTrig
handles.hController.updateModel(hObject,eventdata,handles);



function etScanOffsetX_Callback(hObject, eventdata, handles)
% hObject    handle to etScanOffsetX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etScanOffsetX as text
%        str2double(get(hObject,'String')) returns contents of etScanOffsetX as a double


% --- Executes during object creation, after setting all properties.
function etScanOffsetX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etScanOffsetX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etScanOffsetY_Callback(hObject, eventdata, handles)
% hObject    handle to etScanOffsetY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etScanOffsetY as text
%        str2double(get(hObject,'String')) returns contents of etScanOffsetY as a double


% --- Executes during object creation, after setting all properties.
function etScanOffsetY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etScanOffsetY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function phaseSlider_Callback(hObject, eventdata, handles)
% hObject    handle to phaseSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function phaseSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phaseSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in abortCurrentAcq.
function abortCurrentAcq_Callback(hObject, eventdata, handles)
% hObject    handle to abortCurrentAcq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cbAutoSave.
function cbAutoSave_Callback(hObject, eventdata, handles)
% hObject    handle to cbAutoSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbAutoSave
handles.hController.updateModel(hObject,eventdata,handles);


function etServoDelay_Callback(hObject, eventdata, handles)
% hObject    handle to etServoDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etServoDelay as text
%        str2double(get(hObject,'String')) returns contents of etServoDelay as a double


% --- Executes during object creation, after setting all properties.
function etServoDelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etServoDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbFinePhaseAdjust.
function cbFinePhaseAdjust_Callback(hObject, eventdata, handles)
% hObject    handle to cbFinePhaseAdjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbFinePhaseAdjust


% --- Executes on button press in pbDecServoDelay.
function pbDecServoDelay_Callback(hObject, eventdata, handles)
% hObject    handle to pbDecServoDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbIncServoDelay.
function pbIncServoDelay_Callback(hObject, eventdata, handles)
% hObject    handle to pbIncServoDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function etAccelerationTime_Callback(hObject, eventdata, handles)
% hObject    handle to etAccelerationTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etAccelerationTime as text
%        str2double(get(hObject,'String')) returns contents of etAccelerationTime as a double


% --- Executes during object creation, after setting all properties.
function etAccelerationTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etAccelerationTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbDecAccelerationTime.
function pbDecAccelerationTime_Callback(hObject, eventdata, handles)
% hObject    handle to pbDecAccelerationTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbIncAccelerationTime.
function pbIncAccelerationTime_Callback(hObject, eventdata, handles)
% hObject    handle to pbIncAccelerationTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbSaveConfig.
function pbSaveConfig_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in cbInfiniteFocus.
function cbInfiniteFocus_Callback(hObject, eventdata, handles)
% hObject    handle to cbInfiniteFocus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbInfiniteFocus



function shutterDelay_Callback(hObject, eventdata, handles)
% hObject    handle to shutterDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shutterDelay as text
%        str2double(get(hObject,'String')) returns contents of shutterDelay as a double


% --- Executes during object creation, after setting all properties.
function shutterDelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shutterDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function scanRotationSlider_Callback(hObject, eventdata, handles)
% hObject    handle to scanRotationSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


function scanRotation_Callback(hObject, eventdata, handles)
% hObject    handle to scanRotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scanRotation as text
%        str2double(get(hObject,'String')) returns contents of scanRotation as a double


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


function fullfield_Callback(hObject, eventdata, handles)
handles.hModel.scanZoomFactor = handles.hModel.scanMinZoomFactor;


function scanShiftSlow_Callback(hObject, eventdata, handles)
% hObject    handle to scanShiftSlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scanShiftSlow as text
%        str2double(get(hObject,'String')) returns contents of scanShiftSlow as a double



function scanShiftFast_Callback(hObject, eventdata, handles)
% hObject    handle to scanShiftFast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scanShiftFast as text
%        str2double(get(hObject,'String')) returns contents of scanShiftFast as a double



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
handles.hModel.offsetGalvoDown();

% --- Executes on button press in up.
function up_Callback(hObject, eventdata, handles)
% hObject    handle to up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.offsetGalvoUp();

% --- Executes on button press in zero.
function zero_Callback(hObject, eventdata, handles)
% hObject    handle to zero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.offsetGalvoZero();


function ystep_Callback(hObject, eventdata, handles)
% hObject    handle to ystep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ystep as text
%        str2double(get(hObject,'String')) returns contents of ystep as a double


function xstep_Callback(hObject, eventdata, handles)
% hObject    handle to xstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xstep as text
%        str2double(get(hObject,'String')) returns contents of xstep as a double

% --- Executes on slider movement.
function zoomtensslider_Callback(hObject, eventdata, handles)
% hObject    handle to zoomtensslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.hController.changeScanZoomFactor(hObject,10,str2double(get(handles.zoomtens,'String')));


% --- Executes on slider movement.
function zoomonesslider_Callback(hObject, eventdata, handles)
% hObject    handle to zoomonesslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.hController.changeScanZoomFactor(hObject,1,str2double(get(handles.zoomones,'String')));


% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function zoomhundreds_Callback(hObject, eventdata, handles)
% hObject    handle to zoomhundreds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zoomhundreds as text
%        str2double(get(hObject,'String')) returns contents of zoomhundreds as a double
handles.hController.changeScanZoomFactor(hObject,100,str2double(get(handles.zoomhundreds,'String')));



function zoomtens_Callback(hObject, eventdata, handles)
% hObject    handle to zoomtens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zoomtens as text
%        str2double(get(hObject,'String')) returns contents of zoomtens as a double
handles.hController.updateModel(hObject,eventdata,handles);


function zoomones_Callback(hObject, eventdata, handles)
% hObject    handle to zoomones (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zoomones as text
%        str2double(get(hObject,'String')) returns contents of zoomones as a double
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes on button press in selectLineScanAngle.
function selectLineScanAngle_Callback(hObject, eventdata, handles)
% hObject    handle to selectLineScanAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in centerOnSelection.
function centerOnSelection_Callback(hObject, eventdata, handles)
% hObject    handle to centerOnSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in tbShowAlignGUI.
function tbShowAlignGUI_Callback(hObject, eventdata, handles)
% hObject    handle to tbShowAlignGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbShowAlignGUI

%NOTE: In SI4, the 'align' button is re-purposed for point functionality
handles.hController.changedPointButton(hObject,eventdata);

% --- Executes on slider movement.
function zoomfracslider_Callback(hObject, eventdata, handles)
% hObject    handle to zoomfracslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.hController.changeScanZoomFactor(hObject,0.1,str2double(get(handles.zoomfrac,'String')));

function zoomfrac_Callback(hObject, eventdata, handles)
% hObject    handle to zoomfrac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zoomfrac as text
%        str2double(get(hObject,'String')) returns contents of zoomfrac as a double
handles.hController.updateModel(hObject,eventdata,handles);


function etScanAngleMultiplierSlow_Callback(hObject, eventdata, handles)
% hObject    handle to etScanAngleMultiplierSlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etScanAngleMultiplierSlow as text
%        str2double(get(hObject,'String')) returns contents of etScanAngleMultiplierSlow as a double
handles.hController.updateModel(hObject,eventdata,handles);



% --- Executes on button press in setReset.
function setReset_Callback(hObject, eventdata, handles)
% hObject    handle to setReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function cycleName_Callback(hObject, eventdata, handles)
% hObject    handle to cycleName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cycleName as text
%        str2double(get(hObject,'String')) returns contents of cycleName as a double


% --- Executes during object creation, after setting all properties.
function cycleName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cycleName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function configName_Callback(hObject, eventdata, handles)
% hObject    handle to configName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etConfiguration as text
%        str2double(get(hObject,'String')) returns contents of etConfiguration as a double


% --- Executes during object creation, after setting all properties.
function etConfiguration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etConfiguration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cyclePosition_Callback(hObject, eventdata, handles)
% hObject    handle to cyclePosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cyclePosition as text
%        str2double(get(hObject,'String')) returns contents of cyclePosition as a double


% --- Executes during object creation, after setting all properties.
function cyclePosition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cyclePosition (see GCBO)
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

% Hints: get(hObject,'String') returns contents of etRepeatsDone as text
%        str2double(get(hObject,'String')) returns contents of etRepeatsDone as a double


% --- Executes during object creation, after setting all properties.
function etRepeatsDone_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etRepeatsDone (see GCBO)
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

% Hints: get(hObject,'String') returns contents of etNumRepeats as text
%        str2double(get(hObject,'String')) returns contents of etNumRepeats as a double
handles.hController.updateModel(hObject,eventdata,handles);



function baseName_Callback(hObject, eventdata, handles)
% hObject    handle to baseName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baseName as text
%        str2double(get(hObject,'String')) returns contents of baseName as a double
handles.hController.updateModel(hObject,eventdata,handles);


function fileCounter_Callback(hObject, eventdata, handles)
% hObject    handle to fileCounter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileCounter as text
%        str2double(get(hObject,'String')) returns contents of fileCounter as a double
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes on slider movement.
function positionToExecuteSlider_Callback(hObject, eventdata, handles)
% hObject    handle to positionToExecuteSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function positionToExecuteSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to positionToExecuteSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function slicesDone_Callback(hObject, eventdata, handles)
% hObject    handle to slicesDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etSlicesDone as text
%        str2double(get(hObject,'String')) returns contents of etSlicesDone as a double


% --- Executes during object creation, after setting all properties.
function etSlicesDone_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etSlicesDone (see GCBO)
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

% Hints: get(hObject,'String') returns contents of etNumFrames as text
%        str2double(get(hObject,'String')) returns contents of etNumFrames as a double
handles.hController.updateModel(hObject,eventdata,handles);



function slicesTotal_Callback(hObject, eventdata, handles)
% hObject    handle to slicesTotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etNumSlices as text
%        str2double(get(hObject,'String')) returns contents of etNumSlices as a double
handles.hController.updateModel(hObject,eventdata,handles);


function etRepeatPeriod_Callback(hObject, eventdata, handles)
% hObject    handle to etRepeatPeriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etRepeatPeriod as text
%        str2double(get(hObject,'String')) returns contents of etRepeatPeriod as a double
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes on button press in showrotbox.
function showrotbox_Callback(hObject, eventdata, handles)
% hObject    handle to showrotbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in linescan.
function linescan_Callback(hObject, eventdata, handles)
% hObject    handle to linescan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of linescan


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


% --- Executes on button press in ROI.
function ROI_Callback(hObject, eventdata, handles)
% hObject    handle to ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in addROI.
function addROI_Callback(hObject, eventdata, handles)
% hObject    handle to addROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in roiSaver.
function roiSaver_Callback(hObject, eventdata, handles)
% hObject    handle to roiSaver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns roiSaver contents as cell array
%        contents{get(hObject,'Value')} returns selected item from roiSaver


% --- Executes during object creation, after setting all properties.
function roiSaver_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiSaver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dropROI.
function dropROI_Callback(hObject, eventdata, handles)
% hObject    handle to dropROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in backROI.
function backROI_Callback(hObject, eventdata, handles)
% hObject    handle to backROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in nextROI.
function nextROI_Callback(hObject, eventdata, handles)
% hObject    handle to nextROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in undo.
function undo_Callback(hObject, eventdata, handles)
% hObject    handle to undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function etSecondsCounter_Callback(hObject, eventdata, handles)
% hObject    handle to etSecondsCounter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etSecondsCounter as text
%        str2double(get(hObject,'String')) returns contents of etSecondsCounter as a double


% --- Executes during object creation, after setting all properties.
function etSecondsCounter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etSecondsCounter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pbBase_Callback(hObject, eventdata, handles)
handles.hModel.scanParamResetToBase();

function pbSetBase_Callback(hObject, eventdata, handles)
handles.hModel.scanParamSetBase();

% --- Executes on button press in cbLineScanEnable.
function cbLineScanEnable_Callback(hObject, eventdata, handles)
% hObject    handle to cbLineScanEnable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbLineScanEnable



function userSettingsName_Callback(hObject, eventdata, handles)
% hObject    handle to userSettingsName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etUserSettings as text
%        str2double(get(hObject,'String')) returns contents of etUserSettings as a double


% --- Executes during object creation, after setting all properties.
function etUserSettings_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etUserSettings (see GCBO)
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



function etIterationsDone_Callback(hObject, eventdata, handles)
% hObject    handle to etIterationsDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etIterationsDone as text
%        str2double(get(hObject,'String')) returns contents of etIterationsDone as a double

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


% --- Executes on button press in pbAddPoints.
function pbAddPoints_Callback(hObject, eventdata, handles)
% hObject    handle to pbAddPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in tbToggleROI.
function tbToggleROI_Callback(hObject, eventdata, handles)
% hObject    handle to tbToggleROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbToggleROI


% --- Executes on button press in pbAddPosition.
function pbAddPosition_Callback(hObject, eventdata, handles)
% hObject    handle to pbAddPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in pbLoadUsr.
function pbLoadUsr_Callback(hObject, eventdata, handles)
% hObject    handle to pbLoadUsr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.usrLoadUsr();

% --- Executes on button press in pbSaveUsr.
function pbSaveUsr_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveUsr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.usrSaveUsr();

% --- Executes on button press in pbLoadCfg.
function pbLoadCfg_Callback(hObject, eventdata, handles)
% hObject    handle to pbLoadCfg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.cfgLoadConfig();

% --- Executes on button press in pbSaveCfg.
function pbSaveCfg_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveCfg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.cfgSaveConfig();

% --- Executes on button press in pbSetSaveDir.
function pbSetSaveDir_Callback(hObject, eventdata, handles)
% hObject    handle to pbSetSaveDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.setSavePath();

function etNumAvgFramesSave_Callback(hObject, eventdata, handles)
% hObject    handle to etNumAvgFramesSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etNumAvgFramesSave as text
%        str2double(get(hObject,'String')) returns contents of etNumAvgFramesSave as a double
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes on button press in pbIncAcqNumber.
function pbIncAcqNumber_Callback(hObject, eventdata, handles)
% hObject    handle to pbIncAcqNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.loggingFileCounter = handles.hModel.loggingFileCounter + 1;

%% Fast Configurations Panel

function pbFastConfig1_Callback(hObject, eventdata, handles) %#ok<*INUSL,*DEFNU>
handles.hController.hModel.fastCfgLoadConfig(1);

function pbFastConfig2_Callback(hObject, eventdata, handles)
handles.hController.hModel.fastCfgLoadConfig(2);

function pbFastConfig3_Callback(hObject, eventdata, handles)
handles.hController.hModel.fastCfgLoadConfig(3);

function pbFastConfig4_Callback(hObject, eventdata, handles)
handles.hController.hModel.fastCfgLoadConfig(4);

function pbFastConfig5_Callback(hObject, eventdata, handles)
handles.hController.hModel.fastCfgLoadConfig(5);

function pbFastConfig6_Callback(hObject, eventdata, handles)
handles.hController.hModel.fastCfgLoadConfig(6);

function tbShowConfigGUI_Callback(hObject, eventdata, handles)

%TODO: Re-implement 'tethering'
hConfigGUI = handles.hController.hGUIs.configControlsV4;
if get(hObject,'Value')
    set(hConfigGUI,'Visible','on');
else
    set(hConfigGUI,'Visible','off');
end


%% File menu
function mnu_File_LoadUserSettings_Callback(hObject, eventdata, handles)
handles.hModel.usrLoadUsr();

function mnu_File_SaveUserSettings_Callback(hObject, eventdata, handles)
handles.hModel.usrSaveUsr();

function mnu_File_SaveUserSettingsAs_Callback(hObject, eventdata, handles)
handles.hModel.usrSaveUsrAs();

function mnu_File_LoadConfiguration_Callback(hObject, eventdata, handles)
handles.hModel.cfgLoadConfig();

function mnu_File_SaveConfiguration_Callback(hObject, eventdata, handles)
handles.hModel.cfgSaveConfig();

function mnu_File_SaveConfigurationAs_Callback(hObject, eventdata, handles)
handles.hModel.cfgSaveConfigAs();

function mnu_File_FastConfigurations_Callback(hObject, eventdata, handles)
handles.hController.showGUI('fastConfigurationV4');

function mnu_File_SetSavePath_Callback(hObject, eventdata, handles)
handles.hModel.setSavePath();

function mnu_File_ExitMatlab_Callback(hObject, eventdata, handles)
scim_exit('prompt');
if ~scim_isRunning()
    exit;
end

function mnu_File_ExitScanImage_Callback(hObject, eventdata, handles)
scim_exit('prompt');

function mnu_File_LoadCycle_Callback(hObject, eventdata, handles)

function mnu_File_SaveCycle_Callback(hObject, eventdata, handles)

function mnu_File_SaveCycleAs_Callback(hObject, eventdata, handles)

function mnu_File_SaveLastAcqAs_Callback(hObject, eventdata, handles)
handles.hModel.saveDisplayAs();


%% Settings menu

function mnu_Settings_Beams_Callback(hObject, eventdata, handles)
%TODO

function mnu_Settings_Channels_Callback(hObject, eventdata, handles)
handles.hController.showGUI('channelControlsV4');

function mnu_Settings_Triggers_Callback(hObject, eventdata, handles)
handles.hController.showGUI('triggerControlsV4');

function mnu_Settings_ExportedClocks_Callback(hObject, eventdata, handles)
%N/A for SI4

function mnu_Settings_FastConfigurations_Callback(hObject, eventdata, handles)
handles.hController.showGUI('fastConfigurationV4');

function mnu_Settings_UserFunctions_Callback(hObject, eventdata, handles)
handles.hController.showGUI('userFunctionControlsV4');

function mnu_Settings_UserSettings_Callback(hObject, eventdata, handles)
handles.hController.showGUI('userSettingsV4');

%% View menu
function mnu_View_RaiseAllWindows_Callback(hObject, eventdata, handles)
handles.hController.raiseAllGUIs();

function mnu_View_ShowAllWindows_Callback(hObject, eventdata, handles)
handles.hController.showAllGUIs();

function mnu_View_AcquisitionControls_Callback(hObject, eventdata, handles)
handles.hController.showGUI('acquisitionControlsV4');

function mnu_View_CycleModeControls_Callback(hObject, eventdata, handles)
%TODO

function mnu_View_ImageControls_Callback(hObject, eventdata, handles)
handles.hController.showGUI('imageControlsV4');

function mnu_View_PowerControls_Callback(hObject, eventdata, handles)
handles.hController.showGUI('powerControlsV4');

function mnu_View_MotorControls_Callback(hObject, eventdata, handles)
handles.hController.showGUI('motorControlsV4');

function mnu_View_FastZControls_Callback(hObject, eventdata, handles)
handles.hController.showGUI('fastZControlsV4');

function mnu_View_ROIControls_Callback(hObject, eventdata, handles)
%TODO

function mnu_View_PosnControls_Callback(hObject, eventdata, handles)
%TODO

function mnu_View_Channel1Display_Callback(hObject, eventdata, handles)
handles.hController.showChannelDisplay(1);

function mnu_View_Channel2Display_Callback(hObject, eventdata, handles)
handles.hController.showChannelDisplay(2);

function mnu_View_Channel3Display_Callback(hObject, eventdata, handles)
handles.hController.showChannelDisplay(3);

function mnu_View_Channel4Display_Callback(hObject, eventdata, handles)
handles.hController.showChannelDisplay(4);

function mnu_View_Channel1MaxDisplay_Callback(hObject, eventdata, handles)
%TODO

function mnu_View_Channel2MaxDisplay_Callback(hObject, eventdata, handles)
%TODO

function mnu_View_Channel3MaxDisplay_Callback(hObject, eventdata, handles)
%TODO

function mnu_View_Channel4MaxDisplay_Callback(hObject, eventdata, handles)
%TODO

function mnu_View_ChannelMergeDisplay_Callback(hObject, eventdata, handles)
%TODO

% --- Executes on button press in cbAutoSave.
function checkbox13_Callback(hObject, eventdata, handles)
% hObject    handle to cbAutoSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbAutoSave




%% CREATE FCNS 

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

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

% --- Executes during object creation, after setting all properties.
function scanRotationSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scanRotationSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor',[.9 .9 .9]);
end

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

% --- Executes during object creation, after setting all properties.
function zoomhundredsslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoomhundredsslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function zoomtensslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoomtensslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor',[.9 .9 .9]);
end

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

% --- Executes during object creation, after setting all properties.
function cbLineScanEnable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cbLineScanEnable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

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



% --- Executes during object creation, after setting all properties.
function left_CreateFcn(hObject, eventdata, handles)
% hObject    handle to left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'CData',most.gui.loadIcon('arrow.bmp',16,180,[0 0 1]));


% --- Executes during object creation, after setting all properties.
function right_CreateFcn(hObject, eventdata, handles)
% hObject    handle to right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'CData',most.gui.loadIcon('arrow.bmp',16,[],[0 0 1]));

% --- Executes during object creation, after setting all properties.
function down_CreateFcn(hObject, eventdata, handles)
% hObject    handle to down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'CData',most.gui.loadIcon('arrow.bmp',16,90,[0 0 1]));

% --- Executes during object creation, after setting all properties.
function up_CreateFcn(hObject, eventdata, handles)
% hObject    handle to up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'CData',most.gui.loadIcon('arrow.bmp',16,270,[0 0 1]));


% --- Executes on button press in tbToggleLinescan.
function tbToggleLinescan_Callback(hObject, eventdata, handles)
% hObject    handle to tbToggleLinescan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbToggleLinescan
handles.hController.toggleLineScan(hObject,eventdata);



function secondsCounter_Callback(hObject, eventdata, handles)
% hObject    handle to secondsCounter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of secondsCounter as text
%        str2double(get(hObject,'String')) returns contents of secondsCounter as a double



function framesDone_Callback(hObject, eventdata, handles)
% hObject    handle to framesDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of framesDone as text
%        str2double(get(hObject,'String')) returns contents of framesDone as a double


% --- Executes on button press in autoconvert.
function autoconvert_Callback(hObject, eventdata, handles)
% hObject    handle to autoconvert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes on button press in focusSave.
function focusSave_Callback(hObject, eventdata, handles)
% handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes on button press in autoscale.
function autoscale_Callback(hObject, eventdata, handles)
% handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes on button press in delayedChannelsOn.
function delayedChannelsOn_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes on selection change in nbDelayedChannels.
function nbDelayedChannels_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function nbDelayedChannels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nbDelayedChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in mergeAlign.
function mergeAlign_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);



function mergeshift_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function mergeshift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mergeshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in triggerOut.
function triggerOut_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);



function triggerOutDelay_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function triggerOutDelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to triggerOutDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function triggerOutDuration_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function triggerOutDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to triggerOutDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in savedBitdepth.
function savedBitdepth_Callback(hObject, eventdata, handles)
% handles.hController.updateModel(hObject,eventdata,handles);
