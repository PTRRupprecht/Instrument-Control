function ia_createAnnotationGraphics(hObject, varargin)
%Varargin may specify to only create a single annotation's graphics items.

primaryView = getLocalGh(progmanager, hObject, 'primaryView');
globalView = getLocalGh(progmanager, hObject, 'globalView');
fig = getParent(primaryView, 'figure');

annotations = getLocal(progmanager, hObject, 'annotations');
if isempty(annotations)
    return;
end

annotationGraphics = getLocal(progmanager, hObject, 'annotationGraphics');

imHeader = getLocal(progmanager, hObject, 'currentHeader');

tform = [];
startPoint = 1;
endPoint = length(annotations);
if ~isempty(varargin)
    if varargin{1} ~= 0
        startPoint = varargin{1};
        endPoint = varargin{1};
        tform = getLocal(progmanager, hObject, 'registrationTransform');
    end
    ia_clearAnnotationGraphics(hObject, startPoint : endPoint);    
elseif ~isempty(annotationGraphics)
    ia_clearAnnotationGraphics(hObject);
end

if endPoint - startPoint > 75 %Arbitrarily chose that number as the point where a progress bar is worthwhile.
    userdata = [];
    wb = waitbarWithCancel(0, 'Creating annotation graphics...', 'UserData', userdata, 'Tag', 'ia_createAnnotationGraphics');
    operations = endPoint - startPoint;
end

