function varargout = pmtControlsV4(varargin)
% PMTCONTROLSV4 MATLAB code for pmtControlsV4.fig
%      PMTCONTROLSV4, by itself, creates a new PMTCONTROLSV4 or raises the existing
%      singleton*.
%
%      H = PMTCONTROLSV4 returns the handle to a new PMTCONTROLSV4 or the handle to
%      the existing singleton*.
%
%      PMTCONTROLSV4('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PMTCONTROLSV4.M with the given input arguments.
%
%      PMTCONTROLSV4('Property','Value',...) creates a new PMTCONTROLSV4 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pmtControlsV4_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pmtControlsV4_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pmtControlsV4

% Last Modified by GUIDE v2.5 13-Aug-2011 15:03:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pmtControlsV4_OpeningFcn, ...
                   'gui_OutputFcn',  @pmtControlsV4_OutputFcn, ...
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


% --- Executes just before pmtControlsV4 is made visible.
function pmtControlsV4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pmtControlsV4 (see VARARGIN)

% Choose default command line output for pmtControlsV4
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pmtControlsV4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pmtControlsV4_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function etPMTGain1_Callback(hObject, eventdata, handles)
% hObject    handle to etPMTGain1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etPMTGain1 as text
%        str2double(get(hObject,'String')) returns contents of etPMTGain1 as a double
handles.hController.changePMTGain(hObject,eventdata,1);

%handles.hModel.hPMT.pmtGain1 =  str2double(get(hObject,'String'));

% newVal = str2double(get(hObject,'String'));
% if ~isnan(newVal) && newVal > 0
%     handles.hModel.hPMT.pmtGain1 = newVal;
% else
%     set(hObject,'String',num2str(handles.hModel.hPMT.pmtGain1));
% end


function etPMTGain2_Callback(hObject, eventdata, handles)
% hObject    handle to etPMTGain2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etPMTGain2 as text
%        str2double(get(hObject,'String')) returns contents of etPMTGain2 as a double
handles.hController.changePMTGain(hObject,eventdata,2);

%handles.hModel.hPMT.pmtGain2 =  str2double(get(hObject,'String'));

% newVal = str2double(get(hObject,'String'));
% if ~isnan(newVal) && newVal > 0
%     handles.hModel.hPMT.pmtGain2 =  str2double(get(hObject,'String'));
% else
%     set(hObject,'String',num2str(handles.hModel.hPMT.pmtGain2));
% end



% --- Executes on button press in tbPMTEnable1.
function tbPMTEnable1_Callback(hObject, eventdata, handles)
% hObject    handle to tbPMTEnable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbPMTEnable1

handles.hModel.pmtEnable(1) = get(hObject,'Value');
% newVal = get(hObject,'Value');
% handles.hModel.hPMT.pmtEnable1 = newVal;


% --- Executes on button press in tbPMTEnable2.
function tbPMTEnable2_Callback(hObject, eventdata, handles)
% hObject    handle to tbPMTEnable2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbPMTEnable2
handles.hModel.pmtEnable(2) = get(hObject,'Value');

% newVal = get(hObject,'Value');
% handles.hModel.hPMT.pmtEnable2 = newVal;



%% CREATE FCNS
% --- Executes during object creation, after setting all properties.
function etPMTGain1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etPMTGain1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etPMTGain2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etPMTGain2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
