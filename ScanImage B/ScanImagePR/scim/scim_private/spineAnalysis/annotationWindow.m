function varargout = annotationWindow(varargin)
% ANNOTATIONWINDOW M-file for annotationWindow.fig
%      ANNOTATIONWINDOW, by itself, creates a new ANNOTATIONWINDOW or raises the existing
%      singleton*.
%
%      H = ANNOTATIONWINDOW returns the handle to a new ANNOTATIONWINDOW or the handle to
%      the existing singleton*.
%
%      ANNOTATIONWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANNOTATIONWINDOW.M with the given input arguments.
%
%      ANNOTATIONWINDOW('Property','Value',...) creates a new ANNOTATIONWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before annotationWindow_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to annotationWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help annotationWindow

% Last Modified by GUIDE v2.5 07-Aug-2007 23:46:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @annotationWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @annotationWindow_OutputFcn, ...
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

% --- Executes just before annotationWindow is made visible.
function annotationWindow_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for annotationWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = annotationWindow_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
        'tag', '', 'Class', 'char', 'Gui', 'annotationLabel', ...
        'initialX', 0, 'Class', 'Numeric', 'Gui', 'initialX', ...
        'finalX', 0, 'Class', 'Numeric', 'Gui', 'finalX', ...
        'initialY', 0, 'Class', 'Numeric', 'Gui', 'initialY', ...
        'finalY', 0, 'Class', 'Numeric', 'Gui', 'finalY', ...
        'initialFrame', 0, 'Class', 'Numeric', 'Gui', 'initialFrame', ...
        'finalFrame', 0, 'Class', 'Numeric', 'Gui', 'finalFrame', ...
        'annotationText', '', 'Class', 'char', 'Gui', 'annotationText', ...
        'userID', '', 'Class', 'char', 'Gui', 'userID', ...
        'persistence', 1, 'Gui', 'persistenceMenu', 'Class', 'Numeric', ...
        'correlationID', 0, 'Gui', 'correlationID', 'Class', 'Numeric', ...
        'setAsStable', @setAsStable, ...
        'setAsLoss', @setAsLoss, ...
        'setAsGain', @setAsGain, ...
        'setAsTransient', @setAsTransient, ...
        'setAsNeutral', @setAsNeutral, ...
        'hObject', hObject, ...
        'annotationList', {}, ...
        'annotationListValue', 1, 'Gui', 'annotationListBox', 'Class', 'Numeric', ...
        'annotationLength', 0, 'Class', 'Numeric', 'Gui', 'annotationLength', ...
        'lastLength', 0, 'Class', 'Numeric', ...
        'channel', 1, 'Class', 'Numeric', 'Gui', 'channel', ...
    };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

setMain(progmanager, hObject, 'annotationDisplayUpdateFcn', @annotationDisplayUpdate);
setMain(progmanager, hObject, 'annotationObject', hObject);

% toggleGuiVisibility(progmanager, hObject, 'annotationWindow', 'Off');

setLocalGh(progmanager, hObject, 'persistenceMenu', 'String', {'Stable', 'Loss', 'Gain', 'Transient', 'Neutral'});

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
% --- Executes during object creation, after setting all properties.
function annotationText_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function annotationText_Callback(hObject, eventdata, handles)

annotations = getMain(progmanager, hObject, 'annotations');
index = getMain(progmanager, hObject, 'currentAnnotation');
annotations(index).text = getLocal(progmanager, hObject, 'annotationText');
setMain(progmanager, hObject, 'annotations', annotations);

ia_annotationModified(hObject, index);

return;

% ------------------------------------------------------------------
% --- Executes on button press in hideAnnotation.
function hideAnnotation_Callback(hObject, eventdata, handles)

toggleGuiVisibility(progmanager, hObject, 'annotationWindow', 'Off');

return;

% ------------------------------------------------------------------
function listAnnotations(hObject)

annotations = getMain(progmanager, hObject, 'annotations');

list = {};
for i = 1 : length(annotations)
    list{i, 1} = i;
    list{i, 2} = sprintf('%s %s :: ID %s', annotations(i).type, num2str(i), num2str(annotations(i).correlationID));
end

setLocal(progmanager, hObject, 'annotationList', list);

return;

