function stringVal = stateVar2String(stateVar,state)
%STATEVAR2STRING Convert a ScanImage state variable to a string
%
%% SYNTAX
%   stringVal = stateVar2String(stateVar)
%   stringVal = stateVar2String(stateVar, stateStruct)
%       stateVar: String containing name of a ScanImage state variable, in full structure format (e.g. 'state.acq.numPixels')
%       state: Structure variable representing the ScanImage state variable, allowing function to be used without obtaining 'state' from global workspace 
%
%% NOTES
%   Created to factor out common code used in CFG and Header saving
%   String value for variable is in a format that can be correctly parsed by initGUIsFromCellArray()
%
%   ArrayString variables (due to be phased out) are not correctly supported in 'user mode', where state is passed in as a structure variable -- Vijay Iyer 6/24/09
%
%% CHANGES
%   VI062409A: Support case where state is passed in as a structure variable, rather than relying on global workspace -- Vijay Iyer 6/24/09
%   VI071009A: Need isempty() now with strfind() call to handle logical AND with userMode test from VI062409A -- Vijay Iyer 7/1/09
%   VI093010A: Support vector string cell arrays, encoding them as pipe-delimited strings -- Vijay Iyer 9/30/10
%   VI100110A: Also support empty cell arrays (i.e. empty vector string cell arrays) -- Vijay Iyer 10/1/10
%   VI100410A: Allow vectorial string cell arrays to contain quote characters -- Vijay Iyer 10/4/10
%   
%% CREDITS
%   Created 3/15/09, by Vijay Iyer
%% ******************************************

%%%VI062409A%%%%%
if nargin < 2
    global state %#ok<REDEF>
    userMode = false;
else
    userMode = true;
end
%%%%%%%%%%%%%%%%%

val=[];

if ~userMode && ~isempty(strfind(stateVar,'ArrayString'))%VI070109A %%%ArrayString values are due to be phased out...can now store arrays directly
    eval(['val= mat2str(' stateVar(1:end-6) ');']);
else
    eval(['val=' stateVar ';']);
end
%%%%%%%%%%%%%%%%%%%%%%%%

if iscellstr(val) && isvector(val) %vector string cell array %VI093010A
    val = strrep(val,'''',''''''); %VI100410A
    if size(val,1) > 1 %Column vector
        stringVal = ['''{' sprintf('%s|; ',val{:}) '}''']; %VI093010A
    else %row vector
        stringVal = ['''{' sprintf('%s| ',val{:}) '}''']; %VI093010A
    end
elseif iscell(val) && isempty(val) %VI100110A
    stringVal = '{}';
elseif iscell(val)  %don't handle other cell arrays, besides empty or string cell arrays
    stringVal = [];
elseif islogical(val)
    if val
        stringVal = '1';
    else
        stringVal = '0';
    end
elseif isnumeric(val)
    if ndims(val) > 2
        stringVal = ['''' ndArray2Str(val) '''']; %Use custom ndArray2Str() to deal with ND arrays; store as 'string string' to be loaded correctly by initGUIsFromCellArray()
    elseif isscalar(val) || isempty(val)
        stringVal = mat2str(val);
    else
        stringVal = ['''' mat2str(val) '''']; %Store 2D arrays as a 'string string' to be loaded correctly by initGUIsFromCellArray()
    end
else %should be a string...convert to a 'string string'
    
    % if the string has quotes inside it, we need to format the string a bit differently...
    if strfind(val,'''')
       val =  ['$' strrep(val,'''','''''')];
    end
    stringVal = ['''' val ''''];
end
