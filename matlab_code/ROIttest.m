%load ROI signals

%switch out ROI selection
% ROIselection = CustoutMNIonMNIgm; 
ROIselection = CustoutWeionWeigm;

for i = 1:1000; index = randperm(size(ROIselection,1)); 
    New_ROIselection = ROIselection(index,:);
    PdataFinal1 = New_ROIselection(1:100, 3:end); 
    HCdataFinal1=New_ROIselection(101:end, 3:end);
    
    for j = 1:9; %change j for the number of ROIs
        [~,pFinal1(j,i)] = ttest2(table2array(PdataFinal1(:,j)), table2array(HCdataFinal1(:,j))) ; 
    end; 
end

PdataRealFinal1 = ROIselection(1:100, 3:end);
HCdataRealFinal1 = ROIselection(101:end, 3:end);


% for k = 1:19; 
    [~,pactFinal1] = ttest2(table2array(PdataRealFinal1),table2array(HCdataRealFinal1), 'Tail', 'left');
% end

for i=1:9; count(i) = length(find(pFinal1(i,:)<=pactFinal1(1,i))); end %change i for the number of ROIs

p = pactFinal1(1,:)'
c = count'
