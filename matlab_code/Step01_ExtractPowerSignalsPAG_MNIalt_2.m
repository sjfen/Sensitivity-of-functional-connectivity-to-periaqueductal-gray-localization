%exstract ROI signals from resting state image

function AnalysisOutput = Step01_ExtractPowerSignals_MNIalt(AnalysisInput)

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
    
    [path1,file1,ext1] = fileparts(mfilename('fullpath'));
    load([path1 filesep 'PP264template.mat']);
    AfniSetupString = 'export PATH=$PATH:/Users/amplmember/abin';
    NumPart = length(AnalysisInput.Files);
    
    load('/Users/amplmember/GoogleDrive/2017_MAPP_Sonja_PAG/PAG_Datasets/MNItrace/1mmMask.txt'); %1mm hand trace of the PAG
    
    TransformPath = '/Users/amplmember/GoogleDrive/2017_MAPP_Sonja_PAG/transformations_healthycontrol/'; %path to copy traced images/transformed images from
    
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
            
            mkdir('~/Desktop/Temp');
            
            Participant = [];
            Participant.MAPP_ID = id_name;
            
            addtable= table([265;266],[nan;nan],[-4;4],[-26;-26],[-14;-14], [3;3], {nan;nan}, {nan;nan}, 'VariableNames', {'ROI', 'Original_ROI', 'X', 'Y', 'Z', 'R', 'Color', 'Network'}) %wei coordinates 3mm radius
            PP266 = [PP264template; addtable]
            
            %locations for MNI and traced
            for j = 1:size(PP266,1)
                
                set(AnalysisInput.ProgramStatusIndicator,'string',[mfilename ':Running ... participant ' num2str(i) ' ROI ' num2str(j)],'foregroundcolor','g');drawnow;
                
                % run 3dmaskdump and load results
                command2 = ['3dmaskdump -nball ' num2str(PP266.X(j)) ' ' num2str(PP266.Y(j)) ' ' num2str(PP266.Z(j)) ' ' num2str(PP266.R(j)) ' -o ~/Desktop/Temp/temp_pb04' num2str(j) '.txt pb04.' id_name '.rest.r01.blur+tlrc'];
                command3 = ['3dmaskdump -nball ' num2str(PP266.X(j)) ' ' num2str(PP266.Y(j)) ' ' num2str(PP266.Z(j)) ' ' num2str(PP266.R(j)) ' -o ~/Desktop/Temp/temp_errts' num2str(j) '.txt errts.' id_name '.rest.anaticor+tlrc'];
                            
                [status,result] = system([AfniSetupString ' ; ' command1 ' ; ' command2]);
                [status,result] = system([AfniSetupString ' ; ' command1 ' ; ' command3]);
                
                pause(0.01);
                
                A = load(['~/Desktop/Temp/temp_pb04' num2str(j) '.txt']);
                B = load(['~/Desktop/Temp/temp_errts' num2str(j) '.txt']);
                Coordinates = A(:,1:3);
                Signals = A(:,4:end);
                CensoredSignals = B(:,4:end);
                CensoredSignals(CensoredSignals==0) = NaN;
                
                % store results
   
                Participant.PowerROI(j).MniBall.Value = [PP266.X(j) PP266.Y(j) PP266.Z(j) PP266.R(j)];
                Participant.PowerROI(j).MniBall.Description = 'Center of ROI, MNI LPI coordinates [X mm, Y mm, Z mm, Radius mm]';

                Participant.PowerROI(j).Network.Value = PP266.Network{j};
                Participant.PowerROI(j).Network.Description = 'Description of brain network associated with region';
                
                Participant.PowerROI(j).Color.Value = PP266.Color{j};
                Participant.PowerROI(j).Color.Description = 'Suggested color based on network';
                
                Participant.PowerROI(j).VoxelCoordinates.Value = Coordinates;
                Participant.PowerROI(j).VoxelCoordinates.Description = 'Nx3 matrix of indices of N voxels in ROI (X,Y,Z)- 2/1: voxel locations (I,J,K), unless specified -xyz';
                
                Participant.PowerROI(j).VoxelSignals.Value = Signals;
                Participant.PowerROI(j).VoxelSignals.Source = ['pb04.' id_name '.rest.r01.blur+tlrc'];
                Participant.PowerROI(j).VoxelSignals.Description = 'Nx296 matrix of signals for N voxels in ROI, uncensored and not de-meaned';
                
                Participant.PowerROI(j).VoxelCensoredSignals.Value = CensoredSignals;
                Participant.PowerROI(j).VoxelCensoredSignals.Source = ['errts.' id_name '.rest.anaticor+tlrc'];
                Participant.PowerROI(j).VoxelCensoredSignals.Description = 'Nx296 matrix of signals for N voxels in ROI, de-meaned and NaN for censored volume';
            end
            
            %extract MNI mask using coordinates from 3dmaskdump
            for k=1:size(X1mmMask,1)
                command4 = ['3dmaskdump -dbox ' num2str(X1mmMask(k,1)) ' ' num2str(X1mmMask(k,2)) ' ' num2str(X1mmMask(k,3)) ' -o ~/Desktop/Temp/temp_MNIpb04' num2str(k) '.txt pb04.' id_name '.rest.r01.blur+tlrc'];
                [status,result] = system([AfniSetupString ' ; ' command1 ' ; ' command4]);
                
                command6 = ['3dmaskdump -dbox ' num2str(X1mmMask(k,1)) ' ' num2str(X1mmMask(k,2)) ' ' num2str(X1mmMask(k,3)) ' -o ~/Desktop/Temp/temp_MNIerrts' num2str(k) '.txt errts.' id_name '.rest.anaticor+tlrc'];
                [status,result] = system([AfniSetupString ' ; ' command1 ' ; ' command6]);
                
                pause(0.05);
                
                A = load(['~/Desktop/Temp/temp_MNIpb04' num2str(k) '.txt']);
                B = load(['~/Desktop/Temp/temp_MNIerrts' num2str(k) '.txt']);
                Coordinates(k,:) = A(:,1:3);
                Signals(k,:) = A(:,4:end);
                CensoredSignals(k,:) = B(:,4:end);
                
            end
            
            CensoredSignals(CensoredSignals==0) = NaN;
            
            % store results
            
            Participant.PowerROI(j+1).Color.Value = [1 1 1];
            Participant.PowerROI(j+1).Color.Description = 'Suggested color based on seed';
            
            Participant.PowerROI(j+1).VoxelCoordinates.Value = Coordinates;
            Participant.PowerROI(j+1).VoxelCoordinates.Description = 'Nx3 matrix of indices of N voxels in ROI (X,Y,Z)';
            
            Participant.PowerROI(j+1).VoxelSignals.Value = Signals;
            Participant.PowerROI(j+1).VoxelSignals.Source = ['pb04.' id_name '.rest.r01.blur+tlrc'];
            Participant.PowerROI(j+1).VoxelSignals.Description = 'Nx296 matrix of signals for N voxels in ROI, uncensored and not de-meaned';
            
            Participant.PowerROI(j+1).VoxelCensoredSignals.Value = CensoredSignals;
            Participant.PowerROI(j+1).VoxelCensoredSignals.Source = ['errts.' id_name '.rest.anaticor+tlrc'];
            Participant.PowerROI(j+1).VoxelCensoredSignals.Description = 'Nx296 matrix of signals for N voxels in ROI, de-meaned and NaN for censored volume';
            
                
            save([ResultsFolder filesep 'PowerROISignalsPAGMNIalt_092018.mat'],'Participant'); %s
            
            system('rm -r ~/Desktop/Temp');
            
        end
        
    end
    
    
    
catch err
    set(AnalysisInput.ProgramStatusIndicator,'string',[mfilename ':had an error. See Matlab window for details.'],'foregroundcolor','g');drawnow;
    cd(BaseDirectory);
    rethrow(err);
end

AnalysisOutput = 1;