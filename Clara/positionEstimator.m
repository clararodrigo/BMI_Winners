function [x, y] = positionEstimator(test_data, modelParameters)
    trajs = zeros(2,1000); % i made it 1000 so all trajectories fit
    outputs = zeros(2,1000);
    trajs(:, 1) = test_data.startHandPos';
    x = trajs(1,1);
    y = trajs(2,1);
    for i=2:length(test_data.spikes)
        outputs(:,i) = predict(modelParameters, test_data.spikes(:,i));
%         [eRA, normDiff] = reachingAngleEstimator(iRA,iTest,maxLength, spikes)
        trajs(1,i) = trajs(1,i-1)+outputs(1,i);
        trajs(2,i) = trajs(2,i-1)+outputs(2,i);    
        x = trajs(1,i);
        y = trajs(2,i);
    end
end

function output = predict(modelParameters,inputs)
    output = inputs'*modelParameters.weights;
end
