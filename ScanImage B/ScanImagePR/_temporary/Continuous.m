
% Device parameters
AODevice = 'Dev1';
AOChan = 0; % Must be 1 channel

import dabs.ni.daqmx.*

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
hAOTask.cfgSampClkTiming(sampleRate,'DAQmx_Val_ContSamps');
hAOTask.cfgOutputBuffer(numSamples);
A = hAOTask.writeAnalogData(sawtooth,false);%,-1,false,200000);
hAOTask.start();


hAOTask.isTaskDone()
hAOTask.stop();

hAOTask.clear();

