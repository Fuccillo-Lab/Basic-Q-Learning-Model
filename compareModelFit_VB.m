%% Compare Model Fit
function [likelihood]=compareModelFit_VB(SessionData,alpha,whichModel,beta,decay,bias)
    if ~exist('SessionData','var')
       uiopen 
    end
    %% Check Model Fit    
    [choices,~]=extractChoices_VB(SessionData);
    if whichModel=='SoftMax'
        [choiceProbabilities, ~,~]=LV_QLearn_Softmax_VB(SessionData,alpha,beta,bias);
    elseif whichModel=='SoftDec'
        [choiceProbabilities, ~,~]=LV_QLearn_SoftmaxDecay_VB(SessionData,alpha,beta,bias,decay);
    end
%% Negative log likelihood
% The log likelihood for each choice is calculated. Then we inverse the
% result so that the minimization function will maximize the likelihood.
    likelihood=0;
    for i = 1:length(choices)
        switch choices(i)
            case 0 
                %omitted choice. No change to likelihood
            case 1 
                likelihood=likelihood+ log(choiceProbabilities(1,i));
            case 2
                likelihood=likelihood+ log(choiceProbabilities(2,i));
        end
    end
    likelihood=-likelihood;
    
end