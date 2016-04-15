function scim_abort(verbose)
%% function scim_abort(verbose)
%SCIM_ABORT Aborts ongoing ScanImage acquisition, if any, of any typee
%
%% SYNTAX
%   scim_abort(verbose)
%       verbose: Logical value indicating, if true, to display status info (on Main Controls window) upon aborting operation. If omitted, value assumed to be true.
%% NOTES
%   This function is particularly useful for User Functions which may need to end an ongoing acquisition based on some criteria detected from previously acquired data, or related to externally measured/generated physiology/behavior/stimulus.
%
%   In ScanImage 3.7, this will comprise contents of abortCurrent() rather than calling it. It was decided not to refactor in time for ScanImage 3.6 release -- Vijay Iyer 12/7/09
%
%% CREDITS
%   Created 12/7/09, by Vijay Iyer
%% *****************************************

ver = scim_isRunning();

if ver == 0
    error('ScanImage must be running to use scim_pointLaser()');
elseif ver == 4
    evalin('base','hSI.abort();');
    return;
end

if nargin < 1
    verbose = true;
end
abortCurrent(verbose);





