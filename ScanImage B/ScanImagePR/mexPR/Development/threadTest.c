#include "mex.h"
#include "stdio.h"
#include "math.h"
#include <windows.h>
#include <process.h>    
#include <tmwtypes.h>


typedef struct {
   uint16_T *data1;
   uint16_T *data2;
}t;

void myFunc(void *param) {
   t *args = (t*) param;
   uint16_T *x = args->data1;
   uint16_T  *y = args->data2;
   printf("x=%d, y=%d\n", x, y);
   free(args);
   _endthreadex( 0 );
};

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] ) {
   HANDLE handle;
   t *arg;
   arg = (t *)malloc(sizeof(t));
   arg->data1 = (uint16_T *)mxGetData(prhs[0]);
   arg->data2 = (uint16_T *)mxGetData(prhs[1]);
   handle = (HANDLE) _beginthreadex(  NULL, 0, &myFunc, (void*) arg,0, NULL);
   printf("asfasd");
}

