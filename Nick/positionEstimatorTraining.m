function [modelParameters] = positionEstimatorTraining(training_data)

trial_count = size(training_data);
neuron_count = size(training_data(1,1).spikes);

handPosEst = zeros(2, trial_count(2));

% Find the average peak response by the hand for each direction
hist = zeros(2, trial_count(2));

angles = zeros(1,8);
for direction = 1:trial_count(2)
    average_x_count = 0;
    average_y_count = 0;
    
    x_average = 0;
    y_average = 0;
    for tri = 1:trial_count(1)
        %get peak gradient from each trial
        xgradient = gradient(training_data(tri, direction).handPos(1, :));
        [M, ~] = max(xgradient);
        [N, ~] = min(xgradient);
        if abs(M)>abs(N)
            average_x_count = average_x_count + M;
        else
            average_x_count = average_x_count + N;
        end
        
        ygradient = gradient(training_data(tri, direction).handPos(2, :));
        [M, ~] = max(ygradient);
        [N, ~] = min(ygradient);
        if abs(M)>abs(N)
            average_y_count = average_y_count + M;
        else
            average_y_count = average_y_count + N;
        end
        
        x_average = x_average + training_data(tri,direction).handPos(1, end);
        y_average = y_average + training_data(tri,direction).handPos(2, end);
    end
    hist(1, direction) = average_x_count/trial_count(1);
    hist(2, direction) = average_y_count/trial_count(1);
    
    x_average = x_average/trial_count(1);
    y_average = y_average/trial_count(1);
    sign_x = x_average<0;
    angles(1, direction) = atan(y_average/x_average)+sign_x.*sign(y_average)*pi;
end

handPosEst = hist;

modelParameters.gradient = handPosEst;

neuron_tuning = zeros(neuron_count(1), trial_count(2));
for dir = 1:8
    avg = 0;
    for tri = 1:trial_count(1)
        avg = avg + sum(training_data(tri,dir).spikes, 2)/length(training_data(tri,dir).spikes);
    end
    neuron_tuning(:, dir) = avg/trial_count(1);
end
modelParameters.neuron_tuning = neuron_tuning;

direction_weights = ones(1, 8);
direction_weights(1,1) = 0.4175;
modelParameters.direction_weights = direction_weights;

end