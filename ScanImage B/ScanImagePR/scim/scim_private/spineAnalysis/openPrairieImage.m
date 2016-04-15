% openPrairieImage - Loads an image stack acquired using a Prairie Instruments microscope.
%
% SYNTAX
%  cdata = openPrairieImage(filename)
%   filename - The stack's XML file to be opened.
%   cdata - The image data, in a format similar to that returned by genericOpenTif when opening ScanImage files.
%           If multiple channels of data exist, it is automatically split into cell arrays.
%
% NOTES
%  The first approach taken was to use a regular expression to do the parsing.
%  For some reason, the regular expressions were producing unexpected results.
%  Specifically, they were arbitrarily dependent upon whitespace despite the regular expression 
%  appearing to be well formed and tolerant of whitespace. This approach was abandoned, and the 
%  behavior of the regexp was left as a mystery (after letting a few others review it, as a sanity check).
%  Some of the regular expressions tried looked like this:
%    '<File\s+channel="\d+"\s+filename="(?<filename>.+)"\s+/>.*'
%    '<Frame\s+(?<frameparameters>.+)>(?<childtags>.+)\s+</Frame>'
%
%  In the case of multichannel images, there may be some sorting needed, based on each frame's index.
%  Without a sample of such an image, it's unclear how things may be organized. For now, just assume
%  each channel's frames are listed in order, and split them out as they are encountered.
%
%  See the end of this file for sample XML.
%
% Created - Timothy O'Connor 8/19/08
% Copyright - Linda Wilbrecht/UCSF 2008
function cdata = openPrairieImage(filename)

%Sanity check the file we're opening.
if exist(filename, 'file') ~= 2
    error('File ''%s'' not found.', filename);
end
if ~endsWithIgnoreCase(filename, '.xml')
    fprintf(2, 'openPrairieImage: Warning - To open a Prairie image, the stack''s XML file must be specified.\n''%s'' does not appear to be an XML file.\n', filename);
end

%Open the file.
fid = fopen(filename, 'r');
if fid == -1
    error('Failed to open file ''%s'' - %s', filename, lasterr);
end

%Read the XML data for the file.
xmlStr = '';
s = fgets(fid);
while s ~= -1
    xmlStr = [xmlStr, s];
    s = fgets(fid);
end

%We're done with the file, close it.
fclose(fid);

%Get the path to the XML file, which we'll need to find the frame files.
stackPath = fileparts(filename);

quoteIndices = findstr(xmlStr, '"');%Cache this, for speed.

%Figure out how many channels are stored in this stack.
channelStrings = getAllParams(xmlStr, 'channel', quoteIndices);
channels = ones(size(channelStrings));
for i = 1 : length(channelStrings)
    channels(i) = str2double(channelStrings{i});
end
numberOfChannels = length(unique(channels));
if numberOfChannels == 1
    cdata = [];
else
    cdata = cell(numberOfChannels, 1);
end

%Get a list of all the corresponding files.
filenames = getAllParams(xmlStr, 'filename', quoteIndices);

%Pop up a progress bar, to mimick genericOpenTif.m's behavior.
wb = waitbar(0, 'Loading Prairie image stack...', 'Name', 'Loading Prairie image stack...', 'NumberTitle', 'Off');

%Dole out the data into the cdata array.
for i = 1 : length(filenames)
    waitbar(i / length(filenames), wb, ['Loading frame ' num2str(i)]);
	imdata = imread(fullfile(stackPath, filenames{i}));
    if numberOfChannels == 1
        cdata(:, :, i) = imdata;
    else
        cdata{channels(i)}(:, :, i) = imdata;
    end
end

delete(wb);

return;

%--------------------------------------------------------
%Returns a cell array of strings, with each string containing an occurrence the entire named tag, including the closing tag.
function tags = getTags(str, tagName)

%Find all occurrences of the tag name.
startIndices = strfind(str, ['<' tagName]);
if isempty(startIndices)
    error('Tag ''%s'' not found.', tagName);
end

%Find all occurrences of the associated closing tag.
endIndices = strfind(str, ['</' tagName '>']);
if isempty(endIndices)
    warning('No closing tags found for ''%s''.', tagName);
    endIndices = length(str);%Just try to grab the whole thing.
elseif length(endIndices) ~= length(startIndices)
    warning('Number of closing tags (%s) for ''%s'' do not match the number of starting tags (%s).', tagName, num2str(length(endIndices)), num2str(length(startIndices)));
    %Don't bother trying to handle this, although we could do it reasonably anyway. It's not worth the effort now.
end

