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
%
% This sample configures an ATS9440 to make a no pre-trigger (NPT) mode
% AutoDMA acqusition, optionally saving the data to file and displaying it
% on screen.
%

% Add path to AlazarTech mfiles
addpath('C:\ScanImagePR\_PRalazar\Include')

% Call mfile with library definitions
AlazarDefs

% Load driver library 
if ~alazarLoadLibrary()
    fprintf('Error: ATSApi.dll not loaded\n');
    return
end

% TODO: Select a board 
systemId = int32(1);
boardId = int32(1);

% Get a handle to the board
boardHandle = calllib('ATSApi', 'AlazarGetBoardBySystemID', systemId, boardId);
setdatatype(boardHandle, 'voidPtr', 1, 1);
if boardHandle.Value == 0
    fprintf('Error: Unable to open board system ID %u board ID %u\n', systemId, boardId);
    return
end

% Configure the board's sample rate, input, and trigger settings
if ~configureBoard_new(boardHandle)
    fprintf('Error: Board configuration failed\n');
    return
end

% Acquire data, optionally saving it to a file
if ~acquireData(boardHandle)
    fprintf('Error: Acquisition failed\n');
    return
end


