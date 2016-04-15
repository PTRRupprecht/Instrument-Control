// Copyright Aaron Ponti, 2010/10/04

#include <mex.h>
#include <cstring>

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    // Check that the number of input and output parameters is valid
	if ( nrhs != 1 )
		mexErrMsgTxt("One input parameter expected.");
	if ( nlhs > 1 )
		mexErrMsgTxt("One output parameter expected.");

    // Make sure that the input is a uint8 char array with 4 elements
    if ( !mxIsClass( prhs[ 0 ], "uint8" ) ||
            !( mxGetN( prhs[ 0 ] ) == 4 && mxGetM( prhs[ 0 ] ) == 1 ) )
        mexErrMsgTxt( 
            "The input parameter must be a ( 1 x 4 ) uint8 array!" );
  
    // Get a pointer to the input uint8 array
    unsigned char *fIn = ( unsigned char * ) mxGetData( prhs[ 0 ] );
  
    // Create a single (float) scalar
    const mwSize dims[ ] = { 1, 1 };
    plhs[ 0 ] = mxCreateNumericArray( 2, dims, mxSINGLE_CLASS, mxREAL);
    
    // Get a pointer to the output char array
    float * cOut = ( float * ) mxGetData( plhs[ 0 ] );
    
    // Get the corresponding unsigned char array representation of 
    // the input single (float)
    std::memcpy( cOut, fIn, sizeof( float ) );
}
