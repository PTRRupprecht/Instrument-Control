% -------------------------------------------------------------------------
% Title:   AlazarDefs.m
% Version: 6.1.0
% Date:    2013/01/30
% --------------------------------------------------------------------------

%---------------------------------------------------------------------------
%
% Copyright (c) 2008-2013 AlazarTech, Inc.
% 
% AlazarTech, Inc. licenses this software under specific terms and
% conditions. Use of any of the software or derivatives thereof in any
% product without an AlazarTech digitizer board is strictly prohibited. 
% 
% AlazarTech, Inc. provides this software AS IS, WITHOUT ANY WARRANTY,
% EXPRESS OR IMPLIED, INCLUDING, WITHOUT LIMITATION, ANY WARRANTY OF
% MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. AlazarTech makes no 
% guarantee or representations regarding the use of, or the results of the 
% use of, the software and documentation in terms of correctness, accuracy,
% reliability, currentness, or otherwise; and you rely on the software,
% documentation and results solely at your own risk.
% 
% IN NO EVENT SHALL ALAZARTECH BE LIABLE FOR ANY LOSS OF USE, LOSS OF 
% BUSINESS, LOSS OF PROFITS, INDIRECT, INCIDENTAL, SPECIAL OR CONSEQUENTIAL 
% DAMAGES OF ANY KIND. IN NO EVENT SHALL ALAZARTECH'S TOTAL LIABILITY EXCEED
% THE SUM PAID TO ALAZARTECH FOR THE PRODUCT LICENSED HEREUNDER.
% 
%---------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Return codes
%--------------------------------------------------------------------------

ApiSuccess                              = int32(512);
ApiFailed								= int32(513);
ApiAccessDenied                         = int32(514);
ApiDmaChannelUnavailable				= int32(515);
ApiDmaChannelInvalid					= int32(516);
ApiDmaChannelTypeError					= int32(517);
ApiDmaInProgress						= int32(518);
ApiDmaDone								= int32(519);
ApiDmaPaused							= int32(520);
ApiDmaNotPaused                         = int32(521);
ApiDmaCommandInvalid					= int32(522);
ApiDmaManReady							= int32(523);
ApiDmaManNotReady						= int32(524);
ApiDmaInvalidChannelPriority			= int32(525);
ApiDmaManCorrupted						= int32(526);
ApiDmaInvalidElementIndex				= int32(527);
ApiDmaNoMoreElements					= int32(528);
ApiDmaSglInvalid						= int32(529);
ApiDmaSglQueueFull						= int32(530);
ApiNullParam							= int32(531);
ApiInvalidBusIndex						= int32(532);
ApiUnsupportedFunction					= int32(533);
ApiInvalidPciSpace						= int32(534);
ApiInvalidIopSpace						= int32(535);
ApiInvalidSize							= int32(536);
ApiInvalidAddress						= int32(537);
ApiInvalidAccessType					= int32(538);
ApiInvalidIndex                         = int32(539);
ApiMuNotReady							= int32(540);
ApiMuFifoEmpty							= int32(541);
ApiMuFifoFull							= int32(542);
ApiInvalidRegister						= int32(543);
ApiDoorbellClearFailed					= int32(544);
ApiInvalidUserPin						= int32(545);
ApiInvalidUserState                     = int32(546);
ApiEepromNotPresent                     = int32(547);
ApiEepromTypeNotSupported				= int32(548);
ApiEepromBlank							= int32(549);
ApiConfigAccessFailed					= int32(550);
ApiInvalidDeviceInfo					= int32(551);
ApiNoActiveDriver						= int32(552);
ApiInsufficientResources				= int32(553);
ApiObjectAlreadyAllocated				= int32(554);
ApiAlreadyInitialized					= int32(555);
ApiNotInitialized						= int32(556);
ApiBadConfigRegEndianMode				= int32(557);
ApiInvalidPowerState					= int32(558);
ApiPowerDown							= int32(559);
ApiFlybyNotSupported					= int32(560);
ApiNotSupportThisChannel				= int32(561);
ApiNoAction                             = int32(562);
ApiHSNotSupported						= int32(563);
ApiVPDNotSupported						= int32(564);
ApiVpdNotEnabled						= int32(565);
ApiNoMoreCap							= int32(566);
ApiInvalidOffset						= int32(567);
ApiBadPinDirection						= int32(568);
ApiPciTimeout							= int32(569);
ApiDmaChannelClosed                     = int32(570);
ApiDmaChannelError						= int32(571);
ApiInvalidHandle						= int32(572);
ApiBufferNotReady						= int32(573);
ApiInvalidData							= int32(574);
ApiDoNothing							= int32(575);
ApiDmaSglBuildFailed					= int32(576);
ApiPMNotSupported						= int32(577);
ApiInvalidDriverVersion                 = int32(578);
ApiWaitTimeout							= int32(579);
ApiWaitCanceled                         = int32(580);
ApiBufferTooSmall						= int32(581);
ApiBufferOverflow						= int32(582);
ApiInvalidBuffer						= int32(583);
ApiInvalidRecordsPerBuffer				= int32(584);
ApiDmaPending							= int32(585);
ApiLockAndProbePagesFailed				= int32(586);
ApiWaitAbandoned						= int32(587);
ApiWaitFailed							= int32(588);
ApiTransferComplete                     = int32(589);
ApiPllNotLocked                         = int32(590);
ApiNotSupportedInDualChannelMode        = int32(591);
ApiNotSupportedInQuadChannelMode		= int32(592);
ApiFileIoError							= int32(593);
ApiInvalidClockFrequency				= int32(594);

