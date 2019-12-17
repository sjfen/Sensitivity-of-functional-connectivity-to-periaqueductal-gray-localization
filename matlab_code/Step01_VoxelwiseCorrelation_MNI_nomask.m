%create voxelwise correlation to MNI trace

function AnalysisOutput = Step01_VoxelwiseCorrelation_MNI_nomask(AnalysisInput)

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
    
    [outfile,outpath] = uiputfile('*','Save output file');
    
    InputPath = '/Volumes/AmplStorage2/Experiments/preproc/';
    
    strsep = EnableHelperFunction([],'strsep.m');
    
    [path1,file1,ext1] = fileparts(mfilename('fullpath'));
    AfniSetupString = 'export PATH=$PATH:/Users/amplmember/abin';
    NumPart = length(AnalysisInput.Files);
    
    TransformPath = '/Users/amplmember/GoogleDrive/2017_MAPP_Sonja_PAG/transformations_healthycontrol/'; %path to copy traced images/transformed images from
    temppath = '~/Desktop/Temp/'; %temporary directory to store files and remove at the end of each for loop
    
    for i = 1:NumPart
        
        i
        
        
        load(AnalysisInput.Files{i});
        
        id_name = Participant.MappId;
        id_name_results = [id_name '.rest.results'];
        
        ResultsFolder = [InputPath id_name filesep 'SUMA' filesep id_name_results filesep];
        
        pb04file = [ResultsFolder 'pb04.' id_name '.rest.r01.blur+tlrc.HEAD'];
        errtsfile = [ResultsFolder 'errts.' id_name '.rest.anaticor+tlrc.HEAD'];
        
        if exist(pb04file,'file')==2 & exist(errtsfile,'file')==2
            
            command1 = ['cd ' outpath];

            mkdir('~/Desktop/Temp');
            
            Participant = [];
            Participant.MAPP_ID = id_name;
            
            %generate the PAG mask image for signal extraction
            PAGmask = ['3dUndump -prefix ' temppath '1mmMask_new -xyz -master /Volumes/AmplStorage2/Experiments/preproc/' id_name ...
                '/SUMA/' id_name '.rest.results/errts.' id_name '.rest.anaticor+tlrc.BRIK -orient RAI /Users/amplmember/GoogleDrive/2017_MAPP_Sonja_PAG/PAG_Datasets/MNItrace/1mmMask.txt'];
          
            %extract PAG signal
            TimeSeries = ['3dmaskave -mask ' temppath '1mmMask_new+tlrc. -q /Volumes/AmplStorage2/Experiments/preproc/' id_name ...
                '/SUMA/' id_name '.rest.results/errts.' id_name '.rest.anaticor+tlrc.BRIK > ' temppath 'TimeseriesSignal.1D'];
            
            %generate correlation
            GenCorr =  ['3dDeconvolve -input /Volumes/AmplStorage2/Experiments/preproc/' id_name '/SUMA/' id_name '.rest.results/errts.' id_name ...
                '.rest.anaticor+tlrc.  -polort 1  -num_stimts 1  -stim_file 1 ' temppath ...
                'TimeseriesSignal.1D -tout -rout -fitts ' temppath 'fit_subj01 -bucket CorrMNI_' id_name];
            
            %get correlation r values
            GetRval = ['3dcalc -a CorrMNI_' id_name '+tlrc.[Stim#1_R^2] -b CorrMNI_' id_name '+tlrc.[Stim#1#0_Coef] -prefix rcoefMNI_' id_name ...
                ' -expr "ispositive(b)*sqrt(a)-isnegative(b)*sqrt(a)"'];
            
            %convert correlation coefficients to Gaussian
            ConvGaus = ['3dcalc -a rcoefMNI_' id_name '+tlrc. -expr ''atanh(a)'' -prefix zcoefMNI_' id_name];
          
            
            [status,result] = system([AfniSetupString ' ; ' PAGmask]);
            [status,result] = system([AfniSetupString ' ; ' TimeSeries]);
            [status,result] = system([AfniSetupString ' ; ' command1 ';' GenCorr]); %cd to the folder where these files are saved
            [status,result] = system([AfniSetupString ' ; ' command1 ';' GetRval]); %cd to the folder where these files are saved
            [status,result] = system([AfniSetupString ' ; ' command1 ';' ConvGaus]); %cd to the folder where these files are saved
            
            cd(BaseDirectory);
            
            system('rm -r ~/Desktop/Temp');
            
        end
        
    end
    
catch err
    set(AnalysisInput.ProgramStatusIndicator,'string',[mfilename ':had an error. See Matlab window for details.'],'foregroundcolor','g');drawnow;
    cd(BaseDirectory);
    rethrow(err);
end

AnalysisOutput = 1;