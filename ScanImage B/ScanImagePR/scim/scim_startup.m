%% scim_startup.m
%   This script displays a selection GUI which allows ScanImage to be started, or to bypass ScanImage and simply start Matlab
%   If the user desires this graphical selection to appear upon starting Matlab each time, scim_startup can be called from
%   the startup.m file for a given Matlab installation (located at <MATLABROOT>\toolboxes\local\).
%   Alternatively, this file can be copied to the <MATLABROOT>\toolboxes\local folder and renamed to 'startup.m'
%   
%   This functionality is not required. Scanimage can readily be invoked from the command-line, by entering 'scanimage'.



global state gh
set(0,'DefaultFigureIntegerHandle','off','DefaultFigureDoubleBuffer','on','DefaultFigureNumberTitle','off');
gh.openingGUI = guihandles(openingGUI);
close(gcf);