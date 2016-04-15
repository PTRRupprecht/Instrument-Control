classdef MotorRegistry
    
    methods (Static)
        
        function info = getControllerInfo(type)
            assert(ischar(type),'''type'' must be a stage controller type.');
            m = scanimage.MotorRegistry.controllerMap;
            if m.isKey(type)
                info = m(type);
            else
                info = [];
            end
        end
        
    end
    
    properties (Constant,GetAccess=private)
        controllerMap = zlclInitControllerMap();
    end
    
    methods (Access=private)
        function obj = MotorRegistry()
        end      
    end            
    
end

function m = zlclInitControllerMap

m = containers.Map();

s = struct();
s.Names = {'mp285' 'sutter.mp285' 'sutter.MP285'};
s.Class = 'dabs.sutter.MP285';
s.SubType = '';
s.TwoStep.Enable = true; 
s.TwoStep.FastLSCPropVals = struct('resolutionMode','coarse');
s.TwoStep.SlowLSCPropVals = struct('resolutionMode','fine');
s.TwoStep.InitSlowLSCProps = true;
s.SafeReset = true;
zlclAddMotor(m,s);

s = struct();
s.Names = {'mpc200' 'sutter.mpc200' 'sutter.MPC200'};
s.Class = 'dabs.sutter.MPC200';
s.SubType = '';
s.TwoStep.Enable = false; 
%s.TwoStep.FastLSCPropVals = struct('resolutionMode','coarse');
%s.TwoStep.SlowLSCPropVals = struct('resolutionMode','fine');
s.SafeReset = false;
zlclAddMotor(m,s);

s = struct();
s.Names = {'scientifica' 'scientifica.LinearStageController'};
s.Class = 'dabs.scientifica.LinearStageController';
s.SubType = '';
s.TwoStep.Enable = true;
s.TwoStep.FastLSCPropVals = struct(); %Velocity is switched between fast/slow, but determined programatically for each stage type
s.TwoStep.SlowLSCPropVals = struct(); %Velocity is switched between fast/slow, but determined programatically for each stage type
s.TwoStep.InitSlowLSCProps = false;
s.SafeReset = false;
zlclAddMotor(m,s);

s = struct();
s.Names = {'pi.e816' 'pi.e665' 'pi.E816' 'pi.E665'};
s.Class = 'dabs.pi.LinearStageController';
s.SubType = 'e816';
s.TwoStep.Enable = false; 
s.SafeReset = false;
zlclAddMotor(m,s);

s = struct();
s.Names = {'pi.e753'};
s.Class = 'dabs.pi.LinearStageController';
s.SubType = 'e753';
s.TwoStep.Enable = false; 
s.SafeReset = false;
zlclAddMotor(m,s);

s = struct();
s.Names = {'thorlabs.bscope' 'thorlabs.BScope' 'thorlabs.bScope.BScopeLSC'};
s.Class = 'dabs.thorlabs.bScope.BScopeLSC';
s.SubType = '';
s.TwoStep.Enable = false; 
s.SafeReset = true;
zlclAddMotor(m,s);

s = struct();
s.Names = {'luigsneumann.sm5' 'luigsneumann.SM5'};
s.Class = 'dabs.luigsneumann.SM5';
s.SubType = '';
s.TwoStep.Enable = false; 
s.SafeReset = true;
zlclAddMotor(m,s);

s = struct();
s.Names = {'npoint.lc40x' 'npoint.LC40x'};
s.Class = 'dabs.npoint.LinearStageController';
s.SubType = 'LC40x';
s.TwoStep.Enable = false;
s.SafeReset = true;
zlclAddMotor(m,s);

s = struct();
s.Names = {'dummy' 'dummies.DummyLSC'};
s.Class = 'dabs.dummies.DummyLSC';
s.SubType = '';
s.TwoStep.Enable = false; 
s.SafeReset = true;
zlclAddMotor(m,s);

end

function zlclAddMotor(m,s)
names = s.Names;
for c = 1:length(names)
    m(names{c}) = s;
end
end
