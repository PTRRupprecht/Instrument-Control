
in hLSM:




AlazarDefs;

% TODO: Select CHA input parameters as required
retCode = ...
    calllib('ATSApi', 'AlazarInputControl', ...       
        obj.ATSboardHandle,		...	% HANDLE -- board handle
        CHANNEL_A,			...	% U8 -- input channel 
        DC_COUPLING,		...	% U32 -- input coupling id
        INPUT_RANGE_PM_1_V, ...	% U32 -- input range id
        IMPEDANCE_50_OHM	...	% U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControl failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Select CHB input parameters as required
retCode = ...
    calllib('ATSApi', 'AlazarInputControl', ...       
        obj.ATSboardHandle,		...	% HANDLE -- board handle
        CHANNEL_B,			...	% U8 -- channel identifier
        DC_COUPLING,		...	% U32 -- input coupling id
        INPUT_RANGE_PM_1_V,	...	% U32 -- input range id
        IMPEDANCE_50_OHM	...	% U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControl failed -- %s\n', errorToText(retCode));
    return
end



INPUT_RANGE_PM_100_MV 5 50?
INPUT_RANGE_PM_200_MV 6 50?
INPUT_RANGE_PM_400_MV 7 50?
INPUT_RANGE_PM_1_V 10 50?
INPUT_RANGE_PM_2_V 11 50?
INPUT_RANGE_PM_4_V 12 50?