% ------------------------------------------------------------------
function annotationDisplayUpdate(hObject, varargin)

annotation = getMain(progmanager, hObject, 'annotations');
annotationGraphics = getMain(progmanager, hObject, 'annotationGraphics');
index = getMain(progmanager, hObject, 'currentAnnotation');

if index < 1 | isempty(annotation)
    setLocal(progmanager, hObject, 'initialX', 0);
    setLocal(progmanager, hObject, 'finalX', 0);
    setLocal(progmanager, hObject, 'initialY', 0);
    setLocal(progmanager, hObject, 'finalY', 0);
    setLocal(progmanager, hObject, 'initialFrame', 0);
    setLocal(progmanager, hObject, 'finalFrame', 0);
    setLocal(progmanager, hObject, 'tag', '');
    setLocal(progmanager, hObject, 'annotationText', '');
    setLocal(progmanager, hObject, 'userID', '');
    setLocal(progmanager, hObject, 'correlationID', 0);
    setLocalGh(progmanager, hObject, 'autoID', 'String', '');
    setLocalGh(progmanager, hObject, 'persistenceMenu', 'Value', 1);
    setLocal(progmanager, hObject, 'lastLength', 0);
    setLocal(progmanager, hObject, 'annotationLength', 0);
    if isempty(annotation)
        setLocalGh(progmanager, hObject, 'annotationListBox', 'String', '');
    end
    
    return;
end

listAnnotations(hObject);
annotationList = getLocal(progmanager, hObject, 'annotationList');
setLocalGh(progmanager, hObject, 'annotationListBox', 'String', {annotationList{:, 2}});
setLocal(progmanager, hObject, 'annotationListValue', index);

if index > length(annotation)
    index = length(annotation);
end

%Iterate over all annotations, looking for any with the current correlationID.
xFactor = getMain(progmanager, hObject, 'xConversionFactor');
yFactor = getMain(progmanager, hObject, 'yConversionFactor');
zFactor = getMain(progmanager, hObject, 'zConversionFactor');

len = 0;
for i = 1 : length(annotation)
    if annotation(i).correlationID == annotation(index).correlationID
        if strcmpi(class(annotation(i).userData), 'struct')
            if structHasField(annotation(i).userData, 'type')
                if strcmpi(annotation(i).userData.type, 'Neurolucida')
                    len = len + annotation(i).userData.nldAnalysis.length;
                else
                    zlen = 0;
                    for j = 2 : length(annotation(i).z)
                        zlen = zlen + abs(annotation(i).z(j) - annotation(i).z(j - 1));
                    end
                    len = len + sqrt(sum(abs(diff(annotation(i).x) * xFactor))^2 + ...
                        sum(abs(diff(annotation(i).y) * yFactor))^2 + ...
                        (zlen * zFactor)^2);
                end
            else
                zlen = 0;
                for j = 2 : length(annotation(i).z)
                    zlen = zlen + abs(annotation(i).z(j) - annotation(i).z(j - 1));
                end
                len = len + sqrt(sum(abs(diff(annotation(i).x) * xFactor))^2 + ...
                    sum(abs(diff(annotation(i).y) * yFactor))^2 + ...
                    (zlen * zFactor)^2);
            end
        end
    end
end
setLocal(progmanager, hObject, 'lastLength', len);
setLocal(progmanager, hObject, 'annotationLength', len);
yUnits = getMain(progmanager, hObject, 'xUnits');
if getMain(progmanager, hObject, 'unitaryConversions')
    if strcmpi(getMain(progmanager, hObject, 'xUnits'), yUnits) & strcmpi(getMain(progmanager, hObject, 'zUnits'), yUnits)
        setLocalGh(progmanager, hObject, 'lengthUnitsLabel', 'String', yUnits);
    else
        setLocalGh(progmanager, hObject, 'lengthUnitsLabel', 'String', 'Mixed Units');
    end
else
    setLocalGh(progmanager, hObject, 'lengthUnitsLabel', 'String', 'Pixels');
end

%Prune down the list of annotations, to just the current one.
annotation = annotation(index);

