function scim_upgrade(varargin)
%SCIM_UPGRADE Utility function for upgrading data files (e.g. CFG, USR, and
%INI or MachineData files) to work with newer version of ScanImage.
%Function upgrades all files of specified file extension in the the
%selected directory(s), and then saves all upgraded files to a common
%target directory
%
% Function prompts first for source directory and then for target directory containing upgraded files.
%
% SYNTAX
%   scim_upgrade() - <For SI 4.x versions> Upgrades prior SI4 files to be compatible with current SI4 version
%   scim_upgrade(newVersion,oldVersion) - <For SI 3.x versions> Upgrade files from one specified version to another (e.g. '3.7.1' to '3.8')


if nargin == 2
    scim_upgrade_3(varargin{:});
else
    assert(nargin == 0,'The scim_upgrade() function takes either 0 or 2 arguments - for SI4 and SI3, respectively.');
end

verUpdateFcnsMap = getVerUpdateFcnsMap();


%Select source file path
sourcePath = uigetdir(most.idioms.startPath,'Select source folder');
if isnumeric(sourcePath)
    return;
end

%Select target file path
targetPath = uigetdir(fileparts(sourcePath),'Select target folder');
if isnumeric(targetPath)
    return;
end

%Determine current version
ds = dir(sourcePath);
ds = ds([ds.isdir] == 0);

for dirIdx=1:length(ds)
    
    [~,f,e] = fileparts(ds(dirIdx).name);
    srcName = fullfile(sourcePath,[f e]);
    
    if ismember(lower(e),{'.usr' '.cfg'})
        srcFile = matfile(srcName);
    else
        srcFile = [];
    end
    
    %Assume we're updating from ScanImage r4.1.0, by default
    ver = struct('major',4.1,'minor',0,'pr',inf);
    
    %Check source file ScanImage version if possible (for CFG/USR files)
    if ~isempty(srcFile)
        s = srcFile.scanimage_SI4;
        if isfield(s,'versionMajor')
            ver.major = s.versionMajor;
            
            if isfield(s,'versionMinor')
                ver.minor = s.versionMinor;
            end
            
            if isfield(s,'versionPRNumber')
                ver.pr = s.versionPRNumber;
            end
        end
    end
    
    versionUpdateFcns = verUpdateFcnsMap(getVersionTag(ver));
    
    for fcnIdx=1:length(versionUpdateFcns)
        if ~isempty(srcFile)
            feval(versionUpdateFcns{fcnIdx},srcFile,targetPath);
        else
            feval(versionUpdateFcns{fcnIdx},srcName,targetPath);
        end
    end
    
end


return;

end



%% VERSION UPDATE FUCNTIONS

function m = getVerUpdateFcnsMap()
%Identify update functions needed to upgrade from specified version

m = containers.Map;

m('4.1.0') = {@updatePropSetsToR4p2 @updateMDFToR4p2 @copyXMLFiles};
m('4.1.1') = {@updatePropSetsToR4p2 @updateMDFToR4p2 @copyXMLFiles};

end

function updateMDFToR4p2(srcFileOrName,targetPath)

[srcName,srcFile] = getSourceFileDescriptors(srcFileOrName);
[~,f,e] = fileparts(srcName);

%Identify if this is a Machine Data File(s)
if ~strcmpi(e,'.m')
    return;
end

%Expect MDF file to begin with '%%' sign (and non-MDF files to not do so)
fid = fopen(srcName,'r');
C = textscan(fid,'%s','Delimiter','');
C = C{1};
fclose(fid);

if isempty(strfind(lower(C{1}),'machine data file')) && ~isequal(C{1}(1:2),'%%')
    return;
end

%Copy MDF file to target directory
tgtName = getTargetFileDescriptors(srcName,targetPath);
copyfile(srcName,tgtName);


%Insert new MDF vars into file
s = struct();

s.galvoDeviceID = '';
s.galvoChanIDs = [];
s.galvoCmdOutputRate = 5e5;
s.galvoAngle2VoltageFactor = 0.33;
s.galvoAngle2LSMAngleFactor = 1.0;
s.galvoParkAngles = 9;
s.galvoAcceleration = 1;
s.galvoMaxVelocity = 1;

addMDFVars(srcName,tgtName,s);

%Modify MDF vars
modifyMDFVar(srcName,tgtName,'Thorlabs Devices','apiCurrentVersion','1.5');  %Update to ThorAPI 1.5

end


function updatePropSetsToR4p2(srcFileOrName,targetPath)
%Update CFG/USR files to r4.2 from r4.1.0

[srcName,srcFile] = getSourceFileDescriptors(srcFileOrName);
[~,f,e] = fileparts(srcName);

if ~ismember(lower(e),{'.cfg' '.usr'})
    return;
end

[tgtName,tgtFile] = getTargetFileDescriptors(srcFile,targetPath);

%Copy CFG/USR file to target directory
copyfile(srcName,tgtName);

