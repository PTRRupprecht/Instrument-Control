function ia_setColors(hObject, varargin)

annotations = getLocal(progmanager, hObject, 'annotations');
annotationGraphics = getLocal(progmanager, hObject, 'annotationGraphics');
current = getLocal(progmanager, hObject, 'currentAnnotation');
correlated = getLocal(progmanager, hObject, 'correlatedAnnotations');

if isempty(annotations)
    return;
end

recursion = 0;
if length(varargin) > 1
    recursion = varargin{2};
end

indices = [];
if isempty(varargin) | ~(getLocal(progmanager, hObject, 'allowCorrelationIDCollisions') | recursion)
    %Watch out for having this option checked, since it could hammer performance.
    indices = 1 : length(annotationGraphics);
else
    indices = varargin{1};
end

if indices < 1
    return;
elseif any(indices > length(annotationGraphics))
    warning('Color update requested for index graphics object whose index is out of range: %s', mat2str(indices));
    return;
end

if indices > length(annotations)
    warning('Attempting to color annotation indices outside of legal range (1-%s): %s', length(annotations), mat2str(indices));
    indices = 1 : length(annotationGraphics);
end

for i = indices
    if strcmpi(annotations(i).type, 'Line')
        if i == current
            set(annotationGraphics(i).primaryLine, 'Color', [1 0 0]);
            set(annotationGraphics(i).globalLine, 'Color', [1 0 0]);
            set(annotationGraphics(i).primaryText, 'Color', [1 0 0]);
            set(annotationGraphics(i).globalText, 'Color', [1 0 0]);
            if ismember(i, correlated)
                set(annotationGraphics(i).primaryLineDirection, 'Color', [1 0 0]);                
            else
                set(annotationGraphics(i).primaryLineDirection, 'Color', [.7 .5 0]);
            end
            lastSelected = getLocal(progmanager, hObject, 'lastSelectColored');
            if current ~= lastSelected & lastSelected <= length(annotationGraphics)
                ia_setColors(hObject, getLocal(progmanager, hObject, 'lastSelectColored'), 1);
            end
            setLocal(progmanager, hObject, 'lastSelectColored', current);
        elseif annotations(i).persistence == 1
            set(annotationGraphics(i).primaryLine, 'Color', [.5 1 0]);
            set(annotationGraphics(i).globalLine, 'Color', [.5 1 0]);
            set(annotationGraphics(i).globalText, 'Color', [.5 1 0]);
            set(annotationGraphics(i).primaryText, 'Color', [.5 1 0]);
            if ismember(i, correlated)
                set(annotationGraphics(i).primaryLineDirection, 'Color', [.5 1 0]);                
            end
        elseif annotations(i).persistence == 2
            set(annotationGraphics(i).primaryLine, 'Color', [0.5019607843137255 1 1]);
            set(annotationGraphics(i).globalLine, 'Color', [0.5019607843137255 1 1]);
            set(annotationGraphics(i).globalText, 'Color', [0.5019607843137255 1 1]);
            set(annotationGraphics(i).primaryText, 'Color', [0.5019607843137255 1 1]);
            if ismember(i, correlated)
                set(annotationGraphics(i).primaryLineDirection, 'Color', [0.5019607843137255 1 1]);
            else
                set(annotationGraphics(i).primaryLineDirection, 'Color', [.7 .5 0]);
            end
        elseif annotations(i).persistence == 3
            set(annotationGraphics(i).primaryLine, 'Color', [1 .5 1]);
            set(annotationGraphics(i).globalLine, 'Color', [1 .5 1]);
            set(annotationGraphics(i).primaryText, 'Color', [1 .5 1]);
            set(annotationGraphics(i).globalText, 'Color', [1 .5 1]);
            if ismember(i, correlated)
                set(annotationGraphics(i).primaryLineDirection, 'Color', [1 .5 1]);  
            else
                set(annotationGraphics(i).primaryLineDirection, 'Color', [.7 .5 0]);
            end
        elseif annotations(i).persistence == 4
            set(annotationGraphics(i).primaryLine, 'Color', [0 .5 .5]);
            set(annotationGraphics(i).globalLine, 'Color', [0 .5 .5]);
            set(annotationGraphics(i).primaryText, 'Color', [0 .5 .5]);
            set(annotationGraphics(i).globalText, 'Color', [0 .5 .5]);
            if ismember(i, correlated)
                set(annotationGraphics(i).primaryLineDirection, 'Color', [0 .5 .5]);
            else
                set(annotationGraphics(i).primaryLineDirection, 'Color', [.7 .5 0]);
            end
        elseif annotations(i).persistence == 5
            set(annotationGraphics(i).primaryLine, 'Color', [.7 0.25098039215686274 0.25098039215686274]);
            set(annotationGraphics(i).globalLine, 'Color', [.7 0.25098039215686274 0.25098039215686274]);
            set(annotationGraphics(i).primaryText, 'Color', [.7 0.25098039215686274 0.25098039215686274]);
            set(annotationGraphics(i).globalText, 'Color', [.7 0.25098039215686274 0.25098039215686274]);
            if ismember(i, correlated)
                set(annotationGraphics(i).primaryLineDirection, 'Color', [.7 0.25098039215686274 0.25098039215686274]);
            else
                set(annotationGraphics(i).primaryLineDirection, 'Color', [.7 .5 0]);
            end
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
        
        %TO051305A - Flag annotations with text notes attached.
        if ~isempty(annotations(i).text)
            set(annotationGraphics(i).primaryText, 'Color', [1 1 0]);
            set(annotationGraphics(i).globalText, 'Color', [1 1 0]);
        end
        
        if photometryAvailable
            if ~endsWith(get(annotationGraphics(i).primaryText, 'String'), '\bullet')
                set(annotationGraphics(i).primaryText, 'String', [get(annotationGraphics(i).primaryText, 'String') '\bullet']);
            end
            if ~endsWith(get(annotationGraphics(i).globalText, 'String'), '\bullet')
                set(annotationGraphics(i).globalText, 'String', [get(annotationGraphics(i).globalText, 'String') '\bullet']);
            end
        else
            set(annotationGraphics(i).primaryText, 'String', num2str(annotations(i).correlationID));
            set(annotationGraphics(i).globalText, 'String', num2str(annotations(i).correlationID));
        end
    elseif strcmpi(annotations(i).type, 'point')
        if i == current
            set(annotationGraphics(i).primaryFidPoint, 'FaceColor', [1 0 0], 'EdgeColor', [1 0 0]);
            set(annotationGraphics(i).globalFidPoint, 'FaceColor', [1 0 0], 'EdgeColor', [1 0 0]);
        else
            set(annotationGraphics(i).primaryFidPoint, 'FaceColor', [0 0 1], 'EdgeColor', [0 0 1]);
        set(annotationGraphics(i).globalFidPoint, 'FaceColor', [0 0 1], 'EdgeColor', [0 0 1]);
        end
    end
end

setLocal(progmanager, hObject, 'annotations', annotations);

return;