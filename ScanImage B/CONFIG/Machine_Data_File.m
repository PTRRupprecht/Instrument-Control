% Most Software Machine Data File

%% ScanImage
extFrameClockTerminal = 0; % Numeric scalar identifying PFI terminal (0-15) to which external frame clock signal is connected to boards requiring it (primaryDeviceID, beamDeviceID, fastZAODeviceID)

%Ctr0-3 channels on this board are reserved. 
primaryDeviceID = 'si4'; %String identifying 'primary' NI board used by ScanImage. 

%Resonant scanner parameters. Default values correspond to Cambridge CRS-8 scanner specifications
scannerMaxAngularRange = 15 * 0.88; %Max optical angular range (peak-peak) which scanner can achieve - including only portion of amplitude considered suitable for acquisition. 
scannerFrequencyNominal = 7.91e3; %Frame rate, in Hz, of laser scanner system

%Thor LSM system parameters
lsmDigitizerPositive = true; %If true, voltage values are directly mapped to positive pixel values. If false, digitizer inverts negative voltage values to positive pixel values. Should be set in accordance with the polarity of the photodetector/amplifier system in use.

%Self-trigger parameters. Required to allow ScanImage to 'trigger itself'.
trigSelfTrigSourceDeviceID = 'si4'; %String specifying device name on which ScanImage self trigger is generated. 
trigSelfTrigSourceLineID = 0; %Numeric scalar identifying digital output line, on port 0 of board identified by primaryBoardID, on which ScanImage generates trigger signal to start self-triggered acquisitions
trigSelfTrigDestinationTerminal = 2;  % Numeric scalar identifying PFI terminal (0-15) to which digital output identified by trigSelfTrigSourceLineID is connected on /all/ ScanImage-controlled boards

% ************ OPTIONAL *********************

pmtModuleControl = false; %If true, (Thorlabs-supplied) PMT power supply is controlled/monitored by ScanImage

%Beam (typically Pockels cells) and beam calibration (typically photodiode) channels

%If any Beam is defined, the scanner line clock signal must be connected to a specified extLineClockTerminal
extLineClockTerminal = 1; %PFI terminal (0-15) on which line clock signal is input to boards requiring it (beamDeviceID)

beamDeviceID = 'si4'; %String or cell string array of device name(s) containing beam modulation channels. If single string, applies to all channels in beamChanIDs.
beamChanIDs = [1]; %Array of integers specifying AO channel IDs, one for each beam modulation channel. Length of array determines number of 'beams'.
beamIDs = {'Ti-Sa MaiTai HP'}; %Optional string cell array of identifiers for each beam
beamVoltageRanges = 1.5; %Scalar or array of values specifying voltage range to use for each beam. Scalar applies to each beam.
beamCmdOutputRate = 7e5; %Sampling rate to use beam output channels
beamCalInputDeviceIDs = 'si4'; %String or cell string array of device name(s) containing beam calibration channels. If single string, applies to all beamCalInputChanIDs.
beamCalInputChanIDs = [1]; %Array of integers specifying AI channel IDs, one for each beam modulation channel. Values of nan specify no calibration for particular beam.
beamCalOffsets = 0.0693962; %Array of beam calibration offset voltages for each beam calibration channel

%Galvo for Y control or X/Y control
galvoDeviceID = '';
galvoChanIDs = []; %Scalar or 2-vector specifying 1) single chanID for Y galvo control OR 2) pair of chanIDs for X/Y galvo control.
galvoCmdOutputRate = 5e5; %Sampling rate to use for galvo output channels
galvoAngle2VoltageFactor = 5*0.125*3/4; %Scalar or 2-vector specifying conversion factor from optical degrees to volts. Use 2-vector to specify separate X & Y galvo conversion factor (in that order).
crsAngle2VoltageFactor = 0.2; %Scalar or 2-vector specifying conversion factor from optical degrees to volts. Use 2-vector to specify separate X & Y galvo conversion factor (in that order).
galvoAngle2LSMAngleFactor = 1; %Scalar specifying ratio (scaling factor) of SI4 Y galvo max angular range to LSM Y galvo max angular range
galvoParkAngles = 9; %Scalar or 2-vector of angle(s), in optical degrees, at which to park galvo(s) when not acquiring. Vector length should equal galvoChanIDs
galvoAcceleration = 1; %In optical-degrees/s^2
galvoMaxVelocity = 1; %In optical-degree/s 

%Shutter(s) used to prevent any beam exposure from reaching specimen during idle periods
shutterDeviceIDs = 'si4'; %String or cell string array of device name(s) on which shutter output(s) are generated. If single string, applies to all shutterLineIDs
shutterPortIDs = 0; %Scalar integer or array of integers indicating port number for each shutter line. If scalar, same port number used for all shutterLineIDs
shutterLineIDs = [7]; %Scalar integer or array of integers indicating line number for each shutter line. One value for each shutter line controlled by application
shutterOpenLevel = 1; %Logical or 0/1 scalar/array indicating TTL level (0=LO;1=HI) corresponding to shutter open state for each shutter line. If scalar, value applies to all shutterLineIDs
shutterBeforeEOM = true; %Logical or 0/1 indicating if shutter is before EOM. Single value, applying to all shutterLineIDs.
shutterIDs = {'shutterBeforePockels'}; %Optional string cell array of identifiers for the shutters, one for each of the shutterLineIDs
shutterOpenTime = 0.2; %Time, in seconds, to delay following certain shutter open commands (e.g. between stack slices), allowing shutter to fully open before proceeding.

