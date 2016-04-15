function varargout = fastConfigurationV4(varargin)
% FASTCONFIGURATIONV4 MATLAB code for fastConfigurationV4.fig
%      FASTCONFIGURATIONV4, by itself, creates a new FASTCONFIGURATIONV4 or raises the existing
%      singleton*.
%
%      H = FASTCONFIGURATIONV4 returns the handle to a new FASTCONFIGURATIONV4 or the handle to
%      the existing singleton*.
%
%      FASTCONFIGURATIONV4('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FASTCONFIGURATIONV4.M with the given input arguments.
%
%      FASTCONFIGURATIONV4('Property','Value',...) creates a new FASTCONFIGURATIONV4 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fastConfigurationV4_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fastConfigurationV4_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fastConfigurationV4

% Last Modified by GUIDE v2.5 11-Jun-2011 01:32:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fastConfigurationV4_OpeningFcn, ...
                   'gui_OutputFcn',  @fastConfigurationV4_OutputFcn, ...
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

function fastConfigurationV4_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.pcFastCfgTable = most.gui.control.ColumnArrayTable(handles.tblFastConfig);
guidata(hObject, handles);

function varargout = fastConfigurationV4_OutputFcn(hObject, eventdata, handles)  %#ok<*INUSL>
varargout{1} = handles.output;

function tblFastConfig_CellEditCallback(hObject, eventdata, handles) %#ok<*DEFNU>
handles.hController.updateModel(hObject,eventdata,handles);

function pbBrowse1_Callback(hObject, eventdata, handles)
handles.hController.hModel.fastCfgSetConfigFile(1);

function pbBrowse2_Callback(hObject, eventdata, handles)
handles.hController.hModel.fastCfgSetConfigFile(2);

function pbBrowse3_Callback(hObject, eventdata, handles)
handles.hController.hModel.fastCfgSetConfigFile(3);

function pbBrowse4_Callback(hObject, eventdata, handles)
handles.hController.hModel.fastCfgSetConfigFile(4);

function pbBrowse5_Callback(hObject, eventdata, handles)
handles.hController.hModel.fastCfgSetConfigFile(5);

function pbBrowse6_Callback(hObject, eventdata, handles)
handles.hController.hModel.fastCfgSetConfigFile(6);

function pbRemove1_Callback(hObject, eventdata, handles)
handles.hController.hModel.fastCfgClearConfigFile(1);

function pbRemove2_Callback(hObject, eventdata, handles)
handles.hController.hModel.fastCfgClearConfigFile(2);

function pbRemove3_Callback(hObject, eventdata, handles)
handles.hController.hModel.fastCfgClearConfigFile(3);

function pbRemove4_Callback(hObject, eventdata, handles)
handles.hController.hModel.fastCfgClearConfigFile(4);

function pbRemove5_Callback(hObject, eventdata, handles)
handles.hController.hModel.fastCfgClearConfigFile(5);

function pbRemove6_Callback(hObject, eventdata, handles)
handles.hController.hModel.fastCfgClearConfigFile(6);

function pbSaveUSR_Callback(hObject, eventdata, handles)
handles.hController.hModel.usrSaveUsr();

% --------------------------------------------------------------------
function pbHelp_Callback(hObject, eventdata, handles)

helpString = [...
    'Fast Configurations allow loading a saved configuration (CFG) file with ' ...
    'one button -- either buttons on MAIN CONTROLS window or F1-F6 keys.' ...
    '\newline\newline' ...
    'To assign CFG file to Fast Config <1-6>, press corresponding ' ...
    'browse {\bf(...)} button, and then select file.' ...
    '\newline\newline' ...
    '{\bf  CFG Name:} Displays name of CFG file assigned to Fast Config <1-6>, if any. To recall path of file, select (...) and Cancel.' ...
    '\newline' ...
    '{\bf  AutoStart?:} If selected, pressing Fast Config button or F1-F6, will automaticaly start acquisition.\\' ...
    '\newline' ...
    '{\bf  AutoStart Type:} Specifies what type of acquisition is automatically started, when AutoStart is true.'...
    ];

msgbox(helpString,'FAST CONFIGURATIONS (Help)','help',struct('WindowStyle','modal','Interpreter','tex'));
