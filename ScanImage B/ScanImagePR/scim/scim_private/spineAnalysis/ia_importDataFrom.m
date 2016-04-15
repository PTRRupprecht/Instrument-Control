function ia_importDataFrom(hObject, eventdata, handles)
warning('This function ''ia_importDataFrom'' has been deprecated.');
return;
if isdir(getLocal(progmanager, hObject, 'filePath'))
    cd(getLocal(progmanager, hObject, 'filePath'));
else
    cd(fullfile(matlabroot, 'work'));
end

[fname, pname] = uigetfile({'*.ann', 'Annotation Files'; '*.mat', 'Binary MAT File'}, 'Import From');
if isequal(fname, 0) | isequal(pname, 0)
    return;
end

%Max out the correlationID for this directory.
allFiles = dir([pname '*.ann']);
correlationID = getGlobal(progmanager, 'nextCorrelationId', 'stackBrowserControl', 'StackBrowserControl');
% wb = waitbar(0, 'Scanning for correlation GUID collisions...');
% % for i = 1 : length(allFiles)
% %     temp = load(fullfile(pname, allFiles(i).name), '-mat');
% %     correlationID = max(correlationID, temp.annotationData.annotations.correlationID);
% %     waitbar(i / length(allFiles), wb);
% % end
% setGlobal(progmanager, 'nextCorrelationId', 'stackBrowserControl', 'StackBrowserControl', correlationID + 1);
% setGlobal(progmanager, 'lastGUID', 'stackBrowserControl', 'StackBrowserControl', correlationID + 1);
% close(wb);

loaded = load(fullfile(pname, fname), '-mat');
setLocal(progmanager, hObject, 'annotations', loaded.annotationData.annotations);
setLocal(progmanager, hObject, 'filePath', loaded.annotationData.filePath);
setLocal(progmanager, hObject, 'fileName', loaded.annotationData.fileName);

if getLocal(progmanager, hObject, 'tagCounter') <= length(loaded.annotationData.annotations)
    setLocal(progmanager, hObject, 'tagCounter', length(loaded.annotationData.annotations) + 1);
end

% ia_clearAnnotationGraphics(hObject);
% ia_createAnnotationGraphics(hObject);

return;