%differences in connectivity

function PublishOutput = Differences_WeiPreprocess(PublishInput)
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

  set(PublishInput.ProgramStatusIndicator,'string','Differences_WeiPreprocess: Running...','foregroundcolor','g');drawnow;

%----------- Your code here !!! ---------------

NPF = EnableHelperFunction([],{'NewPaperFigure.m'});%h = NPF('Margin',[0.5 0.5]);
fdr_bh= EnableHelperFunction([],{'fdr_bh';'fdr_bh.m'});

% % 
load(PublishInput.ResultFiles{1});

perctDiffPAGR2Hand = ((Result.Result2.Z_PAGR - Result.Result2.Z_PAGHand)*100)./Result.Result2.Z_PAGHand;
perctDiffPAGL2Hand = ((Result.Result2.Z_PAGL - Result.Result2.Z_PAGHand)*100)./Result.Result2.Z_PAGHand;

perctDiffPAGR2MNI = ((Result.Result2.Z_PAGR - Result.Result2.Z_PAGMNI)*100)./Result.Result2.Z_PAGMNI;
perctDiffPAGL2MNI = ((Result.Result2.Z_PAGL - Result.Result2.Z_PAGMNI)*100)./Result.Result2.Z_PAGMNI;

perctDiffMNI2Hand = ((Result.Result2.Z_PAGMNI - Result.Result2.Z_PAGHand)*100)./Result.Result2.Z_PAGHand;

meanPAGR2Hand = mean(perctDiffPAGR2Hand);
meanPAGL2Hand = mean(perctDiffPAGL2Hand);

meanPAGL2MNI = mean(perctDiffPAGL2MNI);
meanPAGR2MNI = mean(perctDiffPAGR2MNI);

meanMNI2Hand = mean(perctDiffMNI2Hand);

for i = 1:264;
    
    [hR2H(i),pR2H(i)] = ttest(Result.Result2.Z_PAGR(:,i)-Result.Result2.Z_PAGHand(:,i));
    [hM2H(i),pM2H(i)] = ttest(Result.Result2.Z_PAGMNI(:,i)-Result.Result2.Z_PAGHand(:,i));
    
    stdR2H(i)  = std(Result.Result2.Z_PAGR(:,i)-Result.Result2.Z_PAGHand(:,i));
    stdM2H(i) = std(Result.Result2.Z_PAGMNI(:,i)-Result.Result2.Z_PAGHand(:,i));
    
    [hR2H_paired(i),pR2H_paired(i)] = ttest(Result.Result2.Z_PAGR(:,i),Result.Result2.Z_PAGHand(:,i));
    [hM2H_paired(i),pM2H_paired(i)] = ttest(Result.Result2.Z_PAGMNI(:,i), Result.Result2.Z_PAGHand(:,i));
    
    [psR2H(i),hsR2H(i)] = signrank(Result.Result2.Z_PAGR(:,i)-Result.Result2.Z_PAGHand(:,i));
    [psM2H(i), hsM2H(i)] = signrank(Result.Result2.Z_PAGMNI(:,i)-Result.Result2.Z_PAGHand(:,i));
    
    [psR2H_paired(i),hsR2H_paired(i)] = signrank(Result.Result2.Z_PAGR(:,i),Result.Result2.Z_PAGHand(:,i));
    [psM2H_paired(i), hsM2H_paired(i)] = signrank(Result.Result2.Z_PAGMNI(:,i), Result.Result2.Z_PAGHand(:,i));
    
end


[hfR2H, crit_pR2H, adj_pR2H_fdr_bh]=fdr_bh(pR2H);
[hfM2H, crit_pM2H, adj_pM2H_fdr_bh] = fdr_bh(pM2H);

[hfsR2H, crit_psR2H, adj_psR2H_fdr_bh]=fdr_bh(psR2H);
[hfsM2H, crit_psM2H, adj_psM2H_fdr_bh] = fdr_bh(psM2H);

meanR2Hpval = mean(pR2H);
sdR2Hpval = std(pR2H);

meanM2Hpval = mean(pM2H);
sdM2Hpval = std(pM2H);

meansR2Hpval = mean(psR2H);
sdsR2Hpval = std(psR2H);

meansM2Hpval = mean(psM2H);
sdsM2Hpval = std(psM2H);

a = find(pR2H_paired <= 0.05);
b = find(psR2H_paired <= 0.05);
c = find(pM2H_paired <= 0.05);
d = find(psM2H_paired <= 0.05);
a2 = find(adj_pR2H_fdr_bh <= 0.05);
b2 = find(adj_psR2H_fdr_bh <= 0.05);
c2 = find(adj_pM2H_fdr_bh <= 0.05);
d2 = find(adj_psM2H_fdr_bh <= 0.05);
%

%within 20% of the mean connectivity
%Left Wei compared to traced hand
left20 = find((meanPAGL2Hand)<=20 & (meanPAGL2Hand)>=-20);
perctROIL = length(left20)/264*100;

