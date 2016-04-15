function ia_importData(hObject, eventdata, handles)

warning('This function ''ia_importData'' has been deprecated.');
return;

annotationData.filePath = getLocal(progmanager, hObject, 'filePath');
annotationData.fileName = getLocal(progmanager, hObject, 'fileName');

%Max out the correlationID for this directory.
allFiles = dir([annotationData.filePath '*.ann']);
correlationID = getGlobal(progmanager, 'nextCorrelationId', 'stackBrowserControl', 'StackBrowserControl');
wb = waitbar(0, 'Scanning for correlation GUID collisions...');
for i = 1 : length(allFiles)
    temp = load(allFiles(i).name, '-mat');
    correlationID = max([correlationID temp.annotationData.annotations.correlationID]);
    waitbar(i / length(allFiles), wb);
end
setGlobal(progmanager, 'nextCorrelationId', 'stackBrowserControl', 'StackBrowserControl', correlationID + 1);
setGlobal(progmanager, 'lastGUID', 'stackBrowserControl', 'StackBrowserControl', correlationID + 1);
close(wb);

p = find(annotationData.fileName == '.');
if ~isempty(p)
    annotationData.fileName = annotationData.fileName(1 : p(end) - 1);
end
annotationData.fileName = [annotationData.fileName '.ann'];
fullname = fullfile(annotationData.filePath, annotationData.fileName);

if exist(fullname) ~= 2
%This seems to get annoying, so don't do it for now.
%     ia_importDataFrom(hObject);
fprintf(2, 'No file (%s) found to import data from.\n', fullname);
    return;
end

loaded = load(fullname, '-mat');

setLocal(progmanager, hObject, 'annotations', loaded.annotationData.annotations);
setLocal(progmanager, hObject, 'filePath', loaded.annotationData.filePath);
setLocal(progmanager, hObject, 'fileName', loaded.annotationData.fileName);

if getLocal(progmanager, hObject, 'tagCounter') <= length(loaded.annotationData.annotations)
    setLocal(progmanager, hObject, 'tagCounter', length(loaded.annotationData.annotations) + 1);
end

% ia_clearAnnotationGraphics(hObject);
% ia_createAnnotationGraphics(hObject);

return;