%--------------------------------------------------------------------------
% Board types
%--------------------------------------------------------------------------

ATS_NONE        = int32(0);
ATS850          = int32(1);
ATS310          = int32(2);
ATS330          = int32(3);
ATS855          = int32(4);
ATS315          = int32(5);
ATS335          = int32(6);
ATS460          = int32(7);
ATS860          = int32(8);
ATS660          = int32(9);
ATS665          = int32(10);
ATS9462         = int32(11);
ATS9434         = int32(12);
ATS9870         = int32(13);
ATS9350         = int32(14);
ATS9325         = int32(15);
ATS9440         = int32(16);
ATS9410         = int32(17);
ATS9351         = int32(18);
ATS9310         = int32(19);
ATS9461         = int32(20);
ATS9850         = int32(21);
ATS9625         = int32(22);
ATG6500			= int32(23);
ATS9626			= int32(24);
ATS9360			= int32(25);
ATS_LAST        = int32(26);

%--------------------------------------------------------------------------
% Clock Control
%--------------------------------------------------------------------------

% Clock sources
INTERNAL_CLOCK              =	hex2dec('00000001');
EXTERNAL_CLOCK              =	hex2dec('00000002');
FAST_EXTERNAL_CLOCK         =	hex2dec('00000002')';
MEDIMUM_EXTERNAL_CLOCK      =	hex2dec('00000003')';
MEDIUM_EXTERNAL_CLOCK       =	hex2dec('00000003')';
SLOW_EXTERNAL_CLOCK         =	hex2dec('00000004')';
EXTERNAL_CLOCK_AC           =	hex2dec('00000005')';
EXTERNAL_CLOCK_DC           =	hex2dec('00000006')';
EXTERNAL_CLOCK_10MHz_REF    =	hex2dec('00000007')';
INTERNAL_CLOCK_DIV_5        =	hex2dec('000000010')';
MASTER_CLOCK                =	hex2dec('000000011')';

