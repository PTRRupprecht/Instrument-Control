%         import ni.daqmx.*
%            ggTask.clear();
%            ggTask = Task('PRVoice Coil Sense Task');
%             PRvoiceCoil_sens = ggTask;
%             PRvoiceCoil_sens.createAIVoltageChan('Dev4',[16 17]);
       
       
%             pause(1.5);

samplingrate = 1e4;

% addpath('C:\Documents and Settings\rupppete\NI DAQ DABS');
% folderX = pwd;
% cd('C:\Documents and Settings\rupppete\NI DAQ DABS');
% import ni.daqmx.*      


diffPosition = Task('diffPosition');
diffPosition.createAOVoltageChan('Dev1',[4]);

cmdOutputRate = 1e2;
numsamples = 2;

diffPosition.stop();
diffPosition.cfgSampClkTiming(cmdOutputRate,'DAQmx_Val_FiniteSamps',numsamples);
diffPosition.cfgOutputBuffer(numsamples);
diffPosition.writeAnalogData(zeros(numsamples,1)',false);
%                             pumpControl.cfgSampClkTiming(obj.galvoCmdOutputRate,'DAQmx_Val_FiniteSamps',numsamples);
diffPosition.start(); 

diffPosition.stop();
diffPosition.clear();

offsetx = 0;
counter = 1;
clear meaX integratorX
clear XX;
while 1
    try; PRvoiceCoil_sens.stop(); end
    PRvoiceCoil_sens.cfgSampClkTiming(samplingrate,'DAQmx_Val_FiniteSamps',round(samplingrate*4/27));
    PRvoiceCoil_sens.start();
    pause(4/27+0.01);

    A = PRvoiceCoil_sens.readAnalogData();
    XX(:,8) = A(:,1);
    indizes = find(sum(XX));
    X = XX(:,indizes);
    integratorX(20) = mean(A(:,1));
    indizesI = find(integratorX);
    errorI = sum(integratorX(indizesI));
    B1 = conv(A(:,1),fspecial('gaussian',[1 1],9),'valid');
    B2 = conv(A(:,2),fspecial('gaussian',[1 1],9),'valid');
%                 [(mean(B1)-3.5)/(max(B1)-min(B1)) max(B1)-min(B1)]
    figure(31); subplot(3,1,1); plot((1:numel(B1))/32,B1);axis([0 numel(B1)/32 2.0 4.9]); grid on;
    subplot(3,1,2); plot((1:numel(B2))/32,B2);axis([0 numel(B2)/32 -1 1]);
    meaX(counter) = mean(B1);
    [mean(B1) median(mean(X))]
    counter = counter +1;
    subplot(3,1,3); plot(meaX-3.5,'.');
    drawnow;
    diffPosition.stop();
    diffPosition.cfgSampClkTiming(cmdOutputRate,'DAQmx_Val_FiniteSamps',numsamples);
    diffPosition.cfgOutputBuffer(numsamples);
    offsetx = offsetx + (3.5 - median(mean(X)))*0.05 + (23.5 - errorI)*0.00;
    diffPosition.writeAnalogData(offsetx*ones(numsamples,1),false);
    %                             pumpControl.cfgSampClkTiming(obj.galvoCmdOutputRate,'DAQmx_Val_FiniteSamps',numsamples);
    diffPosition.start();
    XX = circshift(XX,[0 1]);
    integratorX = circshift(integratorX,[0 1]);
end


      
            k = k + 1;
            
            TTT{k}.traces = A;
  
            save('Test25kHz_ZZHz.mat','TTT')