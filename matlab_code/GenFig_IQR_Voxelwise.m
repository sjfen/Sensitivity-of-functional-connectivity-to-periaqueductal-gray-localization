%generate voxelwise Better or Worse images

function PublishOutput = GenFig_IQR_Voxelwise(PublishInput)
% Publishing Methods are .m functions that look at result files and produce new result files or publication figures
% PublishInput
%     .ResultFiles - cell array of file names passed to the method
%     .HelperFunctions - cell array of helper function names to be used with EnableHelperFunction
%     .PathSep - path separator '/' in mac/linux and '\' in windows
%     .ProgramStatusIndicator - a handle to the Program Status Indicator on the front panel so that status can be updated from within the reader
% PublishOutput - not currently used
%

BaseDirectory = cd;

try
    
    set(PublishInput.ProgramStatusIndicator,'string','GenFig_IQR_Voxelwise: Running...','foregroundcolor','g');drawnow;
    
    %----------- Your code here !!! ---------------
    
    load('HelperFunctions/fMRI/Graphics/StandardBrain.mat');
    CorticalVolumeBlob = EnableHelperFunction([],{'fMRI';'Graphics';'CorticalVolumeBlob.m'});
    LoadUntouchNiiGz = EnableHelperFunction([],{'fMRI';'LoadUntouchNiiGz.m'});
    SaveUntouchNiiGz = EnableHelperFunction([],{'fMRI';'SaveUntouchNiiGz.m'});
    fdr_bh= EnableHelperFunction([],{'fdr_bh';'fdr_bh.m'});
    
    NPF = EnableHelperFunction([],{'NewPaperFigure.m'});h = NPF('Margin',[0.5 0.5]);
    Iso2MeshPath = 'HelperFunctions/iso2mesh';
    load('HelperFunctions/fMRI/Graphics/StandardBrainPrepared.mat');
    CorticalSurface = EnableHelperFunction([],{'fMRI';'Graphics';'CorticalSurface.m'});
    load('HelperFunctions/fMRI/Graphics/NeuroColorMaps.mat');
    strsep = EnableHelperFunction([],'strsep.m');
    
    Iso2MeshPath2 = 'HelperFunctions/iso2mesh_ampl4';
    
    origdat = load(PublishInput.ResultFiles{1});
    valdat = load(PublishInput.ResultFiles{2});
    load('/Users/amplmember/GoogleDrive/2017_MAPP_Sonja_PAG/Stats/VoxelBased_Correlation/PowerComparison/MaskVoxelCoord.mat')
    
    %%Original data
    
    %find a comparison where the Sphere > S.Space (IQR is smaller and median is
    %closer to 0 for the S.Space
    for i=1:size(origdat.Result.Result2.Z_PAGR,2); OmedianR(i)=median(origdat.Result.Result2.Z_PAGR(:,i)-origdat.Result.Result2.Z_PAGHand(:,i)); end
    for i=1:size(origdat.Result.Result2.Z_PAGR,2); OmedianMNI(i)=median(origdat.Result.Result2.Z_PAGMNI(:,i)-origdat.Result.Result2.Z_PAGHand(:,i)); end
    
    for i=1:size(origdat.Result.Result2.Z_PAGR,2); OrR(i)=iqr(origdat.Result.Result2.Z_PAGR(:,i)-origdat.Result.Result2.Z_PAGHand(:,i)); end
    for i=1:size(origdat.Result.Result2.Z_PAGR,2); OrMNI(i)=iqr(origdat.Result.Result2.Z_PAGMNI(:,i)-origdat.Result.Result2.Z_PAGHand(:,i)); end
    
    %quantile values
    for i=1:size(origdat.Result.Result2.Z_PAGR,2); OqR(:,i)=quantile(origdat.Result.Result2.Z_PAGR(:,i)-origdat.Result.Result2.Z_PAGHand(:,i), [0.25 0.50 0.75]); end
    for i=1:size(origdat.Result.Result2.Z_PAGR,2); OqMNI(:,i)=quantile(origdat.Result.Result2.Z_PAGMNI(:,i)-origdat.Result.Result2.Z_PAGHand(:,i), [0.25 0.50 0.75]); end
    
    Osmallerval = find(abs(OmedianR)>=abs(OmedianMNI) & OrR>=OrMNI);
    Otest.IQRmedianThresh = Osmallerval;
    
    Olargerval = find(abs(OmedianR)<=abs(OmedianMNI) & OrR<=OrMNI);
    Otest.IQRmedianoppThresh = Olargerval;
    
    % % %
    %Valdation Data
    %find a comparison where the Sphere > S.Space (IQR is smaller and median is
    %closer to 0 for the S.Space
    for i=1:size(valdat.Result.Result2.Z_PAGR,2); VmedianR(i)=median(valdat.Result.Result2.Z_PAGR(:,i)-valdat.Result.Result2.Z_PAGHand(:,i)); end
    for i=1:size(valdat.Result.Result2.Z_PAGR,2); VmedianMNI(i)=median(valdat.Result.Result2.Z_PAGMNI(:,i)-valdat.Result.Result2.Z_PAGHand(:,i)); end
    
    for i=1:size(valdat.Result.Result2.Z_PAGR,2); VrR(i)=iqr(valdat.Result.Result2.Z_PAGR(:,i)-valdat.Result.Result2.Z_PAGHand(:,i)); end
    for i=1:size(valdat.Result.Result2.Z_PAGR,2); VrMNI(i)=iqr(valdat.Result.Result2.Z_PAGMNI(:,i)-valdat.Result.Result2.Z_PAGHand(:,i)); end
    
    %quantile values
    for i=1:size(valdat.Result.Result2.Z_PAGR,2); VqR(:,i)=quantile(valdat.Result.Result2.Z_PAGR(:,i)-valdat.Result.Result2.Z_PAGHand(:,i), [0.25 0.50 0.75]); end
    for i=1:size(valdat.Result.Result2.Z_PAGR,2); VqMNI(:,i)=quantile(valdat.Result.Result2.Z_PAGMNI(:,i)-valdat.Result.Result2.Z_PAGHand(:,i), [0.25 0.50 0.75]); end
    
    Vsmallerval = find(abs(VmedianR)>=abs(VmedianMNI) & VrR>=VrMNI);
    Vtest.IQRmedianThresh = Vsmallerval;
    
    Vlargerval = find(abs(VmedianR)<=abs(VmedianMNI) & VrR<=VrMNI);
    Vtest.IQRmedianoppThresh = Vlargerval;
    
    %overlap calculation
    Overtest.IQRmedianThresh = intersect(Osmallerval,Vsmallerval);
    Overtest.IQRmedianoppThresh = intersect(Olargerval,Vlargerval);
    
    Overtest.ROI = 170;
    
    mask_group=load_untouch_nii('/Volumes/AmplStorage2/Experiments/preproc/0101101231/SUMA/0101101231.rest.results/mask_group.nii')
image = mask_group.img

[allVoxels, ind_allVoxels] = find(image == 1);
ind_allVoxels = find(image == 1)

ind_OBetter = ind_allVoxels(Osmallerval);
ind_VBetter = ind_allVoxels(Vsmallerval);
ind_VWorse = ind_allVoxels(Vlargerval);
ind_OWorse = ind_allVoxels(Olargerval);

OBetter = zeroImg;
OBetter(ind_OBetter) =1;
OWorse = zeroImg;
OWorse(ind_OWorse) = 1;
VWorse = zeroImg;
VWorse(ind_VWorse) = 1;
VBetter = zeroImg;
VBetter(ind_VBetter) = 1;

OBetter_Full = mask_group;
OBetter_Full.img = OBetter;
VBetter_Full = mask_group;
VBetter_Full.img = VBetter;
OWorse_Full = mask_group;
OWorse_Full.img = OWorse;
VWorse_Full = mask_group;
VWorse_Full.img = VWorse;

save_untouch_nii(OBetter_Full, '~/Desktop/OBetter.nii')
save_untouch_nii(VBetter_Full, '~/Desktop/VBetter.nii')
save_untouch_nii(VWorse_Full, '~/Desktop/VWorse.nii')
save_untouch_nii(OWorse_Full, '~/Desktop/OWorse.nii')
    
catch err
    set(PublishInput.ProgramStatusIndicator,'string','GenFig_IQR_CombinedROIS had an error. See Matlab window for details.','foregroundcolor','r');drawnow;
    cd(BaseDirectory);
    rethrow(err);
end

PublishOutput = 1;