%Apply the spatial transformation.
tform = getMain(progmanager, hObject, 'registrationTransform');
if ~isempty(tform)
    if size(annotation.x, 1) < size(annotation.x, 2)
        coords = tformfwd(cat(2, annotation.x', annotation.y'), tform);
    else
        coords = tformfwd(cat(2, annotation.x, annotation.y), tform);
    end
    annotation.x = coords(:, 1);
    annotation.y = coords(:, 2);
end

setLocalGh(progmanager, hObject, 'annotationText', 'HorizontalAlignment', 'left');
setLocalGh(progmanager, hObject, 'autoID', 'String', num2str(annotation.autoID));
setLocal(progmanager, hObject, 'initialX', roundTo(annotation.x(1), 1));
setLocal(progmanager, hObject, 'finalX', roundTo(annotation.x(2), 1));
setLocal(progmanager, hObject, 'initialY', roundTo(annotation.y(1), 1));
setLocal(progmanager, hObject, 'finalY', roundTo(annotation.y(2), 1));
setLocal(progmanager, hObject, 'initialFrame', roundTo(annotation.z(1), 1));
setLocal(progmanager, hObject, 'finalFrame', roundTo(annotation.z(2), 1));
setLocal(progmanager, hObject, 'tag', ['Tag:   ' annotation.tag]);
setLocal(progmanager, hObject, 'annotationText', annotation.text);
setLocal(progmanager, hObject, 'userID', annotation.userID);
setLocal(progmanager, hObject, 'correlationID', annotation.correlationID);
setLocalGh(progmanager, hObject, 'autoID', 'String', num2str(annotation.autoID));
setLocalGh(progmanager, hObject, 'persistenceMenu', 'Value', annotation.persistence);
setLocalGh(progmanager, hObject, 'channel', 'String', num2str(annotation.channel));%TO080707A

if strcmpi(annotation.type, 'point')
    setLocalGh(progmanager, hObject, 'finalX', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'finalY', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'initialFrame', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'finalFrame', 'Enable', 'Off');
else
    setLocalGh(progmanager, hObject, 'finalX', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'finalY', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'initialFrame', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'finalFrame', 'Enable', 'On');
end

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function initialX_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --------------------------------------------------------------------
function initialX_Callback(hObject, varargin)

annotations = getMain(progmanager, hObject, 'annotations');
annotationGraphics = getMain(progmanager, hObject, 'annotationGraphics');
index = getMain(progmanager, hObject, 'currentAnnotation');
header = getMain(progmanager, hObject, 'currentHeader');

%Enforce boundaries.
initialX = getLocal(progmanager, hObject, 'initialX');
if initialX > header.acq.pixelsPerLine
    initialX = header.acq.pixelsPerLine;
    setLocal(progmanager, hObject, 'initialX', initialX);
elseif initialX < 1
    initialX = 1;
    setLocal(progmanager, hObject, 'initialX', initialX);
end

%Apply the spatial transformation.
tform = getMain(progmanager, hObject, 'registrationTransform');
if ~isempty(tform)
    coords = tforminv([initialX getLocal(progmanager, hObject, 'initialY')], tform);
    initialX = coords(1);
end

annotations(index).x(1) = initialX;
setLocal(progmanager, hObject, 'annotations', annotations);

xData = get(annotationGraphics(index).primaryLine, 'XData');
xData(1) = initialX;

set(annotationGraphics(index).primaryLine, 'XData', xData);
set(annotationGraphics(index).globalLine, 'XData', xData);

xData(2) = (xData(1) + .25 * (xData(2) - xData(1)));
set(annotationGraphics(index).primaryLineDirection, 'XData', xData);

ia_annotationModified(hObject, index);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function finalX_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --------------------------------------------------------------------
function finalX_Callback(hObject, varargin)

annotations = getMain(progmanager, hObject, 'annotations');
annotationGraphics = getMain(progmanager, hObject, 'annotationGraphics');
index = getMain(progmanager, hObject, 'currentAnnotation');
header = getMain(progmanager, hObject, 'currentHeader');

%Enforce boundaries.
finalX = getLocal(progmanager, hObject, 'finalX');
if finalX > header.acq.pixelsPerLine
    finalX = header.acq.pixelsPerLine;
    setLocal(progmanager, hObject, 'finalX', finalX);
