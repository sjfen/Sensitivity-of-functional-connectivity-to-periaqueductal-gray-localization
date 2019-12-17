%connectivity for voxelwise analysis

function PublishOutput = WeiPreprocess_to_Connectivity_2_Voxelwise(PublishInput)
% Publishing Methods are .m functions that look at result files and produce new result files or publication figures
% PublishInput
%     .ResultFiles - cell array of file names passed to the method
%     .HelperFunctions - cell array of helper function names to be used with EnableHelperFunction
%     .PathSep - path separator '/' in mac/linux and '\' in windows
%     .ProgramStatusIndicator - a handle to the Program Status Indicator on the front panel so that status can be updated from within the reader
% PublishOutput - not currently used
%

for i = 1:10
    try
        close(i)
    end
end

BaseDirectory = cd;

try
    
    set(PublishInput.ProgramStatusIndicator,'string','WeiPreprocess_to_Connectivity: Running...','foregroundcolor','g');drawnow;
    
    %----------- Your code here !!! ---------------
    ExtractVariable = EnableHelperFunction([],{'MetaData';'ExtractVariable.m'});
    PowerSpectrum = EnableHelperFunction([],{'PowerSpectrum.m'});

    load(PublishInput.ResultFiles{1});
    
    NumROI = length(Result.Participant(i).Voxel);
    
    PAGLind = NumROI-3;
    PAGRind = NumROI-2;
    Hand = NumROI;
    MNI = NumROI-1;
    
    NumPart = length(Result.Participant);
    
    %add meta data
    for i = 1:NumPart

        % desired metadata - add more later based on pid
        pid(i,1) = ExtractVariable(Result.Participant(i).Meta,'pid');
        sex(i,1) = ExtractVariable(Result.Participant(i).Meta,'sex');
        age(i,1) = ExtractVariable(Result.Participant(i).Meta,'age');
        siteid(i,1) = ExtractVariable(Result.Participant(i).Meta,'siteid');
        cohorttype(i,1) = ExtractVariable(Result.Participant(i).Meta,'cohorttype');
        
        
        % examine SNR
        
        if i == 1
            NumRoi = length(Result.Participant(i).Voxel); %changed from ROI to Voxel for voxelwise analysis
        end
        
        
    end
    %
    
    for i = 1:length(Result.Participant)
        
        PAGLsignal = Result.Participant(i).Voxel(PAGLind).MeanSignal(:);
        PAGRsignal = Result.Participant(i).Voxel(PAGRind).MeanSignal(:);
        PAGHandsignal = Result.Participant(i).Voxel(Hand).MeanSignal(:);
        PAGMNIsignal = Result.Participant(i).Voxel(MNI).MeanSignal(:);

        
        a = {Result.Participant(i).Voxel(1:end-4).MeanSignal}; %do not want the correlation between PAG and other PAG signals.
        Signal = cat(1,a{:})';

        
        for j = 1:size(Signal,2) %this was done because when using corr with entire Signal --> nans
            
        set(PublishInput.ProgramStatusIndicator,'string',['WeiPreprocess_to_Connectivity_2_Voxelwsie: Running... participant ' num2str(i) ' of ' num2str(j)],'foregroundcolor','g');drawnow;

            
        C_PAGLsignal = corr(PAGLsignal,Signal(:,j),'rows','complete');

        NewResult.Result2.Z_PAGL(i,j) = atan(C_PAGLsignal);
        
        C_PAGRsignal = corr(PAGRsignal,Signal(:,j),'rows','complete');

        NewResult.Result2.Z_PAGR(i,j) = atan(C_PAGRsignal);
        
        C_PAGHandsignal = corr(PAGHandsignal,Signal(:,j),'rows','complete');

        NewResult.Result2.Z_PAGHand(i,j) = atan(C_PAGHandsignal);
        
        C_PAGMNIsignal = corr(PAGMNIsignal, Signal(:,j), 'rows', 'complete');

        NewResult.Result2.Z_PAGMNI(i,j) = atan(C_PAGMNIsignal);
        
        end
        
    end
    
    NewResult.MetaDataTable = table(pid,siteid,sex,age,cohorttype,'VariableNames',{'pid';'siteid';'sex';'age';'cohorttype'});
    file2str = EnableHelperFunction([],{'file2str.m'});NewResult.CodeUsed = file2str([mfilename('fullpath') '.m']);
    
    Result = NewResult;
    
    save([PublishInput.ResultFiles{1}(1:end-4) '_Connectivity.mat'],'Result');
    
catch err
    set(PublishInput.ProgramStatusIndicator,'string','WeiPreprocess_to_Connectivity had an error. See Matlab window for details.','foregroundcolor','r');drawnow;
    cd(BaseDirectory);
    rethrow(err);
end

PublishOutput = 1;
