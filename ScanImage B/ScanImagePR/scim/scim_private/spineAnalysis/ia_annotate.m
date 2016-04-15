%% CHANGES
%   VI071310A: Use getRectFromAxes()/getPointsFromAxes for selection of rectangular area & points, respectively -- Vijay Iyer 7/13/10

function ia_annotate(hObject, varargin)

if getGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl')
    return;
end
setGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl', 1);

primaryView = getLocalGh(progmanager, hObject, 'primaryView');
globalView = getLocalGh(progmanager, hObject, 'globalView');

set(getParent(primaryView, 'figure'), 'HandleVisibility', 'On');%TO062007C - getline spawns a new figure in Matlab 7 if the HandleVisibility is set to Off. -- Tim O'Connor 6/20/07
[x y] = getPointsFromAxes(primaryView,'numberOfPoints',2,'nomovegui',1); %VI071310A
set(getParent(primaryView, 'figure'), 'HandleVisibility', 'Off');%TO062007C - getline spawns a new figure in Matlab 7 if the HandleVisibility is set to Off. -- Tim O'Connor 6/20/07

setGlobal(progmanager, 'drawingMode', 'StackBrowserControl', 'stackBrowserControl', 0);

if length(x) < 2 | length(y) < 2
    return;
end
x = x(1:2);
y = y(1:2);

%Apply the spatial transformation.
tform = getMain(progmanager, hObject, 'registrationTransform');
if ~isempty(tform)
    if size(x, 1) < size(x, 2)
        coords = tforminv(cat(2, x', y'), tform);
    else
        coords = tforminv(cat(2, x, y), tform);
    end
    
    x = coords(:, 1);
    y = coords(:, 2);
end

annotations = getMain(progmanager, hObject, 'annotations');
annotationGraphics = getMain(progmanager, hObject, 'annotationGraphics');
index = length(annotations) + 1;

tagCounter = getLocal(progmanager, hObject, 'tagCounter');
tag = sprintf('Annotation-%s', num2str(tagCounter));
setLocal(progmanager, hObject, 'tagCounter', tagCounter + 1);

annotations(index).type = 'Line';
annotations(index).x = x;
annotations(index).y = y;
annotations(index).z(1:2) = getLocal(progmanager, hObject, 'frameNumber');
annotations(index).tag = tag;
annotations(index).text = '';
annotations(index).autoID = tagCounter;
annotations(index).userID = num2str(tagCounter);
annotations(index).correlationID = ia_getNewCorrelationId;
annotations(index).correlationState = 'unknown';
annotations(index).persistence = 5;%Stable: 1, Loss: 2, Gain: 3, Transient: 4, Neutral: 5
annotations(index).creationTime = clock;
annotations(index).userData.type = '';
annotations(index).filename = getLocal(progmanager, hObject, 'fileName');
%TO080707A
annotations(index).channel = getLocal(progmanager, hObject, 'currentChannel');
for i = 1 : getMain(progmanager, hObject, 'numberOfChannels')
    annotations(index).photometry(i).background = [];
    annotations(index).photometry(i).backgroundBounds = [];
    annotations(index).photometry(i).backgroundFrame = [];
    annotations(index).photometry(i).normalization = [];
    annotations(index).photometry(i).normalizationBounds = [];
    annotations(index).photometry(i).normalizationFrame = [];
    annotations(index).photometry(i).normalizationMethod = 1;
    annotations(index).photometry(i).integral = [];
    annotations(index).photometry(i).integralBounds = [];
    annotations(index).photometry(i).integralFrame = [];
    annotations(index).photometry(i).backgroundChannel = annotations(index).channel;
    annotations(index).photometry(i).normalizationChannel = annotations(index).channel;
    annotations(index).photometry(i).integralChannel = annotations(index).channel;
    annotations(index).photometry(i).integralPixelCount = [];
end

setLocal(progmanager, hObject, 'currentAnnotation', index);
setLocal(progmanager, hObject, 'annotations', annotations);

feval(getLocal(progmanager, hObject, 'annotationDisplayUpdateFcn'), getLocal(progmanager, hObject, 'annotationObject'));

ia_createAnnotationGraphics(hObject, index);

if length(varargin) > 0
    if ~varargin{1}
        return;
    end
end

feval(getGlobal(progmanager, 'annotationAddedFcn', 'StackBrowserControl', 'stackBrowserControl'), ...
    getGlobal(progmanager, 'hObject', 'StackBrowserControl', 'stackBrowserControl'), hObject);

ia_updatePhotometryFromAnnotation(hObject);

return;