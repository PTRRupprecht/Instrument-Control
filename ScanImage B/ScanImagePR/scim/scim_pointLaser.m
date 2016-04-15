function scim_pointLaser(posn,launchDialog)
%SCIM_POINTLASER Point beam to specified angular coordinates
%
%% SYNTAX
%   scim_pointLaser(posn,launchDialog)
%       posn: 2-element vector of [fast slow] angular coordinates, for fast & slow dimensions, respectively. If empty, [fast slow] values are selected graphically. 
%       launchDialog: (Default=true) Logical indicating whether to launch dialog to re-park beam.
%
%% NOTES
%   When posn is passed, note that 1) scanOffsetAngleX/Y is NOT added, and 2) value is converted to voltage via voltsPerOpticalDegree value in INI file
%
%   If posn is not specified, and selected interactively, then:
%       1) The 'target figure' specified in Image Controls pertains
%       2) If using graphical selection, it is assumed the scanShiftFast/Slow, 
%           scanAngleMultiplierFast/Slow, zoomFactor, pixels/Line, lines/Frame, 
%           and fastScanningX values have NOT changed since acquisition used 
%           for displayed image
%
%   TODO: Verify that function operates correctly in case where X/Y to Fast/Slow mapping is inverted. It seems like this might not be working. (VI090412)
%

%Ensure SI3.x is running (and handle other cases)
ver = scim_isRunning();
if ver == 0
    error('ScanImage must be running to use scim_pointLaser()');
elseif ver == 4
    evalin('base','hSI.scanPointBeam();');
    return;
end
    
global state

%Determine point to use
if nargin && ~isempty(posn)
    assert(isnumeric(posn) && numel(posn)==2,'Argument ''posn'' must be a numeric 2-element vector');
   
    fast = posn(1);
    slow = posn(2);        
else
    %Select point from an image figure
    hax = si_selectImageFigure();
    if isempty(hax)
        return;
    end
    [fast,slow] = getPointsFromAxes(hax,'Cursor','crosshair','nomovegui',1,'numberOfPoints',1);
    
    %Convert selected point to angular coordinates
    sizeImage = [state.acq.pixelsPerLine  state.internal.storedLinesPerFrame];
    fastNormalized = fast/sizeImage(1) - 0.5;
    slowNormalized = slow/sizeImage(2) - 0.5;
    
    fast = state.acq.scanShiftFast + fastNormalized * (state.init.scanAngularRangeReferenceFast * state.acq.scanAngleMultiplierFast)/state.acq.zoomFactor;
    slow = state.acq.scanShiftSlow + slowNormalized * (state.init.scanAngularRangeReferenceSlow * state.acq.scanAngleMultiplierSlow)/state.acq.zoomFactor;    
    
end

%Launch dialog used to re-park beam, if needed
if nargin < 2 || launchDialog
    hDlg = warndlg('Beam ON and pointing! Press to turn OFF and park.','Beam Pointing','replace');
    hButton = findobj(hDlg,'Style','pushbutton');
    
    set(hDlg,'CloseRequestFcn',@disablePoint);
    set(hButton,'Callback',@disablePoint);              
end

%Point laser beam
if state.acq.fastScanningX
    xy = [fast slow];
else
    xy = [slow fast];
end
xy = xy + [state.init.scanOffsetAngleX state.init.scanOffsetAngleY];

si_parkOrPointLaser(xy,'transmit');

    function disablePoint(src,evnt)
       scim_parkLaser();
       delete(gcbf);               
    end


end

