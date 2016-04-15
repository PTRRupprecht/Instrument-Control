#include "mex.h"
#include <windows.h>
#include <stdio.h>
#include <process.h>
#include <string.h>
 
unsigned Counter = 0;
unsigned Counter_1 = 0;
double *cmd;
    
unsigned __stdcall SecondThreadFunc( void* pArguments )
{
     Sleep(4);
     
    _endthreadex(0);
    return 0;
}
 
unsigned __stdcall ThirdThreadFunc( void* pArguments )
{
    if( strcmp( (char*)pArguments,"Init" ) )
        Counter_1 = 12;
    else
    {
        while ( Counter_1 < 1000000 )
        Counter_1++;
    }
 
    _endthreadex(0);
    return 0;
}
 
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
    HANDLE hThreads[2];
    unsigned threadID[2];
    char *cmd1;
    //On vérifie que l'argument soit une chaîne de caractères
    if( nrhs != 2 )
        mexErrMsgTxt( "Two input required" );
 
    //On récupère la chaîne de caractères
    cmd = mxGetPr( prhs[0] );
    cmd1 = mxArrayToString( prhs[1] );
 
    printf( "Creating second thread...\n" );
 
    //Create the second thread.
    //Create the third thread.
    hThreads[0] = (HANDLE)_beginthreadex( NULL, 0, &SecondThreadFunc, NULL, 0, &threadID[0] );
    hThreads[1] = (HANDLE)_beginthreadex( NULL, 0, &ThirdThreadFunc, cmd1, 0, &threadID[1] );
 
    WaitForMultipleObjects(2,hThreads,TRUE,INFINITE);
    printf( "Counters should be 1000000; first is -> %d\n", Counter );
    printf( "Counters should be 1000000; first is -> %d\n", Counter_1 );
 
    CloseHandle( hThreads[0] );
    CloseHandle( hThreads[1] );
 
    mxFree(cmd);
    mxFree(cmd1);
}