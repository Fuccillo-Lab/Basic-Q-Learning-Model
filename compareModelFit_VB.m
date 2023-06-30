%% Compare Model Fit
function [acc]=compareModelFit_VB(SessionData,alpha,whichModel,beta,decay,bias)
    if ~exist('SessionData','var')
       uiopen 
    end
    %% Check Model Fit    
    [choices,~]=extractChoices_VB(SessionData);
    if whichModel=='SoftMax'
        [choiceProbabilities, ~,~]=LV_QLearn_Softmax_VB(SessionData,alpha,beta,bias);
        choices = choices - 1;
        acc = -(transpose(choices(:))*log(choiceProbabilities(2,:))' + transpose((1-choices(:)))*log(choiceProbabilities(1,:))') ; %note that this is matrix multiplication so we get 1 values which will be a sum. See mtimes in matlab help
    elseif whichModel=='SoftDec'
        [choiceProbabilities, ~,~]=LV_QLearn_SoftmaxDecay_VB(SessionData,alpha,beta,bias,decay);
        choices = choices - 1;
        acc = -(transpose(choices(:))*log(choiceProbabilities(2,:))' + transpose((1-choices(:)))*log(choiceProbabilities(1,:))') ;%note that this is matrix multiplication so we get 1 values which will be a sum. See mtimes in matlab help
    
    end

    
end