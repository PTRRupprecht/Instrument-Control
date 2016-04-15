function scim_show(unhide,subset)
%% function scim_show(unhide,subset)
%SCIM_SHOW Raises ScanImage windows that have been minimized or hidden by other windows.
%
%% SYNTAX
%   scim_show(): Most common usage, simply raises all ScanImage windows that are open. 
%   scim_show(unhide): Raises all windows, also opening any that were closed. 
%   scim_show(unhide,subset) (SI3 only)
%       unhide: <LOGICAL - Default = false> Indicates to open windows that are presently closed. 
%       subset: <one of {'main', 'display', 'all'} - Default='all'>  Indicating which windows to raise/open.
%
%% NOTES
%   This command is useful for case where windows have been minimized. 
%  
%   Technically 'opening' a window means to make Visible='on'. ScanImage windows are never truly closed.
%
%% CREDITS
%   Created 2010.11.03 DEQ
%% *****************************************


if nargin < 1 || isempty(unhide)
    unhide = false;
end

ver = scim_isRunning();

if ver == 0
    error('ScanImage must be running to use scim_show()');
elseif ver == 4
    if unhide
        evalin('base','hSICtl.showAllGUIs();');
    else        
        evalin('base','hSICtl.raiseAllGUIs();');
    end
    return;
end

if nargin < 2 || isempty(subset)
    subset = 'all';
end

switch lower(subset)
    case {'main'}
        showMain();
        showDisplay();
        
    case 'display'
        showDisplay();
        
    case 'all'
        showMain();
        showDisplay();
        showDialogs();
end

    function showGUI(gui)
        % a helper function that determines if a GUI item is visible, and if so,
        % brings it to the front (unless the user has specified 'force' mode,
        % in which case no visibility check will be made).
               
        if unhide
            figure(gui); pause(.02); %pause appears necessary to gurarantee that figure() will work            
        elseif strcmp(get(gui,'visible'),'on')
            figure(gui); pause(.02); %pause appears necessary to gurarantee that figure() will work            
        end
    end

    function showMain()
        
        showGUI(gh.mainControls.figure1);
        showGUI(gh.imageControls.figure1);
        showGUI(gh.powerControl.figure1);
        showGUI(gh.motorControls.figure1);
		showGUI(gh.cycleGUI.figure1);
        %showGUI(gh.configurationControls.figure1); %tethered to MainControls
		showGUI(gh.roiGUI.figure1);
        showGUI(gh.positionGUI.figure1);
    end

    function showDisplay()
        showGUI(state.internal.GraphFigure(1));
        showGUI(state.internal.GraphFigure(2));
        showGUI(state.internal.GraphFigure(3));
        showGUI(state.internal.GraphFigure(4));
        showGUI(state.internal.MergeFigure);
        
        showGUI(gh.roiDisplayGUI.figure1);
    end

    function showDialogs()
		showGUI(gh.configurationControls.figure1);
        %         showGUI(gh.channelGUI.figure1); %modal (at this time)
        showGUI(gh.triggerGUI.figure1);
        %        showGUI(gh.alignGUI.figure1); %tethered to MainControls
        showGUI(gh.userPreferenceGUI.figure1);
        %showGUI(gh.powerBox.figure1); %tethered to Power Controls
        %         showGUI(gh.laserFunctionPanel.figure1); %modal (at this time)
        showGUI(gh.clockExportGUI.figure1);
        showGUI(gh.fastConfigurationGUI.figure1);
        showGUI(gh.userFunctionsGUI.figure1);
		showGUI(gh.metaStackGUI.figure1);
    end

end
