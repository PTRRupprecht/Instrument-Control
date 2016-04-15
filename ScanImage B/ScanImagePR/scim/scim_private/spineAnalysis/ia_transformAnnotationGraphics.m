function ia_transformAnnotationGraphics(hObject, varargin)

annotations = getLocal(progmanager, hObject, 'annotations');
if isempty(annotations)
    return;
end

annotationGraphics = getLocal(progmanager, hObject, 'annotationGraphics');
if isempty(annotationGraphics)
    warning('Found ''annotations'' object without corresponding ''annotationGraphics'' object.\n');
    return;
end

tform = getLocal(progmanager, hObject, 'registrationTransform');
% if isempty(tform)
%     return;
% end

indices = [];
if isempty(varargin)
    indices = 1 : length(annotationGraphics);
else
    indices = varargin{1};
end

if indices < 1
    return;
end

udata.hObject = hObject;
wb = waitbarWithCancel(0, sprintf('Applying coordinate transform to annotations...', num2str(j)), 'UserData', udata, 'Tag', 'applyAnnotationTransformWaitBar');

% imheader = getLocal(progmanager, hObject, 'currentHeader');
% if ~isempty(imheader)
%     radius = round(0.01 * mean(imHeader.acq.pixelsPerLine, imHeader.acq.linesPerFrame));
% else
    radius = 4;
% end

for i = indices
    waitbar(i / length(indices), wb);
    
    if isWaitbarCancelled(wb)
        delete(wb);
        return;
    end
    
    %Apply transformations (maybe this could be sped up and taken out of this loop).
    if ~isempty(tform)
        if size(annotations(i).x, 1) < size(annotations(i).x, 2)
            coords = tformfwd(cat(2, annotations(i).x', annotations(i).y'), tform);
        else
            coords = tformfwd(cat(2, annotations(i).x, annotations(i).y), tform);
        end
        annotations(i).x = coords(:, 1);
        annotations(i).y = coords(:, 2);
    end

    if strcmpi(annotations(i).type, 'line')   
        set(annotationGraphics(i).primaryLine, 'XData', annotations(i).x, 'YData', annotations(i).y);
        set(annotationGraphics(i).globalLine, 'XData', annotations(i).x, 'YData', annotations(i).y);
        set(annotationGraphics(i).primaryLineDirection, 'XData', [annotations(i).x(1) (annotations(i).x(1) + .25 * (annotations(i).x(2) - annotations(i).x(1)))], ...
            'YData', [annotations(i).y(1) (annotations(i).y(1) + .25 * (annotations(i).y(2) - annotations(i).y(1)))]);
    elseif strcmpi(annotations(i).type, 'point')
        set(annotationGraphics(i).primaryFidPoint, 'Position', [annotations(i).x(1) annotations(i).y(1) radius radius]);
        set(annotationGraphics(i).globalFidPoint, 'Position', [annotations(i).x(1) annotations(i).y(1) radius radius]);
    elseif strcmpi(annotations(i).type, 'polyline')
        set(annotationGraphics(i).polyLinePrimary, 'XData', annotations(i).x, 'YData', annotations(i).y);
        set(annotationGraphics(i).polyLineGlobal, 'XData', annotations(i).x, 'YData', annotations(i).y);
    end
    
    units = get(getLocalGh(progmanager, hObject, 'primaryView'), 'Units');
    if strcmpi(units, 'characters')
        textSpace = 1;
    elseif strcmpi(units, 'pixels')
        textSpace = 2;    
    elseif strcmpi(units, 'points')
        textSpace = 1;
    elseif strcmpi(units, 'normalized')
        textSpace = .02;
    elseif strcmpi(units, 'centimeters')
        textSpace = .25;
    elseif strcmpi(units, 'inches')
        textSpace = .1250;
    end
    if annotations(i).x(1) > annotations(i).x(2)
        x = annotations(i).x(2) - textSpace;
    else
        x = annotations(i).x(2) + textSpace;
    end
    if annotations(i).y(1) > annotations(i).y(2)
        y = annotations(i).y(2) - textSpace;
    else
        y = annotations(i).y(2) + textSpace;
    end
    
    set(annotationGraphics(i).primaryText, 'Position', [x y]);
    set(annotationGraphics(i).globalText, 'Position', [x y]);
    
    if isWaitbarCancelled(wb)
        delete(wb);
        return;
    end
end
delete(wb);

setLocal(progmanager, hObject, 'annotationGraphics', annotationGraphics);

return;