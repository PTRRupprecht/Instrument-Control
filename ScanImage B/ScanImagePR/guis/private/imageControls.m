function varargout = imageControls(varargin)
%IMAGECONTROLS M-file for imageControls.fig
%      IMAGECONTROLS, by itself, creates a new IMAGECONTROLS or raises the existing
%      singleton*.
%
%      H = IMAGECONTROLS returns the handle to a new IMAGECONTROLS or the handle to
%      the existing singleton*.
%
%      IMAGECONTROLS('Property','Value',...) creates a new IMAGECONTROLS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to imageControls_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IMAGECONTROLS('CALLBACK') and IMAGECONTROLS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IMAGECONTROLS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imageControls

% Last Modified by GUIDE v2.5 05-Dec-2011 14:15:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imageControls_OpeningFcn, ...
                   'gui_OutputFcn',  @imageControls_OutputFcn, ...
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


% --- Executes just before imageControls is made visible.
function imageControls_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for imageControls
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imageControls wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

% --- Outputs from this function are returned to the command line.
function varargout = imageControls_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in tbAdvanced.
function tbAdvanced_Callback(hObject, eventdata, handles)
% hObject    handle to tbAdvanced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbAdvanced


% --- Executes on button press in pbSaveUSR.
function pbSaveUSR_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveUSR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbGetPMTOffsets.
function pbGetPMTOffsets_Callback(hObject, eventdata, handles)
% hObject    handle to pbGetPMTOffsets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in pmImageColormap.
function pmImageColormap_Callback(hObject, eventdata, handles)
% hObject    handle to pmImageColormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmImageColormap contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmImageColormap


% --- Executes during object creation, after setting all properties.
function pmImageColormap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmImageColormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in applyColormap.
function applyColormap_Callback(hObject, eventdata, handles)
% hObject    handle to applyColormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cbLockRollAvg2AcqAvg.
function cbLockRollAvg2AcqAvg_Callback(hObject, eventdata, handles)
% hObject    handle to cbLockRollAvg2AcqAvg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbLockRollAvg2AcqAvg



function etRollingAverage_Callback(hObject, eventdata, handles)
% hObject    handle to etRollingAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etRollingAverage as text
%        str2double(get(hObject,'String')) returns contents of etRollingAverage as a double


% --- Executes during object creation, after setting all properties.
function etRollingAverage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etRollingAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbUseLastSelFrame.
function cbUseLastSelFrame_Callback(hObject, eventdata, handles)
% hObject    handle to cbUseLastSelFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbUseLastSelFrame


% --- Executes on button press in cbLockFrameSel2RollAvg.
function cbLockFrameSel2RollAvg_Callback(hObject, eventdata, handles)
% hObject    handle to cbLockFrameSel2RollAvg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbLockFrameSel2RollAvg



function etFrameSelections_Callback(hObject, eventdata, handles)
% hObject    handle to etFrameSelections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etFrameSelections as text
%        str2double(get(hObject,'String')) returns contents of etFrameSelections as a double


% --- Executes during object creation, after setting all properties.
function etFrameSelections_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etFrameSelections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etFrameSelFactor_Callback(hObject, eventdata, handles)
% hObject    handle to etFrameSelFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etFrameSelFactor as text
%        str2double(get(hObject,'String')) returns contents of etFrameSelFactor as a double


% --- Executes during object creation, after setting all properties.
function etFrameSelFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etFrameSelFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tbZoom.
function tbZoom_Callback(hObject, eventdata, handles)
% hObject    handle to tbZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbZoom


% --- Executes on button press in tbDataTip.
function tbDataTip_Callback(hObject, eventdata, handles)
% hObject    handle to tbDataTip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbDataTip


% --- Executes on button press in pbStats.
function pbStats_Callback(hObject, eventdata, handles)
% hObject    handle to pbStats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbHistogram.
function pbHistogram_Callback(hObject, eventdata, handles)
% hObject    handle to pbHistogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in pmTargetFigure.
function pmTargetFigure_Callback(hObject, eventdata, handles)
% hObject    handle to pmTargetFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmTargetFigure contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmTargetFigure


% --- Executes during object creation, after setting all properties.
function pmTargetFigure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmTargetFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function blackSlideChan3_Callback(hObject, eventdata, handles)
% hObject    handle to blackSlideChan3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function blackSlideChan3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blackSlideChan3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function blackEditChan3_Callback(hObject, eventdata, handles)
% hObject    handle to blackEditChan3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of blackEditChan3 as text
%        str2double(get(hObject,'String')) returns contents of blackEditChan3 as a double


% --- Executes during object creation, after setting all properties.
function blackEditChan3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blackEditChan3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function whiteSlideChan3_Callback(hObject, eventdata, handles)
% hObject    handle to whiteSlideChan3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function whiteSlideChan3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to whiteSlideChan3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function whiteEditChan3_Callback(hObject, eventdata, handles)
% hObject    handle to whiteEditChan3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of whiteEditChan3 as text
%        str2double(get(hObject,'String')) returns contents of whiteEditChan3 as a double


