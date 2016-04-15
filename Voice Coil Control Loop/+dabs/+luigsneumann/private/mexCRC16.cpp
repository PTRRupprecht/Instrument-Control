#include "lib_crc.h"
#include "mex.h"
#include "cstring"


/* Call this function as follows:
 *
 * [ lsb, msb, crc ] = mexCRC16( uint8ArrayIn, useHex )
 *
 *    e.g. [ lsb, msb, crc ] = mexCRC16( uint8( [ 40 04 ], 0 ) );
 *
 * Type help mexCRC16 in MATLAB for additional information.
 *
 * Copyright Aaron Ponti, 2010/10/04
 *
 * Uses lib_crc by Lammert Bies, info@lammertbies.nl
 *
 */

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    int USE_HEX = 0;
    
    // Check that the number of input and output parameters is valid
	if ( nrhs != 2 )
		mexErrMsgTxt("Two input parameters expected.");
	if ( nlhs > 3 )
		mexErrMsgTxt("Maximum three output parameters expected.");

    // Make sure that the input is an array of unsigned integers
    if ( !mxIsClass( prhs[ 0 ], "uint8" ) )
        mexErrMsgTxt( 
            "The first input parameter must be of class uint8!" );
  
    // Check the dimensions of the input parameter: it must be ( 1 x m )
    if ( mxGetM( prhs[ 0 ] ) > 1 )
        mexErrMsgTxt( 
            "The first input parameter must be of size ( 1 x m )!" );
    
    // Get the second parameter (scalar)
    double h = mxGetScalar( prhs[ 1 ] );
    if ( ( h != 0 ) && ( h != 1 ) )
        mexErrMsgTxt( 
            "The second input parameter must be either 0 or 1!" );
    bool useHex = ( h == 1 );

    // We keep the number of columns
    int N = mxGetN( prhs[ 0 ] );

    // Check that the number of entries is compatible with the hex mode
    if ( ( useHex == 1 ) && ( N % 2 ) == 1 )
        mexErrMsgTxt( 
            "If useHex is 1, then the number of entries in the first "
            "input parameter must be even!" );
        
    // Get a pointer to the input uint8 array
    unsigned char *cIn = ( unsigned char * ) mxGetData( prhs[ 0 ] );

    // Create two unsigned int scalars to hold the LSB and MSB of the CRC
    const mwSize dims[ ] = { 1, 1 };
    plhs[ 0 ] = mxCreateNumericArray( 2, dims, mxUINT8_CLASS, mxREAL);
    plhs[ 1 ] = mxCreateNumericArray( 2, dims, mxUINT8_CLASS, mxREAL);
    plhs[ 2 ] = mxCreateNumericArray( 2, dims, mxUINT16_CLASS, mxREAL);
    
    // Get pointers to the outputs
    unsigned char  *msb = ( unsigned char *)  mxGetData( plhs[ 0 ] );
    unsigned char  *lsb = ( unsigned char *)  mxGetData( plhs[ 1 ] );
    unsigned short *crc = ( unsigned short *) mxGetData( plhs[ 2 ] );
    
    unsigned short crc_ccitt_0000 = 0;
    if ( useHex == 0 )
    {
        // Calculate CRC-CCITT (0x0000)
        for ( mwSize i = 0; i < N; i++ )
            crc_ccitt_0000 = update_crc_ccitt(  crc_ccitt_0000, *( cIn + i ) );
    }
    else
    {
        char hex_val;
        for ( int i = 0; i < N; i+=2 )
        {
            hex_val  = ( char ) ( ( *( cIn + i )     &  '\x0f' ) << 4 );
            hex_val |= ( char ) ( ( *( cIn + i + 1 ) &  '\x0f' )      );
            crc_ccitt_0000 = update_crc_ccitt(  crc_ccitt_0000, hex_val );
        }
    }

    // Break down the CRC into LSB and MSB
    *lsb = ( unsigned char ) crc_ccitt_0000;
    *msb = ( unsigned char )( crc_ccitt_0000 >> 8 );
    
    // Return also the crc
    *crc = crc_ccitt_0000;
}


