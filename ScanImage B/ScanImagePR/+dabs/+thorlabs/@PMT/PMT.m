classdef PMT < dabs.thorlabs.private.ThorDevice
    %PMT Summary of this class goes here
    %   Detailed explanation goes here
    
    %% ABSTRACT PROPERTY REALIZATIONS (dabs.thorlabs.private.ThorDevice)
    properties (Constant, Hidden)
%         deviceTypeDescriptorSDK = 'Device'; %Descriptor used by SDK for device type in function calls, e.g. 'Device', 'Camera', etc.
        prop2ParamMap=zlclInitProp2ParamMap(); %Map of class property names to API-defined parameters names
    end
    
    
    %% ABSTRACT PROPERTY REALIZATIONS (most.APIWrapper)
    
    %Following MUST be supplied with non-empty values for each concrete subclass
%     properties (Constant, Hidden)
%         apiPrettyName='Thorlabs PMT Module';  %A unique descriptive string of the API being wrapped
%         apiCompactName='ThorlabsPMT'; %A unique, compact string of the API being wrapped (must not contain spaces)        
       
        %Properties which can be indexed by version
%         apiDLLNames = 'ThorPMT'; %Either a single name of the DLL filename (sans the '.dll' extension), or a Map of such names keyed by values in 'apiSupportedVersionNames'
        %apiHeaderFilenames = {'PMT_SDK_MOD.h' 'PMT_SDK_MOD.h'  'PMT_SDK_MOD.h' 'PMT_SDK.h' 'PMT_SDK.h' 'PMT_SDK.h' 'PMT_SDK.h' 'PMT_SDK.h'}; %Either a single name of the header filename (with the '.h' extension - OR a .m or .p extension), or a Map of such names keyed by values in 'apiSupportedVersionNames'
%         apiHeaderFilenames = 'ThorPMT_proto.m';
%     end
    
    %% DEVICE PROPERTIES (PSEUDO-DEPENDENT)
    %PDEP properties corresponding directly to 'params' defined by API
    properties (SetObservable, GetObservable, AbortSet)
        scanEnable;
        pmtGain1;
        pmtGain2;
        pmtEnable1;
        pmtEnable2;
        deviceType;  
        % ECU2 related:
        scanZoomPos;  
        
    end
    
    %ECU2 API properties:
