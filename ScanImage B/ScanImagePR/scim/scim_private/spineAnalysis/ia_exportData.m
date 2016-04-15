function ia_exportData(hObject, eventdata, handles)

warning('This function ''ia_exportData'' has been deprecated.');
return;

annotationData.filePath = getLocal(progmanager, hObject, 'filePath');
annotationData.fileName = getLocal(progmanager, hObject, 'fileName');

p = find(annotationData.fileName == '.');
if ~isempty(p)
    annotationData.fname = annotationData.fileName(1 : p(end) - 1);
end
annotationData.fname = [annotationData.fileName '.ann'];
fullname = fullfile(annotationData.filePath, annotationData.fname);

%Don't automatically overwrite.
if exist(fullname) == 2
    overwrite = questdlg(sprintf('File ''%s'' exists. Overwrite?', fullname), 'Confirm Overwrite', 'No');
    if strcmpi(overwrite, 'No')
        return;
    end
end

annotationData.annotations = getLocal(progmanager, hObject, 'annotations');

save(fullname, 'annotationData', '-mat');

return;