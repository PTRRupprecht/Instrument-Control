function varargout = userSettingsV4(varargin)
%USERSETTINGSV4 M-file for userSettingsV4.fig
%      USERSETTINGSV4, by itself, creates a new USERSETTINGSV4 or raises the existing
%      singleton*.
%
%      H = USERSETTINGSV4 returns the handle to a new USERSETTINGSV4 or the handle to
%      the existing singleton*.
%
%      USERSETTINGSV4('Property','Value',...) creates a new USERSETTINGSV4 using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to userSettingsV4_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      USERSETTINGSV4('CALLBACK') and USERSETTINGSV4('CALLBACK',hObject,...) call the
%      local function named CALLBACK in USERSETTINGSV4.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help userSettingsV4

% Last Modified by GUIDE v2.5 19-Apr-2011 18:58:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @userSettingsV4_OpeningFcn, ...
                   'gui_OutputFcn',  @userSettingsV4_OutputFcn, ...
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

function userSettingsV4_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
handles.output = hObject;
handles.pcCurrentUSRProps = most.gui.control.PropertyTable(handles.tblCurrentUsrProps);
set(handles.tblCurrentUsrProps,'UserData',handles.pcCurrentUSRProps); % xxx this does not get set automatically by Controller probably b/c there is no "propbinding"
most.gui.AdvancedPanelToggler.init(hObject,handles.tbShowAdvanced,19);

guidata(hObject, handles);

function varargout = userSettingsV4_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function tblCurrentUsrProps_CellEditCallback(hObject, eventdata, handles) %#ok<*DEFNU>
handles.hController.changeCurrentUsrProp(hObject,eventdata,handles);

function tbShowAdvanced_Callback(hObject, eventdata, handles) %#ok<*INUSD>
hFig = ancestor(hObject,'figure');
most.gui.AdvancedPanelToggler.toggle(hFig);

function tblSpecifyUsrProps_CellEditCallback(hObject, eventdata, handles)
handles.hController.specifyCurrentUsrProp(hObject,eventdata,handles);

function pbSelectAll_Callback(hObject, eventdata, handles)
data = get(handles.tblSpecifyUsrProps,'Data');
allConfigProps = data(:,1);
handles.hController.hModel.usrPropListCurrent = allConfigProps;

function pbClearAll_Callback(hObject,eventdata,handles)
handles.hController.hModel.usrPropListCurrent = cell(0,1);

function pbRestoreDefault_Callback(hObject, eventdata, handles)
handles.hController.hModel.usrPropListCurrent = handles.hController.hModel.usrPropListDefault;
