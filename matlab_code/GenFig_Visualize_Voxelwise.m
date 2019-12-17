
function PublishOutput = GenFig_Visualize_Voxelwise(PublishInput)
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
    
    set(PublishInput.ProgramStatusIndicator,'string','GenFig_Visualize_Voxelwise: Running...','foregroundcolor','g');drawnow;
    
    %----------- Your code here !!! ---------------
    
    LoadUntouchNiiGz = EnableHelperFunction([],{'fMRI'; 'LoadUntouchNiiGz.m'});
    load('HelperFunctions/fMRI/Graphics/StandardBrain.mat');
    load('HelperFunctions/fMRI/Graphics/NeuroColorMaps.mat');
    CorticalSurfaceActivity = EnableHelperFunction([],{'fMRI';'Graphics';'CorticalSurfaceActivity.m'});
    Iso2MeshPath = 'HelperFunctions/iso2meshNew_ampl4';
    NPF = EnableHelperFunction([],{'NewPaperFigure.m'});h = NPF('Margin',[0.5 0.5]);
    
%     AxesHandle = axes('position', [0.1483 0.7925 0.2633 0.1763]);
    
    OBetter = LoadUntouchNiiGz(PublishInput.ResultFiles{1}, BaseDirectory);
    VBetter = LoadUntouchNiiGz(PublishInput.ResultFiles{2}, BaseDirectory);
    BothBetter = OBetter;
    BothBetter.img = OBetter.img.*VBetter.img;
    
    
    
    for n = 1:12; %we are looking at 4 different sides of the brain for 3 different datasets: Original, Validation, Overlap
        
        %          ax= [{[0.21 0.7457 0.1789 0.3]}; {[0.3525 0.7457 0.1789 0.24]};{[0.4275 0.7457 0.1789 0.24]}; {[0.57 0.7457 0.1789 0.3]}];
        
        ax = [{[0.08232 0.7915 0.1057 0.1846]}; {[0.19 0.7915 0.1057 0.1846]}; {[0.08232 0.612 0.1057 0.1846]}; {[0.19 0.612 0.1057 0.1846]}; {[0.3358 0.7915 0.1057 0.1846]}; {[0.4435 0.7915 0.1057 0.1846]}; {[0.3358 0.6017 0.1057 0.1846]}; {[0.4435 0.6017 0.1057 0.1846]}; {[0.08232 0.3282 0.1057 0.1846]}; {[0.19 0.3282 0.1057 0.1846]}; {[0.08232 0.147 0.1057 0.1846]}; {[0.19 0.147 0.1057 0.1846]}];
        
        BrainAxes = axes('position',[ax{n}]);
        %0.235 0.7457 0.1789 0.2895
        
        % Both, RightHemi, and LeftHemi are available
%         cd(Iso2MeshPath)
        
        % Mesh = RightHemi;
        %         hemi = [RightHemi; Both; LeftHemi];
        
        if mod(n,2) == 1 % odd number
            hemi = 'left';
        else
            hemi = 'right';
        end
            
%         hemi = ['left'; 'left'; 'right'; 'right'; 'left'; 'left'; 'right'; 'right';'left'; 'left'; 'right'; 'right'];
%         Mesh = hemi(n);
        
        if n==1 || n==2 || n==3 || n==4
            Activity(1) = OBetter;
        elseif n==5 || n==6 || n==7 || n==8
            Activity(1) = VBetter;
        else
        Activity(1) = BothBetter;
        end
        
        
        Pos.max = 2;
        Pos.thresh = 0;
        Pos.cmap = RedYellow;
        Neg.max = 2;
        Neg.thresh = 0;
        Neg.cmap = BlueLightBlue;
        
%         BrainHandle = plotmesh(Mesh.Node,Mesh.Face,'linestyle','none','facealpha',1);
%         BrainHandle = CorticalSurfaceActivity(AxesHandle,nii.img,6000,Activity,Pos,Neg,Iso2MeshPath,BaseDirectory,'left',47)
        BrainHandle = CorticalSurfaceActivity(BrainAxes,nii.img,6000,Activity,Pos,Neg,Iso2MeshPath,BaseDirectory,hemi,47)
        
        a = [-90 90 90 -90 -90 90 90 -90 -90 90 90 -90];
        %     b = [0 90 0];
        %         b = [0 90  0];
        b = [0 0 0 0 0 0 0 0 0 0 0 0];
        view(a(n),b(n));
        lighting gouraud
        L = camlight('headlight');
        material dull
        set(BrainHandle,'facealpha',1)
%         alpha(0.75)
        drawnow
        hold on
        axis off
        
    end
    
    
catch err
    set(PublishInput.ProgramStatusIndicator,'string','GenFig_IQR_CombinedROIS had an error. See Matlab window for details.','foregroundcolor','r');drawnow;
    cd(BaseDirectory);
    rethrow(err);
end

PublishOutput = 1;