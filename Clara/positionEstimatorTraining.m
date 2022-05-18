function [modelParameters] = positionEstimatorTraining(training_data)

modelParameters = struct();
modelParameters.weights = rand(98,4); % different parameters for each dimension
% The targets will be the change in x and y
l = 1; % this is the number of spike times we give (ive only tried with 1)
% TODO: look at how to make it flexible so l can be many things
% loss = zeros(670,1);
[m,n] = size(training_data);
for j=1:8%n
    for t=1:m
        for i=1:length(training_data(t,j).spikes(1,:))-l-2
            input = training_data(t,j).spikes(:,i); % this would change if l>1
            targets = training_data(t,j).handPos(1:2,i+1)-training_data(t,j).handPos(1:2,i); % we want dx and dy
            [modelParameters, error1, error2, change1, change2] = update_weights(modelParameters, input, targets);
        end
    end
end

end

function [modelParameters, error1, error2, change1, change2] = update_weights(modelParameters,inputs,targets)

    outputs = predict(modelParameters,inputs);

    error1 = rmse(targets(1), outputs(1,1)); % x error
    error2 = rmse(targets(2), outputs(1,2)); % y error
    
    change1 = inputs*(error1.*10*(1-(tanh(outputs(1,1))).^2));
    change2 = inputs*(error2.*10*(1-(tanh(outputs(1,2))).^2));

    if(targets(1) > outputs(1,1))
        modelParameters.weights(:,1) = modelParameters.weights(:,1) + change1;
    end
    if(targets(1) < outputs(1,1))
        modelParameters.weights(:,1) = modelParameters.weights(:,1) - change1;
    end
    if(targets(2) > outputs(1,2))
        modelParameters.weights(:,2) = modelParameters.weights(:,2) + change2;
    end
    if(targets(2) < outputs(1,2))
        modelParameters.weights(:,2) = modelParameters.weights(:,2) - change2;
    end
    
    % this is THE KEY (it cured my week-long agony)
    modelParameters.weights(:,1) = normalize(modelParameters.weights(:,1));
    modelParameters.weights(:,2) = normalize(modelParameters.weights(:,2));
end

function output = predict(modelParameters,inputs)
    m = inputs'*modelParameters.weights(:,1:2);
    output = m'*modelParameters.weights(:,3:4);
end
   
function error = rmse(a, b)
    error = sqrt(mean((a - b).^2));
end
