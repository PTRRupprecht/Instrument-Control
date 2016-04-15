function ia_exportToTabDelimited(hObject, eventdata, handles)
warning('This function ''ia_ExportToTabDelimited'' has been deprecated.');
return;
[annotationData.fname fpath] = uiputfile({'*.tab', '(*.tab) Tab-Delimited Files'; '*.*', 'All Files'}, 'Export To Tab-Delimited File...');
if isequal(annotationData.fname, 0) | isequal(fpath, 0)
    return;
end

ia_exportDelimited(hObject, fullfile(fpath, annotationData.fname), sprintf('\t'));

return;