elseif finalX < 1
    finalX = 1;
    setLocal(progmanager, hObject, 'finalX', finalX);
end

%Apply the spatial transformation.
tform = getMain(progmanager, hObject, 'registrationTransform');
if ~isempty(tform)
    coords = tforminv([finalX getLocal(progmanager, hObject, 'finalY')], tform);
    finalX = coords(1);
end

annotations(index).x(2) = finalX;
setLocal(progmanager, hObject, 'annotations', annotations);

xData = get(annotationGraphics(index).primaryLine, 'XData');
xData(2) = finalX;

set(annotationGraphics(index).primaryLine, 'XData', xData);
set(annotationGraphics(index).globalLine, 'XData', xData);

xData(2) = (xData(1) + .25 * (xData(2) - xData(1)));
set(annotationGraphics(index).primaryLineDirection, 'XData', xData);

ia_annotationModified(hObject, index);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function initialY_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --------------------------------------------------------------------
function initialY_Callback(hObject, varargin)

annotations = getMain(progmanager, hObject, 'annotations');
annotationGraphics = getMain(progmanager, hObject, 'annotationGraphics');
index = getMain(progmanager, hObject, 'currentAnnotation');
header = getMain(progmanager, hObject, 'currentHeader');

%Enforce boundaries.
initialY = getLocal(progmanager, hObject, 'initialY');
if initialY > header.acq.linesPerFrame
    initialY = header.acq.linesPerFrame;
    setLocal(progmanager, hObject, 'initialY', initialY);
elseif initialY < 1
    initialY = 1;
    setLocal(progmanager, hObject, 'initialY', initialY);
end

%Apply the spatial transformation.
tform = getMain(progmanager, hObject, 'registrationTransform');
if ~isempty(tform)
    coords = tforminv([getLocal(progmanager, hObject, 'initialX') initialY], tform);
    initialY = coords(2);
end

annotations(index).y(1) = initialY;
setLocal(progmanager, hObject, 'annotations', annotations);

yData = get(annotationGraphics(index).primaryLine, 'YData');
yData(1) = initialY;

set(annotationGraphics(index).primaryLine, 'YData', yData);
set(annotationGraphics(index).globalLine, 'YData', yData);

yData(2) = (yData(1) + .25 * (yData(2) - yData(1)));
set(annotationGraphics(index).primaryLineDirection, 'YData', yData);

ia_annotationModified(hObject, index);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function finalY_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --------------------------------------------------------------------
function finalY_Callback(hObject, varargin)

annotations = getMain(progmanager, hObject, 'annotations');
annotationGraphics = getMain(progmanager, hObject, 'annotationGraphics');
index = getMain(progmanager, hObject, 'currentAnnotation');
header = getMain(progmanager, hObject, 'currentHeader');

%Enforce boundaries.
finalY = getLocal(progmanager, hObject, 'finalY');
if finalY > header.acq.linesPerFrame
    finalY = header.acq.linesPerFrame;
    setLocal(progmanager, hObject, 'finalY', finalY);
elseif finalY < 1
    finalY = 1;
    setLocal(progmanager, hObject, 'finalY', finalY);
end

%Apply the spatial transformation.
tform = getMain(progmanager, hObject, 'registrationTransform');
if ~isempty(tform)
    coords = tforminv([getLocal(progmanager, hObject, 'finalX') finalY], tform);
    finalY = coords(2);
end

annotations(index).y(2) = finalY;
setLocal(progmanager, hObject, 'annotations', annotations);

yData = get(annotationGraphics(index).primaryLine, 'YData');
yData(2) = finalY;

set(annotationGraphics(index).primaryLine, 'YData', yData);
set(annotationGraphics(index).globalLine, 'YData', yData);

yData(2) = (yData(1) + .25 * (yData(2) - yData(1)));
set(annotationGraphics(index).primaryLineDirection, 'YData', yData);

ia_annotationModified(hObject, index);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function initialFrame_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --------------------------------------------------------------------
function initialFrame_Callback(hObject, varargin)

annotations = getMain(progmanager, hObject, 'annotations');
annotationGraphics = getMain(progmanager, hObject, 'annotationGraphics');
index = getMain(progmanager, hObject, 'currentAnnotation');
header = getMain(progmanager, hObject, 'currentHeader');

