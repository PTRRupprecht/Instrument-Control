
addpath('C:\Documents and Settings\rupppete\NI DAQ DABS');
import ni.daqmx.*





%%function chanObjs = createAIVoltageChan(obj,deviceNames,chanIDs,chanNames,minVal,maxVal,units,customScaleName,terminalConfig)
%   deviceNames: String or string cell array specifying names of device on which channel(s) should be added, e.g. 'Dev1'. If a cell array, chanIDs must also be a cell array (of equal length).
%   chanIDs: A numeric array of channel IDs or, in the case of multiple deviceNames (a multi-device Task), a cell array of such numeric arrays
%   chanNames: (OPTIONAL) A string or string cell array specifying names to assign to each of the channels in chanIDs (if a single string, the chanID is appended for each channel) In the case of a multi-device Task, a cell array of such strings or string cell arrays. If omitted/empty, then default DAQmx channel name is used.
%   minVal: (OPTIONAL) The minimum value, in units, that you expect to generate. If omitted/blank, then largest possible range supported by device is used.
%   maxVal: (OPTIONAL) The maximum value, in units, that you expect to generate. If omitted/blank, then largest possible range supported by device is used.
%   units: (OPTIONAL) One of {'DAQmx_Val_Volts', 'DAQmx_Val_FromCustomScale'}. Specifies units in which to generate voltage. 'DAQmx_Val_FromCustomScale' specifies that units of a supplied scale are to be used (see 'units' argument). If blank/omitted, default is 'DAQmx_Val_Volts'.
%   customScaleName: (OPTIONAL) The name of a custom scale to apply to the channel. To use this parameter, you must set units to 'DAQmx_Val_FromCustomScale'. If you do not set units to DAQmx_Val_FromCustomScale, this argument is ignored.
%
%   chanObjs: The created Channel object(s)
            

% galvo scanner
% PRgalvo.clear();
PRgalvo = Task('PR Task galvo');
PRgalvo.createAOVoltageChan(['Dev1'],[0 1 2 3]);
galvoCmdOutputRate = 1e3;
amplitude = 3;
frequency_set = 10; % Hz
numsamples = floor(galvoCmdOutputRate/frequency_set);
% sinusTooth = sin((1:numsamples)/numsamples*2*pi);

effectiveFrequency = galvoCmdOutputRate/numsamples;
sawtoothThere = linspace(-amplitude,amplitude,numsamples-200)';
sawtoothBack = linspace(amplitude,-amplitude,200)';
% sawtooth = sinusTooth; %[sawtoothThere; sawtoothBack];
sawtooth = [sawtoothThere; sawtoothBack];

sawtooth2 = zeros(size(sawtooth));
sawtooth2(50:100) = 5;

sawtooth4 = [sawtooth, sawtooth2, sawtooth, sawtooth];

% set up analog output task, whait for a trigger input
PRgalvo.cfgSampClkTiming(galvoCmdOutputRate,'DAQmx_Val_ContSamps');
PRgalvo.cfgOutputBuffer(numsamples);
PRgalvo.writeAnalogData(sawtooth4,false);
% PRgalvo.cfgSampClkTiming(obj.galvoCmdOutputRate,'DAQmx_Val_FiniteSamps',length(sawtooth));
PRgalvo.start(); 

% pause(0.4);

saltooth = zeros(size(sawtooth));
% saltooth(1:1000) = 0.03; %saltooth(5001:10000) = 2.5;
size(saltooth)

A = PRgalvo.writeAnalogData(saltooth,true);
pause(1.0);
PRgalvo.stop();
PRgalvo.clear();