%     properties (GetObservable)
%         fieldSizeInfo;        
%     end
   
    
    %% PRIVATE/PROTECTED PROPERTIES
    
    properties (SetAccess=protected,Hidden)
       paramChangeFlag; %Logical indicating if a property has been changed
       %isConnected=false;  % true if PMT is actually connected
    end    
    
    %% HIDDEN PROPERTIES
    
    %Hidden PDEP properties corresponding directly to 'params' defined by API
    properties (GetObservable,SetObservable,Hidden)
        bidiPhaseAlignmentCoarse1; %bidiPhaseAlignmentCoarse value for fieldSize 255
        bidiPhaseAlignmentCoarse2; %bidiPhaseAlignmentCoarse value for fieldSize 254
        bidiPhaseAlignmentCoarse3; %bidiPhaseAlignmentCoarse value for fieldSize 253
        bidiPhaseAlignmentCoarse4; % ...
        bidiPhaseAlignmentCoarse5; 
        bidiPhaseAlignmentCoarse6; 
        bidiPhaseAlignmentCoarse7; 
        bidiPhaseAlignmentCoarse8; 
        bidiPhaseAlignmentCoarse9; 
        bidiPhaseAlignmentCoarse10; 
        bidiPhaseAlignmentCoarse11; 
        bidiPhaseAlignmentCoarse12; 
        bidiPhaseAlignmentCoarse13; 
        bidiPhaseAlignmentCoarse14; 
        bidiPhaseAlignmentCoarse15; 
        bidiPhaseAlignmentCoarse16; 
        bidiPhaseAlignmentCoarse17;
        bidiPhaseAlignmentCoarse18;
        bidiPhaseAlignmentCoarse19;
        bidiPhaseAlignmentCoarse20;
        bidiPhaseAlignmentCoarse21;
        bidiPhaseAlignmentCoarse22;
        bidiPhaseAlignmentCoarse23;
        bidiPhaseAlignmentCoarse24;
        bidiPhaseAlignmentCoarse25;
        bidiPhaseAlignmentCoarse26;
        bidiPhaseAlignmentCoarse27;
        bidiPhaseAlignmentCoarse28;
        bidiPhaseAlignmentCoarse29;
        bidiPhaseAlignmentCoarse30;
        bidiPhaseAlignmentCoarse31;
        bidiPhaseAlignmentCoarse32;
        bidiPhaseAlignmentCoarse33;
        bidiPhaseAlignmentCoarse34;
        bidiPhaseAlignmentCoarse35;
        bidiPhaseAlignmentCoarse36;
        bidiPhaseAlignmentCoarse37;
        bidiPhaseAlignmentCoarse38;
        bidiPhaseAlignmentCoarse39;
        bidiPhaseAlignmentCoarse40;
        bidiPhaseAlignmentCoarse41;
        bidiPhaseAlignmentCoarse42;
        bidiPhaseAlignmentCoarse43;
        bidiPhaseAlignmentCoarse44;
        bidiPhaseAlignmentCoarse45;
        bidiPhaseAlignmentCoarse46;
        bidiPhaseAlignmentCoarse47;
        bidiPhaseAlignmentCoarse48;
        bidiPhaseAlignmentCoarse49;
        bidiPhaseAlignmentCoarse50;
        bidiPhaseAlignmentCoarse51;
        bidiPhaseAlignmentCoarse52;
        bidiPhaseAlignmentCoarse53;
        bidiPhaseAlignmentCoarse54;
        bidiPhaseAlignmentCoarse55;
        bidiPhaseAlignmentCoarse56;
        bidiPhaseAlignmentCoarse57;
        bidiPhaseAlignmentCoarse58;
        bidiPhaseAlignmentCoarse59;
        bidiPhaseAlignmentCoarse60;
        bidiPhaseAlignmentCoarse61;
        bidiPhaseAlignmentCoarse62;
        bidiPhaseAlignmentCoarse63;
        bidiPhaseAlignmentCoarse64;
        bidiPhaseAlignmentCoarse65;
        bidiPhaseAlignmentCoarse66;
        bidiPhaseAlignmentCoarse67;
        bidiPhaseAlignmentCoarse68;
        bidiPhaseAlignmentCoarse69;
        bidiPhaseAlignmentCoarse70;
        bidiPhaseAlignmentCoarse71;
        bidiPhaseAlignmentCoarse72;
        bidiPhaseAlignmentCoarse73;
        bidiPhaseAlignmentCoarse74;
        bidiPhaseAlignmentCoarse75;
        bidiPhaseAlignmentCoarse76;
        bidiPhaseAlignmentCoarse77;
        bidiPhaseAlignmentCoarse78;
        bidiPhaseAlignmentCoarse79;
        bidiPhaseAlignmentCoarse80;
        bidiPhaseAlignmentCoarse81;
        bidiPhaseAlignmentCoarse82;
        bidiPhaseAlignmentCoarse83;
        bidiPhaseAlignmentCoarse84;
        bidiPhaseAlignmentCoarse85;
        bidiPhaseAlignmentCoarse86;
        bidiPhaseAlignmentCoarse87;
        bidiPhaseAlignmentCoarse88;
        bidiPhaseAlignmentCoarse89;
        bidiPhaseAlignmentCoarse90;
        bidiPhaseAlignmentCoarse91;
        bidiPhaseAlignmentCoarse92;
        bidiPhaseAlignmentCoarse93;
        bidiPhaseAlignmentCoarse94;
        bidiPhaseAlignmentCoarse95;
        bidiPhaseAlignmentCoarse96;
        bidiPhaseAlignmentCoarse97;
        bidiPhaseAlignmentCoarse98;
        bidiPhaseAlignmentCoarse99;
        bidiPhaseAlignmentCoarse100;
        bidiPhaseAlignmentCoarse101;
        bidiPhaseAlignmentCoarse102;
        bidiPhaseAlignmentCoarse103;
        bidiPhaseAlignmentCoarse104;
        bidiPhaseAlignmentCoarse105;
        bidiPhaseAlignmentCoarse106;
        bidiPhaseAlignmentCoarse107;
        bidiPhaseAlignmentCoarse108;
        bidiPhaseAlignmentCoarse109;
        bidiPhaseAlignmentCoarse110;
        bidiPhaseAlignmentCoarse111;
        bidiPhaseAlignmentCoarse112;
        bidiPhaseAlignmentCoarse113;
        bidiPhaseAlignmentCoarse114;
        bidiPhaseAlignmentCoarse115;
        bidiPhaseAlignmentCoarse116;
        bidiPhaseAlignmentCoarse117;
        bidiPhaseAlignmentCoarse118;
        bidiPhaseAlignmentCoarse119;
        bidiPhaseAlignmentCoarse120;
        bidiPhaseAlignmentCoarse121;
        bidiPhaseAlignmentCoarse122;
        bidiPhaseAlignmentCoarse123;
        bidiPhaseAlignmentCoarse124;
        bidiPhaseAlignmentCoarse125;
        bidiPhaseAlignmentCoarse126;
        bidiPhaseAlignmentCoarse127;
        bidiPhaseAlignmentCoarse128;
        bidiPhaseAlignmentCoarse129;
        bidiPhaseAlignmentCoarse130;
        bidiPhaseAlignmentCoarse131;
        bidiPhaseAlignmentCoarse132;
        bidiPhaseAlignmentCoarse133;
        bidiPhaseAlignmentCoarse134;
        bidiPhaseAlignmentCoarse135;
        bidiPhaseAlignmentCoarse136;
        bidiPhaseAlignmentCoarse137;
        bidiPhaseAlignmentCoarse138;
        bidiPhaseAlignmentCoarse139;
        bidiPhaseAlignmentCoarse140;
        bidiPhaseAlignmentCoarse141;
        bidiPhaseAlignmentCoarse142;
        bidiPhaseAlignmentCoarse143;
        bidiPhaseAlignmentCoarse144;
        bidiPhaseAlignmentCoarse145;
        bidiPhaseAlignmentCoarse146;
        bidiPhaseAlignmentCoarse147;
        bidiPhaseAlignmentCoarse148;
        bidiPhaseAlignmentCoarse149;
        bidiPhaseAlignmentCoarse150;
        bidiPhaseAlignmentCoarse151;
        bidiPhaseAlignmentCoarse152;
        bidiPhaseAlignmentCoarse153;
        bidiPhaseAlignmentCoarse154;
        bidiPhaseAlignmentCoarse155;
        bidiPhaseAlignmentCoarse156;
        bidiPhaseAlignmentCoarse157;
        bidiPhaseAlignmentCoarse158;
        bidiPhaseAlignmentCoarse159;
        bidiPhaseAlignmentCoarse160;
        bidiPhaseAlignmentCoarse161;
        bidiPhaseAlignmentCoarse162;
        bidiPhaseAlignmentCoarse163;
        bidiPhaseAlignmentCoarse164;
        bidiPhaseAlignmentCoarse165;
        bidiPhaseAlignmentCoarse166;
        bidiPhaseAlignmentCoarse167;
        bidiPhaseAlignmentCoarse168;
        bidiPhaseAlignmentCoarse169;
        bidiPhaseAlignmentCoarse170;
        bidiPhaseAlignmentCoarse171;
        bidiPhaseAlignmentCoarse172;
        bidiPhaseAlignmentCoarse173;
        bidiPhaseAlignmentCoarse174;
        bidiPhaseAlignmentCoarse175;
        bidiPhaseAlignmentCoarse176;
        bidiPhaseAlignmentCoarse177;
        bidiPhaseAlignmentCoarse178;
        bidiPhaseAlignmentCoarse179;
        bidiPhaseAlignmentCoarse180;
        bidiPhaseAlignmentCoarse181;
        bidiPhaseAlignmentCoarse182;
        bidiPhaseAlignmentCoarse183;
        bidiPhaseAlignmentCoarse184;
        bidiPhaseAlignmentCoarse185;
        bidiPhaseAlignmentCoarse186;
        bidiPhaseAlignmentCoarse187;
        bidiPhaseAlignmentCoarse188;
        bidiPhaseAlignmentCoarse189;
        bidiPhaseAlignmentCoarse190;
        bidiPhaseAlignmentCoarse191;
        bidiPhaseAlignmentCoarse192;
        bidiPhaseAlignmentCoarse193;
        bidiPhaseAlignmentCoarse194;
        bidiPhaseAlignmentCoarse195;
        bidiPhaseAlignmentCoarse196;
        bidiPhaseAlignmentCoarse197;
        bidiPhaseAlignmentCoarse198;
        bidiPhaseAlignmentCoarse199;
        bidiPhaseAlignmentCoarse200;
        bidiPhaseAlignmentCoarse201;
        bidiPhaseAlignmentCoarse202;
        bidiPhaseAlignmentCoarse203;
        bidiPhaseAlignmentCoarse204;
        bidiPhaseAlignmentCoarse205;
        bidiPhaseAlignmentCoarse206;
        bidiPhaseAlignmentCoarse207;
        bidiPhaseAlignmentCoarse208;
        bidiPhaseAlignmentCoarse209;
        bidiPhaseAlignmentCoarse210;
        bidiPhaseAlignmentCoarse211;
        bidiPhaseAlignmentCoarse212;
        bidiPhaseAlignmentCoarse213;
        bidiPhaseAlignmentCoarse214;
        bidiPhaseAlignmentCoarse215;
        bidiPhaseAlignmentCoarse216;
        bidiPhaseAlignmentCoarse217;
        bidiPhaseAlignmentCoarse218;
        bidiPhaseAlignmentCoarse219;
        bidiPhaseAlignmentCoarse220;
        bidiPhaseAlignmentCoarse221;
        bidiPhaseAlignmentCoarse222;
        bidiPhaseAlignmentCoarse223;
        bidiPhaseAlignmentCoarse224;
        bidiPhaseAlignmentCoarse225;
        bidiPhaseAlignmentCoarse226;
        bidiPhaseAlignmentCoarse227;
        bidiPhaseAlignmentCoarse228;
        bidiPhaseAlignmentCoarse229;
        bidiPhaseAlignmentCoarse230;
        bidiPhaseAlignmentCoarse231;
        bidiPhaseAlignmentCoarse232;
        bidiPhaseAlignmentCoarse233;
        bidiPhaseAlignmentCoarse234;
        bidiPhaseAlignmentCoarse235;
        bidiPhaseAlignmentCoarse236;
        bidiPhaseAlignmentCoarse237;
        bidiPhaseAlignmentCoarse238;
        bidiPhaseAlignmentCoarse239;
        bidiPhaseAlignmentCoarse240;
        bidiPhaseAlignmentCoarse241;
        bidiPhaseAlignmentCoarse242;
        bidiPhaseAlignmentCoarse243;
        bidiPhaseAlignmentCoarse244;
        bidiPhaseAlignmentCoarse245;
        bidiPhaseAlignmentCoarse246;
        bidiPhaseAlignmentCoarse247;
        bidiPhaseAlignmentCoarse248;
        bidiPhaseAlignmentCoarse249; %...
        bidiPhaseAlignmentCoarse250; %bidiPhaseAlignmentCoarse value for fieldSize 6
        bidiPhaseAlignmentCoarse251; %bidiPhaseAlignmentCoarse value for fieldSize 5
    end
    
    %% VISIBLE PROPERTIES
    
    %PDEP properties corresponding directly to 'params' defined by API
