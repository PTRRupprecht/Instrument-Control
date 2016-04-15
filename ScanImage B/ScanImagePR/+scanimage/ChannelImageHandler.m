classdef ChannelImageHandler < handle
% Handles preset colormap specifications etc for channel images. Eventually
% can expand this to handle all channel-image "view" code. (Can move
% channel images, merge, etc out of SI core.)

    properties (Constant)        
        % col 1: pretty spec. col 2: detailed spec        
        colorMapSpecs = {
            'Gray'              {'gray' 'gray' 'gray'} 
            'Gray - High Sat.'  {'grayHighSat' 'grayHighSat' 'grayHighSat'}
            'Gray - Low Sat.'   {'grayLowSat' 'grayLowSat' 'grayLowSat'}
            'Gray - Both Sat.'  {'grayBothSat' 'grayBothSat' 'grayBothSat'}
            'Jet'               {'jet' 'jet' 'jet'}
            'R/G/Gray/Gray'     {'red' 'green' 'gray'}
            'G/R/Gray/Gray'     {'green' 'red' 'gray'}
            };
        prettyColorMapSpecs = scanimage.ChannelImageHandler.colorMapSpecs(:,1);
        colorMapUITableColumnIdx = 7; % hardcoded for now, columnArrayTable doesn't handle everything needed  
    end
        
    properties
        hChannelControlsCAT; % ColumnArrayTable PropControl for channelControls uitable
        hChannelControlsUITable; % for ColumnEditable property, currently not a member of ColumnArrayTable
        hChannelImageFigs; % NChannelsx1 array of handles to channel image figures
    end    
        
    methods
        
        function obj = ChannelImageHandler(hColumnArrayTable,hUITable)
            assert(isa(hColumnArrayTable,'most.gui.control.ColumnArrayTable'));
            assert(ishandle(hUITable) && strcmp(get(hUITable,'Type'),'uitable'));
            
            obj.hChannelControlsCAT = hColumnArrayTable;
            obj.hChannelControlsUITable = hUITable;
            obj.hChannelImageFigs = []; % remains empty until registerChannelImageFigs is called
        end
        
        function registerChannelImageFigs(obj,hFigs)
            assert(all(ishandle(hFigs)) && numel(hFigs)==obj.hChannelControlsCAT.nRows);
            obj.hChannelImageFigs = hFigs;
            obj.applyTableColorMapsToImageFigs;
        end
        
        function initColorMapsInTable(obj)
            pms = scanimage.ChannelImageHandler.prettyColorMapSpecs{1};
            obj.updateTable(pms);
        end
        
        function updateTable(obj,prettyColorMapSpec)
            assert(ischar(prettyColorMapSpec));
            if strcmp(prettyColorMapSpec,'Custom')
                ce = get(obj.hChannelControlsUITable,'ColumnEditable');
                ce(obj.colorMapUITableColumnIdx) = true;
                set(obj.hChannelControlsUITable,'ColumnEditable',ce);
            else
                cms = obj.colorMapSpecs;
                [tf loc] = ismember(prettyColorMapSpec,cms(:,1));
                assert(tf);
                clrSpecs = cms{loc,2};
                
                % truncate/expand clrSpecs to match number of rows in tbl
                Nrows = obj.hChannelControlsCAT.nRows;
                if numel(clrSpecs) > Nrows
                    clrSpecs = clrSpecs(1:Nrows);
                elseif numel(clrSpecs) < Nrows
                    clrSpecs(end+1:Nrows) = clrSpecs(end);
                end
                
                % set colormap values in table
                clrMapVals = cellfun(@(x)obj.colorMapSpec2MLCmd(x),clrSpecs,'UniformOutput',false);
                dat = get(obj.hChannelControlsUITable,'Data');
                dat(:,obj.colorMapUITableColumnIdx) = clrMapVals(:);
                set(obj.hChannelControlsUITable,'Data',dat);
                
                % update column editable-ness
                ce = get(obj.hChannelControlsUITable,'ColumnEditable');
                ce(obj.colorMapUITableColumnIdx) = false;
                set(obj.hChannelControlsUITable,'ColumnEditable',ce);
            end
        end
        
        function applyTableColorMapsToImageFigs(obj)
            assert(~isempty(obj.hChannelImageFigs)); % channel images must be registered
            
            tableDat = get(obj.hChannelControlsUITable,'Data');
            colorMapFcns = tableDat(:,obj.colorMapUITableColumnIdx);
            hFigs = obj.hChannelImageFigs;
            
            for c = 1:numel(colorMapFcns)
                cm = [];
                evalstr = sprintf('cm = %s;',colorMapFcns{c});
                try
                    eval(evalstr);
                    set(hFigs(c),'ColorMap',cm);
                catch  %#ok<CTCH>
                    warning('scanimage:ChannelImageHandler',...
                        'Error caught evaluating/applying colormap specification for channel %d. Leaving colormap unchanged.',c);
                    continue;
                end
            end            
        end
        
    end
    
    methods (Static)
        
        function cmd = colorMapSpec2MLCmd(spec)
            cmd = sprintf('scim_colorMap(''%s'',8,5)',spec);
        end        
        
    end
    
end
    