for i = startPoint : endPoint
    udata.tag = annotations(i).tag;

    cMenu = uicontextmenu('Parent', fig);
    uimenu(cMenu, 'Label', 'Details', 'Tag', 'annotationContextMenu-Details', 'UserData', udata, ...
        'Callback', 'toggleGuiVisibility(progmanager, getLocal(progmanager, gcbf, ''annotationObject''), ''annotationWindow'', ''On'');');
    uimenu(cMenu, 'Label', 'Delete', 'Callback', @ia_deleteAnnotation, 'UserData', udata, 'Tag', 'annotationContextMenu-Delete');
    uimenu(cMenu, 'Label', 'Volume', 'Callback', {@ia_computeVolume, gcbo}, 'UserData', udata, 'Tag', 'annotationContextMenu-ComputeVolume');
    mh = uimenu(cMenu, 'Label', 'Persistence', 'UserData', udata);
    uimenu(mh, 'Label', 'Stable', 'Callback', {getLocal(progmanager, getLocal(progmanager, hObject, 'annotationObject'), 'setAsStable'), ...
            getLocal(progmanager, hObject, 'annotationObject')}, 'UserData', udata, 'Tag', 'annotationContextMenu-Stable');
    uimenu(mh, 'Label', 'Loss', 'Callback', {getLocal(progmanager, getLocal(progmanager, hObject, 'annotationObject'), 'setAsLoss'), ...
            getLocal(progmanager, hObject, 'annotationObject')}, 'UserData', udata, 'Tag', 'annotationContextMenu-Loss');
    uimenu(mh, 'Label', 'Gain', 'Callback', {getLocal(progmanager, getLocal(progmanager, hObject, 'annotationObject'), 'setAsGain'), ...
            getLocal(progmanager, hObject, 'annotationObject')}, 'UserData', udata, 'Tag', 'annotationContextMenu-Gain');
    uimenu(mh, 'Label', 'Transient', 'Callback', {getLocal(progmanager, getLocal(progmanager, hObject, 'annotationObject'), 'setAsTransient'), ...
            getLocal(progmanager, hObject, 'annotationObject')}, 'UserData', udata, 'Tag', 'annotationContextMenu-Transient');
    uimenu(mh, 'Label', 'Neutral', 'Callback', {getLocal(progmanager, getLocal(progmanager, hObject, 'annotationObject'), 'setAsNeutral'), ...
            getLocal(progmanager, hObject, 'annotationObject')}, 'UserData', udata, 'Tag', 'annotationContextMenu-Neutral');
    
    if ~isempty(tform)
        if size(annotations(i).x, 1) < size(annotations(i).x, 2)
            coords = tformfwd(cat(2, annotations(i).x', annotations(i).y'), tform);
        else
            coords = tformfwd(cat(2, annotations(i).x, annotations(i).y), tform);
        end
        annotations(i).x = coords(:, 1);
        annotations(i).y = coords(:, 2);
    end
    
    if strcmpi(annotations(i).type, 'Line') | strcmpi(annotations(i).type, 'Spine')
        annotationGraphics(i).primaryLine = line(annotations(i).x, annotations(i).y, 'LineStyle', '-', 'LineWidth', 3, 'Color', [0 .6 0], 'Parent', primaryView, ...
            'Tag', udata.tag, 'UIContextMenu', cMenu, 'ButtonDownFcn', @ia_selectAnnotation, 'UserData', udata, 'Visible', 'Off');
        
        annotationGraphics(i).primaryLineDirection = line([annotations(i).x(1) (annotations(i).x(1) + .25 * (annotations(i).x(2) - annotations(i).x(1)))], ...
            [annotations(i).y(1) (annotations(i).y(1) + .25 * (annotations(i).y(2) - annotations(i).y(1)))], ...
            'LineStyle', '-', 'LineWidth', 3, 'Color', [0 1 0], 'Parent', primaryView, 'Tag', [udata.tag '-direction'], ...
            'UIContextMenu', cMenu, 'ButtonDownFcn', @ia_selectAnnotation, 'UserData', udata, 'Visible', 'Off');
        
        annotationGraphics(i).globalLine = line(annotations(i).x, annotations(i).y, 'LineStyle', '-', 'LineWidth', 2, 'Color', [0 .9 0], 'Parent', globalView, ...
            'Tag', [udata.tag '-global'], 'UserData', udata, 'Visible', 'Off');
        
        annotationGraphics(i).primaryFidPoint = [];
        annotationGraphics(i).globalFidPoint = [];
        
        units = get(primaryView, 'Units');
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

        photometryAvailable = 0;
        if isfield(annotations(i), 'photometry')
            %Just look for one field, and assume the rest are okay.
            if isfield(annotations(i).photometry, 'background')
                if ~isempty(annotations(i).photometry(1).background)%TO080707A
                    photometryAvailable = 1;
                end
            end
        end
        if photometryAvailable
            annotationGraphics(i).primaryText = text(x, y, [num2str(annotations(i).correlationID) '\bullet'], 'UserData', udata, 'ButtonDownFcn', @ia_selectAnnotation, ...
                'Tag', [udata.tag '-text'], 'UIContextMenu', cMenu, 'HorizontalAlignment', 'Center', 'FontWeight', 'bold', 'Parent', primaryView, 'Visible', 'Off');
            annotationGraphics(i).globalText = text(x, y, [num2str(annotations(i).correlationID) '\bullet'], 'UserData', udata, 'ButtonDownFcn', @ia_selectAnnotation, ...
                'Tag', [udata.tag '-text'], 'UIContextMenu', cMenu, 'HorizontalAlignment', 'Center', 'FontWeight', 'bold', 'Parent', globalView, 'Visible', 'Off');
        else
            annotationGraphics(i).primaryText = text(x, y, num2str(annotations(i).correlationID), 'UserData', udata, 'ButtonDownFcn', @ia_selectAnnotation, ...
                'Tag', [udata.tag '-text'], 'UIContextMenu', cMenu, 'HorizontalAlignment', 'Center', 'FontWeight', 'bold', 'Parent', primaryView, 'Visible', 'Off');
            annotationGraphics(i).globalText = text(x, y, num2str(annotations(i).correlationID), 'UserData', udata, 'ButtonDownFcn', @ia_selectAnnotation, ...
                'Tag', [udata.tag '-text'], 'UIContextMenu', cMenu, 'HorizontalAlignment', 'Center', 'FontWeight', 'bold', 'Parent', globalView, 'Visible', 'Off');
        end
    elseif strcmpi(annotations(i).type, 'point') | strcmpi(annotations(i).type, 'Fiducial')

        annotationGraphics(i).primaryLine = [];
        annotationGraphics(i).primaryLineDirection = [];
        annotationGraphics(i).globalLine = [];

        radius = round(0.01 * mean(imHeader.acq.pixelsPerLine, imHeader.acq.linesPerFrame));

        annotationGraphics(i).primaryFidPoint = rectangle('Position', [annotations(i).x(1) annotations(i).y(1) radius radius], 'Curvature', [1 1], 'Parent', primaryView, ...
            'Tag', udata.tag, 'UIContextMenu', cMenu, 'ButtonDownFcn', @ia_selectAnnotation, 'UserData', udata, 'FaceColor', [0 0 1], 'EdgeColor', [0 0 1], 'Visible', 'Off');
        annotationGraphics(i).globalFidPoint = rectangle('Position', [annotations(i).x(1) annotations(i).y(1) 2*radius 2*radius], 'Curvature', [1 1], 'Parent', globalView, ...
            'Tag', [udata.tag '-global'], 'UIContextMenu', cMenu, 'ButtonDownFcn', @ia_selectAnnotation, 'UserData', udata, 'FaceColor', [0 0 1], 'EdgeColor', [0 0 1], 'Visible', 'Off') ;
    elseif strcmpi(annotations(i).type, 'polyline')
        annotationGraphics(i).polyLinePrimary = line(annotations(i).x, annotations(i).y, 'LineStyle', '--', 'LineWidth', 2, 'Color', [.7 0 .7], 'Parent', primaryView, ...
            'Tag', udata.tag, 'UIContextMenu', cMenu, 'ButtonDownFcn', @ia_selectAnnotation, 'UserData', udata, 'Visible', 'Off');
        extendSupportedCMenu = get(annotationGraphics(i).polyLinePrimary, 'UIContextMenu');
        uimenu(extendSupportedCMenu, 'Label', 'Extend', 'Callback', @ia_extendAnnotation, 'UserData', udata, 'Tag', 'annotationContextMenu-Delete');
        annotationGraphics(i).polyLineGlobal = line(annotations(i).x, annotations(i).y, 'LineStyle', '--', 'LineWidth', 2, 'Color', [.7 0 .7], 'Parent', globalView, ...
            'Tag', [udata.tag '-global'], 'UIContextMenu', cMenu, 'ButtonDownFcn', @ia_selectAnnotation, 'UserData', udata, 'Visible', 'Off');
    else
        warning('stackBrowser: Encountered annotation object with unknown type. Can not render associated graphics for annotation #%s, with correlationID %s. Type: ''%s''', ...
            num2str(i), num2str(annotations(i).correlationID), annotations(i).type);
    end
    
    annotationGraphics(i).tag = udata.tag;
    
    if endPoint - startPoint > 75 
        waitbar(i / operations, wb);        
        if isWaitbarCancelled(wb)
            %No cancelling of this, for now.
            %         delete(wb);
            %         return;
        end
    end
end

%Show the correct details.
currentAnnotation = getLocal(progmanager, hObject, 'currentAnnotation');
if currentAnnotation < 1 | currentAnnotation > length(annotationGraphics)
    setLocal(progmanager, hObject, 'currentAnnotation', endPoint);
end
feval(getLocal(progmanager, hObject, 'annotationDisplayUpdateFcn'), getLocal(progmanager, hObject, 'annotationObject'));

setLocal(progmanager, hObject, 'annotationGraphics', annotationGraphics);

ia_setColors(hObject);
% if ~isempty(tform)
%     ia_transformAnnotationGraphics(hObject, startPoint : endPoint);
% end
ia_setLineVisibilities(hObject);

if endPoint - startPoint > 75
    delete(wb);
end

return;