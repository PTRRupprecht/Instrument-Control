function varargout = imageControlsV4(varargin)
%IMAGECONTROLSV4 M-file for imageControlsV4.fig
%      IMAGECONTROLSV4, by itself, creates a new IMAGECONTROLSV4 or raises the existing
%      singleton*.
%
%      H = IMAGECONTROLSV4 returns the handle to a new IMAGECONTROLSV4 or the handle to
%      the existing singleton*.
%
%      IMAGECONTROLSV4('Property','Value',...) creates a new IMAGECONTROLSV4 using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to imageControlsV4_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IMAGECONTROLSV4('CALLBACK') and IMAGECONTROLSV4('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IMAGECONTROLSV4.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imageControlsV4

% Last Modified by GUIDE v2.5 11-Aug-2014 23:44:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imageControlsV4_OpeningFcn, ...
                   'gui_OutputFcn',  @imageControlsV4_OutputFcn, ...
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


% --- Executes just before imageControlsV4 is made visible.
function imageControlsV4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for imageControlsV4
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imageControlsV4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = imageControlsV4_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function blackSlideChan2_Callback(hObject, eventdata, handles)
% hObject    handle to blackSlideChan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.hController.changeChannelsLUT(hObject,false,2);


% --- Executes during object creation, after setting all properties.
function blackSlideChan2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blackSlideChan2 (see GCBO)
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

handles.hController.changeChannelsLUT(hObject,false,2);

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


% --- Executes on slider movement.
function whiteSlideChan2_Callback(hObject, eventdata, handles)
% hObject    handle to whiteSlideChan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.hController.changeChannelsLUT(hObject,true,2);


% --- Executes during object creation, after setting all properties.
function whiteSlideChan2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to whiteSlideChan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function whiteEditChan2_Callback(hObject, eventdata, handles)
% hObject    handle to whiteEditChan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of whiteEditChan2 as text
%        str2double(get(hObject,'String')) returns contents of whiteEditChan2 as a double
handles.hController.changeChannelsLUT(hObject,true,2);


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



function currentPosX_Callback(hObject, eventdata, handles)
% hObject    handle to currentPosX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of currentPosX as text
%        str2double(get(hObject,'String')) returns contents of currentPosX as a double


% --- Executes during object creation, after setting all properties.
function currentPosX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentPosX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function currentPosY_Callback(hObject, eventdata, handles)
% hObject    handle to currentPosY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of currentPosY as text
%        str2double(get(hObject,'String')) returns contents of currentPosY as a double


% --- Executes during object creation, after setting all properties.
function currentPosY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentPosY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function intensity_Callback(hObject, eventdata, handles)
% hObject    handle to intensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of intensity as text
%        str2double(get(hObject,'String')) returns contents of intensity as a double


% --- Executes during object creation, after setting all properties.
function intensity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in zoom3.
function zoom3_Callback(hObject, eventdata, handles)
% hObject    handle to zoom3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in histogram1.
function histogram1_Callback(hObject, eventdata, handles)
% hObject    handle to histogram1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in imstats1.
function imstats1_Callback(hObject, eventdata, handles)
% hObject    handle to imstats1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in zoom2.
function zoom2_Callback(hObject, eventdata, handles)
% hObject    handle to zoom2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in zoom1.
function zoom1_Callback(hObject, eventdata, handles)
% hObject    handle to zoom1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in histogram2.
function histogram2_Callback(hObject, eventdata, handles)
% hObject    handle to histogram2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in imstats2.
function imstats2_Callback(hObject, eventdata, handles)
% hObject    handle to imstats2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in histogram3.
function histogram3_Callback(hObject, eventdata, handles)
% hObject    handle to histogram3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in imstats3.
function imstats3_Callback(hObject, eventdata, handles)
% hObject    handle to imstats3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in zoom4.
function zoom4_Callback(hObject, eventdata, handles)
% hObject    handle to zoom4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in histogram4.
function histogram4_Callback(hObject, eventdata, handles)
% hObject    handle to histogram4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in imstats4.
function imstats4_Callback(hObject, eventdata, handles)
% hObject    handle to imstats4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in tbAdvanced.
function tbAdvanced_Callback(hObject, eventdata, handles)
% hObject    handle to tbAdvanced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbAdvanced
toggleAdvancedPanel(hObject,12,'y');


% --- Executes on button press in imageBox.
function imageBox_Callback(hObject, eventdata, handles)
% hObject    handle to imageBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of imageBox


% --- Executes on button press in averageSamples.
function averageSamples_Callback(hObject, eventdata, handles)
% hObject    handle to averageSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of averageSamples


% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in imageColormap.
function imageColormap_Callback(hObject, eventdata, handles)
% hObject    handle to imageColormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns imageColormap contents as cell array
%        contents{get(hObject,'Value')} returns selected item from imageColormap


% --- Executes during object creation, after setting all properties.
function imageColormap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imageColormap (see GCBO)
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

%%% Image Tools

function tbZoom_Callback(hObject, eventdata, handles)
handles.hController.changeGUIToggleToolState(hObject,@zoom);

function tbDataTip_Callback(hObject, eventdata, handles)
handles.hController.changeGUIToggleToolState(hObject,@datacursormode);

function pbStats_Callback(hObject, eventdata, handles)
handles.hController.imageFunction('imageStats');

function pbHistogram_Callback(hObject, eventdata, handles)
handles.hController.imageFunction('imageHistogram');

function pmTargetFigure_Callback(hObject, eventdata, handles)
handles.hController.changeChannelsTargetDisplay(hObject);

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
handles.hController.changeChannelsLUT(hObject,false,3);


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
handles.hController.changeChannelsLUT(hObject,false,3);


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
handles.hController.changeChannelsLUT(hObject,true,3);


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
handles.hController.changeChannelsLUT(hObject,true,3);


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
function blackSlideChan4_Callback(hObject, eventdata, handles)
% hObject    handle to blackSlideChan4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.hController.changeChannelsLUT(hObject,false,4);

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
handles.hController.changeChannelsLUT(hObject,false,4);


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
handles.hController.changeChannelsLUT(hObject,true,4);


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
handles.hController.changeChannelsLUT(hObject,true,4);


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
handles.hController.changeChannelsLUT(hObject,false,1);


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
handles.hController.changeChannelsLUT(hObject,false,1);


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

handles.hController.changeChannelsLUT(hObject,true,1);

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
handles.hController.changeChannelsLUT(hObject,true,1);


% --- Executes during object creation, after setting all properties.
function whiteSlideChan1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to whiteSlideChan1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbLockRollAvg2AcqAvg.
function cbLockRollAvg2AcqAvg_Callback(hObject, eventdata, handles)
% hObject    handle to cbLockRollAvg2AcqAvg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbLockRollAvg2AcqAvg
handles.hController.updateModel(hObject,eventdata,handles);


function etRollingAverage_Callback(hObject, eventdata, handles)
% hObject    handle to etRollingAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etRollingAverage as text
%        str2double(get(hObject,'String')) returns contents of etRollingAverage as a double
handles.hController.updateModel(hObject,eventdata,handles);


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
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes on button press in cbLockFrameSel2RollAvg.
function cbLockFrameSel2RollAvg_Callback(hObject, eventdata, handles)
% hObject    handle to cbLockFrameSel2RollAvg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbLockFrameSel2RollAvg
handles.hController.updateModel(hObject,eventdata,handles);



function etFrameSelections_Callback(hObject, eventdata, handles)
% hObject    handle to etFrameSelections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etFrameSelections as text
%        str2double(get(hObject,'String')) returns contents of etFrameSelections as a double
handles.hController.updateModel(hObject,eventdata,handles);


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
handles.hController.updateModel(hObject,eventdata,handles);


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


% --------------------------------------------------------------------
function mnu_Settings_ShowCrosshair_Callback(hObject, eventdata, handles)
% hObject    handle to mnuShowCrosshair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggleCheckedMenu(hObject);
handles.hController.updateModel(hObject,eventdata,handles);

% --------------------------------------------------------------------
function mnu_Settings_SaveUserSettings_Callback(hObject, eventdata, handles)
% hObject    handle to mnuSaveUserSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.usrSaveUsr();

% --------------------------------------------------------------------
function mnu_Settings_SaveUserSettingsAs_Callback(hObject, eventdata, handles)
% hObject    handle to mnuSaveUserSettingsAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.usrSaveUsrAs();


function toggleCheckedMenu(hObject)
if strcmp(get(hObject,'Checked'),'on')
    set(hObject,'Checked','off'); 
else
    set(hObject,'Checked','on');
end

% --------------------------------------------------------------------
function mnu_Settings_ShowUserSettings_Callback(hObject, eventdata, handles)
% hObject    handle to mnuShowUserSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hController.showGUI('userSettingsV4');


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

%% CREATE FCNS

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
