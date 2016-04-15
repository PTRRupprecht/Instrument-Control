function ia_exportToBinary(hObject, eventdata, handles)
warning('This function ''ia_exportToBinary'' has been deprecated.');
return;
annotationData.filePath = getLocal(progmanager, hObject, 'filePath');
annotationData.fileName = getLocal(progmanager, hObject, 'fileName');

annotationData.fname = annotationData.fileName;
%Default filename.
p = find(annotationData.fileName == '.');
if ~isempty(p)
    annotationData.fname = annotationData.fileName(1 : p(end) - 1);
end
annotationData.fname = [annotationData.fname '.ann'];

[fname fpath] = uiputfile({'*.ann', '(*.ann) Annotation Files'; '*.mat', '(*.mat) Binary MAT Files'; '*.*', '(*.*) All Files'}, 'Export To Binary File...');
if isequal(fname, 0) | isequal(fpath, 0)
    return;
end
if length(fname) > 4
    if ~strcmpi('.ann', fname(length(fname) - 4 : length(fname)))
        fname = [fname '.ann'];
    end
else
    fname = [fname '.ann'];
end

fullname = fullfile(fpath, fname);
if exist(fullname) == 2
    overwrite = questdlg(sprintf('File ''%s'' exists. Overwrite?', fullname), 'Confirm Overwrite', 'No');
    if strcmpi(overwrite, 'No')
        return;
    end
end

annotationData.annotations = getLocal(progmanager, hObject, 'annotations');

save(fullname, 'annotationData');

return;
