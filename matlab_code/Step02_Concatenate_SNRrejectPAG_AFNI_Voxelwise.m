% concatenate subjects and create final .mat datset

function AnalysisOutput = SNR_Concatenate_SNRrejectPAG_AFNI_Voxelwise(AnalysisInput)

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
    
    [outfile,outpath] = uiputfile('*.mat','Save output file');
    
    Cell2Path = EnableHelperFunction([],'Cell2Path.m');
    
    
    VisitName = 'FirstScan';
    ModalityName = 'RestingState';
    MetaModalityName = 'Meta';
    DataName = 'reoriented';
    
    InputPath = '/Volumes/AmplStorage2/Experiments/preproc/';
    
    for PartNum = 1:length(AnalysisInput.Files) % forloop across subjects
        
        load([AnalysisInput.Files{PartNum}]);
        
        id_name = Participant.MappId;
        id_name_results = [id_name '.rest.results'];
        
        SubjPathSUMAresults = [InputPath id_name filesep 'SUMA' filesep id_name_results filesep ];
        
        set(AnalysisInput.ProgramStatusIndicator,'string',[mfilename ':Running ... participant ' num2str(PartNum)],'foregroundcolor','g');drawnow;
        
        VisitInd = find(strcmp({Participant.Visit.Name},VisitName));
        ModalityInd = find(strcmp({Participant.Visit(VisitInd).Modality.Name},ModalityName));
        MetaModalityInd = find(strcmp({Participant.Visit(VisitInd).Modality.Name},MetaModalityName));
        DataInd = find(strcmp({Participant.Visit(VisitInd).Modality(ModalityInd).Data.Name},DataName));
        
        
        % get meta data
        Result.Participant(PartNum,1).Meta = Participant.Visit(VisitInd).Modality(MetaModalityInd).Data;
        
        MotionParameterFile = [SubjPathSUMAresults 'dfile_rall.1D'];
        Result.Participant(PartNum,1).Motion.ColumnDescription = {'Rx';'Ry';'Rz';'Tx';'Ty';'Tz'};
        Result.Participant(PartNum,1).Motion.Value = load(MotionParameterFile);
        
        StatsFolder = SubjPathSUMAresults;
   
        
        OutputFile = [StatsFolder 'PowerROISignalsPAGVoxelwise.mat'];
        
        load(OutputFile);
        
        NumROI = length(Participant.PowerROI);
        
        
        for i = 1:NumROI
            
            
            set(AnalysisInput.ProgramStatusIndicator,'string',[mfilename ':Running ... participant ' num2str(PartNum) ' :  region ' num2str(i)],'foregroundcolor','g');drawnow;
            
            if i == NumROI-1 || i == NumROI || i == NumROI-2 || i == NumROI-3; %MNI trace and hand trace
                
                %unique based on voxel coordinate repetition
                [C, ia, ic] = unique(Participant.PowerROI(i).VoxelCoordinates.Value, 'rows');
                
                X0 = Participant.PowerROI(i).VoxelSignals.Value(ia,:)';
                X0r = Participant.PowerROI(i).VoxelCensoredSignals.Value(ia,:)';
                
                %Remove censored values from both the mri signal and the
                %residuals
                CenInd = find(X0r==0);
                X0(CenInd)=NaN;
                X0r(CenInd)=NaN;
           
                values = Participant.PowerROI(i).VoxelCensoredSignals.Value(ia,:);
                
                X = values;
                x = mean(X,1);
                x = X;
                cenind = find(x==0);
                x_cen = x;
                x_cen(cenind) = NaN;
                Result.Participant(PartNum,1).Voxel(i,1).MeanSignal = mean(values,1);
                Result.Participant(PartNum,1).Voxel(i,1).MeanSignalCensoredNAN = mean(x_cen,1);
                
                
            else
                
                X0 = Participant.PowerROI(i).VoxelSignals.Value';
                X0r = Participant.PowerROI(i).VoxelCensoredSignals.Value';
                
                %Remove censored values from both the mri signal and the
                %residuals
                CenInd = find(X0r==0);
                X0(CenInd)=NaN;
                X0r(CenInd)=NaN;
                
                X = Participant.PowerROI(i).VoxelCensoredSignals.Value;
                x = X;
                cenind = find(x==0);
                x_cen = x;
                x_cen(cenind) = NaN;
%                 do not want to mean voxels bc there is only 1 unlike ROIs
                Result.Participant(PartNum,1).Voxel(i,1).MeanSignal = Participant.PowerROI(i).VoxelCensoredSignals.Value;
                Result.Participant(PartNum,1).Voxel(i,1).MeanSignalCensoredNAN = x_cen;
                
            end
            
            
            
            
        end
    end
    
    file2str = EnableHelperFunction([],{'file2str.m'});Result.CodeUsed = file2str([mfilename('fullpath') '.m']);
    
    
    
    save([outpath outfile],'Result', '-v7.3');
    
    
catch err
    set(AnalysisInput.ProgramStatusIndicator,'string',[mfilename ':had an error. See Matlab window for details.'],'foregroundcolor','g');drawnow;
    cd(BaseDirectory);
    rethrow(err);
end

AnalysisOutput = 1;