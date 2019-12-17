%stats on MNI to HAND and TRAD (wei trace) to HAND 
load('PAGConnectivityall30altMNI092018.mat')

for i = 1:size(Result.Participant,1); 
    meanWei(i,:) = Result.Participant(i).ROI(266).MeanSignalCensoredNAN; 
    meanMNI(i,:) = Result.Participant(i).ROI(267).MeanSignalCensoredNAN; 
    meanHand(i,:) = Result.Participant(i).ROI(268).MeanSignalCensoredNAN; 
end

for i = 1:30; 
    [rho_meanHandWei(i), pval_meanHandWei(i)] = corr(meanHand(i,:)', meanWei(i,:)','Rows','complete');
end

for i = 1:30; 
    [rho_meanHandMNI(i), pval_meanHandMNI(i)] = corr(meanHand(i,:)', meanMNI(i,:)','Rows','complete');
end

rhotan_meanHandWei = atan(rho_meanHandWei);
rhotan_meanHandMNI = atan(rho_meanHandMNI);

[h p stats] = ttest(rhotan_meanHandWei',rhotan_meanHandMNI');