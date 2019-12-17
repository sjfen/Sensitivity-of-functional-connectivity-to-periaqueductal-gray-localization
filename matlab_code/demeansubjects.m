%demean subjects used in voxelwise group analysis

function AnalysisOutput = demeansubjects(AnalysisInput)

% AnalysisInput
% .Files - cell array of data files for all selected trials
% .HelperFunctions - cell array of helper functions to be used with EnableHelperFunction
% .PathSep - / in mac and \ in windows
%
% don't forget to save your result appropriately

%change MNI to Wei through search and replace!

BaseDirectory = cd;

try
    
    set(AnalysisInput.ProgramStatusIndicator,'string',[mfilename ':Running ...'],'foregroundcolor','g');drawnow;
    
    %----------- Your code here !!! ---------------
    
    InputPath = '/Volumes/AmplStorage2/Experiments/preproc/';
    
    strsep = EnableHelperFunction([],'strsep.m');
    
    AfniSetupString = 'export PATH=$PATH:/Users/amplmember/abin';
    NumPart = length(AnalysisInput.Files);
    
    
    l = 1; %for subjects without a meta file
    k = 1; %for subjects that were not included in criteria
    
    for i = 1:NumPart
        load(AnalysisInput.Files{i});
        
        id_name = Participant.MappId; 
        id_name_results = [id_name '.rest.results'];
        
        ResultsFolder = [InputPath id_name filesep 'SUMA' filesep id_name_results filesep];
        DataFolder = '/Volumes/AmplStorage2/Experiments/StatsData/PAG/Stats_PAG_10122018/VoxelBased_Correlation/AFNI_Voxelwise/HealthyPatients/AllData_ttest_check/';
        
        MetaDataPath = ['/Volumes/AmplStorage2/Experiments/MAPP/' id_name '/' id_name '.mat']; %changed for 201101340
        
        pb04file = [ResultsFolder 'pb04.' id_name '.rest.r01.blur+tlrc.HEAD'];
        errtsfile = [ResultsFolder 'errts.' id_name '.rest.anaticor+tlrc.HEAD'];
        
        %test whether files exist in folder:
        if exist(MetaDataPath, 'file')==2
            if exist(pb04file,'file')==2 & exist(errtsfile,'file')==2

                MetaDataFile = load(MetaDataPath);
                
                cohortind = find(strcmp({MetaDataFile.Participant.Visit(1).Modality(1).Data.Name}, 'cohorttype') == 1); %changed for 201101340
                cohortval = MetaDataFile.Participant.Visit(1).Modality(1).Data(cohortind).Value;

                sexind = find(strcmp({MetaDataFile.Participant.Visit(1).Modality(1).Data.Name}, 'sex') == 1); %changed for 201101340
                sexval = MetaDataFile.Participant.Visit(1).Modality(1).Data(sexind).Value;
                
                siteind = find(strcmp({MetaDataFile.Participant.Visit(1).Modality(1).Data.Name}, 'siteid') == 1);%changed for 201101340
                siteval = MetaDataFile.Participant.Visit(1).Modality(1).Data(siteind).Value;
                
                %select site that you want to use to demean
                s = num2str(siteval)
                s1 = str2double(s(1));
                s1string = s(1);
                
                  command1 = ['cd ' DataFolder]; %go to the folder which stores mean site values
                  command2 = ['3dcalc -prefix HealthyControl/Male/demean/zcoefWei_' id_name '+tlrc.HEAD -a HealthyControl/Male/zcoefWei_' id_name '+tlrc.HEAD -b meanWei0' s1string '+tlrc. -expr ''a-b''']
                  command3 = ['3dcalc -prefix HealthyControl/Female/demean/zcoefWei_' id_name '+tlrc.HEAD -a HealthyControl/Female/zcoefWei_' id_name '+tlrc.HEAD -b meanWei0' s1string '+tlrc. -expr ''a-b''']
                  command4 = ['3dcalc -prefix Patients/Male/demean/zcoefWei_' id_name '+tlrc.HEAD -a Patients/Male/zcoefWei_' id_name '+tlrc.HEAD -b meanWei0' s1string '+tlrc. -expr ''a-b''']
                  command5 = ['3dcalc -prefix Patients/Female/demean/zcoefWei_' id_name '+tlrc.HEAD -a Patients/Female/zcoefWei_' id_name '+tlrc.HEAD -b meanWei0' s1string '+tlrc. -expr ''a-b''']

                
                if cohortval == 2 & sexval == 1 % healthy control and male
                    [status,result] = system([command1 ' ; ' command2]);
                elseif cohortval == 2 & sexval == 2 % healthy control and female
                    [status,result] = system([command1 ' ; ' command3]);
                elseif cohortval == 1 & sexval == 1; % patients and male
                    [status,result] = system([command1 ' ; ' command4]);
                elseif cohortval == 1 & sexval == 2; %patients and female
                    [status,result] = system([command1 ' ; ' command5]);
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
    
    
    assignin('base', 'NoMeta', NoMeta);
    assignin('base', 'MetaAlt', MetaAlt);
    
    
catch err
    set(AnalysisInput.ProgramStatusIndicator,'string',[mfilename ':had an error. See Matlab window for details.'],'foregroundcolor','g');drawnow;
    cd(BaseDirectory);
    rethrow(err);
end

AnalysisOutput = 1;



