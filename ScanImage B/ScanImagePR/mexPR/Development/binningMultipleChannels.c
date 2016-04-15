/* averaging images over several pixels                                  */
/*                                                                       */
/*************************************************************************/

#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mwSignedIndex hh, ii, ll, kk;        /*  counters                       */
    mwSize m, n;                 /*  size of matrices               */
    double *x, *y1, *y2; /*  input and output matrices, here only for two outputs */
    int pxls, lines, nbchan, binning;
    /*  matrices needed */
    mxArray *yArray1, *yArray2;

    /*  Now we need to get the data */
    x = (double *)mxGetData(prhs[0]);
    m = (mwSize) mxGetM(prhs[0]);
    n = (mwSize) mxGetN(prhs[0]);

    pxls =  (int )mxGetScalar(prhs[1]);
    lines =  (int )mxGetScalar(prhs[2]);
    nbchan =  (int )mxGetScalar(prhs[3]);
        
    binning = m/pxls/nbchan;

    yArray1 = mxCreateDoubleMatrix(pxls, lines, mxREAL);
    y1 = mxGetPr(yArray1);
    yArray2 = mxCreateDoubleMatrix(pxls, lines, mxREAL);
    y2 = mxGetPr(yArray2);
    plhs[0] = yArray1;
    plhs[1] = yArray2;

    printf("%d %d %d %d \n",pxls,lines,binning, pxls*binning*nbchan);
    
    for (ll=0; ll<nbchan; ll++) {
        if (ll == 1) {
            for(ii=0; ii<lines; ii++) {
                for(hh=0; hh<pxls; hh++) {
                    for (kk=0; kk<binning;kk++) {


                        y1[ii * lines + hh] = y1[ii * lines + hh] + x[ii* pxls*binning*nbchan  + ll + kk*nbchan + binning*nbchan*hh]/binning;
                    }
                }
            }
        }
        else {
            for(ii=0; ii<lines; ii++) {
                for(hh=0; hh<pxls; hh++) {
                    for (kk=0; kk<binning;kk++) {


                        y2[ii * lines + hh] = y2[ii * lines + hh] + x[ii * pxls*binning*nbchan + ll + kk*nbchan + binning*nbchan*hh]/binning;
                    }
                }
            } 
        }
    }
 
    
}