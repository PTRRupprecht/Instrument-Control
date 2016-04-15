
classdef ThorLSM < dabs.thorlabs.LSM
    %THORLSM Adapter between ScanImage app and Thorlabs LSM device class
       
   
    properties (Hidden,Dependent) 
        channelsInputRange; 
    end    

    properties (Hidden,Dependent,SetAccess=protected)
        channelsInputRangeValues;
        flybackScannerPeriodsCurrent; %flybackScannerPeriods value based on current values of {fieldSize,flybackScannerPeriodsSetEnable} props
    end   
    
    properties (Hidden,SetAccess=protected)
        fieldSizeMax;
        fieldSizeMin;        
        
        flybackScannerPeriodsMap; %Map of flybackScannerPeriod values keyed by fieldSize, for default case where flybackScannerPeriodsSetEnable = false & galvoEnable = true
    end    
    
    properties (Constant)
        channelsBitDepth = 14; %Both ATS460 and ATS9440 are 14-bit boards 
    end
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = ThorLSM()           
            
            %Constructor-initialized vals
%             fieldSizeInfo = 42;%obj.paramInfoMap('fieldSize');
% PR2014 :: this comes from one of the parameter maps
            obj.fieldSizeMax = 255; %fieldSizeInfo.paramMax;                     
            obj.fieldSizeMin = 10; %fieldSizeInfo.paramMin;
            
            %Load flybackScannerPeriods map - or compute/store it, if needed
            initValStruct.flybackScannerPeriodsMap = containers.Map('KeyType','double','ValueType','double');
            obj.ensureClassDataFile(initValStruct);
            
%             obj.flybackScannerPeriodsMap = obj.getClassDataVar('flybackScannerPeriodsMap');
            
%             obj.flybackScannerPeriodsSetEnable = false;

%             fieldSizes = obj.fieldSizeMin:obj.fieldSizeMax;
%             if ~isequal(cell2mat(obj.flybackScannerPeriodsMap.keys()),fieldSizes)          
%                 obj.flybackScannerPeriodsMap = containers.Map('KeyType','double','ValueType','double');
% 
%                 for fs = fieldSizes
%                    obj.fieldSize = fs;
%                    obj.flybackScannerPeriodsMap(fs) = obj.flybackScannerPeriods;                    
%                 end                                
%                 
%                 obj.setClassDataVar('flybackScannerPeriodsMap',obj.flybackScannerPeriodsMap);
%             end                                   
            
        end

        
    end

    %% PROPERTY ACCESS METHODS
    methods
                
        
        function set.channelsInputRange(obj,val)        

            for i=1:length(val)
                propName = sprintf('inputChannelRange%d',i);
                
                if ~isempty(obj.findprop(propName))
                    
                    [~,listIdx] = ismember(val{i},obj.channelsInputRangeValues,'rows');                    
                    obj.(propName) = length(obj.channelsInputRangeValues) - listIdx + 1; %LSM class accepts numeric index as well string specification
                elseif ~isempty(val{i})
                    if i > obj.numChannels
                        obj.DError('','Class %s only supports up to %d channels',mfilename('class'),obj.numChannels);
                    else
                        obj.DError('','Logical programming error');
                    end
                end
            end                        
        end
        
        %         function val = get.channelsInputRange(obj)
        %
        %             val = cell(obj.numChannels,1);
        %             for i=1:length(obj.numChannels)
        %                 propName = sprintf('inputChannelRange%d',i);
        %                 val{i} = obj.(propName);
        %             end
        %         end
        
        
        function val = get.channelsInputRangeValues(obj)
            
            
            %Nx2 array, N=channelsNumChannels, with each row representing an allowable range value (2-element arrays, specifying min-max)
            val = [0.1; 0.2; 0.4; 1; 2; 4];
             
%             persistent enumValMapMap enumValMap encodedValues    % retep
%             
%             if isempty(enumValMapMap)
%                 enumValMapMap = obj.accessAPIDataVar('enumValMapMap');
%                 enumValMap = enumValMapMap('InputRange');
%                 
%                 encodedValues = enumValMap.values();
%             end
%             
%             %TODO: Handle volts/millivolts!
%             numericVals = zeros(length(encodedValues),1);
%             for i=1:length(numericVals)
%                 rawNumericVal = str2num(encodedValues{i}(isstrprop(encodedValues{i},'digit')));
%                 if strfind(lower(encodedValues{i}),'mv')
%                     numericVals(i) = 1e-3 * rawNumericVal;
%                 else
%                     numericVals(i) = rawNumericVal;
%                 end
%             end    
%             numericVals = sort(numericVals,'descend');            
%             
%             val = zeros(length(numericVals),2);
%             for i=1:length(numericVals)
%                 val(i,:) = [0 numericVals(i)];
%             end
            %             val = cell(length(numericVals),1);
            %             for i=1:length(numericVals)
            %                 val{i} = [0 numericVals(i)];
            %             end
        end
        
  
        function val = get.flybackScannerPeriodsCurrent(obj)
            % set the number of flyback frames to zero, other than ScanImage, PR2014.
            val = 0;
        end

        
        
    end
    
    %% PUBLIC METHODS
    methods
        
        function [fieldVal,fieldValRaw] = zoom2FieldSize(obj,zoomVal)
            fieldValRaw = obj.fieldSizeMax/zoomVal;            
            fieldVal = round(fieldValRaw);
        end
        
        function [zoomVal,zoomValRaw] = fieldSize2Zoom(obj,fieldVal)
            zoomValRaw = obj.fieldSizeMax / fieldVal;            
            zoomVal = round(10 * zoomValRaw) / 10;
        end
        
    end
    
end

