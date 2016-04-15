/* nothing but setting the data in images to new values                  */
/*                                                                       */
/*************************************************************************/

#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

      (void) plhs;

      mexPrintf("%s \n",(float*)mxGetData(prhs[2]));
      mexPrintf("%p \n",prhs[2]);

    
}
