function ia_selectAnnotation(varargin)

hObject = gcbf;
udata = get(gcbo, 'UserData');
annotations = getMain(progmanager, hObject, 'annotations');
index = -1;

%Find this annotation's structure.
for i = 1 : length(annotations)
    if strcmp(annotations(i).tag, udata.tag)
        index = i;
        break;
    end
end

if index == -1
    warning('Can not find structure to match line object.');
    return;
end

setLocal(progmanager, hObject, 'currentAnnotation', index);
feval(getLocal(progmanager, hObject, 'annotationDisplayUpdateFcn'), getLocal(progmanager, hObject, 'annotationObject'));

ia_setColors(hObject, index);

if getLocal(progmanager, hObject, 'frameNumber') ~= annotations(index).z(1) & ...
        getLocal(progmanager, hObject, 'switchFrameOnSelection')
    setLocal(progmanager, hObject, 'frameNumber', annotations(index).z(1));
    feval(getLocal(progmanager, hObject, 'displayNewImage'), hObject);
    
    stepSize = annotations(index).z(1) - getLocal(progmanager, hObject, 'lastFrame');
    feval(getGlobal(progmanager, 'frameChange', 'stackBrowserControl', 'StackBrowserControl'), ...
        getGlobal(progmanager, 'hObject', 'stackBrowserControl', 'StackBrowserControl'), ...
        stepSize);
end

ia_updatePhotometryFromAnnotation(hObject);

return;