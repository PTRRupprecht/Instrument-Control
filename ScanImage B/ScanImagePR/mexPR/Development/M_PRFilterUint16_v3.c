/*************************************************************
*
*    Multithreaded Binning of MultichannelData
*
*    Author: Peter Rupprecht 
*    Date: 13/14-08-2014
*
*******************************************************************/
 
#include "mex.h"
#include "math.h"
#include <windows.h>
#include <process.h> 
#include <tmwtypes.h>


typedef struct{
    int ini;
    int fin;
    int  nb_lines;
    int  nb_pxls;
    int  nb_channels;
    int  binning;
    uint16_T * ima;
    uint16_T * y1;
}myargument;

unsigned __stdcall ThreadFunc( void* pArguments )
{
    int ini,fin;
    int y1ind1, y1ind2, imaind;
    uint16_T *ima,*y1; //y2 braucht es nicht, oder?
    int nb_lines,nb_pxls,nb_channels,binning;
    myargument arg;
    arg=*(myargument *) pArguments;


		
    ini=arg.ini;    
    fin=arg.fin;
    ima=arg.ima;
    y1=arg.y1;
    nb_lines=arg.nb_lines;
    nb_pxls=arg.nb_pxls;
    nb_channels=arg.nb_channels;
    binning=arg.binning;
    
    // So kann man die 3 for loops etwas vereinfachen und die wiederholte berechnung der indices vermeiden       
    for(y1ind1=ini; y1ind1<fin; y1ind1++) {
		y1ind2=y1ind1+nb_lines;
        for (imaind=y1ind1*nb_pxls*binning*nb_channels; imaind<(y1ind1*nb_pxls*binning*nb_channels+binning*nb_channels);imaind =imaind+nb_channels) {
            y1[y1ind1*nb_pxls] += ima[imaind];
            y1[y1ind2*nb_pxls] += ima[imaind + 1];
        }
    }
    _endthreadex( 0 );
    return 0;
} 

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray*prhs[] )     
{    
    int i,Nthreads,ini,fin;
    uint16_T *ima,*y1;
    int nb_lines,nb_pxls;
    int nb_channels,binning;
    mxArray *yArray1;
    
    myargument *ThreadArgs;  
    HANDLE *ThreadList; // Handles to the worker threads           
    
    if(nrhs<5)
    {
        printf("Error: Wrong number of arguments! Must be 5\r");
        return;
    }
   
    /*Get image*/
    ima = (uint16_T * )mxGetData(prhs[0]);    
    
    /*Get the Integer*/
    nb_lines =  (int ) mxGetScalar(prhs[1]);
    nb_pxls = (int ) mxGetScalar(prhs[2]);
    nb_channels = (int)  mxGetScalar(prhs[3]);
    binning =  (int) mxGetScalar(prhs[4]);
    /* get number of threads*/
    Nthreads = (int) mxGetScalar(prhs[5]);


    /*Allocate memory and assign output pointer*/
    yArray1 = mxCreateNumericMatrix(nb_pxls, 2*nb_lines, mxUINT16_CLASS,mxREAL);
    y1 = mxGetData(yArray1);
    plhs[0] = yArray1;

    // Reserve room for handles of threads in ThreadList
	ThreadList = (HANDLE*)malloc(Nthreads* sizeof( HANDLE ));
	ThreadArgs = (myargument*) malloc( Nthreads*sizeof(myargument));

    for (i=0; i<Nthreads; i++)
    {       
	// Make Thread Structure
        ini=(i*nb_lines)/Nthreads;
        fin=((i+1)*nb_lines)/Nthreads;

        ThreadArgs[i].nb_lines=nb_lines;
        ThreadArgs[i].nb_pxls=nb_pxls;
        ThreadArgs[i].ima=ima;
        ThreadArgs[i].y1=y1;
        ThreadArgs[i].nb_channels=nb_channels;
        ThreadArgs[i].binning=binning;    
        ThreadArgs[i].ini=ini;
        ThreadArgs[i].fin=fin;
        
        ThreadList[i] = (HANDLE)_beginthreadex( NULL, 0, &ThreadFunc, &ThreadArgs[i] , 0, NULL );
  }
    
  for (i=0; i<Nthreads; i++) { WaitForSingleObject(ThreadList[i], INFINITE); }
  for (i=0; i<Nthreads; i++) { CloseHandle( ThreadList[i] ); }
    
  free(ThreadArgs); 
  free(ThreadList);
        
  return;
}
