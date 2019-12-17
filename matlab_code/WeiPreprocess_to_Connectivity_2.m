%connectivity for power analysis

function PublishOutput = WeiPreprocess_to_Connectivity(PublishInput)
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
    
    PAGLind = 265;
    PAGRind = 266;
    Hand = 268;
    MNI = 267;
    
    %TimeInd = 10:286;
    
    load(PublishInput.ResultFiles{1});
    
    NumPart = length(Result.Participant);
    
    %add meta data
    for i = 1:NumPart

        set(PublishInput.ProgramStatusIndicator,'string',['WeiPreprocess_to_Connectivity: Running... participant ' num2str(i) ' of ' num2str(NumPart)],'foregroundcolor','g');drawnow;
        
        % desired metadata - add more later based on pid
        pid(i,1) = ExtractVariable(Result.Participant(i).Meta,'pid');
        sex(i,1) = ExtractVariable(Result.Participant(i).Meta,'sex');
        age(i,1) = ExtractVariable(Result.Participant(i).Meta,'age');
        siteid(i,1) = ExtractVariable(Result.Participant(i).Meta,'siteid');
        cohorttype(i,1) = ExtractVariable(Result.Participant(i).Meta,'cohorttype');
        
        
        % examine SNR
        
        if i == 1
            NumRoi = length(Result.Participant(i).ROI);
        end
        
        
        if isfield(Result.Participant(i).ROI(1),'SNR') == 1
            for j = 1:NumRoi
                NewResult.SNR(i,j) = Result.Participant(i).ROI(j).SNR;
            end
        end
        
    end
        
        
        for i = 1:length(Result.Participant)
            
            PAGLsignal = Result.Participant(i).ROI(PAGLind).MeanSignal(:);
            PAGRsignal = Result.Participant(i).ROI(PAGRind).MeanSignal(:);
            PAGHandsignal = Result.Participant(i).ROI(Hand).MeanSignal(:);
            PAGMNIsignal = Result.Participant(i).ROI(MNI).MeanSignal(:);
            
            c = 1;

            for j = 1:264
                
                
                Signal = Result.Participant(i).ROI(j).MeanSignal(:);
                
                C_PAGLsignal = corr(PAGLsignal,Signal,'rows','complete');
                NewResult.Result2.Z_PAGL(i,c) = atan(C_PAGLsignal);
                
                C_PAGRsignal = corr(PAGRsignal,Signal,'rows','complete');
                NewResult.Result2.Z_PAGR(i,c) = atan(C_PAGRsignal);
                
                C_PAGHandsignal = corr(PAGHandsignal,Signal,'rows','complete');
                NewResult.Result2.Z_PAGHand(i,c) = atan(C_PAGHandsignal);
                
                C_PAGMNIsignal = corr(PAGMNIsignal, Signal, 'rows', 'complete');
                NewResult.Result2.Z_PAGMNI(i,c) = atan(C_PAGMNIsignal);
                
                c = c+1;
                
            end
            
        end
        
        NewResult.MetaDataTable = table(pid,siteid,sex,age,cohorttype,'VariableNames',{'pid';'siteid';'sex';'age';'cohorttype'});
        file2str = EnableHelperFunction([],{'file2str.m'});NewResult.CodeUsed = file2str([mfilename('fullpath') '.m']);
        
        connectivitylist = fieldnames(NewResult.Result2);
        
        %correct for site and age
        [U,~,site] = unique(NewResult.MetaDataTable.siteid);
        
        
        DummyVariables = dummyvar(site);
        DummyVariables(:,end) = [];
        
        
        T = NewResult.MetaDataTable;
        
        lmestr = 'x ~ age';
        for i = 1:size(DummyVariables,2)
            T.(['site' num2str(i)]) = DummyVariables(:,i);
            lmestr = [lmestr ' + site' num2str(i)];
        end
        
        for k = 1:size(connectivitylist,1)
            NumPairs = size(NewResult.Result2.(connectivitylist{k}), 2);
            for i = 1:NumPairs
                
                set(PublishInput.ProgramStatusIndicator,'string',['WeiPreprocess_to_Connectivity: Running ... connection ' num2str(i) ' of ' num2str(NumPairs)],'foregroundcolor','g');drawnow;
                
                x = NewResult.Result2.(connectivitylist{k})(:,i);
                
                T.x = x;
                
                lme = fitlme(T,lmestr); % dummy variables included
                
                CorrectedConnectivity(:,i)= residuals(lme); %residuals after controlling for age and site
            end
            
            NewResult.Result2.([connectivitylist{k} '_corrected']) = CorrectedConnectivity;
        end
        
        
        
        Result = NewResult;
        
        save([PublishInput.ResultFiles{1}(1:end-4) '_Connectivity.mat'],'Result');
        
        catch err
            set(PublishInput.ProgramStatusIndicator,'string','WeiPreprocess_to_Connectivity had an error. See Matlab window for details.','foregroundcolor','r');drawnow;
            cd(BaseDirectory);
            rethrow(err);
    end
    
    PublishOutput = 1;
