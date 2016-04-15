function ia_updatePhotometryFromAnnotation(hObject)

index = getMain(progmanager, hObject, 'currentAnnotation');

if isempty(index) | index < 1
    return;
end

%TO080707 - Process photometry across multiple channels, for ratiometric imaging. -- Tim O'Connor 8/7/07
annotations = getMain(progmanager, hObject, 'annotations');
frameNumber = getMain(progmanager, hObject, 'frameNumber');
hObject = getMain(progmanager, hObject, 'photometryWindow');
channel = getMain(progmanager, hObject, 'currentChannel');
numberOfChannels = getMain(progmanager, hObject, 'numberOfChannels');

if ~isfield(annotations(index), 'photometry')
    for i = 1 : length(numberOfChannels)
        annotations(index).photometry(i).background = [];
        annotations(index).photometry(i).backgroundBounds = [];
        annotations(index).photometry(i).backgroundFrame = [];
        annotations(index).photometry(i).backgroundChannel = 1;
        annotations(index).photometry(i).normalization = [];
        annotations(index).photometry(i).normalizationBounds = [];
        annotations(index).photometry(i).normalizationFrame = [];
        annotations(index).photometry(i).normalizationChannel = 1;
        annotations(index).photometry(i).integral = [];
        annotations(index).photometry(i).integralBounds = [];
        annotations(index).photometry(i).integralFrame = [];
        annotations(index).photometry(i).integralChannel = 1;
        annotations(index).photometry(i).integralPixelCount = 0;%TO080507D
        annotations(index).photometry(i).normalizationMethod = [];
    end
    
    setLocal(progmanager, hObject, 'annotations', annotations);
end

if isempty(annotations(index).photometry)
    for i = 1 : length(numberOfChannels)
        annotations(index).photometry(i).background = [];
        annotations(index).photometry(i).backgroundBounds = [];
        annotations(index).photometry(i).backgroundFrame = [];
        annotations(index).photometry(i).backgroundChannel = 1;
        annotations(index).photometry(i).normalization = [];
        annotations(index).photometry(i).normalizationBounds = [];
        annotations(index).photometry(i).normalizationFrame = [];
        annotations(index).photometry(i).normalizationChannel = 1;
        annotations(index).photometry(i).integral = [];
        annotations(index).photometry(i).integralBounds = [];
        annotations(index).photometry(i).integralFrame = [];
        annotations(index).photometry(i).integralChannel = 1;
        annotations(index).photometry(i).integralPixelCount = 0;%TO080507D
        annotations(index).photometry(i).normalizationMethod = [];
    end
    
    setLocal(progmanager, hObject, 'annotations', annotations);
end

%TO080707A
if length(annotations(index).photometry) < channel
    channel = 1;%Should there be a warning here? Is defaulting to 1 okay?
end

%TO080707A: Be more aggressive with setting the store buttons to bold.
if ~isempty(annotations(index).photometry(channel).background)
    setLocal(progmanager, hObject, 'backgroundValue', annotations(index).photometry(channel).background);
    setLocalGh(progmanager, hObject, 'storeBackground', 'FontWeight', 'Normal');
else
    setLocalGh(progmanager, hObject, 'storeBackground', 'FontWeight', 'Bold');
end
if ~isempty(annotations(index).photometry(channel).backgroundBounds)
    setLocal(progmanager, hObject, 'backgroundRegion', annotations(index).photometry(channel).backgroundBounds);
else
    setLocalGh(progmanager, hObject, 'storeBackground', 'FontWeight', 'Bold');
end
if ~isempty(annotations(index).photometry(channel).backgroundFrame)
    setLocal(progmanager, hObject, 'backgroundFrame', annotations(index).photometry(channel).backgroundFrame);
else
    setLocal(progmanager, hObject, 'backgroundFrame', []);
    setLocalGh(progmanager, hObject, 'storeBackground', 'FontWeight', 'Bold');
end
if ~isempty(annotations(index).photometry(channel).backgroundChannel)
    setLocal(progmanager, hObject, 'backgroundChannel', annotations(index).photometry(channel).backgroundChannel);
else
    setLocal(progmanager, hObject, 'backgroundChannel', 1);
    setLocalGh(progmanager, hObject, 'storeBackground', 'FontWeight', 'Bold');
end

if ~isempty(annotations(index).photometry(channel).normalization)
    setLocal(progmanager, hObject, 'normalizationValue', annotations(index).photometry(channel).normalization);
    setLocalGh(progmanager, hObject, 'storeNormalization', 'FontWeight', 'Normal');
