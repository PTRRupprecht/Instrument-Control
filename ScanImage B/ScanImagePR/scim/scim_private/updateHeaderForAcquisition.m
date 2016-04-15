function varargout = updateHeaderForAcquisition(headerVar)
% Function to update header values, which will be stored in upcoming acquisition files, to match current state
%% SYNTAX
%   updateHeaderForAcquisition()
%   headerString = updateHeaderForAcquisition(headerVar)
%       headerVar: A ScanImage header structure
%       headerString: A string representation of the ScanImage header structure
%% NOTES
%   This version was rewritten from scratch. To see earlier versions of this function, see updateHeaderForAcquisition.mold -- Vijay Iyer 3/15/09
%% CHANGES
%   VI062409A: Allow mode where a passed-in header variable returns a header string, so this function can be utilized for post-processing as well -- Vijay Iyer 6/24/09
%   
%% CREDITS
%   Created 3/15/09, by Vijay Iyer
%% *********************************************************

%%%VI0624090A%%%%%%%%%%
if nargin < 1
    global state;
    userMode = false;
else
    state = headerVar;
    state.headerString = '';
    userMode = true;
end
%%%%%%%%%%%%%%%%%%%%%%%%

processStateField('state');

%%%VI062409A%%%%%%%%%%%%%%%
if userMode
    varargout{1} = state.headerString;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function processStateField(stateField)
        fNames = fieldnames(eval(stateField));        
        for i=1:length(fNames)
            fieldName = [stateField '.' fNames{i}];
            if isstruct(eval(fieldName))
                processStateField(fieldName);
            else %current field is a variable
                if userMode || any(bitand(getGlobalConfigStatus(fieldName),2)) %VI062409A
                    processStateVar(fieldName);
                end
            end
        end   
    end

    function processStateVar(stateVar)
        %Determine if variable is already in the header string        
        pos=findstr(state.headerString, [stateVar '=']);

        %Convert variable value into a string
        if userMode %VI062409A
            val = stateVar2String(stateVar,state); %VI062409A
        else
            val = stateVar2String(stateVar);
        end

        %Append string to header string
        if length(pos)==0 %Variable not already in header string; just add it!
            state.headerString=[state.headerString stateVar '=' val 13];
        else
            cr=findstr(state.headerString, 13);
            next=cr(find(cr>pos,1));
            if length(next)==0 %at end of header string
                state.headerString=[state.headerString(1:pos-1) stateVar '=' val 13];
            else %in middle of header string
                state.headerString=[state.headerString(1:pos-1) stateVar '=' val state.headerString(next:end)];
            end
        end

    end

end