% --- Executes during object creation, after setting all properties.
function whiteEditChan3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to whiteEditChan3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function blackSlideChan2_Callback(hObject, eventdata, handles)
% hObject    handle to blackSlideChan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function blackSlideChan2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blackSlideChan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function whiteSlideChan2_Callback(hObject, eventdata, handles)
% hObject    handle to whiteSlideChan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function whiteSlideChan2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to whiteSlideChan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function blackEditChan2_Callback(hObject, eventdata, handles)
% hObject    handle to blackEditChan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of blackEditChan2 as text
%        str2double(get(hObject,'String')) returns contents of blackEditChan2 as a double


% --- Executes during object creation, after setting all properties.
function blackEditChan2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blackEditChan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function whiteEditChan2_Callback(hObject, eventdata, handles)
% hObject    handle to whiteEditChan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of whiteEditChan2 as text
%        str2double(get(hObject,'String')) returns contents of whiteEditChan2 as a double


% --- Executes during object creation, after setting all properties.
function whiteEditChan2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to whiteEditChan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function blackSlideChan4_Callback(hObject, eventdata, handles)
% hObject    handle to blackSlideChan4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function blackSlideChan4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blackSlideChan4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function blackEditChan4_Callback(hObject, eventdata, handles)
% hObject    handle to blackEditChan4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of blackEditChan4 as text
%        str2double(get(hObject,'String')) returns contents of blackEditChan4 as a double


% --- Executes during object creation, after setting all properties.
function blackEditChan4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blackEditChan4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function whiteSlideChan4_Callback(hObject, eventdata, handles)
% hObject    handle to whiteSlideChan4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function whiteSlideChan4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to whiteSlideChan4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function whiteEditChan4_Callback(hObject, eventdata, handles)
% hObject    handle to whiteEditChan4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of whiteEditChan4 as text
%        str2double(get(hObject,'String')) returns contents of whiteEditChan4 as a double


% --- Executes during object creation, after setting all properties.
function whiteEditChan4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to whiteEditChan4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function blackSlideChan1_Callback(hObject, eventdata, handles)
% hObject    handle to blackSlideChan1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function blackSlideChan1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blackSlideChan1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function blackEditChan1_Callback(hObject, eventdata, handles)
% hObject    handle to blackEditChan1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of blackEditChan1 as text
%        str2double(get(hObject,'String')) returns contents of blackEditChan1 as a double


% --- Executes during object creation, after setting all properties.
function blackEditChan1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blackEditChan1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function whiteEditChan1_Callback(hObject, eventdata, handles)
% hObject    handle to whiteEditChan1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of whiteEditChan1 as text
%        str2double(get(hObject,'String')) returns contents of whiteEditChan1 as a double


% --- Executes during object creation, after setting all properties.
function whiteEditChan1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to whiteEditChan1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function whiteSlideChan1_Callback(hObject, eventdata, handles)
% hObject    handle to whiteSlideChan1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function whiteSlideChan1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to whiteSlideChan1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function mnuSettings_Callback(hObject, eventdata, handles)
% hObject    handle to mnuSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuAverageSamples_Callback(hObject, eventdata, handles)
% hObject    handle to mnuAverageSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuShowCrosshair_Callback(hObject, eventdata, handles)
% hObject    handle to mnuShowCrosshair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuSaveUserSettings_Callback(hObject, eventdata, handles)
% hObject    handle to mnuSaveUserSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuSaveUserSettingsAs_Callback(hObject, eventdata, handles)
% hObject    handle to mnuSaveUserSettingsAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cbAverageSamples.
function cbAverageSamples_Callback(hObject, eventdata, handles)
% hObject    handle to cbAverageSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbAverageSamples


% --- Executes on button press in cbShowCrosshair.
function cbShowCrosshair_Callback(hObject, eventdata, handles)
% hObject    handle to cbShowCrosshair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbShowCrosshair


% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuPMTOffsets_Callback(hObject, eventdata, handles)
% hObject    handle to mnuPMTOffsets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuGetPMTOffsets_Callback(hObject, eventdata, handles)
% hObject    handle to mnuGetPMTOffsets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuShowPMTOffsets_Callback(hObject, eventdata, handles)
% hObject    handle to mnuShowPMTOffsets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuShowUserSettings_Callback(hObject, eventdata, handles)
% hObject    handle to mnuShowUserSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_Settings_AverageSamples_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_Settings_AverageSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_Settings_ShowCrosshair_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_Settings_ShowCrosshair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_Settings_SaveUserSettings_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_Settings_SaveUserSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_Settings_SaveUserSettingsAs_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_Settings_SaveUserSettingsAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_Settings_ShowUserSettings_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_Settings_ShowUserSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_PMTOffsets_GetPMTOffsets_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_PMTOffsets_GetPMTOffsets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_PMTOffsets_AutoRead_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_PMTOffsets_AutoRead (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_PMTOffsets_AutoSubtractChan1_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_PMTOffsets_AutoSubtractChan1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_PMTOffsets_AutoSubtractChan2_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_PMTOffsets_AutoSubtractChan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_PMTOffsets_AutoSubtractChan3_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_PMTOffsets_AutoSubtractChan3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnu_PMTOffsets_AutoSubtractChan4_Callback(hObject, eventdata, handles)
% hObject    handle to mnu_PMTOffsets_AutoSubtractChan4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
