%% Example script for running Q model fitting and plotting

    if ~exist('SessionData','var')
       disp('load up a Bpod Session')
       uiopen 
    end
    %%
    results=table({'model'},2,3,'VariableNames',{'ModelName','MedianAcc','Likelihood'});
    %% Test Softmax
    softmaxResult=fitQModel_VB(SessionData,'SoftMax');
    plotVB(softmaxResult);
    %% Test Softmax Accuracy
    accuracyList=zeros(1,2000);
    for i=1:2000
        accuracyList(i)=modelAccuracy_VB(softmaxResult);
    end
    figure()
    histogram(accuracyList);
    results.ModelName(1)={'SoftMax'};
    results.MedianAcc(1)=median(accuracyList);
    results.Likelihood(1)=softmaxResult.likelihood;
    
    hold on
    title('Measuring Accuracy of Softmax 2000 times')
    ylabel(' # of occurences')
    xlabel('Accuracy')
    hold off;
    %% Test Softmax Decay
    % NOT WORKING!!!!!!
%     softDecayResult=fitQModel_VB(SessionData,'SoftDec');
%     plotVB(softDecayResult);
%     
%         accuracyList=zeros(1,2000);
%     for i=1:2000
%         accuracyList(i)=modelAccuracy_VB(softDecayResult);
%     end
%     results.ModelName(2)={'SoftDec'};
%     results.MedianAcc(2)=median(accuracyList);
%     results.Likelihood(2)=softDecayResult.likelihood;
%     figure()
%     histogram(accuracyList);
%     hold on
%     title('Measuring Accuracy of Softmax Decay 2000 times')
%     ylabel(' # of occurences')
%     xlabel('Accuracy')
%     hold off;