% Internal sample rates
SAMPLE_RATE_1KSPS           =	hex2dec('00000001');
SAMPLE_RATE_2KSPS           =	hex2dec('00000002');
SAMPLE_RATE_5KSPS           =	hex2dec('00000004');
SAMPLE_RATE_10KSPS          =	hex2dec('00000008');
SAMPLE_RATE_20KSPS          =	hex2dec('0000000A');
SAMPLE_RATE_50KSPS          =	hex2dec('0000000C');
SAMPLE_RATE_100KSPS         =	hex2dec('0000000E');
SAMPLE_RATE_200KSPS         =	hex2dec('00000010');
SAMPLE_RATE_500KSPS         =	hex2dec('00000012');
SAMPLE_RATE_1MSPS           =	hex2dec('00000014');
SAMPLE_RATE_2MSPS           =	hex2dec('00000018');
SAMPLE_RATE_5MSPS           =	hex2dec('0000001A');
SAMPLE_RATE_10MSPS          =	hex2dec('0000001C');
SAMPLE_RATE_20MSPS          =	hex2dec('0000001E');
SAMPLE_RATE_25MSPS          =	hex2dec('00000021');
SAMPLE_RATE_50MSPS          =	hex2dec('00000022');
SAMPLE_RATE_100MSPS         =	hex2dec('00000024');
SAMPLE_RATE_125MSPS         =   hex2dec('00000025');
SAMPLE_RATE_160MSPS         =   hex2dec('00000026');
SAMPLE_RATE_180MSPS         =   hex2dec('00000027');
SAMPLE_RATE_200MSPS         =	hex2dec('00000028');
SAMPLE_RATE_250MSPS         =   hex2dec('0000002B');
SAMPLE_RATE_400MSPS			= 	hex2dec('0000002D');
SAMPLE_RATE_500MSPS         =   hex2dec('00000030');
SAMPLE_RATE_800MSPS			= 	hex2dec('00000032');
SAMPLE_RATE_1GSPS           =   hex2dec('00000035');
SAMPLE_RATE_1000MSPS        =   hex2dec('00000035');
SAMPLE_RATE_1200MSPS        =   hex2dec('00000037');
SAMPLE_RATE_1500MSPS        =   hex2dec('0000003A');
SAMPLE_RATE_1600MSPS        =   hex2dec('0000003B');
SAMPLE_RATE_1800MSPS        =   hex2dec('0000003D');
SAMPLE_RATE_2000MSPS        =   hex2dec('0000003F');
SAMPLE_RATE_2GSPS           =   hex2dec('0000003F');
SAMPLE_RATE_USER_DEF        =	hex2dec('00000040');

% Clock edges
CLOCK_EDGE_RISING           =	hex2dec('00000000');
CLOCK_EDGE_FALLING          =	hex2dec('00000001');

% Decimation
DECIMATE_BY_8               =   hex2dec('00000008');
DECIMATE_BY_64              =   hex2dec('00000040');

%--------------------------------------------------------------------------
% Input Control
%--------------------------------------------------------------------------

% Input channels
CHANNEL_ALL                 =   hex2dec('00000000');
CHANNEL_A                   =   hex2dec('00000001');
CHANNEL_B                   =   hex2dec('00000002');
CHANNEL_C                   =   hex2dec('00000004');
CHANNEL_D                   =   hex2dec('00000008');
CHANNEL_E                   =   hex2dec('00000010');
CHANNEL_F                   =   hex2dec('00000012');
CHANNEL_G                   =   hex2dec('00000014');
CHANNEL_H                   =   hex2dec('00000018');

% Input ranges
INPUT_RANGE_PM_20_MV        =   hex2dec('00000001');
INPUT_RANGE_PM_40_MV        =   hex2dec('00000002');
INPUT_RANGE_PM_50_MV        =   hex2dec('00000003');
INPUT_RANGE_PM_80_MV        =   hex2dec('00000004');
INPUT_RANGE_PM_100_MV       =   hex2dec('00000005');
INPUT_RANGE_PM_200_MV       =   hex2dec('00000006');
INPUT_RANGE_PM_400_MV       =   hex2dec('00000007');
INPUT_RANGE_PM_500_MV       =   hex2dec('00000008');
INPUT_RANGE_PM_800_MV       =   hex2dec('00000009');
INPUT_RANGE_PM_1_V          =   hex2dec('0000000A');
INPUT_RANGE_PM_2_V          = 	hex2dec('0000000B');
INPUT_RANGE_PM_4_V          =	hex2dec('0000000C');
INPUT_RANGE_PM_5_V          =	hex2dec('0000000D');
INPUT_RANGE_PM_8_V          =	hex2dec('0000000E');
INPUT_RANGE_PM_10_V         =	hex2dec('0000000F');
INPUT_RANGE_PM_20_V         =	hex2dec('00000010');
INPUT_RANGE_PM_40_V         =	hex2dec('00000011');
INPUT_RANGE_PM_16_V         =   hex2dec('00000012');
INPUT_RANGE_HIFI            = 	hex2dec('00000020');
INPUT_RANGE_PM_1_V_25		= 	hex2dec('00000021');
INPUT_RANGE_PM_2_V_5		= 	hex2dec('00000025');
INPUT_RANGE_PM_125_MV		=	hex2dec('00000028');
INPUT_RANGE_PM_250_MV		=	hex2dec('00000030');

% Input impedances
IMPEDANCE_1M_OHM            =	hex2dec('00000001');
IMPEDANCE_50_OHM            =	hex2dec('00000002');
IMPEDANCE_75_OHM            =	hex2dec('00000004');
IMPEDANCE_300_OHM           =	hex2dec('00000008');
IMPEDANCE_600_OHM           =	hex2dec('0000000A');

