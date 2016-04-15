function ia_setOption(hObject, optionName, optionValue)

browsers = ia_getActiveStackBrowsers(hObject);

for i = 1 : length(browsers)
    setLocal(progmanager, browsers(i), optionName, optionValue);
end

return;