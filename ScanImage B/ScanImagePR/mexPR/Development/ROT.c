/* averaging images over several pixels                                  */
/*                                                                       */
/*************************************************************************/

#include "mex.h"
#include <tmwtypes.h>
#include "stdio.h"
#include "math.h"
#include <windows.h>
#include <process.h>

static volatile int WaitForThread1;
static volatile int WaitForThread2;
static volatile uint16_T percentage;
static HANDLE percentageMutex;

typedef struct {
   uint16_T *x;
   uint16_T *y1;
   uint16_T *y2;
   uint16_T *ThreadID;
   uint16_T pxls;
   uint16_T lines;
   uint16_T nbchan;
   double binning;
}passing;


unsigned __stdcall linebin(uint16_T **Args)
{
    // Loop variable
    uint16_T hh, ii, ll;
    double kk;
    
    // Get all needed function variables from the double pointer array
    uint16_T *x, *y1, *y2, *ThreadID;
    uint16_T pxls, lines, nbchan;
    double binning;
    
    x = Args[0];
    y1 = Args[1];
    pxls = *Args[2];
    lines = *Args[3];
    nbchan = *Args[4];
    binning = (double )Args[5];
    y2 = Args[6];
    ThreadID = Args[7];
    
    // execute whatever is interesting
    if(ThreadID[0]==1)
    {
        for(ii=0; ii<lines; ii=ii+2) {
            for(hh=0; hh<pxls; hh++) {
                for (kk=0; kk<binning;kk++) {
                    y1[ii * lines + hh] = y1[ii * lines + hh] + x[ii* pxls*binning*nbchan  + 0 + kk*nbchan + binning*nbchan*hh]/binning;
                    y2[ii * lines + hh] = y2[ii * lines + hh] + x[ii * pxls*binning*nbchan + 1 + kk*nbchan + binning*nbchan*hh]/binning;
                }
            }
        }
    }
    
    // Square all odd numbers in the second thread
    if(ThreadID[0]==2)
    {
        for(ii=1; ii<lines; ii=ii+2) {
            for(hh=0; hh<pxls; hh++) {
                for (kk=0; kk<binning;kk++) {
                    y1[ii * lines + hh] = y1[ii * lines + hh] + x[ii* pxls*binning*nbchan*2  + 0 + kk*nbchan + binning*nbchan*hh]/binning;
                    y2[ii * lines + hh] = y2[ii * lines + hh] + x[ii * pxls*binning*nbchan*2 + 1 + kk*nbchan + binning*nbchan*hh]/binning;
                }
            }
        }
    }
    
    // Set the thread finished variables
    if(ThreadID[0]==1) { WaitForThread1 = 0; }
    if(ThreadID[0]==2) { WaitForThread2 = 0; }
    
    // explicit end thread, helps to ensure proper recovery of resources allocated for the thread
    _endthreadex( 0 );
    return 0;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    passing *ThreadArgs1;
    ThreadArgs1 = (passing *)malloc(sizeof(passing));
    passing *ThreadArgs2;
    ThreadArgs2 = (passing *)malloc(sizeof(passing));
    uint16_T ThreadID1[1]={1}; // ID of first Thread 
    uint16_T ThreadID2[1]={2}; // ID of second Thread
    HANDLE *ThreadList; // Handles to the worker threads
    mwSize m, n;
    mxArray *yArray1, *yArray2;
    m = (mwSize) mxGetM(prhs[0]);
    n = (mwSize) mxGetN(prhs[0])
    
    /*  Now we need to get the data */
    ThreadArgs1.x = mxGetData(prhs[0]);
    ThreadArgs2.x = mxGetData(prhs[0]);
    m = (mwSize) mxGetM(prhs[0]);
    n = (mwSize) mxGetN(prhs[0]);
    ThreadArgs1.pxls =  (uint16_T )mxGetScalar(prhs[1]);
    ThreadArgs1.lines =  (uint16_T )mxGetScalar(prhs[2]);
    ThreadArgs1.nbchan =  (uint16_T )mxGetScalar(prhs[3]);
    ThreadArgs1.binning = 16; // m/pxls/nbchan;
    ThreadArgs2.pxls =  (uint16_T )mxGetScalar(prhs[1]);
    ThreadArgs2.lines =  (uint16_T )mxGetScalar(prhs[2]);
    ThreadArgs2.nbchan =  (uint16_T )mxGetScalar(prhs[3]);
    ThreadArgs2.binning = 16; // m/pxls/nbchan;
    
    yArray2 = mxCreateNumericMatrix(pxls, lines, mxUINT16_CLASS,mxREAL);
    yArray1 = mxCreateNumericMatrix(pxls, lines, mxUINT16_CLASS,mxREAL);
    
    ThreadArgs1.y1 = mxGetData(yArray1);
    ThreadArgs2.y1 = mxGetData(yArray1);
    ThreadArgs1.y2 = mxGetData(yArray2);
    ThreadArgs2.y2 = mxGetData(yArray2);
    

    ThreadArgs1.x = mxGetData(prhs[0]);
    ThreadArgs2.x = mxGetData(prhs[0]);
    m = (mwSize) mxGetM(prhs[0]);
    n = (mwSize) mxGetN(prhs[0]);

    
    uint16_T *x;
    uint16_T *y1, *y2;
    uint16_T *pxls, *lines, *nbchan, *binning;
    mxArray *yArray1, *yArray2;

    // now the imported parts
    uint16_T **ThreadArgs1,**ThreadArgs2; // double pointer array to store all needed function variables
    
    /*  Now we need to get the data */
    x = mxGetData(prhs[0]);
    m = (mwSize) mxGetM(prhs[0]);
    n = (mwSize) mxGetN(prhs[0]);
    pxls =  (uint16_T )mxGetScalar(prhs[1]);
    lines =  (uint16_T )mxGetScalar(prhs[2]);
    nbchan =  (uint16_T )mxGetScalar(prhs[3]);
    binning = 16; // m/pxls/nbchan;

    yArray1 = mxCreateNumericMatrix(pxls, lines, mxUINT16_CLASS,mxREAL);
    y1 = mxGetData(yArray1);
    yArray2 = mxCreateNumericMatrix(pxls, lines, mxUINT16_CLASS,mxREAL);
    y2 = mxGetData(yArray2);
    plhs[0] = yArray1;
    plhs[1] = yArray2;
    
    // Create the Mutex
    percentageMutex = CreateMutex(NULL, FALSE, NULL);        

    // Reserve room for handles of threads in ThreadList
    ThreadList = (HANDLE*)malloc(2* sizeof( HANDLE ));
    
    // Reserve room for 4 function variables(arrays)
    ThreadArgs1 = (uint16_T **)malloc( 8* sizeof( uint16_T * ) );  
    ThreadArgs2 = (uint16_T **)malloc( 8* sizeof( uint16_T * ) );  
    
    // Percentage finished is zero
    percentage=0;
    
    // Let's now create our first separate thread and ask it to start
    // the square() function.
    WaitForThread1 = 1;
    ThreadArgs1[0]=x;
    ThreadArgs1[1]=y1;
    ThreadArgs1[2]=pxls;
    ThreadArgs1[3]=lines;
    ThreadArgs1[4]=nbchan;
    ThreadArgs1[5]=binning;
    ThreadArgs1[6]=y2;
    ThreadArgs1[7]=ThreadID1;
    ThreadList[0] = (HANDLE)_beginthreadex( NULL, 0, &linebin, ThreadArgs1 , 0, NULL );

 
    // Let's now create our second separate thread and ask it to start
    // the square() function.
    WaitForThread2 = 1;
    ThreadArgs2[0]=x;
    ThreadArgs2[1]=y1;
    ThreadArgs2[2]=pxls;
    ThreadArgs2[3]=lines;
    ThreadArgs2[4]=nbchan;
    ThreadArgs2[5]=binning;
    ThreadArgs2[6]=y2;
    ThreadArgs2[7]=ThreadID2;
    ThreadList[1] = (HANDLE)_beginthreadex( NULL, 0, &linebin, ThreadArgs2 , 0, NULL );
    
    // From here on there are two + one separate threads executing
    // our one program.

    // Print percentage finished while waiting on Threads to finish
    while( WaitForThread1||WaitForThread2)  
    {         
        WaitForSingleObject(percentageMutex, INFINITE);
//             mexPrintf("finished: %d % \n",(int) percentage);
//             mexEvalString("drawnow");
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