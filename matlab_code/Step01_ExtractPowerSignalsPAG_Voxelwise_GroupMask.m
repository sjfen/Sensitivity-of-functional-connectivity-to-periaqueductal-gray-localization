function AnalysisOutput = Step01_ExtractSeedSignalsPAG_Voxelwise_GroupMask(AnalysisInput)

% AnalysisInput
% .Files - cell array of data files for all selected trials
% .HelperFunctions - cell array of helper functions to be used with EnableHelperFunction
% .PathSep - / in mac and \ in windows
%
% don't forget to save your result appropriately
%ONLY EXTRACTING SIGNAL FROM SEEDS

BaseDirectory = cd;

try
    
    set(AnalysisInput.ProgramStatusIndicator,'string',[mfilename ':Running ...'],'foregroundcolor','g');drawnow;
    
    %----------- Your code here !!! ---------------
    
    InputPath = '/Volumes/AmplStorage2/Experiments/preproc/';
    
    strsep = EnableHelperFunction([],'strsep.m');
    
    [path1,file1,ext1] = fileparts(mfilename('fullpath'));
    %     load([path1 filesep 'PP264template.mat']);
    AfniSetupString = 'export PATH=$PATH:/Users/amplmember/abin';
    NumPart = length(AnalysisInput.Files);
    
    load('/Users/amplmember/GoogleDrive/2017_MAPP_Sonja_PAG/PAG_Datasets/MNItrace/1mmMask.txt');
    
    TransformPath = '/Users/amplmember/GoogleDrive/2017_MAPP_Sonja_PAG/transformations_healthycontrol/'; %path to copy traced images/transformed images from
    temppath = '~/Desktop/Temp2/'; %temporary directory to store files and remove at the end of each for loop
     
    %perform extraction
    for i = 1:NumPart
        
        i
        
        
        load(AnalysisInput.Files{i});
        
        id_name = Participant.MappId;
        id_name_results = [id_name '.rest.results'];
        
        ResultsFolder = [InputPath id_name filesep 'SUMA' filesep id_name_results filesep];
        
        pb04file = [ResultsFolder 'pb04.' id_name '.rest.r01.blur+tlrc.HEAD'];
        errtsfile = [ResultsFolder 'errts.' id_name '.rest.anaticor+tlrc.HEAD'];
        
        if exist(pb04file,'file')==2 & exist(errtsfile,'file')==2
            
            
            command1 = ['cd ' ResultsFolder];
            
            mkdir('~/Desktop/Temp2');
            
            Participant = [];
            Participant.MAPP_ID = id_name;
            
            % run 3dmaskdump and load results
            command2 = ['3dmaskdump -mask ' ResultsFolder 'mask_group+tlrc. -o ' temppath 'temp_pb04_' id_name '.txt pb04.' id_name '.rest.r01.blur+tlrc'];
            command3 = ['3dmaskdump -mask ' ResultsFolder 'mask_group+tlrc. -o ' temppath 'temp_errts_' id_name '.txt errts.' id_name '.rest.anaticor+tlrc'];

            [status,result] = system([AfniSetupString ' ; ' command1 ' ; ' command2]);
            [status,result] = system([AfniSetupString ' ; ' command1 ' ; ' command3]);
            
            pause(0.01);
            
            dataPb04 = load([temppath 'temp_pb04_' id_name '.txt']);
            dataErrts = load([temppath 'temp_errts_' id_name '.txt']);
            
            for j = 1:size(dataErrts,1)
                
                set(AnalysisInput.ProgramStatusIndicator,'string',[mfilename ':Running ... participant ' num2str(i) ' ROI ' num2str(j)],'foregroundcolor','g');drawnow;

                A = dataPb04(j,:);
                B = dataErrts(j,:);
                Coordinates = A(:,1:3);
                Signals = A(:,4:end);
                CensoredSignals = B(:,4:end);
                CensoredSignals(CensoredSignals==0) = NaN;
                
                % store results
                
                Participant.PowerROI(j).VoxelCoordinates.Value = Coordinates;
                Participant.PowerROI(j).VoxelCoordinates.Description = 'Nx3 matrix of indices of N voxels in ROI (X,Y,Z)- 2/1: voxel locations (I,J,K), unless specified -xyz';
                
                Participant.PowerROI(j).VoxelSignals.Value = Signals;
                Participant.PowerROI(j).VoxelSignals.Source = ['pb04.' id_name '.rest.r01.blur+tlrc'];
                Participant.PowerROI(j).VoxelSignals.Description = 'Nx296 matrix of signals for N voxels in ROI, uncensored and not de-meaned';
                
                Participant.PowerROI(j).VoxelCensoredSignals.Value = CensoredSignals;
                Participant.PowerROI(j).VoxelCensoredSignals.Source = ['errts.' id_name '.rest.anaticor+tlrc'];
                Participant.PowerROI(j).VoxelCensoredSignals.Description = 'Nx296 matrix of signals for N voxels in ROI, de-meaned and NaN for censored volume';
            end
            
            %add two Wei masks
            addWeiVox= [-4, -26, -14; 4, -26, -14];

         for w = 1:size(addWeiVox,1)
                
                set(AnalysisInput.ProgramStatusIndicator,'string',[mfilename ':Running ... participant ' num2str(i) ' ROI ' num2str(j)],'foregroundcolor','g');drawnow;
                
                % run 3dmaskdump and load results
                command2 = ['3dmaskdump -nball ' num2str(addWeiVox(w,1)) ' ' num2str(addWeiVox(w,2)) ' ' num2str(addWeiVox(w,3)) ' ' num2str(3) ' -o ~/Desktop/Temp2/temp_pb04' num2str(j+w) '.txt pb04.' id_name '.rest.r01.blur+tlrc'];
                command3 = ['3dmaskdump -nball ' num2str(addWeiVox(w,1)) ' ' num2str(addWeiVox(w,2)) ' ' num2str(addWeiVox(w,3)) ' ' num2str(3) ' -o ~/Desktop/Temp2/temp_errts' num2str(j+w) '.txt errts.' id_name '.rest.anaticor+tlrc'];

                [status,result] = system([AfniSetupString ' ; ' command1 ' ; ' command2]);
                [status,result] = system([AfniSetupString ' ; ' command1 ' ; ' command3]);
                
                pause(0.01);
                
                A = load(['~/Desktop/Temp2/temp_pb04' num2str(j+w) '.txt']);
                B = load(['~/Desktop/Temp2/temp_errts' num2str(j+w) '.txt']);
                Coordinates = A(:,1:3);
                Signals = A(:,4:end);
                CensoredSignals = B(:,4:end);
                CensoredSignals(CensoredSignals==0) = NaN;
                
                % store results
  
                Participant.PowerROI(j+w).MniBall.Value = addWeiVox(w,:);
                Participant.PowerROI(j+w).MniBall.Description = 'Center of ROI, MNI LPI coordinates [X mm, Y mm, Z mm, Radius mm]';
                
                Participant.PowerROI(j+w).VoxelCoordinates.Value = Coordinates;
                Participant.PowerROI(j+w).VoxelCoordinates.Description = 'Nx3 matrix of indices of N voxels in ROI (X,Y,Z)- 2/1: voxel locations (I,j+w,K), unless specified -xyz';
                
                Participant.PowerROI(j+w).VoxelSignals.Value = Signals;
                Participant.PowerROI(j+w).VoxelSignals.Source = ['pb04.' id_name '.rest.r01.blur+tlrc'];
                Participant.PowerROI(j+w).VoxelSignals.Description = 'Nx296 matrix of signals for N voxels in ROI, uncensored and not de-meaned';
                
                Participant.PowerROI(j+w).VoxelCensoredSignals.Value = CensoredSignals;
                Participant.PowerROI(j+w).VoxelCensoredSignals.Source = ['errts.' id_name '.rest.anaticor+tlrc'];
                Participant.PowerROI(j+w).VoxelCensoredSignals.Description = 'Nx296 matrix of signals for N voxels in ROI, de-meaned and NaN for censored volume';
            end
      

            %MNI mask using coordinates from 3dmaskdump
            for k=1:size(X1mmMask,1)
                command4 = ['3dmaskdump -dbox ' num2str(X1mmMask(k,1)) ' ' num2str(X1mmMask(k,2)) ' ' num2str(X1mmMask(k,3)) ' -o ~/Desktop/Temp2/temp_MNIpb04' num2str(k) '.txt pb04.' id_name '.rest.r01.blur+tlrc'];
                [status,result] = system([AfniSetupString ' ; ' command1 ' ; ' command4]);
                
                
                command6 = ['3dmaskdump -dbox ' num2str(X1mmMask(k,1)) ' ' num2str(X1mmMask(k,2)) ' ' num2str(X1mmMask(k,3)) ' -o ~/Desktop/Temp2/temp_MNIerrts' num2str(k) '.txt errts.' id_name '.rest.anaticor+tlrc'];
                [status,result] = system([AfniSetupString ' ; ' command1 ' ; ' command6]);
                
                pause(0.05);
                
                A = load(['~/Desktop/Temp2/temp_MNIpb04' num2str(k) '.txt']);
                B = load(['~/Desktop/Temp2/temp_MNIerrts' num2str(k) '.txt']);
                Coordinates(k,:) = A(:,1:3);
                Signals(k,:) = A(:,4:end);
                CensoredSignals(k,:) = B(:,4:end);
                
            end
            
            CensoredSignals(CensoredSignals==0) = NaN;
            
            % store results

            Participant.PowerROI(j+3).VoxelCoordinates.Value = Coordinates;
            Participant.PowerROI(j+3).VoxelCoordinates.Description = 'Nx3 matrix of indices of N voxels in ROI (X,Y,Z)';
            
            Participant.PowerROI(j+3).VoxelSignals.Value = Signals;
            Participant.PowerROI(j+3).VoxelSignals.Source = ['pb04.' id_name '.rest.r01.blur+tlrc'];
            Participant.PowerROI(j+3).VoxelSignals.Description = 'Nx296 matrix of signals for N voxels in ROI, uncensored and not de-meaned';
            
            Participant.PowerROI(j+3).VoxelCensoredSignals.Value = CensoredSignals;
            Participant.PowerROI(j+3).VoxelCensoredSignals.Source = ['errts.' id_name '.rest.anaticor+tlrc'];
            Participant.PowerROI(j+3).VoxelCensoredSignals.Description = 'Nx296 matrix of signals for N voxels in ROI, de-meaned and NaN for censored volume';
            
            
            command5 = ['3dmaskdump -mask /Users/amplmember/GoogleDrive/2017_MAPP_Sonja_PAG/transformations_healthycontrol/' id_name '/follow_ROI_traced+tlrc. -o ~/Desktop/Temp2/temp_pb04' num2str(j+4) '.txt pb04.' id_name '.rest.r01.blur+tlrc'];
            
            
            [status,result] = system([AfniSetupString ' ; ' command1 ' ; ' command5]);
            
            pause(0.01);
            

            command7 = ['3dmaskdump -mask /Users/amplmember/GoogleDrive/2017_MAPP_Sonja_PAG/transformations_healthycontrol/' id_name '/follow_ROI_traced+tlrc. -o ~/Desktop/Temp2/temp_errts' num2str(j+4) '.txt errts.' id_name '.rest.anaticor+tlrc'];
            
            
            [status,result] = system([AfniSetupString ' ; ' command1 ' ; ' command7]); 
            
            A = load(['~/Desktop/Temp2/temp_pb04' num2str(j+4) '.txt']);
            B = load(['~/Desktop/Temp2/temp_errts' num2str(j+4) '.txt']);
            Coordinates = A(:,1:3);
            Signals = A(:,4:end);
            CensoredSignals = B(:,4:end);
            CensoredSignals(CensoredSignals==0) = NaN;
            
            % store results

            Participant.PowerROI(j+4).VoxelCoordinates.Value = Coordinates;
            Participant.PowerROI(j+4).VoxelCoordinates.Description = 'Nx3 matrix of indices of N voxels in ROI (X,Y,Z) - 2/1: voxel locations (I,J,K), unless specified -xyz';
            
            Participant.PowerROI(j+4).VoxelSignals.Value = Signals;
            Participant.PowerROI(j+4).VoxelSignals.Source = ['pb04.' id_name '.rest.r01.blur+tlrc'];
            Participant.PowerROI(j+4).VoxelSignals.Description = 'Nx296 matrix of signals for N voxels in ROI, uncensored and not de-meaned';
            
            Participant.PowerROI(j+4).VoxelCensoredSignals.Value = CensoredSignals;
            Participant.PowerROI(j+4).VoxelCensoredSignals.Source = ['errts.' id_name '.rest.anaticor+tlrc'];
            Participant.PowerROI(j+4).VoxelCensoredSignals.Description = 'Nx296 matrix of signals for N voxels in ROI, de-meaned and NaN for censored volume';
            
            
            
            save([ResultsFolder filesep 'PowerROISignalsPAGVoxelwise.mat'],'Participant');
            
            system('rm -r ~/Desktop/Temp2');
            
        end
        
    end
    
    
    
catch err
    set(AnalysisInput.ProgramStatusIndicator,'string',[mfilename ':had an error. See Matlab window for details.'],'foregroundcolor','g');drawnow;
    cd(BaseDirectory);
    rethrow(err);
end

AnalysisOutput = 1;