#include "mex.h"
#include "stdio.h"
#include "math.h"
// undef needed for LCC compiler
#undef EXTERN_C
#include <windows.h>
#include <process.h>    


// This c function square.c is a simple example of multi-threading
// for windows. 
// It uses 2 worker threads and a main thread. The first worker thread
// will square all values on the even indexes x[0] x[2] .. x[n], and the second 
// worker thread all odd indexes x[1] x[3] .. x[n].
//
// example 1, 
// mex square.c -v;
// y = square([1 2 3 4 5 6 7 8 9])
//
// example 2,
// y = square(rand(100,100));


// Variables used to detect if the threads are finished
// (volatile: reload the variable instead of using the value available in a register)
static volatile int WaitForThread1;
static volatile int WaitForThread2;

// Finished percentage of the total input numbers
static volatile double percentage;

// Mutex used to lock percentage variable, to allow only one thread to 
// read or write it at the same time.
static HANDLE percentageMutex;

// The function which is multi threaded. 
// When ThreadID is 1 it takes the square of all even numbers, if ThreadID 
// is 2 it takes the square of all odd numbers
unsigned __stdcall square(double **Args)
{
    // Loop variable
    int i=0;
    
    // Get all needed function variables from the double pointer array
    double *Data, *Result, *ThreadID, *DataSize;
    Data = Args[0];
    Result = Args[1];
    ThreadID = Args[2];
    DataSize = Args[3];
    
    // Square all even numbers in the first thread
    if(ThreadID[0]==1)
    {
        for (i=0; i<(int)DataSize[0]; i=i+2)
        {
            Result[i]=Data[i]*Data[i];
            WaitForSingleObject(percentageMutex, INFINITE);
                percentage+=100/((double)DataSize[0]);
            ReleaseMutex(percentageMutex);
        }
    }
    
    // Square all odd numbers in the second thread
    if(ThreadID[0]==2)
    {
        for (i=1; i<(int)DataSize[0]; i=i+2)
        {
            Result[i]=Data[i]*Data[i];
            WaitForSingleObject(percentageMutex, INFINITE);
                 percentage+=100/((double)DataSize[0]);
            ReleaseMutex(percentageMutex);
        }
    }
    
    // Set the thread finished variables
    if(ThreadID[0]==1) { WaitForThread1 = 0; }
    if(ThreadID[0]==2) { WaitForThread2 = 0; }
    
    // explicit end thread, helps to ensure proper recovery of resources allocated for the thread
    _endthreadex( 0 );
    return 0;
}

// The matlab mex function
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    double *Data;  // The input data (x)
    double *Result; // The output data (x^2)
    mwSize Dcols, Drows; // Dimensions of input data
    double **ThreadArgs1,**ThreadArgs2; // double pointer array to store all needed function variables
    double ThreadID1[1]={1}; // ID of first Thread 
    double ThreadID2[1]={2}; // ID of second Thread
    double DataSize[1]={0}; // Total size of the input data
    HANDLE *ThreadList; // Handles to the worker threads

    // Create the Mutex
    percentageMutex = CreateMutex(NULL, FALSE, NULL);        

    // Reserve room for handles of threads in ThreadList
    ThreadList = (HANDLE*)malloc(2* sizeof( HANDLE ));
    
    // Reserve room for 4 function variables(arrays)
    ThreadArgs1 = (double **)malloc( 4* sizeof( double * ) );  
    ThreadArgs2 = (double **)malloc( 4* sizeof( double * ) );  
    
    // Get the dimensions of the input data
    Dcols = (mwSize) mxGetN(prhs[0]); 
    Drows = (mwSize) mxGetM(prhs[0]);
    // Get total data size
    DataSize[0]=(double)Drows*Dcols;
    
    // Link the array data to the first input array 
    Data = mxGetPr(prhs[0]);
    
    // Initialize and link the output matrix
    plhs[0] = mxCreateDoubleMatrix(Drows,Dcols, mxREAL); 
    Result = mxGetPr(plhs[0]);
    
    // Percentage finished is zero
    percentage=0;
    
    // Let's now create our first separate thread and ask it to start
    // the square() function.
    WaitForThread1 = 1;
    ThreadArgs1[0]=Data;
    ThreadArgs1[1]=Result;
    ThreadArgs1[2]=ThreadID1;
    ThreadArgs1[3]=DataSize;
    ThreadList[0] = (HANDLE)_beginthreadex( NULL, 0, &square, ThreadArgs1 , 0, NULL );

 
    // Let's now create our second separate thread and ask it to start
    // the square() function.
    WaitForThread2 = 1;
    ThreadArgs2[0]=Data;
    ThreadArgs2[1]=Result;
    ThreadArgs2[2]=ThreadID2;
    ThreadArgs2[3]=DataSize;
    ThreadList[1] = (HANDLE)_beginthreadex( NULL, 0, &square, ThreadArgs2 , 0, NULL );
    
    // From here on there are two + one separate threads executing
    // our one program.

    // Print percentage finished while waiting on Threads to finish
    while( WaitForThread1||WaitForThread2)  
    {         
        WaitForSingleObject(percentageMutex, INFINITE);
            mexPrintf("finished: %d % \n",(int) percentage);
            mexEvalString("drawnow");
        ReleaseMutex(percentageMutex);
        Sleep( 1 ); 
    }
    
    // Normally, the next code line is used to wait for threads to finish
    // WaitForMultipleObjects(2, ThreadList, true, INFINITE);
    
    // Explicit destroy the Mutex and Thread objects, helps to ensure proper recovery of resources.
    CloseHandle(percentageMutex);
    CloseHandle( ThreadList[0] );
    CloseHandle( ThreadList[1] );
}



