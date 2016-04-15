%% CHANGES
%   VI071310A: Use getRectFromAxes()/getPointsFromAxes for selection of rectangular area & points, respectively -- Vijay Iyer 7/13/10

function ia_extendAnnotation(varargin)

%Gather up some variables.
index = -1;
if isempty(varargin)
    hObject = gcbf;
    udata = get(gcbo, 'UserData');
    %Find this annotation's structure.
    for i = 1 : length(annotations)
        if strcmp(annotations(i).tag, udata.tag)
            index = i;
            break;
        end
    end
else
    hObject = varargin{1};
    index = getLocal(progmanager, hObject, 'currentAnnotation');
end
annotations = getLocal(progmanager, hObject, 'annotations');
annotationGraphics = getLocal(progmanager, hObject, 'annotationGraphics');

if getGlobal(progmanager, 'drawingMode', 'stackBrowserControl', 'StackBrowserControl')
    return;
end
setGlobal(progmanager, 'drawingMode', 'stackBrowserControl', 'StackBrowserControl', 1);

primaryView = getLocalGh(progmanager, hObject, 'primaryView');
globalView = getLocalGh(progmanager, hObject, 'globalView');

set(getParent(primaryView, 'figure'), 'HandleVisibility', 'On');%TO062007C - getline spawns a new figure in Matlab 7 if the HandleVisibility is set to Off. -- Tim O'Connor 6/20/07
[x y] = getPointsFromAxes(primaryView,'numberOfPoints',2,'nomovegui',1); %VI071310A
set(getParent(primaryView, 'figure'), 'HandleVisibility', 'Off');%TO062007C - getline spawns a new figure in Matlab 7 if the HandleVisibility is set to Off. -- Tim O'Connor 6/20/07

setGlobal(progmanager, 'drawingMode', 'stackBrowserControl', 'StackBrowserControl', 0);
annotations(index).x = cat(1, annotations(index).x, x);
annotations(index).y = cat(1, annotations(index).y, y);
annotations(index).z(length(annotations(index).z) + 1 : length(annotations(index).x)) = getLocal(progmanager, hObject, 'frameNumber');

setLocal(progmanager, hObject, 'annotations', annotations);
ia_createAnnotationGraphics(hObject, index);

return;