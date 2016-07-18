function varargout = guigui(varargin)
% GUIGUI MATLAB code for guigui.fig
%      GUIGUI, by itself, creates a new GUIGUI or raises the existing
%      singleton*.
%
%      H = GUIGUI returns the handle to a new GUIGUI or the handle to
%      the existing singleton*.
%
%      GUIGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIGUI.M with the given input arguments.
%
%      GUIGUI('Property','Value',...) creates a new GUIGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guigui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guigui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guigui

% Last Modified by GUIDE v2.5 18-Jul-2016 17:37:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guigui_OpeningFcn, ...
                   'gui_OutputFcn',  @guigui_OutputFcn, ...
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


% --- Executes just before guigui is made visible.
function guigui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guigui (see VARARGIN)

% Choose default command line output for guigui
handles.output = hObject;
handles.cmdrate = 1e2;
handles.waveform4 = zeros(1000,4);
handles.channelX = 1;
handles.flowscaling = 5;
handles.stop = 0;
try
    fclose(instrfindall);
end
handles.pump1 = regloPump('COM5');

import dabs.ni.daqmx.*
import most.*
disp('Loading NI DAQmx drivers ...');
try; handles.TTLtrigger.clear(); end
pause(2);
handles.TTLtrigger = Task();
handles.TTLtrigger.createDOChan('Dev3','port0/line0');
handles.TTLtrigger.writeDigitalData(0);
handles.repeats = 1;
handles.waitingTime = 0;

set(handles.edit1,'string','5');
set(handles.edit2,'string','1');
set(handles.edit3,'string','0');
set(handles.edit4,'string','1');
set(handles.edit5,'string','0');

axes(handles.axes1);
co = [0    1    1
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840
        0    0.4470    0.7410];
set(gcf,'defaultAxesColorOrder',co);
plot((1:size(handles.waveform4,1))/handles.cmdrate,handles.waveform4(:,2:4));
xlabel('time [sec]');
ylabel('pump speed [mL/min]');


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guigui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guigui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
[FileName,PathName,~] = uigetfile('*.mat','Please select a pump waveform file');
load(strcat(PathName,FileName));strcat(PathName,FileName)
handles.waveform4 = waveform4*handles.flowscaling;
axes(handles.axes1) ;
co = [0    1    1
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840
        0    0.4470    0.7410];
set(gcf,'defaultAxesColorOrder',co);
plot((1:size(handles.waveform4,1))/handles.cmdrate,handles.waveform4(:,2:4));
xlabel('time [sec]');
ylabel('total flow rate [mL/min]');
guidata(hObject, handles);
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
handles.waveform4 = ones(300000,4)/4*handles.flowscaling;
axes(handles.axes1) ;
co = [0    1    1
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840
        0    0.4470    0.7410];
set(gcf,'defaultAxesColorOrder',co);
plot((1:size(handles.waveform4,1))/handles.cmdrate,handles.waveform4(:,2:4));
xlabel('time [sec]');
ylabel('total flow rate [mL/min]');
guidata(hObject, handles);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
if handles.pump1.direction(1) == 1
    for i = 1:4
        handles.pump1 = handles.pump1.setDirection(i,0);
        guidata(hObject, handles);
    end
else
    for i = 1:4
        handles.pump1 = handles.pump1.setDirection(i,1);
        guidata(hObject, handles);
    end
end

function edit1_Callback(hObject, eventdata, handles)
temp = handles.flowscaling;
XX = get(hObject,'String');
handles.flowscaling = str2double(XX);
handles.waveform4 = handles.waveform4/temp*handles.flowscaling;
axes(handles.axes1) ;
co = [0    1    1
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840
        0    0.4470    0.7410];
set(gcf,'defaultAxesColorOrder',co);
plot((1:size(handles.waveform4,1))/handles.cmdrate,handles.waveform4(:,2:4));
xlabel('time [sec]');
ylabel('total flow rate [mL/min]');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
handles.waveform4 = zeros(500,4);
handles.waveform4(:,handles.channelX) = handles.flowscaling;
axes(handles.axes1);
co = [0    1    1
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840
        0    0.4470    0.7410];
set(gcf,'defaultAxesColorOrder',co);
plot((1:size(handles.waveform4,1))/handles.cmdrate,handles.waveform4(:,2:4));
xlabel('time [sec]');
ylabel('total flow rate [mL/min]');

guidata(hObject, handles);

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
    % start timed loop with
    % a) TTL trigger
    % b) pump control with varying pump speed
    handles.TTLtrigger.writeDigitalData(0);
    pause(0.05);
    setappdata(get(hObject,'Parent'),'stop',0);

    handles.stop = 0;
    tic
    handles.TTLtrigger.writeDigitalData(1);
    TTL_level = 1;
    while toc < size(handles.waveform4,1)/handles.cmdrate && getappdata(get(hObject,'Parent'),'stop') == 0
        xx = toc;

        time_index = max(1,round(xx*handles.cmdrate));
        for i = 1:4
            rpm = handles.waveform4(time_index,i)/0.063;
            handles.pump1.setSpeed(i,rpm);
            handles.pump1.startChannel(i);
        end
        set(handles.edit3,'string',sprintf('%2.1f',round(10*xx)/10));
        if xx > 1 && TTL_level == 1
            handles.TTLtrigger.writeDigitalData(0);
            TTL_level = 0;
        end
        pause(0.01); % 
    end
    setappdata(get(hObject,'Parent'),'stop',1);
    handles.pump1.setSpeed(1,handles.flowscaling/0.063);
    for i = 2:4; handles.pump1.setSpeed(i,0); end
    handles.pump1.startChannel(1);
    guidata(hObject, handles);

