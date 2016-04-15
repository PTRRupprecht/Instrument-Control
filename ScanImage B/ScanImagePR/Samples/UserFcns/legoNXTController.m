function legoNXTController(src,evnt,rxeFileName)


persistent hLego

switch evnt.EventName
    
    case 'acquisitionStart'
         %COM_CloseNXT('all');
       if isempty(hLego)
           hLego = COM_OpenNXT();

           %            try
           %              hLego = COM_OpenNXT();
           %            catch  %#ok<CTCH>
           %                COM_CloseNXT('all');
           %                hLego = COM_OpenNXT();
           %            end
       end
         
        NXT_StopProgram(hLego);
        
    case 'startTriggerProcessed'
        %runLego();
        startDelay = 1; %Delay from trigger  time to start of NXT program
        triggerProcessingTime = 0.5; %Measured triggerFcn processing time via tic/toc
        t = timer('TimerFcn',{@triggerNXT,rxeFileName, hLego}, 'StartDelay', startDelay - triggerProcessingTime);
        start(t);
        
        
        %         switch motionType
        %             case 'quarterback'
        %                 NXT_StartProgram('quarterback.rxe',hLego);
        %             case 'forward'
        %                 NXT_StartProgram('forward.rxe',hLego);
        %         end
        
    case {'acquisitionDone' 'acquisitionAborted'}
        currProgram = NXT_GetCurrentProgramName(hLego);
        if ~strcmpi(currProgram,'No active program')
            fprintf(2,'WARNING: Program ''%s'' was running at end of acquisition. Program has been stopped.\n',currProgram);
        end
        NXT_StopProgram(hLego);
end
end

function triggerNXT(src,evt, rxeFileName, hLego)

if ~isempty(rxeFileName)
    NXT_StartProgram([rxeFileName '.rxe'],hLego);
end

end





