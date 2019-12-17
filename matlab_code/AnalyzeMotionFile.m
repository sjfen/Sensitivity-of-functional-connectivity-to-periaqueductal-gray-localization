%create data to check for differences in head motion between patients and
%healthy control

function AnalysisOutput = AnalyzeMotionFile(AnalysisInput)

% AnalysisInput
% .Files - cell array of data files for all selected trials
% .HelperFunctions - cell array of helper functions to be used with EnableHelperFunction
% .PathSep - / in mac and \ in windows
%
% don't forget to save your result appropriately

BaseDirectory = cd;

try
    
    set(AnalysisInput.ProgramStatusIndicator,'string',[mfilename ':Running ...'],'foregroundcolor','g');drawnow;
    
    %----------- Your code here !!! ---------------
    
    InputPath = '/Volumes/AmplStorage2/Experiments/preproc/';
    
    strsep = EnableHelperFunction([],'strsep.m');
    
%     [path1,file1,ext1] = fileparts(mfilename('fullpath'));
%     load([path1 filesep 'PowerROI.mat']);
    AfniSetupString = 'export PATH=$PATH:/Users/amplmember/abin';
    NumPart = length(AnalysisInput.Files);
    
    
     l = 1;
     k = 1;
     a = 1;
     b = 1;
     c = 1;
     d = 1;
    for i = 1:NumPart
        
        i
        
        
        load(AnalysisInput.Files{i});
        
        id_name = Participant.MappId;
        id_name_results = [id_name '.rest.results'];
        
        ResultsFolder = [InputPath id_name filesep 'SUMA' filesep id_name_results filesep];
        DataFolder = '/Volumes/AmplStorage2/Experiments/StatsData/PAG/Stats_PAG_10122018/VoxelBased_Correlation/AFNI_Voxelwise/HealthyPatients/AllData_ttest_check/';
        
%         MetaDataPath = ['/Volumes/AmplStorage2/Experiments/MAPP/' id_name '/' id_name '_Meta.mat'];
        MetaDataPath = ['/Volumes/AmplStorage2/Experiments/MAPP/' id_name '/' id_name '.mat']; %changed for 201101340
        
        MotionDataPath = [ResultsFolder 'motion_' id_name '.rest_enorm.1D']; %changed for 201101340'];
%         NewMotionDataPath = [ResultsFolder 'motion_' id_name '.rest_enorm.1D];
        
        pb04file = [ResultsFolder 'pb04.' id_name '.rest.r01.blur+tlrc.HEAD'];
        errtsfile = [ResultsFolder 'errts.' id_name '.rest.anaticor+tlrc.HEAD'];
        

        if exist(MetaDataPath, 'file')==2      
            if exist(pb04file,'file')==2 & exist(errtsfile,'file')==2
                
%                 command = ['1d_tool.py -infile ' MotionDataPath '-write ' MotionDataPath(end-2) 'txt']
%                 system
 
                
                MetaDataFile = load(MetaDataPath);
                MotionDataFile = load(MotionDataPath);
                %cohort index
%                 cohortind = find(strcmp({MetaDataFile.TrialMeta.MappMeta.Name}, 'cohorttype') == 1);
%                 cohortval = MetaDataFile.TrialMeta.MappMeta(cohortind).Value;
                
                cohortind = find(strcmp({MetaDataFile.Participant.Visit(1).Modality(1).Data.Name}, 'cohorttype') == 1); %changed for 201101340
                cohortval = MetaDataFile.Participant.Visit(1).Modality(1).Data(cohortind).Value;
                
                
                %sex index
%                 sexind = find(strcmp({MetaDataFile.TrialMeta.MappMeta.Name}, 'sex') == 1);
%                 sexval = MetaDataFile.TrialMeta.MappMeta(sexind).Value; 
                
                sexind = find(strcmp({MetaDataFile.Participant.Visit(1).Modality(1).Data.Name}, 'sex') == 1); %changed for 201101340
                sexval = MetaDataFile.Participant.Visit(1).Modality(1).Data(sexind).Value;
                
                %site index
%                 siteind = find(strcmp({MetaDataFile.TrialMeta.MappMeta.Name}, 'siteid') == 1);
%                 siteval = MetaDataFile.TrialMeta.MappMeta(siteind).Value;  
 
                siteind = find(strcmp({MetaDataFile.Participant.Visit(1).Modality(1).Data.Name}, 'siteid') == 1);%changed for 201101340
                siteval = MetaDataFile.Participant.Visit(1).Modality(1).Data(siteind).Value;
                
                
                if cohortval == 2 & sexval == 1
                
                MotionHC_M(a,:) = MotionDataFile(2:end);    
                sexHC_M(a) = sexval;
                siteHC_M(a) = siteval;
                id_nameHC_M(a) = str2num(id_name);
                a = a+1;
                    
                
                elseif cohortval == 2 & sexval == 2

                MotionHC_F(b,:) = MotionDataFile(2:end);    
                sexHC_F(b) = sexval;
                siteHC_F(b) = siteval;
                id_nameHC_F(b) = str2num(id_name);
                b = b+1;
                    
                elseif cohortval == 1 & sexval == 1;
 
                MotionP_M(c,:) = MotionDataFile(2:end);
                sexP_M(c) = sexval;
                siteP_M(c) = siteval;
                id_nameP_M(c) = str2num(id_name);
                c = c+1;
                
                elseif cohortval == 1 & sexval == 2;
                
                MotionP_F(d,:) = MotionDataFile(2:end);
                sexP_F(d) = sexval;
                siteP_F(d) = siteval;
                id_nameP_F(d) = str2num(id_name);
                d = d+1;
                

                else
                    MetaAlt{k} = id_name;
                    k = k+1;
                end
                      
                
                
            end
        else
            NoMeta{l} = id_name;
            l = l+1;
        end
    end

k;
    
catch err
    set(AnalysisInput.ProgramStatusIndicator,'string',[mfilename ':had an error. See Matlab window for details.'],'foregroundcolor','g');drawnow;
    cd(BaseDirectory);
    rethrow(err);
end

AnalysisOutput = 1;