%     properties (SetObservable, GetObservable)
%         fieldSize;
%     end
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = PMT(varargin)
            
            %Invoke superclass constructor
            obj = obj@dabs.thorlabs.private.ThorDevice();                                       
                        
            %Invoke superclass initializer
            obj.initialize();
            
            %For ECU2:
            %obj.fieldSizeInfo = obj.paramInfoMap('scanZoomPos');
            
        end
        
        
    end
    
    %% PROPERTY ACCESS
    
    %PDep Property Handling

     methods (Hidden, Access=protected)
        function pdepPropHandleGet(obj,src,evnt)
            disp('Normally, pdepPropHandleGet() would not be used, PR2014.');
%             propName = src.Name;
%             
%             if(~obj.isConnected)
%                 return
%             end
%             
%             switch propName
%                 case {}
%                     sprintf('This function 2 is not implemented and un-commented %s (PR2014)',@obj.getParameterEncoded)
% %                     obj.pdepPropGroupedGet(@obj.getParameterEncoded,src,evnt);
%                 otherwise
%                     sprintf('This function 3 is not implemented and un-commented %s (PR2014)',@obj.getParameterEncoded)
% %                     obj.pdepPropGroupedGet(@obj.getParameterSimple,src,evnt);
%             end
        end
        
        function pdepPropHandleSet(obj,src,evnt)
            disp('Normally, pdepPropHandleGet() would not be used, PR2014.');
%             propName = src.Name;
%         
%              if(~obj.isConnected)
%                 return 
%              end
%              
%              paramCode = obj.paramCodeMap(propName); 
%              paramInfo = obj.paramInfoMap(propName);
% 
%              if(paramInfo.paramAvailable)
%                  propval = obj.(propName);                    
%                  sprintf('This function is not implemented and un-commented %s, %s (PR2014)',paramCode,propval);
% %                  obj.apiCall('SetParam', paramCode, propval);
% %              
% %                 %Following sequence required for property change to take effect
% %                 obj.apiCall('PreflightPosition');
% %                 obj.apiCall('SetupPosition');
% %                 obj.apiCall('StartPosition');
% %                 obj.apiCall('PostflightPosition');
%              end
       
        end
        
     end

    %% DEVELOPER METHODS
    methods 
        function display(obj)
            if isempty((obj.scanZoomPos)) %(obj.fieldSizeInfo.paramAvailable)
                obj.displaySmart({'scanEnable' 'pmtEnable1' 'pmtEnable2' 'pmtGain1' 'pmtGain2'});
            else
                obj.displaySmart({'scanEnable' 'pmtEnable1' 'pmtEnable2' 'pmtGain1' 'pmtGain2' 'scanZoomPos'});            
            end
        end
        
        function [fieldVal,fieldValRaw] = zoom2FieldSize(obj,zoomVal)
%             fieldValRaw = obj.fieldSizeInfo.paramMax / zoomVal;            
            fieldValRaw = 50 / zoomVal;      % PR2014       
            fieldVal = round(fieldValRaw);
        end
        
        function [zoomVal,zoomValRaw] = fieldSize2Zoom(obj,fieldVal)
%             zoomValRaw = obj.fieldSizeInfo.paramMax / fieldVal;            
            zoomValRaw = 50 / fieldVal;            
            zoomVal = round(10 * zoomValRaw) / 10;
        end
    end
    
end

%% HELPERS

function prop2ParamMap = zlclInitProp2ParamMap()

prop2ParamMap = containers.Map('KeyType','char','ValueType','char');

prop2ParamMap('scanEnable') = 'PARAM_SCANNER_ENABLE';
prop2ParamMap('pmtGain1') = 'PARAM_PMT1_GAIN_POS';
prop2ParamMap('pmtGain2') = 'PARAM_PMT2_GAIN_POS';
prop2ParamMap('pmtEnable1') = 'PARAM_PMT1_ENABLE';
prop2ParamMap('pmtEnable2') = 'PARAM_PMT2_ENABLE';
prop2ParamMap('deviceType') = 'PARAM_DEVICE_TYPE';

%Thorlabs: ECU2 related:
prop2ParamMap('scanZoomPos') = 'PARAM_SCANNER_ZOOM_POS';
%prop2ParamMap('fieldSize') = 'PARAM_LSM_FIELD_SIZE';

