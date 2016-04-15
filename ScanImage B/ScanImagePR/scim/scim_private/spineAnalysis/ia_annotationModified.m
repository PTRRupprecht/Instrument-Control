%ia_annotationModified(hObject, index) - Updates dependent components (such as an active summaryTable).
%
% hObject - handle to the stackBrowser where the modification occurred
% index - the index of the annotation that got changed
function ia_annotationModified(hObject, index)

hObject = getMain(progmanager, hObject, 'hObject');

summaryTable = getGlobal(progmanager, 'summaryTable', 'StackBrowserControl', 'stackBrowserControl');
setGlobal(progmanager, 'changesMadeSinceLastSave', 'StackBrowserControl', 'stackBrowserControl', 1);

if ~isempty(summaryTable)
    if isstarted(progmanager, summaryTable)
        
        persistentData = getGlobal(progmanager, 'persistentData', 'StackBrowserControl', 'stackBrowserControl');
        rows = st_getRowNames(summaryTable);
        columns = st_getColumnNames(summaryTable);
        annotations = getMain(progmanager, hObject, 'annotations');

        row = -1;
        column = -1;
        
        for i = 1 : length(rows)
            if str2num(rows{i}) == annotations(index).correlationID
                row = i;
                break;
            end
        end
        for i = 1 : length(columns)
            if strcmpi(columns{i}, annotations(index).filename)
                column = i;
                break;
            end
        end

        if row > 0 & column > 0
            switch annotations(index).persistence
                case 1
                    color = [.5 1 0];
                case 2
                    color = [0.5019607843137255 1 1];
                case 3
                    color = [1 .5 1];
                case 4
                    color = [0 .5 .5];
                case 5
                    color = [.7 0.25098039215686274 0.25098039215686274];
                otherwise
                    color = [1 0 0];
                    warning('Failed to map peristence state to color.');
            end
            
            st_setSingleElementColor(summaryTable, row, column, color);
        end

    end%isstarted(progmanager, summaryTable)
end%~isempty(summaryTable)

ia_setColors(hObject, index);

return;