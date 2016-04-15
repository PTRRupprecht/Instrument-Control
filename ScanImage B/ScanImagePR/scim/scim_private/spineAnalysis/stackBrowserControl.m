function varargout = stackBrowserControl(varargin)
% STACKBROWSERCONTROL M-file for stackBrowserControl.fig
%      STACKBROWSERCONTROL, by itself, creates a new STACKBROWSERCONTROL or raises the existing
%      singleton*.
%
%      H = STACKBROWSERCONTROL returns the handle to a new STACKBROWSERCONTROL or the handle to
%      the existing singleton*.
%
%      STACKBROWSERCONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STACKBROWSERCONTROL.M with the given input arguments.
%
%      STACKBROWSERCONTROL('Property','Value',...) creates a new STACKBROWSERCONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stackBrowserControl_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stackBrowserControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stackBrowserControl

% Last Modified by GUIDE v2.5 23-Dec-2004 15:37:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stackBrowserControl_OpeningFcn, ...
                   'gui_OutputFcn',  @stackBrowserControl_OutputFcn, ...
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


% --- Executes just before stackBrowserControl is made visible.
function stackBrowserControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stackBrowserControl (see VARARGIN)

% Choose default command line output for stackBrowserControl
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes stackBrowserControl wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = stackBrowserControl_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'trackingLocked', 0, 'Class', 'Numeric', 'Gui', 'roiLockCheckbox', ...
       'framesLocked', 0, 'Class', 'Numeric', 'Gui', 'frameLockCheckbox', ...
       'trackDown', @trackDown, ...
       'trackUp', @trackUp, ...
       'trackRight', @trackRight, ...
       'trackLeft', @trackLeft, ...
       'windowCounter', 0, 'Class', 'Numeric', ...
       'windowNames', {}, 'Class', 'cell', ...
       'displayUpdateCallbacks', {}, 'Class', 'cell', ...
       'hObject', [], ...
       'frameChange', @frameChange, ...
       'subPrograms', {}, ...
       'analysisFilePath', matlabroot, ...
       'fileLoadedFcn', @fileLoadedFcn, ...
       'annotationAddedFcn', @annotationAddedFcn, ...
       'annotationDeletedFcn', @annotationDeletedFcn, ...
       'annotationAddedDuringCorrelation', @annotationAddedDuringCorrelation, ...
       'nextCorrelationId', 1, 'Gui', 'nextCorrelationId', 'Class', 'Numeric', ...
       'lastGUID', 1, ...
       'drawingMode', 0, ...
       'browserCloseEvent', @browserCloseEvent, ...
       'persistentData', {}, ...
       'filePath', fullfile(matlabroot, 'work'), ...
       'fileName', '', ...
       'saveMenuItem_Callback', @saveMenuItem_Callback, ...
       'saveMenuAsItem_Callback', @saveMenuAsItem_Callback, ...
       'loadMenuItem_Callback', @loadMenuItem_Callback, ...
       'loadFromMenuItem_Callback', @loadFromMenuItem_Callback, ...
       'summaryTable', [], ...
       'optionsObject', [], ...
       'displayOptionsObject', [], ...
       'featureRecognitionOptionsObject', [], ...
       'defaultZoom', 1, 'Class', 'Numeric', 'Gui', 'defaultZoom', 'Min', 0, ...
       'defaultFilter', 'median', 'Class', 'char', 'Gui', 'defaultFilter', ...
       'expandWindowButton', 0, 'Class', 'Numeric', 'Gui', 'expandWindowButton', ...
       'xConversionFactor', 1, 'Class', 'Numeric', ...
       'xUnits', 'Pixels', 'Class', 'Char', ...
       'yConversionFactor', 1, 'Class', 'Numeric', ...
       'yUnits', 'Pixels', 'Class', 'Char', ...
       'zConversionFactor', 1, 'Class', 'Numeric', ...
       'zUnits', 'Pixels', 'Class', 'Char', ...
       'zoomsLocked', 0, 'Class', 'Numeric', 'Gui', 'zoomLockCheckbox', ...
       'changesMadeSinceLastSave', 0, ...
       'multichannelPhotometryData', 0, ...
   };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'hObject', hObject);

setLocalGh(progmanager, hObject, 'defaultFilter', 'String', {'median', 'none', 'wiener', 'sobel', 'gaussian', 'prewitt', 'laplacian', 'log', 'unsharp'});
setLocal(progmanager, hObject, 'defaultFilter', 'median');

% newWindowButton_Callback(hObject, eventdata, handles);

% makeGenericallyResizeable(get(getLocalGh(progmanager, hObject, 'newWindowButton'), 'Parent'));

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

%Close down all subprograms.
programs = getLocal(progmanager, hObject, 'subPrograms');

if isempty(programs)
    return;
end

for i = 1 : length(programs)
    if isstarted(progmanager, programs{i})
        try
            closeprogram(progmanager, programs{i});
        catch
            warning('Error closing subprogram ''%s'' - %s', get(programs{i}, 'program_name'), lasterr);
        end
    end
end

summaryTable = getLocal(progmanager, hObject, 'summaryTable');
programRunning = 1;
if isempty(summaryTable)
    programRunning = 0;
else
    if ~isstarted(progmanager, summaryTable)
        programRunning = 0;
    end
end
if programRunning
    try
        closeprogram(progmanager, summaryTable);
    catch
        warning('Error closing subprogram ''Summary Table'' - %s', lasterr);
    end
end

return;

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.1;

return;

% ------------------------------------------------------------------
function genericSaveSettings(hObject, eventdata, handles)

return;

% --------------------------------------------------------------------
function roiLockCheckbox_Callback(hObject, eventdata, handles)

return;

% --------------------------------------------------------------------
% --- Executes on button press in newWindowButton.
function newWindowButton_Callback(hObject, eventdata, handles)

windowCounter = getLocal(progmanager, hObject, 'windowCounter') + 1;
windowName = ['s' num2str(windowCounter) '_StackBrowser'];
programs = getLocal(progmanager, hObject, 'subPrograms');

p = program(windowName, 'stackBrowser', 'stackBrowser', 'annotationWindow', 'annotationWindow', ...
    'stackBrowserUnits', 'stackBrowserUnits', 'photometry', 'photometry');

openprogram(progmanager, p);

programs{length(programs) + 1} = p;
setLocal(progmanager, hObject, 'subPrograms', programs);

windowNames = getLocal(progmanager, hObject, 'windowNames');
windowNames{length(windowNames) + 1} = windowName;

setLocal(progmanager, hObject, 'windowCounter', windowCounter);
setLocal(progmanager, hObject, 'windowNames', windowNames);
setLocal(progmanager, hObject, 'hObject', hObject);

p = program('AnnotationCorrelator', 'annotationCorrelator', 'annotationCorrelator');
if isstarted(progmanager, p)
    feval(getGlobal(progmanager, 'setObjects', 'annotationCorrelator', 'AnnotationCorrelator'), ...
        getGlobal(progmanager, 'hObject', 'annotationCorrelator', 'AnnotationCorrelator'));
end

return;

