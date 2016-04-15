% mexSingleToUint8Array returns the byte representation of a 'single'
%
% SYNOPSIS a = mexSingleToUint8Array( single( b ) )
%
% EXAMPLE:      a = mexSingleToUint8Array( single( 4.37 ) )
%               a = 
%                   10  215  139   64
%
% INPUT    b : scalar of class 'single'
%
% OUTPUT   a : uint8 array (4 elements) containing the byte representation
%              of the 'single' variable b.
%
% Copyright Aaron Ponti, 2010/10/04
