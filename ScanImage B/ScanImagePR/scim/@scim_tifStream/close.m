function close(this)
% @scim_tifStream\close: Complete and close the file associated with this @tifstream
%
%% CREDITS
%   Created 8/17/08 by Vijay Iyer
%% **************************************************

global tifstreamGlobal;

fid = tifstreamGlobal(this.ptr).fid;
lengthSuppIFD = length(tifstreamGlobal(this.ptr).suppIFDByteData);

%Adjust the last offset to 'next' IFD to 0000
fseek(fid,-(lengthSuppIFD+4),'eof');
fwrite(fid,0,'uint32');
fclose(fid);

tifstreamGlobal(this.ptr).fid = [];

delete(this,'leaveFile'); %This removes the @tifstream object

return;

