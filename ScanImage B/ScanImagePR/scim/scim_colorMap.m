function map = scim_colorMap(color, numBits, satLevel)
%% function map = scim_colorMap(color, numBits, satLevel)
% Default function used by ScanImage to generate colormap used by Image display figures
%   
%% SYNTAX
%   color: <OPTIONAL - Default='gray'> One of {'gray' 'grayHighSat' 'grayLowSat' 'grayBothSat' 'red' 'green' 'blue'}
%           gray: Identical to Matlab gray() function
%           grayHighSat: Gray colormap with pixels near high saturation (determined by numBits/satLevel) colored red
%           grayLowSat: Gray colormap with pixels near low saturation (determined by numBits/satLevel) colored red
%           grayBothSat: Combination of grayHighSat/grayLowSat
%           red: Simple linear map from black to maximal red intensity (length/steps determined by numBits)
%           green: Simple linear map from black to maximal green intensity (length/steps determined by numBits)
%           blue: Simple linear map from black to maximal blue intensity (length/steps determined by numBits)
%            
%   numBits: <OPTIONAL - Default=8> Specifies length (2^numBits) of map and step-size of color increments (1/(2^(numBits-1)).
%   satLevel: <OPTIONAL - Default=5> Applies to 'grayHighSat'/'grayLowSat'/'grayBothSat' cases. Specifies, as percentage of the entire range (0-2^(numBits-1)), range of high and/or low levels to consider saturated.
%
%   map: An Nx3 matrix, where N=2^numBits, specifying a valid Matlab colormap (see 'help colormap' for more details)

%% NOTES
%   Type 'help colormap' or 'doc colormap' at Matlab command line for background
%   
%   To change the default colormap used by ScanImage,in the Channels... dialog, users can:
%       1) Change the arguments (color, bits) to scim_colorMap()
%       2) Change the function to a Matlab built-in colormap function, e.g. to 'jet(256)' (see 'help colormap' for list of options)
%       3) Change the function to a user-supplied colormap function, which should output a single argument 'map' containing an Nx3 matrix (see 'help colormap' for information on color map matrices)
%
%   If users create their own colormap function, they must ensure it is located on the Matlab path
%
%% CREDITS
%   Created 11/22/10, by Vijay Iyer
%   Based heavily on previous makeColorMap() function (unknown author)
%% ******************************************************************************

if nargin < 1 || isempty(color)
    color='gray';
    numBits=8;
    satLevel = 5;
end

if nargin < 2 || isempty(numBits)
    numBits=8;
    satLevel = 5;
end

if nargin < 3 || isempty(satLevel)
    satLevel = 5;
end
    
a = zeros(2^numBits,1);
b = (0:1/(2^numBits -1):1)';
fraction = .01 * satLevel;
index=round(fraction*length(b));

switch color
    case 'red'
        map = squeeze(cat(3, b, a, a));
    case 'green'
        map = squeeze(cat(3, a, b, a));
    case 'blue'
        map = squeeze(cat(3, a, a, b));
    case 'gray'
        map = squeeze(cat(3, b, b, b));
    case 'grayHighSat'
        map = squeeze(cat(3, b, b, b));
        map(end-index:end,[2 3])=0;
    case 'grayLowSat'
        map = squeeze(cat(3, b, b, b));
        map(1:index,[1 3])=0;
        map(1:index,2)=flipud(linspace(.8,1,length(map(1:index,2)))');
    case 'grayBothSat'
        map = squeeze(cat(3, b, b, b));
        map(end-index:end,[2 3])=0;
        map(1:index,[1 3])=0;
        map(1:index,2)=flipud(linspace(.8,1,length(map(1:index,2)))');
    case 'jet'
        map = jet;
end

	