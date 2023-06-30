function [choices,rewards]=extractChoices_VB(SessionData)

if ~exist('SessionData','var')
   uiopen 
end
%%

choices=cell2mat(SessionData.choiceHistory);
rewards=zeros(2,SessionData.nTrials);

for i=1:SessionData.nTrials

    switch SessionData.BlockTypes{i}
        case '12-0'
            rewards(1,i)=12;
            rewards(2,i)=0;
        case '12-4'
            rewards(1,i)=12;
            rewards(2,i)=4;
        case '4-12'
            rewards(1,i)=4;
            rewards(2,i)=12;
        case '0-12'
            rewards(1,i)=0;
            rewards(2,i)=12;
    end
    
    switch choices(i)
        case 1
            rewards(1,i)=SessionData.Rewarded{i};
        case 2
            rewards(2,i)=SessionData.Rewarded{i};
    end
end


