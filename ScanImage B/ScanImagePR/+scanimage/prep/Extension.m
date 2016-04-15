classdef Extension < handle
   
    properties
        Name
        Enabled
    end
    
    methods
        
        function init(obj,src,evt)
        end
        
        function shutdown(obj,src,evt)
        end
       
        function acquisitionStart(obj,src,evt)
        end
        
        function acquisitionDone(obj,src,evt)
        end
        
        function acquisitionAborted(obj,src,evt)
        end
        
        function sliceDone(obj,src,evt)
        end
        
        function focusStart(obj,src,evt)
        end
        
        function focusDone(obj,src,evt)
        end
        
        function stripeAcquired(obj,src,evt)
        end
        
        function frameAcquired(obj,src,evt)
        end
        
        function startTriggerReceived(obj,src,evt)
        end
        
        function nextTriggerReceived(obj,src,evt)
        end
        
    end
            
end