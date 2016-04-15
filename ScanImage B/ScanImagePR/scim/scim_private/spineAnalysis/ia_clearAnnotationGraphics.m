function ia_clearAnnotationGraphics(hObject, varargin)

annotationGraphics = getLocal(progmanager, hObject, 'annotationGraphics');
range = 1 : length(annotationGraphics);

if ~isempty(varargin)
    range = varargin{1};
    if any(range > length(annotationGraphics))
        return;
    end
end

if ~isempty([annotationGraphics(range).primaryLine])
    if ishandle([annotationGraphics(range).primaryLine])
        delete(annotationGraphics(range).primaryLine);
    else
        [annotationGraphics.primaryLine] = deal([]);
    end
end
if ~isempty([annotationGraphics.primaryLineDirection])
    if ishandle([annotationGraphics(range).primaryLineDirection])
        delete(annotationGraphics(range).primaryLineDirection);
    else
        [annotationGraphics.primaryLineDirection] = deal([]);
    end
end
if ~isempty([annotationGraphics.globalLine])
    if ishandle([annotationGraphics(range).globalLine])
        delete(annotationGraphics(range).globalLine);
    else
        [annotationGraphics.globalLine] = deal([]);
    end
end
if ~isempty([annotationGraphics.primaryFidPoint])
    if ishandle([annotationGraphics(range).primaryFidPoint])
        delete(annotationGraphics(range).primaryFidPoint);
    else
        [annotationGraphics.primaryFidPoint] = deal([]);
    end
end
if ~isempty([annotationGraphics.globalFidPoint])
    if ishandle([annotationGraphics(range).globalFidPoint])
        delete(annotationGraphics(range).globalFidPoint);
    else
        [annotationGraphics.globalFidPoint] = deal([]);
    end
end
if ~isempty([annotationGraphics.polyLinePrimary])
    if ishandle([annotationGraphics(range).polyLinePrimary])
        delete(annotationGraphics(range).polyLinePrimary);
    else
        [annotationGraphics.polyLinePrimary] = deal([]);
    end
end
if ~isempty([annotationGraphics.polyLineGlobal])
    if ishandle([annotationGraphics(range).polyLineGlobal])
        delete(annotationGraphics(range).polyLineGlobal);
    else
        [annotationGraphics.polyLineGlobal] = deal([]);
    end
end
if ~isempty([annotationGraphics.primaryText])
    if ishandle([annotationGraphics(range).primaryText])
        delete(annotationGraphics(range).primaryText);
    else
        [annotationGraphics.primaryText] = deal([]);
    end
end
if ~isempty([annotationGraphics.globalText])
    if ishandle([annotationGraphics(range).globalText])
        delete(annotationGraphics(range).globalText);
    else
        [annotationGraphics.globalText] = deal([]);
    end
end

if length(annotationGraphics) > 1
    annotationGraphics = annotationGraphics(1);
end

setLocal(progmanager, hObject, 'annotationGraphics', annotationGraphics);

return;