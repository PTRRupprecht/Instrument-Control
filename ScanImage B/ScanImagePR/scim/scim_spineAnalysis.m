function scim_spineAnalysis()
% Launches the spineAnalysis utility, employed to date mostly for longitudinal tracking of spine morphology

openprogram(progmanager, program('stackBrowserControl', 'StackBrowserControl', 'stackBrowserControl', ...
    'stackBrowserOptions', 'stackBrowserOptions', 'stackBrowserDisplayOptions', 'stackBrowserDisplayOptions', ...
    'stackBrowserFeatureRecognitionOptions', 'stackBrowserFeatureRecognitionOptions'))

return;