%Motor used for X/Y/Z motion, including stacks. 
%motorDimensions & motorControllerType must be specified to enable this feature.
%Supported moto
motorDimensions = 'XYZ'; %If supplied, one of {'XYZ', 'XY', 'Z'}. Defaults to 'XYZ'.
motorControllerType = 'sutter.mp285'; %If supplied, one of  {'thorlabs.bscope', 'sutter.MP285', 'sutter.MPC200', 'scientifica', 'pi.E665', 'pi.E816', 'pi.E753', 'luigsneumann.SM5', 'npoint.LC40x'}
motorStageType = ''; %Some controller require a valid stageType be specified
motorCOMPort = [1]; %Integer identifying COM port for controller, if using serial communication
motorBaudRate = []; %Value identifying baud rate of serial communication. If empty, default value for controller used.
motorZDepthPositive = true; %Logical indicating if larger Z values correspond to greater depth
motorPositionDeviceUnits = []; %1x3 array specifying, in meters, raw units in which motor controller reports position. If unspecified, default positionDeviceUnits for stage/controller type presumed.
motorVelocitySlow = []; %Velocity to use for moves smaller than motorFastMotionThreshold value. If unspecified, default value used for controller. Specified in units appropriate to controller type.
motorVelocityFast = []; %Velocity to use for moves larger than motorFastMotionThreshold value. If unspecified, default value used for controller. Specified in units appropriate to controller type.

%Secondary motor for Z motion, allowing either XY-Z or XYZ-Z hybrid configuration
motor2ControllerType = ''; %If supplied, one of {'thorlabs.bscope', 'sutter.MP285', 'sutter.MPC200', 'scientifica', 'pi.E665', 'pi.E816', 'pi.E753', 'luigsneumann.SM5', 'npoint.LC40x'}
motor2StageType = ''; %Some controller require a valid stageType be specified
motor2COMPort = []; %Integer identifying COM port for controller, if using serial communication
motor2BaudRate = []; %Value identifying baud rate of serial communication. If empty, default value for controller used.
motor2ZDepthPositive = true; %Logical indicating if larger Z values correspond to greater depth
motor2PositionDeviceUnits = [];  %1x3 array specifying, in meters, raw units in which motor controller reports position. If unspecified, default positionDeviceUnits for stage/controller type presumed.
motor2VelocitySlow = []; %Velocity to use for moves smaller than motorFastMotionThreshold value. If unspecified, default value used for controller. Specified in units appropriate to controller type.
motor2VelocityFast = []; %Velocity to use for moves larger than motorFastMotionThreshold value. If unspecified, default value used for controller. Specified in units appropriate to controller type.

%FastZ hardware used for fast axial motion, supporting fast stacks and/or volume imaging
%fastZControllerType must be specified to enable this feature. 
%Specifying fastZControllerType='useMotor2' indicates that motor2 ControllerType/StageType/COMPort/etc will be used.
fastZControllerType = ''; %If supplied, one of {'useMotor2', 'pi.e665', 'pi.e816'}. 
fastZCOMPort = []; %Integer identifying COM port for controller, if using serial communication
fastZBaudRate = []; %Value identifying baud rate of serial communication. If empty, default value for controller used.

%Some FastZ hardware requires or benefits from use of an analog output used to control sweep/step profiles
%If analog control is used, then an analog sensor (input channel) must also be configured
fastZAODeviceID = ''; %String specifying device name containing AO channel used for FastZ control
fastZAOChanID = []; %Scalar integer indicating AO channel used for FastZ control
fastZAIDeviceID = '';  %String specifying device name containig AI channel used for FastZ position sensor
fastZAIChanID = [];  %Scalar integer indicating AI channel used for FastZ sensor
fastZCmdOutputRate = 5e5; %Sampling rate to use for fastZ AO command signals


%New hardware replacing and enhancing the Thorlabs stuff, modified PR2014-08-27, PR2015-07-08
scanDevice = 'Dev1'; % DAQ board for scanning, frame generator and triggered lineClock
frameClockChannel = 0; % counter output channel (CO)
resScanChannel = 0; % analog output (AO) channel for amplitude of resonant scanner
disableResScan = 'line0'; % digital output (DA) channel to disable resonant scanner
galvoChannel = 1; % analog output (AO) channel
galvoTriggerChannel = 0; % PFI channel, must receive frame trigger for retriggerable galvo
lineClockChan = 1; % counter output (CO) channel for lineclock generation (dummy)
iLineClockChan = 2; % counter output (CO) channel for lineclock delay generation
iLineClockTrig = 1; % PFI channel receiving the lineClock and triggering the iLineClock with a given delay
iLineClockReceive = 3; % PFI channel receiving the ilineClock and triggering the frameClock without delay
frameClock2Chan = 1; % Counter output channel for frameClock2
frameClock2Trig = 2; % PFI channel receiving frameClock, for use with frameClock2 task
xTrigCtr = 3; % Counter Channel for xTrigger (terminates the acquisition when a sufficient number of frames has arrived)
fastzDevice = 'DevZ'; % DAQ board for fast z-scanning, frame generator and triggered lineClock
fastzAOChannel = 0; % analog output channel used for waveform to control fast z-motor
fastzAOPockels = 1; % analog output channel used for waveform to control slow pockels cell modulation with z
fastzAIHallSensor = 0; % analog input channel used for detecting the position of the fast z-mirror

%% Thorlabs Devices
% apiCurrentVersion = '1.5'; %One of {'1.4' '1.5'}.

