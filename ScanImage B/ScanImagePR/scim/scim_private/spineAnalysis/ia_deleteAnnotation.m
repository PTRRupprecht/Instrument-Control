function ia_deleteAnnotation(varargin)

%Gather up some variables.
index = [];
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
    %Allow linked annotations to be deleted en masse.
    for i = 1 : length(annotations)
        if ~ismember(i, index) & annotations(i).correlationID == annotations(index).correlationID
            index(length(index) + 1) = i;
        end
    end
else
    hObject = varargin{1};
    index = getLocal(progmanager, hObject, 'currentAnnotation');
end
annotations = getLocal(progmanager, hObject, 'annotations');
annotationGraphics = getLocal(progmanager, hObject, 'annotationGraphics');

if isempty(index)
    fprintf(2, 'Lost the handle(s) to the line object(s)!\n');
    delete(findobj('Tag', udata.tag));
    delete(findobj('Tag', [udata.tag '-direction']));

    dlg = questdlg('An annotation handle has been lost. Clear all annotations?', 'Annotation Error', 'Yes', 'No', 'No');
    if strcmpi(dlg, 'Yes')
        annotations = [];
        annotationGraphics = [];
        setMain(progmanager, hObject, 'annotations', annotations);
        setLocal(progmanager, hObject, 'annotationGraphics', annotationGraphics);
    end
    
    udata
    annotations
    annotations.tag
        
    return;
end

for i = 1 : length(index)
    if all(~ishandle([annotationGraphics(index(i)).primaryLine annotationGraphics(index(i)).primaryLineDirection ...
                annotationGraphics(index(i)).globalLine annotationGraphics(index(i)).primaryFidPoint annotationGraphics(index(i)).globalFidPoint ...
                annotationGraphics(index(i)).polyLinePrimary annotationGraphics(index(i)).polyLineGlobal annotationGraphics(index(i)).primaryText annotationGraphics(index(i)).globalText]))
        fprintf(2, 'Lost the handle(s) to the line object(s)! Found incorrect associations!!!\n');
        
        delete(findobj('Tag', udata.tag));
        delete(findobj('Tag', [udata.tag '-direction']));
        
        dlg = questdlg('An annotation handle has been lost. Clear all annotations?', 'Annotation Error', 'Yes', 'No', 'No');
        if strcmpi(dlg, 'Yes')
            annotations = [];
            annotationGraphics = [];
            setLocal(progmanager, hObject, 'annotations', annotations);
            setLocal(progmanager, hObject, 'annotationGraphics', annotationGraphics);
        end
        
        return;
    end
    
    %Get rid of the graphics.
    delete(annotationGraphics(index(i)).primaryLine);
    delete(annotationGraphics(index(i)).primaryLineDirection);
    delete(annotationGraphics(index(i)).globalLine);
    delete(annotationGraphics(index(i)).primaryFidPoint);
    delete(annotationGraphics(index(i)).globalFidPoint);
    delete(annotationGraphics(index(i)).polyLinePrimary);
    delete(annotationGraphics(index(i)).polyLineGlobal);
    delete(annotationGraphics(index(i)).primaryText);
    delete(annotationGraphics(index(i)).globalText);
    
    %Update the detail display.
    if length(annotations) == 2
        setLocal(progmanager, hObject, 'currentAnnotation', 1);
    elseif index(i) < length(annotations) - 1
        setLocal(progmanager, hObject, 'currentAnnotation', index(i) + 1);
    elseif index(i) == length(annotations) - 1
        setLocal(progmanager, hObject, 'currentAnnotation', index(i) - 1);
    else
        setLocal(progmanager, hObject, 'currentAnnotation', -1);
    end
    setLocal(progmanager, hObject, 'lastSelectColored', getLocal(progmanager, hObject, 'currentAnnotation'));
    
    %Cut from the arrays.
    annotations = annotations(find((1:length(annotations) ~= index(i))));
    annotationGraphics = annotationGraphics(find((1:length(annotationGraphics) ~= index(i))));
end

setLocal(progmanager, hObject, 'annotations', annotations);
setLocal(progmanager, hObject, 'annotationGraphics', annotationGraphics);

feval(getLocal(progmanager, hObject, 'annotationDisplayUpdateFcn'), getLocal(progmanager, hObject, 'annotationObject'));

feval(getGlobal(progmanager, 'annotationDeletedFcn', 'stackBrowserControl', 'StackBrowserControl'), ...
    getGlobal(progmanager, 'hObject', 'stackBrowserControl', 'StackBrowserControl'), hObject);

return;