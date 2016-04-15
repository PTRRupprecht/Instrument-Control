function delete(this,varargin)
% @scim_tifStream\delete: Close file and clear object data of @tifstream instance
%% SYNTAX
%   delete(this)
%   delete(this,'leaveFile')
%       this: a @tifstream object
%       'leaveFile': Add this option to leave the @scim_tifStream's file intact
%
%% NOTES
%   This function should generally not be called directly; but rather is called via the close() method which closes a @scim_tifStream and its associated file
%   This function can be called to forcibly remove a @scim_tifStream object which has not been closed.
%% CREDITS
%   Created 8/17/08 by Vijay Iyer
%% **************************************************

global tifstreamGlobal;

leaveFile = false;

%Process input arguments
if ~isempty(varargin)
    if strcmpi(varargin{1},'leavefile')
        leaveFile=true;
    end
end

if ~isempty(tifstreamGlobal) && length(tifstreamGlobal)>=this.ptr
    fid = tifstreamGlobal(this.ptr).fid;
    filename = tifstreamGlobal(this.ptr).filename;
    tifstreamGlobal(this.ptr) = [];
else %Ideally, this should never happen
    fid = [];
    filename = '';
    tifstreamGlobal = []; %
end

%Close file, if it exists and is open
try    
   if ~isempty(fid)       
       fclose(fid);
   end
   
   if ~isempty(filename) && ~leaveFile
       delete(filename);
   end          
catch
   error(['Error in closing or deleting file, so the file may remain: ' lasterr]);    
end

return;

