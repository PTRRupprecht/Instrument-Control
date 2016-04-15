function [text] = boardTypeIdToText(boardType)
% Convert board type id to text

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

%call mfile with library definitions
AlazarDefs

switch boardType
case ATS850
    text = 'ATS850';
case ATS310
    text = 'ATS310';
case ATS330
    text = 'ATS330';
case ATS855
    text = 'ATS855';
case ATS315
    text = 'ATS315';
case ATS335
    text = 'ATS335';
case ATS460
    text = 'ATS460';
case ATS860
    text = 'ATS860';
case ATS660
    text = 'ATS660';
case ATS9461
    text = 'ATS9461';
case ATS9462
    text = 'ATS9462';
case ATS9850
    text = 'ATS9850';	
case ATS9870
    text = 'ATS9870';
case ATS9310
    text = 'ATS9310';		
case ATS9325
    text = 'ATS9325';	
case ATS9350
    text = 'ATS9350';
case ATS9351
    text = 'ATS9351';
case ATS9410
    text = 'ATS9410';	
case ATS9440
    text = 'ATS9440';
case ATS9360
    text = 'ATS9360';
case ATS9625
    text = 'ATS9625';	
case ATS9626
    text = 'ATS9626';
otherwise
    text = '?';
end          

end
