function id = ia_getNewCorrelationId

id = getGlobal(progmanager, 'nextCorrelationId', 'stackBrowserControl', 'StackBrowserControl');

setGlobal(progmanager, 'nextCorrelationId', 'stackBrowserControl', 'StackBrowserControl', id + 1);

return;