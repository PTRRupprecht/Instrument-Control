function varargout = configurationControls(varargin)
%CONFIGURATIONCONTROLS M-file for configurationControls.fig
%      CONFIGURATIONCONTROLS, by itself, creates a new CONFIGURATIONCONTROLS or raises the existing
%      singleton*.
%
%      H = CONFIGURATIONCONTROLS returns the handle to a new CONFIGURATIONCONTROLS or the handle to
%      the existing singleton*.
%
%      CONFIGURATIONCONTROLS('Property','Value',...) creates a new CONFIGURATIONCONTROLS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to configurationControls_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      CONFIGURATIONCONTROLS('CALLBACK') and CONFIGURATIONCONTROLS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in CONFIGURATIONCONTROLS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help configurationControls

% Last Modified by GUIDE v2.5 21-Oct-2011 11:49:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @configurationControls_OpeningFcn, ...
                   'gui_OutputFcn',  @configurationControls_OutputFcn, ...
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


% --- Executes just before configurationControls is made visible.
function configurationControls_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for configurationControls
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes configurationControls wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = configurationControls_OutputFcn(hObject, eventdata, handles)
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



function linesPerFrame_Callback(hObject, eventdata, handles)
% hObject    handle to linesPerFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of linesPerFrame as text
%        str2double(get(hObject,'String')) returns contents of linesPerFrame as a double


% --- Executes during object creation, after setting all properties.
function linesPerFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linesPerFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pixelsPerLine.
function pixelsPerLine_Callback(hObject, eventdata, handles)
% hObject    handle to pixelsPerLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pixelsPerLine contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pixelsPerLine


% --- Executes during object creation, after setting all properties.
function pixelsPerLine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixelsPerLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function configurationName_Callback(hObject, eventdata, handles)
% hObject    handle to configurationName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of configurationName as text
%        str2double(get(hObject,'String')) returns contents of configurationName as a double


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


% --- Executes on button press in pbApplyConfig.
function pbApplyConfig_Callback(hObject, eventdata, handles)
% hObject    handle to pbApplyConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in tbShowAdvanced.
function tbShowAdvanced_Callback(hObject, eventdata, handles)
% hObject    handle to tbShowAdvanced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbShowAdvanced


% --- Executes on button press in cbBidirectionalScan.
function cbBidirectionalScan_Callback(hObject, eventdata, handles)
% hObject    handle to cbBidirectionalScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbBidirectionalScan



function etShutterDelay_Callback(hObject, eventdata, handles)
% hObject    handle to etShutterDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etShutterDelay as text
%        str2double(get(hObject,'String')) returns contents of etShutterDelay as a double


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



function etSamplesPerLine_Callback(hObject, eventdata, handles)
% hObject    handle to etSamplesPerLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etSamplesPerLine as text
%        str2double(get(hObject,'String')) returns contents of etSamplesPerLine as a double


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



function etPixelTime_Callback(hObject, eventdata, handles)
% hObject    handle to etPixelTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etPixelTime as text
%        str2double(get(hObject,'String')) returns contents of etPixelTime as a double


% --- Executes during object creation, after setting all properties.
function etPixelTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etPixelTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etBinFactor_Callback(hObject, eventdata, handles)
% hObject    handle to etBinFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etBinFactor as text
%        str2double(get(hObject,'String')) returns contents of etBinFactor as a double


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



function etFrameRate_Callback(hObject, eventdata, handles)
% hObject    handle to etFrameRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etFrameRate as text
%        str2double(get(hObject,'String')) returns contents of etFrameRate as a double


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


% --- Executes on selection change in pmMsPerLine.
function pmMsPerLine_Callback(hObject, eventdata, handles)
% hObject    handle to pmMsPerLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmMsPerLine contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmMsPerLine


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


% --- Executes on button press in cbFramesPerFileLock.
function cbFramesPerFileLock_Callback(hObject, eventdata, handles)
% hObject    handle to cbFramesPerFileLock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbFramesPerFileLock


% --- Executes on button press in cbAutoSave.
function cbAutoSave_Callback(hObject, eventdata, handles)
% hObject    handle to cbAutoSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbAutoSave



function etFramesPerFile_Callback(hObject, eventdata, handles)
% hObject    handle to etFramesPerFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etFramesPerFile as text
%        str2double(get(hObject,'String')) returns contents of etFramesPerFile as a double


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



function etScanDelay_Callback(hObject, eventdata, handles)
% hObject    handle to etScanDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etScanDelay as text
%        str2double(get(hObject,'String')) returns contents of etScanDelay as a double


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


% --- Executes on button press in cbFineAcqAdjust.
function cbFineAcqAdjust_Callback(hObject, eventdata, handles)
% hObject    handle to cbFineAcqAdjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbFineAcqAdjust


