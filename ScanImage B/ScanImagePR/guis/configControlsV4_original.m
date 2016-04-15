function varargout = configControlsV4_original(varargin)
%CONFIGCONTROLSV4_ORIGINAL M-file for configControlsV4_original.fig
%      CONFIGCONTROLSV4_ORIGINAL, by itself, creates a new CONFIGCONTROLSV4_ORIGINAL or raises the existing
%      singleton*.
%
%      H = CONFIGCONTROLSV4_ORIGINAL returns the handle to a new CONFIGCONTROLSV4_ORIGINAL or the handle to
%      the existing singleton*.
%
%      CONFIGCONTROLSV4_ORIGINAL('Property','Value',...) creates a new CONFIGCONTROLSV4_ORIGINAL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to configControlsV4_original_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      CONFIGCONTROLSV4_ORIGINAL('CALLBACK') and CONFIGCONTROLSV4_ORIGINAL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in CONFIGCONTROLSV4_ORIGINAL.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help configControlsV4_original

% Last Modified by GUIDE v2.5 03-Jan-2011 15:14:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @configControlsV4_original_OpeningFcn, ...
                   'gui_OutputFcn',  @configControlsV4_original_OutputFcn, ...
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


% --- Executes just before configControlsV4_original is made visible.
function configControlsV4_original_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for configControlsV4_original
handles.output = hObject;

%Adding PropControls
handles.pcChannelConfig = most.gui.control.ColumnArrayTable(findobj(hObject,'Tag','tblChanConfig'));

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes configControlsV4_original wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = configControlsV4_original_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close configControls.
function configControls_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to configControls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);



function linesPerFrame_Callback(hObject, eventdata, handles)
% hObject    handle to linesPerFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of linesPerFrame as text
%        str2double(get(hObject,'String')) returns contents of linesPerFrame as a double


% --- Executes on selection change in pmPixelsPerLine.
function pmPixelsPerLine_Callback(hObject, eventdata, handles)
% hObject    handle to pmPixelsPerLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmPixelsPerLine contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmPixelsPerLine
handles.hController.updateModel(hObject,eventdata,handles);


function configurationName_Callback(hObject, eventdata, handles)
% hObject    handle to configurationName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of configurationName as text
%        str2double(get(hObject,'String')) returns contents of configurationName as a double


% --- Executes on button press in pbApplyConfig.
function pbApplyConfig_Callback(hObject, eventdata, handles)
% hObject    handle to pbApplyConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in pmScanMode.
function pmScanMode_Callback(hObject, eventdata, handles)
% hObject    handle to pmScanMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmScanMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmScanMode


% --- Executes on button press in pbSaveConfig.
function pbSaveConfig_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbLoadConfig.
function pbLoadConfig_Callback(hObject, eventdata, handles)
% hObject    handle to pbLoadConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbSaveConfigAs.
function pbSaveConfigAs_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveConfigAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cbDisableStriping.
function cbDisableStriping_Callback(hObject, eventdata, handles)
% hObject    handle to cbDisableStriping (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbDisableStriping


% --- Executes on button press in tbConfigChanged.
function tbConfigChanged_Callback(hObject, eventdata, handles)
% hObject    handle to tbConfigChanged (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbConfigChanged


% --- Executes on button press in tbShowAdvanced.
function tbShowAdvanced_Callback(hObject, eventdata, handles)
% hObject    handle to tbShowAdvanced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbShowAdvanced



function etShutterDelay_Callback(hObject, eventdata, handles)
% hObject    handle to etShutterDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etShutterDelay as text
%        str2double(get(hObject,'String')) returns contents of etShutterDelay as a double



function etBidiPhaseAlign_Callback(hObject, eventdata, handles)
% hObject    handle to etBidiPhaseAlign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etBidiPhaseAlign as text
%        str2double(get(hObject,'String')) returns contents of etBidiPhaseAlign as a double


% --- Executes when selected object is changed in uipanel22.
function uipanel22_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel22 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)



function fastScanAmplitude_Callback(hObject, eventdata, handles)
% hObject    handle to fastScanAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fastScanAmplitude as text
%        str2double(get(hObject,'String')) returns contents of fastScanAmplitude as a double



function slowScanAmplitude_Callback(hObject, eventdata, handles)
% hObject    handle to slowScanAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slowScanAmplitude as text
%        str2double(get(hObject,'String')) returns contents of slowScanAmplitude as a double


% --- Executes on button press in cbChanActive1.
function cbChanActive1_Callback(hObject, eventdata, handles)
% hObject    handle to cbChanActive1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbChanActive1


% --- Executes on selection change in pmChan1Range.
function pmChan1Range_Callback(hObject, eventdata, handles)
% hObject    handle to pmChan1Range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmChan1Range contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmChan1Range


% --- Executes during object creation, after setting all properties.
function pmChan1Range_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmChan1Range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbChanActive2.
function cbChanActive2_Callback(hObject, eventdata, handles)
% hObject    handle to cbChanActive2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbChanActive2


% --- Executes on selection change in popupmenu13.
function popupmenu13_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu13 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu13


% --- Executes during object creation, after setting all properties.
function popupmenu13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbBlankFlyback.
function cbBlankFlyback_Callback(hObject, eventdata, handles)
% hObject    handle to cbBlankFlyback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbBlankFlyback



function etFillFracAdjust_Callback(hObject, eventdata, handles)
% hObject    handle to etFillFracAdjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etFillFracAdjust as text
%        str2double(get(hObject,'String')) returns contents of etFillFracAdjust as a double


% --- Executes when entered data in editable cell(s) in tblChanConfig.
function tblChanConfig_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tblChanConfig (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
handles.hController.updateModel(hObject,eventdata,handles);
