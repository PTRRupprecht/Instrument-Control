
import dabs.ni.daqmx.*



% frame trigger test


frameClock = Task('Frame clock');
framerate = 30;
if isempty(framerate); framerate = 20; disp('No framerate, dummy framerate set, PR.'); end; % dummy frequency, PR2014
dutyCycle = 0.5;
numFrames = 3400;
frameClock.createCOPulseChanFreq('Dev1', 0,[],framerate, dutyCycle);

% frameClock.set('startTrigRetriggerable',1)
% frameClock.cfgDigEdgeStartTrig(sprintf('PFI%d',obj.iLineClockReceive),'DAQmx_Val_Rising');

frameClock.cfgImplicitTiming('DAQmx_Val_ContSamps');


hFramePeriodCtr = Task('Frame Clock Period Counter');
hFramePeriodCtr.createCIPeriodChan('Dev1',2); %Uses ctr2
hFramePeriodCtr.cfgImplicitTiming('DAQmx_Val_ContSamps');
hFramePeriodCtr.channels(1).set('periodTerm','PFI0'); %Set frame clock source as the period source; assumes rising edge
      
hFramePeriodCtr.start();

frameClock.start();
pause(1.6);
frameClock.stop();
[A,B] = hFramePeriodCtr.readCounterData();

hFramePeriodCtr.stop();
frameClock.clear();
hFramePeriodCtr.clear();



%%




% galvo scanner
PRgalvo.clear();
PRgalvo = Task('PR Task galvo');
PRgalvo.createAOVoltageChan('Dev1',1);
galvoCmdOutputRate = 4e5;
amplitude = 0;
numsamples = floor(galvoCmdOutputRate/0.2);
% sinusTooth = sin((1:numsamples)/numsamples*2*pi);

effectiveFrequency = galvoCmdOutputRate/numsamples;
sawtoothThere = linspace(-amplitude,amplitude,numsamples-200)';
sawtoothBack = linspace(amplitude,-amplitude,200)';
sawtooth = [sawtoothThere; sawtoothBack]+0;

PRgalvo.cfgSampClkTiming(galvoCmdOutputRate,'DAQmx_Val_ContSamps');
PRgalvo.cfgOutputBuffer(numsamples+2);
A = PRgalvo.writeAnalogData(sawtooth,false);
PRgalvo.start();

PRgalvo.stop();
PRgalvo.clear();  
            

            
% resonant scanner

obj.CRScmd = Task('PR Task CRS');
obj.CRScmd.createAOVoltageChan('Dev1',0,sprintf('CRS command'),0,5);


obj.CRSdisable = Task('PR Task disable CRS');
obj.CRSdisable.createDOChan('Dev1','line0'); 
% disable resonant scanner
obj.CRSdisable.writeDigitalData(true,true);
obj.CRSdisable.writeDigitalData(false,true);



CRS_amplitude =0 ;

writeAnalogData(obj.CRScmd, CRS_amplitude, 1, true, 1);
% enable resonant scanner

while 1
PRgalvo.stop();
CRS_amplitude = 3;

writeAnalogData(obj.CRScmd, CRS_amplitude, 1, true, 1);

pause(2.5);
writeAnalogData(obj.CRScmd, 0, 1, true, 1);

PRgalvo.start();

pause(2.6);
end

obj.CRSdisable.stop();
obj.CRSdisable.start();

obj.CRScmd.stop();
obj.CRScmd.start();

obj.CRScmd.clear();
obj.CRSdisable.clear();