%Update USR files
if strcmpi(e,'.usr')
    addProps(tgtFile,'channelsReadOffsetsOnStartup',false);
end

%Update CFG files
if strcmpi(e,'.cfg')
    addProps(tgtFile,...
        'galvoEnable',false,...
        'mroiParams',struct('scanShift',{},'scanAngleMultiplierSlow',{},'scanLinesPerFrame',{}),...
        'mroiZoomFactor',1,...
        'mroiPixelsPerLine',512,...
        'mroiUpdateMinLines',200,...
        'scanShiftFast',0,...
        'scanShiftSlow',0);
end

%Move properties from CFG file to USR file, as needed
if ~isempty(srcFile)
    moveCfgToUsr(srcFile,targetPath,'channelsAutoReadOffsets',false);
end

end

function copyXMLFiles(srcFileOrName,targetPath)

srcName = getSourceFileDescriptors(srcFileOrName);
[~,f,e] = fileparts(srcName);

if isequal(lower(e),'.xml')
    tgtName = getTargetFileDescriptors(srcName,targetPath);
    copyfile(srcName,tgtName);
end
end





%% MDF Helper Functions
function addMDFVars(srcFileName,tgtFileName,mdfVarStruct)
src = fopen(srcFileName,'r');
tgt = fopen(tgtFileName,'r+');

ME = [];
try
    %Identify section start lines
    sectionStartLines = [];
    scanimageStartLine = [];
    
    lineCnt = 1;
    while ~feof(src)
        s = fgetl(src);
        s = strtrim(s);
        if ischar(s) && length(s) >= 2 && isequal(s(1:2),'%%')
            sectionStartLines(end+1) = lineCnt;
            
            if strfind(s,'ScanImage')
                assert(isempty(scanimageStartLine),'Unexpectedly found more than 1 ScanImage section in Machine Data File');
                scanimageStartLine = lineCnt;
            end
        end
        
        lineCnt = lineCnt + 1;
    end
    
    frewind(src);
    
    %Determine starting line of section after ScanImage in MDF
    idx = find(sectionStartLines == scanimageStartLine);
    if idx == length(sectionStartLines) %ScanImage is last section
        nextSectionLine = inf;
    else
        nextSectionLine = sectionStartLines(idx+1);
    end
    
    %Navigate to end of ScanImage section
    if isinf(nextSectionLine)
        fseek(tgt,0,'eof');
    else
        fseek(tgt,0,'bof');
        for i=1:(nextSectionLine-1)
            tline = fgets(tgt);
        end
        fseek(tgt,0,'cof'); %need to call fseek between text read & write operations
    end
    
    
    %Insert new MDF vars just before next section
    vars = fieldnames(mdfVarStruct);
    for i=1:length(vars)
        var = vars{i};
        fprintf(tgt,'%s = %s;\n',var,mat2str(mdfVarStruct.(var)));
    end
    
    %Fill in remainder sections, if needed
    if isinf(nextSectionLine)
        return;
    end
    
    fprintf(tgt,'\n');
    
    for i=1:(nextSectionLine - 1)
        fgetl(src);
    end
    
    
    numRemainderLines = lineCnt - nextSectionLine + 1;
    for i=1:numRemainderLines
        s = fgetl(src);
        if ischar(s)
            fprintf(tgt,'%s\n',s);
        else
            fprintf(tgt,'%\n');
        end
    end
    
catch MEtemp
    ME = MEtemp;
end

fclose(src);
fclose(tgt);

if ~isempty(ME)
    ME.rethrow();
end


end

function modifyMDFVar(srcFileName,tgtFileName,sectionName,varName,varNewVal)
src = fopen(srcFileName,'r');
tgt = fopen(tgtFileName,'r+');

ME = [];

try
    %Find start of section with variable to modify
    sectionStartLine = findSectionStartLine(tgt,sectionName);
        
    %Navigate to variable within target file
    frewind(tgt);
    for i=1:sectionStartLine
        fgets(tgt);
    end
    
    %numRemainderLines = -1;
    sectionLineNumber = 1;
    while ~feof(tgt)
        s = fgets(tgt);
        
%         if numRemainderLines >= 0
%             numRemainderLines = numRemainderLines + 1;
%         elseif strfind(lower(s),lower(varName))
%             numRemainderLines = 0;
        if strfind(lower(s),lower(varName))
            break;
        elseif feof(tgt)
            error('Failed to find variable ''%s'' in specified section ''%s''\n',varName,sectionName);
        else
            sectionLineNumber = sectionLineNumber + 1;
            continue;
        end
        
    end
    
%     if numRemainderLines == -1
%         error('Failed to find variable ''%s'' in specified section ''%s''\n',varName,sectionName);
%     end
    
    %Store line to modify & remainder lines
    frewind(tgt);
    
    for i=1:(sectionStartLine + sectionLineNumber - 1) %Skip preceding lines
        fgets(tgt);
    end
    
    oldLine = fgets(tgt); %Capture line to modify
    
