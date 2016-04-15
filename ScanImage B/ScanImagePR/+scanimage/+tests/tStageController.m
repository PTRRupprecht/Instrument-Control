%% interactive test to test scanimage.StageController
comPort = 1;

twoStepDistanceThreshold = 100; % 100 um
twoStepFastPropVals = struct('resolutionMode','coarse');
twoStepSlowPropVals = struct('resolutionMode','fine');

%%
mp = dabs.sutter.MP285('comport',comPort);
sc = scanimage.StageController(mp,...
    'twoStepEnable',true,...
    'twoStepDistanceThreshold',100,...
    'twoStepFastPropVals',twoStepFastPropVals,...
    'twoStepSlowPropVals',twoStepSlowPropVals);

%% Position
fprintf(1,'positionAbsolute: %s\n',num2str(sc.positionAbsolute));
fprintf(1,'positionRelative: %s\n',num2str(sc.positionRelative));

%% zero
sc.zeroSoft([1 0 1]);
fprintf(1,'zeroed [1 0 1]\n');
fprintf(1,'positionAbsolute: %s\n',num2str(sc.positionAbsolute));
fprintf(1,'positionRelative: %s\n',num2str(sc.positionRelative));

%% moveBlocking (big)
tic;
sc.moveRelativeBlocking(-[1e3 1e3 1e3]);
toc
fprintf(1,'positionAbsolute: %s\n',num2str(sc.positionAbsolute));
fprintf(1,'positionRelative: %s\n',num2str(sc.positionRelative));

%% moveBlocking (small)
tic;
sc.moveRelativeBlocking(-[950 950 950]);
toc
fprintf(1,'positionAbsolute: %s\n',num2str(sc.positionAbsolute));
fprintf(1,'positionRelative: %s\n',num2str(sc.positionRelative));

%% move nonblocking (small)
t = tic;
sc.moveRelativeStart(-[900 900 900]);
sc.moveWaitForFinish(0.25);
toc(t)
fprintf(1,'positionAbsolute: %s\n',num2str(sc.positionAbsolute));
fprintf(1,'positionRelative: %s\n',num2str(sc.positionRelative));

%% move nonblocking (large)
t = tic;
sc.moveRelativeStart([3e3 3e3 3e3]);
sc.moveWaitForFinish(3.0);
toc(t)
fprintf(1,'positionAbsolute: %s\n',num2str(sc.positionAbsolute));
fprintf(1,'positionRelative: %s\n',num2str(sc.positionRelative));

%% move nonblocking w timeout
t = tic;
sc.moveRelativeStart([0 0 0]);
sc.moveWaitForFinish(0.5);
toc(t)
fprintf(1,'positionAbsolute: %s\n',num2str(sc.positionAbsolute));
fprintf(1,'positionRelative: %s\n',num2str(sc.positionRelative));

%% move nonblocking w interrupt
sc.moveRelativeStart([0 0 0]);
pause(0.5);
sc.moveInterrupt();
fprintf(1,'positionAbsolute: %s\n',num2str(sc.positionAbsolute));
fprintf(1,'positionRelative: %s\n',num2str(sc.positionRelative));

