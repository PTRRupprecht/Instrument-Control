function varargout = channelControlsV4test(varargin)
% CHANNELCONTROLSV4TEST MATLAB code for channelControlsV4test.fig
%      CHANNELCONTROLSV4TEST, by itself, creates a new CHANNELCONTROLSV4TEST or raises the existing
%      singleton*.
%
%      H = CHANNELCONTROLSV4TEST returns the handle to a new CHANNELCONTROLSV4TEST or the handle to
%      the existing singleton*.
%
%      CHANNELCONTROLSV4TEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHANNELCONTROLSV4TEST.M with the given input arguments.
%
%      CHANNELCONTROLSV4TEST('Property','Value',...) creates a new CHANNELCONTROLSV4TEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before channelControlsV4test_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to channelControlsV4test_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help channelControlsV4test

% Last Modified by GUIDE v2.5 07-Oct-2014 19:18:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @channelControlsV4test_OpeningFcn, ...
                   'gui_OutputFcn',  @channelControlsV4test_OutputFcn, ...
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


% --- Executes just before channelControlsV4test is made visible.
function channelControlsV4test_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to channelControlsV4test (see VARARGIN)

% Choose default command line output for channelControlsV4test
handles.output = hObject;

%Adding PropControls
handles.pcChannelConfig = most.gui.control.ColumnArrayTable(findobj(hObject,'Tag','tblChanConfig'),'Channel %d');

% initialize pmImageColorMap and colormaps in table
prettyColorMapSpecs = scanimage.ChannelImageHandler.prettyColorMapSpecs;
set(handles.pmImageColormap,'String',[prettyColorMapSpecs(:);{'Custom'}]);
set(handles.pmImageColormap,'Value',1);
handles.channelImageHandler = scanimage.ChannelImageHandler(handles.pcChannelConfig,handles.tblChanConfig);
handles.channelImageHandler.initColorMapsInTable();

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes channelControlsV4test wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = channelControlsV4test_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pbSaveCfg.
function pbSaveCfg_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveCfg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.cfgSaveConfig();

% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1


function cbMergeEnable_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

function cbChannelsMergeFocusOnly_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

% --- Executes on button press in pbSaveUSR.
function pbSaveUSR_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveUSR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.usrSaveUsr();

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

chanIdx = eventdata.Indices(1);
colIdx = eventdata.Indices(2);
switch colIdx
    case 1
        handles.hController.channelsSave2(hObject,eventdata,handles);
    case 2 % PR2014 workaround
        handles.hController.channelsDisplay(hObject,eventdata,handles);
    case 3
        
        %TODO: eliminate this special case handling!
        %TODO: Handle popup menu...
        
        newVal = eventdata.NewData;
        if ~isempty(newVal)
            try
                newVal = str2num(newVal);
                handles.hModel.channelsInputRange{chanIdx} = newVal;
            catch ME
                most.idioms.reportError(ME);
                data = get(hObject,'Data');
                indicesList = num2cell(eventdata.Indices);
                data{indicesList{:}} = eventdata.PreviousData;
                set(hObject,'Data',data);
            end
        end
    case 7
        handles.channelImageHandler.applyTableColorMapsToImageFigs();
    otherwise
        handles.hController.updateModel(hObject,eventdata,handles);
end

function pmImageColormap_Callback(hObject, eventdata, handles)
strs = get(hObject,'String');
val = get(hObject,'Value');
handles.channelImageHandler.updateTable(strs{val});
handles.channelImageHandler.applyTableColorMapsToImageFigs();


% --- Executes on button press in pbReadOffsets.
function pbReadOffsets_Callback(hObject, eventdata, handles)
% hObject    handle to pbReadOffsets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.channelsReadOffsets();

% --- Executes on button press in cbAutoReadOffsets.
function cbAutoReadOffsets_Callback(hObject, eventdata, handles)
% hObject    handle to cbAutoReadOffsets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbAutoReadOffsets
handles.hController.updateModel(hObject,eventdata,handles);


% --- Executes when selected cell(s) is changed in tblChanConfig.
function tblChanConfig_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to tblChanConfig (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function tblChanConfig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tblChanConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
