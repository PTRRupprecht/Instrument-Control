function varargout = stackBrowserFeatureRecognitionOptions(varargin)
% STACKBROWSERFEATURERECOGNITIONOPTIONS M-file for stackBrowserFeatureRecognitionOptions.fig
%      STACKBROWSERFEATURERECOGNITIONOPTIONS, by itself, creates a new STACKBROWSERFEATURERECOGNITIONOPTIONS or raises the existing
%      singleton*.
%
%      H = STACKBROWSERFEATURERECOGNITIONOPTIONS returns the handle to a new STACKBROWSERFEATURERECOGNITIONOPTIONS or the handle to
%      the existing singleton*.
%
%      STACKBROWSERFEATURERECOGNITIONOPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STACKBROWSERFEATURERECOGNITIONOPTIONS.M with the given input arguments.
%
%      STACKBROWSERFEATURERECOGNITIONOPTIONS('Property','Value',...) creates a new STACKBROWSERFEATURERECOGNITIONOPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stackBrowserFeatureRecognitionOptions_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stackBrowserFeatureRecognitionOptions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stackBrowserFeatureRecognitionOptions
%JL113007A debug 
%JL113007B debug
%JL113007C debug
%JL113007D debug
% Last Modified by GUIDE v2.5 19-Oct-2004 15:40:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stackBrowserFeatureRecognitionOptions_OpeningFcn, ...
                   'gui_OutputFcn',  @stackBrowserFeatureRecognitionOptions_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% ------------------------------------------------------------------
% --- Executes just before stackBrowserFeatureRecognitionOptions is made visible.
function stackBrowserFeatureRecognitionOptions_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = stackBrowserFeatureRecognitionOptions_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

%NOTE: The main GUI's defaults take precedence over these (see genericStartFcn).
out = {
        'volumeDistanceFactor', 2, 'Class', 'Numeric', 'Gui', 'distanceFactor', ...
        'volumeDistanceMaskThreshold', [.6], 'Class', 'Array', 'Gui', 'distanceThreshold', ...
        'volumeDistanceMaskThresholdFactor', [0], 'Class', 'Array', 'Gui', 'distanceThresholdFactor', ...
        'volumeWeightDistanceMask', 1, 'Class', 'Numeric', 'Gui', 'distanceWeight', ...
        'volumeWeightEdgeMask', 1, 'Class', 'Numeric', 'Gui', 'edgeWeight', ...
        'volumeWeightProfileMask', 1, 'Class', 'Numeric', 'Gui', 'profileWeight', ...
        'volumeEdgeFilterStrength', 5, 'Class', 'Numeric', 'Gui', 'edgeFilterStrength', ...
        'volumeRegionSizeFactor', 2, 'Class', 'Numeric', 'Max', 2, 'Gui', 'regionSizeFactor', ...
        'volumeBinarizeDistanceMask', 0, 'Class', 'Numeric', 'Min', 0, 'Max', 1, 'Gui', 'binarizeDistanceMask', ...
        'volumeProfileRadiusFactor', 10, 'Class', 'Numeric', 'Gui', 'profileRadiusFactor', ...
        'volumeThresholdFactor', 0.1, 'Class', 'Numeric', 'Min', 0.01, 'Max', 0.7, 'Gui', 'thresholdFactor', 'Gui', 'thresholdFactorSlider', ...
        'volumeProfileCenterWeight', .5, 'Class', 'Numeric', 'Min', 0, 'Max', 1, 'Gui', 'profileCenterWeight', 'Gui', 'profileCenterWeightSlider', ...
        'volumeProfileThresholds', [1 2], 'Class', 'Array', 'Gui', 'profileThreshold', ...
        'volumeProfileValues', [1 .5], 'Class', 'Array', 'Gui', 'profileThresholdFactor', ...
        'volumeFrameWindow', 3, 'Class', 'Numeric', 'Min', 0, 'Gui', 'frameWindow', ...
        'volumeAutoSelectRegion', 1, 'Class', 'Numeric', 'Min', 0, 'Max', 1, 'Gui', 'autoSelectRegion', ...
        'volumeAutoScanFrames', 1, 'Class', 'Numeric', 'Min', 0, 'Max', 1, 'Gui', 'autoScanFrames', ...
        'volumeDisplayCalculations', 1, 'Class', 'Numeric', 'Min', 0, 'Max', 1, 'Gui', 'displayCalculations', ...
    };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

toggleGuiVisibility(progmanager, hObject, 'stackBrowserFeatureRecognitionOptions', 'Off');

setMain(progmanager, hObject, 'featureRecognitionOptionsObject', hObject);
% 
% localNames = getGUIVariableNames(progmanager, hObject);
% mainNames = getGUIVariableNames(progmanager, getMain(progmanager, hObject, 'hObject'));
% 
% for i = 1 : length(localNames)
%     if ismember(mainNames{i}, localNames)
%         %Copy over the setting from the main gui.
%         setLocal(progmanager, hObject, mainNames{i}, getMain(progmanager, hObject, mainNames{i}));
%     end
% end

