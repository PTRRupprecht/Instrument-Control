% ia_makeColorTable(hObject)
function colors = ia_makeColorTable(hObject, rows, columns)

colors = {};

persistentData = getLocal(progmanager, hObject, 'persistentData');
% summaryTable = getLocal(progmanager, hObject, 'summaryTable');
% rows = st_getRowNames(summaryTable);
% columns = st_getColumnNames(summaryTable);

%Persistence - Stable: 1, Loss: 2, Gain: 3, Transient: 4, Neutral: 5
for i = 1 : length(columns)
    annotationsIndex = find(strcmpi({persistentData{:, 1}}, columns{i}));
    annotations = persistentData{annotationsIndex, 2};

    if ~isempty(annotations)
        correlationIDs = [annotations.correlationID];
    else
        correlationIDs = [];
    end
    
    for j = 1 : length(rows)        
        index = find(correlationIDs == str2num(rows{j}));
        
        if ~isempty(index)
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
                    color = [1 1 1];
                    warning('Failed to map peristence state to color.');
            end
        else
            color = [1 1 1];
        end
        
        colors{j, i} = color;
    end
end

return;