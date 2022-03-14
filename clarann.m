%% Initialization
% https://uk.mathworks.com/matlabcentral/answers/516023-how-to-write-back-propagation-code-without-using-neural-network-toolbox
clear ; close all; clc
load("monkeydata_training.mat")

% This is just applying a simple 1-layer NN (i thought the smaller, the
% faster itll be)

tic
% Init model
model = struct();
model.weights = rand(98,2); % different parameters for each dimension

% TRAINING_________________________________________________________________
% The targets will be the change in x and y
l = 1; % this is the number of spike times we give (ive only tried with 1)
% TODO: look at how to make it flexible so l can be many things
loss = zeros(670,1);
for j=1:8
    for t=1:60
        for i=1:length(trial(t,j).spikes(1,:))-l-2
            input = trial(t,j).spikes(:,i); % this would change if l>1
            targets = trial(t,j).handPos(1:2,i+1)-trial(t,j).handPos(1:2,i); % we want dx and dy
            [model, error1, error2, change1, change2] = update_weights(model, input, targets);
        end
    end
end

% TESTING__________________________________________________________________
trajs = zeros(16,1000); % i made it 1000 so all trajectories fit
outputs = zeros(2,1000);
for d=1:8 % testing one in each direction
    for i=2:length(trial(2,d).handPos(1,:))
        outputs(:,i) = predict(model, trial(2,d).spikes(:,i));
        trajs(2*d-1,i) = trial(2,d).handPos(1,i-1)+outputs(1,i);
        trajs(2*d,i) = trial(2,d).handPos(2,i-1)+outputs(2,i);
    end
end
toc
plot_estimates(trial,trajs) 

% Calculating RMSE (sorry for the ugliness)
rmse1 = sqrt(immse(trial(2,1).handPos(1:2,:),trajs(1:2,1:length(trial(2,1).handPos(1,:)))));
rmse2 = sqrt(immse(trial(2,2).handPos(1:2,:),trajs(3:4,1:length(trial(2,2).handPos(1,:)))));
rmse3 = sqrt(immse(trial(2,3).handPos(1:2,:),trajs(5:6,1:length(trial(2,3).handPos(1,:)))));
rmse4 = sqrt(immse(trial(2,4).handPos(1:2,:),trajs(7:8,1:length(trial(2,4).handPos(1,:)))));
rmse5 = sqrt(immse(trial(2,5).handPos(1:2,:),trajs(9:10,1:length(trial(2,5).handPos(1,:)))));
rmse6 = sqrt(immse(trial(2,6).handPos(1:2,:),trajs(11:12,1:length(trial(2,6).handPos(1,:)))));
rmse7 = sqrt(immse(trial(2,7).handPos(1:2,:),trajs(13:14,1:length(trial(2,7).handPos(1,:)))));
rmse8 = sqrt(immse(trial(2,8).handPos(1:2,:),trajs(15:16,1:length(trial(2,8).handPos(1,:)))));

% FUNCTIONS_________________________________________________________________
function [model, error1, error2, change1, change2] = update_weights(model,inputs,targets)

    outputs = predict(model,inputs);

    error1 = rmse(targets(1), outputs(1,1)); % x error
    error2 = rmse(targets(2), outputs(1,2)); % y error
    
    change1 = inputs*(error1.*10*(1-(tanh(outputs(1,1))).^2));
    change2 = inputs*(error2.*10*(1-(tanh(outputs(1,2))).^2));

    if(targets(1) > outputs(1,1))
        model.weights(:,1) = model.weights(:,1) + change1;
    end
    if(targets(1) < outputs(1,1))
        model.weights(:,1) = model.weights(:,1) - change1;
    end
    if(targets(2) > outputs(1,2))
        model.weights(:,2) = model.weights(:,2) + change2;
    end
    if(targets(2) < outputs(1,2))
        model.weights(:,2) = model.weights(:,2) - change2;
    end
    
    % this is THE KEY (it cured my week-long agony)
    model.weights(:,1) = normalize(model.weights(:,1));
    model.weights(:,2) = normalize(model.weights(:,2));
end
   
function output = predict(model,inputs)
    output = inputs'*model.weights;
end

function error = rmse(a, b)
    error = sqrt(mean((a - b).^2));
end

function plot_estimates(trial, predicted)
    figure()
    for i=1:8
        plot(trial(2,i).handPos(1,:),trial(2,i).handPos(2,:))
        hold on
        plot(predicted(2*i-1,:), predicted(2*i,:))
    end
end