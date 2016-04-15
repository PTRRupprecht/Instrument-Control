/*************************************************************
*
*    Multithreaded Bilateral Filter
*
*    Author: Jose Vicente Manjon Herrera 
*    Date: 09-03-2009
*
*******************************************************************/
 
#include "mex.h"
#include "math.h"
#include <windows.h>
#include <process.h>   

typedef struct{
    int rows;
    int cols;
    double * in_image;
    double * out_image;
    double * weight;
    int ini;
    int fin;
    int radio;
    int sigmaI;
    int sigmaS;
}myargument;

unsigned __stdcall ThreadFunc( void* pArguments )
{
    double *ima,*fima,*weight,val,sigS,sigI,w,nv,d;
    int ii,jj,ni,nj,i,j,ini,fin,rows,cols,v;

    myargument arg;
    arg=*(myargument *) pArguments;

    rows=arg.rows;    
    cols=arg.cols;
    ini=arg.ini;    
    fin=arg.fin;
    ima=arg.in_image;
    fima=arg.out_image;
    weight=arg.weight;
    v=arg.radio;
    sigI=arg.sigmaI;
    sigS=arg.sigmaS;
           
    // bilateral filter 
    
    
    
//     for(i=ini;i<fin;i++) 
//     for(j=0;j<cols;j++) 
//     {
//         for(ii=0;ii<v;ii++) 
//         for(jj=-v;jj<v;jj++)
//         {
//             ni=i+ii;
//             nj=j+jj;
//             if(ii==0 && jj==0) continue;
//             if(ni>=0 && nj>=0 && ni<cols && nj<rows)
//             {                
//                 d=(ima[nj*cols+ni]-ima[j*cols+i]);
// 				d=d*d;
//                 w=exp(-(ii*ii+jj*jj)/(2*sigS*sigS)+(-d/(2*sigI*sigI)));
//                 
//                 // symmetric weight computation
//                 
//                 fima[j*cols+i]  += w*ima[nj*cols+ni];
//                 weight[j*cols+i]+= w;
//                 
//                 fima[nj*cols+ni]  += w*ima[j*cols+i];
//                 weight[nj*cols+ni]+= w;
//             }
//         }
//     }

    _endthreadex( 0 );
    return 0;
} 

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray*prhs[] )     
{    
    int v,i,Nthreads,np,ini,fin,count,ndim,rows,cols;
    double *ima,*fima,*weight,sigI,sigS;
    const int  *dims ;
    
    myargument *ThreadArgs;  
    HANDLE *ThreadList; // Handles to the worker threads           
    
    if(nrhs<4)
    {
        printf("Error: Wrong number of arguments!! must be 4\r");
        return;
    } 
   
    /*Get image*/
    ima = mxGetPr(prhs[0]);    
    rows=mxGetM(prhs[0]);
    cols=mxGetN(prhs[0]);

    ndim = mxGetNumberOfDimensions(prhs[0]);
    dims= mxGetDimensions(prhs[0]);

    /*Get the Integer*/
    v = (int)(mxGetScalar(prhs[1]));
    sigS = mxGetScalar(prhs[2]);  
    sigI = mxGetScalar(prhs[3]);  
    
    /* get number of threads*/
    Nthreads = (int) mxGetScalar(prhs[4]);  

    /*Allocate memory and assign output pointer*/

    plhs[0] = mxCreateNumericArray(ndim,dims,mxDOUBLE_CLASS, mxREAL);
    fima = mxGetPr(plhs[0]);      
    weight = mxGetPr( mxCreateNumericArray(ndim,dims,mxDOUBLE_CLASS, mxREAL));
    
    for(i=0;i<dims[0]*dims[1];i++)
    {
        fima[i]=ima[i];
        weight[i]=1;
    }
    
    // Reserve room for handles of threads in ThreadList
	ThreadList = (HANDLE*)malloc(Nthreads* sizeof( HANDLE ));
	ThreadArgs = (myargument*) malloc( Nthreads*sizeof(myargument));
	
    for (i=0; i<Nthreads; i++)
    {       
	// Make Thread Structure
    ini=(i*rows)/Nthreads;
    fin=((i+1)*rows)/Nthreads;
    
    ThreadArgs[i].rows=rows;
	ThreadArgs[i].cols=cols;
    ThreadArgs[i].in_image=ima;
	ThreadArgs[i].out_image=fima;
    ThreadArgs[i].weight=weight;
    ThreadArgs[i].ini=ini;
    ThreadArgs[i].fin=fin;
    ThreadArgs[i].radio=v;    
    ThreadArgs[i].sigmaI=sigI;    
    ThreadArgs[i].sigmaS=sigS;    
	
    ThreadList[i] = (HANDLE)_beginthreadex( NULL, 0, &ThreadFunc, &ThreadArgs[i] , 0, NULL );
  }
    
  for (i=0; i<Nthreads; i++) { WaitForSingleObject(ThreadList[i], INFINITE); }
  for (i=0; i<Nthreads; i++) { CloseHandle( ThreadList[i] ); }
    
  free(ThreadArgs); 
  free(ThreadList);

  for(i=0;i<dims[0]*dims[1];i++) fima[i]/=weight[i];
        
  return;
}
