// WriteAnalogData.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include "mex.h"
#include "NIDAQmx.h"

//% General method for writing analog data to a Task containing one or more anlog output Channels
//%% function sampsPerChanWritten = writeAnalogData(task, writeData, timeout, autoStart, numSampsPerChan)
//%   writeData: Data to write to the Channel(s) of this Task. Supplied as matrix, whose columns represent Channels.
//%              Data should be of numeric types double, uint16, or int16.
//%              Data of double type will be 'scaled' by DAQmx driver, which includes application of software calibration, for devices which support this.
//%              Data of uint16/int16 types will be 'unscaled' -- i.e. in the 'native' format of the device. Note such samples will not be calibrated in software.
//%
//%   timeout: <OPTIONAL - Default: inf) Time, in seconds, to wait for function to complete read. If 'inf' or < 0, then function will wait indefinitely. A value of 0 indicates to try once to write the submitted samples. If this function successfully writes all submitted samples, it does not return an error. Otherwise, the function returns a timeout error and returns the number of samples actually written.
//%   autoStart: <OPTIONAL - Logical - Default: false> Logical value specifies whether or not this function automatically starts the task if you do not start it. 
//%   numSampsPerChan: <OPTIONAL> Specifies number of samples per channel to write. If omitted/empty, the number of samples is inferred from number of rows in writeData array. 
//%
//%   sampsPerChanWritten: The actual number of samples per channel successfully written to the buffer.
//%
//%% NOTES
//%   If double data is supplied, the DAQmxWriteAnalogF64 function in DAQmx API is used. 
//%   If uint16/int16 data is supplied, the DAQmxWriteBinaryU16/I16 functions, respectively, in DAQmx API are used.
//%
//%   The 'dataLayout' parameter of DAQmx API functions is not supported -- data is always grouped by Channel (DAQmx_Val_GroupByChannel).
//%   This corresponds to Matlab matrix ordering where each Channel corresponds to one column. 
//%
//%   Some general rules:
//%       If you configured timing for your task (using a cfgXXXTiming() method), your write is considered a buffered write. The # of samples in the FIRST write call to Task configures the buffer size, unless cfgOutputBuffer() is called first.
//%       Note that a minimum buffer size of 2 samples is required, so a FIRST write operation of only 1 sample (without prior call to cfgOutputBuffer()) will generate an error.
//%



//Static variables
bool32 dataLayout = DAQmx_Val_GroupByChannel; //This forces DAQ toolbox like ordering, i.e. each Channel corresponds to a column

//Helper functions
void handleDAQmxError(int32 status, const char *functionName)
{
	int32 errorStringSize;
	char *errorString;

	char *finalErrorString;

	//Display DAQmx error string
	errorStringSize = DAQmxGetErrorString(status,NULL,0); //Gets size of buffer
	errorString = (char *)mxCalloc(errorStringSize,sizeof(char));
	finalErrorString = (char*) mxCalloc(errorStringSize+100,sizeof(char));

	DAQmxGetErrorString(status,errorString,errorStringSize);

	sprintf(finalErrorString, "DAQmx Error (%d) encountered in %s:\n %s\n", status, functionName, errorString);
	mexErrMsgTxt(finalErrorString);
}


//Gateway routine
//sampsPerChanWritten = writeAnalogData(task, writeData, timeout, autoStart, numSampsPerChan)
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	//General vars
	char errMsg[512];
	
	//Read input arguments
	float64 timeout;
	int numSampsPerChan;
	bool32 autoStart;
	TaskHandle taskID, *taskIDPtr;

	//Get TaskHandle
	taskIDPtr = (TaskHandle*)mxGetData(mxGetProperty(prhs[0],0, "taskID"));
	taskID = *taskIDPtr;

	if ((nrhs < 3) || mxIsEmpty(prhs[2]))
		timeout = 10.0;
	else
	{
		timeout = (float64) mxGetScalar(prhs[2]);
		if (mxIsInf(timeout))
			timeout = DAQmx_Val_WaitInfinitely;
	}

	if ((nrhs < 4) || mxIsEmpty(prhs[3])) {
		int32 sampTimingType = 0;
		int32 status = DAQmxGetSampTimingType(taskID,&sampTimingType);
		if (status!=0) {
			mexErrMsgTxt("Failed to get sample timing type from DAQmx.");
		}
		autoStart = (sampTimingType==DAQmx_Val_OnDemand);
	}
	else
		autoStart = (bool32) mxGetScalar(prhs[3]);

	size_t numRows = mxGetM(prhs[1]);
	if ((nrhs < 5) || mxIsEmpty(prhs[4]))
		numSampsPerChan = numRows;
	else
		numSampsPerChan = (int) mxGetScalar(prhs[4]);

	//Verify correct input length

	//Write data
	int32 sampsWritten;
	int32 status;


	switch (mxGetClassID(prhs[1]))
	{	
		case mxUINT16_CLASS:
			status = DAQmxWriteBinaryU16(taskID, numSampsPerChan, autoStart, timeout, dataLayout, (uInt16*) mxGetData(prhs[1]), &sampsWritten, NULL);
		break;

		case mxINT16_CLASS:
			status = DAQmxWriteBinaryI16(taskID, numSampsPerChan, autoStart, timeout, dataLayout, (int16*) mxGetData(prhs[1]), &sampsWritten, NULL);
		break;

		case mxDOUBLE_CLASS:
			status = DAQmxWriteAnalogF64(taskID, numSampsPerChan, autoStart, timeout, dataLayout, (float64*) mxGetData(prhs[1]), &sampsWritten, NULL);
		break;

		default:
			sprintf_s(errMsg,"Class of supplied writeData argument (%s) is not valid", mxGetClassName(prhs[1]));
			mexErrMsgTxt(errMsg);
	}

	//Handle output arguments and errors
	if (!status)
	{
		if (nlhs > 0) {
			plhs[0] = mxCreateDoubleScalar(0);	
			double *sampsPerChanWritten = mxGetPr(plhs[0]);
		}

		//mexPrintf("Successfully wrote %d samples of data\n", sampsWritten);		
	}
	else //Write failed
		handleDAQmxError(status, mexFunctionName());
}




