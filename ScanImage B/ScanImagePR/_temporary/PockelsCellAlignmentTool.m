
import dabs.ni.daqmx.*


% galvo scanner
try; PRgalvo.clear(); end
PRgalvo = Task('PR Task galvo');
PRgalvo.createAOVoltageChan('si4',1);
galvoCmdOutputRate = 4e3;
amplitude = 0;
numsamples = floor(galvoCmdOutputRate/1);
% sinusTooth = sin((1:numsamples)/numsamples*2*pi);

effectiveFrequency = galvoCmdOutputRate/numsamples;
sawtoothThere = linspace(1.5,1.5,numsamples)';
sawtoothThere = [sawtoothThere; 1.5*ones(2000,1); 1.5*ones(2000,1)];

% figure; plot(sawtoothThere)


% sawtooth = [sawtooth; 1; -1];
% set up analog output task, whait for a trigger input
PRgalvo.cfgSampClkTiming(galvoCmdOutputRate,'DAQmx_Val_ContSamps');
PRgalvo.cfgOutputBuffer(numel(sawtoothThere)+2);
A = PRgalvo.writeAnalogData(sawtoothThere,false);
% PRgalvo.cfgSampClkTiming(obj.galvoCmdOutputRate,'DAQmx_Val_FiniteSamps',length(sawtooth));
PRgalvo.start();

PRgalvo.stop();
PRgalvo.clear();  
            