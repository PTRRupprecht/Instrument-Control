function [inputRangeVolts] = inputRangeIdToVolts(inputRangeId)
% Convert input range identifier to volts

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

switch inputRangeId
case INPUT_RANGE_PM_20_MV
    inputRangeVolts = 0.02;
case INPUT_RANGE_PM_40_MV
    inputRangeVolts = 0.04;
case INPUT_RANGE_PM_50_MV
    inputRangeVolts = 0.05;
case INPUT_RANGE_PM_80_MV
    inputRangeVolts = 0.08;
case INPUT_RANGE_PM_100_MV
    inputRangeVolts = 0.1;
case INPUT_RANGE_PM_200_MV
    inputRangeVolts = 0.2;
case INPUT_RANGE_PM_400_MV
    inputRangeVolts = 0.4;
case INPUT_RANGE_PM_500_MV
    inputRangeVolts = 0.5;
case INPUT_RANGE_PM_800_MV
    inputRangeVolts = 0.8;
case INPUT_RANGE_PM_1_V
    inputRangeVolts = 1;
case INPUT_RANGE_PM_2_V
    inputRangeVolts = 2;
case INPUT_RANGE_PM_4_V
    inputRangeVolts = 4;
case INPUT_RANGE_PM_5_V
    inputRangeVolts = 5;
case INPUT_RANGE_PM_8_V
    inputRangeVolts = 8;
case INPUT_RANGE_PM_10_V
    inputRangeVolts = 10;
case INPUT_RANGE_PM_20_V
    inputRangeVolts = 20;
case INPUT_RANGE_PM_40_V
    inputRangeVolts = 40;
case INPUT_RANGE_PM_16_V
    inputRangeVolts = 16;
case INPUT_RANGE_PM_1_V_25
    inputRangeVolts = 1.25;        
case INPUT_RANGE_PM_2_V_5
    inputRangeVolts = 2.5;	
case INPUT_RANGE_PM_125_MV
    inputRangeVolts = 0.125;
case INPUT_RANGE_PM_250_MV
    inputRangeVolts = 0.250;			
otherwise
    inputRangeVolts = 0;
end

end