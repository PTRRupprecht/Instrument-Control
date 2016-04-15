function byteArray = makeByteArray(val,numBytes)
%@tifstream\private\makeByteArray: Make an array of bytes of specified length from the specified value
%% SYNTAX
%   byteArray = makeByteArray(val,numBytes)
%       val: Value, or array of values, to be written out
%       numBytes: Number of bytes to write per value; zeros will be appended if needed
%       byteArray: Array of bytes (i.e. 'uint8' type) representing value, with zeros appended as required
%
%% *************************************************

% if ~ismember(lower(dataType), {'uint8' 'uint16' 'uint32'})
%     error('Only 8/16/32-bit unsigned integer data types are presently supported');
% end
% 
% if any(val > intmax(dataType))
%     error('Value too great for specified data type');
% end

byteArray = uint8([]);
for i=1:length(val)
    %Limits checking
    if val(i) > 2^(numBytes*8)-1
        error(['Value (' val(i) ') exceeds that allowed for specified number of bytes']);
    end
    %val(i) = uint32(i);
    val(i) = double(val(i));
    
    %Expand each value into array of bytes
    %hexVal = dec2hex(uint32(val(i)));
    %binVal = dec2bin(val(i),32);    

%     if mod(length(hexVal),2) %Ensure even # of hex digits --> integer # of bytes
%         hexVal = ['0' hexVal];
%     end
    byteVals = uint8(zeros(1,numBytes));
    byteCount = 0;
    for j=numBytes:-1:1
        byteVals(j) = uint8(floor(val(i)/(2^(8*(j-1)))));
        val(i) = val(i) - double(byteVals(j))*2^(8*(j-1));
        if byteVals(j) ~= 0
            byteCount = max(byteCount,j);
        end
    end
    
    byteArray = [byteArray byteVals]; %append to array

%     byteCount = length(hexVal)/2;
%     newElements = uint8([]);
%     for i=1:byteCount
%         newElements = [newElements uint8(hex2dec(hexVal(end-1:end)))]; 
%         hexVal(end-1:end) = [];
%     end    
%     byteArray = [byteArray newElements];
    
%     if numBytes > length(newElements)
%         extraBytes = numBytes - length(newElements);
%         byteArray = [byteArray uint8(zeros(1,extraBytes))];
%     end

       


end
 
% %Pad with extra zero bytes if needed
% if numBytes < length(byteArray)
%     error('Data too long for specified byte count');
% elseif numBytes > length(byteArray)
%     extraBytes = numBytes - length(byteArray);
%     byteArray = [byteArray uint8(zeros(1,extraBytes))];
% end


%end






