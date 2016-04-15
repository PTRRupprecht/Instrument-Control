%  @scim_tifStream\get: Get properties of this tifstream object
%% SYNTAX
%   value = get(this,property1, ...)
%       this: a @scim_tifStream object
%       property1,2,...: Property names of the tifstream object 
%       value: The value for the specified property, or a cell array of values for the specified properties
%   
%% NOTES
%
%% CHANGES
%   VI042809A: Handle correctly the case where no property is specified
%   
%% CREDITS
%   Created 8/21/08 by Vijay Iyer
%% ************************************************************

function value = get(this, varargin)
global tifstreamGlobal;

names = fieldnames(tifstreamGlobal(this.ptr));

if isempty(varargin)
    for i = 1 : length(names)
        value.(names{i}) = tifstreamGlobal(this.ptr).(names{i});
    end
elseif ~iscellstr(varargin)
    error('Arguments must all be strings, specifying %s property names',mfilename('class'));
else
    for i=1:length(varargin)
        [found, idx] = ismember(lower(varargin{i}), lower(names));
        if ~found
            error('Invalid property name: ''%s''', varargin{i});
        else          
            value{i} = tifstreamGlobal(this.ptr).(names{idx});
        end
    end
end

%Don't return cell array if only one property requested
if iscell(value) && length(value)==1 %VI042809A
    value = value{1};
end

return;