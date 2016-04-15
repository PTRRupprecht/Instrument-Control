classdef PriorStage < Programming.Interfaces.VClassic
    %PRIORSTAGE Class encapsulating a Prior Stage controller device

    %% PSEUDO-DEPENDENT PROPERTIES
    
    properties (GetObservable, SetObservable)
        peripheralInfo;
        instrumentInfo;
        softwareVersion;
        stageInfo;
        focusInfo;
        
        limitStatus;
        motorStatus;
        limitSwitchActive;
        serialNumber;
        
        backlashEnableXY;
        backlashNumStepsXY;
        backlashJoystickEnableXY;
        backlashJoystickNumStepsXY;
        backlashEnableZ;
        backlashNumStepsZ;
        backlashJoystickEnableZ;
        backlashJoystickNumStepsZ;       
        
        joystickDirectionX;
        joystickDirectionY;
        joystickDirectionZ;
        
        absolutePosition;
        positionXY;
        positionX;
        positionY;
        positionZ;
        
        resolution;
        
        speedJoystickXY;
        speedJoystickZ;
        
        speedXY;
        speedUnitsXY;
        speedZ;
        speedUnitsZ;        
        speedMaximumXY;
        speedMaximumZ;
        accelerationXY;
        accelerationZ;
        sCurveValueXY;
        sCurveValueZ;
        
        stepSizeXY;
        directionX;
        directionY;
        
        stepSizeZ;
        directionZ;
        
        microPerRev;
      
    end
    
    %% PRIVATE PROPERTIES
    
    properties (Hidden, SetAccess=private)
        
        hSerial; %Handle to RS232 interface
        
        pdepPropCommandMap;
        
    end
    
    %% ABSTRACT PROPERTY REALIZATIONS
    properties(GetAccess=protected,Constant,Hidden)
        setErrorStrategy = 'setEmpty';
        
        
        
    end
   
    
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = PriorStage(comPort,varargin)
            % Optional Property-Value Arguments:
            %   baudRate: 
            
            import Devices.Interfaces.*;            
            
            %RS232DeviceBasic Initialization (association)
            obj.hSerial = RS232DeviceBasic(obj,'comPort', comPort,'availableBaudRates',[9600 19200 38400],'standardBaudRate',9600, 'deviceSimpleResp','R');
            obj.hSerial.initialize('comPort',comPort,varargin{:}); %Prop-Val pairs include                                          
            
            obj.hSerial.terminatorDefault = 'CR'; %Use this for both send & receive -- appears to be /no/ exceptions!!                        
            
           
            %VClass Initialization (inheritance)            
            obj.customDisplayPropertyList = {   'peripheralInfo' 'stageInfo' 'motorStatus' 'absolutePosition' 'resolution' 'backlashEnableXY' 'backlashEnableZ' ...
                                                'motorStatus' 'speedJoystickXY' 'speedJoystickZ'};
            %TODO: Add speedXY/Z/ and speedUnitsXY/Z to display list -- but need to ensure they are initialized
            %TODO: Add backlashNumSteps properties to display list (maybe) -- but need to ensure they are initialized            
                                                                     
            
            %Initialization helpers
            obj.initializePdepPropCommandMap();
                        
            %Test for correct connection
            try
                obj.getScalarNumericProp('softwareVersion');
            catch ME
                error('A serial device was detected, but was not of type %s',mfilename('class'));
            end                       
            
        end
        
        function delete(obj)            
            delete(obj.hSerial);            
        end
        
    end
    
    
    %% PROPERTY ACCESS METHODS
    
    methods (Access=protected)
        %____________________get property___________________%
        function pdepPropHandleGet(obj,src,evnt)
            propName = src.Name;
            
            switch propName
                case {'resolution', 'microPerRev'}
                    obj.pdepPropGroupedGet(@obj.getXYZProp,src,evnt)  
                case { 'limitStatus', 'limitSwitchActive'}
                    obj.pdepPropGroupedGet(@obj.getSimpleStringProp,src,evnt) %Single-line string replies
                case {'instrumentInfo'}
                    obj.pdepPropGroupedGet(@obj.getMultiStringProp,src,evnt) %Multi-line string replies /without/ END as final line
                case {'peripheralInfo', 'stageInfo','focusInfo'}
                    obj.pdepPropGroupedGet(@obj.getMultiStringEndTerminatedProp,src,evnt)  %Multi-line string replies with END as final line             
                case {'backlashEnableXY', 'backlashJoystickEnableXY', 'backlashEnableZ','backlashJoystickEnableZ'}
                    obj.pdepPropGroupedGet(@obj.getBacklashEnable, src, evnt)
                case{ 'backlashNumStepsXY', 'backlashJoystickNumStepsXY', 'backlashNumStepsZ','backlashJoystickNumStepsZ'}
                     obj.pdepPropGroupedGet(@obj.getBacklashNumSteps, src, evnt)
                case {'joystickDirectionX', 'joystickDirectionY', 'joystickDirectionZ', 'speedJoystickXY', 'speedJoystickZ', ...
                        'speedMaximumXY', 'speedMaximumZ', 'accelerationXY', 'accelerationZ', 'sCurveValueXY', 'sCurveValueZ',...
                        'motorStatus', 'softwareVersion', 'serialNumber', 'directionX', 'directionY', 'directionZ', 'stepSizeZ', ...
                        'positionX', 'positionY', 'positionZ'}
                    obj.pdepPropGroupedGet(@obj.getScalarNumericProp,src,evnt)
                case {'absolutePosition', 'stepSizeXY', 'positionXY'}
                    obj.pdepPropGroupedGet(@obj.getVectorNumericProp,src,evnt);
                case {'speedXY', 'speedUnitsXY', 'speedZ', 'speedUnitsZ'} %PRIOR: Strange that Prior interface does not allow read access for these values
                    %Do nothing -- this will use locally store variable
                otherwise
                    obj.pdepPropGroupedGet(@obj.getStandard,src,evnt)
            end
            
        end
        
        function val = getSimpleStringProp(obj,propName)
            val = obj.hSerial.sendCommandStringReply(obj.pdepPropCommandMap(propName));
        end
        
        function val = getMultiStringProp(obj,propName)
            val = obj.getMultiStringHelper(propName,false);            
        end
     
        
        function val = getMultiStringEndTerminatedProp(obj,propName)      
            val = obj.getMultiStringHelper(propName,true);
        end
            

        function val = getScalarNumericProp(obj,propName)           
            val = str2double(obj.hSerial.sendCommandStringReply(obj.pdepPropCommandMap(propName)));                                              
        end
        
        function val = getVectorNumericProp(obj,propName)
           respString =  obj.hSerial.sendCommandStringReply(obj.pdepPropCommandMap(propName));                         
           
           counter = 0;
           while ~isempty(respString)
               [oneVal, respString] = strtok(respString, ',');
               counter = counter + 1;
               val(counter) = str2double(oneVal);
           end            
        end
        
        function val = getXYZProp(obj, propName)
           %Go through and call RES once for each axis and pack into vectot 
           XYval = str2double(obj.hSerial.sendCommandStringReply([obj.pdepPropCommandMap(propName),',s']));   
           Zval = str2double(obj.hSerial.sendCommandStringReply([obj.pdepPropCommandMap(propName),',z']));            
           val = [XYval, Zval];
        end
        
        function val = getBacklashEnable(obj, propName)
           reslt =  obj.hSerial.sendCommandStringReply(obj.pdepPropCommandMap(propName));  
           [enable, ~] = strtok(reslt, ',');
           val = enable;
        end
        
        function val = getBacklashNumSteps(obj,propName)
            
            %PRIOR: The backlash commands do not appear to return number of steps, as documented. 
            
            error('The number of steps for backlash mode is not accessible');
            %             reslt =  obj.hSerial.sendCommandStringReply(obj.pdepPropCommandMap(propName));
            %             [~, numSteps] = strtok(reslt, ',');
            %             val = str2double(strtok(numSteps, ','));
        end
    
    %Get Property Helper Methods
    
    function val = getMultiStringHelper(obj,propName,endTerminated)                
      
            cachedTerminator = obj.hSerial.hSerial.terminator;
            
            try
                obj.hSerial.sendCommand(obj.pdepPropCommandMap(propName));
                
                obj.hSerial.hSerial.terminator = 'CR';
                
                firstLineReceived = false;                   
                
                val = '';
                while true          
                    if ~endTerminated && firstLineReceived
                        if ~obj.hSerial.hSerial.BytesAvailable
                            break;
                        end
                    end
                    
                    [newLine,~,msg] = fgetl(obj.hSerial.hSerial);
                    firstLineReceived = true;
                    
                    if isempty(newLine)
                         error('ERROR: Serial port communication error occurred (%s). Cannot access ''%s'' property.',msg,propName);                                 
                    elseif strcmpi(newLine,'END')
                        break;
                    else
                        val = strvcat(val,newLine); %#ok<VCAT>
                    end
                end
                
                obj.hSerial.hSerial.terminator = cachedTerminator;
                
            catch ME
                obj.hSerial.hSerial.terminator = cachedTerminator;
                ME.rethrow();
            end            
        
    end
        
        
    %______________________set property_____________________________%
        
        function pdepPropHandleSet(obj,src,evnt)
            propName = src.Name;
            
            switch propName
                case {'speedXY', 'speedUnitsXY', 'speedUnitZ'}
                    obj.pdepPropIndividualSet(src,evnt)
                case {'backlashEnableXY', 'backlashJoystickEnableXY', 'backlashEnableZ', 'backlashJoystickEnableZ',... 
                        'joystickDirectionX', 'joystickDirectionY', 'joystickDirectionZ', 'speedJoystickXY',...
                        'speedJoystickZ', 'speedMaximumXY', 'speedMaximumZ', 'accelerationXY', 'accelerationZ',...
                        'sCurveValueXY', 'sCurveValueZ', 'directionX', 'directionY', 'directionZ','stepSizeZ', ...
                         'positionX', 'positionY', 'positionZ'}
                    obj.pdepPropGroupedSet(@obj.setScalarNumericProp, src, evnt)
                case{ 'backlashNumStepsXY', 'backlashJoystickNumStepsXY', 'backlashNumStepsZ', 'backlashJoystickNumStepsZ'}
                     obj.pdepPropGroupedSet(@obj.setBacklashNumSteps, src, evnt)
                case { 'stepSizeXY', 'positionXY'}
                    obj.pdepPropGroupedSet(@obj.setVectorNumericProp,src,evnt)
                case {'resolution', 'microPerRev'}
                    obj.pdepPropGroupedSet(@obj.setXYZProp, src, evnt)                    
                case {'absolutePosition'}
                    obj.pdepPropSetDisallow(src,evnt)
            end
        end
        
        function val = setScalarNumericProp(obj,propName, val)
            val = (obj.hSerial.sendCommandStringReply([obj.pdepPropCommandMap(propName), ',', num2str(val)]));
            checkSerialReply(propName, val);
        end
        
        function val = setVectorNumericProp(obj,propName, valArray)
            % now the parameter is a numberic array, we need to concatenate
            % them to a string
            valString = '';
            for counter = 1: length(valArray)
                if ~isnan(valArray(counter))  %don't accept NAN arguments
                    valString = [valString, ',', num2str(valArrary(counter))];
                else
                    fprintf('Fail to set the property %s because NAN is unacceptable.\n',propName);
                end
            end
            
            val = obj.hSerial.sendCommandStringReply([obj.pdepPropCommandMap(propName), valString]);
            checkSerialReply(propName, val);
        end
        
        function val = setBacklashNumSteps(obj, propName, numSteps)
            rst = strfind(propName, 'NumSteps');
            enablePropName = [propName(1:rst-1) 'Enable' propName(rst+8:end)];
            enableVal = obj.(enablePropName);
            val = (obj.hSerial.sendCommandStringReply([obj.pdepPropCommandMap(propName), ',', num2str(enableVal), ',', num2str(numSteps)]));
            checkSerialReply(propName, val);
        end
        
        function setXYZProp(obj, propName, val)
            oldVal = obj.(propName);
            if (~isnan(val(1))) && (oldVal(1) ~= val(1)) %X axis value is changed
                obj.hSerial.sendCommand([obj.pdepPropCommandMap(propName), ',x,', num2str(val(1))]);
            end
            
            if (~isnan(val(2))) && (oldVal(2) ~= val(2)) %Y axis value is changed
                obj.hSerial.sendCommand([obj.pdepPropCommandMap(propName), ',y,', num2str(val(2))]);
            end
            
            if (~isnan(val(3))) && (oldVal(3) ~= val(3)) %Z axis value is changed
                obj.hSerial.sendCommand([obj.pdepPropCommandMap(propName), ',z,', num2str(val(3))]);                
            end
        end
        
        
        function setSpeedXY(obj, val)
            unitVal = obj.speedUnitsXY;
            valString = [num2str(val(1)), ',', num2str(val(2)), ',', unitVal];
            obj.hSerial.sendCommand(['VS,', valString]);
        end
        
        function setSpeedUnitsXY(obj, val)
            %val is either 'u' or 'p'
            if (strcmp(val, 'p') || srcmp(val, 'u'))
                speedVal = obj.speedXY;
                valString = [num2str(speedVal(1)), ',', num2str(speedVal(2)), ',', val];
                obj.hSerial.sendCommand(['VS,', valString]);
            else
                fprintf('wrong input value for speedUnitsXY, it should be either p or u.\n');
            end
        end
        
        function setSpeedZ(obj, val)
            unitVal = obj.speedUnitsZ;
            valString = [num2str(val), ',', unitVal];
            obj.hSerial.sendCommand(['VZ,', valString]);
        end
        
        function setSpeedUnitsZ(obj, val)
            %val is either 'u' or 'p'
            if (strcmp(val, 'p') || srcmp(val, 'u'))
                speedVal = obj.speedZ;
                valString = [num2str(speedVal),',', val];
                obj.hSerial.sendCommand(['VZ,', valString]);
            else
                fprintf('wrong input value for speedUnitsZ, it should be either p or u.\n');
            end
        end
        
    end
    
    %% PUBLIC METHODS
    methods
        %------------------------General commands----------------------%
        function stop(obj)
           %stops movement in a controlled manner to reduce the risk of losing position
           obj.hSerial.sendCommandSimpleReply('I');
        end
        
        function stopImmediate(obj)
            %stops movement immediately in all axes. 
            %Mechanical inertia may  result in the system continuing to move for a short period after 
            %the command is received. In this case, the controller position 
            %and mechanical position will no longer agree.
           obj.hSerial.sendCommandSimpleReply('K');            
        end
          
        
        %------------------------x, y, and z axis commands----------------------%
        %TODO: Add separate moveCompleteAbsolute() and moveCompleteIncremental() methods -- these will call moveStartXXX() methdos and poll for completion
        
        function moveStartAbsolute(obj,targetPosn)
            %targetPosn is a 2 or 3 element array specifying X,Y or X,Y,Z position 
            %the current 'absolute' coordinates maintained by device
            %To specify no motion in a given axis, use NaN
                      
            if (length(targetPosn)==2) || (isnan(targetPosn(3)))
                if isnan(targetPosn(2))
                    obj.hSerial.sendCommandSimpleReply(['GX,' num2str(targetPosn(1))]);
                else isnan(targetPosn(1))
                    obj.hSerial.sendCommandSimpleReply(['GY,' num2str(targetPosn(2))]); %Z is optional with G command
                end
            else %Case where all three coordinates are given, but may include NAN
                currPosn = obj.absolutePosition;
                for index = 1:3 
                    if isnan(targetPosn(index))
                        targetPosn(index) = currPosn(index);
                    end
                end  
                obj.hSerial.sendCommandSimpleReply(['G,' num2str(targetPosn(1)) ',' num2str(targetPosn(2)), ',' num2str(targetPosn(3))]);
            end
        end
        
        
        function moveCompleteAbsolute(obj,targetPosn)
            %targetPosn is a 2 or 3 element array specifying X,Y or X,Y,Z position
            %the current 'absolute' coordinates maintained by device
            %To specify no motion in a given axis, use NaN            
         
            
            finished = zeros(1, length(targetPosn));
            moveStartAbsolute(obj,targetPosn);
            
            %TODO: Use a class moveTimeout property to throw error if taking too long
            %TODO: Fix as done in moveCompleteIncremental()
            while finised ~= ones(1, length(targetPosn))
                currPosn = obj.absolutePosition;
                for index = 1:length(targetPosn)
                    if isnan(targetPosn(index))
                        finished(index) = 1;
                    else
                        if targetPosn(index) == currPosn(index)
                           finished(index) = 1;
                        end
                    end
                end               
            end
            
        end
        
        function moveStartIncremental(obj,targetPosn)
            %targetPosn is a 2 or 3 element array specifying X,Y,and Z distance to move relative to current position
            %NaN is not acceptable in this function (use 0 instead)
            
            if (length(targetPosn)==2)
                obj.hSerial.sendCommandSimpleReply(['GR,' num2str(targetPosn(1)) ',' num2str(targetPosn(2))]);
            else
                obj.hSerial.sendCommandSimpleReply(['GR,' num2str(targetPosn(1)) ',' num2str(targetPosn(2)) ',' num2str(targetPosn(3))]);
            end
        end
        
        function moveCompleteIncremental(obj,targetPosn)
            %targetPosn is a 2 or 3 element array specifying X,Y,and Z distance to move relative to current position
            %NaN is not acceptable in this function (use 0 instead)
            finished = false(1, length(targetPosn));
            oldPosn = obj.absolutePosition;
            moveStartIncremental(obj,targetPosn);
            
            %TODO: Use a class moveTimeout property to throw error if taking too long
            while any(~finished)
                currPosn = obj.absolutePosition;
                for index = 1:length(targetPosn)
                    if targetPosn(index)==0
                        finished(index) = true;
                    else
                        if  currPosn(index) == oldPosn(index) + targetPosn(index)
                            finished(index) = true;
                        end
                    end
                end
                pause(0.1);
            end
            
            
        end        
        
        function moveToAbsoluteOrigin(obj)
            % move the stage and focus to zero (0,0,0)
            obj.hSerial.sendCommandSimpleReply('M');
        end
        
        function setAbsoluteOrigin(obj,varargin)
            %Sets current position to absolute origin maintained by device firmware
            %If (optional) 'newCoordinates' is supplied, as a 2 or 3 element vector, the current position will be set to the specified position
            
            if isempty(varargin) %Sets the stage and focus position to Zero(0,0,0)               
                val = obj.hSerial.sendCommandStringReply('Z');
                if (val ~= '0')
                    fprintf('Failed to set the stage and focus position to Zero.\n');
                end
            else                 %Sets a new coordinates
                if (length(varargin{1})==2) || (isnan(varargin{1}(3)))
                    if isnan(varargin{1}(2))
                        obj.hSerial.sendCommandSimpleReply(['PX,' num2str(varargin{1}(1))]);
                    else isnan(varargin{1}(1))
                        obj.hSerial.sendCommandSimpleReply(['PY,' num2str(varargin{1}(2))]); %Z is optional with G command
                    end
                else             %Case where all three coordinates are given, but may include NAN
                    currPosn = obj.absolutePosition;
                    for index = 1:3
                        if isnan(varargin{1}(index))
                            targetPosn(index) = currPosn(index);
                        end
                    end
                    obj.hSerial.sendCommandSimpleReply(['P,' num2str(targetPosn(1)) ',' num2str(targetPosn(2)), ',' num2str(targetPosn(3))]);
                    if (val ~= '0')
                        fprintf('Failed to set a new coordinate.\n');
                    end
                end
            end
            
        end
        
          %------------------------x and y axese commands----------------------%      
        
        function moveXYBack(obj,varargin)
            %move back by specified steps
            
            if isempty(varargin)             %move back by v steps as defined by the 'X' command
                obj.hSerial.sendCommandSimpleReply('B');
            else                          %move back by steps specified by the function argument
                obj.hSerial.sendCommandSimpleReply(['B,' num2str(varargin)]);
            end
        end
        
        function moveXYForward(obj,varargin)
            %move forward by specified steps
            
            if isempty(varargin)             %move forward by v steps as defined by the 'X' command
                obj.hSerial.sendCommandSimpleReply('F');
            else                          %move forward by steps specified by the function argument
                obj.hSerial.sendCommandSimpleReply(['F,' num2str(varargin)]);
            end
        end
        
        function moveXYLeft(obj,varargin)
            %move left by specified steps
            
            if isempty(varargin)              %move left by v steps as defined by the 'X' command
                obj.hSerial.sendCommandSimpleReply('L');
            else                          %move left by steps specified by the function argument
                obj.hSerial.sendCommandSimpleReply(['L,' num2str(varargin)]);
            end
        end     
        
        function moveXYRight(obj, varargin)
            %move right by specified steps
            
            if isempty(varargin)            %move right by v steps as defined by the 'X' command
                obj.hSerial.sendCommandSimpleReply('R');
            else                          %move right by steps specified by the function argument
                obj.hSerial.sendCommandSimpleReply(['R,' num2str(varargin)]);
            end
        end   
        
        function restoreXYIndex(obj)
            %restore index of stage. This command is only effective if the
            %SIS command has been used on installation This command can be
            %used at any time and will resynchronize the stage and
            %controller position should the stage hae been manually moved
            %when th econtroller was off. If the stage has not been
            %manually moved this command will not normally be needed.
            
            % Construct a questdlg with two options
            choice = questdlg('Restore Index of Stage is only effective if the SIS comand has been used on installation. If the stage has not been manually moved, this command will not normally be needed. Are you still want to restore index of stage?', ...
                'Restore index of stage', 'Yes','No','No');
            % Handle response
            switch choice
                case 'Yes'
                    obj.hSerial.sendCommandSimpleReply('RIS');
                case 'No'
            end


        end
        
        function setXYIndex(obj)
            %Set index of stage. This command would normally only be used
            %on first installation of the system

            
            % Construct a questdlg with two options
            choice = questdlg('Set index of stage would normally only be used on first installation of the system. Are you still want to restore index of stage?', ...
                'Set index of stage', 'Yes','No','No');
            % Handle response
            switch choice
                case 'Yes'
                    obj.hSerial.sendCommandSimpleReply('SIS');
                case 'No'
            end
        end
        
       %------------------------Z axis commands----------------------% 
       function moveZDown(obj, varargin)
            %move down by specified steps
            if isempty(varargin)                         %move down by v steps as defined by the 'C' command
                obj.hSerial.sendCommandSimpleReply('D');
            else                          %move down by steps specified by the function argument
                obj.hSerial.sendCommandSimpleReply(['D,' num2str(varargin)]);
            end
       end 
        
       
       function moveZUp(obj, varargin)
            %move up by specified steps
            if isempty(varargin)                       %move up by v steps as defined by the 'C' command
                obj.hSerial.sendCommandSimpleReply('U');
            else                          %move up by steps specified by the function argument
                obj.hSerial.sendCommandSimpleReply(['U,' num2str(varargin)]);
            end
       end 
       
       function moveAbsZPos(obj,targetZPos)
           obj.hSerial.sendCommandSimpleReply(['V,' num2str(targetZPos)]);
       end
       
        %------------------------joystick commands----------------------%   
        
        function turnOnJoystick(obj)
            val = obj.hSerial.sendCommandStringReply('H');
            if (val ~= '0')
                fprintf('Failed turn on the joystick.\n')
            end
        end
        
        function turnOffJoystick(obj)
            val = obj.hSerial.sendCommandStringReply('J');
            if (val ~= '0')
                fprintf('Failed turn off the joystick.\n')
            end
        end
    end
    
    %% ABSTRACT METHOD IMPLEMENTATIONS & SUPERCLASS OVERRIDES
    
    methods
        function display(obj)
           obj.VClassDisplay(); 
        end                
        
    end
    
    
    
    %% PRIVATE/PROTECTED METHODS
    
    methods (Access=private)
        
        function initializePdepPropCommandMap(obj)
            obj.pdepPropCommandMap = containers.Map('KeyType','char','ValueType','char');
            
            obj.pdepPropCommandMap('peripheralInfo') = '?';
            obj.pdepPropCommandMap('instrumentInfo') = 'DATE';
            obj.pdepPropCommandMap('softwareVersion') = 'VERSION';
            obj.pdepPropCommandMap('stageInfo') = 'STAGE';
            obj.pdepPropCommandMap('focusInfo') = 'FOCUS';
            
            obj.pdepPropCommandMap('limitStatus') = '=';
            obj.pdepPropCommandMap('motorStatus') = '$';
            obj.pdepPropCommandMap('limitSwitchActive') = 'LMT';
            obj.pdepPropCommandMap('serialNumber') = 'SERIAL';
            
            obj.pdepPropCommandMap('backlashEnableXY') = 'BLSH';
            obj.pdepPropCommandMap('backlashNumStepsXY') = 'BLSH';
            obj.pdepPropCommandMap('backlashJoystickEnableXY') = 'BLSJ';
            obj.pdepPropCommandMap('backlashJoystickNumStepsXY') = 'BLSJ';
            obj.pdepPropCommandMap('backlashEnableZ') = 'BLZH';
            obj.pdepPropCommandMap('backlashNumStepsZ') = 'BLZH';
            obj.pdepPropCommandMap('backlashJoystickEnableZ') = 'BLZJ';
            obj.pdepPropCommandMap('backlashJoystickNumStepsZ') = 'BLZJ';
            
            
            obj.pdepPropCommandMap('joystickDirectionX') = 'JXD';
            obj.pdepPropCommandMap('joystickDirectionY') = 'JYD';
            obj.pdepPropCommandMap('joystickDirectionZ') = 'JZD';
            
            obj.pdepPropCommandMap('absolutePosition') = 'P';
            obj.pdepPropCommandMap('positionXY') = 'PS';
            obj.pdepPropCommandMap('positionX') = 'PX';
            obj.pdepPropCommandMap('positionY') = 'PY';
            obj.pdepPropCommandMap('positionZ') = 'PZ';            

        
            obj.pdepPropCommandMap('resolution') = 'RES';
            
            obj.pdepPropCommandMap('speedJoystickXY') = 'O';
            obj.pdepPropCommandMap('speedJoystickZ') = 'OF';
            
            obj.pdepPropCommandMap('speedXY') = 'VS';
            obj.pdepPropCommandMap('speedUnitsXY') = 'VS';
            obj.pdepPropCommandMap('speedZ') = 'VZ';
            obj.pdepPropCommandMap('speedUnitsZ') = 'VZ';
            
            obj.pdepPropCommandMap('speedMaximumXY') = 'SMS';
            obj.pdepPropCommandMap('speedMaximumZ') = 'SMZ';
            obj.pdepPropCommandMap('accelerationXY') = 'SAS';
            obj.pdepPropCommandMap('accelerationZ') = 'SAZ';
            obj.pdepPropCommandMap('sCurveValueXY') = 'SCS';
            obj.pdepPropCommandMap('sCurveValueZ') = 'SCZ';
            
            obj.pdepPropCommandMap('stepSizeXY') = 'X';
            obj.pdepPropCommandMap('directionX') = 'XD';
            obj.pdepPropCommandMap('directionY') = 'YD';
            obj.pdepPropCommandMap('stepSizeZ') = 'C';
            obj.pdepPropCommandMap('directionZ') = 'ZD';
            
            obj.pdepPropCommandMap('microPerRev') = 'UPR';         
        end
        

        
    end
    
    
    
end

%% HELPER FUNCTIONS
function checkSerialReply(propName, returnVal)
if (returnVal ~= '0') %Device returns 0 when property set is successful, and appears to return 'R' when not successful
    %fprintf('Failed to set the property %s\n', propName)
    throwAsCaller(MException('','Device reports an error on attempt to set property ''%s''',propName));
end
end