%Portion out the string into a cell array, with each cell containing one tag (possibly discarding excess whitespace.
endTagOffset = 2 + length(tagName);
tags = cell(size(startIndices));
for i = 1 : length(tags)
    tags{i} = str(startIndices(i) : endIndices(i) + endTagOffset);
end

return;

%--------------------------------------------------------
%Returns the value for the specified XML parameter.
%There must be only one occurrence of the parameter within the specified string.
function paramVal = getParam(str, paramName)

%Find the parameter name.
startIndex = findstr(str, [paramName '="']);
if isempty(startIndex)
    error('XML parameter ''%s'' not found.', paramName);
elseif length(startIndex) > 1
    error('Multiple occurrences of XML parameter ''%s'' found, when only one is expected.', paramName);
end

paramStartOffset = length(paramName) + 2;

%Search for the closing quote.
endIndex = startIndex + paramStartOffset + 1;
for i = endIndex : length(str)
    if str(i) == '"'
        break;
    end
    endIndex = i;
end

%Extract the value.
paramVal = str(startIndex + paramStartOffset : endIndex - 1);

return;

%--------------------------------------------------------
%Returns the values for the specified XML parameter.
%There may be multiple occurrences of the parameter within the specified string.
%Optionally take the quoteIndices as an argument, so it can be cached for efficiency.
function params = getAllParams(str, paramName, varargin)

%Find all occurrences of the parameter name.
startIndices = findstr(str, [paramName '="']);
if isempty(startIndices)
    error('XML parameter ''%s'' not found.', paramName);
end

%It should be faster to find all '"' chars, than to individually scan for each one, assuming there are many.
if isempty(varargin)
    quoteIndices = findstr(str, '"');
else
    quoteIndices = findstr(str, '"');
end
paramStartOffset = length(paramName) + 2;

%Break out all the values into the cell array.
params = cell(size(startIndices));
for i = 1 : length(startIndices)
    subsequentQuotes = quoteIndices(quoteIndices > startIndices(i) + paramStartOffset);
    params{i} = str(startIndices(i) + paramStartOffset : subsequentQuotes(1) - 1);
end

return;

%--------------------------------------------------------
%This test code is useful for generating a single frame's string (based on a variable 'index'):
% frameString = ['    <Frame relativeTime="23.9368879999997" absoluteTime="24.2488629999998" index="' num2str(index) '" label="CurrentSettings">'];
% frameString = sprintf('%s\n%s', frameString, '      <File channel="1" filename="ZSeries-05192008-1505-005_Cycle001_CurrentSettings_Ch1_000013.tif" />');
% frameString = sprintf('%s\n%s', frameString, '      <ExtraParameters validData="True" />');
% frameString = sprintf('%s\n%s', frameString, '      <PVStateShard>');
% frameString = sprintf('%s\n%s', frameString, '        <Key key="objectiveLens" permissions="Read, Write, Save" value="Olympus 40X" />');
% frameString = sprintf('%s\n%s', frameString, '        <Key key="objectiveLensNA" permissions="Read, Write, Save" value="0.8" />');
% frameString = sprintf('%s\n%s', frameString, '        <Key key="objectiveLensMag" permissions="Read, Write, Save" value="40" />');
% frameString = sprintf('%s\n%s', frameString, '        <Key key="pixelsPerLine" permissions="Read, Write, Save" value="512" />');
% frameString = sprintf('%s\n%s', frameString, '        <Key key="linesPerFrame" permissions="Read, Write, Save" value="512" />');
% frameString = sprintf('%s\n%s', frameString, '        <Key key="systemType" permissions="Write, Save" value="3" />');
% frameString = sprintf('%s\n%s', frameString, '        <Key key="binningMode" permissions="Read, Write, Save" value="0" />');
% frameString = sprintf('%s\n%s', frameString, '        <Key key="frameAveraging" permissions="Read, Write, Save" value="1" />');
% frameString = sprintf('%s\n%s', frameString, '      </PVStateShard>');
% frameString = sprintf('%s\n%s', frameString, '    </Frame>');

%--------------------------------------------------------
%Here's a sample of what the XML should look like:
% ?<?xml version="1.0" encoding="utf-8"?>
% <PVScan version="3.0.0.3" date="5/19/2008 3:58:09 PM" notes="">
%   <Sequence type="ZSeries" cycle="1">
%     <Frame relativeTime="0" absoluteTime="0.311975000000075" index="1" label="CurrentSettings">
%       <File channel="1" filename="ZSeries-05192008-1505-005_Cycle001_CurrentSettings_Ch1_000001.tif" />
%       <ExtraParameters validData="True" />
%       <PVStateShard>
%         <Key key="objectiveLens" permissions="Read, Write, Save" value="Olympus 40X" />
%         <Key key="objectiveLensNA" permissions="Read, Write, Save" value="0.8" />
%         <Key key="objectiveLensMag" permissions="Read, Write, Save" value="40" />
%         <Key key="pixelsPerLine" permissions="Read, Write, Save" value="512" />
%         <Key key="linesPerFrame" permissions="Read, Write, Save" value="512" />
%         <Key key="systemType" permissions="Write, Save" value="3" />
%         <Key key="binningMode" permissions="Read, Write, Save" value="0" />
%         <Key key="frameAveraging" permissions="Read, Write, Save" value="1" />
%         <Key key="framePeriod" permissions="Read, Write, Save" value="1.380352" />
%         <Key key="scanlinePeriod" permissions="Read, Write, Save" value="0.002696" />
%         <Key key="dwellTime" permissions="Read, Write, Save" value="4.0" />
%         <Key key="positionCurrent_XAxis" permissions="Write, Save" value="-1320.625" />
%         <Key key="positionCurrent_YAxis" permissions="Write, Save" value="532.5" />
%         <Key key="positionCurrent_ZAxis" permissions="Write, Save" value="5.2875" />
%         <Key key="zDevice" permissions="Write, Save" value="0" />
%         <Key key="rotation" permissions="Read, Write, Save" value="0" />
%         <Key key="opticalZoom" permissions="Read, Write, Save" value="1.0" />
%         <Key key="micronsPerPixel_XAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="micronsPerPixel_YAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="pmtGain_0" permissions="Write, Save" value="637.5" />
%         <Key key="pmtGain_1" permissions="Write, Save" value="0" />
%         <Key key="pmtGain_2" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_0" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_1" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_2" permissions="Write, Save" value="0" />
%         <Key key="laserPower_0" permissions="Write, Save" value="10" />
%         <Key key="laserWavelength_0" permissions="Write, Save" value="820" />
%         <Key key="twophotonLaserPower_0" permissions="Write, Save" value="3672" />
%         <Key key="preAmpGain_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_3" permissions="Write, Save" value="4" />
%       </PVStateShard>
%     </Frame>
%     <Frame relativeTime="1.98430099999996" absoluteTime="2.29627600000003" index="2" label="CurrentSettings">
%       <File channel="1" filename="ZSeries-05192008-1505-005_Cycle001_CurrentSettings_Ch1_000002.tif" />
%       <ExtraParameters validData="True" />
%       <PVStateShard>
%         <Key key="objectiveLens" permissions="Read, Write, Save" value="Olympus 40X" />
%         <Key key="objectiveLensNA" permissions="Read, Write, Save" value="0.8" />
%         <Key key="objectiveLensMag" permissions="Read, Write, Save" value="40" />
%         <Key key="pixelsPerLine" permissions="Read, Write, Save" value="512" />
%         <Key key="linesPerFrame" permissions="Read, Write, Save" value="512" />
%         <Key key="systemType" permissions="Write, Save" value="3" />
%         <Key key="binningMode" permissions="Read, Write, Save" value="0" />
%         <Key key="frameAveraging" permissions="Read, Write, Save" value="1" />
%         <Key key="framePeriod" permissions="Read, Write, Save" value="1.380352" />
%         <Key key="scanlinePeriod" permissions="Read, Write, Save" value="0.002696" />
%         <Key key="dwellTime" permissions="Read, Write, Save" value="4.0" />
%         <Key key="positionCurrent_XAxis" permissions="Write, Save" value="-1320.625" />
%         <Key key="positionCurrent_YAxis" permissions="Write, Save" value="532.5" />
%         <Key key="positionCurrent_ZAxis" permissions="Write, Save" value="2.2875" />
%         <Key key="zDevice" permissions="Write, Save" value="0" />
%         <Key key="rotation" permissions="Read, Write, Save" value="0" />
%         <Key key="opticalZoom" permissions="Read, Write, Save" value="1.0" />
%         <Key key="micronsPerPixel_XAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="micronsPerPixel_YAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="pmtGain_0" permissions="Write, Save" value="641.666666666667" />
%         <Key key="pmtGain_1" permissions="Write, Save" value="0" />
%         <Key key="pmtGain_2" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_0" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_1" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_2" permissions="Write, Save" value="0" />
%         <Key key="laserPower_0" permissions="Write, Save" value="10" />
%         <Key key="laserWavelength_0" permissions="Write, Save" value="820" />
%         <Key key="twophotonLaserPower_0" permissions="Write, Save" value="3671" />
%         <Key key="preAmpGain_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_3" permissions="Write, Save" value="4" />
%       </PVStateShard>
%     </Frame>
%     <Frame relativeTime="3.98425399999996" absoluteTime="4.29622900000004" index="3" label="CurrentSettings">
%       <File channel="1" filename="ZSeries-05192008-1505-005_Cycle001_CurrentSettings_Ch1_000003.tif" />
%       <ExtraParameters validData="True" />
%       <PVStateShard>
%         <Key key="objectiveLens" permissions="Read, Write, Save" value="Olympus 40X" />
%         <Key key="objectiveLensNA" permissions="Read, Write, Save" value="0.8" />
%         <Key key="objectiveLensMag" permissions="Read, Write, Save" value="40" />
%         <Key key="pixelsPerLine" permissions="Read, Write, Save" value="512" />
%         <Key key="linesPerFrame" permissions="Read, Write, Save" value="512" />
%         <Key key="systemType" permissions="Write, Save" value="3" />
%         <Key key="binningMode" permissions="Read, Write, Save" value="0" />
%         <Key key="frameAveraging" permissions="Read, Write, Save" value="1" />
%         <Key key="framePeriod" permissions="Read, Write, Save" value="1.380352" />
%         <Key key="scanlinePeriod" permissions="Read, Write, Save" value="0.002696" />
%         <Key key="dwellTime" permissions="Read, Write, Save" value="4.0" />
%         <Key key="positionCurrent_XAxis" permissions="Write, Save" value="-1320.625" />
%         <Key key="positionCurrent_YAxis" permissions="Write, Save" value="532.5" />
%         <Key key="positionCurrent_ZAxis" permissions="Write, Save" value="-0.7125" />
%         <Key key="zDevice" permissions="Write, Save" value="0" />
%         <Key key="rotation" permissions="Read, Write, Save" value="0" />
%         <Key key="opticalZoom" permissions="Read, Write, Save" value="1.0" />
%         <Key key="micronsPerPixel_XAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="micronsPerPixel_YAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="pmtGain_0" permissions="Write, Save" value="645.833333333333" />
%         <Key key="pmtGain_1" permissions="Write, Save" value="0" />
%         <Key key="pmtGain_2" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_0" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_1" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_2" permissions="Write, Save" value="0" />
%         <Key key="laserPower_0" permissions="Write, Save" value="10" />
%         <Key key="laserWavelength_0" permissions="Write, Save" value="820" />
%         <Key key="twophotonLaserPower_0" permissions="Write, Save" value="3672" />
%         <Key key="preAmpGain_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_3" permissions="Write, Save" value="4" />
%       </PVStateShard>
%     </Frame>
%     <Frame relativeTime="5.96859399999994" absoluteTime="6.28056900000001" index="4" label="CurrentSettings">
%       <File channel="1" filename="ZSeries-05192008-1505-005_Cycle001_CurrentSettings_Ch1_000004.tif" />
%       <ExtraParameters validData="True" />
%       <PVStateShard>
%         <Key key="objectiveLens" permissions="Read, Write, Save" value="Olympus 40X" />
%         <Key key="objectiveLensNA" permissions="Read, Write, Save" value="0.8" />
%         <Key key="objectiveLensMag" permissions="Read, Write, Save" value="40" />
%         <Key key="pixelsPerLine" permissions="Read, Write, Save" value="512" />
%         <Key key="linesPerFrame" permissions="Read, Write, Save" value="512" />
%         <Key key="systemType" permissions="Write, Save" value="3" />
%         <Key key="binningMode" permissions="Read, Write, Save" value="0" />
%         <Key key="frameAveraging" permissions="Read, Write, Save" value="1" />
%         <Key key="framePeriod" permissions="Read, Write, Save" value="1.380352" />
%         <Key key="scanlinePeriod" permissions="Read, Write, Save" value="0.002696" />
%         <Key key="dwellTime" permissions="Read, Write, Save" value="4.0" />
%         <Key key="positionCurrent_XAxis" permissions="Write, Save" value="-1320.625" />
%         <Key key="positionCurrent_YAxis" permissions="Write, Save" value="532.5" />
%         <Key key="positionCurrent_ZAxis" permissions="Write, Save" value="-3.7125" />
%         <Key key="zDevice" permissions="Write, Save" value="0" />
%         <Key key="rotation" permissions="Read, Write, Save" value="0" />
%         <Key key="opticalZoom" permissions="Read, Write, Save" value="1.0" />
%         <Key key="micronsPerPixel_XAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="micronsPerPixel_YAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="pmtGain_0" permissions="Write, Save" value="650" />
%         <Key key="pmtGain_1" permissions="Write, Save" value="0" />
%         <Key key="pmtGain_2" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_0" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_1" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_2" permissions="Write, Save" value="0" />
%         <Key key="laserPower_0" permissions="Write, Save" value="10" />
%         <Key key="laserWavelength_0" permissions="Write, Save" value="820" />
%         <Key key="twophotonLaserPower_0" permissions="Write, Save" value="3673" />
%         <Key key="preAmpGain_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_3" permissions="Write, Save" value="4" />
%       </PVStateShard>
%     </Frame>
%     <Frame relativeTime="7.96857899999986" absoluteTime="8.28055399999994" index="5" label="CurrentSettings">
%       <File channel="1" filename="ZSeries-05192008-1505-005_Cycle001_CurrentSettings_Ch1_000005.tif" />
%       <ExtraParameters validData="True" />
%       <PVStateShard>
%         <Key key="objectiveLens" permissions="Read, Write, Save" value="Olympus 40X" />
%         <Key key="objectiveLensNA" permissions="Read, Write, Save" value="0.8" />
%         <Key key="objectiveLensMag" permissions="Read, Write, Save" value="40" />
%         <Key key="pixelsPerLine" permissions="Read, Write, Save" value="512" />
%         <Key key="linesPerFrame" permissions="Read, Write, Save" value="512" />
%         <Key key="systemType" permissions="Write, Save" value="3" />
%         <Key key="binningMode" permissions="Read, Write, Save" value="0" />
%         <Key key="frameAveraging" permissions="Read, Write, Save" value="1" />
%         <Key key="framePeriod" permissions="Read, Write, Save" value="1.380352" />
%         <Key key="scanlinePeriod" permissions="Read, Write, Save" value="0.002696" />
%         <Key key="dwellTime" permissions="Read, Write, Save" value="4.0" />
%         <Key key="positionCurrent_XAxis" permissions="Write, Save" value="-1320.625" />
%         <Key key="positionCurrent_YAxis" permissions="Write, Save" value="532.5" />
%         <Key key="positionCurrent_ZAxis" permissions="Write, Save" value="-6.7125" />
%         <Key key="zDevice" permissions="Write, Save" value="0" />
%         <Key key="rotation" permissions="Read, Write, Save" value="0" />
%         <Key key="opticalZoom" permissions="Read, Write, Save" value="1.0" />
%         <Key key="micronsPerPixel_XAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="micronsPerPixel_YAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="pmtGain_0" permissions="Write, Save" value="654.166666666667" />
%         <Key key="pmtGain_1" permissions="Write, Save" value="0" />
%         <Key key="pmtGain_2" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_0" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_1" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_2" permissions="Write, Save" value="0" />
%         <Key key="laserPower_0" permissions="Write, Save" value="10" />
%         <Key key="laserWavelength_0" permissions="Write, Save" value="820" />
%         <Key key="twophotonLaserPower_0" permissions="Write, Save" value="3670" />
%         <Key key="preAmpGain_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_3" permissions="Write, Save" value="4" />
%       </PVStateShard>
%     </Frame>
%     <Frame relativeTime="9.96854699999994" absoluteTime="10.280522" index="6" label="CurrentSettings">
%       <File channel="1" filename="ZSeries-05192008-1505-005_Cycle001_CurrentSettings_Ch1_000006.tif" />
%       <ExtraParameters validData="True" />
%       <PVStateShard>
%         <Key key="objectiveLens" permissions="Read, Write, Save" value="Olympus 40X" />
%         <Key key="objectiveLensNA" permissions="Read, Write, Save" value="0.8" />
%         <Key key="objectiveLensMag" permissions="Read, Write, Save" value="40" />
%         <Key key="pixelsPerLine" permissions="Read, Write, Save" value="512" />
%         <Key key="linesPerFrame" permissions="Read, Write, Save" value="512" />
%         <Key key="systemType" permissions="Write, Save" value="3" />
%         <Key key="binningMode" permissions="Read, Write, Save" value="0" />
%         <Key key="frameAveraging" permissions="Read, Write, Save" value="1" />
%         <Key key="framePeriod" permissions="Read, Write, Save" value="1.380352" />
%         <Key key="scanlinePeriod" permissions="Read, Write, Save" value="0.002696" />
%         <Key key="dwellTime" permissions="Read, Write, Save" value="4.0" />
%         <Key key="positionCurrent_XAxis" permissions="Write, Save" value="-1320.625" />
%         <Key key="positionCurrent_YAxis" permissions="Write, Save" value="532.5" />
%         <Key key="positionCurrent_ZAxis" permissions="Write, Save" value="-9.7125" />
%         <Key key="zDevice" permissions="Write, Save" value="0" />
%         <Key key="rotation" permissions="Read, Write, Save" value="0" />
%         <Key key="opticalZoom" permissions="Read, Write, Save" value="1.0" />
%         <Key key="micronsPerPixel_XAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="micronsPerPixel_YAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="pmtGain_0" permissions="Write, Save" value="658.333333333333" />
%         <Key key="pmtGain_1" permissions="Write, Save" value="0" />
%         <Key key="pmtGain_2" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_0" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_1" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_2" permissions="Write, Save" value="0" />
%         <Key key="laserPower_0" permissions="Write, Save" value="10" />
%         <Key key="laserWavelength_0" permissions="Write, Save" value="820" />
%         <Key key="twophotonLaserPower_0" permissions="Write, Save" value="3672" />
%         <Key key="preAmpGain_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_3" permissions="Write, Save" value="4" />
%       </PVStateShard>
%     </Frame>
%     <Frame relativeTime="11.9528029999997" absoluteTime="12.2647779999998" index="7" label="CurrentSettings">
%       <File channel="1" filename="ZSeries-05192008-1505-005_Cycle001_CurrentSettings_Ch1_000007.tif" />
%       <ExtraParameters validData="True" />
%       <PVStateShard>
%         <Key key="objectiveLens" permissions="Read, Write, Save" value="Olympus 40X" />
%         <Key key="objectiveLensNA" permissions="Read, Write, Save" value="0.8" />
%         <Key key="objectiveLensMag" permissions="Read, Write, Save" value="40" />
%         <Key key="pixelsPerLine" permissions="Read, Write, Save" value="512" />
%         <Key key="linesPerFrame" permissions="Read, Write, Save" value="512" />
%         <Key key="systemType" permissions="Write, Save" value="3" />
%         <Key key="binningMode" permissions="Read, Write, Save" value="0" />
%         <Key key="frameAveraging" permissions="Read, Write, Save" value="1" />
%         <Key key="framePeriod" permissions="Read, Write, Save" value="1.380352" />
%         <Key key="scanlinePeriod" permissions="Read, Write, Save" value="0.002696" />
%         <Key key="dwellTime" permissions="Read, Write, Save" value="4.0" />
%         <Key key="positionCurrent_XAxis" permissions="Write, Save" value="-1320.625" />
%         <Key key="positionCurrent_YAxis" permissions="Write, Save" value="532.5" />
%         <Key key="positionCurrent_ZAxis" permissions="Write, Save" value="-12.7125" />
%         <Key key="zDevice" permissions="Write, Save" value="0" />
%         <Key key="rotation" permissions="Read, Write, Save" value="0" />
%         <Key key="opticalZoom" permissions="Read, Write, Save" value="1.0" />
%         <Key key="micronsPerPixel_XAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="micronsPerPixel_YAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="pmtGain_0" permissions="Write, Save" value="662.5" />
%         <Key key="pmtGain_1" permissions="Write, Save" value="0" />
%         <Key key="pmtGain_2" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_0" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_1" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_2" permissions="Write, Save" value="0" />
%         <Key key="laserPower_0" permissions="Write, Save" value="10" />
%         <Key key="laserWavelength_0" permissions="Write, Save" value="820" />
%         <Key key="twophotonLaserPower_0" permissions="Write, Save" value="3672" />
%         <Key key="preAmpGain_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_3" permissions="Write, Save" value="4" />
%       </PVStateShard>
%     </Frame>
%     <Frame relativeTime="13.9527579999999" absoluteTime="14.264733" index="8" label="CurrentSettings">
%       <File channel="1" filename="ZSeries-05192008-1505-005_Cycle001_CurrentSettings_Ch1_000008.tif" />
%       <ExtraParameters validData="True" />
%       <PVStateShard>
%         <Key key="objectiveLens" permissions="Read, Write, Save" value="Olympus 40X" />
%         <Key key="objectiveLensNA" permissions="Read, Write, Save" value="0.8" />
%         <Key key="objectiveLensMag" permissions="Read, Write, Save" value="40" />
%         <Key key="pixelsPerLine" permissions="Read, Write, Save" value="512" />
%         <Key key="linesPerFrame" permissions="Read, Write, Save" value="512" />
%         <Key key="systemType" permissions="Write, Save" value="3" />
%         <Key key="binningMode" permissions="Read, Write, Save" value="0" />
%         <Key key="frameAveraging" permissions="Read, Write, Save" value="1" />
%         <Key key="framePeriod" permissions="Read, Write, Save" value="1.380352" />
%         <Key key="scanlinePeriod" permissions="Read, Write, Save" value="0.002696" />
%         <Key key="dwellTime" permissions="Read, Write, Save" value="4.0" />
%         <Key key="positionCurrent_XAxis" permissions="Write, Save" value="-1320.625" />
%         <Key key="positionCurrent_YAxis" permissions="Write, Save" value="532.5" />
%         <Key key="positionCurrent_ZAxis" permissions="Write, Save" value="-15.7125" />
%         <Key key="zDevice" permissions="Write, Save" value="0" />
%         <Key key="rotation" permissions="Read, Write, Save" value="0" />
%         <Key key="opticalZoom" permissions="Read, Write, Save" value="1.0" />
%         <Key key="micronsPerPixel_XAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="micronsPerPixel_YAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="pmtGain_0" permissions="Write, Save" value="666.666666666667" />
%         <Key key="pmtGain_1" permissions="Write, Save" value="0" />
%         <Key key="pmtGain_2" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_0" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_1" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_2" permissions="Write, Save" value="0" />
%         <Key key="laserPower_0" permissions="Write, Save" value="10" />
%         <Key key="laserWavelength_0" permissions="Write, Save" value="820" />
%         <Key key="twophotonLaserPower_0" permissions="Write, Save" value="3671" />
%         <Key key="preAmpGain_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_3" permissions="Write, Save" value="4" />
%       </PVStateShard>
%     </Frame>
%     <Frame relativeTime="15.9527039999998" absoluteTime="16.2646789999999" index="9" label="CurrentSettings">
%       <File channel="1" filename="ZSeries-05192008-1505-005_Cycle001_CurrentSettings_Ch1_000009.tif" />
%       <ExtraParameters validData="True" />
%       <PVStateShard>
%         <Key key="objectiveLens" permissions="Read, Write, Save" value="Olympus 40X" />
%         <Key key="objectiveLensNA" permissions="Read, Write, Save" value="0.8" />
%         <Key key="objectiveLensMag" permissions="Read, Write, Save" value="40" />
%         <Key key="pixelsPerLine" permissions="Read, Write, Save" value="512" />
%         <Key key="linesPerFrame" permissions="Read, Write, Save" value="512" />
%         <Key key="systemType" permissions="Write, Save" value="3" />
%         <Key key="binningMode" permissions="Read, Write, Save" value="0" />
%         <Key key="frameAveraging" permissions="Read, Write, Save" value="1" />
%         <Key key="framePeriod" permissions="Read, Write, Save" value="1.380352" />
%         <Key key="scanlinePeriod" permissions="Read, Write, Save" value="0.002696" />
%         <Key key="dwellTime" permissions="Read, Write, Save" value="4.0" />
%         <Key key="positionCurrent_XAxis" permissions="Write, Save" value="-1320.625" />
%         <Key key="positionCurrent_YAxis" permissions="Write, Save" value="532.5" />
%         <Key key="positionCurrent_ZAxis" permissions="Write, Save" value="-18.7125" />
%         <Key key="zDevice" permissions="Write, Save" value="0" />
%         <Key key="rotation" permissions="Read, Write, Save" value="0" />
%         <Key key="opticalZoom" permissions="Read, Write, Save" value="1.0" />
%         <Key key="micronsPerPixel_XAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="micronsPerPixel_YAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="pmtGain_0" permissions="Write, Save" value="670.833333333333" />
%         <Key key="pmtGain_1" permissions="Write, Save" value="0" />
%         <Key key="pmtGain_2" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_0" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_1" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_2" permissions="Write, Save" value="0" />
%         <Key key="laserPower_0" permissions="Write, Save" value="10" />
%         <Key key="laserWavelength_0" permissions="Write, Save" value="820" />
%         <Key key="twophotonLaserPower_0" permissions="Write, Save" value="3673" />
%         <Key key="preAmpGain_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_3" permissions="Write, Save" value="4" />
%       </PVStateShard>
%     </Frame>
%     <Frame relativeTime="17.9526599999999" absoluteTime="18.264635" index="10" label="CurrentSettings">
%       <File channel="1" filename="ZSeries-05192008-1505-005_Cycle001_CurrentSettings_Ch1_000010.tif" />
%       <ExtraParameters validData="True" />
%       <PVStateShard>
%         <Key key="objectiveLens" permissions="Read, Write, Save" value="Olympus 40X" />
%         <Key key="objectiveLensNA" permissions="Read, Write, Save" value="0.8" />
%         <Key key="objectiveLensMag" permissions="Read, Write, Save" value="40" />
%         <Key key="pixelsPerLine" permissions="Read, Write, Save" value="512" />
%         <Key key="linesPerFrame" permissions="Read, Write, Save" value="512" />
%         <Key key="systemType" permissions="Write, Save" value="3" />
%         <Key key="binningMode" permissions="Read, Write, Save" value="0" />
%         <Key key="frameAveraging" permissions="Read, Write, Save" value="1" />
%         <Key key="framePeriod" permissions="Read, Write, Save" value="1.380352" />
%         <Key key="scanlinePeriod" permissions="Read, Write, Save" value="0.002696" />
%         <Key key="dwellTime" permissions="Read, Write, Save" value="4.0" />
%         <Key key="positionCurrent_XAxis" permissions="Write, Save" value="-1320.625" />
%         <Key key="positionCurrent_YAxis" permissions="Write, Save" value="532.5" />
%         <Key key="positionCurrent_ZAxis" permissions="Write, Save" value="-21.7125" />
%         <Key key="zDevice" permissions="Write, Save" value="0" />
%         <Key key="rotation" permissions="Read, Write, Save" value="0" />
%         <Key key="opticalZoom" permissions="Read, Write, Save" value="1.0" />
%         <Key key="micronsPerPixel_XAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="micronsPerPixel_YAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="pmtGain_0" permissions="Write, Save" value="675" />
%         <Key key="pmtGain_1" permissions="Write, Save" value="0" />
%         <Key key="pmtGain_2" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_0" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_1" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_2" permissions="Write, Save" value="0" />
%         <Key key="laserPower_0" permissions="Write, Save" value="10" />
%         <Key key="laserWavelength_0" permissions="Write, Save" value="820" />
%         <Key key="twophotonLaserPower_0" permissions="Write, Save" value="3670" />
%         <Key key="preAmpGain_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_3" permissions="Write, Save" value="4" />
%       </PVStateShard>
%     </Frame>
%     <Frame relativeTime="19.9526149999997" absoluteTime="20.2645899999998" index="11" label="CurrentSettings">
%       <File channel="1" filename="ZSeries-05192008-1505-005_Cycle001_CurrentSettings_Ch1_000011.tif" />
%       <ExtraParameters validData="True" />
%       <PVStateShard>
%         <Key key="objectiveLens" permissions="Read, Write, Save" value="Olympus 40X" />
%         <Key key="objectiveLensNA" permissions="Read, Write, Save" value="0.8" />
%         <Key key="objectiveLensMag" permissions="Read, Write, Save" value="40" />
%         <Key key="pixelsPerLine" permissions="Read, Write, Save" value="512" />
%         <Key key="linesPerFrame" permissions="Read, Write, Save" value="512" />
%         <Key key="systemType" permissions="Write, Save" value="3" />
%         <Key key="binningMode" permissions="Read, Write, Save" value="0" />
%         <Key key="frameAveraging" permissions="Read, Write, Save" value="1" />
%         <Key key="framePeriod" permissions="Read, Write, Save" value="1.380352" />
%         <Key key="scanlinePeriod" permissions="Read, Write, Save" value="0.002696" />
%         <Key key="dwellTime" permissions="Read, Write, Save" value="4.0" />
%         <Key key="positionCurrent_XAxis" permissions="Write, Save" value="-1320.625" />
%         <Key key="positionCurrent_YAxis" permissions="Write, Save" value="532.5" />
%         <Key key="positionCurrent_ZAxis" permissions="Write, Save" value="-24.7125" />
%         <Key key="zDevice" permissions="Write, Save" value="0" />
%         <Key key="rotation" permissions="Read, Write, Save" value="0" />
%         <Key key="opticalZoom" permissions="Read, Write, Save" value="1.0" />
%         <Key key="micronsPerPixel_XAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="micronsPerPixel_YAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="pmtGain_0" permissions="Write, Save" value="679.166666666666" />
%         <Key key="pmtGain_1" permissions="Write, Save" value="0" />
%         <Key key="pmtGain_2" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_0" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_1" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_2" permissions="Write, Save" value="0" />
%         <Key key="laserPower_0" permissions="Write, Save" value="10" />
%         <Key key="laserWavelength_0" permissions="Write, Save" value="820" />
%         <Key key="twophotonLaserPower_0" permissions="Write, Save" value="3671" />
%         <Key key="preAmpGain_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_3" permissions="Write, Save" value="4" />
%       </PVStateShard>
%     </Frame>
%     <Frame relativeTime="21.9525569999996" absoluteTime="22.2645319999997" index="12" label="CurrentSettings">
%       <File channel="1" filename="ZSeries-05192008-1505-005_Cycle001_CurrentSettings_Ch1_000012.tif" />
%       <ExtraParameters validData="True" />
%       <PVStateShard>
%         <Key key="objectiveLens" permissions="Read, Write, Save" value="Olympus 40X" />
%         <Key key="objectiveLensNA" permissions="Read, Write, Save" value="0.8" />
%         <Key key="objectiveLensMag" permissions="Read, Write, Save" value="40" />
%         <Key key="pixelsPerLine" permissions="Read, Write, Save" value="512" />
%         <Key key="linesPerFrame" permissions="Read, Write, Save" value="512" />
%         <Key key="systemType" permissions="Write, Save" value="3" />
%         <Key key="binningMode" permissions="Read, Write, Save" value="0" />
%         <Key key="frameAveraging" permissions="Read, Write, Save" value="1" />
%         <Key key="framePeriod" permissions="Read, Write, Save" value="1.380352" />
%         <Key key="scanlinePeriod" permissions="Read, Write, Save" value="0.002696" />
%         <Key key="dwellTime" permissions="Read, Write, Save" value="4.0" />
%         <Key key="positionCurrent_XAxis" permissions="Write, Save" value="-1320.625" />
%         <Key key="positionCurrent_YAxis" permissions="Write, Save" value="532.5" />
%         <Key key="positionCurrent_ZAxis" permissions="Write, Save" value="-27.7125" />
%         <Key key="zDevice" permissions="Write, Save" value="0" />
%         <Key key="rotation" permissions="Read, Write, Save" value="0" />
%         <Key key="opticalZoom" permissions="Read, Write, Save" value="1.0" />
%         <Key key="micronsPerPixel_XAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="micronsPerPixel_YAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="pmtGain_0" permissions="Write, Save" value="683.333333333333" />
%         <Key key="pmtGain_1" permissions="Write, Save" value="0" />
%         <Key key="pmtGain_2" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_0" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_1" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_2" permissions="Write, Save" value="0" />
%         <Key key="laserPower_0" permissions="Write, Save" value="10" />
%         <Key key="laserWavelength_0" permissions="Write, Save" value="820" />
%         <Key key="twophotonLaserPower_0" permissions="Write, Save" value="3673" />
%         <Key key="preAmpGain_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_3" permissions="Write, Save" value="4" />
%       </PVStateShard>
%     </Frame>
%     <Frame relativeTime="23.9368879999997" absoluteTime="24.2488629999998" index="13" label="CurrentSettings">
%       <File channel="1" filename="ZSeries-05192008-1505-005_Cycle001_CurrentSettings_Ch1_000013.tif" />
%       <ExtraParameters validData="True" />
%       <PVStateShard>
%         <Key key="objectiveLens" permissions="Read, Write, Save" value="Olympus 40X" />
%         <Key key="objectiveLensNA" permissions="Read, Write, Save" value="0.8" />
%         <Key key="objectiveLensMag" permissions="Read, Write, Save" value="40" />
%         <Key key="pixelsPerLine" permissions="Read, Write, Save" value="512" />
%         <Key key="linesPerFrame" permissions="Read, Write, Save" value="512" />
%         <Key key="systemType" permissions="Write, Save" value="3" />
%         <Key key="binningMode" permissions="Read, Write, Save" value="0" />
%         <Key key="frameAveraging" permissions="Read, Write, Save" value="1" />
%         <Key key="framePeriod" permissions="Read, Write, Save" value="1.380352" />
%         <Key key="scanlinePeriod" permissions="Read, Write, Save" value="0.002696" />
%         <Key key="dwellTime" permissions="Read, Write, Save" value="4.0" />
%         <Key key="positionCurrent_XAxis" permissions="Write, Save" value="-1320.625" />
%         <Key key="positionCurrent_YAxis" permissions="Write, Save" value="532.5" />
%         <Key key="positionCurrent_ZAxis" permissions="Write, Save" value="-30.7125" />
%         <Key key="zDevice" permissions="Write, Save" value="0" />
%         <Key key="rotation" permissions="Read, Write, Save" value="0" />
%         <Key key="opticalZoom" permissions="Read, Write, Save" value="1.0" />
%         <Key key="micronsPerPixel_XAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="micronsPerPixel_YAxis" permissions="Read, Write, Save" value="0.231481481481482" />
%         <Key key="pmtGain_0" permissions="Write, Save" value="687.5" />
%         <Key key="pmtGain_1" permissions="Write, Save" value="0" />
%         <Key key="pmtGain_2" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_0" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_1" permissions="Write, Save" value="0" />
%         <Key key="pmtOffset_2" permissions="Write, Save" value="0" />
%         <Key key="laserPower_0" permissions="Write, Save" value="10" />
%         <Key key="laserWavelength_0" permissions="Write, Save" value="820" />
%         <Key key="twophotonLaserPower_0" permissions="Write, Save" value="3672" />
%         <Key key="preAmpGain_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpGain_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpOffset_3" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_0" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_1" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_2" permissions="Write, Save" value="0" />
%         <Key key="preAmpFilterBlock_3" permissions="Write, Save" value="4" />
%       </PVStateShard>
%     </Frame>
%   </Sequence>
% </PVScan>