% --------------------------------------------------------------------
function validateProgramList(hObject, varargin)

windowNames = getLocal(progmanager, hObject, 'windowNames');
wN = {};

for i = 1 : length(windowNames)
    if isstarted(progmanager, windowNames{i})
        wN{length(wN) + 1} = windowNames{i};
    end
end

setLocal(progmanager, hObject, 'windowNames', wN);

return;

% --------------------------------------------------------------------
function tileMenuItem_Callback(hObject, eventdata, handles)

validateProgramList(hObject);

windowNames = getLocal(progmanager, hObject, 'windowNames');

xOffset = 5;
yOffset = 5;

for i = 1 : length(windowNames)
    f = getGlobalFigure(progmanager, windowNames{i}, 'stackBrowser');
    
    pos = get(f, 'Position');
    pos(1) = xOffset * i;
    pos(2) = 5 + yOffset * (length(windowNames) - i);
    
    set(f, 'Position', pos);
end

% --------------------------------------------------------------------
function trackDown(hObject, stepSize)

windowNames = getLocal(progmanager, hObject, 'windowNames');
programs = getLocal(progmanager, hObject, 'subPrograms');

for i = 1 : length(windowNames)
    if ~strcmpi(get(programs{i}, 'program_name'), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
        setGlobal(progmanager, 'yBoundLow', 'stackBrowser', windowNames{i}, ...
            getGlobal(progmanager, 'yBoundLow', 'stackBrowser', windowNames{i}) - stepSize);
        
        setGlobal(progmanager, 'yBoundHigh', 'stackBrowser', windowNames{i}, ...
            getGlobal(progmanager, 'yBoundHigh', 'stackBrowser', windowNames{i}) - stepSize);
        
        feval(getGlobal(progmanager, 'updateImageDisplay', 'stackBrowser', windowNames{i}), ...
            getGlobal(progmanager, 'hObject', 'stackBrowser', windowNames{i}));
    end
end

return;

% --------------------------------------------------------------------
function trackUp(hObject, stepSize)

windowNames = getLocal(progmanager, hObject, 'windowNames');
programs = getLocal(progmanager, hObject, 'subPrograms');

for i = 1 : length(windowNames)
    if ~strcmpi(get(programs{i}, 'program_name'), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
        setGlobal(progmanager, 'yBoundLow', 'stackBrowser', windowNames{i}, ...
            getGlobal(progmanager, 'yBoundLow', 'stackBrowser', windowNames{i}) + stepSize);
        
        setGlobal(progmanager, 'yBoundHigh', 'stackBrowser', windowNames{i}, ...
            getGlobal(progmanager, 'yBoundHigh', 'stackBrowser', windowNames{i}) + stepSize);
        
        feval(getGlobal(progmanager, 'updateImageDisplay', 'stackBrowser', windowNames{i}), ...
            getGlobal(progmanager, 'hObject', 'stackBrowser', windowNames{i}));
    end
end

return;

% --------------------------------------------------------------------
function trackRight(hObject, stepSize)

windowNames = getLocal(progmanager, hObject, 'windowNames');
programs = getLocal(progmanager, hObject, 'subPrograms');

for i = 1 : length(windowNames)
    if ~strcmpi(get(programs{i}, 'program_name'), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
        setGlobal(progmanager, 'xBoundLow', 'stackBrowser', windowNames{i}, ...
            getGlobal(progmanager, 'xBoundLow', 'stackBrowser', windowNames{i}) + stepSize);
        
        setGlobal(progmanager, 'xBoundHigh', 'stackBrowser', windowNames{i}, ...
            getGlobal(progmanager, 'xBoundHigh', 'stackBrowser', windowNames{i}) + stepSize);
        
        feval(getGlobal(progmanager, 'updateImageDisplay', 'stackBrowser', windowNames{i}), ...
            getGlobal(progmanager, 'hObject', 'stackBrowser', windowNames{i}));
    end
end

return;

% --------------------------------------------------------------------
function trackLeft(hObject, stepSize)

windowNames = getLocal(progmanager, hObject, 'windowNames');
programs = getLocal(progmanager, hObject, 'subPrograms');

for i = 1 : length(windowNames)
    if ~strcmpi(get(programs{i}, 'program_name'), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
        setGlobal(progmanager, 'xBoundLow', 'stackBrowser', windowNames{i}, ...
            getGlobal(progmanager, 'xBoundLow', 'stackBrowser', windowNames{i}) - stepSize);
        
        setGlobal(progmanager, 'xBoundHigh', 'stackBrowser', windowNames{i}, ...
            getGlobal(progmanager, 'xBoundHigh', 'stackBrowser', windowNames{i}) - stepSize);
        
        feval(getGlobal(progmanager, 'updateImageDisplay', 'stackBrowser', windowNames{i}), ...
            getGlobal(progmanager, 'hObject', 'stackBrowser', windowNames{i}));
    end
end

return;

% --------------------------------------------------------------------
% --- Executes on button press in frameLockCheckbox.
function frameLockCheckbox_Callback(hObject, eventdata, handles)

return;

% --------------------------------------------------------------------
function frameChange(hObject, stepSize)

if stepSize == 0
    return;
end

windowNames = getLocal(progmanager, hObject, 'windowNames');
programs = getLocal(progmanager, hObject, 'subPrograms');

for i = 1 : length(windowNames)
    if ~strcmpi(get(programs{i}, 'program_name'), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
        setGlobal(progmanager, 'frameNumber', 'stackBrowser', windowNames{i}, ...
            getGlobal(progmanager, 'frameNumber', 'stackBrowser', windowNames{i}) + stepSize);
        
        feval(getGlobal(progmanager, 'displayNewImage', 'stackBrowser', windowNames{i}), ...
            getGlobal(progmanager, 'hObject', 'stackBrowser', windowNames{i}));
    end
end

return;

% --------------------------------------------------------------------
% --- Executes on button press in correlateAnnotations.
function correlateAnnotations_Callback(hObject, eventdata, handles)

p = program('AnnotationCorrelator', 'annotationCorrelator', 'annotationCorrelator');

if ~isstarted(progmanager, p)
    programs = getLocal(progmanager, hObject, 'subPrograms');
    
    openprogram(progmanager, p);

    programs{length(programs) + 1} = p;
    setLocal(progmanager, hObject, 'subPrograms', programs);

    windowNames = getLocal(progmanager, hObject, 'windowNames');
    windowNames{length(windowNames) + 1} = 'AnnotationCorrelator';

    setLocal(progmanager, hObject, 'windowNames', windowNames);
    setLocal(progmanager, hObject, 'hObject', hObject);
end

return;

% --------------------------------------------------------------------
function fileLoadedFcn(hObject, varargin)

windowNames = getLocal(progmanager, hObject, 'windowNames');
programs = getLocal(progmanager, hObject, 'subPrograms');

for i = 1 : length(windowNames)
    if strcmpi(get(programs{i}, 'program_name'), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
        feval(getGlobal(progmanager, 'setObjects', 'annotationCorrelator', windowNames{i}), ...
            getGlobal(progmanager, 'hObject', 'annotationCorrelator', windowNames{i}));
    end
end

return;

% --------------------------------------------------------------------
function annotationAddedFcn(hObject, varargin)

windowObj = [];
for i = 1 : length(varargin)
    if ishandle(varargin{i})
        windowObj = varargin{i};
        break;
    end
end

windowNames = getLocal(progmanager, hObject, 'windowNames');
programs = getLocal(progmanager, hObject, 'subPrograms');

for i = 1 : length(windowNames)
    if strcmpi(get(programs{i}, 'program_name'), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
        feval(getGlobal(progmanager, 'annotationAddedDuringCorrelation', 'annotationCorrelator', windowNames{i}), ...
            getGlobal(progmanager, 'hObject', 'annotationCorrelator', windowNames{i}), windowObj);
    end
end

populateSummaryTable(hObject);
setLocal(progmanager, hObject, 'changesMadeSinceLastSave', 1);

return;

% --------------------------------------------------------------------
function annotationDeletedFcn(hObject, varargin)

windowObj = [];
for i = 1 : length(varargin)
    if ishandle(varargin{i})
        windowObj = varargin{i};
        break;
    end
end

windowNames = getLocal(progmanager, hObject, 'windowNames');
programs = getLocal(progmanager, hObject, 'subPrograms');

for i = 1 : length(windowNames)
    if strcmpi(get(programs{i}, 'program_name'), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
        feval(getGlobal(progmanager, 'annotationDeletedDuringCorrelation', 'annotationCorrelator', windowNames{i}), ...
            getGlobal(progmanager, 'hObject', 'annotationCorrelator', windowNames{i}), windowObj);
    end
end

populateSummaryTable(hObject);
setLocal(progmanager, hObject, 'changesMadeSinceLastSave', 1);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function nextCorrelationId_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% --------------------------------------------------------------------
function nextCorrelationId_Callback(hObject, eventdata, handles)

last = getLocal(progmanager, hObject, 'lastGUID');
next = getLocal(progmanager, hObject, 'nextCorrelationId');

if next < last
    rollback = questdlg('Set GUID to a lower value than is necessary to maintain uniqueness (not recommended)?', 'Rollback GUID', 'Yes', 'No', 'No');
    if strcmpi(rollback, 'No')
        setLocal(progmanager, hObject, 'nextCorrelationId', last);
    else
        setLocal(progmanager, hObject, 'lastGUID', next);
    end
else
    setLocal(progmanager, hObject, 'lastGUID', next);
end

return;

% --------------------------------------------------------------------
function annotationAddedDuringCorrelation(hObject, windowObj)

windowNames = getLocal(progmanager, hObject, 'windowNames');
programs = getLocal(progmanager, hObject, 'subPrograms');

for i = 1 : length(windowNames)
    if strcmpi(get(programs{i}, 'program_name'), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
        if getGlobal(progmanager, 'correlationRunning', 'annotationCorrelator', windowNames{i})
            feval(getGlobal(progmanager, 'annotationAddedDuringCorrelation', 'annotationCorrelator', windowNames{i}), ...
                getGlobal(progmanager, 'hObject', 'annotationCorrelator', windowNames{i}), windowObj);
        end
    end
end

populateSummaryTable(hObject);
setLocal(progmanager, hObject, 'changesMadeSinceLastSave', 1);

return;

% --------------------------------------------------------------------
function annotationDeletedDuringCorrelation(hObject, windowObj)

windowNames = getLocal(progmanager, hObject, 'windowNames');
programs = getLocal(progmanager, hObject, 'subPrograms');

for i = 1 : length(windowNames)
    if strcmpi(get(programs{i}, 'program_name'), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
        if getGlobal(progmanager, 'correlationRunning', 'annotationCorrelator', windowNames{i})
            feval(getGlobal(progmanager, 'annotationDeletedDuringCorrelation', 'annotationCorrelator', windowNames{i}), ...
                getGlobal(progmanager, 'hObject', 'annotationCorrelator', windowNames{i}), windowObj);
        end
    end
end

populateSummaryTable(hObject);
setLocal(progmanager, hObject, 'changesMadeSinceLastSave', 1);

return;

% --------------------------------------------------------------------
function browserCloseEvent(hObject, windowObj)

p = program('AnnotationCorrelator', 'annotationCorrelator', 'annotationCorrelator');
if isstarted(progmanager, p)
    feval(getGlobal(progmanager, 'setObjects', 'annotationCorrelator', 'AnnotationCorrelator'), ...
        getGlobal(progmanager, 'hObject', 'annotationCorrelator', 'AnnotationCorrelator'));
end

return;

% --------------------------------------------------------------------
function updatePersistentData(hObject)

%TO060305A - This can cause problems, if not set properly, and it's not worth it for a little optimization. -- Tim O'Connor 6/3/05
% if ~getLocal(progmanager, hObject, 'changesMadeSinceLastSave')
%     return;
% end

persistentData = getLocal(progmanager, hObject, 'persistentData');
windowNames = getLocal(progmanager, hObject, 'windowNames');
programs = getLocal(progmanager, hObject, 'subPrograms');

for i = 1 : length(windowNames)
    if ~strcmpi(get(programs{i}, 'program_name'), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
        try
            fileName = getGlobal(progmanager, 'fileName', 'stackBrowser', windowNames{i});
            annotations = getGlobal(progmanager, 'annotations', 'stackBrowser', windowNames{i});
            index = size(persistentData, 1) + 1;
            for j = 1 : size(persistentData, 1)
                if strcmpi(persistentData{j, 1}, fileName)
                    index = j;
                    break;
                end
            end
            persistentData{index, 1} = fileName;        
            persistentData{index, 2} = annotations;
            persistentData{index, 3} = ia_getMetadata(getGlobal(progmanager, 'hObject', 'stackBrowser', windowNames{i}));
        catch
            warning('Error accessing data from %s. The GUI will be skipped, and any previously unsaved data will be lost.', windowNames{i});
        end
    end
end

setLocal(progmanager, hObject, 'persistentData', persistentData);

return;

% --------------------------------------------------------------------
function saveMenuItem_Callback(varargin)

hObject = varargin{1};
if length(varargin) > 2
    eventdata = varargin{2};
    handles = varargin{3};
end

fileName = getLocal(progmanager, hObject, 'fileName');
analysisFilePath = getLocal(progmanager, hObject, 'analysisFilePath');
if isempty(fileName) | isempty(analysisFilePath)
    saveAsMenuItem_Callback(hObject, eventdata, handles);
    return;
end

fullname = fullfile(analysisFilePath, fileName);
if exist(fullname) == 2
    overwrite = questdlg(sprintf('File ''%s'' exists. Overwrite?', fullname), 'Confirm Overwrite', 'No');
    if strcmpi(overwrite, 'No')
        return;
    end
end

updatePersistentData(hObject);

persistentData = getLocal(progmanager, hObject, 'persistentData');
save(fullname, 'persistentData', '-mat');

return;

% --------------------------------------------------------------------
function saveAsMenuItem_Callback(varargin)

hObject = varargin{1};
if length(varargin) > 2
    eventdata = varargin{2};
    handles = varargin{3};
end

[fname fpath] = uiputfile({'*.ann', '(*.ann) Annotation Files'; '*.mat', '(*.mat) Binary MAT Files'; '*.*', '(*.*) All Files'}, 'Save As...');
if isequal(fname, 0) | isequal(fpath, 0)
    return;
end
if length(fname) > 4
    if ~strcmpi('.ann', fname(length(fname) - 3 : length(fname)))
        fname = [fname '.ann'];
    end
else
    fname = [fname '.ann'];
end
fullname = fullfile(fpath, fname);

if exist(fullname) == 2
    overwrite = questdlg(sprintf('File ''%s'' exists. Overwrite?', fullname), 'Confirm Overwrite', 'No');
    if strcmpi(overwrite, 'No')
        return;
    end
end

updatePersistentData(hObject);

persistentData = getLocal(progmanager, hObject, 'persistentData');
save(fullname, 'persistentData', '-mat');
setLocal(progmanager, hObject, 'fileName', fname);
setLocal(progmanager, hObject, 'analysisFilePath', fpath);
setLocal(progmanager, hObject, 'changesMadeSinceLastSave', 0);

return;

% --------------------------------------------------------------------
function loadFromMenuItem_Callback(varargin)

hObject = varargin{1};
if length(varargin) > 2
    eventdata = varargin{2};
    handles = varargin{3};
end

if getLocal(progmanager, hObject, 'changesMadeSinceLastSave')
    yesOrNo = questdlg(sprintf('Do you wish to save any changes you may have made to your analysis?\n\n%s', ... 
        'Choosing ''No'' will discard any changes made to the current image since the previous save.'), 'Save Changes', 'Yes');
    if strcmpi(yesOrNo, 'Yes')
        saveMenuItem_Callback(varargin{:});
    elseif strcmpi(yesOrNo, 'Cancel')
        return;
    end
end

if ~isempty(getLocal(progmanager, hObject, 'analysisFilePath'))
    cd(getLocal(progmanager, hObject, 'analysisFilePath'));
end
[fname fpath] = uigetfile({'*.ann', '(*.ann) Annotation Files'; '*.mat', ' (*.mat) Binary MAT File'; '*.*', '(*.*) All Files'}, 'Import From...');
if isequal(fname, 0) | isequal(fpath, 0)
    return;
end
fullname = fullfile(fpath, fname);

if exist(fullname) ~= 2
    warning('Selected file, ''%s'', does not appear to be a valid file.', fullname);
    return;
end

loadData(hObject, fullname);
setLocal(progmanager, hObject, 'changesMadeSinceLastSave', 0);

return;

% --------------------------------------------------------------------
function loadMenuItem_Callback(varargin)

hObject = varargin{1};
if length(varargin) > 2
    eventdata = varargin{2};
    handles = varargin{3};
end

if getLocal(progmanager, hObject, 'changesMadeSinceLastSave')
    yesOrNo = questdlg('Discard changes since last save?', 'Discard Changes', 'Yes', 'No', 'No');
    if strcmpi(yesOrNo, 'No')
        return;
    end
end

fileName = getLocal(progmanager, hObject, 'fileName');
analysisFilePath = getLocal(progmanager, hObject, 'analysisFilePath');
if isempty(fileName) | isempty(analysisFilePath)
    loadFromMenuItem_Callback(hObject, eventdata, handles);
    return;
end

fullname = fullfile(analysisFilePath, fileName);
if exist(fullname) ~= 2
    fullname = fullfile(analysisFilePath, [fileName '.ann']);
    
    if exist(fullname) ~= 2
        loadFromMenuItem_Callback(hObject, eventdata, handles);
        return;
    end
end

loadData(hObject, fullname);

return;

% --------------------------------------------------------------------
function loadData(hObject, fullname)

loaded = load(fullname, '-mat');
persistentData = {};

%Remove empty columns created by older versions. --Tim O'Connor 3/7/05 - TO030705a
for i = 1 : size(loaded.persistentData, 1)
    if ~isempty(loaded.persistentData{i, 1}) & ~isempty(loaded.persistentData{i, 2})
        k = size(persistentData, 1) + 1;
        for j = 1 : size(loaded.persistentData, 2)
            persistentData{k, j} = loaded.persistentData{i, j};
        end
    else
        fprintf(2, 'Found empty data column while loading data from file ''%s'', ignoring...\n', fullname);
    end
end

setLocal(progmanager, hObject, 'persistentData', persistentData);
updateOldData(hObject);

[fpath fname, ext] = fileparts(fullname);
setLocal(progmanager, hObject, 'fileName', [fname ext]);
setLocal(progmanager, hObject, 'analysisFilePath', fpath);

ids = zeros(size(loaded.persistentData, 1), 1);
for i = 1 : size(loaded.persistentData)
    ann = loaded.persistentData{i, 2};
    if ~isempty(ann)
        ids(i) = max([ann.correlationID]);
    end
end
next = max(max(ids, getLocal(progmanager, hObject, 'nextCorrelationId'))) + 1;
setLocal(progmanager, hObject, 'nextCorrelationId', next);

windowNames = getLocal(progmanager, hObject, 'windowNames');
programs = getLocal(progmanager, hObject, 'subPrograms');

for i = 1 : length(windowNames)
    if ~strcmpi(get(programs{i}, 'program_name'), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
        feval(getGlobal(progmanager, 'dataLoadedFcn', 'stackBrowser', windowNames{i}), ...
            getGlobal(progmanager, 'hObject', 'stackBrowser', windowNames{i}));
    end
end

populateSummaryTable(hObject);

return;

% --------------------------------------------------------------------
function exportTabDelimited_Callback(hObject, eventdata, handles)

% exportDelimited(hObject, sprintf('\t'), 1);%Test me here.

cd(getLocal(progmanager, hObject, 'analysisFilePath'));
[fname fpath] = uiputfile({'*.tab', '(*.tab) Tab-Delimited Files'; '*.*', '(*.*) All Files'}, 'Save As...');
if isequal(fname, 0) | isequal(fpath, 0)
    return;
end

if length(fname) > 4
    if ~strcmpi('.tab', fname(length(fname) - 3 : length(fname)))
        fname = [fname '.tab'];
    end
else
    fname = [fname '.tab'];
end

try
    f = fopen(fullfile(fpath, fname), 'w');
catch
    errordlg(sprintf('Failed to open file for writing: %s', fullfile(fpath, fname)));
end

exportDelimited(hObject, sprintf('\t'), f);

try
    fclose(f);
catch
    warning('Error closing file: s', fullfile(fpath, fname));
end

return;

% --------------------------------------------------------------------
function exportCommaSeparated_Callback(hObject, eventdata, handles)

exportDelimited(hObject, ',', 1);%Test me here.

cd(getLocal(progmanager, hObject, 'analysisFilePath'));
[fname fpath] = uiputfile({'*.csv', '(*.csv) Comma-Separated Files'; '*.*', '(*.*) All Files'}, 'Save As...');
if isequal(fname, 0) | isequal(fpath, 0)
    return;
end

if length(fname) > 4
    if ~strcmpi('.csv', fname(length(fname) - 3 : length(fname)))
        fname = [fname '.csv'];
    end
else
    fname = [fname '.csv'];
end

try
    f = fopen(fullfile(fpath, fname), 'w');
catch
    errordlg(sprintf('Failed to open file for writing: %s', fullfile(fpath, fname)));
end

exportDelimited(hObject, ',', f);

try
    fclose(f);
catch
    warning('Error closing file: %s', fullfile(fpath, fname));
end

return;

% --------------------------------------------------------------------
%TO122109B - Export polyline lengths, do this before exporting the annotation data (so it requires an extra pass over the data.
function tabularizedData = generateTabularizedData(hObject)

persistentData = getLocal(progmanager, hObject, 'persistentData');

%Print the data.
tabularizedData = [];
rowIndex = 1;

%TO122109B
for i = 1 : getLocal(progmanager, hObject, 'nextCorrelationId') - 1
    rowIndex = rowIndex + 1;
    for j = 1 : size(persistentData, 1)
        annotations = persistentData{j, 2};
        if size(persistentData, 2) >= 3
            metadata = persistentData{j, 3};
        else
            metadata = [];
        end
        if isempty(annotations)
            %Something must get put out here, instead of just issuing a continue. TO022405a - Tim O'Connor 2/24/05
            annotations.correlationID = [];
            annotations.x = [];
            annotations.y = [];
            annotations.z = [];
        end
        
        polylineIndex = [];
        correlationIDs = [annotations.correlationID];
        index = find(correlationIDs == i);
        %TO032310C - Watch out for multiple correlationID matches. Not sure how this happened. -- Tim O'Connor 3/23/10
        if length(index) > 1
            warning('Multiple annotations found with correlation ID %s.', num2str(i));
            index = index(end);
        end
        if ~isempty(index)
            if ~strcmpi(annotations(index).type, 'polyline')
                index = [];
            end
        end
        if ~isempty(index)
            tabularizedData(rowIndex, 1) = i;
            if metadata.units.unitaryConversions
                xConv = metadata.units.xConversionFactor;
                yConv = metadata.units.yConversionFactor;
                zConv = metadata.units.zConversionFactor;
            else
                xConv = 1;
                yConv = 1;
                zConv = 1;
            end
            tabularizedData(rowIndex, j + 1) = sqrt(sum(abs(diff(xConv * annotations(index).x)))^2 ...
                + sum(abs(diff(yConv * annotations(index).y)))^2 + sum(abs(diff(zConv * annotations(index).z)))^2);
        end
    end
end
for i = 1 : getLocal(progmanager, hObject, 'nextCorrelationId') - 1
    rowIndex = rowIndex + 1;
    for j = 1 : size(persistentData, 1)
        annotations = persistentData{j, 2};
        if size(persistentData, 2) >= 3
            metadata = persistentData{j, 3};
        else
            metadata = [];
        end
        if isempty(annotations)
            %Something must get put out here, instead of just issuing a continue. TO022405a - Tim O'Connor 2/24/05
            annotations.correlationID = [];
            annotations.x = [];
            annotations.y = [];
            annotations.z = [];
        end

        correlationIDs = [annotations.correlationID];
        index = find(correlationIDs == i);
        %TO032310C - Watch out for multiple correlationID matches. Not sure how this happened. -- Tim O'Connor 3/23/10
        if length(index) > 1
            warning('Multiple annotations found with correlation ID %s.', num2str(i));
            index = index(end);
        end
        if ~isempty(index)
            if ~all(strcmpi(annotations(index).type, 'line'))
                index = [];
            end
        end

        if ~(size(tabularizedData, 1) >= rowIndex && size(tabularizedData, 2) >= j + 1)
            tabularizedData(rowIndex, j + 1) = 0;
        end
        if ~isempty(index)
            tabularizedData(rowIndex, 1) = i;
            for m = 1 : length(index)
                zlen = 0;
                for k = 2 : length(annotations(index(m)).z)
                    zlen = zlen + abs(annotations(index(m)).z(k) - annotations(index(m)).z(k - 1));
                end
                tabularizedData(rowIndex, j + 1) = 0;
                if isfield(metadata, 'units')
                    if metadata.units.unitaryConversions
                        tabularizedData(rowIndex, j + 1) = tabularizedData(rowIndex, j + 1) + ...
                            sqrt(abs(diff(metadata.units.xConversionFactor * annotations(index(m)).x))^2 + ...
                            abs(diff(metadata.units.yConversionFactor * annotations(index(m)).y))^2 + metadata.units.zConversionFactor * zlen^2);
                    else
                        tabularizedData(rowIndex, j + 1) = tabularizedData(rowIndex, j + 1) + ...
                            sqrt(abs(diff(annotations(index(m)).x))^2 + abs(diff(annotations(index(m)).y))^2 + zlen^2);
                    end
                else
                    tabularizedData(rowIndex, j + 1) = tabularizedData(rowIndex, j + 1) + ...
                        sqrt(abs(diff(annotations(index(m)).x))^2 + abs(diff(annotations(index(m)).y))^2 + zlen^2);%+ abs(diff(annotations(index(m)).z))^2);
                end
            end
        end
    end
end

indices = [];
for i = 1 : size(tabularizedData, 1)
    if any(tabularizedData(i, 2 : end) ~= 0)
        indices(length(indices) + 1) = i;
    end
end

tabularizedData = tabularizedData(indices, :);

return;

% --------------------------------------------------------------------
%TO080707A
%TO122109A - Fixed a problem where all data was shifted one column to the right. -- Tim O'Connor 12/21/09
function exportPhotometryDelimited(hObject, delimiter, f)

try
    fieldList = {'Background', 'Normalization Factor', 'Integral'};
    try
        [fieldList, ok] = listdlg('ListString', fieldList, 'SelectionMode', 'multiple', 'InitialValue', 1:length(fieldList), ...
            'Name', 'Export Photometry', 'PromptString', 'Select photometry fields to export...');
        if ~ok
            return;
        end
    catch
        fprintf(2, 'Failed to prompt for fields using `listdlg`, function may not be available in this version of Matlab. Exporting all fields...\n');
        fieldList = 1 : length(fieldList);
    end
    if ismember(1, fieldList)
        exportBackground = 1;
    else
        exportBackground = 0;
    end
    if ismember(2, fieldList)
        exportNormalization = 1;
    else
        exportNormalization = 0;
    end
    if ismember(3, fieldList)
        exportIntegral = 1;
    else
        exportIntegral = 0;
    end
    
    fprintf(f, '\r\n\r\n\r\nPhotometry - v0.4\n');
    fprintf(f, 'Exported - %s\r\n', datestr(datevec(now)));
    fprintf(f, 'CorrelationID%sIntegralChannel', delimiter);
    persistentData = getLocal(progmanager, hObject, 'persistentData');
    expandBy = exportBackground + exportNormalization + (2 * exportIntegral);
    for i = 1 : size(persistentData, 1)
        fprintf(f, '%s', repmat([delimiter persistentData{i, 1}], 1, expandBy));
    end
    fprintf(f, '\r\n%s', delimiter);
    for i = 1 : size(persistentData, 1)
        if exportBackground
            fprintf(f, '%sBackground', delimiter);
        end
        if exportNormalization
            fprintf(f, '%sNormalizationFactor', delimiter);
        end
        if exportIntegral
            fprintf(f, '%sIntegral%sIntegralPixelCount', delimiter, delimiter);
        end
    end
    fprintf(f, '\r\n');

    %This is where things get  ugly. There's all sorts of different cases about what to print and the number of rows/columns is pretty variable.
    %Indices get incremented all over the place.
    tabularizedData = [];
    rowOffset = 0;
    rowOffsetPerImageMax = 0;
    %Iterate over all correlationIDs.
    for i = 1 : getLocal(progmanager, hObject, 'nextCorrelationId') - 1
        %Iterate over each image's data.
        for j = 1 : size(persistentData, 1)
            rowOffsetPerImage = 0;%Reset this variable for each image.
            annotations = persistentData{j, 2};
            if isempty(annotations)
                %No data for this image, skip it.
                continue;
            end
            correlationIDs = [annotations.correlationID];
            index = find(correlationIDs == i);
            %TO032310C - Watch out for multiple correlationID matches. Not sure how this happened. -- Tim O'Connor 3/23/10
            if length(index) > 1
                warning('Multiple annotations found with correlation ID %s.', num2str(i));
                index = index(end);
            end
            if isempty(index)
                %This correlationID wasn't found in this image, skip it.
                continue;
            end

            %Iterate over columns per image, which depends on the fields that are being exported.
            %Iterate over photometry channels.
            %Values should only be entered into the array from within this loop.
            for n = 1 : expandBy
                %i is the correlationID.
                %rowOffset is the current row beyond i, due to possible multiple photometry channels per ID.
                %rowOffsetPerImage is the current image's row offset. This is a running count that gets reset for each image.
                %rowOffsetPerImageMax is the total number of rows for the current correlationID, to be used to increment rowOffset to the next set of rows.
                %index is the current annotation.
                %j is the image's index.
                %expandBy is the number of columns per image.
                %n is the index into the photometry array.
                %colOffset is the current data column.

                if n > length(annotations(index).photometry)
                    %No (more) photometry data for this channel.
                    break;%Quit iterating this annotation's photometry data.
                end
                colOffset = 3 + (j-1) * expandBy;%The current data column's index. %TO122109A - Changed from "4 + ..." because all data was shifted one column to the right.
                %If annotations were found for this image, insert the correlationID.
                %The case where no photometry data is found will be handled later. It will be filled with zeros if nothing's found.
                %Assign correlationID and channel for this row.
                tabularizedData(i+rowOffset+rowOffsetPerImage, 1) = i;%INSERT CorrelationID
                if ~isfield(annotations(index), 'photometry')
                    %Set all data for this image in this row to zero, skip to next.
                    tabularizedData(i+rowOffset+rowOffsetPerImage, colOffset : colOffset+expandBy-1) = 0;%INSERT all fields
                    break;
                elseif isempty(annotations(index).photometry)
                    %Set all data for this image in this row to zero, skip to next.
                    tabularizedData(i+rowOffset+rowOffsetPerImage, colOffset : colOffset+expandBy-1) = 0;%INSERT all fields
                    break;
                end
                tabularizedData(i+rowOffset+rowOffsetPerImage, 2) = annotations(index).photometry(n).integralChannel;%INSERT channel
                if exportBackground
                    if isempty(annotations(index).photometry(n).background)
                        tabularizedData(i+rowOffset+rowOffsetPerImage, colOffset) = 0;
                    else
                        tabularizedData(i+rowOffset+rowOffsetPerImage, colOffset) = annotations(index).photometry(n).background;%INSERT background
                    end
                    colOffset = colOffset + 1;%Data was inserted in this column, increment the column offset counter.
                end
                if exportNormalization
                    if isempty(annotations(index).photometry(n).normalization)
                        tabularizedData(i+rowOffset+rowOffsetPerImage, colOffset) = 0;
                    else
                        tabularizedData(i+rowOffset+rowOffsetPerImage, colOffset) = annotations(index).photometry(n).normalization;%INSERT normalization
                    end
                    colOffset = colOffset + 1;%Data was inserted in this column, increment the column offset counter.
                end
                if exportIntegral
                    if isempty(annotations(index).photometry(n).integral)
                        tabularizedData(i+rowOffset+rowOffsetPerImage, colOffset) = 0;
                    else
                        tabularizedData(i+rowOffset+rowOffsetPerImage, colOffset) = annotations(index).photometry(n).integral;%INSERT integral
                    end
                    colOffset = colOffset + 1;%Data was inserted in this column, increment the column offset counter.

                    %TO080507D - Export number of pixels in the integral region.
                    if isempty(annotations(index).photometry(n).integral)
                        tabularizedData(i+rowOffset+rowOffsetPerImage, colOffset) = 0;
                    else
                        tabularizedData(i+rowOffset+rowOffsetPerImage, colOffset) = annotations(index).photometry(n).integralPixelCount;%INSERT integral pixel count.
                    end
                    colOffset = colOffset + 1;%Data was inserted in this column, increment the column offset counter.
                end
                if n < length(annotations(index).photometry)
                    %Add another row for the next channel's photometry data for this image.
                    rowOffsetPerImage = rowOffsetPerImage + 1;
                    rowOffsetPerImageMax = max(rowOffsetPerImageMax, rowOffsetPerImage);
                end
            end%for n
        end%for j
        rowOffset = rowOffset+rowOffsetPerImageMax;%Move to the beginning of the next correlationID's rows.
    end%for i

    %Prune rows full of zeros or with an "unknown channel" (ie. no photometry data).
    indices = [];
    for i = 1 : size(tabularizedData, 1)
        if any(tabularizedData(i, 3 : end) ~= 0) && (tabularizedData(i, 2) ~= 0)
            indices(length(indices) + 1) = i;
        end
    end
    tabularizedData = tabularizedData(indices, :);    
    for i = 1 : size(tabularizedData, 1)
        for j = 1 : size(tabularizedData, 2)
            fprintf(f, '%s%s', num2str(tabularizedData(i, j)), delimiter);
        end
        fprintf(f, '\r\n');
    end
catch
    fprintf(2, 'Failed to export photometry data:\n%s\n', getLastErrorStack);
end

return;

% --------------------------------------------------------------------
function exportDelimited(hObject, delimiter, f)

updatePersistentData(hObject);
persistentData = getLocal(progmanager, hObject, 'persistentData');

%Print a header.
fprintf(f, 'Annotations - v0.4\n');
fprintf(f, 'Exported - %s\r\n', datestr(datevec(now)));
fprintf(f, 'CorrelationID%s ', delimiter);
for i = 1 : size(persistentData, 1)
    % [%s, %s, %s]
    metadata = [];
    if size(persistentData, 2) >= 3
        metadata = persistentData{i, 3};
        if isfield(metadata, 'units')
            if metadata.units.unitaryConversions
                fprintf(f, '%s [%s-%s-%s]%s ', persistentData{i, 1}, metadata.units.xUnits, metadata.units.yUnits, ...
                    metadata.units.zUnits, delimiter);
            else
                fprintf(f, '%s [pix-pix-pix]%s ', persistentData{i, 1}, delimiter);
            end
        end
    else
        fprintf(f, '%s [pix-pix-pix]%s ', persistentData{i, 1}, delimiter);
    end
end
fprintf(f, '\r\n');

tabularizedData = generateTabularizedData(hObject);
for i = 1 : size(tabularizedData, 1)
    if any(tabularizedData(i, 2:end) ~= 0)
        for j = 1 : size(tabularizedData, 2)
            fprintf(f, '%s%s ', num2str(tabularizedData(i, j)), delimiter);
        end
        fprintf(f, '\r\n');
    end
end

exportPhotometryDelimited(hObject, delimiter, f);
% for i = 1 : getLocal(progmanager, hObject, 'nextCorrelationId') - 1
%     fprintf(f, '%s%s ', num2str(i), delimiter);
%     
%     for j = 1 : size(persistentData, 1)
%         annotations = persistentData{j, 2};
%         
%         index = -1;
%         for k = 1 : length(annotations)
%             if annotations(k).correlationID == i & strcmpi(annotations(k).type, 'line')
%                 index = k;
%                 break;
%             end
%         end
%         
%         if index > 0
%             fprintf(f, '%s%s ', num2str(sqrt(abs(annotations(index).x(2) - annotations(index).x(1))^2 ...
%                 + abs(annotations(index).y(2) - annotations(index).y(1))^2)), delimiter);
%         else
%             fprintf(f, '0%s ', delimiter);
%         end
%     end
%     
%     fprintf(f, '\r\n');
% end

return;

% --------------------------------------------------------------------
function exportToExcel_Callback(hObject, eventdata, handles)

errordlg(sprintf('Exporting directly to Excel is not implemented, yet.\nInstead, export to tab delimited or comma separated and open in Excel.'), ...
    'Feature Not Implemented');

return;


% --------------------------------------------------------------------
function newDataset_Callback(hObject, eventdata, handles)

updatePersistentData(hObject);
persistentData = getLocal(progmanager, hObject, 'persistentData');
if ~isempty(persistentData)
    saveData = questdlg('Would you like to save your current dataset?', 'Save Data', 'Yes', 'No', 'Cancel', 'Yes');
    if strcmpi(saveData, 'Yes')
        saveMenuItem_Callback(varargin);
    elseif strcmpi(saveData, 'Cancel')
        return;
    end
end

[fname fpath] = uiputfile({'*.ann', '(*.ann) Annotation Files'; '*.mat', '(*.mat) Binary MAT Files'; '*.*', '(*.*) All Files'}, 'Save As...');
if isequal(fname, 0) | isequal(fpath, 0)
    return;
end

if length(fname) > 4
    if ~strcmpi('.ann', fname(length(fname) - 3 : length(fname)))
        fname = [fname '.ann'];
    end
else
    fname = [fname '.ann'];
end
fullname = fullfile(fpath, fname);

persistentData = {};
setLocal(progmanager, hObject, 'persistentData', persistentData);
save(fullname, 'persistentData', '-mat');
setLocal(progmanager, hObject, 'fileName', fname);
setLocal(progmanager, hObject, 'analysisFilePath', fpath);

setLocal(progmanager, hObject, 'nextCorrelationId', 1);

windowNames = getLocal(progmanager, hObject, 'windowNames');
programs = getLocal(progmanager, hObject, 'subPrograms');

for i = 1 : length(windowNames)
    if ~strcmpi(get(programs{i}, 'program_name'), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
        feval(getGlobal(progmanager, 'dataLoadedFcn', 'stackBrowser', windowNames{i}), ...
            getGlobal(progmanager, 'hObject', 'stackBrowser', windowNames{i}));
    end
end

return;

% --------------------------------------------------------------------
function updateOldData(hObject)

persistentData = getLocal(progmanager, hObject, 'persistentData');

for i = 1 : size(persistentData, 1)

    if isempty(persistentData{i, 1})
        continue;
    end
    
    if ~any(persistentData{i, 1} == '.')
        persistentData{i, 1} = [persistentData{i, 1} '.tif'];
    end
    
    data = persistentData{i, 2};
    if ~isfield(data, 'userData')
        for j = 1 : length(data)
            data(j).userData = [];
        end
    end
    
    if ~isfield(data, 'photometry')
        for j = 1 : length(data)
            data(j).photometry.background = [];
            data(j).photometry.backgroundBounds = [];
            data(j).photometry.backgroundFrame = [];
            data(j).photometry.backgroundChannel = 1;
            data(j).photometry.normalization = [];
            data(j).photometry.normalizationBounds = [];
            data(j).photometry.normalizationFrame = [];
            data(j).photometry.normalizationChannel = 1;
            data(j).photometry.integral = [];
            data(j).photometry.integralBounds = [];
            data(j).photometry.integralFrame = [];
            data(j).photometry.integralChannel = 1;
            data(j).photometry.normalizationMethod = [];
            
        end
    end
    
%     if ~isfield(data.photometry, 'background') | ~isfield(data.photometry, 'normalization') | ...
%              ~isfield(data.photometry, 'integral')
    for j = 1 : length(data)
        if isempty(data(j).photometry)
            data(j).photometry.background = [];
            data(j).photometry.backgroundBounds = [];
            data(j).photometry.backgroundFrame = [];
            data(j).photometry.normalization = [];
            data(j).photometry.normalizationBounds = [];
            data(j).photometry.normalizationFrame = [];
            data(j).photometry.integral = [];
            data(j).photometry.integralBounds = [];
            data(j).photometry.integralFrame = [];
            data(j).photometry.normalizationMethod = 1;
        elseif length(data(j).photometry) == 1
            %TO090407A - Assume that if photometry includes multi-channel data, it is properly initialized.
            %            These checks were only put in place for backwards compatibility anyway.
            if ~isfield(data(j).photometry, 'normalizationMethod')
                data(j).photometry.normalizationMethod = 1;
            elseif isempty(data(j).photometry.normalizationMethod)
                data(j).photometry.normalizationMethod = 1;
            end

            if ~isfield(data(j).photometry, 'backgroundChannel')
                data(j).photometry.backgroundChannel = 1;
            end
            if ~isfield(data(j).photometry, 'normalizationChannel')
                data(j).photometry.normalizationChannel = 1;
            end
            if ~isfield(data(j).photometry, 'integralChannel')
                data(j).photometry.integralChannel = 1;
            end
        end
        
        if ~isfield(data(j), 'channel')
            data(j).channel = 1;
        elseif isempty(data(j).channel)
            data(j).channel = 1;
        end
    end
%     end
    
    validAnnotations = 1 : length(data);
    for j = 1 : length(data)
        if isempty(data(j).type) | isempty(data(j).x) | isempty(data(j).y)
            validAnnotations = validAnnotations(find(validAnnotations ~= j));
        end
    end
    data = data(validAnnotations);
    
    [data(:).filename] = deal(persistentData{i, 1});
    persistentData{i, 2} = data;
end

if size(persistentData, 2) < 3
    for i = 1 : size(persistentData, 1)
        persistentData{i, 3} = [];
    end
end

setLocal(progmanager, hObject, 'persistentData', persistentData);

return;

% --------------------------------------------------------------------
function updateSession(hObject)

windowNames = getLocal(progmanager, hObject, 'windowNames');
programs = getLocal(progmanager, hObject, 'subPrograms');

session = [];

for i = 1 : length(windowNames)
    if ~strcmpi(get(programs{i}, 'program_name'), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
        index = length(session) + 1;
        session(index).fileNameDisplay = getGlobal(progmanager, 'fileNameDisplay', 'stackBrowser', windowNames{i});
        session(index).filterType = getGlobal(progmanager, 'filterType', 'stackBrowser', windowNames{i});
    end
end

setLocal(progmanager, hObject, 'session', session);

return;

% --------------------------------------------------------------------
% --- Executes on button press in summaryTable.
function summaryTable_Callback(hObject, eventdata, handles)

summaryTable = getLocal(progmanager, hObject, 'summaryTable');

programRunning = 1;
if isempty(summaryTable)
    programRunning = 0;
else
    if ~isstarted(progmanager, summaryTable)
        programRunning = 0;
    end
end

if ~programRunning
    openprogram(progmanager, program('Image_Analysis_Summary', 'summaryTable'))
    
    summaryTable = getGlobal(progmanager, 'hObject', 'summaryTable', 'Image_Analysis_Summary');
end

setLocal(progmanager, hObject, 'summaryTable', summaryTable);

populateSummaryTable(hObject);

return;

% --------------------------------------------------------------------
function populateSummaryTable(hObject)

summaryTable = getLocal(progmanager, hObject, 'summaryTable');
if isempty(summaryTable)
    return;
elseif ~isstarted(progmanager, summaryTable)
    return;
end

updatePersistentData(hObject);
persistentData = getLocal(progmanager, hObject, 'persistentData');

columnNames = {};
for i = 1 : size(persistentData, 1)
    if ~isempty(persistentData{i, 1})
        columnNames{length(columnNames) + 1} = persistentData{i, 1};      
    end
end
tabularizedData = generateTabularizedData(hObject);

rowNames = {};
for i = 1 : size(tabularizedData, 1)
    rowNames{i} = num2str(tabularizedData(i, 1));
end

% st_setTableData(summaryTable, tabularizedData(:, 2 : size(tabularizedData, 2)));
% st_setColumnNames(summaryTable, columnNames);
% st_setRowNames(summaryTable, rowNames);

st_setAllFields(summaryTable, tabularizedData(:, 2 : size(tabularizedData, 2)), rowNames, columnNames, ia_makeColorTable(hObject, rowNames, columnNames));

st_setCellSelectionCallback(summaryTable, {@summaryTableSelection_Callback, hObject});
st_setRowSelectionCallback(summaryTable, {@summaryTableRowSelection_Callback, hObject});

% ia_colorSummaryTable(hObject);

return;

% --------------------------------------------------------------------
function summaryTableSelection_Callback(hObject, row, column)

summaryTable = getLocal(progmanager, hObject, 'summaryTable');
rowNames = st_getRowNames(summaryTable);
correlationID = str2num(rowNames{row});
columnNames = st_getColumnNames(summaryTable);

programs = getLocal(progmanager, hObject, 'subPrograms');
hObjects = [];
for i = length(programs) : -1 : 1
    if ~strcmpi(getProgramName(progmanager, programs{i}), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
        if strcmpi(getLocal(progmanager, getFigHandle(progmanager, programs{i}), 'fileName'), columnNames{column})
            hObjects(length(hObjects) + 1) = getLocal(progmanager, getFigHandle(progmanager, programs{i}), 'hObject');
        end
    end
end

for i = 1 : length(hObjects)
    annotations = getLocal(progmanager, hObjects(i), 'annotations');
    for j = 1 : length(annotations)
        if annotations(j).correlationID == correlationID
            setLocal(progmanager, hObjects(i), 'currentAnnotation', j);
            ia_setColors(hObjects(i));
            feval(getLocal(progmanager, hObjects(i), 'annotationDisplayUpdateFcn'), getLocal(progmanager, hObjects(i), 'annotationObject'));
            feval(getLocal(progmanager, hObjects(i), 'centerOnAnnotation'), hObjects(i));
            continue;
        end
    end
end

return;

% --------------------------------------------------------------------
function summaryTableRowSelection_Callback(hObject, row)

summaryTable = getLocal(progmanager, hObject, 'summaryTable');
rowNames = st_getRowNames(summaryTable);
correlationID = str2num(rowNames{row});

programs = getLocal(progmanager, hObject, 'subPrograms');
hObjects = [];
for i = length(programs) : -1 : 1
    if ~strcmpi(getProgramName(progmanager, programs{i}), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
            hObjects(length(hObjects) + 1) = getLocal(progmanager, getFigHandle(progmanager, programs{i}), 'hObject');
    end
end

for i = 1 : length(hObjects)
    annotations = getLocal(progmanager, hObjects(i), 'annotations');
    for j = 1 : length(annotations)
        if annotations(j).correlationID == correlationID
            setLocal(progmanager, hObjects(i), 'currentAnnotation', j);
            ia_setColors(hObjects(i));
            feval(getLocal(progmanager, hObjects(i), 'annotationDisplayUpdateFcn'), getLocal(progmanager, hObjects(i), 'annotationObject'));
            feval(getLocal(progmanager, hObjects(i), 'centerOnAnnotation'), hObjects(i));
            continue;
        end
    end
end

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function defaultZoom_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --------------------------------------------------------------------
function defaultZoom_Callback(hObject, eventdata, handles)

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function defaultFilter_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --------------------------------------------------------------------
% --- Executes on selection change in defaultFilter.
function defaultFilter_Callback(hObject, eventdata, handles)

return;

% --------------------------------------------------------------------
% --- Executes on button press in expandWindowButton.
function expandWindowButton_Callback(hObject, eventdata, handles)

f = getParent(hObject, 'figure');
pos = get(f, 'Position');

if getLocal(progmanager, hObject, 'expandWindowButton')
    setLocalGh(progmanager, hObject, 'expandWindowButton', 'String', '<<');
    setLocalGh(progmanager, hObject, 'expandWindowButton', 'ToolTipString', 'Contract window to hide options and defaults.');
    pos(3) = 63.8;
else
    setLocalGh(progmanager, hObject, 'expandWindowButton', 'String', '>>');
    setLocalGh(progmanager, hObject, 'expandWindowButton', 'ToolTipString', 'Expand window to show options and defaults.');
    pos(3) = 30.2;
end

set(f, 'Position', pos);

return;

% --------------------------------------------------------------------
% --- Executes on button press in zoomLockCheckbox.
function zoomLockCheckbox_Callback(hObject, eventdata, handles)

return;