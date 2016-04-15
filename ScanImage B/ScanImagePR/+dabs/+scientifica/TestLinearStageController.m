classdef TestLinearStageController < most.testing.TestSuite
    %TESTLINEARSTAGECONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    %% ABSTRACT PROPERTY REALIZATIONS (most.testing.TestSuite)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties (Constant)
        classUnderTest = 'dabs.scientifica.LinearStageController';
        constructionPVArgs = {'stageType','patchstar','comPort',3,'baudRate',9600};
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %% CLASS-SPECIFIC PROPERTIES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Hidden, Access=private)
        moveTestDistancePerDimension = 4000.15; %Distance in um to move for long tests
        moveTestMaxVelocitySubFactors = [3 6];
        moveTestMoveTimeout = 30;
        moveTestStandardReplyTimeout = 2;

        moveTestCompleteEventFcn = @(src,evnt)fprintf(1,'Move completed. Reached position: %s\n',mat2str(src.positionAbsolute));
        moveTestCompleteEventListener = [];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %% CONSTRUCTOR/DESTRUCTOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        function obj = TestLinearStageController()
            obj.setup();
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %% ABSTRACT METHODS REALIZATIONS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods(Access=protected)
   
        function setup(obj)
            import most.testing.*;
            
            obj.addTest(Test(@obj.testPropertyReadout,'testName','Read-out of all public properties'));
            obj.addTest(Test(@obj.testMoveComplete,'testName','MoveComplete test at different velocities'));
            obj.addTest(Test(@obj.testMoveStart,'testName','MoveStart test at different velocities'));
            
            %DEQ - this used to work, but adding support for multiple output args breaks it. 
            %obj.addTest(Test(obj.hTestFixture,'getInfoHardware','testName','Get Hardware Info'));
        end
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %% CLASS METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods (Access=public)
       
        function [didPass, output] = testGetInfoHardware(obj)
            try
               obj.hTestFixture.getInfoHardware(); 
            catch ME
                didPass = false;
                output = ME.message;
                return;
            end
            
            didPass = true;
            output = 'Success.';
        end
        
        function [didPass, output] = testPropertyReadout(obj)
            mc = metaclass(obj.hTestFixture);
            propcell = mc.Properties;
            propcell = propcell(cellfun(@(x) strcmpi(x.GetAccess,'public') && ~x.Hidden,propcell));
            props = cellfun(@(x)x.Name,propcell,'UniformOutput',false);
            
            badProps = {};
            badPropErrors = {};
            
            for i=1:length(props)
                try
                    val = obj.hTestFixture.(props{i});
                catch ME
                    badProps = [{props{i}} badProps]; %#ok<AGROW>
                    badPropErrors = [{ME.message} badPropErrors]; %#ok<AGROW>
                end
            end
            
            if ~isempty(badProps)
                errorMessage = sprintf('Encountered errors accessing the following properties:\n\r');
                errorMessage = [errorMessage sprintf('Property Name\t\tErrorMessage\n')];
                for i=1:length(badProps)
                    errorMessage = [errorMessage sprintf('%s\t\t%s\n',badProps{i},badPropErrors{i})];
                end
                
                didPass = false;
                output = MException('TestLinearStageController:propertyTest',errorMessage);
            else
                didPass = true;
                output = sprintf('Successfully read all public properties!');
            end
        end
       
        
        function [didPass, output] = testMoveComplete(obj)
            % MoveComplete test at different velocities

            obj.hTestFixture.moveTimeout = obj.moveTestMoveTimeout;

            obj.hTestFixture.velocity = obj.hTestFixture.maxVelocity;
            direction = 1;
            disp(sprintf('Starting move of specified distance (%d um) at maximum velocity\n',obj.moveTestDistancePerDimension));
            t1 = tic();
            
            try
                obj.hTestFixture.moveCompleteAbsolute(obj.hTestFixture.positionAbsolute + direction * obj.moveTestDistancePerDimension * [1 1 1]);
                disp(sprintf('Completed move in %1.2g seconds\n',toc(t1)));
                pause(0.5);

                for subFactor=obj.moveTestMaxVelocitySubFactors
                    direction = direction * (-1);
                    obj.hTestFixture.velocity = round(obj.hTestFixture.maxVelocity / subFactor);

                    disp(sprintf('Starting move of specified distance (%d um) at velocity %dX slower than maximum velocity\n',obj.moveTestDistancePerDimension,subFactor));   
                    t1 = tic();    
                    obj.hTestFixture.moveCompleteAbsolute(obj.hTestFixture.positionAbsolute + direction * obj.moveTestDistancePerDimension * [1 1 1]);        
                    disp(sprintf('Completed move in %1.2g seconds\n',toc(t1)))
                end
            catch ME
                output = [output ME.message];
                didPass = false;
                return;
            end
            
            output = 'success!';
            didPass = true;
        end
        
        function [didPass, output] = testMoveStart(obj)
            % MoveCompleteGenerateEvent test at different velocities
            
            obj.hTestFixture.hHardwareInterface.replyTimeoutDefault = obj.moveTestStandardReplyTimeout;
            obj.hTestFixture.asyncMoveTimeout = obj.moveTestMoveTimeout;
            obj.hTestFixture.generateMoveCompletedEvent = true;
            
            if ~isempty(obj.moveTestCompleteEventListener)
                delete(obj.moveTestCompleteEventListener);
            end
            obj.moveTestCompleteEventListener = obj.hTestFixture.addlistener('moveCompletedEvent',obj.moveTestCompleteEventFcn);

            try
                obj.hTestFixture.velocity = obj.hTestFixture.maxVelocity;
                direction = 1;
                fprintf(1,'Starting move of specified distance (%d um) at maximum velocity\n',obj.moveTestDistancePerDimension);
                obj.hTestFixture.moveStartAbsolute(obj.hTestFixture.positionAbsolute + direction * obj.moveTestDistancePerDimension * [1 1 1]);
                s = input('Press a key to continue AFTER move complete notification occurs; q to quit\n','s');
                if strcmpi(s,'q')
                    error('Test aborted');
                end  

                for subFactor=obj.moveTestMaxVelocitySubFactors
                    direction = direction * (-1);
                    obj.hTestFixture.velocity = round(obj.hTestFixture.maxVelocity / subFactor);

                    fprintf(1,'Starting move of specified distance (%d um) at velocity %dX slower than maximum velocity\n',obj.moveTestDistancePerDimension,subFactor);
                    obj.hTestFixture.moveStartAbsolute(obj.hTestFixture.positionAbsolute + direction * obj.moveTestDistancePerDimension * [1 1 1]);        
                    s = input('Press a key to continue AFTER move complete notification occurs; q to quit\n','s');
                    if strcmpi(s,'q')
                        error('Test aborted');
                    end

                end
            catch ME
               didPass = false;
               output = ME.message;
               return;
            end
            
            didPass = true;
            output = 'Success';
        end
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

