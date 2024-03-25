%% Example script for running Q model fitting and plotting

%% Load in the data
nAnimals=14;
resultStruct=struct();
cd('C:\Users\Luigim\Dropbox\Bpod\Master Bpod Data')
%Files to analyze should be local or in path for this code to work.
for i = 1:nAnimals
    disp(['Choose the laser data for animal ' num2str(i)])
    animalData=uigetfile;
    animalName=strsplit(animalData,'_');
    animalName=animalName(1);
    resultStruct(i).animalName=animalName;
    load(animalData)
    resultStruct(i).SessionData=SessionData;
end
cd('C:\Users\Luigim\Documents\MATLAB\LV_QLearn_VolumeBlocks\QLearning\Basic-Q-Learning-Model')
% Manually Annotate laser side!
laserKey=['R';'L';'L';'R';'R';'R';'L';'L';'L';'R';'R';'L';'L';'R';]; %aDMS post staggered
% laserKey=['B';'B';'B';'B';'B';'B';'B';'B';'B';'B';'B';'B';'B';];
% laserKey=['R';'R';'L';'R';'L';'L';'L';'L';'R';'R';'L';'L';'R';'L';'R']; %pDMS pre
% laserKey=['R';'R';'L';'R';'L';'L';'L';'L';'R';'R';'L';'R';'L']; %pDMS post
postChoiceInhibition=true;
bilateralLaser=false;
filename='aDMS_unilateral_post_staggered2';
for i=1:nAnimals
    resultStruct(i).laserSide=laserKey(i);
    
end
%% Perform model fits on each dataset
for i = 1:nAnimals
%     Test Softmax Decay
        resultStruct(i).softDecayResult=fitQModel_VB(resultStruct(i).SessionData,'SoftDec');
    resultStruct(i).likelihood=resultStruct(i).softDecayResult.likelihood;
    resultStruct(i).alpha=resultStruct(i).softDecayResult.alpha;
    resultStruct(i).beta=resultStruct(i).softDecayResult.beta;
    resultStruct(i).bias=resultStruct(i).softDecayResult.bias;
    resultStruct(i).decay=resultStruct(i).softDecayResult.decay;
    
    % We want bias terms to be considered in terms of ipsi and contralateral.
    % Currently, a negative bias terms indicates a bias to the left side and a 
    % positive bias term indicates a bias to the right side.

    % We will make it so that a positive bias is correlated with choosing the
    % contralateral side, whereas negative bias is correlated with the
    % ipsilateral side.
    if resultStruct(i).laserSide=='R'
        resultStruct(i).bias=-(resultStruct(i).bias);
    end
end

%% Plot Results
for i = 1:nAnimals
    figure()
    subplot(1,2,1)
    hold on
    softDecayResult=resultStruct(i).softDecayResult;
    title(resultStruct(i).animalName{1})
    plotVB(softDecayResult);
    %% Test Softmax with full decay accuracy
    accuracyList=zeros(1,2000);
    for j=1:2000
        accuracyList(j)=modelAccuracy_VB(softDecayResult);
    end
    resultStruct(i).MedianAcc=median(accuracyList);
    
    subplot(1,2,2)
    hold on
    histogram(accuracyList);
    hold on
    title('Measuring Accuracy of Softmax Decay Model 2000 times')
    ylabel(' # of occurences')
    xlabel('Accuracy')
    hold off;
    
    
end
%% Analysis for how Q value differences influence choice - PreChoice/Unilateral
%% Plot Q Difference vs Choice 
    figure()
    hold on
    ylim([0 1])
    xlim([0 7])
    xticks([1.5 3.5 5.5])
    xticklabels({'-12 to -4','-4 to 4','4 to 12'})
    xlabel('Q Ipsi - Q Contra')
    ylabel('Probability (Contralateral)')
    title('Effect of Unilateral Laser on choice at different Q Values')
    
    for j =1:nAnimals
        softDecayResult=resultStruct(j).softDecayResult;
        laserObserved=zeros(1,SessionData.nTrials);
