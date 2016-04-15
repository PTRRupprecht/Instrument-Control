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

    // Make sure that the input is a uint8 char array with 2 elements
    if ( !mxIsClass( prhs[ 0 ], "uint8" ) ||
            !( mxGetN( prhs[ 0 ] ) == 2 && mxGetM( prhs[ 0 ] ) == 1 ) )
        mexErrMsgTxt( 
            "The input parameter must be a ( 1 x 2 ) uint8 array!" );
  
    // Get a pointer to the input uint8 array
    unsigned char *fIn = ( unsigned char * ) mxGetData( prhs[ 0 ] );
  
    // Create an unsigned int numeric array to hold the 'converted' array
    const mwSize dims[ ] = { 1, sizeof( unsigned char ) };
    plhs[ 0 ] = mxCreateNumericArray( 2, dims, mxUINT16_CLASS, mxREAL);
  
    // Get a pointer to the output char array
    unsigned short * cOut = ( unsigned short * ) mxGetData( plhs[ 0 ] );
    
    // Get the corresponding unsigned char array representation of 
    // the input single (uint16)
    std::memcpy( cOut, fIn, sizeof( unsigned short ) );
}