frame = getLocal(progmanager, hObject, 'initialFrame');
if frame > header.acq.numberOfZSlices
    frame = header.acq.numberOfZSlices;
    setLocal(progmanager, hObject, 'initialFrame', frame);
elseif frame < 1
    frame = 1;
    setLocal(progmanager, hObject, 'initialFrame', frame);
end
annotations(index).z(1) = frame;

setMain(progmanager, hObject, 'annotations', annotations);
ia_setLineVisibilities(getMain(progmanager, hObject, 'hObject'));

ia_annotationModified(hObject, index);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function finalFrame_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --------------------------------------------------------------------
function finalFrame_Callback(hObject, varargin)

annotations = getMain(progmanager, hObject, 'annotations');
annotationGraphics = getMain(progmanager, hObject, 'annotationGraphics');
index = getMain(progmanager, hObject, 'currentAnnotation');
header = getMain(progmanager, hObject, 'currentHeader');

frame = round(getLocal(progmanager, hObject, 'finalFrame'));
if frame > header.acq.numberOfZSlices
    frame = header.acq.numberOfZSlices;
elseif frame < 1
    frame = 1;
end
setLocal(progmanager, hObject, 'finalFrame', frame);

annotations(index).z(2) = frame;

setMain(progmanager, hObject, 'annotations', annotations);
ia_setLineVisibilities(getMain(progmanager, hObject, 'hObject'));

ia_annotationModified(hObject, index);

return;

% --------------------------------------------------------------------
% --- Executes on button press in deleteButton.
function deleteButton_Callback(hObject, varargin)

ia_deleteAnnotation(getMain(progmanager, hObject, 'hObject'));
% annotations = getMain(progmanager, hObject, 'annotations');
% annotationGraphics = getMain(progmanager, hObject, 'annotationGraphics');
% index = getMain(progmanager, hObject, 'currentAnnotation');
% header = getMain(progmanager, hObject, 'currentHeader');
% 
% annotations = getMain(progmanager, hObject, annotationsName);
% annotationGraphics = getMain(progmanager, hObject, annotationGraphicsName);
% index = getMain(progmanager, hObject, currentAnnotationName);
% header = getMain(progmanager, hObject, headerName);
% if isempty(annotations) | index < 1
%     return;
% end
% 
% annotationGraphics = getMain(progmanager, hObject, 'annotationGraphics');
% 
% delete(annotationGraphics(index).primaryLine);
% delete(annotationGraphics(index).primaryLineDirection);
% delete(annotationGraphics(index).globalLine);
% 
% if length(annotations) == 2
%     setMain(progmanager, hObject, 'currentAnnotation', 1);
% elseif index < length(annotations) - 1
%     setMain(progmanager, hObject, 'currentAnnotation', index + 1);
% elseif index > 1
%     setMain(progmanager, hObject, 'currentAnnotation', index - 1);
% else
%     setMain(progmanager, hObject, 'currentAnnotation', -1);
% end
% 
% annotations = annotations(find((1:length(annotations) ~= index)));
% annotationGraphics = annotationGraphics(find((1:length(annotationGraphics) ~= index)));
% 
% setMain(progmanager, hObject, 'annotations', annotations);
% setMain(progmanager, hObject, 'annotationGraphics', annotationGraphics);
% 
% annotationDisplayUpdate(hObject);

return;

% --------------------------------------------------------------------
% --- Executes on button press in newAnnotation.
function newAnnotation_Callback(hObject, eventdata, handles)

%Switch focus.
set(getParent(getMain(progmanager, hObject, 'hObject'), 'figure'), 'Visible', 'On');

%Do the macarana.
feval(getMain(progmanager, hObject, 'annotateCallback'), getMain(progmanager, hObject, 'hObject'));

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function autoID_CreateFcn(hObject, eventdata, handles)

%Leave this one gray.
return;

% --------------------------------------------------------------------
function autoID_Callback(hObject, eventdata, handles)
%This isn't tied to a variable. The user can not change this.

annotations = getMain(progmanager, hObject, 'annotations');
index = getMain(progmanager, hObject, 'currentAnnotation');

