%% DIGITAL OUTPUT EXTRA EDITION

% digital output: port 1 = PFI, port 0 = DIO; both start with lines from 0,
% but the PFI0 is a special output
% if not using the ports, but only lines, then DIO 0-7 is lines 0-7, and
% PFI 0-7 is lines 8-15

% ff = dabs.ni.daqmx.Task(sprintf('Trigger'));
% ff.createDOChan('si4',sprintf('port%d/line%d',0,1));
% % ff.createDOChan('si4',sprintf('line%d',9));
% ff.writeDigitalData(1); pause(0.5)
% ff.writeDigitalData(0);       
% ff.clear()



% Device parameters
AODevice = 'Dev1';
AOChan = 0; % Must be 1 channel

import dabs.ni.daqmx.*

hAOTask1 = Task('Peter Tas');
hAOTask1.createAOVoltageChan(AODevice,0);
A = hAOTask1.writeAnalogData(1.0,true);

hAOTask2 = Task('Peter T');
hAOTask2.createAOVoltageChan(AODevice,1);
A = hAOTask2.writeAnalogData(1.5,true);

hAOTask1.clear()
hAOTask2.clear()


%sawtooth frequency
frequency = 1000;
sampleRate = 1e5; %Hz

numSamples = round(sampleRate/frequency);

f_effective = sampleRate/numSamples


% updatePeriodSamples = round(updatePeriod * sampleRate);

hAOTask = Task('Peter Task1');

hAOTask.createAOVoltageChan(AODevice,AOChan);


sawtooth = linspace(-2,2,numSamples)';

% set up analog output task, whait for a trigger input
hAOTask.cfgDigEdgeStartTrig(sprintf('PFI%d',1));
hAOTask.set('startTrigRetriggerable',1);
hAOTask.cfgSampClkTiming(sampleRate,'DAQmx_Val_FiniteSamps',numSamples);
hAOTask.cfgOutputBuffer(numSamples);
A = hAOTask.writeAnalogData(sawtooth,false);%,-1,false,200000);
hAOTask.start();

% set up digital output that will be used as an external trigger for PFI1

DODevice = 'si4';

hTrigger = dabs.ni.daqmx.Task(sprintf('Trigger'));
hTrigger.createDOChan(DODevice,sprintf('line%d',7));

for i = 1:3
    hTrigger.writeDigitalData(1,1); pause(0.9)
    hTrigger.writeDigitalData(0,1);
end
hTrigger.start()

hTrigger.clear();

hAOTask.isTaskDone()
hAOTask.stop();

hAOTask.clear();


% hAOTask.cfgImplicitTiming('DAQmx_Val_FiniteSamps',5e5);

% obj.hGalvos.createAOVoltageChan(obj.mdfData.galvoDeviceID,obj.mdfData.galvoChanIDs);
                
%     obj.hGalvos.cfgSampClkTiming(obj.mdfData.galvoCmdOutputRate,'DAQmx_Val_FiniteSamps',2);
%     obj.hGalvos.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.mdfData.extFrameClockTerminal));
%     obj.hGalvos.set('startTrigRetriggerable',1);
% 
%     obj.hGalvos.control('DAQmx_Val_Task_Unreserve');
%     obj.hGalvosPark.writeAnalogData(repmat(0,1,numel(obj.mdfData.galvoChanIDs)));
% 
%     obj.hGalvos.cfgSampClkTiming(obj.mdfData.galvoCmdOutputRate,'DAQmx_Val_FiniteSamps',numSamples);
%     obj.hGalvos.cfgOutputBuffer(numSamples);
% 
%     obj.hGalvos.writeAnalogData(obj.galvoAODataBuf1D * voltFactor(1));
                
% hTask.cfgSampClkTiming(sampleRate,'DAQmx_Val_ContSamps');

% hTask.registerEveryNSamplesEvent(@JohannesCallback,updatePeriodSamples);


% hTask.start();

