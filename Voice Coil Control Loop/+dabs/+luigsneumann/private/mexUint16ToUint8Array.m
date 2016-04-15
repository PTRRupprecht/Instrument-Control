% mexUin16ToUint8Array returns the byte representation of a 'uint16'
%
% SYNOPSIS a = mexUin16ToUint8Array( single( b ) )
%
% EXAMPLE:      a = mexUin16ToUint8Array( uint16( 1025 ) )
%               a = 
%                   1  4
%
% INPUT    b : scalar of class 'uint16'
%
% OUTPUT   a : uint8 array (2 elements) containing the byte representation
%              of the 'uint16' variable b.
%
% Copyright Aaron Ponti, 2010/10/08