%mean difference
totmeanPAGL2Hand = mean(meanPAGL2Hand);

%Right Wei compared traced hand
right20 = find((meanPAGR2Hand)<=20 & (meanPAGR2Hand)>=-20);
perctROIR = length(right20)/264*100;

%MNI compared traced hand
MNI20 = find((meanMNI2Hand)<=20 & (meanMNI2Hand)>=-20);
perctROIMNI = length(MNI20)/264*100;

%mean difference
totmeanPAGR2Hand = mean(meanPAGR2Hand);

sdPAGR2Hand = std(perctDiffPAGR2Hand);
[BPAGR2Hand, IPAGR2Hand] = sort(meanPAGR2Hand);
BsdPAGR2Hand = sdPAGR2Hand(IPAGR2Hand);
figure, plot(BPAGR2Hand, 'linewidth',2); hold on; plot(BPAGR2Hand+BsdPAGR2Hand, 'linewidth',1); hold on; plot(BPAGR2Hand-BsdPAGR2Hand, 'linewidth',1); 
ylim([ -500 500])
title('PAGR2Hand')
ylabel('Percent Change in Connectivity')
xlabel('Regions of Interest')

sdPAGL2Hand = std(perctDiffPAGL2Hand);
[BPAGL2Hand, IPAGL2Hand] = sort(meanPAGL2Hand);
BsdPAGL2Hand = sdPAGL2Hand(IPAGL2Hand);
figure, plot(BPAGL2Hand, 'linewidth',2); hold on; plot(BPAGL2Hand+BsdPAGL2Hand, 'linewidth',1); hold on; plot(BPAGL2Hand-BsdPAGL2Hand, 'linewidth',1); 
ylim([ -500 500])
title('PAGRL2Hand')
ylabel('Percent Change in Connectivity')
xlabel('Regions of Interest')

sdPAGR2MNI = std(perctDiffPAGR2MNI);
[BPAGR2MNI, IPAGR2MNI] = sort(meanPAGR2MNI);
BsdPAGR2MNI = sdPAGR2MNI(IPAGR2MNI);
figure, plot(BPAGR2MNI, 'linewidth',2); hold on; plot(BPAGR2MNI+BsdPAGR2MNI, 'linewidth',1); hold on; plot(BPAGR2MNI-BsdPAGR2MNI, 'linewidth',1); 
ylim([ -500 500])
title('PAGR2MNI')
ylabel('Percent Change in Connectivity')
xlabel('Regions of Interest')

sdPAGL2MNI = std(perctDiffPAGL2MNI);
[BPAGL2MNI, IPAGL2MNI] = sort(meanPAGL2MNI);
BsdPAGL2MNI = sdPAGL2MNI(IPAGL2MNI);
figure, plot(BPAGL2MNI, 'linewidth',2); hold on; plot(BPAGL2MNI+BsdPAGL2MNI, 'linewidth',1); hold on; plot(BPAGL2MNI-BsdPAGL2MNI); ylim([ -500 500])
title('PAGL2MNI')
ylabel('Percent Change in Connectivity')
xlabel('Regions of Interest')

sdMNI2Hand = std(perctDiffMNI2Hand);
[BMNI2Hand, IMNI2Hand] = sort(meanMNI2Hand);
BsdMNI2Hand = sdMNI2Hand(IMNI2Hand);
figure, plot(BMNI2Hand, 'linewidth',2); hold on; plot(BMNI2Hand+BsdMNI2Hand, 'linewidth',1); hold on; plot(BMNI2Hand-BsdMNI2Hand, 'linewidth',1); 
ylim([ -500 500])
title('MNI2Hand')
ylabel('Percent Change in Connectivity')
xlabel('Regions of Interest')

Result.Differences.meanVals = [ meanPAGL2Hand;  meanPAGR2Hand; meanPAGL2MNI; meanPAGR2MNI; meanMNI2Hand];
Result.Differences.Stats.ttest = [ pR2H; pM2H];
Result.Differences.Stats.signrank = [ psR2H; psM2H];
Result.Differences.Stats.ttest_corrected = [ adj_pR2H_fdr_bh; adj_pM2H_fdr_bh ];
Result.Differences.Stats.signrank_corrected = [adj_psR2H_fdr_bh; adj_psM2H_fdr_bh];
Result.Differences.Stats.Description = 'first row is the Standard Right Wei seed, the second row is the MNI seed';

Result.Differences.Description = 'meanVals: percent mean values across 15 subjects for Left Wei to Hand, Right Wei to Hand, Left Wei to MNI, Right Wei to MNI, and MNI to Hand; Stats: statistical values including the corrected (fdr_bh) and uncorrected pvalues';

save([PublishInput.ResultFiles{1}(1:end-4) '_Differences.mat'],'Result');

catch err
  set(PublishInput.ProgramStatusIndicator,'string','HistogramForFirstFourSubjects had an error. See Matlab window for details.','foregroundcolor','r');drawnow;
  cd(BaseDirectory);
  rethrow(err);
end

PublishOutput = 1;