updateEnable(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function version = getVersion(hObject, eventdata, handles)

version = 0.1;

return;

% ------------------------------------------------------------------
function genericSaveSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function updateMainProgramVariables(hObject, eventdata, handles)

localNames = getGUIVariableNames(progmanager, hObject);
mainNames = getGUIVariableNames(progmanager, getMain(progmanager, hObject, 'hObject'));

for i = 1 : length(localNames)
    if ismember(localNames{i}, mainNames)
        %Copy over the setting from the main gui.
        setMain(progmanager, hObject, localNames{i}, getLocal(progmanager, hObject, localNames{i}));
    end
end

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function distanceThresholdFactor_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function distanceThresholdFactor_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'distanceThresholdFactor', getLocal(progmanager, hObject, 'distanceThresholdFactor'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function distanceFactor_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function distanceFactor_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'distanceFactor', getLocal(progmanager, hObject, 'distanceFactor'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function distanceWeight_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function distanceWeight_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'distanceWeight', getLocal(progmanager, hObject, 'distanceWeight'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function edgeWeight_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function edgeWeight_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'edgeWeight', getLocal(progmanager, hObject, 'edgeWeight'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function profileWeight_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function profileWeight_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'profileWeight', getLocal(progmanager, hObject, 'profileWeight'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function edgeFilterStrength_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function edgeFilterStrength_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'edgeFilterStrength', getLocal(progmanager, hObject, 'edgeFilterStrength'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function regionSizeFactor_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function regionSizeFactor_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'regionSizeFactor', getLocal(progmanager, hObject, 'regionSizeFactor'));

return;

% ------------------------------------------------------------------
% --- Executes on button press in binarizeDistanceMask.
function binarizeDistanceMask_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'binarizeDistanceMask', getLocal(progmanager, hObject, 'binarizeDistanceMask'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function profileRadiusFactor_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function profileRadiusFactor_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'profileRadiusFactor', getLocal(progmanager, hObject, 'profileRadiusFactor'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function thresholdFactorSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
% --- Executes on slider movement.
function thresholdFactorSlider_Callback(hObject, eventdata, handles)

%JL113007A debug 
% ia_setOption(hObject, 'thresholdFactorSlider', getLocal(progmanager, hObject, 'thresholdFactorSlider'));
ia_setOption(hObject, 'volumeThresholdFactor', getLocal(progmanager, hObject, 'volumeThresholdFactor'));


return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function thresholdFactor_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function thresholdFactor_Callback(hObject, eventdata, handles)
%JL113007C debug 
ia_setOption(hObject, 'volumeThresholdFactor', getLocal(progmanager, hObject, 'volumeThresholdFactor'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function profileThreshold_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function profileThreshold_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'profileThreshold', getLocal(progmanager, hObject, 'profileThreshold'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function profileThresholdFactor_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function profileThresholdFactor_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'profileThresholdFactor', getLocal(progmanager, hObject, 'profileThresholdFactor'));


return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function profileCenterWeightSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
% --- Executes on slider movement.
function profileCenterWeightSlider_Callback(hObject, eventdata, handles)
%JL113007B debug
%ia_setOption(hObject, 'profileCenterWeightSlider', getLocal(progmanager, hObject, 'profileCenterWeightSlider'));
ia_setOption(hObject, 'volumeProfileCenterWeight', getLocal(progmanager, hObject, 'volumeProfileCenterWeight'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function profileCenterWeight_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function profileCenterWeight_Callback(hObject, eventdata, handles)
%JL113007D debug
% ia_setOption(hObject, 'profileCenterWeight', getLocal(progmanager, hObject, 'profileCenterWeight'));
ia_setOption(hObject, 'volumeProfileCenterWeight', getLocal(progmanager, hObject, 'volumeProfileCenterWeight'));
return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function distanceThreshold_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function distanceThreshold_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'distanceThreshold', getLocal(progmanager, hObject, 'distanceThreshold'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function frameWindow_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function frameWindow_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'frameWindow', getLocal(progmanager, hObject, 'frameWindow'));

return;

% ------------------------------------------------------------------
function autoSelectRegion_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'autoSelectRegion', getLocal(progmanager, hObject, 'autoSelectRegion'));
updateEnable(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function autoScanFrames_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'autoScanFrames', getLocal(progmanager, hObject, 'autoScanFrames'));
updateEnable(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function updateEnable(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'volumeAutoScanFrames')
    setLocalGh(progmanager, hObject, 'frameWindow', 'Enable', 'On');
else
    setLocalGh(progmanager, hObject, 'frameWindow', 'Enable', 'Off');
end

if getLocal(progmanager, hObject, 'volumeAutoSelectRegion')
    setLocalGh(progmanager, hObject, 'regionSizeFactor', 'Enable', 'On');
else
    setLocalGh(progmanager, hObject, 'regionSizeFactor', 'Enable', 'Off');
end

return;

% ------------------------------------------------------------------
function displayCalculations_Callback(hObject, eventdata, handles)

ia_setOption(hObject, 'displayCalculations', getLocal(progmanager, hObject, 'displayCalculations'));

return;