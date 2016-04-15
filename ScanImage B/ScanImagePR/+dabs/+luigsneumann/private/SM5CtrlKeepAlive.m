function SM5CtrlKeepAlive(TObj, Event, obj)
%------------------------------------------
% Valentin Stein
% 02.04.2011
%
% function called by the Serial object to keep
% connection alive
%------------------------------------------

    fwrite(obj.Serial, obj.KeepAlive);

    while obj.Serial.BytesAvailable < 6
    end
    obj.LastAnswer = fread(obj.Serial, 6);
  