% Input coupling 
AC_COUPLING                 =   hex2dec('00000001');
DC_COUPLING                 =	hex2dec('00000002');

%--------------------------------------------------------------------------
% Trigger Control
%--------------------------------------------------------------------------

% Trigger engines
TRIG_ENGINE_J               =	hex2dec('00000000');
TRIG_ENGINE_K               =	hex2dec('00000001');

% Trigger engine operations
TRIG_ENGINE_OP_J            =   hex2dec('00000000');
TRIG_ENGINE_OP_K            =	hex2dec('00000001');
TRIG_ENGINE_OP_J_OR_K		=   hex2dec('00000002');
TRIG_ENGINE_OP_J_AND_K		=   hex2dec('00000003');
TRIG_ENGINE_OP_J_XOR_K		=   hex2dec('00000004');
TRIG_ENGINE_OP_J_AND_NOT_K	=   hex2dec('00000005');
TRIG_ENGINE_OP_NOT_J_AND_K	=   hex2dec('00000006');

% Trigger engine sources
TRIG_CHAN_A                 =   hex2dec('00000000');
TRIG_CHAN_B                 =   hex2dec('00000001');
TRIG_EXTERNAL               =   hex2dec('00000002');
TRIG_DISABLE                =   hex2dec('00000003');
TRIG_CHAN_C                 =   hex2dec('00000004');
TRIG_CHAN_D                 =   hex2dec('00000005');

% Trigger slopes
TRIGGER_SLOPE_POSITIVE      =   hex2dec('00000001');
TRIGGER_SLOPE_NEGATIVE      =   hex2dec('00000002');

% External trigger ranges
ETR_DIV5                    =   hex2dec('00000000');
ETR_X1                      =   hex2dec('00000001');
ETR_5V                      =   hex2dec('00000000');
ETR_1V                      =   hex2dec('00000001');
ETR_TTL                     =   hex2dec('00000002');
ETR_2V5                     =   hex2dec('00000003');

%--------------------------------------------------------------------------
% Auxiliary I/O and LED Control
%--------------------------------------------------------------------------

% AUX outputs
AUX_OUT_TRIGGER             =	0;
AUX_OUT_PACER               =	2;
AUX_OUT_BUSY                =	4;
AUX_OUT_CLOCK               =	6;
AUX_OUT_RESERVED            =	8;
AUX_OUT_CAPTURE_ALMOST_DONE	=	10;
AUX_OUT_AUXILIARY			=	12;
AUX_OUT_SERIAL_DATA			=	14;
AUX_OUT_TRIGGER_ENABLE		=	16;

% AUX inputs
AUX_IN_TRIGGER_ENABLE		=	1;
AUX_IN_DIGITAL_TRIGGER		=	3;
AUX_IN_GATE					=	5;
AUX_IN_CAPTURE_ON_DEMAND	=	7;
AUX_IN_RESET_TIMESTAMP		=	9;
AUX_IN_SLOW_EXTERNAL_CLOCK	=	11;
AUX_IN_AUXILIARY			=	13;
AUX_IN_SERIAL_DATA			=	15;

AUX_INPUT_AUXILIARY			=	13;
AUX_INPUT_SERIAL_DATA		=	15;

% LED states
LED_OFF                     =	hex2dec('00000000');
LED_ON                      =	hex2dec('00000001');

%--------------------------------------------------------------------------
% Get/Set Parameters
%--------------------------------------------------------------------------

