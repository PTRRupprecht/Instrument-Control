#include "mex.h"
 void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
 {
    double imagehandle;
    imagehandle = mxGetScalar(prhs[1]);
    mexSet(imagehandle,"Cdata",prhs[0]);
 }