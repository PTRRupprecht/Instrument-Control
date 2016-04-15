function varargout = posnControlsV4(varargin)
%POSNCONTROLSV4 M-file for posnControlsV4.fig

% Edit the above text to modify the response to help posnControlsV4

% Last Modified by GUIDE v2.5 19-Oct-2011 19:48:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @posnControlsV4_OpeningFcn, ...
                   'gui_OutputFcn',  @posnControlsV4_OutputFcn, ...
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

function posnControlsV4_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

function varargout = posnControlsV4_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


function etPositionNumber_Callback(hObject, eventdata, handles)
posnIdx = str2double(get(hObject,'String'));
try
    handles.hController.motorUserPositionIndex = posnIdx;
catch %#ok<*CTCH>
    set(hObject,'String',num2str(handles.hController.motorUserPositionIndex));
end
        
function sldPositionNumber_Callback(hObject, eventdata, handles)
posnIdx = get(hObject,'Value');
try
    handles.hController.motorUserPositionIndex = posnIdx;
catch %#ok<*CTCH>
    set(hObject,'Value',handles.hController.motorUserPositionIndex);
end

function pbSavePositionList_Callback(hObject, eventdata, handles)
handles.hModel.motorSaveUserDefinedPositions;

function pbLoadPositionList_Callback(hObject, eventdata, handles)
handles.hController.motorLoadUserPositions(handles);

function pbDefinePosition_Callback(hObject, eventdata, handles)
handles.hController.motorDefineUserPositionAndIncrement();

function pbGotoPosition_Callback(hObject, eventdata, handles)
handles.hController.motorGotoUserPosition();

function pbShiftXY_Callback(hObject, eventdata, handles)
%TODO

function pbShiftXYZ_Callback(hObject, eventdata, handles)
%TODO
