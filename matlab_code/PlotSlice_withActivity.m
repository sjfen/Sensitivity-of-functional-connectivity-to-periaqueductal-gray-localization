% this function plots values from a 3D activity image on standard brain
% slice

% Inputs: StandardBrain - nii.img (3d volume in the same space (e.g. 2mm standard) as the activity image
%         ActivityImg - ActivityImg.img (3d volume with values for plotting)
%         DimNum - dimension you want to use for slicing (x slices (first dimension
%                  in 3d volume) -> DimNum = 1; yslices (2nd dimension in 3d volume)
%                  -> DimNum = 2, etc.
%         SliceNum - index to plot in slice 
%         ActivityImgCmap - colormap to use for activity image plot
%         AxisHandle - the axis handle where you want to plot results

function PublishOutput = PlotSlice_withActivity(PublishInput)
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

load_untouch_nii = EnableHelperFunction([],{'nifti';'load_untouch_nii.m'});
load_untouch_nii_hdr = EnableHelperFunction([],{'nifti';'load_untouch_nii_hdr.m'});
load_untouch_nii_img = EnableHelperFunction([],{'nifti';'load_untouch_nii_img.m'});
    
h = figure;

cd('/Users/amplmember/GoogleDrive/DatabaserProject/HelperFunctions/nifti')

brainimag = load_untouch_nii(PublishInput.ResultFiles{1});
actvimag = load_untouch_nii(PublishInput.ResultFiles{2});

cd(BaseDirectory)

StandardBrain = brainimag.img;
ActivityImg = double(actvimag.img);

ActivityImg = abs(ActivityImg);


DimNum = str2num(cell2mat(inputdlg('What dimension are you interested in?')));
SliceNum = str2num(cell2mat(inputdlg('What is the slice number?')));
% SliceNum2 = str2num(cell2mat(inputdlg('What is the slice number overlay?')));
% [X, map] = rgb2ind(imread('/Volumes/AmplStorage2/Experiments/StatsData/PAG/Stats_PAG_10122018/VoxelBased_Correlation/AFNI_Voxelwise/HealthyPatients/AllData_ttest_check/colors.jpg'),128);
map = jet;
% map = [1 0 0];
ActivityImgCmap = map(32:end,:);
% ActivityImgCmap = flipud(map);
AxisHandle = axes(h);

    PlotSlice = EnableHelperFunction([],{'fMRI';'Graphics';'PlotSlice.m'});
    DimList = {'x','y','z'};
    
    % set the threshold of your activity plot
    ImgRange_Activity = [min(min(min(ActivityImg))) max(max(max(ActivityImg)))];
    
    % only show positive values
    if ImgRange_Activity(1)<=0
        ImgRange_Activity(1)=0.001;
    end
    
    
%     % only show negative values
%     if ImgRange_Activity(2)>=0
%         ImgRange_Activity(2)=-0.001;
%     end
    % colormap for the standard brain
    standardBrainCmap = gray(64);

    

%     % transform slice number to MNI coordinates and add to plot
%     R=[-2 0 0 90;
%         0 2 0 -126;
%         0 0 2 -72;
%         0 0 0 1];  % transform matrix for MNI2voxel
% 
%     pt = [1 1 (SliceNum-1)]'; % FSL indexing starts at 0
%     MNIpt = R*[pt;1];
% 
%     MNISlices = MNIpt(3);

MNISlices = SliceNum;

    % -------- Create Brain Map Background -----------
    if ~isempty(StandardBrain)
        img = double(StandardBrain);
        alphadata = ones(size(img));
        ImgRange = [min(min(min(img))) max(max(max(img)))];


        alphadata = ones(size(img));
        alphadata(find(img==0))=0;

        ImageHandle = PlotSlice(StandardBrain,ImgRange,DimNum,SliceNum,alphadata,standardBrainCmap,AxisHandle);
        axis off

    end


    % -------- Overlay activity image -----------
    if ~isempty(ActivityImg)
        img = double(ActivityImg);
        alphadata = ones(size(img));

        alphadata = ones(size(img));
        alphadata(find(img<=ImgRange_Activity(1)))=0;
%         alphadata(find(img>=ImgRange_Activity(2)))=0;

        hold on
        ImageHandle = PlotSlice(ActivityImg,ImgRange_Activity,DimNum,SliceNum,alphadata,ActivityImgCmap,AxisHandle);
        axis off
        lighting gouraud
        L = camlight('headlight');
        material dull

        Xlims = get(AxisHandle,'xlim');
        Ylims = get(AxisHandle,'ylim');
        
        DimLabel={'x','y','z'};
        tlabel = text(AxisHandle,(Xlims(2)-Xlims(1))/2,Ylims(2),[DimLabel{DimNum} ' = ' num2str(MNISlices)],'HorizontalAlignment','center','VerticalAlignment','middle');
            
    end
    
catch err
    set(PublishInput.ProgramStatusIndicator,'string','PlotSlice_withActivity had an error. See Matlab window for details.','foregroundcolor','r');drawnow;
    cd(BaseDirectory);
    rethrow(err);
end

PublishOutput = 1;