setLocalGh(progmanager, hObject, 'autoID', 'String', num2str(annotations(index).autoID));

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function userID_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --------------------------------------------------------------------
function userID_Callback(hObject, eventdata, handles)

annotations = getMain(progmanager, hObject, 'annotations');
index = getMain(progmanager, hObject, 'currentAnnotation');

annotations(index).userID = getLocal(progmanager, hObject, 'userID');

setMain(progmanager, hObject, 'annotations', annotations)

ia_annotationModified(hObject, index);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function correlationID_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --------------------------------------------------------------------
function correlationID_Callback(hObject, eventdata, handles)

annotations = getMain(progmanager, hObject, 'annotations');
index = getMain(progmanager, hObject, 'currentAnnotation');

resolution = '';
collision = -1;

correlationID = getLocal(progmanager, hObject, 'correlationID');
nextCorrelationId = getGlobal(progmanager, 'nextCorrelationId', 'stackBrowserControl', 'StackBrowserControl');

if ~getMain(progmanager, hObject, 'allowCorrelationIDCollisions')
    if correlationID < nextCorrelationId
        for i = 1 : length(annotations)
            if i ~= index & annotations(i).correlationID == correlationID
                resolution = questdlg('Another annotation with the same correlationID exists in this dataset.', 'CorrelationID Collision', ...
                    'Auto Resolve', 'Manually Resolve', 'Cancel Change', 'Manually Resolve');
                collision = i;
                break;
            end
        end
    end
    
    if strcmpi(resolution, 'Cancel Change')
        annotationDisplayUpdate(hObject);
        return;
    elseif strcmpi(resolution, 'Auto Resolve')
        annotations(collision).correlationID = ia_getNewCorrelationId;
    elseif strcmpi(resolution, 'Manually Resolve')
        %Jump to this annotation, let the user give it a new  ID.
        setMain(progmanager, hObject, 'currentAnnotation', collision);
        mainObj = getMain(progmanager, hObject, 'hObject');
        feval(getMain(progmanager, hObject, 'centerOnAnnotation'), mainObj);
        ia_setColors(mainObj);
    end
end

annotations(index).correlationID = correlationID;
setMain(progmanager, hObject, 'annotations', annotations);

if nextCorrelationId <= annotations(index).correlationID
    setGlobal(progmanager, 'nextCorrelationId', 'stackBrowserControl', 'StackBrowserControl', annotations(index).correlationID + 1);
end

annotationGraphics = getMain(progmanager, hObject, 'annotationGraphics');
set(annotationGraphics(index).primaryText, 'String', num2str(annotations(index).correlationID));
set(annotationGraphics(index).globalText, 'String', num2str(annotations(index).correlationID));

annotationDisplayUpdate(hObject);

ia_annotationModified(hObject, index);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function persistenceMenu_CreateFcn(hObject, eventdata, handles)

% --------------------------------------------------------------------
% --- Executes on selection change in persistenceMenu.
function persistenceMenu_Callback(hObject, eventdata, handles)

persistence = getLocal(progmanager, hObject, 'persistence');

if persistence == 1
    %Stable
    setAsStable(hObject);
elseif persistence == 2
    %Loss
    setAsLoss(hObject);
elseif persistence == 3
    %Gain
    setAsGain(hObject);
elseif persistence == 4
    %Transient
    setAsTransient(hObject);
elseif persistence == 5
    %Neutral
    setAsNeutral(hObject);
end

ia_annotationModified(hObject, getMain(progmanager, hObject, 'currentAnnotation'));

return;

% --------------------------------------------------------------------
function setAsStable(hObject, varargin)

for i = 1 : length(varargin)
    if ishandle(varargin{i})
        hObject = varargin{i};
        break;
    end
end

annotations = getMain(progmanager, hObject, 'annotations');
current = getMain(progmanager, hObject, 'currentAnnotation');
annotations(current).persistence = 1;
setMain(progmanager, hObject, 'annotations', annotations);

annotationDisplayUpdate(hObject);
ia_annotationModified(hObject, getMain(progmanager, hObject, 'currentAnnotation'));

return;

% --------------------------------------------------------------------
function setAsLoss(hObject, varargin)

for i = 1 : length(varargin)
    if ishandle(varargin{i})
        hObject = varargin{i};
        break;
    end
end

