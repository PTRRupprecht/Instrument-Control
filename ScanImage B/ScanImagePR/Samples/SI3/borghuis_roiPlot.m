function borghuis_roiPlot(eventName,eventData,varargin)
%ROIPLOT Sample SI 3.7/3.8 user function for plotting mean fluorescence
%data in specified ROI
%
%%  NOTES
% Uses single user function, bound to several SI events, to implement
% functionality. Persistent variable is used to maintain state across
% function calls. Initialization step occurs on as-needed basis at start of
% acquisitions, slowing down the acquisition start once. In SI 3.8, it
% would be possible to bind function to 'appStart' event so that
% initialization could happen then.
%
%% CREDITS
%   Bart Borghuis, Yale University, 2011
%
%% ***************************************************************************

global state

persistent fcnData

numFramePoints = 75;
axColor = [.00 .05 .1];
lineColor = [0 1 0; 1 0 0];

switch eventName
    case {'focusStart' 'acquisitionStart'}
         if ~isfield(fcnData,'hFig') || ~ishandle(fcnData.hFig)
            %Create figure
            fcnData.hFig = figure(100); clf;
            set(fcnData.hFig,'menubar','none','Name','ROI Plot','position',[300   125   500   325]);
            hTools = uitoolbar(fcnData.hFig,'Tag','roiPlotToolbar');
            fcnData.hAx = axes('parent',fcnData.hFig);
            %SelectROITools
            cData=getAddButton();
            uipushtool(hTools,'Tag','pbSelectROI','ClickedCallback',@selectROI,'CData',cData);
            
            cData=getClearButton();
            uipushtool(hTools,'Tag','pbresetROI','ClickedCallback',@resetROI,'CData',cData);
         end
         
         if ~isfield(fcnData,'selChan');
             fcnData.selChan = 1;
             resetROI();
         end
         
         if ~isfield(fcnData,'hLine') || ~ishandle(fcnData.hLine)
             setLine();
         end
         
    case 'frameAcquired'
        %Check if roiSpec is still legal for current frame size. Necessary
        %when switching between scan configurations with different nrs of
        %pixelsperline or linesperframe
        if fcnData.roiSpec(4)>state.acq.linesPerFrame || fcnData.roiSpec(2)>state.acq.pixelsPerLine 
            resetROI();
        end
                roiSpec = fcnData.roiSpec;        

        roiData = state.acq.acquiredData{1}{fcnData.selChan}(roiSpec(3):roiSpec(4),roiSpec(1):roiSpec(2));
        lineData = get(fcnData.hLine,'ydata');
        lineData = [lineData(2:end) mean(mean(roiData))];
        set(fcnData.hLine,'ydata',lineData);
    otherwise
        warning('Unexpected event ''%s'' processed by %s',eventName,mfilename);
