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

    // Make sure that the input is a float (single) scalar
    if ( !mxIsClass( prhs[ 0 ], "uint16" ) ||
            mxGetN( prhs[ 0 ] ) * mxGetM( prhs[ 0 ] ) != 1 )
        mexErrMsgTxt( 
            "The input parameter must be a scalar of class uint16!" );
  
    // Get a pointer to the input float (uint16) scalar
    unsigned short *fIn = ( unsigned short *) mxGetData( prhs[ 0 ] );
  
    // Create an unsigned int numeric array to hold the 'converted' uint16
    const mwSize dims[ ] = { 1, sizeof( unsigned short ) };
    plhs[ 0 ] = mxCreateNumericArray( 2, dims, mxUINT8_CLASS, mxREAL);
    
    // Get a pointer to the output char array
    unsigned char * cOut = ( unsigned char * ) mxGetData( plhs[ 0 ] );
    
    // Get the corresponding unsigned char array representation of 
    // the input single (uint16)
    std::memcpy( cOut, fIn, sizeof( unsigned short ) );
}
