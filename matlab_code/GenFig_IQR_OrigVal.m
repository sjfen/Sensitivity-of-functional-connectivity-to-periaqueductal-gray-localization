%This is figure 2 from the meeting with MCW on March 1, 2018
%This is used to generate the Power images of 'better' or 'worse'
%performances for the power analysis

function PublishOutput = GenFig_IQR_CombinedROI(PublishInput)
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
    
    set(PublishInput.ProgramStatusIndicator,'string','GenFig_IQR_CombinedROIt: Running...','foregroundcolor','g');drawnow;
    
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
    
    load(PublishInput.ResultFiles{3});%power matrix (for color and indicies)
    %%Original data
    
    %find a comparison where the Sphere > S.Space (IQR is smaller and median is
    %closer to 0 for the S.Space
    for i=1:264; OmedianR(i)=median(origdat.Result.Result2.Z_PAGR(:,i)-origdat.Result.Result2.Z_PAGHand(:,i)); end
    for i=1:264; OmedianMNI(i)=median(origdat.Result.Result2.Z_PAGMNI(:,i)-origdat.Result.Result2.Z_PAGHand(:,i)); end
    
    for i=1:264; OrR(i)=iqr(origdat.Result.Result2.Z_PAGR(:,i)-origdat.Result.Result2.Z_PAGHand(:,i)); end
    for i=1:264; OrMNI(i)=iqr(origdat.Result.Result2.Z_PAGMNI(:,i)-origdat.Result.Result2.Z_PAGHand(:,i)); end
    
    %quantile values
    for i=1:264; OqR(:,i)=quantile(origdat.Result.Result2.Z_PAGR(:,i)-origdat.Result.Result2.Z_PAGHand(:,i), [0.25 0.50 0.75]); end
    for i=1:264; OqMNI(:,i)=quantile(origdat.Result.Result2.Z_PAGMNI(:,i)-origdat.Result.Result2.Z_PAGHand(:,i), [0.25 0.50 0.75]); end
    
    Osmallerval = find(abs(OmedianR)>=abs(OmedianMNI) & OrR>=OrMNI);
    Otest.IQRmedianThresh = Osmallerval;
    
    Olargerval = find(abs(OmedianR)<=abs(OmedianMNI) & OrR<=OrMNI);
    Otest.IQRmedianoppThresh = Olargerval;
    
    
    
    Xvals2 = linspace(0,0.4,5000);
    
    
    %R.Wei
    for k = 1:size(Xvals2,2);
        for i=1:264;
            if  OqR(3,i) >= Xvals2(k) || OqR(1,i) <= -Xvals2(k) ;
                OroithreshR2(i,k) = 1;
            else OroithreshR2(i,k) = 0;
            end;
        end;
    end
    %MNI
    for k = 1:size(Xvals2,2);
        for i=1:264;
            if  OqMNI(3,i) >= Xvals2(k) || OqMNI(1,i) <= -Xvals2(k);
                OroithreshMNI2(i,k) = 1;
            else OroithreshMNI2(i,k) = 0;
            end;
        end;
    end
    
    OnumbroisR2 = sum(OroithreshR2);
    OnumbroisMNI2 = sum(OroithreshMNI2);
    
    %find the location of the threshold where S.space to S.specific (MNI to
    %hand) is either 1) at it's maximum (all ROIs covered within a
    %threshold) or 2) at it's minimum (no ROIs covered within a threshold)
    Oroival2 = find(OnumbroisR2==132); %change indicies here!
    OMNIindROI2 = Oroival2(1);
    
    
    %show the difference in ROIs on the S.sphere to S.specific brain (R.wei
    %to hand)
    OROIdiff1 = OroithreshR2(:,OMNIindROI2);
    OROIdiff2 = OroithreshMNI2(:,OMNIindROI2);
    Otest.Rstandard2Hand_threshR2 =find(OROIdiff1 == 1);
    Otest.Rstandard2Hand_threshMNI2 =find(OROIdiff2 == 1);
    %     test.ROI = 214; %change for both in this code vs 218
    Otest.ROI = 170;%changed from 171 for overlap
    Otest.ROI2 = 247;
    
    % % %
    %Valdation Data
    %find a comparison where the Sphere > S.Space (IQR is smaller and median is
    %closer to 0 for the S.Space
    for i=1:264; VmedianR(i)=median(valdat.Result.Result2.Z_PAGR(:,i)-valdat.Result.Result2.Z_PAGHand(:,i)); end
    for i=1:264; VmedianMNI(i)=median(valdat.Result.Result2.Z_PAGMNI(:,i)-valdat.Result.Result2.Z_PAGHand(:,i)); end
    
    for i=1:264; VrR(i)=iqr(valdat.Result.Result2.Z_PAGR(:,i)-valdat.Result.Result2.Z_PAGHand(:,i)); end
    for i=1:264; VrMNI(i)=iqr(valdat.Result.Result2.Z_PAGMNI(:,i)-valdat.Result.Result2.Z_PAGHand(:,i)); end
    
    %quantile values
    for i=1:264; VqR(:,i)=quantile(valdat.Result.Result2.Z_PAGR(:,i)-valdat.Result.Result2.Z_PAGHand(:,i), [0.25 0.50 0.75]); end
    for i=1:264; VqMNI(:,i)=quantile(valdat.Result.Result2.Z_PAGMNI(:,i)-valdat.Result.Result2.Z_PAGHand(:,i), [0.25 0.50 0.75]); end
    
    Vsmallerval = find(abs(VmedianR)>=abs(VmedianMNI) & VrR>=VrMNI);
    Vtest.IQRmedianThresh = Vsmallerval;
    
    Vlargerval = find(abs(VmedianR)<=abs(VmedianMNI) & VrR<=VrMNI);
    Vtest.IQRmedianoppThresh = Vlargerval;
    
    
    
    Xvals2 = linspace(0,0.4,1000);
    
    
    %R.Wei
    for k = 1:size(Xvals2,2);
        for i=1:264;
            if  VqR(3,i) >= Xvals2(k) || VqR(1,i) <= -Xvals2(k) ;
                VroithreshR2(i,k) = 1;
            else VroithreshR2(i,k) = 0;
            end;
        end;
    end
    %MNI
    for k = 1:size(Xvals2,2);
        for i=1:264;
            if  VqMNI(3,i) >= Xvals2(k) || VqMNI(1,i) <= -Xvals2(k);
                VroithreshMNI2(i,k) = 1;
            else VroithreshMNI2(i,k) = 0;
            end;
        end;
    end
    
    
    %     numbroisR = sum(roithreshR2);
    %     numbroisMNI = sum(roithreshMNI);
    VnumbroisR2 = sum(VroithreshR2);
    VnumbroisMNI2 = sum(VroithreshMNI2);
    
    %find the location of the threshold where S.space to S.specific (MNI to
    %hand) is either 1) at it's maximum (all ROIs covered within a
    %threshold) or 2) at it's minimum (no ROIs covered within a threshold)

    Vroival2 = find(VnumbroisR2==132); %change indicies here!
    VMNIindROI2 = Vroival2(1);
    
    
    %show the difference in ROIs on the S.sphere to S.specific brain (R.wei
    %to hand)

    VROIdiff1 = VroithreshR2(:,VMNIindROI2);
    VROIdiff2 = VroithreshMNI2(:,VMNIindROI2);
    Vtest.Rstandard2Hand_threshR2 =find(VROIdiff1 == 1);
    Vtest.Rstandard2Hand_threshMNI2 =find(VROIdiff2 == 1);
    %     test.ROI = 214; %change for both in this code vs 218
    Vtest.ROI = 91;
    Vtest.ROI2 = 82;
    
    %overlap calculation
    Overtest.IQRmedianThresh = intersect(Osmallerval,Vsmallerval);
    Overtest.IQRmedianoppThresh = intersect(Olargerval,Vlargerval);
    
    Overtest.ROI = 170;
    
    
    ax2 = [00.4276 0.9025 0.05573 0.0667];
    axes('position', ax2)
    plot([1],[(origdat.Result.Result2.Z_PAGR(:,Otest.ROI)-origdat.Result.Result2.Z_PAGHand(:,Otest.ROI))], '.', 'Color', [192/255 192/255 192/255], 'MarkerSize', 10), axis([0 3 -1 1])
    hold on;
    plot([2],[(origdat.Result.Result2.Z_PAGMNI(:,Otest.ROI)-origdat.Result.Result2.Z_PAGHand(:,Otest.ROI))], '.', 'Color', [112/255 112/255 112/255], 'MarkerSize', 10), axis([0 3 -1 1])
    
    %     xlabel({'S.Sphere'; 'S.Space'})
    set(gca, 'xtick', [1 2])
    %     set(gca, 'xticklabel',{'S.Sphere to S.Specific'; 'S.Space to S.Specific'})
    set(gca, 'xticklabel',{[]; []})
    set(gca, 'FontSize', 8)
    %     title('Standard Space Trace is a better estimate')
    %
    %     ax2 = [0.5043 0.7938 0.05573 0.0667];
    %     axes('position', ax2)
    %     plot([1],[(valdat.Result.Result2.Z_PAGR(:,Vtest.ROI2)-valdat.Result.Result2.Z_PAGHand(:,Vtest.ROI2))], '.', 'Color', [192/255 192/255 192/255], 'MarkerSize', 10), axis([0 3 -1 1])
    %     hold on;
    %     plot([2],[(valdat.Result.Result2.Z_PAGMNI(:,Vtest.ROI2)-valdat.Result.Result2.Z_PAGHand(:,Vtest.ROI2))], '.', 'Color', [112/255 112/255 112/255], 'MarkerSize', 10), axis([0 3 -1 1])
    %     %     xlabel({'S.Sphere'; 'S.Space'})
    %     set(gca, 'xtick', [1 2])
    %     %     set(gca, 'xticklabel',{'S.Sphere to S.Specific'; 'S.Space to S.Specific'})
    %     set(gca, 'xticklabel',{[]; []})
    %     set(gca, 'FontSize', 8)
    %
    %for overlap
    ax2 = [0.5043 0.7938 0.05573 0.0667];
    axes('position', ax2)
    plot([1],[(valdat.Result.Result2.Z_PAGR(:,Overtest.ROI)-valdat.Result.Result2.Z_PAGHand(:,Overtest.ROI))], '.', 'Color', [192/255 192/255 192/255], 'MarkerSize', 10), axis([0 3 -1 1])
    hold on;
    plot([2],[(valdat.Result.Result2.Z_PAGMNI(:,Overtest.ROI)-valdat.Result.Result2.Z_PAGHand(:,Overtest.ROI))], '.', 'Color', [112/255 112/255 112/255], 'MarkerSize', 10), axis([0 3 -1 1])
    %     xlabel({'S.Sphere'; 'S.Space'})
    set(gca, 'xtick', [1 2])
    %     set(gca, 'xticklabel',{'S.Sphere to S.Specific'; 'S.Space to S.Specific'})
    set(gca, 'xticklabel',{[]; []})
    set(gca, 'FontSize', 8)
    %     title('Standard Space Trace is a better estimate')
    
    %     ax2 = [0.8557 0.7562 0.1009 0.1711];
    %     axes('position', ax2)
    %     plot([1 2],[(Result.Result2.Z_PAGR(:,test.ROI2)-Result.Result2.Z_PAGHand(:,test.ROI2)) (Result.Result2.Z_PAGMNI(:,test.ROI2)-Result.Result2.Z_PAGHand(:,test.ROI2))], '.', 'Color', [128/255 128/255 128/255], 'MarkerSize', 24), axis([0 3 -1 1])
    %     xlabel({'S.Sphere to S.Specific'; 'S.Space to S.Specific'})
    %     set(gca, 'xtick', [1 2])
    % %     set(gca, 'xticklabel',{'S.Sphere to S.Specific'; 'S.Space to S.Specific'})
    %     set(gca, 'xticklabel',{[]; []})
    %     set(gca, 'FontSize', 8)
    %     title('Standard Space Trace is a worse estimate')
    
    for n = 1:8;
                
        ax = [{[0.04667 0.8237 0.18 0.14]}; {[0.04667 0.7 0.18 0.14]}; {[0.2283 0.8237 0.18 0.14]}; {[0.2283 0.7 0.18 0.14]}; {[0.5677 0.8279 0.18 0.14]}; {[0.5677 0.7 0.18 0.14]}; {[0.7513 0.8289 0.18 0.14]}; {[0.7513 0.7 0.18 0.14]}];
        
        BrainAxes = axes('position',[ax{n}]);
        
        % Both, RightHemi, and LeftHemi are available
        cd(Iso2MeshPath)
        
        hemi = [LeftHemi; LeftHemi; RightHemi; RightHemi; LeftHemi; LeftHemi; RightHemi; RightHemi ];
        Mesh = hemi(n);
        
        
        BrainHandle = plotmesh(Mesh.Node,Mesh.Face,'linestyle','none','facealpha',1);
        if n==2 || n==4 || n ==6 || n==8
            set(BrainHandle,'facecolor',[169/255 169/255 169/255]);
        else
            set(BrainHandle,'facecolor',[220/255 220/255 220/255]);
        end
        set(BrainHandle,'facevertexcdata',Mesh.Vector);
        
        a = [-90 90 90 -90 -90 90 90 -90];
        b = [0 0 0 0 0 0 0 0];
        view(a(n),b(n));
        lighting gouraud
        L = camlight('headlight');
        material dull
        set(BrainHandle,'facealpha',1)
        alpha(0.75)
        drawnow
        hold on
        axis off
        
        cd(BaseDirectory)
        
        cd('HelperFunctions');
        
        selecteddir=uigetdir('Select Directory of ROIs');
        allROIs = dir(selecteddir);
        
        for i = 1:size(allROIs,1)-2;
            ROInames{i} = allROIs(i+2).name;
        end
        
        filenames = ROInames(:);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Original or Validation selection
        answer = inputdlg('Indicate ''Original'' or ''Validation''')
        comparestr = cellstr(answer{1})

        if strcmp(comparestr,'Original')==1;
            [aval,bval] = SelectFromList(fieldnames(Otest));
            numb = struct2cell(Otest);

        elseif strcmp(comparestr,'Validation')==1
            [aval,bval] = SelectFromList(fieldnames(Vtest));
            numb = struct2cell(Vtest);
            
        else
            [aval,bval] = SelectFromList(fieldnames(Overtest));
            numb = struct2cell(Overtest);
            
            
        end
        
        newfilenames = filenames(numb{bval});
        
        cd(BaseDirectory);
        
        newPP264xyzlabelcolor = PP264xyzlabelcolor(numb{bval},:);
        
        C = colorcube(165);

        for i = 1:length(newfilenames)
            
            Filelocation{i} = [selecteddir filesep newfilenames{i}];
            
            [path,file,ext] = fileparts(Filelocation{i}(1:end-3));
            
            file = strsplit(file,'_');
            
            %determine which color for the network
            if newPP264xyzlabelcolor(i,5) == 1;
                color = [0 1 1];
            elseif newPP264xyzlabelcolor(i,5) == 2;
                color= [1 0.5 0.2];
            elseif newPP264xyzlabelcolor(i,5) == 3;
                color= [102 0 102]/255;
            elseif newPP264xyzlabelcolor(i,5) == 4;
                color = [255 204 229]/255;
            elseif newPP264xyzlabelcolor(i,5) == 5;
                color = [1 0 0];
            elseif newPP264xyzlabelcolor(i,5) == 6;
                color = [96 96 96]/255;
            elseif newPP264xyzlabelcolor(i,5) == 7;
                color = [0 0 1];
            elseif newPP264xyzlabelcolor(i,5) == 8;
                color = [1 1 0];
            elseif newPP264xyzlabelcolor(i,5) == 9;
                color = [0 0 0];
            elseif newPP264xyzlabelcolor(i,5) == 10;
                color = [102 0 0]/255;
            elseif newPP264xyzlabelcolor(i,5) == 11;
                color = [0 153 153]/255;
            elseif newPP264xyzlabelcolor(i,5) == 12;
                color = [0 204 0]/255;
            elseif newPP264xyzlabelcolor(i,5) == 13;
                color = [102 178 255]/255;
            elseif newPP264xyzlabelcolor(i,5) == 14;
                color = [1 1 1];
            else
                color = [1 1 1]; %uncategorized is white too
            end
            
            
            [Xs,Ys,Zs] = sphere(40);
            
            if n == 1 && newPP264xyzlabelcolor(i,1) <=0; %use if only using one hemisphere (right)
                
                X = newPP264xyzlabelcolor(i,1);
                Y = newPP264xyzlabelcolor(i,2);
                Z = newPP264xyzlabelcolor(i,3);

                r = 5; % radius, mm
                h = surf(X+r*Xs,Y+r*Ys,Z+r*Zs);
                set(h,'facecolor',[color])
                set(h,'linestyle','none')
                material dull
                
                
            elseif n == 5 && newPP264xyzlabelcolor(i,1) <=0; %use if only using one hemisphere (right)
                
                X = newPP264xyzlabelcolor(i,1);
                Y = newPP264xyzlabelcolor(i,2);
                Z = newPP264xyzlabelcolor(i,3);
                             
                r = 5; % radius, mm
                h = surf(X+r*Xs,Y+r*Ys,Z+r*Zs);
                set(h,'facecolor',[color])
                set(h,'linestyle','none')
                material dull
                
            elseif n==2 && newPP264xyzlabelcolor(i,1) <=0;
        
                X = newPP264xyzlabelcolor(i,1);
                Y = newPP264xyzlabelcolor(i,2);
                Z = newPP264xyzlabelcolor(i,3);               
                
                r = 5; % radius, mm
                h = surf(X+r*Xs,Y+r*Ys,Z+r*Zs);
                set(h,'facecolor',[color])
                set(h,'linestyle','none')
                material dull
                
            elseif n==6 && newPP264xyzlabelcolor(i,1) <=0;
                
                %if any(findstr(Region(n).name,'Right')) == 1 %use if only using one hemisphere (right)
                X = newPP264xyzlabelcolor(i,1);
                %X = Region(n).coordinates{2, 1}(1,1); % MNI, mm
                Y = newPP264xyzlabelcolor(i,2);
                %Y = Region(n).coordinates{2, 1}(1,2); % MNI, mm
                Z = newPP264xyzlabelcolor(i,3);
                %Z = Region(n).coordinates{2, 1}(1,3); % MNI, mm
                
                
                r = 5; % radius, mm
                h = surf(X+r*Xs,Y+r*Ys,Z+r*Zs);
                % set(h,'facecolor',[Region(n).network.color{2, 1}])
                set(h,'facecolor',[color])
                set(h,'linestyle','none')
                material dull
                
                
            elseif n==3 && newPP264xyzlabelcolor(i,1) >0; %use if only using one hemisphere (left);
                
                X = newPP264xyzlabelcolor(i,1);
                Y = newPP264xyzlabelcolor(i,2);
                Z = newPP264xyzlabelcolor(i,3);
                
                
                r = 5; % radius, mm
                h = surf(X+r*Xs,Y+r*Ys,Z+r*Zs);
                % set(h,'facecolor',[Region(n).network.color{2, 1}])
                set(h,'facecolor',[color])
                set(h,'linestyle','none')
                material dull
                
            elseif n==7 && newPP264xyzlabelcolor(i,1) >0; %use if only using one hemisphere (left);
                
                X = newPP264xyzlabelcolor(i,1);
                %X = Region(n).coordinates{2, 1}(1,1); % MNI, mm
                Y = newPP264xyzlabelcolor(i,2);
                %Y = Region(n).coordinates{2, 1}(1,2); % MNI, mm
                Z = newPP264xyzlabelcolor(i,3);
                %Z = Region(n).coordinates{2, 1}(1,3); % MNI, mm
                
                
                r = 5; % radius, mm
                h = surf(X+r*Xs,Y+r*Ys,Z+r*Zs);
                % set(h,'facecolor',[Region(n).network.color{2, 1}])
                set(h,'facecolor',[color])
                set(h,'linestyle','none')
                material dull
            elseif n==4 && newPP264xyzlabelcolor(i,1) >0; %use if only using one hemisphere (left);
                
                X = newPP264xyzlabelcolor(i,1);
                %X = Region(n).coordinates{2, 1}(1,1); % MNI, mm
                Y = newPP264xyzlabelcolor(i,2);
                %Y = Region(n).coordinates{2, 1}(1,2); % MNI, mm
                Z = newPP264xyzlabelcolor(i,3);
                %Z = Region(n).coordinates{2, 1}(1,3); % MNI, mm
                
                
                r = 5; % radius, mm
                h = surf(X+r*Xs,Y+r*Ys,Z+r*Zs);
                % set(h,'facecolor',[Region(n).network.color{2, 1}])
                set(h,'facecolor',[color])
                set(h,'linestyle','none')
                material dull
            elseif n==8 && newPP264xyzlabelcolor(i,1) >0; %use if only using one hemisphere (left);
                
                X = newPP264xyzlabelcolor(i,1);
                %X = Region(n).coordinates{2, 1}(1,1); % MNI, mm
                Y = newPP264xyzlabelcolor(i,2);
                %Y = Region(n).coordinates{2, 1}(1,2); % MNI, mm
                Z = newPP264xyzlabelcolor(i,3);
                %Z = Region(n).coordinates{2, 1}(1,3); % MNI, mm
                
                
                r = 5; % radius, mm
                h = surf(X+r*Xs,Y+r*Ys,Z+r*Zs);
                % set(h,'facecolor',[Region(n).network.color{2, 1}])
                set(h,'facecolor',[color])
                set(h,'linestyle','none')
                material dull
                
                
            else
            end
            
        end
    end
    
    
    
    
catch err
    set(PublishInput.ProgramStatusIndicator,'string','GenFig_IQR_CombinedROIS had an error. See Matlab window for details.','foregroundcolor','r');drawnow;
    cd(BaseDirectory);
    rethrow(err);
end

PublishOutput = 1;