prop2ParamMap('bidiPhaseAlignmentCoarse1') = 'PARAM_ECU_TWO_WAY_ZONE_1';
prop2ParamMap('bidiPhaseAlignmentCoarse2') = 'PARAM_ECU_TWO_WAY_ZONE_2';
prop2ParamMap('bidiPhaseAlignmentCoarse3') = 'PARAM_ECU_TWO_WAY_ZONE_3';
prop2ParamMap('bidiPhaseAlignmentCoarse4') = 'PARAM_ECU_TWO_WAY_ZONE_4';
prop2ParamMap('bidiPhaseAlignmentCoarse5') = 'PARAM_ECU_TWO_WAY_ZONE_5';
prop2ParamMap('bidiPhaseAlignmentCoarse6') = 'PARAM_ECU_TWO_WAY_ZONE_6';
prop2ParamMap('bidiPhaseAlignmentCoarse7') = 'PARAM_ECU_TWO_WAY_ZONE_7';
prop2ParamMap('bidiPhaseAlignmentCoarse8') = 'PARAM_ECU_TWO_WAY_ZONE_8';
prop2ParamMap('bidiPhaseAlignmentCoarse9') = 'PARAM_ECU_TWO_WAY_ZONE_9';
prop2ParamMap('bidiPhaseAlignmentCoarse10') = 'PARAM_ECU_TWO_WAY_ZONE_10';
prop2ParamMap('bidiPhaseAlignmentCoarse11') = 'PARAM_ECU_TWO_WAY_ZONE_11';
prop2ParamMap('bidiPhaseAlignmentCoarse12') = 'PARAM_ECU_TWO_WAY_ZONE_12';
prop2ParamMap('bidiPhaseAlignmentCoarse13') = 'PARAM_ECU_TWO_WAY_ZONE_13';
prop2ParamMap('bidiPhaseAlignmentCoarse14') = 'PARAM_ECU_TWO_WAY_ZONE_14';
prop2ParamMap('bidiPhaseAlignmentCoarse15') = 'PARAM_ECU_TWO_WAY_ZONE_15';
prop2ParamMap('bidiPhaseAlignmentCoarse16') = 'PARAM_ECU_TWO_WAY_ZONE_16';
prop2ParamMap('bidiPhaseAlignmentCoarse17') = 'PARAM_ECU_TWO_WAY_ZONE_17';
prop2ParamMap('bidiPhaseAlignmentCoarse18') = 'PARAM_ECU_TWO_WAY_ZONE_18';
prop2ParamMap('bidiPhaseAlignmentCoarse19') = 'PARAM_ECU_TWO_WAY_ZONE_19';
prop2ParamMap('bidiPhaseAlignmentCoarse20') = 'PARAM_ECU_TWO_WAY_ZONE_20';
prop2ParamMap('bidiPhaseAlignmentCoarse21') = 'PARAM_ECU_TWO_WAY_ZONE_21';
prop2ParamMap('bidiPhaseAlignmentCoarse22') = 'PARAM_ECU_TWO_WAY_ZONE_22';
prop2ParamMap('bidiPhaseAlignmentCoarse23') = 'PARAM_ECU_TWO_WAY_ZONE_23';
prop2ParamMap('bidiPhaseAlignmentCoarse24') = 'PARAM_ECU_TWO_WAY_ZONE_24';
prop2ParamMap('bidiPhaseAlignmentCoarse25') = 'PARAM_ECU_TWO_WAY_ZONE_25';
prop2ParamMap('bidiPhaseAlignmentCoarse26') = 'PARAM_ECU_TWO_WAY_ZONE_26';
prop2ParamMap('bidiPhaseAlignmentCoarse27') = 'PARAM_ECU_TWO_WAY_ZONE_27';
prop2ParamMap('bidiPhaseAlignmentCoarse28') = 'PARAM_ECU_TWO_WAY_ZONE_28';
prop2ParamMap('bidiPhaseAlignmentCoarse29') = 'PARAM_ECU_TWO_WAY_ZONE_29';
prop2ParamMap('bidiPhaseAlignmentCoarse30') = 'PARAM_ECU_TWO_WAY_ZONE_30';
prop2ParamMap('bidiPhaseAlignmentCoarse31') = 'PARAM_ECU_TWO_WAY_ZONE_31';
prop2ParamMap('bidiPhaseAlignmentCoarse32') = 'PARAM_ECU_TWO_WAY_ZONE_32';
prop2ParamMap('bidiPhaseAlignmentCoarse33') = 'PARAM_ECU_TWO_WAY_ZONE_33';
prop2ParamMap('bidiPhaseAlignmentCoarse34') = 'PARAM_ECU_TWO_WAY_ZONE_34';
prop2ParamMap('bidiPhaseAlignmentCoarse35') = 'PARAM_ECU_TWO_WAY_ZONE_35';
prop2ParamMap('bidiPhaseAlignmentCoarse36') = 'PARAM_ECU_TWO_WAY_ZONE_36';
prop2ParamMap('bidiPhaseAlignmentCoarse37') = 'PARAM_ECU_TWO_WAY_ZONE_37';
prop2ParamMap('bidiPhaseAlignmentCoarse38') = 'PARAM_ECU_TWO_WAY_ZONE_38';
prop2ParamMap('bidiPhaseAlignmentCoarse39') = 'PARAM_ECU_TWO_WAY_ZONE_39';
prop2ParamMap('bidiPhaseAlignmentCoarse40') = 'PARAM_ECU_TWO_WAY_ZONE_40';
prop2ParamMap('bidiPhaseAlignmentCoarse41') = 'PARAM_ECU_TWO_WAY_ZONE_41';
prop2ParamMap('bidiPhaseAlignmentCoarse42') = 'PARAM_ECU_TWO_WAY_ZONE_42';
prop2ParamMap('bidiPhaseAlignmentCoarse43') = 'PARAM_ECU_TWO_WAY_ZONE_43';
prop2ParamMap('bidiPhaseAlignmentCoarse44') = 'PARAM_ECU_TWO_WAY_ZONE_44';
prop2ParamMap('bidiPhaseAlignmentCoarse45') = 'PARAM_ECU_TWO_WAY_ZONE_45';
prop2ParamMap('bidiPhaseAlignmentCoarse46') = 'PARAM_ECU_TWO_WAY_ZONE_46';
prop2ParamMap('bidiPhaseAlignmentCoarse47') = 'PARAM_ECU_TWO_WAY_ZONE_47';
prop2ParamMap('bidiPhaseAlignmentCoarse48') = 'PARAM_ECU_TWO_WAY_ZONE_48';
prop2ParamMap('bidiPhaseAlignmentCoarse49') = 'PARAM_ECU_TWO_WAY_ZONE_49';
prop2ParamMap('bidiPhaseAlignmentCoarse50') = 'PARAM_ECU_TWO_WAY_ZONE_50';
prop2ParamMap('bidiPhaseAlignmentCoarse51') = 'PARAM_ECU_TWO_WAY_ZONE_51';
prop2ParamMap('bidiPhaseAlignmentCoarse52') = 'PARAM_ECU_TWO_WAY_ZONE_52';
prop2ParamMap('bidiPhaseAlignmentCoarse53') = 'PARAM_ECU_TWO_WAY_ZONE_53';
prop2ParamMap('bidiPhaseAlignmentCoarse54') = 'PARAM_ECU_TWO_WAY_ZONE_54';
prop2ParamMap('bidiPhaseAlignmentCoarse55') = 'PARAM_ECU_TWO_WAY_ZONE_55';
prop2ParamMap('bidiPhaseAlignmentCoarse56') = 'PARAM_ECU_TWO_WAY_ZONE_56';
prop2ParamMap('bidiPhaseAlignmentCoarse57') = 'PARAM_ECU_TWO_WAY_ZONE_57';
prop2ParamMap('bidiPhaseAlignmentCoarse58') = 'PARAM_ECU_TWO_WAY_ZONE_58';
prop2ParamMap('bidiPhaseAlignmentCoarse59') = 'PARAM_ECU_TWO_WAY_ZONE_59';
prop2ParamMap('bidiPhaseAlignmentCoarse60') = 'PARAM_ECU_TWO_WAY_ZONE_60';
prop2ParamMap('bidiPhaseAlignmentCoarse61') = 'PARAM_ECU_TWO_WAY_ZONE_61';
prop2ParamMap('bidiPhaseAlignmentCoarse62') = 'PARAM_ECU_TWO_WAY_ZONE_62';
prop2ParamMap('bidiPhaseAlignmentCoarse63') = 'PARAM_ECU_TWO_WAY_ZONE_63';
prop2ParamMap('bidiPhaseAlignmentCoarse64') = 'PARAM_ECU_TWO_WAY_ZONE_64';
prop2ParamMap('bidiPhaseAlignmentCoarse65') = 'PARAM_ECU_TWO_WAY_ZONE_65';
prop2ParamMap('bidiPhaseAlignmentCoarse66') = 'PARAM_ECU_TWO_WAY_ZONE_66';
prop2ParamMap('bidiPhaseAlignmentCoarse67') = 'PARAM_ECU_TWO_WAY_ZONE_67';
prop2ParamMap('bidiPhaseAlignmentCoarse68') = 'PARAM_ECU_TWO_WAY_ZONE_68';
prop2ParamMap('bidiPhaseAlignmentCoarse69') = 'PARAM_ECU_TWO_WAY_ZONE_69';
prop2ParamMap('bidiPhaseAlignmentCoarse70') = 'PARAM_ECU_TWO_WAY_ZONE_70';
prop2ParamMap('bidiPhaseAlignmentCoarse71') = 'PARAM_ECU_TWO_WAY_ZONE_71';
prop2ParamMap('bidiPhaseAlignmentCoarse72') = 'PARAM_ECU_TWO_WAY_ZONE_72';
prop2ParamMap('bidiPhaseAlignmentCoarse73') = 'PARAM_ECU_TWO_WAY_ZONE_73';
prop2ParamMap('bidiPhaseAlignmentCoarse74') = 'PARAM_ECU_TWO_WAY_ZONE_74';
prop2ParamMap('bidiPhaseAlignmentCoarse75') = 'PARAM_ECU_TWO_WAY_ZONE_75';
prop2ParamMap('bidiPhaseAlignmentCoarse76') = 'PARAM_ECU_TWO_WAY_ZONE_76';
prop2ParamMap('bidiPhaseAlignmentCoarse77') = 'PARAM_ECU_TWO_WAY_ZONE_77';
prop2ParamMap('bidiPhaseAlignmentCoarse78') = 'PARAM_ECU_TWO_WAY_ZONE_78';
prop2ParamMap('bidiPhaseAlignmentCoarse79') = 'PARAM_ECU_TWO_WAY_ZONE_79';
prop2ParamMap('bidiPhaseAlignmentCoarse80') = 'PARAM_ECU_TWO_WAY_ZONE_80';
prop2ParamMap('bidiPhaseAlignmentCoarse81') = 'PARAM_ECU_TWO_WAY_ZONE_81';
prop2ParamMap('bidiPhaseAlignmentCoarse82') = 'PARAM_ECU_TWO_WAY_ZONE_82';
prop2ParamMap('bidiPhaseAlignmentCoarse83') = 'PARAM_ECU_TWO_WAY_ZONE_83';
prop2ParamMap('bidiPhaseAlignmentCoarse84') = 'PARAM_ECU_TWO_WAY_ZONE_84';
prop2ParamMap('bidiPhaseAlignmentCoarse85') = 'PARAM_ECU_TWO_WAY_ZONE_85';
prop2ParamMap('bidiPhaseAlignmentCoarse86') = 'PARAM_ECU_TWO_WAY_ZONE_86';
prop2ParamMap('bidiPhaseAlignmentCoarse87') = 'PARAM_ECU_TWO_WAY_ZONE_87';
prop2ParamMap('bidiPhaseAlignmentCoarse88') = 'PARAM_ECU_TWO_WAY_ZONE_88';
prop2ParamMap('bidiPhaseAlignmentCoarse89') = 'PARAM_ECU_TWO_WAY_ZONE_89';
prop2ParamMap('bidiPhaseAlignmentCoarse90') = 'PARAM_ECU_TWO_WAY_ZONE_90';
prop2ParamMap('bidiPhaseAlignmentCoarse91') = 'PARAM_ECU_TWO_WAY_ZONE_91';
prop2ParamMap('bidiPhaseAlignmentCoarse92') = 'PARAM_ECU_TWO_WAY_ZONE_92';
prop2ParamMap('bidiPhaseAlignmentCoarse93') = 'PARAM_ECU_TWO_WAY_ZONE_93';
prop2ParamMap('bidiPhaseAlignmentCoarse94') = 'PARAM_ECU_TWO_WAY_ZONE_94';
prop2ParamMap('bidiPhaseAlignmentCoarse95') = 'PARAM_ECU_TWO_WAY_ZONE_95';
prop2ParamMap('bidiPhaseAlignmentCoarse96') = 'PARAM_ECU_TWO_WAY_ZONE_96';
prop2ParamMap('bidiPhaseAlignmentCoarse97') = 'PARAM_ECU_TWO_WAY_ZONE_97';
prop2ParamMap('bidiPhaseAlignmentCoarse98') = 'PARAM_ECU_TWO_WAY_ZONE_98';
prop2ParamMap('bidiPhaseAlignmentCoarse99') = 'PARAM_ECU_TWO_WAY_ZONE_99';
prop2ParamMap('bidiPhaseAlignmentCoarse100') = 'PARAM_ECU_TWO_WAY_ZONE_100';
prop2ParamMap('bidiPhaseAlignmentCoarse101') = 'PARAM_ECU_TWO_WAY_ZONE_101';
prop2ParamMap('bidiPhaseAlignmentCoarse102') = 'PARAM_ECU_TWO_WAY_ZONE_102';
prop2ParamMap('bidiPhaseAlignmentCoarse103') = 'PARAM_ECU_TWO_WAY_ZONE_103';
prop2ParamMap('bidiPhaseAlignmentCoarse104') = 'PARAM_ECU_TWO_WAY_ZONE_104';
prop2ParamMap('bidiPhaseAlignmentCoarse105') = 'PARAM_ECU_TWO_WAY_ZONE_105';
prop2ParamMap('bidiPhaseAlignmentCoarse106') = 'PARAM_ECU_TWO_WAY_ZONE_106';
prop2ParamMap('bidiPhaseAlignmentCoarse107') = 'PARAM_ECU_TWO_WAY_ZONE_107';
prop2ParamMap('bidiPhaseAlignmentCoarse108') = 'PARAM_ECU_TWO_WAY_ZONE_108';
prop2ParamMap('bidiPhaseAlignmentCoarse109') = 'PARAM_ECU_TWO_WAY_ZONE_109';
prop2ParamMap('bidiPhaseAlignmentCoarse110') = 'PARAM_ECU_TWO_WAY_ZONE_110';
prop2ParamMap('bidiPhaseAlignmentCoarse111') = 'PARAM_ECU_TWO_WAY_ZONE_111';
prop2ParamMap('bidiPhaseAlignmentCoarse112') = 'PARAM_ECU_TWO_WAY_ZONE_112';
prop2ParamMap('bidiPhaseAlignmentCoarse113') = 'PARAM_ECU_TWO_WAY_ZONE_113';
prop2ParamMap('bidiPhaseAlignmentCoarse114') = 'PARAM_ECU_TWO_WAY_ZONE_114';
prop2ParamMap('bidiPhaseAlignmentCoarse115') = 'PARAM_ECU_TWO_WAY_ZONE_115';
prop2ParamMap('bidiPhaseAlignmentCoarse116') = 'PARAM_ECU_TWO_WAY_ZONE_116';
prop2ParamMap('bidiPhaseAlignmentCoarse117') = 'PARAM_ECU_TWO_WAY_ZONE_117';
prop2ParamMap('bidiPhaseAlignmentCoarse118') = 'PARAM_ECU_TWO_WAY_ZONE_118';
prop2ParamMap('bidiPhaseAlignmentCoarse119') = 'PARAM_ECU_TWO_WAY_ZONE_119';
prop2ParamMap('bidiPhaseAlignmentCoarse120') = 'PARAM_ECU_TWO_WAY_ZONE_120';
prop2ParamMap('bidiPhaseAlignmentCoarse121') = 'PARAM_ECU_TWO_WAY_ZONE_121';
prop2ParamMap('bidiPhaseAlignmentCoarse122') = 'PARAM_ECU_TWO_WAY_ZONE_122';
prop2ParamMap('bidiPhaseAlignmentCoarse123') = 'PARAM_ECU_TWO_WAY_ZONE_123';
prop2ParamMap('bidiPhaseAlignmentCoarse124') = 'PARAM_ECU_TWO_WAY_ZONE_124';
prop2ParamMap('bidiPhaseAlignmentCoarse125') = 'PARAM_ECU_TWO_WAY_ZONE_125';
prop2ParamMap('bidiPhaseAlignmentCoarse126') = 'PARAM_ECU_TWO_WAY_ZONE_126';
prop2ParamMap('bidiPhaseAlignmentCoarse127') = 'PARAM_ECU_TWO_WAY_ZONE_127';
prop2ParamMap('bidiPhaseAlignmentCoarse128') = 'PARAM_ECU_TWO_WAY_ZONE_128';
prop2ParamMap('bidiPhaseAlignmentCoarse129') = 'PARAM_ECU_TWO_WAY_ZONE_129';
prop2ParamMap('bidiPhaseAlignmentCoarse130') = 'PARAM_ECU_TWO_WAY_ZONE_130';
prop2ParamMap('bidiPhaseAlignmentCoarse131') = 'PARAM_ECU_TWO_WAY_ZONE_131';
prop2ParamMap('bidiPhaseAlignmentCoarse132') = 'PARAM_ECU_TWO_WAY_ZONE_132';
prop2ParamMap('bidiPhaseAlignmentCoarse133') = 'PARAM_ECU_TWO_WAY_ZONE_133';
prop2ParamMap('bidiPhaseAlignmentCoarse134') = 'PARAM_ECU_TWO_WAY_ZONE_134';
prop2ParamMap('bidiPhaseAlignmentCoarse135') = 'PARAM_ECU_TWO_WAY_ZONE_135';
prop2ParamMap('bidiPhaseAlignmentCoarse136') = 'PARAM_ECU_TWO_WAY_ZONE_136';
prop2ParamMap('bidiPhaseAlignmentCoarse137') = 'PARAM_ECU_TWO_WAY_ZONE_137';
prop2ParamMap('bidiPhaseAlignmentCoarse138') = 'PARAM_ECU_TWO_WAY_ZONE_138';
prop2ParamMap('bidiPhaseAlignmentCoarse139') = 'PARAM_ECU_TWO_WAY_ZONE_139';
prop2ParamMap('bidiPhaseAlignmentCoarse140') = 'PARAM_ECU_TWO_WAY_ZONE_140';
prop2ParamMap('bidiPhaseAlignmentCoarse141') = 'PARAM_ECU_TWO_WAY_ZONE_141';
prop2ParamMap('bidiPhaseAlignmentCoarse142') = 'PARAM_ECU_TWO_WAY_ZONE_142';
prop2ParamMap('bidiPhaseAlignmentCoarse143') = 'PARAM_ECU_TWO_WAY_ZONE_143';
prop2ParamMap('bidiPhaseAlignmentCoarse144') = 'PARAM_ECU_TWO_WAY_ZONE_144';
prop2ParamMap('bidiPhaseAlignmentCoarse145') = 'PARAM_ECU_TWO_WAY_ZONE_145';
prop2ParamMap('bidiPhaseAlignmentCoarse146') = 'PARAM_ECU_TWO_WAY_ZONE_146';
prop2ParamMap('bidiPhaseAlignmentCoarse147') = 'PARAM_ECU_TWO_WAY_ZONE_147';
prop2ParamMap('bidiPhaseAlignmentCoarse148') = 'PARAM_ECU_TWO_WAY_ZONE_148';
prop2ParamMap('bidiPhaseAlignmentCoarse149') = 'PARAM_ECU_TWO_WAY_ZONE_149';
prop2ParamMap('bidiPhaseAlignmentCoarse150') = 'PARAM_ECU_TWO_WAY_ZONE_150';
prop2ParamMap('bidiPhaseAlignmentCoarse151') = 'PARAM_ECU_TWO_WAY_ZONE_151';
prop2ParamMap('bidiPhaseAlignmentCoarse152') = 'PARAM_ECU_TWO_WAY_ZONE_152';
prop2ParamMap('bidiPhaseAlignmentCoarse153') = 'PARAM_ECU_TWO_WAY_ZONE_153';
prop2ParamMap('bidiPhaseAlignmentCoarse154') = 'PARAM_ECU_TWO_WAY_ZONE_154';
prop2ParamMap('bidiPhaseAlignmentCoarse155') = 'PARAM_ECU_TWO_WAY_ZONE_155';
prop2ParamMap('bidiPhaseAlignmentCoarse156') = 'PARAM_ECU_TWO_WAY_ZONE_156';
prop2ParamMap('bidiPhaseAlignmentCoarse157') = 'PARAM_ECU_TWO_WAY_ZONE_157';
prop2ParamMap('bidiPhaseAlignmentCoarse158') = 'PARAM_ECU_TWO_WAY_ZONE_158';
prop2ParamMap('bidiPhaseAlignmentCoarse159') = 'PARAM_ECU_TWO_WAY_ZONE_159';
prop2ParamMap('bidiPhaseAlignmentCoarse160') = 'PARAM_ECU_TWO_WAY_ZONE_160';
prop2ParamMap('bidiPhaseAlignmentCoarse161') = 'PARAM_ECU_TWO_WAY_ZONE_161';
prop2ParamMap('bidiPhaseAlignmentCoarse162') = 'PARAM_ECU_TWO_WAY_ZONE_162';
prop2ParamMap('bidiPhaseAlignmentCoarse163') = 'PARAM_ECU_TWO_WAY_ZONE_163';
prop2ParamMap('bidiPhaseAlignmentCoarse164') = 'PARAM_ECU_TWO_WAY_ZONE_164';
prop2ParamMap('bidiPhaseAlignmentCoarse165') = 'PARAM_ECU_TWO_WAY_ZONE_165';
prop2ParamMap('bidiPhaseAlignmentCoarse166') = 'PARAM_ECU_TWO_WAY_ZONE_166';
prop2ParamMap('bidiPhaseAlignmentCoarse167') = 'PARAM_ECU_TWO_WAY_ZONE_167';
prop2ParamMap('bidiPhaseAlignmentCoarse168') = 'PARAM_ECU_TWO_WAY_ZONE_168';
prop2ParamMap('bidiPhaseAlignmentCoarse169') = 'PARAM_ECU_TWO_WAY_ZONE_169';
prop2ParamMap('bidiPhaseAlignmentCoarse170') = 'PARAM_ECU_TWO_WAY_ZONE_170';
prop2ParamMap('bidiPhaseAlignmentCoarse171') = 'PARAM_ECU_TWO_WAY_ZONE_171';
prop2ParamMap('bidiPhaseAlignmentCoarse172') = 'PARAM_ECU_TWO_WAY_ZONE_172';
prop2ParamMap('bidiPhaseAlignmentCoarse173') = 'PARAM_ECU_TWO_WAY_ZONE_173';
prop2ParamMap('bidiPhaseAlignmentCoarse174') = 'PARAM_ECU_TWO_WAY_ZONE_174';
prop2ParamMap('bidiPhaseAlignmentCoarse175') = 'PARAM_ECU_TWO_WAY_ZONE_175';
prop2ParamMap('bidiPhaseAlignmentCoarse176') = 'PARAM_ECU_TWO_WAY_ZONE_176';
prop2ParamMap('bidiPhaseAlignmentCoarse177') = 'PARAM_ECU_TWO_WAY_ZONE_177';
prop2ParamMap('bidiPhaseAlignmentCoarse178') = 'PARAM_ECU_TWO_WAY_ZONE_178';
prop2ParamMap('bidiPhaseAlignmentCoarse179') = 'PARAM_ECU_TWO_WAY_ZONE_179';
prop2ParamMap('bidiPhaseAlignmentCoarse180') = 'PARAM_ECU_TWO_WAY_ZONE_180';
prop2ParamMap('bidiPhaseAlignmentCoarse181') = 'PARAM_ECU_TWO_WAY_ZONE_181';
prop2ParamMap('bidiPhaseAlignmentCoarse182') = 'PARAM_ECU_TWO_WAY_ZONE_182';
prop2ParamMap('bidiPhaseAlignmentCoarse183') = 'PARAM_ECU_TWO_WAY_ZONE_183';
prop2ParamMap('bidiPhaseAlignmentCoarse184') = 'PARAM_ECU_TWO_WAY_ZONE_184';
prop2ParamMap('bidiPhaseAlignmentCoarse185') = 'PARAM_ECU_TWO_WAY_ZONE_185';
prop2ParamMap('bidiPhaseAlignmentCoarse186') = 'PARAM_ECU_TWO_WAY_ZONE_186';
prop2ParamMap('bidiPhaseAlignmentCoarse187') = 'PARAM_ECU_TWO_WAY_ZONE_187';
prop2ParamMap('bidiPhaseAlignmentCoarse188') = 'PARAM_ECU_TWO_WAY_ZONE_188';
prop2ParamMap('bidiPhaseAlignmentCoarse189') = 'PARAM_ECU_TWO_WAY_ZONE_189';
prop2ParamMap('bidiPhaseAlignmentCoarse190') = 'PARAM_ECU_TWO_WAY_ZONE_190';
prop2ParamMap('bidiPhaseAlignmentCoarse191') = 'PARAM_ECU_TWO_WAY_ZONE_191';
prop2ParamMap('bidiPhaseAlignmentCoarse192') = 'PARAM_ECU_TWO_WAY_ZONE_192';
prop2ParamMap('bidiPhaseAlignmentCoarse193') = 'PARAM_ECU_TWO_WAY_ZONE_193';
prop2ParamMap('bidiPhaseAlignmentCoarse194') = 'PARAM_ECU_TWO_WAY_ZONE_194';
prop2ParamMap('bidiPhaseAlignmentCoarse195') = 'PARAM_ECU_TWO_WAY_ZONE_195';
prop2ParamMap('bidiPhaseAlignmentCoarse196') = 'PARAM_ECU_TWO_WAY_ZONE_196';
prop2ParamMap('bidiPhaseAlignmentCoarse197') = 'PARAM_ECU_TWO_WAY_ZONE_197';
prop2ParamMap('bidiPhaseAlignmentCoarse198') = 'PARAM_ECU_TWO_WAY_ZONE_198';
prop2ParamMap('bidiPhaseAlignmentCoarse199') = 'PARAM_ECU_TWO_WAY_ZONE_199';
prop2ParamMap('bidiPhaseAlignmentCoarse200') = 'PARAM_ECU_TWO_WAY_ZONE_200';
prop2ParamMap('bidiPhaseAlignmentCoarse201') = 'PARAM_ECU_TWO_WAY_ZONE_201';
prop2ParamMap('bidiPhaseAlignmentCoarse202') = 'PARAM_ECU_TWO_WAY_ZONE_202';
prop2ParamMap('bidiPhaseAlignmentCoarse203') = 'PARAM_ECU_TWO_WAY_ZONE_203';
prop2ParamMap('bidiPhaseAlignmentCoarse204') = 'PARAM_ECU_TWO_WAY_ZONE_204';
prop2ParamMap('bidiPhaseAlignmentCoarse205') = 'PARAM_ECU_TWO_WAY_ZONE_205';
prop2ParamMap('bidiPhaseAlignmentCoarse206') = 'PARAM_ECU_TWO_WAY_ZONE_206';
prop2ParamMap('bidiPhaseAlignmentCoarse207') = 'PARAM_ECU_TWO_WAY_ZONE_207';
prop2ParamMap('bidiPhaseAlignmentCoarse208') = 'PARAM_ECU_TWO_WAY_ZONE_208';
prop2ParamMap('bidiPhaseAlignmentCoarse209') = 'PARAM_ECU_TWO_WAY_ZONE_209';
prop2ParamMap('bidiPhaseAlignmentCoarse210') = 'PARAM_ECU_TWO_WAY_ZONE_210';
prop2ParamMap('bidiPhaseAlignmentCoarse211') = 'PARAM_ECU_TWO_WAY_ZONE_211';
prop2ParamMap('bidiPhaseAlignmentCoarse212') = 'PARAM_ECU_TWO_WAY_ZONE_212';
prop2ParamMap('bidiPhaseAlignmentCoarse213') = 'PARAM_ECU_TWO_WAY_ZONE_213';
prop2ParamMap('bidiPhaseAlignmentCoarse214') = 'PARAM_ECU_TWO_WAY_ZONE_214';
prop2ParamMap('bidiPhaseAlignmentCoarse215') = 'PARAM_ECU_TWO_WAY_ZONE_215';
prop2ParamMap('bidiPhaseAlignmentCoarse216') = 'PARAM_ECU_TWO_WAY_ZONE_216';
prop2ParamMap('bidiPhaseAlignmentCoarse217') = 'PARAM_ECU_TWO_WAY_ZONE_217';
prop2ParamMap('bidiPhaseAlignmentCoarse218') = 'PARAM_ECU_TWO_WAY_ZONE_218';
prop2ParamMap('bidiPhaseAlignmentCoarse219') = 'PARAM_ECU_TWO_WAY_ZONE_219';
prop2ParamMap('bidiPhaseAlignmentCoarse220') = 'PARAM_ECU_TWO_WAY_ZONE_220';
prop2ParamMap('bidiPhaseAlignmentCoarse221') = 'PARAM_ECU_TWO_WAY_ZONE_221';
prop2ParamMap('bidiPhaseAlignmentCoarse222') = 'PARAM_ECU_TWO_WAY_ZONE_222';
prop2ParamMap('bidiPhaseAlignmentCoarse223') = 'PARAM_ECU_TWO_WAY_ZONE_223';
prop2ParamMap('bidiPhaseAlignmentCoarse224') = 'PARAM_ECU_TWO_WAY_ZONE_224';
prop2ParamMap('bidiPhaseAlignmentCoarse225') = 'PARAM_ECU_TWO_WAY_ZONE_225';
prop2ParamMap('bidiPhaseAlignmentCoarse226') = 'PARAM_ECU_TWO_WAY_ZONE_226';
prop2ParamMap('bidiPhaseAlignmentCoarse227') = 'PARAM_ECU_TWO_WAY_ZONE_227';
prop2ParamMap('bidiPhaseAlignmentCoarse228') = 'PARAM_ECU_TWO_WAY_ZONE_228';
prop2ParamMap('bidiPhaseAlignmentCoarse229') = 'PARAM_ECU_TWO_WAY_ZONE_229';
prop2ParamMap('bidiPhaseAlignmentCoarse230') = 'PARAM_ECU_TWO_WAY_ZONE_230';
prop2ParamMap('bidiPhaseAlignmentCoarse231') = 'PARAM_ECU_TWO_WAY_ZONE_231';
prop2ParamMap('bidiPhaseAlignmentCoarse232') = 'PARAM_ECU_TWO_WAY_ZONE_232';
prop2ParamMap('bidiPhaseAlignmentCoarse233') = 'PARAM_ECU_TWO_WAY_ZONE_233';
prop2ParamMap('bidiPhaseAlignmentCoarse234') = 'PARAM_ECU_TWO_WAY_ZONE_234';
prop2ParamMap('bidiPhaseAlignmentCoarse235') = 'PARAM_ECU_TWO_WAY_ZONE_235';
prop2ParamMap('bidiPhaseAlignmentCoarse236') = 'PARAM_ECU_TWO_WAY_ZONE_236';
prop2ParamMap('bidiPhaseAlignmentCoarse237') = 'PARAM_ECU_TWO_WAY_ZONE_237';
prop2ParamMap('bidiPhaseAlignmentCoarse238') = 'PARAM_ECU_TWO_WAY_ZONE_238';
prop2ParamMap('bidiPhaseAlignmentCoarse239') = 'PARAM_ECU_TWO_WAY_ZONE_239';
prop2ParamMap('bidiPhaseAlignmentCoarse240') = 'PARAM_ECU_TWO_WAY_ZONE_240';
prop2ParamMap('bidiPhaseAlignmentCoarse241') = 'PARAM_ECU_TWO_WAY_ZONE_241';
prop2ParamMap('bidiPhaseAlignmentCoarse242') = 'PARAM_ECU_TWO_WAY_ZONE_242';
prop2ParamMap('bidiPhaseAlignmentCoarse243') = 'PARAM_ECU_TWO_WAY_ZONE_243';
prop2ParamMap('bidiPhaseAlignmentCoarse244') = 'PARAM_ECU_TWO_WAY_ZONE_244';
prop2ParamMap('bidiPhaseAlignmentCoarse245') = 'PARAM_ECU_TWO_WAY_ZONE_245';
prop2ParamMap('bidiPhaseAlignmentCoarse246') = 'PARAM_ECU_TWO_WAY_ZONE_246';
prop2ParamMap('bidiPhaseAlignmentCoarse247') = 'PARAM_ECU_TWO_WAY_ZONE_247';
prop2ParamMap('bidiPhaseAlignmentCoarse248') = 'PARAM_ECU_TWO_WAY_ZONE_248';
prop2ParamMap('bidiPhaseAlignmentCoarse249') = 'PARAM_ECU_TWO_WAY_ZONE_249';
prop2ParamMap('bidiPhaseAlignmentCoarse250') = 'PARAM_ECU_TWO_WAY_ZONE_250';
prop2ParamMap('bidiPhaseAlignmentCoarse251') = 'PARAM_ECU_TWO_WAY_ZONE_251';
%TODO: Fill in others!


end


% function apiHeaderFilenamesMap = mapInitApiHeaderFilenames()
% 
% apiHeaderFilenamesMap = containers.Map();
% 
% apiHeaderFilenamesMap('0.1.1') = 'PMT_SDK_0_1_1_MOD.h';
% 
% end
