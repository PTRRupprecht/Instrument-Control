function varargout = configControlsV4(varargin)
%CONFIGCONTROLSV4 M-file for configControlsV4.fig
%      CONFIGCONTROLSV4, by itself, creates a new CONFIGCONTROLSV4 or raises the existing
%      singleton*.
%
%      H = CONFIGCONTROLSV4 returns the handle to a new CONFIGCONTROLSV4 or the handle to
%      the existing singleton*.
%
%      CONFIGCONTROLSV4('Property','Value',...) creates a new CONFIGCONTROLSV4 using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to configControlsV4_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      CONFIGCONTROLSV4('CALLBACK') and CONFIGCONTROLSV4('CALLBACK',hObject,...) call the
%      local function named CALLBACK in CONFIGCONTROLSV4.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help configControlsV4

% Last Modified by GUIDE v2.5 14-Jan-2015 23:25:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @configControlsV4_OpeningFcn, ...
                   'gui_OutputFcn',  @configControlsV4_OutputFcn, ...
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


% --- Executes just before configControlsV4 is made visible.
function configControlsV4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for configControlsV4
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes configControlsV4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = configControlsV4_OutputFcn(hObject, eventdata, handles)
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





%% CFG File Controls

function configurationName_Callback(hObject, eventdata, handles)

function pbSaveConfig_Callback(hObject, eventdata, handles)
handles.hModel.cfgSaveConfig();

function pbLoadConfig_Callback(hObject, eventdata, handles)
handles.hModel.cfgLoadConfig();

function pbSaveConfigAs_Callback(hObject, eventdata, handles)
handles.hModel.cfgSaveConfigAs();

function pbApplyConfig_Callback(hObject, eventdata, handles)

% function tbShowAdvanced_Callback(hObject, eventdata, handles)
% toggleAdvancedPanel(hObject,5,'y');


%% Scan Controls

function etLinesPerFrame_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

function pmPixelsPerLine_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

function pbMeasureFrameRate_Callback(hObject, eventdata, handles)
handles.hModel.scannerPeriodMeasure(true);

function cbBidirectionalScan_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    handles.hModel.scanMode = 'bidirectional';
else
    handles.hModel.scanMode = 'unidirectional';
end


function cbForceSquarePixelation_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);


function cbForceSquarePixel_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);


% function etLinePeriod_Callback(hObject, eventdata, handles)
% handles.hController.updateModel(hObject,eventdata,handles);



%% File Saving Controls

function etFramesPerFile_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);


function cbFramesPerFileLock_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);


function cbAutoSave_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);



%% Acq Delay Controls


function etScanPhase_Callback(hObject, eventdata, handles)
handles.hController.changeScanPhase(hObject);

function pbDecScanPhase_Callback(hObject, eventdata, handles)
handles.hController.changeScanPhaseStepwise(-1,false);

function pbIncScanPhase_Callback(hObject, eventdata, handles)
handles.hController.changeScanPhaseStepwise(1,false);

function pbDecScanPhaseFine_Callback(hObject, eventdata, handles)
handles.hController.changeScanPhaseStepwise(-1,true);

function pbIncScanPhaseFine_Callback(hObject, eventdata, handles)
handles.hController.changeScanPhaseStepwise(1,true);


%% Fill Frac Controls 

function etFillFrac_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);



%% Pockels Controls

function cbBlankFlyback_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);


function etFillFracAdjust_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);


%% Misc Controls

function etShutterDelay_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);



%% CREATE FCNS

% --- Executes during object creation, after setting all properties.
function etPixelsPerLine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixelsPerLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function configurationName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to configurationName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etShutterDelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etShutterDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etSamplesPerLine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etSamplesPerLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etPixelTimeMean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etPixelTimeMean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etBinFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etBinFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etFrameRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etFrameRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function pmMsPerLine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmMsPerLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etFramesPerFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etFramesPerFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etScanDelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etScanDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function pmFillFrac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmFillFrac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etMsPerLine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etMsPerLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etScanPhase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etScanPhase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function pmAIRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmAIRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function pmAORate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmAORate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etMsPerLineConfig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etMsPerLineConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etMinZoom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etMinZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etConfigZoomFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etConfigZoomFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etScanDelayConfig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etScanDelayConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function pmFillFracConfig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmFillFracConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etBaseZoom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etBaseZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etAcqDelayConfig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etAcqDelayConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etFillFracAdjust_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etFillFracAdjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etPixelTimeMaxMinRatio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etPixelTimeMaxMinRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function etFillFrac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etFillFrac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function etFillFracSpatial_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etFillFracSpatial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function etLinesPerFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etLinesPerFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function etLinePeriod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etLinePeriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function pmPixelsPerLine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmPixelsPerLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etFrameAcqFcnDecimationFactor_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function etFrameAcqFcnDecimationFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etFrameAcqFcnDecimationFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function etScanPhaseFine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etScanPhaseFine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in pnlScanPhaseDisplaySelect.
function pnlScanPhaseDisplaySelect_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in pnlScanPhaseDisplaySelect 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

if isequal(eventdata.NewValue,handles.rbScanPhaseHardware)
    handles.hController.scanPhaseDisplay = 'hardware';
elseif isequal(eventdata.NewValue,handles.rbScanPhaseSoftware)
    handles.hController.scanPhaseDisplay = 'software';
else
    assert(false);
end



function edit78_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);




% --- Executes during object creation, after setting all properties.
function edit78_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveScanPhaseMap.
function saveScanPhaseMap_Callback(hObject, eventdata, handles)
% hObject    handle to saveScanPhaseMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.xCorrScanPhase(false);

% --- Executes on button press in loadScanPhaseMap.
function loadScanPhaseMap_Callback(hObject, eventdata, handles)
% hObject    handle to loadScanPhaseMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.xCorrScanPhase(true);

% --- Executes on button press in checkbox29.
function checkbox29_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox29
handles.hController.updateModel(hObject,eventdata,handles);



function edit79_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function edit79_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function onTimeAdjust_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function onTimeAdjust_CreateFcn(hObject, eventdata, handles)
% hObject    handle to onTimeAdjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function timingAdjustPockels_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function timingAdjustPockels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timingAdjustPockels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in xCorrChannelChoise.
function xCorrChannelChoise_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function xCorrChannelChoise_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xCorrChannelChoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showMean.
function showMean_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);


function meanValueShow_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function meanValueShow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to meanValueShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxValueShow_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function maxValueShow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxValueShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in extClockEdge.
function extClockEdge_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);



function extClockLevel_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function extClockLevel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to extClockLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in betweenFrames.
function betweenFrames_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes on button press in autoconvert.
function autoconvert_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes on button press in savedBitdepth.
function savedBitdepth_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes on button press in checkbox35.
function checkbox35_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles); % autoscale

% --- Executes on button press in write2RAM.
function write2RAM_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);



% --- Executes on button press in focusSave.
function focusSave_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes on button press in offlineAveraging.
function offlineAveraging_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);
