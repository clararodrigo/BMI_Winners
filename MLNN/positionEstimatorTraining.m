function [modelParameters] = positionEstimatorTraining(training_data)

%% Find firing rates

[trial_count, dir] = size(training_data);

modelParameters.neuron_count = 98;

modelParameters.hidden_nodes = modelParameters.neuron_count;
modelParameters.V = zeros(modelParameters.neuron_count, modelParameters.hidden_nodes);
x = ones(modelParameters.hidden_nodes,1);

modelParameters.directions = 1;
modelParameters.W = zeros(modelParameters.hidden_nodes, modelParameters.directions);
v = ones(modelParameters.directions, 1);

epsilon_one = 0.5;
epsilon_two = 0.5;

error = zeros(trial_count*dir, 1);

count = 0;

spike_rate = [];
firing_rates = [];
temp_vx = [];
temp_vy = [];
trainingData = struct([]);
velocity = struct([]);
dt = 10; % bin size of 10

for dirn = 1:8
    for n = 1:98        
        for neuron = 1:trial_count                
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
modelParameters.beta = beta;

%% Neural Network
spikes = [];
reach_angle = [];
spike_count = zeros(length(training_data),98);

for dirn = 1:8
    for neuron = 1:98        
        for n = 1:trial_count
            total_spikes = length(find(training_data(n,dirn).spikes(neuron,1:320)==1));
            spike_count(n,neuron) = total_spikes;
        end        
    end
    spikes = cat(1, spikes, spike_count);
    if dirn == 1
        reaching_angle(1:length(training_data)) = 22.5;
    elseif dirn == 2
        reaching_angle(1:length(training_data)) = 67.5;
    elseif dirn == 3
        reaching_angle(1:length(training_data)) = 112.5;
    elseif dirn == 4
        reaching_angle(1:length(training_data)) = 157.5;
    elseif dirn == 5
        reaching_angle(1:length(training_data)) = 202.5;
    elseif dirn == 6
        reaching_angle(1:length(training_data)) = 247.5;
	elseif dirn == 7
        reaching_angle(1:length(training_data)) = 292.5;
    elseif dirn == 8
        reaching_angle(1:length(training_data)) = 337.5;
    end    
    reach_angle = cat(2, reach_angle, reaching_angle); 
end

for tri = 1:height(spikes)
    u = spikes(tri, :);
    x = sig(u*modelParameters.V);
    v = sig(x*modelParameters.W);
    
    true_pos = reach_angle(tri)/360; 
    pred_pos = v;
    
    %update W
    modelParameters.W = modelParameters.W - epsilon_one*(-(true_pos-pred_pos)*sigdash(x'.*modelParameters.W).*x');    
    
    %update V
   
    modelParameters.V = modelParameters.V - epsilon_two * (-(true_pos-pred_pos)*sigdash(x'.*modelParameters.W).*modelParameters.W).*sigdash(u'.*modelParameters.V);
 
end

end

function out = sig(in)
   beta = 0.5;
   out = (1+exp(-beta*in)).^(-1);
end

function out = sigdash(in)
    beta = 0.5;
    out = beta*exp(-beta*in).*(1+exp(-beta.*in)).^(-2);
end