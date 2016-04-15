function ia_drawGridLines(hObject)

delete(getLocal(progmanager, hObject, 'gridLines'));
delete(getLocal(progmanager, hObject, 'gridLinesOnGlobal'));

im = getLocal(progmanager, hObject, 'currentImage');
im = im{getLocal(progmanager, hObject, 'currentChannel')};
xDim = size(im, 2);
yDim = size(im, 1);

primaryView = getLocalGh(progmanager, hObject, 'primaryView');
globalView = getLocalGh(progmanager, hObject, 'globalView');
spacing = getLocal(progmanager, hObject, 'gridLineSpacing');

if getLocal(progmanager, hObject, 'gridLinesVisible')
    visibility = 'On';
    if getLocal(progmanager, hObject, 'gridLinesVisibleOnGlobal')
        visibilityOnGlobal = 'On';
    else
        visibilityOnGlobal = 'Off';
    end
else
    visibility = 'Off';
    visibilityOnGlobal = 'Off';
end

gridLines = [];
gridLinesOnGlobal = [];
udata = [];
for i = 1 : spacing : xDim
    gridLines(length(gridLines) + 1) = line([i i], [1 yDim], 'LineStyle', '-', 'LineWidth', 1, 'Color', [0 0 1], 'Parent', primaryView, ...
            'Tag', ['HorizontalGridLine-' num2str(i)], 'UserData', udata, 'Visible', visibility);
    gridLinesOnGlobal(length(gridLinesOnGlobal) + 1) = line([i i], [1 yDim], 'LineStyle', '-', 'LineWidth', 1, 'Color', [0 0 1], 'Parent', globalView, ...
            'Tag', ['HorizontalGridLine-' num2str(i)], 'UserData', udata, 'Visible', visibilityOnGlobal);
end
for i = 1 : spacing : yDim
    gridLines(length(gridLines) + 1) = line([1 xDim], [i i], 'LineStyle', '-', 'LineWidth', 1, 'Color', [0 0 1], 'Parent', primaryView, ...
            'Tag', ['VeritcalGridLine-' num2str(i)], 'UserData', udata, 'Visible', visibility);
    gridLinesOnGlobal(length(gridLinesOnGlobal) + 1) = line([1 xDim], [i i], 'LineStyle', '-', 'LineWidth', 1, 'Color', [0 0 1], 'Parent', globalView, ...
            'Tag', ['VeritcalGridLine-' num2str(i)], 'UserData', udata, 'Visible', visibilityOnGlobal);
end

setLocal(progmanager, hObject, 'gridLines', gridLines);
setLocal(progmanager, hObject, 'gridLinesOnGlobal', gridLinesOnGlobal);

ia_setGridLineVisibility(hObject);

return;