function edit2_Callback(hObject, eventdata, handles)
temp = get(hObject,'String');
handles.channelX = str2double(temp);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
hardCodedPaths(1,handles,hObject);

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
hardCodedPaths(2,handles,hObject);

% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
hardCodedPaths(3,handles,hObject);

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
hardCodedPaths(4,handles,hObject);

% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
hardCodedPaths(5,handles,hObject);

% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
hardCodedPaths(6,handles,hObject);

function wf4 = hardCodedPaths(number,handles,hObject)
% ATablw = {'C:\OldSystem\RegloICC_PumpControl\pump control waveform\paradigm_91.mat',
%     'C:\OldSystem\RegloICC_PumpControl\pump control waveform\paradigm_92.mat',
%     'C:\OldSystem\RegloICC_PumpControl\pump control waveform\paradigm_93.mat',
%     'C:\OldSystem\RegloICC_PumpControl\pump control waveform\paradigm_94.mat',
%     'C:\OldSystem\RegloICC_PumpControl\pump control waveform\paradigm_95.mat',
%     'C:\OldSystem\RegloICC_PumpControl\pump control waveform\paradigm_96.mat'};
% ATablw = {'C:\OldSystem\RegloICC_PumpControl\pump control waveform\WaveformsMay2016\tuning02.mat',
%     'C:\OldSystem\RegloICC_PumpControl\pump control waveform\WaveformsMay2016\tuning03.mat',
%     'C:\OldSystem\RegloICC_PumpControl\pump control waveform\WaveformsMay2016\tuning04.mat',
%     'C:\OldSystem\RegloICC_PumpControl\pump control waveform\WaveformsMay2016\morphing_log_2to3.mat',
%     'C:\OldSystem\RegloICC_PumpControl\pump control waveform\WaveformsMay2016\morphing_log_3to2.mat',
%     'C:\OldSystem\RegloICC_PumpControl\pump control waveform\WaveformsMay2016\tuning_3steps.mat'};

ATablw = {'C:\OldSystem\RegloICC_PumpControl\pump control waveform\WaveformsJune2016\OdorLane2short.mat',
'C:\OldSystem\RegloICC_PumpControl\pump control waveform\WaveformsJune2016\OdorLane3short.mat',
'C:\OldSystem\RegloICC_PumpControl\pump control waveform\WaveformsJune2016\OdorLane4short.mat',
'C:\OldSystem\RegloICC_PumpControl\pump control waveform\WaveformsJune2016\OdorLane2long.mat',
'C:\OldSystem\RegloICC_PumpControl\pump control waveform\WaveformsJune2016\OdorLane3long.mat',
'C:\OldSystem\RegloICC_PumpControl\pump control waveform\WaveformsJune2016\OdorLane4long.mat'};

load(ATablw{number});
handles.waveform4 = waveform4*handles.flowscaling;
wf4 = waveform4*handles.flowscaling;
axes(handles.axes1) ;
co = [0    1    1
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840
        0    0.4470    0.7410];
set(gcf,'defaultAxesColorOrder',co);
plot((1:size(handles.waveform4,1))/handles.cmdrate,handles.waveform4(:,2:4));
xlabel('time [sec]');
ylabel('total flow rate [mL/min]');
guidata(hObject, handles);



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
setappdata(get(hObject,'Parent'),'stop',1);
handles.pump1.setSpeed(1,handles.flowscaling/0.063);
for i = 2:4; handles.pump1.setSpeed(i,0); end
handles.pump1.startChannel(1);
guidata(hObject, handles);


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
setappdata(get(hObject,'Parent'),'stop',1);
for i = 1:4; handles.pump1.setSpeed(i,0); end
guidata(hObject, handles);



function edit4_Callback(hObject, eventdata, handles)
temp = get(hObject,'String');
temp2 = textscan(temp,'%s');
clear tempX
for kk = 1:numel(temp2{1})
    tempX(kk) = min(max(str2double(temp2{1}{kk}),1),6);
end
handles.repeats = tempX;
set(handles.edit4,'string',num2str(handles.repeats));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
    % start timed loop with
    % a) TTL trigger
    % b) pump control with varying pump speed
    for k = 1:numel(handles.repeats)
        if k > 1
            pause(handles.waitingTime);
        end
        wf4 = hardCodedPaths(handles.repeats(k),handles,hObject);
        handles.TTLtrigger.writeDigitalData(0);
        pause(0.05);
        setappdata(get(hObject,'Parent'),'stop',0);
    
        handles.stop = 0;
        tic
        handles.TTLtrigger.writeDigitalData(1);
        TTL_level = 1;
        while toc < size(wf4,1)/handles.cmdrate && getappdata(get(hObject,'Parent'),'stop') == 0
            xx = toc;

            time_index = max(1,round(xx*handles.cmdrate));
            for i = 1:4
                rpm = wf4(time_index,i)/0.063;
                handles.pump1.setSpeed(i,rpm);
                handles.pump1.startChannel(i);
            end
            set(handles.edit3,'string',sprintf('%2.1f',round(10*xx)/10));
            if xx > 1 && TTL_level == 1
                handles.TTLtrigger.writeDigitalData(0);
                TTL_level = 0;
            end
            pause(0.01); % 
        end
        if xx + 0.5 < size(wf4,1)/handles.cmdrate
            break;
        end
    end
    setappdata(get(hObject,'Parent'),'stop',1);
    handles.pump1.setSpeed(1,handles.flowscaling/0.063);
    for i = 2:4; handles.pump1.setSpeed(i,0); end
    handles.pump1.startChannel(1);
    guidata(hObject, handles);



function edit5_Callback(hObject, eventdata, handles)
temp = get(hObject,'String');
handles.waitingTime = str2double(temp);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
