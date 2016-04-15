format short

import dabs.ni.daqmx.*

hTriggerCallbackCtr = Task('Trigger Callback Counter');
hTriggerCallbackCtr.createCICountEdgesChan('Dev1',3); %Uses ctr3
% hTriggerCallbackCtr.cfgSampClkTiming(0.5, 'DAQmx_Val_ContSamps', [], 'PFI1'); %Sample rate is 'dummy' value. Trigger terminal is a temp value, to be overwritten.
hTriggerCallbackCtr.cfgSampClkTiming(1000, 'DAQmx_Val_HWTimedSinglePoint', [], 'PFI1'); %Sample rate is 'dummy' value. Trigger terminal is a temp value, to be overwritten.
% hTriggerCallbackCtr.cfgImplicitTiming('DAQmx_Val_ContSamps');
hTriggerCallbackCtr.registerSignalEvent({@(varargin)dubidu(43)},'DAQmx_Val_SampleClock');
      
hTriggerCallbackCtr.start()


hTriggerCallbackCtr.stop()
hTriggerCallbackCtr.clear();