end

    function clearData()
        set(fcnData.hLine,'ydata',zeros(numFramePoints,1));
    end

    function resetROI(~,~)
        pos=[1 1 state.acq.pixelsPerLine state.acq.linesPerFrame];
        pos2Rect(pos);
        drawROIRectangle();
        setLine();
        clearData();
    end

    function selectROI(src,evnt)
        %Select ROI
        hax = si_selectImageFigure();
        if isempty(hax)
            return;
        end
        fcnData.selChan = get(hax,'Parent');
        assert(ismember(fcnData.selChan,[1:2]),'Invalid figure selection');
        setLine();
        pos = getRectFromAxes(hax, 'Cursor', 'crosshair', 'nomovegui', 1); %VI071310A %VI021809B
        pos2Rect(pos);
        drawROIRectangle();
        clearData();
    end

    function pos2Rect(pos)
        fcnData.roiSpec = round([pos(1) pos(1)+pos(3)-1 pos(2) pos(2)+pos(4)-1]);
        fcnData.roiRectangleData = {[pos(1)+1 pos(1)+pos(3)-1 pos(1)+pos(3)-1 pos(1)+1 pos(1)+1],...
            [pos(2) pos(2)  pos(2)+pos(4)-1 pos(2)+pos(4)-1 pos(2)]};
    end

    function setLine()
        try
            delete(fcnData.hLine);
        end
        fcnData.hLine = line(1:numFramePoints,zeros(numFramePoints,1),'color',lineColor(fcnData.selChan,:),'markerFaceColor',lineColor(fcnData.selChan,:),'marker','o','markerSize',3,'parent', fcnData.hAx);
        set(fcnData.hAx,'Tag','roiPlotAxes','xLim',[1 numFramePoints],'color',axColor,'XGrid','on','yGrid','on','xcolor',[0.5 0.5 0.5],'ycolor',[0.5 0.5 0.5]);
        xlabel('Frame (n)');
        ylabel('ROI intensity (detector units');
    end
    function drawROIRectangle()
        delete(findall(1:2,'Tag','roiPlotRectangle'));
        figure(fcnData.selChan)
        fcnData.roiRectangle =line(fcnData.roiRectangleData{:},'color',[1 1 1],'linestyle',':');
        set(fcnData.roiRectangle,'Tag','roiPlotRectangle');
    end

    function[cData]=getAddButton()
        cData=[...
            NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
            NaN	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	NaN	NaN	NaN	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	NaN	NaN	NaN	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	NaN	NaN
            NaN	1.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1.00000	NaN	NaN
            NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
            NaN	1.00000	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	NaN	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	NaN	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	NaN	NaN	NaN	NaN	1.00000	NaN	NaN
            NaN	1.00000	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	NaN	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	NaN	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	NaN	NaN	NaN	NaN	1.00000	NaN	NaN
            NaN	1.00000	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	NaN	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	NaN	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	NaN	NaN	NaN	NaN	1.00000	NaN	NaN
            NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN
            NaN	1.00000	NaN	NaN	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	NaN	1.00000	NaN	NaN
            NaN	1.00000	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	NaN	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	NaN	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	NaN	NaN	NaN	NaN	1.00000	NaN	NaN
            NaN	1.00000	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	NaN	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	NaN	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	NaN	NaN	NaN	NaN	1.00000	NaN	NaN
            NaN	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN
            NaN	1.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1.00000	NaN	NaN
            NaN	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	NaN	NaN	NaN	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	NaN	NaN	NaN	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	NaN	NaN
            NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
            NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN];
        
        cData=reshape(cData,16,16,3);
        
    end

    function[cData]=getClearButton()
        cData=[...
            1.00000	1.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1.00000	1.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000
            1.00000	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	1.00000	0.00000	0.00000	0.00000	NaN	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	1.00000	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	NaN	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	1.00000	0.00000	0.00000	0.00000
            NaN	1.00000	1.00000	1.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1.00000	1.00000	1.00000	NaN	NaN	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	NaN	NaN	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	NaN
            NaN	NaN	1.00000	1.00000	1.00000	NaN	NaN	NaN	NaN	NaN	NaN	1.00000	1.00000	1.00000	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	NaN	NaN
            NaN	1.00000	NaN	1.00000	1.00000	1.00000	NaN	NaN	NaN	NaN	1.00000	1.00000	1.00000	1.00000	NaN	NaN	NaN	1.00000	NaN	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	1.00000	NaN	NaN	NaN	1.00000	NaN	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	1.00000	NaN	NaN
            NaN	1.00000	NaN	NaN	1.00000	1.00000	1.00000	NaN	NaN	1.00000	1.00000	1.00000	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	0.00000	0.00000	0.00000	NaN	NaN	0.00000	0.00000	0.00000	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	0.00000	0.00000	0.00000	NaN	NaN	0.00000	0.00000	0.00000	NaN	1.00000	NaN	NaN
            NaN	1.00000	NaN	NaN	NaN	1.00000	1.00000	1.00000	1.00000	1.00000	1.00000	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	NaN	NaN	1.00000	NaN	NaN
            NaN	NaN	NaN	NaN	NaN	NaN	1.00000	1.00000	1.00000	1.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN
            NaN	1.00000	NaN	NaN	NaN	NaN	1.00000	1.00000	1.00000	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	0.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	0.00000	NaN	NaN	NaN	1.00000	NaN	NaN
            NaN	1.00000	NaN	NaN	NaN	1.00000	1.00000	1.00000	1.00000	1.00000	1.00000	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	NaN	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	NaN	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	NaN	NaN	1.00000	NaN	NaN
            NaN	1.00000	NaN	NaN	1.00000	1.00000	1.00000	NaN	NaN	1.00000	1.00000	1.00000	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	0.00000	0.00000	0.00000	NaN	NaN	0.00000	0.00000	0.00000	NaN	1.00000	NaN	NaN	NaN	1.00000	NaN	NaN	0.00000	0.00000	0.00000	NaN	NaN	0.00000	0.00000	0.00000	NaN	1.00000	NaN	NaN
            NaN	NaN	NaN	1.00000	1.00000	1.00000	NaN	NaN	NaN	NaN	1.00000	1.00000	1.00000	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	NaN	NaN	NaN
            NaN	1.00000	1.00000	1.00000	1.00000	NaN	NaN	NaN	NaN	NaN	NaN	1.00000	1.00000	1.00000	NaN	NaN	NaN	1.00000	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	NaN	NaN	NaN	1.00000	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	NaN	NaN
            NaN	1.00000	1.00000	1.00000	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	NaN	0.00000	0.00000	0.00000	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	0.00000	0.00000	0.00000	NaN	NaN	0.00000	0.00000	0.00000	1.00000	1.00000	1.00000	NaN	1.00000	1.00000	1.00000	NaN	0.00000	0.00000	0.00000	NaN
            1.00000	1.00000	1.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1.00000	1.00000	1.00000	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000
            1.00000	1.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1.00000	1.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000	0.00000	0.00000	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	0.00000	0.00000];
        
        cData=reshape(cData,16,16,3);
        
    end
end

