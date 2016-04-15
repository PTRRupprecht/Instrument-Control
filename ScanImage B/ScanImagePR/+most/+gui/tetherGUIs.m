function tetherGUIs(parent,child,relPosn)
%% function tetherGUIs(parent,child,relPosn)
% Tethers specified child GUI to specified parent GUI, according to relPosn
%
%% SYNTAX
%   tetherGUIs(parent,child,relPosn)
%       parent,child: Valid GUI figure handles
%       relPosn: String from set {'righttop' 'rightcenter' 'bottom'} indicating desired location of child GUI relative to parent GUI

assert(ishandle(parent) && ishandle(child),'Parent & child arguments must be Matlab figure handles');

%Only tether if it hasn't been previously tethered (or otherwise had position defined)
parPosn = get(parent,'OuterPosition');
childPosn = get(child,'OuterPosition');

switch relPosn
    case 'righttop'
        childPosn(1) = sum(parPosn([1 3]));
        childPosn(2) = sum(parPosn([2 4])) - childPosn(4);
    case 'rightcenter'
        childPosn(1) = sum(parPosn([1 3]));
        childPosn(2) = parPosn(2) + parPosn(4)/2 - childPosn(4)/2;
    case 'bottom'
        childPosn(1) = parPosn(1) + parPosn(3)/2 - childPosn(3)/2;
        childPosn(2) = parPosn(2) - childPosn(4);
    otherwise
        assert(false,'Unrecognized expression provided for ''relPosn''');
end

set(child,'OuterPosition',childPosn);
