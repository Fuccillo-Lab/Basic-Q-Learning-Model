function plotVB(result)
%%
SessionData=result.SessionData;
maxReward=max([result.SessionData.Rewarded{:}]);

orange = [1 0.3 0.3];
hold on;

xlabel('Trial Number')
ylabel('\Delta Q Value (Q Right - Q Left)')
ylim([-maxReward maxReward+5])
yticks([-12 -8 -4 0 4 8 12 13.5 15.5 16.5])
yticklabels({'-12','-8','-4','0','4','8','12','Block Type:','Left' 'Right'})

for i=1:SessionData.nTrials
    switch SessionData.choiceHistory{i}
        case 2
            dir=[16 17];
            colr='b';
        case 1
            dir=[16 15];
            colr=orange;
        case 0
            dir =[15 17];
            colr=[0.1 0.1 0.1];
    end
    if SessionData.Rewarded{i}==0
        colr='k';
        switch SessionData.choiceHistory{i}
            case 1
                dir=[16 16.5];
            case 2
                dir=[16 15.5];
            case 0
                colr=[0.1 0.1 0.1];
        end
    end
    plot([i i],dir,'Color',colr,'LineWidth',1.5);
end

currentType=SessionData.BlockTypes{1};
blockSwitch=zeros(1,SessionData.nTrials);
text(1,13.5,SessionData.BlockTypes{1})
for i=1:SessionData.nTrials
    if sum(currentType~=SessionData.BlockTypes{i})>0
        blockSwitch(i)=1;
        blockSwitch(i-5:i-1)=2;
        currentType=SessionData.BlockTypes{i};
    end
end

for i=1:SessionData.nTrials
    if SessionData.Laser(i)==1
        plot(polyshape([i-.5 -13;i+.5 -13; i+.5 12;i-.5 12]),...
            'FaceColor','g','FaceAlpha',0.2,'EdgeAlpha',0);
    end
    switch blockSwitch(i)
        case 1
            plot([i i],[-12 13.5],'k')
            text(i+1,13.5,SessionData.BlockTypes{i+1})
        case 2
            if SessionData.Laser(i)==1
                plot(polyshape([i-.5 -12;i+.5 -12; i+.5 12;i-.5 12]),...
                    'FaceColor','g','FaceAlpha',0.5,'EdgeAlpha',0);
            else
                plot(polyshape([i-.5 -12;i+.5 -12; i+.5 12;i-.5 12]),...
                    'FaceColor','k','FaceAlpha',0.2,'EdgeAlpha',0);
            end
            
    end
end

plot(1:SessionData.nTrials,result.QDifferences(1,:),'Color','k','LineWidth',1.5);
plot(1:SessionData.nTrials,zeros(1,SessionData.nTrials),'--','Color','k');

plot(1:SessionData.nTrials,ones(1,SessionData.nTrials)*16,'Color','k');

end
