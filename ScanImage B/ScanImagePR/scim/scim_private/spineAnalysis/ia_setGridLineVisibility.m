function ia_setGridLineVisibility(hObject)

if getLocal(progmanager, hObject, 'gridLinesVisible')
    set(getLocal(progmanager, hObject, 'gridLines'), 'Visible', 'On');
    if getLocal(progmanager, hObject, 'gridLinesVisibleOnGlobal')
        set(getLocal(progmanager, hObject, 'gridLinesOnGlobal'), 'Visible', 'On');
    end
else
    set(getLocal(progmanager, hObject, 'gridLines'), 'Visible', 'Off');
    set(getLocal(progmanager, hObject, 'gridLinesOnGlobal'), 'Visible', 'Off');
end

return;