else
    setLocalGh(progmanager, hObject, 'storeNormalization', 'FontWeight', 'Bold');
end
if ~isempty(annotations(index).photometry(channel).normalizationBounds)
    setLocal(progmanager, hObject, 'normalizationRegion', annotations(index).photometry(channel).normalizationBounds);
else
    setLocalGh(progmanager, hObject, 'storeBackground', 'FontWeight', 'Bold');
end
if ~isempty(annotations(index).photometry(channel).normalizationFrame)
    setLocal(progmanager, hObject, 'normalizationFrame', annotations(index).photometry(channel).normalizationFrame);
else
    setLocal(progmanager, hObject, 'normalizationFrame', []);
    setLocalGh(progmanager, hObject, 'storeBackground', 'FontWeight', 'Bold');
end
if ~isempty(annotations(index).photometry(channel).normalizationMethod)
    setLocal(progmanager, hObject, 'normalizationMethod', annotations(index).photometry(channel).normalizationMethod);
else
    setLocal(progmanager, hObject, 'normalizationMethod', []);
    setLocalGh(progmanager, hObject, 'storeBackground', 'FontWeight', 'Bold');
end
if ~isempty(annotations(index).photometry(channel).normalizationChannel)
    setLocal(progmanager, hObject, 'normalizationChannel', annotations(index).photometry(channel).normalizationChannel);
else
    setLocal(progmanager, hObject, 'normalizationChannel', 1);
    setLocalGh(progmanager, hObject, 'storeBackground', 'FontWeight', 'Bold');
end

if ~isempty(annotations(index).photometry(channel).integral)
    setLocal(progmanager, hObject, 'integralValue', annotations(index).photometry(channel).integral);
    setLocalGh(progmanager, hObject, 'storeIntegral', 'FontWeight', 'Normal');
else
    setLocalGh(progmanager, hObject, 'storeIntegral', 'FontWeight', 'Bold');
end
if ~isempty(annotations(index).photometry(channel).integralBounds)
    setLocal(progmanager, hObject, 'integralRegion', annotations(index).photometry(channel).integralBounds);
else
    setLocalGh(progmanager, hObject, 'storeIntegral', 'FontWeight', 'Bold');
end
if ~isempty(annotations(index).photometry(channel).integralFrame)
    setLocal(progmanager, hObject, 'integralFrame', annotations(index).photometry(channel).integralFrame);
else
    setLocal(progmanager, hObject, 'integralFrame', []);
    setLocalGh(progmanager, hObject, 'storeIntegral', 'FontWeight', 'Bold');
end
if ~isempty(annotations(index).photometry(channel).integralChannel)
    setLocal(progmanager, hObject, 'integralChannel', annotations(index).photometry(channel).integralChannel);
else
    setLocal(progmanager, hObject, 'integralChannel', 1);
    setLocalGh(progmanager, hObject, 'storeIntegral', 'FontWeight', 'Bold');
end

%TO080507D
if ~isfield(annotations(index).photometry(channel), 'integralPixelCount')
    annotations(index).photometry(channel).integralPixelCount = [];
end
if ~isempty(annotations(index).photometry(channel).integralPixelCount)
    setLocal(progmanager, hObject, 'integralPixelCount', annotations(index).photometry(channel).integralPixelCount);
else
    setLocal(progmanager, hObject, 'integralPixelCount', []);
    setLocalGh(progmanager, hObject, 'storeIntegral', 'FontWeight', 'Bold');
end

if getMain(progmanager, hObject, 'loadPhotometryRegions')
    setLocalBatch(progmanager, hObject, ...
        'backgroundRegion', annotations(index).photometry(channel).backgroundBounds, 'backgroundFrame', annotations(index).photometry(channel).backgroundFrame, ...
        'backgroundRegion', annotations(index).photometry(channel).backgroundBounds, 'backgroundFrame', annotations(index).photometry(channel).backgroundFrame, ...
        'normalizationBounds', annotations(index).photometry(channel).normalizationBounds, 'normalizationFrame', annotations(index).photometry(channel).normalizationFrame, ...
        'integralBounds', annotations(index).photometry(channel).integralBounds, 'integralFrame', annotations(index).photometry(channel).integralFrame ...
        );
    ia_redrawRegions(hObject);
else
    setLocal(progmanager, hObject, 'recalculateNormalization', 1);
    ia_updatePhotometryValues(hObject);
end

return;