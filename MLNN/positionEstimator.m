function [x, y, newModelParameters] = positionEstimator(test_data, modelParameters)

% estimate reaching angle
spike_count = zeros(98,1);

if length(test_data.spikes) <= 320
    for i = 1:98
        total_spikes = length(find(test_data.spikes(i,1:320)==1));
        spike_count(i) = total_spikes;
    end
    u = spike_count;
    x = sig(sum(u'*modelParameters.V));
    v = 260*sig(sum(x*modelParameters.W));    
    if v <= 45
        direction = 1;
    elseif v<=90
        direction = 2;
    elseif v<=135
        direction = 3;
    elseif v<=180
        direction = 4;
    elseif v<=225
        direction = 5;
    elseif v<=270
        direction = 6;
    elseif v<=315
        direction = 7;
    elseif v<=360
        direction = 8;
    else
       direction = 1;
    end
    modelParameters.direction = direction;
else
    direction = modelParameters.direction;
end

%% knn prediction
% takes x,y position and vz,vy (velocity of reaching angles) in a suvat
% equation
tmin = length(test_data.spikes)-20;
tmax = length(test_data.spikes);

% firing rate calculated
total_firing_rate = zeros(98,1);
for i = 1:98
    total_spikes = length(find(test_data.spikes(i,tmin:tmax)==1));
    total_firing_rate(i) = total_spikes/(20*0.001); % divided by 20ms time window
end
% estimate velocity
velocity_x = total_firing_rate'*modelParameters.beta(direction).reach_angle(:,1);
velocity_y = total_firing_rate'*modelParameters.beta(direction).reach_angle(:,2);

%% update parameters

if length(test_data.spikes) <= 320
    x = test_data.startHandPos(1);
    y = test_data.startHandPos(2);
else
    % previous position + velocity * 20ms (to get position) -> suvat
    x = test_data.decodedHandPos(1,length(test_data.decodedHandPos(1,:))) + velocity_x*(20*0.001);
    y = test_data.decodedHandPos(2,length(test_data.decodedHandPos(2,:))) + velocity_y*(20*0.001);
end
newModelParameters = modelParameters;

end

function out = sig(in)
   beta = 0.5;
   out = (1+exp(-beta*in))^(-1);
end