% --- Executes on button press in pbDecScanDelay.
function pbDecScanDelay_Callback(hObject, eventdata, handles)
% hObject    handle to pbDecScanDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbIncScanDelay.
function pbIncScanDelay_Callback(hObject, eventdata, handles)
% hObject    handle to pbIncScanDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbDecAcqDelay.
function pbDecAcqDelay_Callback(hObject, eventdata, handles)
% hObject    handle to pbDecAcqDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbIncAcqDelay.
function pbIncAcqDelay_Callback(hObject, eventdata, handles)
% hObject    handle to pbIncAcqDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in pmFillFrac.
function pmFillFrac_Callback(hObject, eventdata, handles)
% hObject    handle to pmFillFrac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmFillFrac contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmFillFrac


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



function etMsPerLine_Callback(hObject, eventdata, handles)
% hObject    handle to etMsPerLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etMsPerLine as text
%        str2double(get(hObject,'String')) returns contents of etMsPerLine as a double


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



function etAcqDelay_Callback(hObject, eventdata, handles)
% hObject    handle to etAcqDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etAcqDelay as text
%        str2double(get(hObject,'String')) returns contents of etAcqDelay as a double


% --- Executes during object creation, after setting all properties.
function etAcqDelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etAcqDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbStaircaseSlowDim.
function cbStaircaseSlowDim_Callback(hObject, eventdata, handles)
% hObject    handle to cbStaircaseSlowDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbStaircaseSlowDim


% --- Executes on button press in cbFlybackFinalLine.
function cbFlybackFinalLine_Callback(hObject, eventdata, handles)
% hObject    handle to cbFlybackFinalLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbFlybackFinalLine


% --- Executes on button press in cbDiscardFlybackLine.
function cbDiscardFlybackLine_Callback(hObject, eventdata, handles)
% hObject    handle to cbDiscardFlybackLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbDiscardFlybackLine


% --- Executes on selection change in pmAIRate.
function pmAIRate_Callback(hObject, eventdata, handles)
% hObject    handle to pmAIRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmAIRate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmAIRate


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


% --- Executes on selection change in pmAORate.
function pmAORate_Callback(hObject, eventdata, handles)
% hObject    handle to pmAORate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmAORate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmAORate


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


% --- Executes on button press in cbAutoAIRate.
function cbAutoAIRate_Callback(hObject, eventdata, handles)
% hObject    handle to cbAutoAIRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbAutoAIRate


% --- Executes on button press in cbAutoAORate.
function cbAutoAORate_Callback(hObject, eventdata, handles)
% hObject    handle to cbAutoAORate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbAutoAORate



function etMsPerLineConfig_Callback(hObject, eventdata, handles)
% hObject    handle to etMsPerLineConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etMsPerLineConfig as text
%        str2double(get(hObject,'String')) returns contents of etMsPerLineConfig as a double


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



function etMinZoom_Callback(hObject, eventdata, handles)
% hObject    handle to etMinZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etMinZoom as text
%        str2double(get(hObject,'String')) returns contents of etMinZoom as a double


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



function etConfigZoomFactor_Callback(hObject, eventdata, handles)
% hObject    handle to etConfigZoomFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etConfigZoomFactor as text
%        str2double(get(hObject,'String')) returns contents of etConfigZoomFactor as a double


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



function etScanDelayConfig_Callback(hObject, eventdata, handles)
% hObject    handle to etScanDelayConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etScanDelayConfig as text
%        str2double(get(hObject,'String')) returns contents of etScanDelayConfig as a double


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


% --- Executes on selection change in pmFillFracConfig.
function pmFillFracConfig_Callback(hObject, eventdata, handles)
% hObject    handle to pmFillFracConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmFillFracConfig contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmFillFracConfig


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


% --- Executes on button press in pbIncZoom.
function pbIncZoom_Callback(hObject, eventdata, handles)
% hObject    handle to pbIncZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbDecZoom.
function pbDecZoom_Callback(hObject, eventdata, handles)
% hObject    handle to pbDecZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function etBaseZoom_Callback(hObject, eventdata, handles)
% hObject    handle to etBaseZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etBaseZoom as text
%        str2double(get(hObject,'String')) returns contents of etBaseZoom as a double


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



function etAcqDelayConfig_Callback(hObject, eventdata, handles)
% hObject    handle to etAcqDelayConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etAcqDelayConfig as text
%        str2double(get(hObject,'String')) returns contents of etAcqDelayConfig as a double


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


% --- Executes on button press in pbAutoCompute.
function pbAutoCompute_Callback(hObject, eventdata, handles)
% hObject    handle to pbAutoCompute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in fastScanRadioX.
function fastScanRadioX_Callback(hObject, eventdata, handles)
% hObject    handle to fastScanRadioX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fastScanRadioX


% --- Executes on button press in fastScanRadioY.
function fastScanRadioY_Callback(hObject, eventdata, handles)
% hObject    handle to fastScanRadioY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fastScanRadioY


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
