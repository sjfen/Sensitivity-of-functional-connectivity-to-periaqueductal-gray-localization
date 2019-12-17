%PAG trace transformation to subject standard space
%validation dataset

function AnalysisOutput = transformTraced2SubjectPAG_AFNItransform_3(AnalysisInput) %to use in the databaser
% AnalysisInput
% .Files - cell array of data files for all selected trials
% .HelperFunctions - cell array of helper functions to be used with EnableHelperFunction
% .PathSep - / in mac and \ in windows
%
% don't forget to save your result appropriately
%

BaseDirectory = cd;

try
    
    set(AnalysisInput.ProgramStatusIndicator,'string','transformTraced2SubjectPAG: Running...','foregroundcolor','g');drawnow;
    
    %----------- Your code here !!! ---------------
    InputPath = '/Volumes/AmplStorage2/Experiments/preproc/';  %this is subjects' directory for resting state preprocessing
    TransformPath = '/Users/amplmember/GoogleDrive/2017_MAPP_Sonja_PAG/transformations_healthycontrol/'; %subjects' transformation directory
    
    TempDir = ['~/Desktop' filesep mfilename '_temp']; %temporary file to store data, this will be deleted afterwards
    mkdir(TempDir);
    
    command0 = ['cd ' TransformPath 'inpt'];
    
    for i = 1:length(AnalysisInput.Files)
        
        load(AnalysisInput.Files{i});
        
        id_name = Participant.MappId;        
        
        %commands for transform from which the subject was traced to subject standard
        command1 = ['flirt -in /Users/amplmember/GoogleDrive/2017_MAPP_Sonja_PAG/PAG_Datasets/MAPP_15Participants_PAGProject_Validation2/inpt_mprage.nii.gz -ref /Volumes/AmplStorage2/Experiments/preproc/inpt/SUMA/inpt_SurfVol.nii -omat ' TempDir filesep 'traceROI_transform_inpt.mat'];
        command2 = ['applyxfm4d /Users/amplmember/GoogleDrive/2017_MAPP_Sonja_PAG/PAG_Datasets/MAPP_15Participants_TracedbyDoug_Validation2/filein/inpt_PAGMASK_mprage.nii.gz /Volumes/AmplStorage2/Experiments/preproc/inpt/SUMA/inpt_SurfVol.nii ' TempDir filesep 'traced2subj_inpt.nii.gz ' TempDir filesep 'traceROI_transform_inpt.mat -singlematrix'];
        command3 = ['fslmaths ' TempDir filesep 'traced2subj_inpt.nii.gz -thr 0.95 -bin ' TempDir filesep 'bintraced2subj_inpt.nii.gz'];

        %start of the mask process that is similar to how the white matter
        %was corrected to subject standard space - save to
        %follow_ROI_trace.nii
        %(FSWe) - save output in temp directory
        command4 = ['3dcopy ' TempDir filesep 'bintraced2subj_inpt.nii.gz ' TempDir filesep 'copy_af_traced'];
        command5 = ['3dNwarpApply -source ' TempDir filesep 'copy_af_traced+orig -master /Volumes/AmplStorage2/Experiments/preproc/inpt/SUMA/inpt.rest.results/pb03.inpt.rest.r01.volreg+tlrc -ainterp NN -nwarp  /Volumes/AmplStorage2/Experiments/preproc/inpt/SUMA/inpt.rest.results/anat.un.aff.qw_WARP.nii /Volumes/AmplStorage2/Experiments/preproc/inpt/SUMA/inpt.rest.results/anat.un.aff.Xat.1D -prefix ' TransformPath 'inpt/follow_ROI_traced'];
        command6 = ['3dAFNItoNIFTI follow_ROI_traced+tlrc.'];
        command7 = ['gzip follow_ROI_traced.nii'];
        
        input = 'inpt';
        name = id_name;
        
        %for command2 only
        input2 = 'filein';
        name2 = id_name(end-3:end);
        
        %apply commands in terminal
        command0_name = strrep(command0,input,name);
        command1_name = strrep(command1,input,name);
        command2_name = strrep(command2,input,name);
        command2_name = strrep(command2_name,input2,name2); %extra file name
        command3_name = strrep(command3,input,name);
        command4_name = strrep(command4,input,name);
        command5_name = strrep(command5,input,name);
        
        %cd(TempDir)
        system(command1_name);
        system(command2_name);
        system(command3_name);
        system(command4_name);
        system(command5_name);
        
        
        system([command0_name ' ; ' command6]);
        system([command0_name ' ; ' command7]);
        
        cd(BaseDirectory);
        
        command8 = ['rm ~/Desktop/transformTraced2SubjectPAG_AFNItransform_2_temp/*'];
        system(command8)
        
        
        
    end
    
catch err
    set(AnalysisInput.ProgramStatusIndicator,'string',[mfilename ':had an error. See Matlab window for details.'],'foregroundcolor','g');drawnow;
    cd(BaseDirectory);
    rethrow(err);
end

AnalysisOutput = 1;
