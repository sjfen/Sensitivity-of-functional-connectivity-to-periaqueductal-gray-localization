%check healthy control and patient differences in motion

figure, subplot(2,2,1); hist([MotionHC_M; MotionHC_F],x)
xlabel('Framewise displacement - mm')
set(gca,'xtick',[0 0.25 0.5 0.75 1]);
xlim([0 1])
title(['Healthy Control Motion: ' num2str(length([MotionHC_M; MotionHC_F])) ' TRs']);

subplot(2,2,2); hist([MotionP_M; MotionP_F],x)
xlabel('Framewise displacement - mm')
set(gca,'xtick',[0 0.25 0.5 0.75 1]);
xlim([0 1])
title(['Patient Motion: ' num2str(length([MotionP_M; MotionP_F])) ' TRs']);

subplot(2,2,[3,4]);
plot(mean([MotionHC_M; MotionHC_F],1), 'LineWidth', 4)
hold on; plot(mean([MotionP_M; MotionP_F],1), 'LineWidth', 4)
legend('Healthy Control', 'Patients')
xlabel('TR')
ylabel('Framewise displacement - mm')
title('Average motion across time (TR)');

%stats
[h,p]=ttest2(mean([MotionP_M; MotionP_F],2), mean([MotionHC_M; MotionHC_F],2));