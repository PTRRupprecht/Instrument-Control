function metadata = ia_getMetadata(hObject)

metadata.units.unitaryConversions = getLocal(progmanager, hObject, 'unitaryConversions');
metadata.units.xConversionFactor = getLocal(progmanager, hObject, 'xConversionFactor');
metadata.units.xUnits = getLocal(progmanager, hObject, 'xUnits');
metadata.units.yConversionFactor = getLocal(progmanager, hObject, 'yConversionFactor');
metadata.units.yUnits = getLocal(progmanager, hObject, 'yUnits');
metadata.units.zConversionFactor = getLocal(progmanager, hObject, 'zConversionFactor');
metadata.units.zUnits = getLocal(progmanager, hObject, 'zUnits');

return;