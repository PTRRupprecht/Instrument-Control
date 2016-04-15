classdef UserFunctionsTable < handle
    % UserFunctionsTable
    % Table of user function "records". Allows adding, deleting, inserting,
    % reshuffling, etc, with buttons and a context menu.
    %
    % A Record is a row in the table. The table is a view of the value 
    % of some model property. This model property is expected to take
    % values which are column vector struct arrays. Each element of this
    % struct array is a record. There is a 1-1 mapping between rows in the
    % table and array elements of the model property.
    %
    % In the model, the struct array of Records has certain Fields. Each
    % field is displayed in a column of the table. (The first column of the
    % table is a numbering index and does not correspond to a field).
    %
    % Model -> View updates
    % The AppController calls UserFunctionsTable.refresh() to update the view.
    %
    % View -> Model updates
    % UserFunctionsTable interacts directly with the Model. The
    % AppController does not play a (direct) role.
    %
    
    properties (Hidden)
        hModel; % handle to model object
        hTable; % handle to uitable

        fRecordFieldInfo; % NumFieldsx1 struct. Keys: Fields. Vals: a 
                          % struct with fields 'Column', 'EncodeFcn', 'DecodeFcn'.
        fColIdx2RecordField; % NumColsx1 cellstr.
        fEventNameField; % Field which takes on the enumerated list of Events/Functions.

        fEventNameFcn; % scalar fcnHandle that returns a cellstr of available Events/Functions.
        fPropertyFcn; % scalar fcnHandle that returns the model property name (string) which stores the records.
        
        fDefaultNewRecord; % scalar struct that represents a default/new record.
        
        fSelectedRowIdx; % array of currently selected table indices (in format returned by CellSelectionCallback).
    end
    
    properties (Dependent)
        fNumCols; % number of columns in table; this is one more than the number of Fields in a Record
        fNumRows; % number of rows in table; this is equal to the number of Records
    end
    
    % Prop access
    methods
        
        function v = get.fNumCols(obj)
            d = get(obj.hTable,'Data');
            v = size(d,2);
        end
        
        function v = get.fNumRows(obj)
            d = get(obj.hTable,'Data');
            v = size(d,1);
        end
        
    end
    
    % Public
    methods
               
        % See properties list above for description of input args.
        function obj = UserFunctionsTable(hMdl,hTbl,recordFieldInfo,...
                evtNameField,eventNamesFcn,propFcn,defaultNewRecord)
            
            % init object state
            obj.hModel = hMdl;
            obj.hTable = hTbl;
            obj.fRecordFieldInfo = recordFieldInfo;
            fields = fieldnames(recordFieldInfo);
            obj.fColIdx2RecordField = repmat({''},1,obj.fNumCols);
            for c = 1:numel(fields)
                fld = fields{c};
                colIdx = recordFieldInfo.(fld).Column;
                obj.fColIdx2RecordField{colIdx} = fld;
            end
                
            obj.fEventNameField = evtNameField;
            obj.fEventNameFcn = eventNamesFcn;
            obj.fPropertyFcn = propFcn;
            obj.fDefaultNewRecord = defaultNewRecord;
            obj.fSelectedRowIdx = [];

            set(hTbl,'CellSelectionCallback',@(src,evt)obj.cbkCellSelect(evt));
            set(hTbl,'CellEditCallback',@(src,evt)obj.cbkCellEdit(evt));
            
            % setup context menu
            uh = uicontextmenu('Tag','cmnuTbl');
            uimenu(uh,'Label','Add','Callback',@(src,evt)obj.add());
            uimenu(uh,'Label','Insert','Callback',@(src,evt)obj.insert());
            uimenu(uh,'Label','Delete','Callback',@(src,evt)obj.del());
            uimenu(uh,'Label','Move up','Callback',@(src,evt)obj.moveUp(),'Separator','on');
            uimenu(uh,'Label','Move down','Callback',@(src,evt)obj.moveDown());
            uimenu(uh,'Label','Browse for function','Callback',@(src,evt)obj.browseForFcn,'Separator','on');
            set(hTbl,'UIContextMenu',uh);
        end
        
        % Refresh table based on model property value.
        function refresh(obj)
            % Refresh events/functions pulldown
            colfmt = get(obj.hTable,'ColumnFormat');
            eventNames = obj.fEventNameFcn();
            colfmt{obj.fRecordFieldInfo.(obj.fEventNameField).Column} = eventNames(:)';
            set(obj.hTable,'ColumnFormat',colfmt);
            
            % Refresh table data
            propName = obj.fPropertyFcn();
            propVal = obj.hModel.(propName);
            Nrecords = numel(propVal);
            data = cell(Nrecords,obj.fNumCols);
            if ~isempty(data)
                for c = 1:Nrecords
                    data(c,:) = obj.record2Row(propVal(c));
                end
                data(:,1) = num2cell((1:Nrecords)');
            end
            set(obj.hTable,'Data',data);
        end
        
        function cbkCellSelect(obj,evt)
            obj.fSelectedRowIdx = evt.Indices;
        end
        
        function cbkCellEdit(obj,evt)
            rowIdx = evt.Indices(1);
            data = get(obj.hTable,'Data');
            
            row = data(rowIdx,:);
            try
                record = obj.row2Record(row);
            catch %#ok<CTCH>
                obj.refresh();
                return;
            end
            propName = obj.fPropertyFcn();
            val = obj.hModel.(propName);
            val(rowIdx) = record;
            obj.setValWithRestore(val);
        end        
        
        % Add a new record to the property (at the end)
        function add(obj)
            newRecord = obj.fDefaultNewRecord;
            propName = obj.fPropertyFcn();
            val = obj.hModel.(propName);
            val(end+1,1) = newRecord;
            obj.setValWithRestore(val);
        end
        
        % Insert a new record to the property at the currently selected
        % row position.
        %
        % If there is no currently selected row, a warndlg is put up.
        function insert(obj)
            if isempty(obj.fSelectedRowIdx)
                warndlg('Select a cell in the table to indicate a row location for insertion.',...
                    'No cell selected', 'modal');
                return;
            end            
            
            rowIdx = obj.fSelectedRowIdx(1); % If multi-select, use first row
            newRecord = obj.fDefaultNewRecord;
            propName = obj.fPropertyFcn();
            val = obj.hModel.(propName);
            newval = [val(1:rowIdx-1,1);newRecord;val(rowIdx:end,1)];
            obj.setValWithRestore(newval);
        end
        
        % Delete the record at the currently selected row position.
        %
        % If there is no currently selected row, a warndlg is put up.
        function del(obj)
            if isempty(obj.fSelectedRowIdx)
                warndlg('Select a cell in the table to indicate a row location for deletion.',...
                    'No cell selected', 'modal');
                return;
            end
            
            rowIdxs = obj.fSelectedRowIdx(:,1); % Could have multiple values if multi-select
            propName = obj.fPropertyFcn();
            val = obj.hModel.(propName);
            val(rowIdxs,:) = [];
            obj.setValWithRestore(val);
        end
        
        % etc
        function moveUp(obj)
            if isempty(obj.fSelectedRowIdx)
                warndlg('Select a cell in the table to indicate a row.', 'No cell selected', 'modal');
                return;
            end
            
            rowIdx = obj.fSelectedRowIdx(1); % If multi-select, use first row
            if rowIdx == 1
                return;
            else
                obj.swapRows(rowIdx,rowIdx-1);
            end
        end
        
        % etc
        function moveDown(obj)
            if isempty(obj.fSelectedRowIdx)
                warndlg('Select a cell in the table to indicate a row.', 'No cell selected', 'modal');
                return;
            end
            
            rowIdx = obj.fSelectedRowIdx(1); % If multi-select, use first row
            if rowIdx == obj.fNumRows
                return;
            else
                obj.swapRows(rowIdx,rowIdx+1);
            end
        end
        
        % Use uigetfile to populate the field 'UserFcnName' in currently
        % selected row
        function browseForFcn(obj)
            if isempty(obj.fSelectedRowIdx)
                warndlg('Select a cell in the table to indicate a row.', 'No cell selected', 'modal');
                return;
            end
            
            rowIdx = obj.fSelectedRowIdx(1); % If multi-select, use first row
            fname = uigetfile('*.m','Select a user function M-file');
            if isequal(fname,0)
                return;
            end
            
            if exist(fname,'file')~=2
                warning('ScanImage:UserFunctionsTable:functionNotOnPath',...
                    'The specified function ''%s'' is not on the current path.',fname);
            end
            
            [~,fname,~] = fileparts(fname); % get rid of extension
            propName = obj.fPropertyFcn();
            val = obj.hModel.(propName);
            val(rowIdx).UserFcnName = fname;
            obj.setValWithRestore(val);            
        end
        
    end
    
    % Private
    methods (Hidden)
        
        % Turn a row from the table into a record struct.
        function record = row2Record(obj,row)
            record = struct();
            for c = 1:numel(row)
                fld = obj.fColIdx2RecordField{c};
                if ~isempty(fld)
                    decodeFcn = obj.fRecordFieldInfo.(fld).DecodeFcn;
                    if ~isempty(decodeFcn)
                        val = decodeFcn(row{c});
                    else
                        val = row{c};
                    end                        
                    record.(fld) = val;
                end
            end
        end
        
        % Turn a record struct into a row for the table.
        function row = record2Row(obj,record)
            row = cell(1,obj.fNumCols);
            fields = fieldnames(record);
            for c = 1:numel(fields)
                fld = fields{c};
                encodeFcn = obj.fRecordFieldInfo.(fld).EncodeFcn;
                if ~isempty(encodeFcn)
                    val = encodeFcn(record.(fld));
                else
                    val = record.(fld);
                end
                row{obj.fRecordFieldInfo.(fld).Column} = val;
            end
        end
                
        function setValWithRestore(obj,val)
            propName = obj.fPropertyFcn();
            try
                obj.hModel.(propName) = val;
            catch %#ok<CTCH>
                obj.refresh();                
            end
        end
        
        function swapRows(obj,rowIdx1,rowIdx2)
            propName = obj.fPropertyFcn();
            val = obj.hModel.(propName);
            row1 = val(rowIdx1);
            val(rowIdx1) = val(rowIdx2);
            val(rowIdx2) = row1;
            obj.setValWithRestore(val);
        end
        
    end
        
end
        