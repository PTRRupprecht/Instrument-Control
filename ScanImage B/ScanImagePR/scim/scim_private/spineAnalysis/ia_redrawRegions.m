% ------------------------------------------------------------------
function ia_redrawRegions(hObject)

colors = {[.5 .5 0], [0 .8125 .78], [.5 .5 .78]};
regionNames = {'backgroundRegion', 'normalizationRegion', 'integralRegion'};
ax = getMainGh(progmanager, hObject, 'primaryView');

cMenu = uicontextmenu('Parent', getParent(hObject, 'figure'));
uimenu(cMenu, 'Label', 'Hide', 'Tag', 'photometryRegionContextMenu', 'Callback', {@contextMenuHide, hObject});

for i = 1 : 3
    bounds = getLocal(progmanager, hObject, regionNames{i});
    if isempty(bounds)
        continue;
    end
    
    %Take care of image registration.
    tform = getMain(progmanager, hObject, 'registrationTransform');
    if ~isempty(tform)
        %Registered
        bounds = tformfwd(bounds', tform)';
    end
    
    graphicName = [regionNames{i} 'Graphic'];
    marker = getLocal(progmanager, hObject, graphicName);
    if ~isempty(marker) & ishandle(marker)
        try
            delete(marker);
            if i == 2
                delete(getLocal(progmanager, hObject, [graphicName '_global']));
            end
        catch
            warning('Failed to delete region marker: %s - ', graphicName, lasterr);
        end
    end
    if getLocal(progmanager, hObject, 'showRegions')
        lock = 1;
        if i == 2
            lock = 0;
        end
        boundary = line(bounds(1, :), bounds(2, :), 'Parent', ax, 'Color', colors{i}, 'LineWidth', 2, 'Tag', ['photometry-' regionNames{i}], 'UIContextMenu', cMenu);
        makegraphicsobjectmutable(boundary, 'Callback', {@graphicsMutationCallback, hObject, boundary, regionNames{i}}, 'lockToAxes', lock);
        setLocal(progmanager, hObject, graphicName, boundary);
        if i == 2
            boundary = line(bounds(1, :), bounds(2, :), 'Parent', getMainGh(progmanager, hObject, 'globalView'), 'Color', colors{i}, 'LineWidth', 2, 'Tag', ['photometry-' regionNames{i}], 'UIContextMenu', cMenu);
            makegraphicsobjectmutable(boundary, 'Callback', {@graphicsMutationCallback, hObject, boundary, regionNames{i}}, 'lockToAxes', 1);
            setLocal(progmanager, hObject, [graphicName '_global'], boundary);
        end
    end
%     rect = rectangle('Parent', ax, 'Position', bounds, ...
%         'FaceColor', 'None', 'EdgeColor', colors{i}, 'LineWidth', 2, 'Tag', ['photometry-' regionNames{i}]);
%     setLocal(progmanager, hObject, graphicName, rect);
end

%For some reason, the first time drawing to the access screws up the image, so the image needs to be redrawn.
if getLocal(progmanager, hObject, 'firstDraw')
    setLocal(progmanager, hObject, 'firstDraw', 0);
    feval(getMain(progmanager, hObject, 'displayNewImage'), getMain(progmanager, hObject, 'hObject'));
end
setLocal(progmanager, hObject, 'firstDraw', 0);

return;

% ------------------------------------------------------------------
function graphicsMutationCallback(hObject, lObject, regionName)

bounds = get(lObject, 'XData');
bounds(2, :) = get(lObject, 'YData');
setLocal(progmanager, hObject, regionName, bounds);
setLocal(progmanager, hObject, strrep(regionName, 'Region', 'Frame'), getMain(progmanager, hObject, 'frameNumber'));

switch lower(regionName)
    case 'backgroundregion'
        setLocalGh(progmanager, hObject, 'storeBackground', 'FontWeight', 'Bold');
    case 'normalizationregion'
        setLocalGh(progmanager, hObject, 'storeNormalization', 'FontWeight', 'Bold');
        setLocal(progmanager, hObject, 'recalculateNormalization', 1);
    case 'normalizationregion_global'
        setLocalGh(progmanager, hObject, 'storeNormalization', 'FontWeight', 'Bold');
        setLocal(progmanager, hObject, 'recalculateNormalization', 1);
    case 'integralregion'
        setLocalGh(progmanager, hObject, 'storeIntegral', 'FontWeight', 'Bold');
    otherwise
        error('Unrecognized region: %s', regionName);
end

ia_updatePhotometryValues(hObject);

return;