%         softDecayResult=superStruct(j).SansLaserSMD;
        if postChoiceInhibition==true
            for i=2:length(softDecayResult.choices)
                laserObserved(i)=softDecayResult.SessionData.Laser(i-1);
            end
        else
            laserObserved=softDecayResult.SessionData.Laser;
        end
        laserBin=table(softDecayResult.choices(1), softDecayResult.QDifferences(1),...
            'VariableNames',{'Choice','QDiff'});
        noLaserBin=table(softDecayResult.choices(1), softDecayResult.QDifferences(1),...
            'VariableNames',{'Choice','QDiff'});
        %Trackers for when to move on to secondary rows
        LB=false;
        NLB=false;
        
        for i=1:softDecayResult.SessionData.nTrials
            switch resultStruct(j).laserSide %Make Q Difference = Q Contra - Q Ipsi
                case 'L'
                   softDecayResult.QDifferences(i)=softDecayResult.Qvalues(1,i)-softDecayResult.Qvalues(2,i);
                case 'R'
                   softDecayResult.QDifferences(i)=softDecayResult.Qvalues(2,i)-softDecayResult.Qvalues(1,i);
            end
            
            if laserObserved(i)==1
                if height(laserBin)==1 && LB==false
                    laserBin.Choice(1)=softDecayResult.choices(i);
                    laserBin.QDiff(1)=softDecayResult.QDifferences(i);
                    LB=true;
                else
                    laserBin.Choice(height(laserBin)+1)=softDecayResult.choices(i);
                    laserBin.QDiff(height(laserBin))=softDecayResult.QDifferences(i);
                end
                
            else
                if height(noLaserBin)==1 && NLB==false
                    noLaserBin.Choice(1)=softDecayResult.choices(i);
                    noLaserBin.QDiff(1)=softDecayResult.QDifferences(i);
                    NLB=true;
                else
                    noLaserBin.Choice(height(noLaserBin)+1)=softDecayResult.choices(i);
                    noLaserBin.QDiff(height(noLaserBin))=softDecayResult.QDifferences(i);
                end
            end
        end
        %% Subsets
        sectLB1=laserBin(laserBin.QDiff < -4,:);
        sectLB2=laserBin(laserBin.QDiff >= -4 & laserBin.QDiff <=4,:);
        sectLB3=laserBin(laserBin.QDiff > 4,:);
        
        sectNLB1=noLaserBin(noLaserBin.QDiff < -4,:);
        sectNLB2=noLaserBin(noLaserBin.QDiff >= -4 & noLaserBin.QDiff <=4,:);
        sectNLB3=noLaserBin(noLaserBin.QDiff > 4,:);
        
        if resultStruct(j).laserSide=='L'
            contralateral=2;
        elseif resultStruct(j).laserSide=='R'
            contralateral=1;
        else
            contralateral=1;
            xlabel('Q Right - Q Left')
            ylabel('Probability (Left)')
            title('Effect of Bilateral Laser on choice at different Q Values')
        end

        plot(1:2,[height(sectNLB1(sectNLB1.Choice==contralateral,:))/height(sectNLB1) height(sectLB1(sectLB1.Choice==contralateral,:))/height(sectLB1)],'Color',[0.8 0.8 0.8])
        
        plot(3:4,[height(sectNLB2(sectNLB2.Choice==contralateral,:))/height(sectNLB2) height(sectLB2(sectLB2.Choice==contralateral,:))/height(sectLB2)],'Color',[0.8 0.8 0.8])
       
        plot(5:6,[height(sectNLB3(sectNLB3.Choice==contralateral,:))/height(sectNLB3) height(sectLB3(sectLB3.Choice==contralateral,:))/height(sectLB3)],'Color',[0.8 0.8 0.8])
       
        softmaxStruct(j).noLaserBin1=height(sectNLB1(sectNLB1.Choice==contralateral,:))/height(sectNLB1);
        softmaxStruct(j).laserBin1=height(sectLB1(sectLB1.Choice==contralateral,:))/height(sectLB1);
        changeScore(j).bin1=softmaxStruct(j).laserBin1-softmaxStruct(j).noLaserBin1;
        
        softmaxStruct(j).noLaserBin2=height(sectNLB2(sectNLB2.Choice==contralateral,:))/height(sectNLB2);
        softmaxStruct(j).laserBin2=height(sectLB2(sectLB2.Choice==contralateral,:))/height(sectLB2);
        changeScore(j).bin2=softmaxStruct(j).laserBin2-softmaxStruct(j).noLaserBin2;
        
        softmaxStruct(j).noLaserBin3=height(sectNLB3(sectNLB3.Choice==contralateral,:))/height(sectNLB3);
        softmaxStruct(j).laserBin3=height(sectLB3(sectLB3.Choice==contralateral,:))/height(sectLB3);
        changeScore(j).bin3=softmaxStruct(j).laserBin3-softmaxStruct(j).noLaserBin3;
    end
    plot(1:2,[nanmean([softmaxStruct(:).noLaserBin1]) nanmean([softmaxStruct(:).laserBin1])],'k-o','MarkerFaceColor','k')
    plot(3:4,[nanmean([softmaxStruct(:).noLaserBin2]) nanmean([softmaxStruct(:).laserBin2])],'k-o','MarkerFaceColor','k')
    plot(5:6,[nanmean([softmaxStruct(:).noLaserBin3]) nanmean([softmaxStruct(:).laserBin3])],'k-o','MarkerFaceColor','k')
    
    scatter(2,nanmean([softmaxStruct(:).laserBin1]),'g','filled');
    scatter(4,nanmean([softmaxStruct(:).laserBin2]),'g','filled');
    scatter(6,nanmean([softmaxStruct(:).laserBin3]),'g','filled');
   
