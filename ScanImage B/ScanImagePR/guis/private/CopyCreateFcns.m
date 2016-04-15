function [C,linesToAppend] = CopyCreateFcns()
%COPYCREATEFCNS Summary of this function goes here
%   Detailed explanation goes here

[srcFile,srcPath] = uigetfile('*.m','Select Source File');
[dstFile,dstPath] =  uigetfile(fullfile(srcPath,'*.m'),'Select Destination File');

srcFid = fopen(fullfile(srcPath,srcFile),'r');
dstFid = fopen(fullfile(dstPath,dstFile),'a');

try
    C = textscan(srcFid,'%s','Delimiter','');
    C = C{1};
    
    linesToAppend = [];
    lineCounter = 1;
    
    while lineCounter < length(C)
        if strfind(C{lineCounter},'_CreateFcn(hObject')
            linesToAppend(end+1) = lineCounter - 1; %Add preceding comment line
            linesToAppend(end+1) = lineCounter; %Add CreateFcn line
            
            while true
                lineCounter = lineCounter + 1;
                
                if ~isempty(strfind(C{lineCounter},'function ')) || ...
                   ~isempty(strfind(C{lineCounter},'% ---'))
                    lineCounter = lineCounter - 1;
                    break;                    
                elseif lineCounter == length(C)                    
                    break;
                end                
            end
            
            linesToAppend = [linesToAppend (linesToAppend(end)+1):(lineCounter)];            
        end
        
        lineCounter = lineCounter + 1;
    end
     
    %disp(linesToAppend');
    %fprintf('Final line counter: %d\n',lineCounter);
    
    %Append to dest file    
    for i=1:length(linesToAppend)
        if i==1 || linesToAppend(i) > (linesToAppend(i-1)+1)
            fprintf(dstFid,'\n');
        end
        fprintf(dstFid,'%s\n',C{linesToAppend(i)});
    end
    
catch ME
    cleanup();
    ME.rethrow();
end

cleanup();


    function cleanup()
        fclose(srcFid);
        fclose(dstFid);
    end
end

