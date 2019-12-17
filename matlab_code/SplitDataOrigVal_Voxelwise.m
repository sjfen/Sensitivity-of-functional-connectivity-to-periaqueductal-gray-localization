%split data into original and validation datasets
%split datset into Original and validation based on previous information

function PublishOutput = SplitDataOrigVal_Voxelwise(PublishInput)
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
    
    set(PublishInput.ProgramStatusIndicator,'string','SplitDataOigVal_Voxelwise: Running...','foregroundcolor','g');drawnow;
    
    %----------- Your code here !!! ---------------
    
    load(PublishInput.ResultFiles{1}); %all subjects
    load(PublishInput.ResultFiles{2}); %original pid and site valeus
%     load(PublishInput.ResultFiles{3}); %do not need validation
%     coordinates

        
o = 1;
v = 1;
    
    for i = 1:length(Result.Participant)
        
        indSiteID = find(strcmp({Result.Participant(i).Meta.Name}, 'siteid'));
        indPID = find(strcmp({Result.Participant(i).Meta.Name}, 'pid'));
        
        if ismember(Result.Participant(i).Meta(indSiteID).Value, origPID(:,1)) && ismember(Result.Participant(i).Meta(indPID).Value, origPID(:,2))
       
        OrigDat.Result.Participant(o,:) = Result.Participant(i);
        o = o+1;
        
        else
            ValDat.Result.Participant(v,:) = Result.Participant(i);
            v = v+1;
        end
    end
    
    Result = OrigDat.Result;
    
    save([PublishInput.ResultFiles{1}(1:end-4) '_OrigDat.mat'],'Result','-v7.3');  
    
    Result = ValDat.Result;
    
    save([PublishInput.ResultFiles{1}(1:end-4) '_ValDat.mat'],'Result', '-v7.3');
        
    
catch err
    set(PublishInput.ProgramStatusIndicator,'string','WeiPreprocess_to_Connectivity had an error. See Matlab window for details.','foregroundcolor','r');drawnow;
    cd(BaseDirectory);
    rethrow(err);
end

PublishOutput = 1;