%     remLines = cell(numRemainderLines,1); %Get remainder lines
%     for i = 1:numRemainderLines
%         remLines{i} = fgetl(tgt);
%     end
    
    %Modify targeted variable
    frewind(tgt);
    for i=1:(sectionStartLine + sectionLineNumber - 1) %Skip preceding lines
        s = fgets(tgt);
    end
    
    equalIdx = find(oldLine == '=');
    
    newLineLHS = oldLine(1:equalIdx-1);
    newLineRHS = oldLine(equalIdx+1:end);
    szRHS = length(newLineRHS);
    
    newLineRHS = [' ' mat2str(varNewVal) ';' blanks(szRHS-1) '\n'];
    
    newLine = [newLineLHS '=' newLineRHS];
    
    
    fseek(tgt,0,'cof'); %need to call fseek between text read & write operations
    fprintf(tgt,'%s',newLine);
    
%     %Re-write remainder lines
%     for i=1:numRemainderLines
%         fprintf(tgt,'%s\n',remLines{i});
%     end
    
catch MEtemp
    ME = MEtemp;
end

fclose(src);
fclose(tgt);

if ~isempty(ME)
    ME.rethrow();
end



end

function sectionStartLine = findSectionStartLine(src,sectionName)
%Identify section start lines

sectionStartLines = [];
sectionStartLine = [];

lineCnt = 1;
while ~feof(src)
    s = fgetl(src);
    s = strtrim(s);
    if ischar(s) && length(s) >= 2 && isequal(s(1:2),'%%')
        sectionStartLines(end+1) = lineCnt;
        
        if strfind(s,sectionName)
            assert(isempty(sectionStartLine),'Unexpectedly found more than 1 line indicating start of ''%s'' section in Machine Data File',sectionStartLine);
            sectionStartLine = lineCnt;
        end
    end
    
    lineCnt = lineCnt + 1;
end

frewind(src);

end

%% PROPSET (CFG/USR) HELPER FUNCTIONS
function addProps(hTgt,newProp1,newPropVal1,varargin)
assert(mod(length(varargin),2) == 0 && (isempty(varargin) || iscellstr(varargin(1:2:end))),...
    'Arguments were not supplied correctly as prop-val pairs');

newProps = [{newProp1} varargin(1:2:end)];
newPropVals = [{newPropVal1} varargin(2:2:end)];


s = hTgt.scanimage_SI4;
for i=1:length(newProps)
    if ~isfield(s,newProps{i})
        s.(newProps{i}) = newPropVals{i}; %Add field with default value
        fprintf('Added prop ''%s'' to file ''%s''\n',newProps{i},hTgt.Properties.Source);
    end
end

hTgt.scanimage_SI4 = s;
end

function removeProps(hTgt,oldProps)
s = hTgt.scanimage_SI4;

propsToRemove = intersect(fieldnames(s),oldProps);
s = rmfield(s,propsToRemove);

for i=1:length(propsToRemove)
    fprintf('Removed prop ''%s'' from file ''%s''\n',propsToRemove{i},hTgt.Properties.Source);
end

hTgt.scanimage_SI4 = s;
end


function moveCfgToUsr(srcFile,targetPath,propName,defaultVal)
%Function that will remove specified property from CFG file while adding it to USR files (with specified default value)

assert(ischar(propName) && isvector(propName),'Argument ''propName'' must be a string');

[~,~,e] = fileparts(srcFile.Properties.Source);

[~,tgtFile] = getTargetFileDescriptors(srcFile,targetPath);


if strcmpi(e,'.cfg')
    removeProps(tgtFile,propName);
end

if strcmpi(e,'.usr')
    addProps(tgtFile,propName,defaultVal);
end

end

%% GENERAL HELPER FUNCTIONS
function verTag = getVersionTag(ver)

verTag = num2str(ver.major);

if ~isempty(ver.minor)
    verTag = [verTag '.' num2str(ver.minor)];
end

end


function [srcName,srcFile] = getSourceFileDescriptors(srcFileOrName)
%Return srcFile & srcName from supplied MAT file or name

if isa(srcFileOrName,'matlab.io.MatFile')
    srcFile = srcFileOrName;
    srcName = srcFile.Properties.Source;
else
    srcFile = [];
    srcName = srcFileOrName;
end

end

function [tgtName,tgtFile] = getTargetFileDescriptors(srcFileOrName, targetPath)
%Get target filename and target MAT file object (for USR/CFG file
%updates) for given source MAT file or source filename


[srcName,srcFile] = getSourceFileDescriptors(srcFileOrName);

[~,sp,se] = fileparts(srcName);

tgtName = fullfile(targetPath,[sp se]);

if isempty(srcFile) %Not a MAT source
    tgtFile = [];
else
    tgtFile = matfile(tgtName,'Writable',true);
end

end






