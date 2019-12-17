%concatenate subjects into one .mat file

function AnalysisOutput = SNR_Concatenate_PAG_SNRrejectPAG_AFNI_2(AnalysisInput)

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
    
    for PartNum = 1:length(AnalysisInput.Files) % for loop across subjects
        
        load([AnalysisInput.Files{PartNum}]);
        
        id_name = Participant.MappId;
        id_name_results = [id_name '.rest.results'];
        
        
        ResultsFolder = [InputPath id_name filesep 'SUMA' filesep id_name_results filesep];
        
        pb04file = [ResultsFolder 'pb04.' id_name '.rest.r01.blur+tlrc.HEAD'];
        errtsfile = [ResultsFolder 'errts.' id_name '.rest.anaticor+tlrc.HEAD'];
        
        if exist(pb04file,'file')==2 & exist(errtsfile,'file')==2
            
            set(AnalysisInput.ProgramStatusIndicator,'string',[mfilename ':Running ... participant ' num2str(PartNum)],'foregroundcolor','g');drawnow;
            
            VisitInd = find(strcmp({Participant.Visit.Name},VisitName));
            ModalityInd = find(strcmp({Participant.Visit(VisitInd).Modality.Name},ModalityName));
            MetaModalityInd = find(strcmp({Participant.Visit(VisitInd).Modality.Name},MetaModalityName));
            DataInd = find(strcmp({Participant.Visit(VisitInd).Modality(ModalityInd).Data.Name},DataName));

            % get meta data
            Result.Participant(PartNum,1).Meta = Participant.Visit(VisitInd).Modality(MetaModalityInd).Data;
            
            MotionParameterFile = [ResultsFolder 'dfile_rall.1D'];
            Result.Participant(PartNum,1).Motion.ColumnDescription = {'Rx';'Ry';'Rz';'Tx';'Ty';'Tz'};
            Result.Participant(PartNum,1).Motion.Value = load(MotionParameterFile);
            
            StatsFolder = ResultsFolder;
            
            OutputFile = [StatsFolder filesep 'PowerROISignalsPAGMNIalt_092018.mat'];
            
            load(OutputFile);
            
            %     NumROI = length(Person.ROI);
            NumROI = length(Participant.PowerROI);
            
            
            for i = 1:NumROI
                
                
                set(AnalysisInput.ProgramStatusIndicator,'string',[mfilename ':Running ... participant ' num2str(PartNum) ' :  region ' num2str(i)],'foregroundcolor','g');drawnow;
                
                if i == 267 %for PAG sigmal
                    
                    %unique based on voxel coordinate repetition
                    [C, ia, ic] = unique(Participant.PowerROI(267).VoxelCoordinates.Value, 'rows');
                    
                    X0 = Participant.PowerROI(i).VoxelSignals.Value(ia,:)';
                    X0r = Participant.PowerROI(i).VoxelCensoredSignals.Value(ia,:)';
                    
                    %Remove censored values from both the mri signal and the
                    %residuals
                    CenInd = find(X0r==0);
                    X0(CenInd)=NaN;
                    X0r(CenInd)=NaN;
                    
                    %signal to noise correction
                    SNRX = nanmean(X0)./nanstd(X0r);
                    SNRX(isnan(SNRX)) = 0;
                    indX = find(SNRX>=100); %cut off for afni (100)
                    
                    Result.Participant(PartNum,1).ROI(i,1).MniBall = Participant.PowerROI(i).MniBall;
                    Result.Participant(PartNum,1).ROI(i,1).Color = Participant.PowerROI(i).Color
                    Result.Participant(PartNum,1).ROI(i,1).Network = Participant.PowerROI(i).Network
                    Result.Participant(PartNum,1).ROI(i,1).SNR = mean(SNRX);
                    Result.Participant(PartNum,1).ROI(i,1).AllVoxels = Participant.PowerROI(i).VoxelCoordinates.Value(ia,:);
                    Result.Participant(PartNum,1).ROI(i,1).IndGoodVoxels = indX;
                    
                    
                    values = Participant.PowerROI(i).VoxelCensoredSignals.Value(ia,:);
                    X = values(indX,:);

                    x = mean(X,1);
                    cenind = find(x==0);
                    x_cen = x;
                    x_cen(cenind) = NaN;
                    Result.Participant(PartNum,1).ROI(i,1).MeanSignal = mean(values,1);
                    Result.Participant(PartNum,1).ROI(i,1).MeanSignalCensored = x;
                    Result.Participant(PartNum,1).ROI(i,1).MeanSignalCensoredNAN = x_cen;
                    
                    
                else %all other siganls
                    
                    X0 = Participant.PowerROI(i).VoxelSignals.Value';
                    X0r = Participant.PowerROI(i).VoxelCensoredSignals.Value';
                    
                    %Remove censored values from both the mri signal and the
                    %residuals
                    CenInd = find(X0r==0);
                    X0(CenInd)=NaN;
                    X0r(CenInd)=NaN;
                    
                    
                    SNRX = nanmean(X0)./nanstd(X0r);
                    SNRX(isnan(SNRX)) = 0;
                    indX = find(SNRX>=100); %cut off for afni (100)

                    Result.Participant(PartNum,1).ROI(i,1).MniBall = Participant.PowerROI(i).MniBall;
                    Result.Participant(PartNum,1).ROI(i,1).Color = Participant.PowerROI(i).Color
                    Result.Participant(PartNum,1).ROI(i,1).Network = Participant.PowerROI(i).Network
                    Result.Participant(PartNum,1).ROI(i,1).SNR = mean(SNRX);
                    Result.Participant(PartNum,1).ROI(i,1).AllVoxels = Participant.PowerROI(i).VoxelCoordinates.Value;
                    Result.Participant(PartNum,1).ROI(i,1).IndGoodVoxels = indX;

                    X = Participant.PowerROI(i).VoxelCensoredSignals.Value(indX,:);
                    x = mean(X,1);
                    cenind = find(x==0);
                    x_cen = x;
                    x_cen(cenind) = NaN;
                    Result.Participant(PartNum,1).ROI(i,1).MeanSignal = mean(Participant.PowerROI(i).VoxelCensoredSignals.Value,1);
                    Result.Participant(PartNum,1).ROI(i,1).MeanSignalCensored = x;
                    Result.Participant(PartNum,1).ROI(i,1).MeanSignalCensoredNAN = x_cen;
                    
                end
                
                
                
                
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