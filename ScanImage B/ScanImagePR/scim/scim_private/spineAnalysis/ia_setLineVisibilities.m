%
% CHANGES
%  TO122209A - Implemented showAnnotationsOnGlobal, which must have been left out due to an oversight. -- Tim O'Connor 12/22/09
function ia_setLineVisibilities(hObject, varargin)

annotations = getMain(progmanager, hObject, 'annotations');
if isempty(annotations)
    return;
end

annotationGraphics = getMain(progmanager, hObject, 'annotationGraphics');
if isempty(annotationGraphics)
    warning('Found ''annotations'' object without corresponding ''annotationGraphics'' object.\n');
    return;
end

%TO080707 - Process photometry across multiple channels, for ratiometric imaging. -- Tim O'Connor 8/7/07
[projectAnnotations, frameNumber, lockAnnotationsToChannel, currentChannel] = getLocalBatch(progmanager, hObject, ...
    'projectAnnotations', 'frameNumber', 'lockAnnotationsToChannel', 'currentChannel');

indices = [];
if isempty(varargin)
    indices = 1 : length(annotationGraphics);
else
    indices = varargin{1};
end

if indices < 1
    return;
end

for i = indices
    %TO080707
    if ~lockAnnotationsToChannel || (annotations(i).channel == currentChannel)
        if strcmpi(annotations(i).type, 'line')
            if (annotations(i).z(1) <= frameNumber & frameNumber <= annotations(i).z(2)) | projectAnnotations
                if getLocal(progmanager, hObject, 'showAnnotationsOnPrimary')
                    set(annotationGraphics(i).primaryLine, 'Visible', 'On');
                    set(annotationGraphics(i).primaryLineDirection, 'Visible', 'On');
                else
                    set(annotationGraphics(i).primaryLine, 'Visible', 'Off');
                    set(annotationGraphics(i).primaryLineDirection, 'Visible', 'Off');
                end
                %TO122209A
                if getLocal(progmanager, hObject, 'showAnnotationsOnGlobal')
                    set(annotationGraphics(i).globalLine, 'Visible', 'On');
                else
                    set(annotationGraphics(i).globalLine, 'Visible', 'Off');
                end

                if getLocal(progmanager, hObject, 'showTextLabelsPrimary')
                    set(annotationGraphics(i).primaryText, 'Visible', 'On');
                else
                    set(annotationGraphics(i).primaryText, 'Visible', 'Off');
                end
                if getLocal(progmanager, hObject, 'showTextLabelsGlobal')
                    set(annotationGraphics(i).globalText, 'Visible', 'On');
                else
                    set(annotationGraphics(i).globalText, 'Visible', 'Off');
                end
            else
                set(annotationGraphics(i).primaryLine, 'Visible', 'Off');
                set(annotationGraphics(i).primaryLineDirection, 'Visible', 'Off');

                set(annotationGraphics(i).primaryText, 'Visible', 'Off');
                set(annotationGraphics(i).globalText, 'Visible', 'Off');

                if getLocal(progmanager, hObject, 'showTextLabelsGlobal')
                    set(annotationGraphics(i).globalText, 'Visible', 'On');
                else
                    set(annotationGraphics(i).globalText, 'Visible', 'Off');
                end

                %Always project all annotations in the global view.
                set(annotationGraphics(i).globalLine, 'Visible', 'On');
            end
        elseif strcmpi(annotations(i).type, 'point')
            if getLocal(progmanager, hObject, 'fiducialOnGlobal')
                set(annotationGraphics(i).globalFidPoint, 'Visible', 'On');
            else
                set(annotationGraphics(i).globalFidPoint, 'Visible', 'Off');
            end
            if getLocal(progmanager, hObject, 'fiducialOnPrimary')
                set(annotationGraphics(i).primaryFidPoint, 'Visible', 'On');
            else
                set(annotationGraphics(i).primaryFidPoint, 'Visible', 'Off');
            end
        elseif strcmpi(annotations(i).type, 'polyline')
            if getLocal(progmanager, hObject, 'polylinesOnGlobal')
                set(annotationGraphics(i).polyLineGlobal, 'Visible', 'On');
            else
                set(annotationGraphics(i).polyLineGlobal, 'Visible', 'Off');
            end
            if getLocal(progmanager, hObject, 'polylinesOnPrimary')
                set(annotationGraphics(i).polyLinePrimary, 'Visible', 'On');
            else
                set(annotationGraphics(i).polyLinePrimary, 'Visible', 'Off');
            end
        end
    end
end

return;