NUMBER_OF_RECORDS           =   hex2dec('10000001');
PRETRIGGER_AMOUNT           =   hex2dec('10000002');
RECORD_LENGTH               =   hex2dec('10000003');
TRIGGER_ENGINE              =   hex2dec('10000004');
TRIGGER_DELAY               =   hex2dec('10000005');
TRIGGER_TIMEOUT             =   hex2dec('10000006');
SAMPLE_RATE                 =   hex2dec('10000007');
CONFIGURATION_MODE          =   hex2dec('10000008'); 
DATA_WIDTH                  =   hex2dec('10000009'); 
SAMPLE_SIZE                 =   DATA_WIDTH;
AUTO_CALIBRATE              =   hex2dec('1000000A');
TRIGGER_XXXXX               =   hex2dec('1000000B');
CLOCK_SOURCE                =   hex2dec('1000000C');
CLOCK_SLOPE                 =   hex2dec('1000000D');
IMPEDANCE                   =   hex2dec('1000000E');
INPUT_RANGE                 =   hex2dec('1000000F');
COUPLING                    =   hex2dec('10000010');
MAX_TIMEOUTS_ALLOWED        =   hex2dec('10000011');
ATS_OPERATING_MODE          =   hex2dec('10000012'); 
CLOCK_DECIMATION_EXTERNAL   =   hex2dec('10000013');
LED_CONTROL                 =   hex2dec('10000014');
ATTENUATOR_RELAY            =   hex2dec('10000018');
EXT_TRIGGER_COUPLING        =   hex2dec('1000001A');
EXT_TRIGGER_ATTENUATOR_RELAY    =  hex2dec('1000001C');
TRIGGER_ENGINE_SOURCE       =   hex2dec('1000001E');
TRIGGER_ENGINE_SLOPE        =   hex2dec('10000020');
SEND_DAC_VALUE              =   hex2dec('10000021');
SLEEP_DEVICE                =   hex2dec('10000022');
GET_DAC_VALUE               =   hex2dec('10000023');
GET_SERIAL_NUMBER           =   hex2dec('10000024');
GET_FIRST_CAL_DATE          =   hex2dec('10000025');
GET_LATEST_CAL_DATE         =   hex2dec('10000026');
GET_LATEST_TEST_DATE        =   hex2dec('10000027');
SEND_RELAY_VALUE            =   hex2dec('10000028');
GET_LATEST_CAL_DATE_MONTH   =   hex2dec('1000002D');
GET_LATEST_CAL_DATE_DAY     =   hex2dec('1000002E');
GET_LATEST_CAL_DATE_YEAR    =   hex2dec('1000002F');
GET_PCIE_LINK_SPEED         =   hex2dec('10000030');
GET_PCIE_LINK_WIDTH         =   hex2dec('10000031');
SETGET_ASYNC_BUFFCOUNT      =   hex2dec('10000040');
SET_DATA_FORMAT             =   hex2dec('10000041');
GET_DATA_FORMAT             =   hex2dec('10000042');
DATA_FORMAT_UNSIGNED        =   0;
DATA_FORMAT_SIGNED          =   1;
SET_SINGLE_CHANNEL_MODE     =   hex2dec('10000043');
MEMORY_SIZE                 =   hex2dec('1000002A');
BOARD_TYPE                  =   hex2dec('1000002B');
ASOPC_TYPE                  =   hex2dec('1000002C');
GET_BOARD_OPTIONS_LOW       =   hex2dec('10000037');
GET_BOARD_OPTIONS_HIGH      =   hex2dec('10000038');
OPTION_STREAMING_DMA        =   uint32(2^0);
OPTION_AVERAGE_INPUT        =   uint32(2^1);
OPTION_EXTERNAL_CLOCK       =   uint32(2^1);
OPTION_DUAL_PORT_MEMORY 	=   uint32(2^2);
OPTION_180MHZ_OSCILLATOR    =   uint32(2^3);
OPTION_LVTTL_EXT_CLOCK      =   uint32(2^4);
OPTION_SW_SPI				=	uint32(2^5);
OPTION_ALT_INPUT_RANGES		= 	uint32(2^6);
OPTION_VARIABLE_RATE_10MHZ_PLL	= 	uint32(2^7);

