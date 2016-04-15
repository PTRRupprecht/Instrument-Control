function [result] = alazarLoadLibrary
% Load ATSApi.dll, the AlazarTech driver shared library 

%---------------------------------------------------------------------------
%
% Copyright (c) 2008-2013 AlazarTech, Inc.
%
% AlazarTech, Inc. licenses this software under specific terms and
% conditions. Use of any of the software or derivatives thereof in any
% product without an AlazarTech digitizer board is strictly prohibited.
%
% AlazarTech, Inc. provides this software AS IS, WITHOUT ANY WARRANTY,
% EXPRESS OR IMPLIED, INCLUDING, WITHOUT LIMITATION, ANY WARRANTY OF
% MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. AlazarTech makes no
% guarantee or representations regarding the use of, or the results of the
% use of, the software and documentation in terms of correctness, accuracy,
% reliability, currentness, or otherwise; and you rely on the software,
% documentation and results solely at your own risk.
%
% IN NO EVENT SHALL ALAZARTECH BE LIABLE FOR ANY LOSS OF USE, LOSS OF
% BUSINESS, LOSS OF PROFITS, INDIRECT, INCIDENTAL, SPECIAL OR CONSEQUENTIAL
% DAMAGES OF ANY KIND. IN NO EVENT SHALL ALAZARTECH%S TOTAL LIABILITY EXCEED
% THE SUM PAID TO ALAZARTECH FOR THE PRODUCT LICENSED HEREUNDER.
%
%---------------------------------------------------------------------------

% set default return code to indicate failure
result = false;

% Load driver library 
if ~libisloaded('ATSApi')    
    if strcmpi(computer('arch'), 'win64') 
        % Use protofile for 64-bit MATLAB
        loadlibrary('ATSApi.dll',@AlazarInclude_pcwin64)
    elseif sscanf(version('-release'), '%d') >= 2009
        % Use protofile for 32-bit MATLAB 2009 and later
        loadlibrary('ATSApi.dll',@AlazarInclude_pcwin32)
    else
        % Use protofile for 32-bit versions of MATLAB ealier than 2009
        loadlibrary('ATSApi.dll',@AlazarInclude)                
    end
    if libisloaded('ATSApi')
        result = true;
    end
else
    % The driver is aready loaded
    result = true;
end

end