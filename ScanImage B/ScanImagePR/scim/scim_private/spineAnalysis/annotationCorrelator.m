function varargout = annotationCorrelator(varargin)
% ANNOTATIONCORRELATOR M-file for annotationCorrelator.fig
%      ANNOTATIONCORRELATOR, by itself, creates a new ANNOTATIONCORRELATOR or raises the existing
%      singleton*.
%
%      H = ANNOTATIONCORRELATOR returns the handle to a new ANNOTATIONCORRELATOR or the handle to
%      the existing singleton*.
%
%      ANNOTATIONCORRELATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANNOTATIONCORRELATOR.M with the given input arguments.
%
%      ANNOTATIONCORRELATOR('Property','Value',...) creates a new ANNOTATIONCORRELATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before annotationCorrelator_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to annotationCorrelator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help annotationCorrelator

% Last Modified by GUIDE v2.5 15-Jul-2004 15:10:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @annotationCorrelator_OpeningFcn, ...
                   'gui_OutputFcn',  @annotationCorrelator_OutputFcn, ...
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


% --- Executes just before annotationCorrelator is made visible.
function annotationCorrelator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to annotationCorrelator (see VARARGIN)

% Choose default command line output for annotationCorrelator
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes annotationCorrelator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = annotationCorrelator_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'hObject', hObject, ...
       'correlationIDCounter', 1, ...
       'oldObj', [], ...
       'newObj', [], ...
       'oldCoords', [], ...
       'newCoords', [], ...
       'oldWindow', [], ...
       'newWindow', [], ...
       'oldUpdateDisplayFcn', [], ...
       'newUpdateDisplayFcn', [], ...
       'oldAnnotationIndex', [], ...
       'newAnnotationIndex', [], ...
       'oldFilename', 1, 'Class', 'Numeric', 'Gui', 'oldFilename', ...
       'newFilename', 1, 'Class', 'Numeric', 'Gui', 'newFilename', ...
       'setObjects', @setObjects, ...
       'constructMap', @constructMaps, ...
       'annotationAddedDuringCorrelation', @annotationAddedDuringCorrelation, ...
       'annotationDeletedDuringCorrelation', @annotationDeletedDuringCorrelation, ...
       'oldUsed', [], ...
       'newUsed', [], ...
       'oldPosition', 0, ...
       'newPosition', 0, ...
       'newStart', 0, ...
       'oldStart', 0, ...
       'nodeCounter', 0, ...
       'inconsistencyFound', 0, ...
       'correlationRunning', 0, ...
       'oldAutoCenter', 1, 'Gui', 'oldAutoCenter', 'Class', 'Numeric', ...
       'newAutoCenter', 1, 'Gui', 'newAutoCenter', 'Class', 'Numeric', ...
       'correlationStarted', 0, ...
   };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'hObject', hObject);

setObjects(hObject);

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.1;

return;

% ------------------------------------------------------------------
function setObjects(hObject)

