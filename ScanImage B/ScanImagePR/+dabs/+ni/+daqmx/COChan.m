classdef COChan < dabs.ni.daqmx.private.CounterChan
    %COCHANNEL A DAQmx Counter Output Channel
    
    properties (Constant)
        type = 'CounterOutput';
    end
    
    properties (Constant, Hidden)
        typeCode = 'CO';
    end
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        function obj = COChan(varargin) 
            %%%TMW: Constructor required, as this is a concrete subclass of abstract lineage
            obj = obj@dabs.ni.daqmx.private.CounterChan(varargin{:});            
        end
    end
    
end

