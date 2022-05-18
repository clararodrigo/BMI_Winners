function [x, y] = positionEstimator(test_data, modelParameters)

time = size(test_data.spikes);
%sum spikes of each neuron
spike_count = sum(test_data.spikes, 2);
%the more a neuron fires, the higher it's direction contributes to the
%total direction
neuron_directions = spike_count.*modelParameters.neuron_tuning
%total direction is a sum over all neuron contributions
total_direction = sum(neuron_directions, 1);
[m,n] = max(total_direction);

%initalise the hand positions
x = test_data.startHandPos(1, 1);
y = test_data.startHandPos(2, 1);

[M, ~] = max(total_direction);
if M~=0
    x = x+time(2)*sum(modelParameters.direction_weights.*modelParameters.gradient(1,:).*total_direction, 2)/(M);
    y = y+time(2)*sum(modelParameters.direction_weights.*modelParameters.gradient(2,:).*total_direction, 2)/(M);
end

end