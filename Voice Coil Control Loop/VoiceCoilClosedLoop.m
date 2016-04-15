

function varargout = VoiceCoilClosedLoop(varargin)
% VOICECOILCLOSEDLOOP MATLAB code for VoiceCoilClosedLoop.fig
%      VOICECOILCLOSEDLOOP, by itself, creates a new VOICECOILCLOSEDLOOP or raises the existing
%      singleton*.
%
%      H = VOICECOILCLOSEDLOOP returns the handle to a new VOICECOILCLOSEDLOOP or the handle to
%      the existing singleton*.
%
%      VOICECOILCLOSEDLOOP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VOICECOILCLOSEDLOOP.M with the given input arguments.
%
%      VOICECOILCLOSEDLOOP('Property','Value',...) creates a new VOICECOILCLOSEDLOOP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VoiceCoilClosedLoop_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VoiceCoilClosedLoop_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VoiceCoilClosedLoop

% Last Modified by GUIDE v2.5 20-Oct-2015 17:27:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VoiceCoilClosedLoop_OpeningFcn, ...
                   'gui_OutputFcn',  @VoiceCoilClosedLoop_OutputFcn, ...
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


% --- Executes just before VoiceCoilClosedLoop is made visible.
function VoiceCoilClosedLoop_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VoiceCoilClosedLoop (see VARARGIN)

% Choose default command line output for VoiceCoilClosedLoop
handles.output = hObject;
handles.framerate = 29;
handles.nbplanes = 4;
handles.targetposition = 4.76;
handles.multiplicator = 0.3;
handles.oscilloscope = 0;
handles.offsetx = 0;
handles.openloop = 0;
handles.sub1 = [];
handles.sub2 = [];
handles.sub3 = [];
handles.sub4 = [];


set(handles.edit1,'string','4.76');
set(handles.edit2,'string','29');
set(handles.edit3,'string','4');
set(handles.edit4,'string','0.3');
set(handles.checkbox1,'Value',0);
set(handles.checkbox2,'Value',0);      
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes VoiceCoilClosedLoop wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VoiceCoilClosedLoop_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
temp = get(hObject,'String');
temp = str2double(temp);
if temp <= 5.3 && temp >= 1.8
    handles.targetposition = temp;
else
    set(handles.edit1,'string',num2str(handles.targetposition));
end
guidata(hObject,handles);


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



function edit2_Callback(hObject, eventdata, handles)
temp = get(hObject,'String');
temp = str2double(temp);
if temp <= 100 && temp >= 1
    handles.framerate = temp;
else
    set(handles.edit2,'string',num2str(handles.framerate));
end
guidata(hObject,handles);

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



function edit3_Callback(hObject, eventdata, handles)
temp = get(hObject,'String');
temp = str2double(temp);
if temp <= 20 && temp >= 1
    handles.nbplanes = temp;
else
    set(handles.edit3,'string',num2str(handles.nbplanes));
end
guidata(hObject,handles);

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



function edit4_Callback(hObject, eventdata, handles)
temp = get(hObject,'String');
temp = str2double(temp);
if temp <= 1 && temp >= 0.01
    handles.multiplicator = temp;
else
    set(handles.edit4,'string',num2str(handles.multiplicator));
end
guidata(hObject,handles);

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


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
handles.oscilloscope = get(hObject,'Value');
guidata(hObject,handles);

% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)

    if get(hObject,'Value')
        folderX = pwd;
        cd('C:\OldSystem\PetersCustomControl\');
        import dabs.ni.daqmx.*
        import most.*
        disp('Loading NI DAQmx drivers ...');
        try; ggTask.clear(); end
        try; PRvoiceCoil_sens.clear(); end
        try; diffPosition.clear(); end
        pause(2);
        cd(folderX);  
        ggTask = Task('PRVoice Coil Sense Task');
        PRvoiceCoil_sens = ggTask;
        PRvoiceCoil_sens.createAIVoltageChan('Dev3',[0 1],[],handles.targetposition-1,handles.targetposition+1);
        samplingrate = 1e4;
        diffPosition = Task('diffPosition');
        diffPosition.createAOVoltageChan('Dev3',[0]);

        cmdOutputRate = 1e2;
        numsamples = 2;
        
        set(handles.togglebutton1,'string','closed loop','BackGroundColor','white');    
        counter = 1;
        clear meaX offsetxoffsetx
        while get(hObject,'Value')
            try; PRvoiceCoil_sens.stop(); end
            nb_volumes = 1;
            
            PRvoiceCoil_sens.cfgSampClkTiming(samplingrate,'DAQmx_Val_FiniteSamps',round(samplingrate*nb_volumes*handles.nbplanes/handles.framerate));
            PRvoiceCoil_sens.start();
            pause(nb_volumes*handles.nbplanes/handles.framerate+0.01);

            A = PRvoiceCoil_sens.readAnalogData();
            B1 = A(:,1);%conv(A(:,1),fspecial('gaussian',[1 1],9),'valid');
            diffPosition.stop();
            diffPosition.cfgSampClkTiming(cmdOutputRate,'DAQmx_Val_FiniteSamps',numsamples);
            diffPosition.cfgOutputBuffer(numsamples);
            if ~handles.openloop
                handles.offsetx = handles.offsetx + (handles.targetposition - mean(A(:,1)))*handles.multiplicator; % proportionality constant !!!
                handles.offsetx = max(min(handles.offsetx,1),-1);
            end
            diffPosition.writeAnalogData(handles.offsetx*ones(numsamples,1),false);
            diffPosition.start();
            if handles.oscilloscope
                if any(get(0,'Children') == 31)
                    meaX(counter) = mean(A(:,1));
                    offsetxoffsetx(counter) = handles.offsetx;
                    range = max(1,counter-50):counter;
                    set(handles.sub1,'XData',(1:numel(B1))/10,'YData',B1);
                    set(handles.sub2,'XData',(1:numel(B1))/10,'YData',(B1-min(B1))/1.5*10*56);
                    set(handles.sub3,'XData',range*handles.nbplanes/handles.framerate,'YData',meaX(range)-handles.targetposition);
                    set(handles.sub4,'XData',range*handles.nbplanes/handles.framerate,'YData',offsetxoffsetx(range));
                else
                    figure(31); subplot(4,1,1); handles.sub1 = plot((1:numel(B1))/10,B1);axis([0 numel(B1)/10 min(B1) max(B1)]); grid on;
                    subplot(4,1,2); handles.sub2 = plot((1:numel(B1))/10,(B1-min(B1))/1.5*10*56);axis([0 numel(B1)/10 0 max((B1-min(B1))/1.5*10*56)]); grid on;
                    meaX(counter) = mean(A(:,1));
                    offsetxoffsetx(counter) = handles.offsetx;
                    range = max(1,counter-50):counter;
    %                 range = 1:counter;
                    subplot(4,1,4); handles.sub3 = plot(range*handles.nbplanes/handles.framerate,meaX(range)-handles.targetposition,'.'); xlabel('time [sec]'); ylabel('Error [V]'); % axis([range(1) range(end) handles.targetposition-0.1 handles.targetposition+0.1]);
                    subplot(4,1,3); handles.sub4 = plot(range*handles.nbplanes/handles.framerate,offsetxoffsetx(range),'.'); xlabel('time [sec]'); ylabel('Offset voltage [V]');
                end
                counter = counter + 1;
            end
            drawnow;
        end
        diffPosition.stop(); PRvoiceCoil_sens.stop();
        diffPosition.clear(); PRvoiceCoil_sens.clear();

        set(handles.togglebutton1,'string','close loop','BackGroundColor','yellow');  
    end
    guidata(hObject,handles);


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
handles.openloop = get(hObject,'Value');
guidata(hObject,handles);

% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2