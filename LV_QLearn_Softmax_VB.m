function [choiceProbabilities,Qvalues,rpe] = LV_QLearn_Softmax_VB(SessionData,alpha,beta,bias)

if ~exist('SessionData','var')
    uiopen
end
[choices,rewards]=extractChoices_VB(SessionData);
Qvalues = zeros(2,SessionData.nTrials);      %assume 0 for starting conditions (could fit)
rpe = zeros(size(Qvalues));

%% Train Weights
for n = 1:SessionData.nTrials-1
    %compute rpe
    switch choices(n)
        case 0
            rpe(1,n) = (0);
            rpe(2,n) = (0);
        case 1
            rpe(1,n) = (rewards(1,n)) - Qvalues(1,n); %compute rpe (negative rpe for 0uL rewards
            rpe(2,n) = (0);
        case 2
            rpe(1,n) = (0); %compute rpe (negative rpe for 0uL rewards
            rpe(2,n) = rewards(2,n) - Qvalues(2,n);
    end
    Qvalues(1, n+1) = Qvalues(1,n) + alpha*rpe(1,n);     %update chosen
    Qvalues(2, n+1) = Qvalues(2,n) + alpha*rpe(2,n);     % update unchosen with 0
end

choiceProbabilities = zeros(2,SessionData.nTrials);

for i=1:SessionData.nTrials
    choiceProbabilities(1,i)= 1/...
        ( 1+exp(1)^-(beta*(Qvalues(1,i)-Qvalues(2,i)) -bias) );
    
    choiceProbabilities(2,i)= 1/...
        ( 1+exp(1)^-(beta*(Qvalues(2,i)-Qvalues(1,i)) +bias) );
end

end