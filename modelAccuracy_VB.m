%% Compare Model Fit
function [acc]=modelAccuracy_VB(Result)
SessionData=Result.SessionData;
model=Result.model;
[choices,~]=extractChoices_VB(SessionData);
weightedChoices = zeros(1,SessionData.nTrials);

%% Check Model Accuracy
if model=='SoftMax'
    [choiceProbabilities, ~,~]=LV_QLearn_Softmax_VB(Result.SessionData,...
        Result.alpha,Result.beta,Result.bias);
end

if model=='SoftDec'
    [choiceProbabilities, ~,~]=LV_QLearn_SoftmaxDecay_VB(Result.SessionData,...
        Result.alpha,Result.beta,Result.bias,Result.decay);
end

%Generate choices using probabilities from softmax equation
accurateGuess=zeros(1,SessionData.nTrials);
for i=1:SessionData.nTrials
    c=rand(1);
    if c<choiceProbabilities(1,i)
        weightedChoices(i)=1;
    else
        weightedChoices(i)=2;
    end
    
    if weightedChoices(i)==choices(i)
        accurateGuess(i)=1;
    end
    
end
acc=sum(accurateGuess(5:end))/(SessionData.nTrials-4);

end