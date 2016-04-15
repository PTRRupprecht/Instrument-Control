
function scim_exit(varargin)
%% function scim_exit(varargin)
%SCIM_EXIT Exits Scanimage (gracefully)
%% SYNTAX
%   scim_exit() --> exits ScanImage unconditionally
%   scim_exit('prompt') --> exits ScanImage only after user confirms intent
%% CHANGES
%   VI110708A: Clear out any other cached figure handles generated during program operation -- Vijay Iyer 11/07/08
%   VI090109A: Handle change to new DAQmx interface -- Vijay Iyer 9/01/09
%   VI092109A: Don't delete the System handle..only clear it. -- Vijay Iyer 9/19/09
%   VI112309A: Check length of some fig handle arrays at each iteration, rather than emptiness as whole -- Vijay Iyer 11/23/09
%   VI122309A: Handle multiple AOPark Tasks for Pockels beams -- Vijay Iyer 12/23/09
%   VI032810A: Close motor controller object, if in use -- Vijay Iyer 3/28/10
%   VI091510A: Add several more checks to make scim_exit() more robust -- Vijay Iyer 9/15/10
%   TO092110A: Fixed crash on Matlab/ScanImage exit. -- Tim O'Connor 9/21/10
%   VI051111A: Close secondary motor controller object, if in use -- Vijay Iyer 5/11/11
%
%% *****************************************

version = scim_isRunning();
if ~version 
    error('ScanImage is not running or not running correctly -- cannot exit from Scanimage');
end

%Prompt user before exit, if needed
if ~isempty(varargin)
    if ~ischar(varargin{1}) || ~strcmpi(varargin{1},'prompt')
        error('Invalid argument provided to. Only valid argument is ''prompt''');
    end

    ans =questdlg('Are you sure you want to exit ScanImage?','Exit ScanImage Confirmation','Yes','No','No');

    if strcmpi(ans,'No')
        return; %Abort this exit function
    end
end
        
%Handle SI4 case
if version == 4
    evalin('base','delete(hSI)');
    evalin('base','clear hSI hSICtl');
    return;
end

%Handle SI3 case

global state gh

%VI091510A
if ~isstruct(gh) %No GUIs have been created yet
    return;
end

%%%VI051710A%%%
if isfield(state,'hSI') && isvalid(state.hSI) 
    notify(state.hSI, 'appClose');
    delete(state.hSI);
end
%%%%%%%%%%%%%%%


%Clear ScanImage's GUI figures...
guiHandles = fieldnames(gh);
for i=1:length(guiHandles)  
    if ishandle(gh.(guiHandles{i}).figure1) %VI091510A
        delete(gh.(guiHandles{i}).figure1);
    end
end

%%%VI091510A: All done if no INI file has been read yet 
if ~isstruct(state) || ~isfield(state,'software') || ~isfield(state.software,'version')
    return;       
end

%Clear any other figures (VI110708A)
for i=1:length(state.internal.figHandles)
    if ishandle(state.internal.figHandles(i))
        close(state.internal.figHandles(i));
    end
end

%Clear the various acquisition/display figures
for i=1:state.init.maximumNumberOfInputChannels
    if length(state.internal.GraphFigure) >= i && ishandle(state.internal.GraphFigure(i)) %VI112309A
        delete(state.internal.GraphFigure(i));
    end
    
    if length(state.internal.MaxFigure) >= i && ishandle(state.internal.MaxFigure(i)) %VI112309A
        delete(state.internal.MaxFigure(i));
    end   
end
if ~isempty(state.internal.MergeFigure) && ishandle(state.internal.MergeFigure)
    delete(state.internal.MergeFigure);
end

%%%VI032810A%%%%%%
if ~isempty(state.motor.hMotor) && isvalid(state.motor.hMotor) %VI091510A
    delete(state.motor.hMotor);
end
%%%%%%%%%%%%%%%%%%   

%%%VI051111A%%%%%%%
if ~isempty(state.motor.hMotorZ) && isvalid(state.motor.hMotorZ) 
    delete(state.motor.hMotorZ);
end
%%%%%%%%%%%%%%%%%%%%

%%%VI090109A: Removed %%%%%%%%%%%%%%%%
%Clear objects owned by Scanimage
%
% stopAllChannels(state.acq.dm);
% delete(state.acq.dm);
% daqobjs = {'state.init.ai' 'state.init.aiPMTOffsets' 'state.init.ao1' 'state.init.ao2' ...
%             'state.init.dio' 'state.init.aiF' 'state.init.ao1F' 'state.init.ao2F' 'state.init.aoPark' ...
%             'state.init.aiZoom'};
%
% for i=1:length(daqobjs)
%     if ~isempty(eval(daqobjs{i}))
%         obj = eval(daqobjs{i});
%         if isrunning(obj)
%             stop(obj);
%         end
%         delete(obj);
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%VI090109A: Clear DAQmx Interface Objects%%%%%%%%
daqObjs = {state.init.hAI state.init.hAIZoom ...
    state.init.hAO state.init.hAOPark state.init.hTrigger state.init.hStartTrigCtr state.init.hNextTrigCtr ...
    state.shutter.hDO state.init.eom.hAO state.init.hFrameClkCtr state.init.hLineClkCtr state.init.hPixelClkCtr};

%%%VI122309A%%
for i=1:state.init.eom.numberOfBeams
    AOParkTask = ['hAOPark' num2str(i)]; %VI031110A
    if isfield(state.init.eom,AOParkTask) %VI031110A
        daqObjs{end+1} = state.init.eom.(AOParkTask);
    end
    
    %%%VI062410A
    if ~isempty(state.init.hAIPhotodiode) && ~isempty(state.init.hAIPhotodiode{i}) %VI091510A
        daqObjs{end+1} = state.init.hAIPhotodiode{i};
    end
%     %TO002110A - This was causing a C-level crash during Matlab shutdown. Technically, the issue is Matlab wasn't properly handling the cell reference exception.
%     %%%VI062410A
%     if length(state.init.hAIPhotodiode) >= i
%         if ~isempty(state.init.hAIPhotodiode{i})
%             daqObjs{end+1} = state.init.hAIPhotodiode{i};
%         end
%     end
end
%%%%%%%%%%%%%%

for i=1:length(daqObjs)
    if ~isempty(daqObjs{i}) && isvalid(daqObjs{i})
        delete(daqObjs{i});
    end
end   

%%%VI092109A
if ~isempty(state.init.hDAQmx)
    clear state.init.hDAQmx; 
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       

%Clear te global variables
clear global gh state;





