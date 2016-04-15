import dabs.ni.daqmx.*
import dabs.ni.daqmx.demos.*

ctrValues = [];

hEdge1 = PulseGenerator('Dev1',3); %PO.3 -- connected to PFI7
hEdge2 = PulseGenerator('Dev1',4); %P0.4 -- connected to PFI6


hCtr = Task('Two-edge Sep counter');
hCtr.createCITwoEdgeSepChan('Dev1',3); %Ctr3 uses PFI7/6 by default for two-edge separation measurements
hCtr.cfgImplicitTiming('DAQmx_Val_ContSamps');

hCtr.start();

edgeSepValues = [1:10 30];

for i=1:length(edgeSepValues);
    hEdge1.go();
    pause(edgeSepValues(i));
    hEdge2.go();
    ctrValues(end+1) = hCtr.readCounterDataScalar();
    fprintf(1,'Read edge-separation value: %g\n',ctrValues(end));
end

delete(hCtr);
delete(hEdge1);
delete(hEdge2);