%% Analysis for how Q value differences influence choice - BILATERAL/Post-Choice ONLY
if postChoiceInhibition==true
    figure()
    for k=1:3
        tabulatedTrials=table([],[],[],[],[],...
            'VariableNames',{'PrevChoice','QPrev','Stay','PrevLaser','PrevReward'});
        subplot(3,1,k)
        hold on
        for i=1:nAnimals
            for j=2:resultStruct(i).SessionData.nTrials
                if cell2mat(resultStruct(i).SessionData.choiceHistory(j))==0
                    continue
                elseif cell2mat(resultStruct(i).SessionData.choiceHistory(j-1))==0
                    continue
                end
                prevChoice=cell2mat(resultStruct(i).SessionData.choiceHistory(j-1));
                tableRow=table(prevChoice,round(resultStruct(i).softDecayResult.Qvalues(prevChoice,j-1)),...
                    prevChoice==cell2mat(resultStruct(i).SessionData.choiceHistory(j)),...
                    resultStruct(i).SessionData.Laser(j-1),cell2mat(resultStruct(i).SessionData.Rewarded(j-1)),...
                    'VariableNames',{'PrevChoice','QPrev','Stay','PrevLaser','PrevReward'});
                tabulatedTrials=vertcat(tabulatedTrials,tableRow);
            end
            
            switch k
                case 1
                    rewardedPlot=0;
                case 2
                    rewardedPlot=4;
                case 3
                    rewardedPlot=12;
            end
            laserBin=tabulatedTrials(tabulatedTrials.PrevLaser==1 & tabulatedTrials.PrevReward==rewardedPlot,:);
            noLaserBin=tabulatedTrials(tabulatedTrials.PrevLaser==0 & tabulatedTrials.PrevReward==rewardedPlot,:);
            sectLB1=laserBin(laserBin.QPrev >= 0 & laserBin.QPrev < 2,:);
            sectLB2=laserBin(laserBin.QPrev >= 2 & laserBin.QPrev < 4,:);
            sectLB3=laserBin(laserBin.QPrev >= 4 & laserBin.QPrev < 6,:);
            sectLB4=laserBin(laserBin.QPrev >= 6 & laserBin.QPrev < 8,:);
            sectLB5=laserBin(laserBin.QPrev >= 8 & laserBin.QPrev < 10,:);
            sectLB6=laserBin(laserBin.QPrev >= 10,:);
            
            sectNLB1=noLaserBin(noLaserBin.QPrev >= 0 & noLaserBin.QPrev < 2,:);
            sectNLB2=noLaserBin(noLaserBin.QPrev >= 2 & noLaserBin.QPrev < 4,:);
            sectNLB3=noLaserBin(noLaserBin.QPrev >= 4 & noLaserBin.QPrev < 6,:);
            sectNLB4=noLaserBin(noLaserBin.QPrev >= 6 & noLaserBin.QPrev < 8,:);
            sectNLB5=noLaserBin(noLaserBin.QPrev >= 8 & noLaserBin.QPrev < 10,:);
            sectNLB6=noLaserBin(noLaserBin.QPrev >= 10,:);
            
            
            
            plot(1:2,[height(sectNLB1(sectNLB1.Stay==1,:))/height(sectNLB1) height(sectLB1(sectLB1.Stay==1,:))/height(sectLB1)],'Color',[0.8 0.8 0.8])
            plot(3:4,[height(sectNLB2(sectNLB2.Stay==1,:))/height(sectNLB2) height(sectLB2(sectLB2.Stay==1,:))/height(sectLB2)],'Color',[0.8 0.8 0.8])
            plot(5:6,[height(sectNLB3(sectNLB3.Stay==1,:))/height(sectNLB3) height(sectLB3(sectLB3.Stay==1,:))/height(sectLB3)],'Color',[0.8 0.8 0.8])
            plot(7:8,[height(sectNLB4(sectNLB4.Stay==1,:))/height(sectNLB4) height(sectLB4(sectLB4.Stay==1,:))/height(sectLB4)],'Color',[0.8 0.8 0.8])
            plot(9:10,[height(sectNLB5(sectNLB5.Stay==1,:))/height(sectNLB5) height(sectLB5(sectLB5.Stay==1,:))/height(sectLB5)],'Color',[0.8 0.8 0.8])
            plot(11:12,[height(sectNLB6(sectNLB6.Stay==1,:))/height(sectNLB6) height(sectLB6(sectLB6.Stay==1,:))/height(sectLB6)],'Color',[0.8 0.8 0.8])
            
            softmaxStruct(i).laserBin1=height(sectLB1(sectLB1.Stay==1,:))/height(sectLB1);
            softmaxStruct(i).noLaserBin1=height(sectNLB1(sectNLB1.Stay==1,:))/height(sectNLB1);
            
            softmaxStruct(i).laserBin2=height(sectLB2(sectLB2.Stay==1,:))/height(sectLB2);
            softmaxStruct(i).noLaserBin2=height(sectNLB2(sectNLB2.Stay==1,:))/height(sectNLB2);
            
            softmaxStruct(i).laserBin3=height(sectLB3(sectLB3.Stay==1,:))/height(sectLB3);
            softmaxStruct(i).noLaserBin3=height(sectNLB3(sectNLB3.Stay==1,:))/height(sectNLB3);
            
            softmaxStruct(i).laserBin4=height(sectLB4(sectLB4.Stay==1,:))/height(sectLB4);
            softmaxStruct(i).noLaserBin4=height(sectNLB4(sectNLB4.Stay==1,:))/height(sectNLB4);
            
            softmaxStruct(i).laserBin5=height(sectLB5(sectLB5.Stay==1,:))/height(sectLB5);
            softmaxStruct(i).noLaserBin5=height(sectNLB5(sectNLB5.Stay==1,:))/height(sectNLB5); %#ok<*SAGROW>
            
            softmaxStruct(i).laserBin6=height(sectLB6(sectLB6.Stay==1,:))/height(sectLB6);
            softmaxStruct(i).noLaserBin6=height(sectNLB6(sectNLB6.Stay==1,:))/height(sectNLB6);
        end
        
        ylim([0 1])
        xlim([0 13])
        xticks([1.5 3.5 5.5 7.5 9.5 11.5])
        xticklabels({'0 to 2', '2 to 4', '4 to 6', '6 to 8', '8 to 10', '10 to 12'})
        switch k
            case 1
                title('Laser Effect on Previously 0UL Trials')
                ylabel('\fontsize{18}P(Stay)')
                xlabel('Q Value before Outcome on t-1')
            case 2
                title('Laser Effect on Previously 4UL Outcome Trials')
                ylabel('\fontsize{18}P(Stay)')
                xlabel('Q Value before Outcome on t-1')
            case 3
                title('Laser Effect on Previously 12UL Outcome Trials')
                ylabel('\fontsize{18}P(Stay)')
                xlabel('Q Value before Outcome on t-1')
        end
        
        plot(1:2,[nanmean([softmaxStruct(:).noLaserBin1]) nanmean([softmaxStruct(:).laserBin1])],'k-o','MarkerFaceColor','k')
        plot(3:4,[nanmean([softmaxStruct(:).noLaserBin2]) nanmean([softmaxStruct(:).laserBin2])],'k-o','MarkerFaceColor','k')
        plot(5:6,[nanmean([softmaxStruct(:).noLaserBin3]) nanmean([softmaxStruct(:).laserBin3])],'k-o','MarkerFaceColor','k')
        plot(7:8,[nanmean([softmaxStruct(:).noLaserBin4]) nanmean([softmaxStruct(:).laserBin4])],'k-o','MarkerFaceColor','k')
        plot(9:10,[nanmean([softmaxStruct(:).noLaserBin5]) nanmean([softmaxStruct(:).laserBin5])],'k-o','MarkerFaceColor','k')
        plot(11:12,[nanmean([softmaxStruct(:).noLaserBin6]) nanmean([softmaxStruct(:).laserBin6])],'k-o','MarkerFaceColor','k')
        
        scatter(2,nanmean([softmaxStruct(:).laserBin1]),'g','filled');
        scatter(4,nanmean([softmaxStruct(:).laserBin2]),'g','filled');
        scatter(6,nanmean([softmaxStruct(:).laserBin3]),'g','filled');
        scatter(8,nanmean([softmaxStruct(:).laserBin4]),'g','filled');
        scatter(10,nanmean([softmaxStruct(:).laserBin5]),'g','filled');
        scatter(12,nanmean([softmaxStruct(:).laserBin6]),'g','filled');
    end
end

%% Throwing Darts
figure()
hold on
xlim([0 3])
ylim([-2 2])
ylabel('Bias Term (Positive = contraltaeral, negative = ipsilateral)')
xlabel('Unilateral Laser Side')
xticks(1:2)
xticklabels({'R','L'})
for i=1:length(resultStruct)
    switch resultStruct(i).laserSide
        case 'R'
            scatter(1,resultStruct(i).bias,'k')
        case 'L'
            scatter(2,resultStruct(i).bias,'k')
    end
end

%% Save Data
save(filename)