p = {};
fnames = {};
programs = getGlobal(progmanager, 'subPrograms', 'stackBrowserControl', 'StackBrowserControl');
for i = length(programs) : -1 : 1
    if ~strcmpi(getProgramName(progmanager, programs{i}), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
        p{length(p) + 1} = programs{i};
        fnames{length(fnames) + 1} = getLocal(progmanager, getFigHandle(progmanager, programs{i}), 'fileName');
    end
end

if length(p) < 2
    fprintf(1, 'Warning: Not enough browsers open to perform correlation. At least 2 browsers must be open and displaying images.\n');
    return;
elseif length(p) > 2
    fprintf(1, 'Warning: More than two browsers open. Correlation will be performed between ''%s'' and ''%s''.\n', ...
        getProgramName(progmanager, p{1}), getProgramName(progmanager, p{2}));
    p = {p{1}, p{2}};
end

fig1 = getFigHandle(progmanager, p{1});
header1 = getLocal(progmanager, fig1, 'currentHeader');

fig2 = getFigHandle(progmanager, p{2});
header2 = getLocal(progmanager, fig2, 'currentHeader');

if isempty(getLocal(progmanager, fig1, 'fileNameDisplay')) | isempty(getLocal(progmanager, fig2, 'fileNameDisplay'))
    fprintf(1, 'Warning: Not enough browsers open to perform correlation. At least 2 browsers must be open and displaying images.\n');
    return;
end

setLocalGh(progmanager, hObject, 'oldFilename', 'String', fnames);
setLocalGh(progmanager, hObject, 'newFilename', 'String', fnames);

if datenum(header1.internal.triggerTimeString) > datenum(header2.internal.triggerTimeString)
    setLocal(progmanager, hObject, 'oldObj', fig2);
    setLocal(progmanager, hObject, 'newObj', fig1);
    setLocal(progmanager, hObject, 'oldFilename', 2);
    setLocal(progmanager, hObject, 'newFilename', 1);
else
    setLocal(progmanager, hObject, 'oldObj', fig1);
    setLocal(progmanager, hObject, 'newObj', fig2);
    setLocal(progmanager, hObject, 'oldFilename', 1);
    setLocal(progmanager, hObject, 'newFilename', 2);
end

oldFilename_Callback(hObject);
newFilename_Callback(hObject);

constructMaps(hObject, 'line');

return;

% ------------------------------------------------------------------
function setOldZoom(hObject)

oldObj = getLocal(progmanager, hObject, 'oldObj');
if isempty(oldObj)
    return;
end

current = getLocal(progmanager, hObject, 'oldPosition');
setLocal(progmanager, oldObj, 'currentAnnotation', current);
if current < 1
    current = getLocal(progmanager, hObject, 'newPosition');
    if current < 1
        return;
    end
    
    newObj = getLocal(progmanager, hObject, 'newObj');
    annotations = getLocal(progmanager, newObj, 'annotations');
    
    span = abs(getLocal(progmanager, newObj, 'xBoundHigh') - getLocal(progmanager, newObj, 'xBoundLow')) / 2;
    
    x = sort([annotations(current).x(1) annotations(current).x(2)]) + [-1*span span];
    y = sort([annotations(current).y(1) annotations(current).y(2)]) + [-1*span span];
    
    if abs(x(1) - x(2)) > 2 * span
        x(2) = x(1) + 2 * span;
    end
    
    if abs(y(1) - y(2)) > 2 * span
        y(2) = y(1) + 2 * span;
    end
    
    setLocal(progmanager, oldObj, 'xBoundLow', x(1));
    setLocal(progmanager, oldObj, 'xBoundHigh', x(2));
    setLocal(progmanager, oldObj, 'yBoundLow', y(1));
    setLocal(progmanager, oldObj, 'yBoundHigh', y(2));
    
    feval(getLocal(progmanager, oldObj, 'updateImageDisplay'), oldObj);
else
    feval(getLocal(progmanager, oldObj, 'centerOnAnnotation'), oldObj);
    
    annotations = getLocal(progmanager, oldObj, 'annotations');
    if annotations(current).z(1) == getLocal(progmanager, oldObj, 'frameNumber')
        feval(getLocal(progmanager, oldObj, 'updateImageDisplay'), oldObj);
    else
        setLocal(progmanager, oldObj, 'frameNumber', annotations(current).z(1));
        feval(getLocal(progmanager, oldObj, 'displayNewImage'), oldObj);
    end
%     if annotations(current).z(1) == getLocal(progmanager, oldObj, 'frameNumber')
%         feval(getLocal(progmanager, oldObj, 'updateImageDisplay'), oldObj);
%     else
%         setLocal(progmanager, oldObj, 'frameNumber', annotations(current).z(1));
%         feval(getLocal(progmanager, oldObj, 'displayNewImage'), oldObj);
%     end
end

return;

% annotations = getLocal(progmanager, oldObj, 'annotations');
% if current > length(annotations)
%     annotations = getLocal(progmanager, getLocal(progmanager, hObject, 'newObj'), 'annotations');
% end
% % if isempty(annotations)
% %     return;
% % end
% 
% if current >= 1 & current <= length(annotations)
%     span = abs(getLocal(progmanager, oldObj, 'xBoundHigh') - getLocal(progmanager, oldObj, 'xBoundLow')) / 2;
%     setLocal(progmanager, oldObj, 'currentAnnotation', current);
% else
%     newObj = getLocal(progmanager, hObject, 'newObj');
%     annotations = getLocal(progmanager, newObj, 'annotations');
%     current = getLocal(progmanager, hObject, 'newPosition');
%     
%     setLocal(progmanager, oldObj, 'currentAnnotation', -1);
%         
%     if current < 1 | current >= length(annotations)
%         ia_setColors(oldObj);
%         feval(getLocal(progmanager, oldObj, 'annotationDisplayUpdateFcn'), getLocal(progmanager, oldObj, 'annotationObject'));
%         return;
%     end
% 
%     span = abs(getLocal(progmanager, newObj, 'xBoundHigh') - getLocal(progmanager, newObj, 'xBoundLow')) / 2;
% end
% 
% x = sort([annotations(current).x(1) annotations(current).x(2)]) + [-1*span span];
% y = sort([annotations(current).y(1) annotations(current).y(2)]) + [-1*span span];
% 
% if abs(x(1) - x(2)) > 2 * span
%     x(2) = x(1) + 2 * span;
% end
% 
% if abs(y(1) - y(2)) > 2 * span
%     y(2) = y(1) + 2 * span;
% end
% 
% setLocal(progmanager, oldObj, 'xBoundLow', x(1));
% setLocal(progmanager, oldObj, 'xBoundHigh', x(2));
% setLocal(progmanager, oldObj, 'yBoundLow', y(1));
% setLocal(progmanager, oldObj, 'yBoundHigh', y(2));
% 
% % newObj = getLocal(progmanager, hObject, 'newObj');
% % setLocal(progmanager, newObj, 'xBoundLow', x(1));
% % setLocal(progmanager, newObj, 'xBoundHigh', x(2));
% % setLocal(progmanager, newObj, 'yBoundLow', y(1));
% % setLocal(progmanager, newObj, 'yBoundHigh', y(2));
% % if annotations(current).z(1) == getLocal(progmanager, newObj, 'frameNumber')
% %     feval(getLocal(progmanager, newObj, 'updateImageDisplay'), newObj);
% % else
% %     setLocal(progmanager, newObj, 'frameNumber', annotations(current).z(1));
% %     feval(getLocal(progmanager, newObj, 'displayNewImage'), newObj);
% % end
% % ia_setColors(oldObj);
% % feval(getLocal(progmanager, oldObj, 'annotationDisplayUpdateFcn'), getLocal(progmanager, oldObj, 'annotationObject'));
% 
% % warning('old: [%s %s %s %s]\n', getLocal(progmanager, oldObj, 'xBoundLow'), getLocal(progmanager, oldObj, 'xBoundHigh'), ...
% %     getLocal(progmanager, oldObj, 'yBoundLow'), getLocal(progmanager, oldObj, 'yBoundHigh'));
% 
% if annotations(current).z(1) == getLocal(progmanager, oldObj, 'frameNumber')
%     feval(getLocal(progmanager, oldObj, 'updateImageDisplay'), oldObj);
% else
%     setLocal(progmanager, oldObj, 'frameNumber', annotations(current).z(1));
%     feval(getLocal(progmanager, oldObj, 'displayNewImage'), oldObj);
% end
% 
% return;

% ------------------------------------------------------------------
function setNewZoom(hObject)

newObj = getLocal(progmanager, hObject, 'newObj');
if isempty(newObj)
    return;
end

current = getLocal(progmanager, hObject, 'newPosition');
setLocal(progmanager, newObj, 'currentAnnotation', current);
if current < 1
    current = getLocal(progmanager, hObject, 'oldPosition');
    if current < 1
        return;
    end
    oldObj = getLocal(progmanager, hObject, 'oldObj');
    annotations = getLocal(progmanager, oldObj, 'annotations');

    span = abs(getLocal(progmanager, oldObj, 'xBoundHigh') - getLocal(progmanager, oldObj, 'xBoundLow')) / 2;

    x = sort([annotations(current).x(1) annotations(current).x(2)]) + [-1*span span];
    y = sort([annotations(current).y(1) annotations(current).y(2)]) + [-1*span span];
    
    if abs(x(1) - x(2)) > 2 * span
        x(2) = x(1) + 2 * span;
    end
    
    if abs(y(1) - y(2)) > 2 * span
        y(2) = y(1) + 2 * span;
    end
    
    setLocal(progmanager, newObj, 'xBoundLow', x(1));
    setLocal(progmanager, newObj, 'xBoundHigh', x(2));
    setLocal(progmanager, newObj, 'yBoundLow', y(1));
    setLocal(progmanager, newObj, 'yBoundHigh', y(2));
    
    feval(getLocal(progmanager, newObj, 'updateImageDisplay'), newObj);
else
    feval(getLocal(progmanager, newObj, 'centerOnAnnotation'), newObj);
    
    annotations = getLocal(progmanager, newObj, 'annotations');
    if annotations(current).z(1) == getLocal(progmanager, newObj, 'frameNumber')
        feval(getLocal(progmanager, newObj, 'updateImageDisplay'), newObj);
    else
        setLocal(progmanager, newObj, 'frameNumber', annotations(current).z(1));
        feval(getLocal(progmanager, newObj, 'displayNewImage'), newObj);
    end
%     if annotations(current).z(1) == getLocal(progmanager, newObj, 'frameNumber')
%         feval(getLocal(progmanager, newObj, 'updateImageDisplay'), newObj);
%     else
%         setLocal(progmanager, newObj, 'frameNumber', annotations(current).z(1));
%         feval(getLocal(progmanager, newObj, 'displayNewImage'), newObj);
%     end
end

return;
% annotations = getLocal(progmanager, newObj, 'annotations');
% if current > length(annotations)
%     annotations = getLocal(progmanager, getLocal(progmanager, hObject, 'oldObj'), 'annotations');
% end
% % if isempty(annotations)
% %     return;
% % end
% 
% if current >= 1 & current <= length(annotations)
% %     newSpan = round(3 * mean([abs(newAnnotation(newCurrent).x(2) - newAnnotation(newCurrent).x(1)) abs(newAnnotation(newCurrent).y(2) - newAnnotation(newCurrent).y(1))]));
%     span = abs(getLocal(progmanager, newObj, 'xBoundHigh') - getLocal(progmanager, newObj, 'xBoundLow')) / 2;
%     setLocal(progmanager, newObj, 'currentAnnotation', current);
% else
%     oldObj = getLocal(progmanager, hObject, 'oldObj');
%     annotations = getLocal(progmanager, oldObj, 'annotations');
%     current = getLocal(progmanager, hObject, 'oldPosition');
%     
%     setLocal(progmanager, newObj, 'currentAnnotation', -1);
%     
%     if current < 1 | current >= length(annotations)
%         ia_setColors(newObj);
%         feval(getLocal(progmanager, newObj, 'annotationDisplayUpdateFcn'), getLocal(progmanager, newObj, 'annotationObject'));
%         return;
%     end
%    
% %     oldSpan = round(3 * mean([abs(oldAnnotation(oldCurrent).x(2) - oldAnnotation(oldCurrent).x(1)) abs(oldAnnotation(oldCurrent).y(2) - oldAnnotation(oldCurrent).y(1))]));
%     span = abs(getLocal(progmanager, oldObj, 'xBoundHigh') - getLocal(progmanager, oldObj, 'xBoundLow')) / 2;
% end
% 
% x = sort([annotations(current).x(1) annotations(current).x(2)]) + [-1*span span];
% y = sort([annotations(current).y(1) annotations(current).y(2)]) + [-1*span span];
% 
% if abs(x(1) - x(2)) > 2 * span
%     x(2) = x(1) + 2 * span;
% end
% 
% if abs(y(1) - y(2)) > 2 * span
%     y(2) = y(1) + 2 * span;
% end
% 
% setLocal(progmanager, newObj, 'xBoundLow', x(1));
% setLocal(progmanager, newObj, 'xBoundHigh', x(2));
% setLocal(progmanager, newObj, 'yBoundLow', y(1));
% setLocal(progmanager, newObj, 'yBoundHigh', y(2));
% 
% % warning('new: [%s %s %s %s]\n', getLocal(progmanager, newObj, 'xBoundLow'), getLocal(progmanager, newObj, 'xBoundHigh'), ...
% %     getLocal(progmanager, newObj, 'yBoundLow'), getLocal(progmanager, newObj, 'yBoundHigh'));
% 
% if annotations(current).z(1) == getLocal(progmanager, newObj, 'frameNumber')
%     feval(getLocal(progmanager, newObj, 'updateImageDisplay'), newObj);
% else
%     setLocal(progmanager, newObj, 'frameNumber', annotations(current).z(1));
%     feval(getLocal(progmanager, newObj, 'displayNewImage'), newObj);
% end
% 
% ia_setColors(newObj);
% feval(getLocal(progmanager, newObj, 'annotationDisplayUpdateFcn'), getLocal(progmanager, newObj, 'annotationObject'));
% 
% return;

% % ------------------------------------------------------------------
% function setZooms(hObject)
% 
% setOldZoom(hObject);
% setNewZoom(hObject);
% 
% return;
% 
% % ------------------------------------------------------------------
% function setColors(hObject)
% 
% oldObj = getLocal(progmanager, hObject, 'oldObj');
% newObj = getLocal(progmanager, hObject, 'newObj');
% ia_setColors(oldObj);
% ia_setColors(newObj);
% 
% return;

% ------------------------------------------------------------------
function constructMaps(hObject, varargin)

if isempty(varargin)
    constructOldMap(hObject, 'line');
    constructNewMap(hObject, 'line');
else
    constructOldMap(hObject, varargin{1});
    constructNewMap(hObject, varargin{1});
end

return;

% ------------------------------------------------------------------
function constructOldMap(hObject, type)

oldObj = getLocal(progmanager, hObject, 'oldObj');
if isempty(oldObj)
    setLocal(progmanager, hObject, 'oldMap', []);
    setLocal(progmanager, hObject, 'oldStart', -1);
    setLocal(progmanager, hObject, 'oldUsed', []);
    return;
end

oldAnnotations = getLocal(progmanager, oldObj, 'annotations');
if isempty(oldAnnotations)
    setLocal(progmanager, hObject, 'oldMap', []);
    setLocal(progmanager, hObject, 'oldStart', -1);
    setLocal(progmanager, hObject, 'oldUsed', []);
    return;
end

oldCoords = [];
oldRemap = [];
for i = 1 : length(oldAnnotations)
    if strcmpi(oldAnnotations(i).type, type)
        oldCoords(size(oldCoords, 1) + 1, 1) = oldAnnotations(i).x(1);
        oldCoords(size(oldCoords, 1), 2) = oldAnnotations(i).y(1);
        oldRemap(size(oldCoords, 1)) = i;
    end
end

if ~isempty(oldCoords)
    [val oldStart] = min(oldCoords(:, 1) + oldCoords(:, 2));
    setLocal(progmanager, hObject, 'oldStart', oldRemap(oldStart));
    
    oldDist = pdist(oldCoords);
    
    oldMap = [];
    j = 1;
    k = 2;
    for i = 1 : length(oldDist)
        oldMap(i, 1) = oldRemap(j);
        oldMap(i, 2) = oldRemap(k);
        oldMap(i, 3) = oldDist(i);
        if k < length(oldRemap)
            k = k + 1;
        else
            j = j + 1;
            k = j + 1;
        end
    end
    if size(oldMap, 1) > 1
        oldMap = sortrows(oldMap, [3 1 2]);%TO062007C - Case sensitivity.
    end
    setLocal(progmanager, hObject, 'oldMap', oldMap);
    setLocal(progmanager, hObject, 'oldUsed', oldRemap(oldStart));
else
    setLocal(progmanager, hObject, 'oldMap', []);
    setLocal(progmanager, hObject, 'oldStart', -1);
    setLocal(progmanager, hObject, 'oldUsed', []);
end

return;

% ------------------------------------------------------------------
function constructNewMap(hObject, type)

newObj = getLocal(progmanager, hObject, 'newObj');
if isempty(newObj)
    setLocal(progmanager, hObject, 'newMap', []);
    setLocal(progmanager, hObject, 'newStart', -1);
    setLocal(progmanager, hObject, 'newUsed', []);
    return;
end

newAnnotations = getLocal(progmanager, newObj, 'annotations');
if isempty(newAnnotations)
    setLocal(progmanager, hObject, 'newMap', []);
    setLocal(progmanager, hObject, 'newStart', -1);
    setLocal(progmanager, hObject, 'newUsed', []);
    return;
end

newCoords = [];
newRemap = [];
for i = 1 : length(newAnnotations)
    if strcmpi(newAnnotations(i).type, type)
        newCoords(size(newCoords, 1) + 1, 1) = newAnnotations(i).x(1);
        newCoords(size(newCoords, 1), 2) = newAnnotations(i).y(1);
        newRemap(size(newCoords, 1)) = i;
    end
end
if ~isempty(newCoords)
    [val newStart] = min(newCoords(:, 1) + newCoords(:, 2));
    setLocal(progmanager, hObject, 'newStart', newRemap(newStart));
    newDist = pdist(newCoords);
    newMap = [];
    j = 1;
    k = 2;
    for i = 1 : length(newDist)
        newMap(i, 1) = newRemap(j);
        newMap(i, 2) = newRemap(k);
        newMap(i, 3) = newDist(i);
        if k < length(newRemap)
            k = k + 1;
        else
            j = j + 1;
            k = j + 1;
        end
    end
    if size(newMap, 1) > 1
        newMap = sortrows(newMap, [3 1 2]);%TO062007C - Case sensitivity.
    end
    setLocal(progmanager, hObject, 'newMap', newMap);
    setLocal(progmanager, hObject, 'newUsed', newRemap(newStart));
else
    setLocal(progmanager, hObject, 'newMap', []);
    setLocal(progmanager, hObject, 'newStart', -1);
    setLocal(progmanager, hObject, 'newUsed', []);
end

return;

% fprintf(1, '\nOld\n');
% for i = 1 : size(oldMap, 1)
%     fprintf(1, '%s <--> %s: %s\n', num2str(oldMap(i, 1)), num2str(oldMap(i, 2)), num2str(oldMap(i, 3)));
% end
% fprintf(1, '\n\n');



% fprintf(1, '\nNew\n');
% for i = 1 : length(newDist)
%     for j = i + 1 : size(newCoords, 1)
%         fprintf(1, '%s <--> %s: %s\n', num2str(newMap(i + j - 2, 1)), num2str(newMap(i + j - 2, 2)), num2str(newMap(i + j - 2, 3)));
%     end
% end

% ------------------------------------------------------------------
function next = traverseMap(map, current, used)

next = -1;

if isempty(map)
    return;
end

%Find the lowest possible step out of the left column
left = find(map(:, 1) == current);
left = left(find(~ismember(map(left, 2), used)));
[val pos] = min(map(left, 3));
if ~isempty(pos)
    left = left(pos(1)) ;
end

%Find the lowest possible step out of the right column.
right = find(map(:, 2) == current);
right = right(find(~ismember(map(right, 1), used)));
[val pos] = min(map(right, 3));
if ~isempty(pos)
    right = right(pos(1));
end

%Choose the correct (lowest distance) one.
if ~isempty(right) & ~isempty(left)
    if map(right, 3) > map(left, 3)
        next = map(left, 2);
    else
        next = map(right, 1);
    end
elseif isempty(right) & ~isempty(left)
    next = map(left, 2);
elseif isempty(left) & ~isempty(right)
    next = map(right, 1);
end
% fprintf(1, 'From %s to %s.\n', num2str(current), num2str(next));
return;

% ------------------------------------------------------------------
function next = stepOld(hObject)

if ~getLocal(progmanager, hObject, 'correlationRunning')
    return;
end

next = traverseMap(getLocal(progmanager, hObject, 'oldMap'), getLocal(progmanager, hObject, 'oldPosition'), ...
    getLocal(progmanager, hObject, 'oldUsed'));

oldObj = getLocal(progmanager, hObject, 'oldObj');

if next < 1
    setLocal(progmanager, hObject, 'oldPosition', -1);
    setLocal(progmanager, oldObj, 'currentAnnotation', -1);
else
    used = getLocal(progmanager, hObject, 'oldUsed');
    used(length(used) + 1) = next;
    setLocal(progmanager, hObject, 'oldUsed', used);
    setLocal(progmanager, hObject, 'oldPosition', next);

%     if next >= 1 & next <= length(annotations)
%         setLocal(progmanager, oldObj, 'currentAnnotation', next);
%     else
%         newObj = getLocal(progmanager, hObject, 'newObj');
%         annotations = getLocal(progmanager, newObj, 'annotations');
%         current = getLocal(progmanager, hObject, 'newPosition');
%         
%         setLocal(progmanager, oldObj, 'currentAnnotation', -1);
%         
%         if current < 1 | current >= length(annotations)
%             ia_setColors(oldObj);
%             feval(getLocal(progmanager, oldObj, 'annotationDisplayUpdateFcn'), getLocal(progmanager, oldObj, 'annotationObject'));
%             return;
%         end
%     end
    
    oldObj = getLocal(progmanager, hObject, 'oldObj');
    setLocal(progmanager, oldObj, 'currentAnnotation', next);
%     ia_setColors(oldObj);
end

ia_setColors(oldObj);
feval(getLocal(progmanager, oldObj, 'annotationDisplayUpdateFcn'), getLocal(progmanager, oldObj, 'annotationObject'));

% if getLocal(progmanager, hObject, 'newPosition') < 1 | ...
%         isempty(getLocal(progmanager, getLocal(progmanager, hObject, 'newObj'), 'annotations'))
%     setLocal(progmanager, hObject, 'newPosition', -1);
%     setLocal(progmanager, getLocal(progmanager, hObject, 'newObj'), 'currentAnnotation', next);
%     setNewZoom(hObject);
% end

% setOldZoom(hObject);

return;

% ------------------------------------------------------------------
function next = stepNew(hObject)

if ~getLocal(progmanager, hObject, 'correlationRunning')
    return;
end

next = traverseMap(getLocal(progmanager, hObject, 'newMap'), getLocal(progmanager, hObject, 'newPosition'), ...
    getLocal(progmanager, hObject, 'newUsed'));

newObj = getLocal(progmanager, hObject, 'newObj');

if next < 1
    setLocal(progmanager, hObject, 'newPosition', -1);
    setLocal(progmanager, newObj, 'currentAnnotation', -1);
else
    used = getLocal(progmanager, hObject, 'newUsed');
    used(length(used) + 1) = next;
    setLocal(progmanager, hObject, 'newUsed', used);
    setLocal(progmanager, hObject, 'newPosition', next);
    
    newObj = getLocal(progmanager, hObject, 'newObj');
    setLocal(progmanager, newObj, 'currentAnnotation', next);
%     ia_setColors(newObj);
end

ia_setColors(newObj);
feval(getLocal(progmanager, newObj, 'annotationDisplayUpdateFcn'), getLocal(progmanager, newObj, 'annotationObject'));

% setNewZoom(hObject);

return;
% next = traverseMap(getLocal(progmanager, hObject, 'newMap'), getLocal(progmanager, hObject, 'newPosition'), ...
%     getLocal(progmanager, hObject, 'newUsed'));
% 
% if next < 1
%     setLocal(progmanager, hObject, 'newPosition', -1);
%     ia_setColors(getLocal(progmanager, hObject, 'newObj'));
%     return;
% else
%     used = getLocal(progmanager, hObject, 'newUsed');
%     used(length(used) + 1) = next;
%     setLocal(progmanager, hObject, 'newUsed', used);
%     setLocal(progmanager, hObject, 'newPosition', next);
%     
%     if next >= 1 & next <= length(annotations)
%         setLocal(progmanager, oldObj, 'currentAnnotation', next);
%     else
%         oldObj = getLocal(progmanager, hObject, 'oldObj');
%         annotations = getLocal(progmanager, oldObj, 'annotations');
%         current = getLocal(progmanager, hObject, 'oldPosition');
%         
%         setLocal(progmanager, newObj, 'currentAnnotation', -1);
%         
%         if current < 1 | current >= length(annotations)
%             ia_setColors(newObj);
%             feval(getLocal(progmanager, newObj, 'annotationDisplayUpdateFcn'), getLocal(progmanager, newObj, 'annotationObject'));
%             return;
%         end
%         
%         span = abs(getLocal(progmanager, oldObj, 'xBoundHigh') - getLocal(progmanager, oldObj, 'xBoundLow')) / 2;
%     end
%     setLocal(progmanager, hObject, 'currentAnnotation', next);
%     ia_setColors(hObject);
%     feval(getLocal(progmanager, hObject, 'annotationDisplayUpdateFcn'), getLocal(progmanager, hObject, 'annotationObject'));
% %     setNewZoom(hObject);
% end
% 
% % if traverseMap(getLocal(progmanager, hObject, 'oldMap'), getLocal(progmanager, hObject, 'oldPosition'), ...
% %     getLocal(progmanager, hObject, 'oldUsed')) < 1
% if getLocal(progmanager, hObject, 'oldPosition') < 1 | ...
%         isempty(getLocal(progmanager, getLocal(progmanager, hObject, 'oldObj'), 'annotations'))
%     used = getLocal(progmanager, hObject, 'oldUsed');
%     used(length(used) + 1) = next;
%     setLocal(progmanager, hObject, 'oldUsed', used);
%     setLocal(progmanager, hObject, 'oldPosition', -1);
% %     setOldZoom(hObject);
% end
% 
% return;

% ------------------------------------------------------------------
function step(hObject)

old = stepOld(hObject);
new = stepNew(hObject);

if old < 1 & new >= 1
    used = getLocal(progmanager, hObject, 'oldUsed');
    used(length(used) + 1) = new;
    setLocal(progmanager, hObject, 'oldUsed', used);
    setLocal(progmanager, hObject, 'oldPosition', new);
%     setOldZoom(hObject);
elseif old >=1 & new < 1
    used = getLocal(progmanager, hObject, 'newUsed');
    used(length(used) + 1) = old;
    setLocal(progmanager, hObject, 'newUsed', used);
    setLocal(progmanager, hObject, 'newPosition', old);
%     setNewZoom(hObject);
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in lossButton.
function lossButton_Callback(hObject, eventdata, handles)

oldObj = getLocal(progmanager, hObject, 'oldObj');
oldAnnotations = getLocal(progmanager, oldObj, 'annotations');
index = getLocal(progmanager, oldObj, 'currentAnnotation');
if oldAnnotations(index).persistence ~= 3
    oldAnnotations(index).persistence = 2;
elseif oldAnnotations(index).persistence == 3
    oldAnnotations(index).persistence = 4;
end
setLocal(progmanager, oldObj, 'annotations', oldAnnotations);

correlated = getLocal(progmanager, oldObj, 'correlatedAnnotations');
correlated(length(correlated) + 1) = index;
setLocal(progmanager, oldObj, 'correlatedAnnotations', correlated);

%Make sure this ID doesn't turn up in the next day.
newObj = getLocal(progmanager, hObject, 'newObj');
newAnnotations = getLocal(progmanager, newObj, 'annotations');
for i = 1 : length(newAnnotations)
    if newAnnotations(i).correlationID == oldAnnotations(index).correlationID
        newAnnotations(i).correlationID = ia_getNewCorrelationID;
    end
end

nodeCounter = getLocal(progmanager, hObject, 'nodeCounter');
setLocal(progmanager, hObject, 'nodeCounter', nodeCounter + 1);

if ~checkForCompletion(hObject) & getLocal(progmanager, hObject, 'correlationRunning')
    %Keep looking for the corrollary to the new one.
    oldPosition = getLocal(progmanager, hObject, 'oldPosition');
    if oldPosition == index
        stepOld(hObject);
    else
        oldUsed = getLocal(progmanager, hObject, 'oldUsed');
        oldUsed(length(oldUsed) + 1) = index;
        setLocal(progmanager, hObject, 'oldUsed', oldUsed);
        setLocal(progmanager, oldObj, 'currentAnnotation', oldPosition);
    end
    
    if getLocal(progmanager, hObject, 'oldAutoCenter')
        setOldZoom(hObject);
    end
end

%Update the display windows.
feval(getLocal(progmanager, oldObj, 'annotationDisplayUpdateFcn'), getLocal(progmanager, oldObj, 'annotationObject'));
feval(getLocal(progmanager, newObj, 'annotationDisplayUpdateFcn'), getLocal(progmanager, newObj, 'annotationObject'));
ia_setColors(oldObj);
ia_setColors(newObj);

ia_annotationModified(oldObj, index);

return;

% ------------------------------------------------------------------
% --- Executes on button press in equalButton.
function equalButton_Callback(hObject, eventdata, handles)

%Mark the old one as stable (if it's not a gain).
oldObj = getLocal(progmanager, hObject, 'oldObj');
oldAnnotations = getLocal(progmanager, oldObj, 'annotations');
oldIndex = getLocal(progmanager, oldObj, 'currentAnnotation');
if oldAnnotations(oldIndex).persistence ~= 3
    oldAnnotations(oldIndex).persistence = 1;
end

%Set the new one to have the same ID as the old, and mark it as stable (if it's not a loss).
newObj = getLocal(progmanager, hObject, 'newObj');
newAnnotations = getLocal(progmanager, newObj, 'annotations');
newIndex = getLocal(progmanager, newObj, 'currentAnnotation');
if newAnnotations(newIndex).persistence ~= 2
    newAnnotations(newIndex).persistence = 1;
end
newAnnotations(newIndex).correlationID = oldAnnotations(oldIndex).correlationID;

resolution = '';
collision = -1;

nextCorrelationId = getGlobal(progmanager, 'nextCorrelationId', 'stackBrowserControl', 'StackBrowserControl');
if oldAnnotations(oldIndex).correlationID < nextCorrelationId
    for i = 1 : length(newAnnotations)
        if i ~= newIndex & newAnnotations(i).correlationID == oldAnnotations(oldIndex).correlationID
            resolution = questdlg('Another annotation with the same correlationID exists in this dataset.', 'CorrelationID Collision', ...
                'Auto Resolve', 'Manually Resolve', 'Cancel Change', 'Manually Resolve');
            collision = i;
            break;
        end
    end
end

if strcmpi(resolution, 'Cancel Change')
    return;
elseif strcmpi(resolution, 'Auto Resolve')
    newAnnotations(collision).correlationID = ia_getNewCorrelationId;
elseif strcmpi(resolution, 'Manually Resolve')
    %Jump to this annotation, let the user give it a new  ID.
    setMain(progmanager, newObj, 'currentAnnotation', collision);
    feval(getLocal(progmanager, newObj, 'centerOnAnnotation'), newObj);
    ia_setColors(newObj);
end

setLocal(progmanager, oldObj, 'annotations', oldAnnotations);
setLocal(progmanager, newObj, 'annotations', newAnnotations);

oldCorrelated = getLocal(progmanager, oldObj, 'correlatedAnnotations');
oldCorrelated(length(oldCorrelated) + 1) = oldIndex;
setLocal(progmanager, oldObj, 'correlatedAnnotations', oldCorrelated);

newCorrelated = getLocal(progmanager, newObj, 'correlatedAnnotations');
newCorrelated(length(newCorrelated) + 1) = newIndex;
setLocal(progmanager, newObj, 'correlatedAnnotations', newCorrelated);

setLocal(progmanager, hObject, 'newAnnotations', newAnnotations);

nodeCounter = getLocal(progmanager, hObject, 'nodeCounter');
setLocal(progmanager, hObject, 'nodeCounter', nodeCounter + 2);

if ~checkForCompletion(hObject) & getLocal(progmanager, hObject, 'correlationRunning')
    %Jump to the next pair.
    oldPosition = getLocal(progmanager, hObject, 'oldPosition');
    if oldPosition == oldIndex
        stepOld(hObject);
    else
        newUsed = getLocal(progmanager, hObject, 'oldUsed');
        newUsed(length(oldUsed) + 1) = oldIndex;
        setLocal(progmanager, hObject, 'oldUsed', oldUsed);
        setLocal(progmanager, oldObj, 'currentAnnotation', oldPosition);
    end
    
    if getLocal(progmanager, hObject, 'oldAutoCenter')
        setOldZoom(hObject);
    end
    
    newPosition = getLocal(progmanager, hObject, 'newPosition');
    if newPosition == newIndex
        stepNew(hObject);
    else
        newUsed = getLocal(progmanager, hObject, 'newUsed');
        newUsed(length(newUsed) + 1) = newIndex;
        setLocal(progmanager, hObject, 'newUsed', newUsed);
        setLocal(progmanager, newObj, 'currentAnnotation', newPosition);
    end
    if getLocal(progmanager, hObject, 'newAutoCenter')
        setNewZoom(hObject);
    end
end

%Update the display windows.
feval(getLocal(progmanager, oldObj, 'annotationDisplayUpdateFcn'), getLocal(progmanager, oldObj, 'annotationObject'));
feval(getLocal(progmanager, newObj, 'annotationDisplayUpdateFcn'), getLocal(progmanager, newObj, 'annotationObject'));
ia_setColors(oldObj);
ia_setColors(newObj);

ia_annotationModified(oldObj, oldIndex);
ia_annotationModified(newObj, newIndex);

return;

% ------------------------------------------------------------------
% --- Executes on button press in gainButton.
function gainButton_Callback(hObject, eventdata, handles)

newObj = getLocal(progmanager, hObject, 'newObj');
newAnnotations = getLocal(progmanager, newObj, 'annotations');
index = getLocal(progmanager, newObj, 'currentAnnotation');
if newAnnotations(index).persistence == 2
    newAnnotations(index).persistence == 4;
else
    newAnnotations(index).persistence = 3;
end
newAnnotations(index).correlationID = ia_getNewCorrelationID;
setLocal(progmanager, newObj, 'annotations', newAnnotations);

correlated = getLocal(progmanager, newObj, 'correlatedAnnotations');
correlated(length(correlated) + 1) = index;
setLocal(progmanager, newObj, 'correlatedAnnotations', correlated);

nodeCounter = getLocal(progmanager, hObject, 'nodeCounter');
setLocal(progmanager, hObject, 'nodeCounter', nodeCounter + 1);

if ~checkForCompletion(hObject) & getLocal(progmanager, hObject, 'correlationRunning')
    %Keep looking for the corrollary to the old one.
    newPosition = getLocal(progmanager, hObject, 'newPosition');
    newPosition = getLocal(progmanager, hObject, 'newPosition');
    if newPosition == index
        stepNew(hObject);
    else
        newUsed = getLocal(progmanager, hObject, 'newUsed');
        newUsed(length(newUsed) + 1) = index;
        setLocal(progmanager, hObject, 'newUsed', newUsed);
        setLocal(progmanager, newObj, 'currentAnnotation', newPosition);
    end
    
    if getLocal(progmanager, hObject, 'newAutoCenter')
        setNewZoom(hObject);
    end
end

%Update the display windows.
feval(getLocal(progmanager, newObj, 'annotationDisplayUpdateFcn'), getLocal(progmanager, newObj, 'annotationObject'));
ia_setColors(newObj);
ia_annotationModified(newObj, index);

return;

% ------------------------------------------------------------------
function done = checkForCompletion(hObject)

done = 0;

if ~getLocal(progmanager, hObject, 'correlationRunning')
    done = 1;
    return;
end

nodeCounter = getLocal(progmanager, hObject, 'nodeCounter');

oldAnnotations = getLocal(progmanager, getLocal(progmanager, hObject, 'oldObj'), 'annotations');
newAnnotations = getLocal(progmanager, getLocal(progmanager, hObject, 'newObj'), 'annotations');

if nodeCounter > length(newAnnotations) + length(oldAnnotations)
    msgbox('Correlation complete.', 'Congratulations');
    
    if getLocal(progmanager, hObject, 'inconsistencyFound')
        msgbox(sprintf('A non-trivial inconsistency emerged during correlation and was dealt with.\nYou may want to rerun the correlation to review it.'), ...
            'Correlation Warning', 'warn');
    end
    
    stopCorrelation_Callback(hObject);
end

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function oldFilename_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function oldFilename_Callback(hObject, eventdata, handles)

names = get(getLocalGh(progmanager, hObject, 'oldFilename'), 'String');
oldFilename = names{getLocal(progmanager, hObject, 'oldFilename')};
programs = getGlobal(progmanager, 'subPrograms', 'stackBrowserControl', 'StackBrowserControl');
for i = 1 : length(programs)
    if ~strcmpi(getProgramName(progmanager, programs{i}), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
        figHandle = getFigHandle(progmanager, programs{i});
        if strcmpi(getLocal(progmanager, figHandle, 'fileName'), oldFilename)
            setLocal(progmanager, hObject, 'oldObj', figHandle);
            return;
        end
    end
end

warning('Unable to find browser displaying file: %s', oldFilename);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function newFilename_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function newFilename_Callback(hObject, eventdata, handles)

names = get(getLocalGh(progmanager, hObject, 'newFilename'), 'String');
newFilename = names{getLocal(progmanager, hObject, 'newFilename')};
programs = getGlobal(progmanager, 'subPrograms', 'stackBrowserControl', 'StackBrowserControl');
for i = 1 : length(programs)
    if ~strcmpi(getProgramName(progmanager, programs{i}), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
        figHandle = getFigHandle(progmanager, programs{i});
        if strcmpi(getLocal(progmanager, figHandle, 'fileName'), newFilename)
            setLocal(progmanager, hObject, 'newObj', figHandle);
            return;
        end
    end
end

warning('Unable to find browser displaying file: %s', newFilename);

return;

% setLocal(progmanager, hObject, 'newFilename', getLocal(progmanager, getLocal(progmanager, hObject, 'newObj'), 'fileNameDisplay'));

return;

% --------------------------------------------------------------------
function semiManualCorrelateMenuOption_Callback(hObject, eventdata, handles)

if isempty(getLocal(progmanager, hObject, 'oldObj')) | isempty(getLocal(progmanager, hObject, 'oldObj'))
    msgbox('Not enough images are available to do a correlation.', 'Need More Images', 'warn');
    return;
end

constructMaps(hObject);
setLocal(progmanager, hObject, 'oldPosition', getLocal(progmanager, hObject, 'oldStart'));
setLocal(progmanager, hObject, 'newPosition', getLocal(progmanager, hObject, 'newStart'));

setOldZoom(hObject);
setNewZoom(hObject);

oldObj = getLocal(progmanager, hObject, 'oldObj');
feval(getLocal(progmanager, oldObj, 'annotationDisplayUpdateFcn'), getLocal(progmanager, oldObj, 'annotationObject'));
setLocal(progmanager, oldObj, 'correlatedAnnotations', []);
ia_setColors(oldObj);

newObj = getLocal(progmanager, hObject, 'newObj');
feval(getLocal(progmanager, newObj, 'annotationDisplayUpdateFcn'), getLocal(progmanager, newObj, 'annotationObject'));
setLocal(progmanager, newObj, 'correlatedAnnotations', []);
ia_setColors(newObj);

setLocal(progmanager, hObject, 'nodeCounter', 1);

setLocalGh(progmanager, hObject, 'lossButton', 'Enable', 'On');    
setLocalGh(progmanager, hObject, 'equalButton', 'Enable', 'On');
setLocalGh(progmanager, hObject, 'gainButton', 'Enable', 'On');

setLocal(progmanager, hObject, 'inconsistencyFound', 0);

setLocal(progmanager, hObject, 'correlationRunning', 1);
setLocal(progmanager, hObject, 'correlationStarted', 1);

return;

% --------------------------------------------------------------------
% --- Executes on button press in oldBack.
function oldBack_Callback(hObject, eventdata, handles)

oldUsed = getLocal(progmanager, hObject, 'oldUsed');

if length(oldUsed) <= 1
    return;
end

setLocal(progmanager, hObject, 'oldPosition', oldUsed(length(oldUsed) - 1));
setOldZoom(hObject);
ia_setColors(getLocal(progmanager, hObject, 'oldObj'));

oldUsed = oldUsed(1 : length(oldUsed) - 1);
setLocal(progmanager, hObject, 'oldUsed', oldUsed);

return;

% --------------------------------------------------------------------
% --- Executes on button press in newBack.
function newBack_Callback(hObject, eventdata, handles)

newUsed = getLocal(progmanager, hObject, 'newUsed');
if length(newUsed) <= 1
    return;
end

setLocal(progmanager, hObject, 'newPosition', newUsed(length(newUsed) - 1));
setNewZoom(hObject);
ia_setColors(getLocal(progmanager, hObject, 'newObj'));

newUsed = newUsed(1 : length(newUsed) - 1);
setLocal(progmanager, hObject, 'newUsed', newUsed);

return;

% --------------------------------------------------------------------
% --- Executes on button press in oldForward.
function oldForward_Callback(hObject, eventdata, handles)

stepOld(hObject);
setOldZoom(hObject);

return;

% --------------------------------------------------------------------
% --- Executes on button press in newForward.
function newForward_Callback(hObject, eventdata, handles)

stepNew(hObject);
setNewZoom(hObject);

return;

% --------------------------------------------------------------------
% --- Executes on button press in drawNew.
function drawNew_Callback(hObject, eventdata, handles)

newObj = getLocal(progmanager, hObject, 'newObj');

ia_annotate(newObj);

setLocal(progmanager, hObject, 'newPosition', getLocal(progmanager, newObj, 'currentAnnotation'));
setNewZoom(hObject);

stepOld(hObject);
stepNew(hObject);

return;

% --------------------------------------------------------------------
% --- Executes on button press in drawOld.
function drawOld_Callback(hObject, eventdata, handles)

oldObj = getLocal(progmanager, hObject, 'oldObj');

ia_annotate(oldObj);

setLocal(progmanager, hObject, 'oldPosition', getLocal(progmanager, oldObj, 'currentAnnotation'));
setOldZoom(hObject);

stepOld(hObject);
stepNew(hObject);

return;

% --------------------------------------------------------------------
function annotationAddedDuringCorrelation(hObject, windowObj)

if ~getLocal(progmanager, hObject, 'correlationRunning')
    return;
end

oldObj = getLocal(progmanager, hObject, 'oldObj');
newObj = getLocal(progmanager, hObject, 'newObj');
f = getParent(windowObj, 'figure');

oldUsed = getLocal(progmanager, hObject, 'oldUsed');
newUsed = getLocal(progmanager, hObject, 'newUsed');
nodeCounter = getLocal(progmanager, hObject, 'nodeCounter');

same = questdlg('Does this annotation correlate to the current one in the other window?', 'Correlation', 'Yes', 'No', 'Yes');
if strcmpi(same, 'Yes')
    equalButton_Callback(hObject, [], []);
    if f == getParent(oldObj, 'figure')
%         oldBack_Callback(hObject);
    elseif f == getParent(newObj, 'figure')
%         newBack_Callback(hObject);
    end
else
    if f == getParent(oldObj, 'figure')
        lossButton_Callback(hObject, [], []);
%         if getLocal(progmanager, hObject, 'oldPosition') >= 1
%             oldBack_Callback(hObject, [], []);
%         end
        nodeCounter = nodeCounter + 1;
    elseif f == getParent(newObj, 'figure')
        gainButton_Callback(hObject, [], []);
%         if getLocal(progmanager, hObject, 'newPosition') >= 1
%             newBack_Callback(hObject, [], []);
%         end
        nodeCounter = nodeCounter + 1;
    else
        fprintf(2, 'Warning: Annotation added to a window that is not part of the current correlation.\n');
    end

    setLocal(progmanager, hObject, 'oldUsed', oldUsed);
    setLocal(progmanager, hObject, 'newUsed', newUsed);
    setLocal(progmanager, hObject, 'nodeCounter', nodeCounter);
    
    setLocal(progmanager, hObject, 'inconsistencyFound', 1);
end

return;

% --------------------------------------------------------------------
function annotationDeletedDuringCorrelation(hObject, windowObj)

if ~getLocal(progmanager, hObject, 'correlationRunning')
    return;
end

oldObj = getLocal(progmanager, hObject, 'oldObj');
newObj = getLocal(progmanager, hObject, 'newObj');
f = getParent(windowObj, 'figure');

same = questdlg('Did that annotation correlate to the current one in the other window?', 'Correlation', 'Yes', 'No', 'Yes');
if strcmpi(same, 'Yes')
    if f == getParent(newObj, 'figure')
        lossButton_Callback(hObject, [], []);
    elseif f == getParent(oldObj, 'figure')
        gainButton_Callback(hObject, [], []);
    else
        fprintf(2, 'Warning: Annotation deleted from a window that is not part of the current correlation.\n');
    end
else
% if f == getParent(newObj, 'figure')
%         annotations = getLocal(progmanager, getLocal(progmanager, hObject, 'oldObj'), 'annotations');
%     elseif f == getParent(oldObj, 'figure')
%         annotations = getLocal(progmanager, getLocal(progmanager, hObject, 'oldObj'), 'annotations');
%     else
%         fprintf(2, 'Warning: Annotation deleted from a window that is not part of the current correlation.\n');
%     end
end

%     oldUsed = getLocal(progmanager, hObject, 'oldUsed');
%     newUsed = getLocal(progmanager, hObject, 'newUsed');
%     oldPosition = getLocal(progmanager, hObject, 'oldPosition');
%     newPosition = getLocal(progmanager, hObject, 'newPosition');
%     
%     constructMap(hObject);
%     
%     setLocal(progmanager, hObject, 'oldUsed', oldUsed);
%     setLocal(progmanager, hObject, 'newUsed', newUsed);
%     setLocal(progmanager, hObject, 'oldPosition', oldPosition);
%     setLocal(progmanager, hObject, 'newPosition', newPosition);
%     
%     setOldZoom(hObject);
%     setNewZoom(hObject);

return;


% --------------------------------------------------------------------
function stopCorrelation_Callback(hObject, eventdata, handles)

done = 1;
% setLocalGh(progmanager, hObject, 'lossButton', 'Enable', 'Off');    
% setLocalGh(progmanager, hObject, 'equalButton', 'Enable', 'Off');
% setLocalGh(progmanager, hObject, 'gainButton', 'Enable', 'Off');
setLocal(progmanager, hObject, 'correlationRunning', 0);
setLocal(progmanager, hObject, 'oldUsed', []);
setLocal(progmanager, getLocal(progmanager, hObject, 'oldObj'), 'correlatedAnnotations', []);
setLocal(progmanager, hObject, 'newUsed', []);
setLocal(progmanager, getLocal(progmanager, hObject, 'newObj'), 'correlatedAnnotations', []);
setLocal(progmanager, hObject, 'correlationStarted', 0);

return;

% --------------------------------------------------------------------
function imagesMenu_Callback(hObject, eventdata, handles)

return;

% --------------------------------------------------------------------
function registerByFiducialPointsMenuItem_Callback(hObject, eventdata, handles)

oldObj = getLocal(progmanager, hObject, 'oldObj');
newObj = getLocal(progmanager, hObject, 'newObj');

oldAnnotations = getLocal(progmanager, oldObj, 'annotations');
newAnnotations = getLocal(progmanager, newObj, 'annotations');

oldPoints = [];
for i = 1 : length(oldAnnotations)
    if strcmpi(oldAnnotations(i).type, 'point')
        oldPoints(size(oldPoints, 1) + 1, 1) = oldAnnotations(i).x(1);
        oldPoints(size(oldPoints, 1), 2) = oldAnnotations(i).y(1);
        oldPoints(size(oldPoints, 1), 3) = oldAnnotations(i).correlationID;
    end
end
if isempty(oldPoints)
    errordlg('No fiducial points defined on the older image.');
    return;
end
oldPoints = sortrows(oldPoints, 3);

newPoints = [];
for i = 1 : length(newAnnotations)
    if strcmpi(newAnnotations(i).type, 'point')
        newPoints(size(newPoints, 1) + 1, 1) = newAnnotations(i).x(1);
        newPoints(size(newPoints, 1), 2) = newAnnotations(i).y(1);
        newPoints(size(newPoints, 1), 3) = newAnnotations(i).correlationID;
    end
end
if isempty(newPoints)
    errordlg('No fiducial points defined on the newer image.');
    return;
end
newPoints = sortrows(newPoints, 3);

if any(oldPoints(:, 3) ~= newPoints(:, 3))
    fprintf(2, 'WARNING: Fiducial points have not been correlated. Image registration will proceed anyway.\n');
end

if ~all(size(newPoints) == size(oldPoints))
    msgbox('The two images contain an unequal number of fiducial points.', 'Unmatched Fiducial Points', 'warn');
end

tform = cp2tform(newPoints(:, 1:2), oldPoints(:, 1:2), 'linear conformal');
setLocal(progmanager, oldObj, 'registrationTransform', []);
setLocal(progmanager, newObj, 'registrationTransform', tform);
feval(getLocal(progmanager, newObj, 'applyTransform'), newObj);

return;

% --------------------------------------------------------------------
function deregister_Callback(hObject, eventdata, handles)

setLocal(progmanager, oldObj, 'registrationTransform', []);
setLocal(progmanager, newObj, 'registrationTransform', []);
feval(getLocal(progmanager, newObj, 'displayNewImage'), newObj);

return;

% --------------------------------------------------------------------
function registerByCrosscorrelationMenuItem_Callback(hObject, eventdata, handles)

return;

% --------------------------------------------------------------------
function correlateFiducialPointsMenuItem_Callback(hObject, eventdata, handles)

if isempty(getLocal(progmanager, hObject, 'oldObj')) | isempty(getLocal(progmanager, hObject, 'oldObj'))
    msgbox('Not enough images are available to do a correlation.', 'Need More Images', 'warn');
    return;
end

constructMaps(hObject, 'point');
setLocal(progmanager, hObject, 'oldPosition', getLocal(progmanager, hObject, 'oldStart'));
setLocal(progmanager, hObject, 'newPosition', getLocal(progmanager, hObject, 'newStart'));

setOldZoom(hObject);
setNewZoom(hObject);

setLocal(progmanager, hObject, 'nodeCounter', 1);

setLocalGh(progmanager, hObject, 'lossButton', 'Enable', 'On');    
setLocalGh(progmanager, hObject, 'equalButton', 'Enable', 'On');
setLocalGh(progmanager, hObject, 'gainButton', 'Enable', 'On');

setLocal(progmanager, hObject, 'inconsistencyFound', 0);

setLocal(progmanager, hObject, 'correlationRunning', 1);

return;

% --------------------------------------------------------------------
% --- Executes on button press in newCenter.
function newCenter_Callback(hObject, eventdata, handles)

setNewZoom(hObject);

return;

% --------------------------------------------------------------------
% --- Executes on button press in oldCenter.
function oldCenter_Callback(hObject, eventdata, handles)

setOldZoom(hObject);

return;

% --------------------------------------------------------------------
% --- Executes on button press in newAutoCenter.
function newAutoCenter_Callback(hObject, eventdata, handles)

return;

% --------------------------------------------------------------------
% --- Executes on button press in oldAutoCenter.
function oldAutoCenter_Callback(hObject, eventdata, handles)

return;

% --------------------------------------------------------------------
function pauseCorrelationMenuItem_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'correlationRunning', 0);

return;

% --------------------------------------------------------------------
function resumeCorrelationMenuItem_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'correlationStarted')
    setLocal(progmanager, hObject, 'correlationRunning', 1);
    setLocal(progmanager, getLocal(progmanager, hObject, 'oldObj'), 'currentAnnotation', getLocal(progmanager, hObject, 'oldPosition'));
    setLocal(progmanager, getLocal(progmanager, hObject, 'newObj'), 'currentAnnotation', getLocal(progmanager, hObject, 'newPosition'));
end

return;