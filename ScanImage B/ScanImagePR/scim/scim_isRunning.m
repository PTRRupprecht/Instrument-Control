function version = scim_isRunning()
%SCIM_ISRUNNING Determines which, if any, major version of ScanImage appears to be currently running
%% SYNTAX
%   version = scim_isRunning()
%       version: 0 if ScanImage is either not running or not running correctly; if SI is found running, the major version number (e.g. 3 or 4) is given

version = 0; %No valid version yet found
existState = ~isempty(whos('global','state'));
existGh =  ~isempty(whos('global','gh'));

%SI4 case
if ~existState && ~existGh
    if evalin('base','exist(''hSI'',''var'');')
        hSI = evalin('base','hSI;');
        if ~isempty(hSI)
            version = 4;
        end
    end
    return;
end

%SI3-corrupted case
if ~existState || ~existGh %SI3 is corrupted
    return; 
end

%SI3 case (existState && existGh)
global state
version = state.software.version;
    


