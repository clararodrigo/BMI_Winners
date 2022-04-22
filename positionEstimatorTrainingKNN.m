function [modelParameters] = positionEstimatorTraining(training_data)

%% Find firing rates

spike_rate = [];
firing_rates = [];
temp_vx = [];
temp_vy = [];
trainingData = struct([]);
velocity = struct([]);
dt = 10; % bin size of 10

for dirn = 1:8
    for n = 1:98
        for neuron = 1:length(training_data)
            for t = 300:dt:550-dt
                
                % find the firing rates of one neural unit for one trial
                total_spikes = length(find(training_data(neuron,dirn).spikes(n,t:t+dt)==1));
                spike_rate = cat(2, spike_rate, total_spikes/(dt*0.001));
                
                % find the velocity of the hand movement
                % (needs calculating just once for each trial)
                if n==1
                    x1 = training_data(neuron,dirn).handPos(1,t);
                    x2 = training_data(neuron,dirn).handPos(1,t+dt);
                    y1 = training_data(neuron,dirn).handPos(2,t);
                    y2 = training_data(neuron,dirn).handPos(2,t+dt);
                    
                    vx = (x2 - x1) / (dt*0.001);
                    vy = (y2 - y1) / (dt*0.001);
                    temp_vx = cat(2, temp_vx, vx);
                    temp_vy = cat(2, temp_vy, vy);
                end
            end
            % store firing rates and concat for each neuron+trial
            firing_rates = cat(2, firing_rates, spike_rate);
            spike_rate = [];
        end
        trainingData(n,dirn).firing_rates = firing_rates;
        velocity(dirn).x = temp_vx;
        velocity(dirn).y = temp_vy;
       
        firing_rates = [];
    end
    temp_vx = [];
    temp_vy = [];
end

%% Linear Regression
% used to predict velocity
beta = struct([]);

for dirn=1:8
    vel = [velocity(dirn).x; velocity(dirn).y];
    total_firing_rate = [];
    for n=1:98
    total_firing_rate = cat(1, total_firing_rate, trainingData(n,dirn).firing_rates);
    end 
    beta(dirn).reach_angle = lsqminnorm(total_firing_rate',vel');
end

%% KNN Classifier
% used to predict the reaching angle from the first 320ms

spikes = [];
reach_angle = [];
spike_count = zeros(length(training_data),98);

for dirn = 1:8
    for neuron = 1:98
        for n = 1:length(training_data)
                total_spikes = length(find(training_data(n,dirn).spikes(neuron,1:320)==1));
                spike_count(n,neuron) = total_spikes;
        end
    end
    spikes = cat(1, spikes, spike_count);
    reaching_angle(1:length(training_data)) = dirn;
    reach_angle = cat(2, reach_angle, reaching_angle); 
end

knn = fitcknn(spikes,reach_angle);

modelParameters = struct('beta',beta,'knnModel',knn); 
end