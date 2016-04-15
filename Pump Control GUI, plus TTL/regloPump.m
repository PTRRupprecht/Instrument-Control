classdef regloPump
    % A small adapter class that allows to control the reglo ICC digital
    % pump by ISMATEC/Cole-Parmer, written by Peter Rupprecht,
    % p.t.r.rupprecht (at) gmail.com
    % To start, type e.g.
    %       pumpdevice = regloPump('COM4')
    % with the COM port being the connection port to the pump (typically a
    % USB port). Then, you can start the pump, e.g. channel 3:
    %       pumpdevice.startChannel(3)
    % and change the pump speed of channel 2 to 35.7 rounds per minute:
    %       pumpdevice.setSpeed(2,35.7)
    % or stop channel 4:
    %       pumpdevice.stopChannel(4)
    % 
    % The '13' in the string that is written to the serial port stands for
    % the carriage return that is required to tell the pump that the
    % command is finished.
    
    properties
        speed = zeros(4,1); % RPM for each channel
        direction = [0 0 0 0 ]; % 1 = counter-clockwise, 0 = clockwise
        tubingdiameter = [1.02 1.02 1.02 1.02]; % in mm
        serialobj = []; % serial object defined via Matlab's serial() command
        COM = ''; % input parameter: COM port to use for the pump
    end
    
    methods
        % initialize pump
        function obj = regloPump(COM)
            obj.COM = COM;
            obj.serialobj = serial(obj.COM);
            fopen(obj.serialobj);
            for i = 1:4
                obj.speed(i) = str2double(obj.getSpeed(i));
            end
            for i = 1:4
                temp = obj.getDirection(i);
                if strcmp(temp(1),'K')
                    obj.direction(i) = 1;
                else
                    obj.direction(i) = 0;
                end
            end
        end
        % delete object
        function obj = delete(obj)
            fclose(obj.serialobj);
            delete(obj.serialobj);
            obj.serialobj = [];
        end
        % set speed for a single channel in RPM
        function obj = setSpeed(obj,channel,speed) % in RPM, with RPM <= 100
            if speed > 100; disp('Speed higher than maximum (100 RPM), reduced to maximum.'); end
            speed = max(min(speed,100),0);
            speedstring = strcat(sprintf('%03d',floor(speed)), num2str(floor((speed-floor(speed))*100)));
            obj.speed(channel) = speed;
            fprintf(obj.serialobj,'%s',strcat(num2str(channel),'S0',speedstring,13));
        end
        % read out speed of a single channel in RPM
        function getRPM = getSpeed(obj,channel)
            fprintf(obj.serialobj,'%s',strcat(num2str(channel),'S',13));
            getRPM = fscanf(obj.serialobj,'%c');
        end
        % not yet implemented/used
        % function setDiameter(obj)
        % end
        % function getDiameter(obj)
        % end
        % set direction for a single channel
        function obj = setDirection(obj,channel,direction)
            if direction == 1
                fprintf(obj.serialobj,'%s',strcat(num2str(channel),'K',13));
            else
                fprintf(obj.serialobj,'%s',strcat(num2str(channel),'J',13));
            end
            obj.direction(channel) = direction;
        end
        % get direction of a single channel
        function getDir = getDirection(obj,channel)
            fprintf(obj.serialobj,'%s',strcat(num2str(channel),'xD',13));
            getDir = fscanf(obj.serialobj,'%c');
        end
        % start operation of the respective channel
        function startChannel(obj,channel)
            fprintf(obj.serialobj,'%s',strcat(num2str(channel),'H',13));
%             fscanf(obj.serialobj,'%c');
        end
        % stop operation of the respective channel
        function stopChannel(obj,channel)
            fprintf(obj.serialobj,'%s',strcat(num2str(channel),'I',13));
%             fscanf(obj.serialobj,'%c');
        end
    end
    
end