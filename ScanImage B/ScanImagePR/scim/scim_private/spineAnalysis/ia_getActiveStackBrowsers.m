function stackBrowsers = ia_getActiveStackBrowsers(hObject)

if ~strcmpi(getGUIName(progmanager, hObject), 'stackBrowserControl')
    hObject = getGlobal(progmanager, 'hObject', 'StackBrowserControl', 'stackBrowserControl');
end

stackBrowsers = [];
programs = getLocal(progmanager, hObject, 'subPrograms');
windowNames = getLocal(progmanager, hObject, 'windowNames');

for i = 1 : length(programs)
    if ~strcmpi(get(programs{i}, 'program_name'), 'AnnotationCorrelator') & isstarted(progmanager, programs{i})
        stackBrowsers(length(stackBrowsers) + 1) = getGlobal(progmanager, 'hObject', 'stackBrowser', windowNames{i});
    end
end

return;