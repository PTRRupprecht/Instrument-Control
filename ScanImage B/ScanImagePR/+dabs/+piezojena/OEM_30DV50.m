classdef OEM_30DV50 < dabs.piezojena.DDrive
    %OEM_30DV50 A class encapsulating the 30DV50 OEM piezo controller/amplifier from Piezosystems Jena
    
    %NOTE: At moment, this simply inherits/replicates d_Drive() class, as there are no discernible differences         
    

    properties (Constant)
       type = 'OEM 30DV50'; 
    end
    
end