TRANSFER_OFFET              =   hex2dec('10000030');
TRANSFER_LENGTH             =   hex2dec('10000031');
TRANSFER_RECORD_OFFSET      =   hex2dec('10000032');
TRANSFER_NUM_OF_RECORDS     =   hex2dec('10000033');
TRANSFER_MAPPING_RATIO      =   hex2dec('10000034');
TRIGGER_ADDRESS_AND_TIMESTAMP = hex2dec('10000035');
MASTER_SLAVE_INDEPENDENT    =   hex2dec('10000036');
TRIGGERED                   =   hex2dec('10000040');
BUSY                        =   hex2dec('10000041');
WHO_TRIGGERED               =   hex2dec('10000042');
SET_DATA_FORMAT				=   hex2dec('10000041');
GET_DATA_FORMAT				=   hex2dec('10000042');
DATA_FORMAT_UNSIGNED		=   0;
DATA_FORMAT_SIGNED			=   1;
SET_SINGLE_CHANNEL_MODE		=   hex2dec('10000043');
GET_SAMPLES_PER_TIMESTAMP_CLOCK	=   hex2dec('10000044');
GET_RECORDS_CAPTURED		=   hex2dec('10000045');
GET_MAX_PRETRIGGER_SAMPLES	=   hex2dec('10000046');
SET_ADC_MODE				=   hex2dec('10000047');
ECC_MODE					=   hex2dec('10000048');
ECC_DISABLE					=   0;
ECC_ENABLE					=   1;
GET_AUX_INPUT_LEVEL			=   hex2dec('10000049');
AUX_INPUT_LOW				=   0;
AUX_INPUT_HIGH				=   1;
GET_ASYNC_BUFFERS_PENDING   =   hex2dec('10000050');
GET_ASYNC_BUFFERS_PENDING_FULL =    hex2dec('10000051');
GET_ASYNC_BUFFERS_PENDING_EMPTY =   hex2dec('10000052');
ACF_SAMPLES_PER_RECORD      =   hex2dec('10000060');
ACF_RECORDS_TO_AVERAGE      =   hex2dec('10000061');
EXT_TRIGGER_IMPEDANCE		=   hex2dec('10000065');
EXT_TRIG_50_OHMS			= 	0;
EXT_TRIG_300_OHMS			= 	1;
GET_CHANNELS_PER_BOARD 		= 	hex2dec('10000070');
GET_CPF_DEVICE 				= 	hex2dec('10000071');
CPF_DEVICE_UNKNOWN 			= 	0;
CPF_DEVICE_EP3SL50 			= 	1;
CPF_DEVICE_EP3SE260 		= 	2;
PACK_MODE 					= 	hex2dec('10000072');
PACK_DEFAULT 				= 	0;
PACK_8_BITS_PER_SAMPLE 		= 	1;
GET_FPGA_TEMPERATURE		=	hex2dec('10000080');

% Master/Slave Configuration
BOARD_IS_INDEPENDENT        =   hex2dec('00000000');
BOARD_IS_MASTER             =	hex2dec('00000001');
BOARD_IS_SLAVE              =	hex2dec('00000002');
BOARD_IS_LAST_SLAVE         =	hex2dec('00000003');

% Attenuator Relay
AR_X1                       =   hex2dec('00000000');
AR_DIV40                    =   hex2dec('00000001');

% Device Sleep state
POWER_OFF                   =   hex2dec('00000000');
POWER_ON                    =   hex2dec('00000001');

% Software Events control
SW_EVENTS_OFF               =   hex2dec('00000000');
SW_EVENTS_ON                =   hex2dec('00000001');

% TimeStamp Value Reset Control
TIMESTAMP_RESET_FIRSTTIME_ONLY	= hex2dec('00000000');
TIMESTAMP_RESET_ALWAYS			= hex2dec('00000001');

% DAC Names used by API AlazarDACSettingAdjust 
ATS460_DAC_A_GAIN			=   hex2dec('00000001');
ATS460_DAC_A_OFFSET			=   hex2dec('00000002');
ATS460_DAC_A_POSITION		=   hex2dec('00000003');
ATS460_DAC_B_GAIN			=   hex2dec('00000009');
ATS460_DAC_B_OFFSET			=   hex2dec('0000000A');
ATS460_DAC_B_POSITION		=   hex2dec('0000000B');
ATS460_DAC_EXTERNAL_CLK_REF	=   hex2dec('00000007');

% DAC Names Specific to the ATS660
ATS660_DAC_A_GAIN			=   hex2dec('00000001');
ATS660_DAC_A_OFFSET			=   hex2dec('00000002');
ATS660_DAC_A_POSITION		=   hex2dec('00000003');
ATS660_DAC_B_GAIN			=   hex2dec('00000009');
ATS660_DAC_B_OFFSET			=   hex2dec('0000000A');
ATS660_DAC_B_POSITION		=   hex2dec('0000000B');
ATS660_DAC_EXTERNAL_CLK_REF	=   hex2dec('00000007');

% DAC Names Specific to the ATS665
ATS665_DAC_A_GAIN			=   hex2dec('00000001');
ATS665_DAC_A_OFFSET			=   hex2dec('00000002');
ATS665_DAC_A_POSITION		=   hex2dec('00000003');
ATS665_DAC_B_GAIN			=   hex2dec('00000009');
ATS665_DAC_B_OFFSET			=   hex2dec('0000000A');
ATS665_DAC_B_POSITION		=   hex2dec('0000000B');
ATS665_DAC_EXTERNAL_CLK_REF	=   hex2dec('00000007');

