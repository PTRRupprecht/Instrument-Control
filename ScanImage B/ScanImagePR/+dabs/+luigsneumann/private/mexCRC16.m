% mexCRC16 calculates the CRC-CCITT (0x0000) of an array of uint8.
%
% SYNOPSIS [ msb, lsb, crc ] = mexCRC16( uint8ArrayIn, useHex )
%
%    e.g. [ msb, lsb, crc ] = mexCRC16( uint8( [ 40 04 ]), 0  );
%
% INPUT uint8Array: array of bytes to be used for calculating the CRC
%       useHex    : either 0 or 1. If 1, the elements will be considered to
%                   be in hexadecimal format. If useHex is 1, then two
%                   consecutive entries will be considered one hex value.
%                   The two following are equivalent:
%                         ... = mexCRC16( uint8( [ 40 04 ], 0 )
%                         ... = mexCRC16( uint8( [ 2 8 0 4 ]), 1 )
%                   since 40 decimal is 28 hexadecimal and
%                          4 decimal is  4 hexadecimal.
%
% OUTPUT msb      : most-significant byte of the CRC
%        lsb      : least-significant byte of the CRC
%        crc      : crc (16 bits)
%
% Copyright Aaron Ponti, 2010/10/04
%
% Uses lib_crc by Lammert Bies, info@lammertbies.nl
