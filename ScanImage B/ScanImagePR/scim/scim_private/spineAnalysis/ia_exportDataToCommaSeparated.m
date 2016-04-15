function ia_exportDataToCommaSeparated(hObject, eventdata, handles)
warning('This function ''ia_exportDataToCommaSeparated'' has been deprecated.');
return;
[annotationData.fname fpath] = uiputfile({'*.csv', '(*.csv) Comma-Separated Files'; '*.*', 'All Files'}, 'Export To Comma-Separated File...');
if isequal(annotationData.fname, 0) | isequal(fpath, 0)
    return;
end

ia_exportDelimited(hObject, fullfile(fpath, annotationData.fname), ',');

return;