annotations = getMain(progmanager, hObject, 'annotations');
current = getMain(progmanager, hObject, 'currentAnnotation');
annotations(current).persistence = 2;
setMain(progmanager, hObject, 'annotations', annotations);

annotationDisplayUpdate(hObject);
ia_annotationModified(hObject, getMain(progmanager, hObject, 'currentAnnotation'));

return;

% --------------------------------------------------------------------
function setAsGain(hObject, varargin)

for i = 1 : length(varargin)
    if ishandle(varargin{i})
        hObject = varargin{i};
        break;
    end
end

annotations = getMain(progmanager, hObject, 'annotations');
current = getMain(progmanager, hObject, 'currentAnnotation');
annotations(current).persistence = 3;
setMain(progmanager, hObject, 'annotations', annotations);

annotationDisplayUpdate(hObject);
ia_annotationModified(hObject, getMain(progmanager, hObject, 'currentAnnotation'));

return;

% --------------------------------------------------------------------
function setAsTransient(hObject, varargin)

for i = 1 : length(varargin)
    if ishandle(varargin{i})
        hObject = varargin{i};
        break;
    end
end

annotations = getMain(progmanager, hObject, 'annotations');
current = getMain(progmanager, hObject, 'currentAnnotation');
annotations(current).persistence = 4;
setMain(progmanager, hObject, 'annotations', annotations);

annotationDisplayUpdate(hObject);
ia_annotationModified(hObject, getMain(progmanager, hObject, 'currentAnnotation'));

return;

% --------------------------------------------------------------------
function setAsNeutral(hObject, varargin)

for i = 1 : length(varargin)
    if ishandle(varargin{i})
        hObject = varargin{i};
        break;
    end
end

annotations = getMain(progmanager, hObject, 'annotations');
current = getMain(progmanager, hObject, 'currentAnnotation');
annotations(current).persistence = 5;
setMain(progmanager, hObject, 'annotations', annotations);

annotationDisplayUpdate(hObject);
ia_annotationModified(hObject, getMain(progmanager, hObject, 'currentAnnotation'));

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function annotationListBox_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --------------------------------------------------------------------
% --- Executes on selection change in annotationListBox.
function annotationListBox_Callback(hObject, eventdata, handles)

%%VI031609A %%%%%%%%%%
listVal = getLocal(progmanager,hObject,'annotationListValue');
if length(listVal) > 1
    setLocal(progmanager,hObject,'annotationListValue',listVal(1));
end
%%%%%%%%%%%%%%%%%%%%%

setMain(progmanager, hObject, 'currentAnnotation', getLocal(progmanager, hObject, 'annotationListValue'));
annotationDisplayUpdate(hObject);

mainObj = getMain(progmanager, hObject, 'hObject');
feval(getMain(progmanager, hObject, 'centerOnAnnotation'), mainObj);
ia_setColors(mainObj);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function annotationLength_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --------------------------------------------------------------------
function annotationLength_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'annotationLength', getLocal(progmanager, hObject, 'lastLength'));

return;

% --------------------------------------------------------------------
%TO080707 - Process photometry across multiple channels, for ratiometric imaging. -- Tim O'Connor 8/7/07
function channel_Callback(hObject, eventdata, handles)

annotations = getMain(progmanager, hObject, 'annotations');
index = getMain(progmanager, hObject, 'currentAnnotation');
channel = getLocal(progmanager, hObject, 'channel');
if channel < 0 || channel > 3 %Hard code the max number of channels for now, but it doesn't need to be limited to 3, and sometimes may need to be just 1.
    errdlg(sprintf('Channel out of range, hardcoded to be limited to 1-3: %s', num2str(channel)));
end
channel
annotations(index).channel = channel;
setMain(progmanager, hObject, 'annotations', annotations);
ia_annotationModified(hObject, index);
ia_setLineVisibilities(getMain(progmanager, hObject, 'hObject'));%TO080707A

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function channel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --------------------------------------------------------------------
%TO080707A
% --- Executes on button press in disp.
function disp_Callback(hObject, eventdata, handles)

annotations = getMain(progmanager, hObject, 'annotations');
index = getMain(progmanager, hObject, 'currentAnnotation');

ia_displayAnnotation(annotations(index));

return;