% Error return values
SETDAC_INVALID_SETGET       = 660;
SETDAC_INVALID_CHANNEL      = 661;
SETDAC_INVALID_DACNAME      = 662;
SETDAC_INVALID_COUPLING     = 663;
SETDAC_INVALID_RANGE        = 664;
SETDAC_INVALID_IMPEDANCE    = 665;
SETDAC_BAD_GET_PTR          = 667;
SETDAC_INVALID_BOARDTYPE    = 668;

% Constants to be used in the Application when dealing with Custom FPGAs
FPGA_GETFIRST               =   hex2dec('FFFFFFFF');
FPGA_GETNEXT                =   hex2dec('FFFFFFFE');
FPGA_GETLAST                =   hex2dec('FFFFFFFC');

%--------------------------------------------------------------------------
% AutoDMA Control 
%--------------------------------------------------------------------------

% AutoDMA flags 
ADMA_EXTERNAL_STARTCAPTURE  =   hex2dec('00000001');
ADMA_ENABLE_RECORD_HEADERS  =   hex2dec('00000008');
ADMA_SINGLE_DMA_CHANNEL     =   hex2dec('00000010');
ADMA_ALLOC_BUFFERS          =   hex2dec('00000020');
ADMA_TRADITIONAL_MODE       =   hex2dec('00000000');
ADMA_CONTINUOUS_MODE        =   hex2dec('00000100');
ADMA_NPT                    =   hex2dec('00000200');
ADMA_TRIGGERED_STREAMING    =   hex2dec('00000400');
ADMA_FIFO_ONLY_STREAMING    =   hex2dec('00000800');
ADMA_INTERLEAVE_SAMPLES     =   hex2dec('00001000');
ADMA_GET_PROCESSED_DATA     =   hex2dec('00002000');

% AutoDMA header constants
ADMA_CLOCKSOURCE            =   hex2dec('00000001');
ADMA_CLOCKEDGE              =   hex2dec('00000002');
ADMA_SAMPLERATE             =   hex2dec('00000003');
ADMA_INPUTRANGE             =   hex2dec('00000004');
ADMA_INPUTCOUPLING          =   hex2dec('00000005');
ADMA_IMPUTIMPEDENCE         =   hex2dec('00000006');
ADMA_EXTTRIGGERED           =   hex2dec('00000007');
ADMA_CHA_TRIGGERED          =   hex2dec('00000008');
ADMA_CHB_TRIGGERED          =   hex2dec('00000009');
ADMA_TIMEOUT                =   hex2dec('0000000A');
ADMA_THISCHANTRIGGERED      =   hex2dec('0000000B');
ADMA_SERIALNUMBER           =   hex2dec('0000000C');
ADMA_SYSTEMNUMBER           =   hex2dec('0000000D');
ADMA_BOARDNUMBER            =   hex2dec('0000000E');
ADMA_WHICHCHANNEL           =   hex2dec('0000000F');
ADMA_SAMPLERESOLUTION       =   hex2dec('00000010');
ADMA_DATAFORMAT             =   hex2dec('00000011');

%--------------------------------------------------------------------------
% AlazarSetClockSwitchOver
%--------------------------------------------------------------------------

CSO_DUMMY_CLOCK_DISABLE				= 0;
CSO_DUMMY_CLOCK_TIMER				= 1;
CSO_DUMMY_CLOCK_EXT_TRIGGER			= 2;
CSO_DUMMY_CLOCK_TIMER_ON_TIMER_OFF	= 3;

%--------------------------------------------------------------------------
% User-programmable FPGA
%--------------------------------------------------------------------------

% AlazarCoprocessorDownload
CPF_OPTION_DMA_DOWNLOAD	 		= 1;

% User-programmable FPGA device types
CPF_DEVICE_UNKNOWN				= 0;
CPF_DEVICE_EP3SL50				= 1;
CPF_DEVICE_EP3SE260				= 2;

% Framework defined registers
CPF_REG_SIGNATURE				= 0;
CPF_REG_REVISION				= 1;
CPF_REG_VERSION					= 2;
CPF_REG_STATUS					= 3;

%--------------------------------------------------------------------------
% AlazarSetExternalTriggerOperationForScanning 
%--------------------------------------------------------------------------

STOS_OPTION_DEFER_START_CAPTURE	 = 1;
