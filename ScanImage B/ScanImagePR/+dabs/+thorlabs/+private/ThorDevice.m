classdef ThorDevice < most.MachineDataFile % & most.PDEPProp %& most.APIWrapper % & most.APIWrapper
    %THORDEVICE Summary of this class goes here

    %% ABSTRACT PROPERTIES
    
    properties (Abstract, Constant, Hidden)
        prop2ParamMap; %Map of class property names to API-defined parameters names
    end    
    %% ABSTRACT PROPERTY REALIZATIONS (most.MachineDataFile)
    properties (Constant, Hidden)
        mdfClassName = mfilename('class');
        mdfHeading = 'Thorlabs Devices';        
        
        mdfDependsOnClasses;
        mdfDirectProp=true;
        mdfPropPrefix;
    end 


    
    %% PUBLIC PROPERTIES
    properties (SetAccess=protected)
         deviceID;
    end
    
    %% PROTECTED/PRIVATE PROPERTIES
    properties (Hidden,SetAccess=protected)
        paramInfoMap; %Map of parameter names to structure of information about the parameters
        paramCodeMap; %Map of parameter names to parameter code values
    end
    
    properties (Hidden, SetAccess=private)
        currentDeviceIDMap = containers.Map('KeyType','char','ValueType','uint8'); %Map of ThorDevice classes to value indicating last deviceID for which property access or method was applied
        
        isConnected = false;
    end
    %% ABSTRACT PROPERTY REALIZATIONS (most.PDEPProp)
    
%     properties (Constant, Hidden)
%         pdepSetErrorStrategy = 'restoreCached'; % <One of {'setEmpty','restoreCached','setErrorHookFcn'}>. setEmpty: stored property value becomes empty when driver set error occurs. restoreCached: restore value from prior to the set action generating error. setErrorHookFcn: The subclass implements its own setErrorHookFcn() to handle set errors in subclass-specific manner.
%     end
   
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = ThorDevice(deviceID)
%         function obj = ThorDevice()
            
            %Parse input arguments
            if ~nargin || isempty(deviceID)
                deviceID = 0;
            end
            
            %Add entry to currentDeviceIDMap for this class, if needed
            if ~obj.currentDeviceIDMap.isKey(class(obj))
                obj.currentDeviceIDMap(class(obj)) = -1;
            end
        
        %Query API to build up Map of parameter information znstInitParamMaps();

        return;
            
        function znstInitParamMaps()
                %Function initializes paramInfoMap/paramCodeMap properties
                %   paramInfoMap: map from class property name to information structure for corresponding param
                %   paramCodeMap: map from class property name to code number for corresponding param (for Get/SetParam() calls)
                
                enumNameMap = obj.accessAPIDataVar('enumNameMap');
                obj.paramInfoMap = containers.Map();
                obj.paramCodeMap = containers.Map({'dummy'},{0}); obj.paramCodeMap.remove('dummy');
                
                propNames = obj.prop2ParamMap.keys();
                
                for j=1:length(propNames)
                    
                    paramName = obj.prop2ParamMap(propNames{j});
                    
                    if enumNameMap.isKey(paramName) %For backward compatibility to earlier API versions with less properties
                        paramCode = enumNameMap(paramName);
                        obj.paramCodeMap(propNames{j}) = paramCode;
                        
                        paramStruct = struct();
                        
                        paramInfoNames = {'paramType' 'paramAvailable' 'paramReadOnly' 'paramMin' 'paramMax' 'paramDefault'};
                        
                        paramInfoVals = cell(length(paramInfoNames),1);
                        
                        try
                            [paramInfoVals{:}] = 1; %%% PR2014 retep  TODO 
                        catch %Handle backward-compatibility -- some of the current properties may not have been in previous API versions
                            continue;
                        end
                        
                        for k=1:length(paramInfoNames)
                            paramStruct.(paramInfoNames{k}) = paramInfoVals{k};
                        end
                        
                        obj.paramInfoMap(propNames{j}) = paramStruct;
                    end
                    
                end
            end 
        end
        
        function delete(obj)
 
        
        end
        
        function initialize(obj)
            
 
        end
        
    end 

    
    
end


