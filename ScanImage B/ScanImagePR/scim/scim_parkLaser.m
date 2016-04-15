function scim_parkLaser(varargin)  
%% function scim_parkLaser(varargin)
% Function to park the laser beam(s) (at INI-defined angular position for SI3), while
% also blanking beam with Pockels and closing shutter
%
%% USAGE
%   scim_parkLaser(): parks laser at standard.ini defined park location (vars state.acq.parkAngleX & state.acq.parkAngleY) in SI3, or within scanner housing in SI4; closes shutter and turns off beam with Pockels Cell
%   scim_parkLaser(...,'soft'): (SI3 only) 'soft' flag causes function to blank beam with Pockels, but leave shutter open
%
%% NOTES
%   When parking at the standard.ini location, the Pockels Cell is set to transmit the minimum possible vlaue.
%
%   The 'soft' option is intended for 'quick' parking, avoiding frequent open/close of the shutter
%
%% ******************************************************************************************

ver = scim_isRunning();
if ver == 0
    error('ScanImage must be running to use scim_pointLaser()');
elseif ver == 4
    evalin('base','hSI.abort();');
    return;
end
    
si_parkOrPointLaser(varargin{:});
