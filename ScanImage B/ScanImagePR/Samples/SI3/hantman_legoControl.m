function hantman_legoControl(eventName,eventData,rxeFileName)
%ScanImage 3.8 user function to start a Lego Mindstorm operation, determined by supplied RXE file, for each GRAB acquisition or LOOP Repeat

persistent hLego

switch eventName
    
    case 'acquisitionStart'
        if isempty(hLego)
            hLego = COM_OpenNXT();
        end
        
        NXT_StopProgram(hLego);

    case 'startTriggerReceived'
        if ~isempty(rxeFileName)
            NXT_StartProgram([rxeFileName '.rxe'],hLego);
        end
        
        %         switch motionType
        %             case 'quarterback'
        %                 NXT_StartProgram('quarterback.rxe',hLego);
        %             case 'forward'
        %                 NXT_StartProgram('forward.rxe',hLego);
        %         end
        
    case {'acquisitionDone' 'abortAcquisitionEnd'}
        currProgram = NXT_GetCurrentProgramName(hLego);
        if ~strcmpi(currProgram,'No active program')
            fprintf(2,'WARNING: Program ''%s'' was running at end of acquisition. Program has been stopped.\n',currProgram);
        end
        NXT_StopProgram(hLego);
end




