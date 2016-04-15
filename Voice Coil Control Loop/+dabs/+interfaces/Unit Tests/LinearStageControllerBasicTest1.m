
%% Variables
clc;
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end
if ~isempty(timerfindall)
    delete(timerfindall);
end

%classUnderTest = 'dabs.scientifica.LinearStageController';
%constructionPVArgs = {'stageType','patchstar','comPort', 3, 'baudRate', 9600};
classUnderTest = 'dabs.sutter.MP285';
constructionPVArgs = {'stageType','mp285','comPort', 3, 'baudRate', 9600, 'bufferSize', 512,'resolution',[.05 .05 .01]};
%classUnderTest = 'dabs.sutter.MPC200';
%constructionPVArgs = {'stageType','mp285','comPort', 6, 'baudRate', 128000, 'resolution',.0625};

moveTestDistancePerDimension = 4000.15; %Distance in um to move for long tests
moveTestMaxVelocitySubFactors = [3 6];
moveTestMoveTimeout = 30;
moveTestStandardReplyTimeout = 2;

moveTestCompleteEventFcn = @(src,evnt)fprintf(1,'Move completed. Reached position: %s\n',mat2str(src.positionAbsolute));
moveTestCompleteEventListener = [];



%% Object Construction

hStage = feval(classUnderTest,constructionPVArgs{:});


%% Read-out of all public properties

mc = metaclass(hStage);
propcell = mc.Properties;
propcell = propcell(cellfun(@(x) strcmpi(x.GetAccess,'public') && ~x.Hidden,propcell));
props = cellfun(@(x)x.Name,propcell,'UniformOutput',false);

badProps = {};
badPropErrors = {};

for i=1:length(props)
   try
       val = hStage.(props{i});
   catch ME
      badProps = [{props{i}} badProps]; %#ok<AGROW>
      badPropErrors = [{ME.message} badPropErrors]; %#ok<AGROW>
   end    
end

if ~isempty(badProps)
    disp('Encountered errors accessing the following properties:');
    fprintf(1,'Property Name\t\tErrorMessage\n');
    for i=1:length(badProps)
        fprintf(1,'%s\t\t%s\n',badProps{i},badPropErrors{i});
    end
else
    disp('Successfully read all public properties!');
end


%% test two step move
hStage.twoStepMoveSlowDistance = 2000;
%hStage.twoStepMoveSlowVelocity = 7;
%hStage.twoStepMoveSlowResolutionMode = 'default';
hStage.twoStepMoveSlowVelocity = 500;
hStage.twoStepMoveSlowResolutionMode = 'fine';
%hStage.twoStepMoveSlowMoveMode = 'straightLine'; % MPC-200
hStage.twoStepMoveSlowMoveMode = 'default'; % Scientifica
hStage.twoStepMoveEnable = true;


%% MoveComplete test at different velocities

%TODO: Repeat this test for all of the resolution modes

hStage.moveTimeout = moveTestMoveTimeout;

hStage.velocity = hStage.maxVelocity;
direction = 1;
fprintf(1,'Starting move of specified distance (%d um) at maximum velocity\n',moveTestDistancePerDimension);
t1 = tic();
hStage.moveComplete(hStage.positionAbsolute + direction * moveTestDistancePerDimension * [1 1 1]);
fprintf(1,'Completed move in %1.2g seconds\n',toc(t1));
pause(0.5);

for subFactor=moveTestMaxVelocitySubFactors
    direction = direction * (-1);
    hStage.velocity = round(hStage.maxVelocity / subFactor);
    
    fprintf(1,'Starting move of specified distance (%d um) at velocity %dX slower than maximum velocity\n',moveTestDistancePerDimension,subFactor);   
    t1 = tic();    
    hStage.moveComplete(hStage.positionAbsolute + direction * moveTestDistancePerDimension * [1 1 1]);        
    fprintf(1,'Completed move in %1.2g seconds\n',toc(t1));
end

%% MoveCompleteGenerateEvent test at different velocities

%TODO: Repeat this test for all of the resolution modes

hStage.hHardwareInterface.replyTimeoutDefault = moveTestStandardReplyTimeout;
hStage.asycMoveTimeout = moveTestMoveTimeout;

if ~isempty(moveTestCompleteEventListener)
    delete(moveTestCompleteEventListener);
end
moveTestCompleteEventListener = hStage.addlistener('moveCompleteEvent',moveTestCompleteEventFcn);

hStage.velocity = hStage.maxVelocity;
direction = 1;
fprintf(1,'Starting move of specified distance (%d um) at maximum velocity\n',moveTestDistancePerDimension);
hStage.moveStartCompleteEvent(hStage.positionAbsolute + direction * moveTestDistancePerDimension * [1 1 1]);
s = input('Press a key to continue AFTER move complete notification occurs; q to quit\n','s');
if strcmpi(s,'q')
    error('Test aborted');
end  

for subFactor=moveTestMaxVelocitySubFactors
    direction = direction * (-1);
    hStage.velocity = round(hStage.maxVelocity / subFactor);
    
    fprintf(1,'Starting move of specified distance (%d um) at velocity %dX slower than maximum velocity\n',moveTestDistancePerDimension,subFactor);
    hStage.moveStartCompleteEvent(hStage.positionAbsolute + direction * moveTestDistancePerDimension * [1 1 1]);        
    s = input('Press a key to continue AFTER move complete notification occurs; q to quit\n','s');
    if strcmpi(s,'q')
        error('Test aborted');
    end
    
end    
    












