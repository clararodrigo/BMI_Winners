clear all; 
close all;
fprintf('Loading data...\n')
load('monkeydata_training.mat');

signal = signal_processing(trial,20);

%% kalman learning
kalmans = trainKalman(signal);

%% predict handpos 

xhattot = 0;
figure (1);

for dirn=1:8
    z = cell(98,1); %,length(output.l_local{98,8}(100,:)));
for exp = 1:100
for neuron = 1:98
    storethis = num2cell(signal.l_local{neuron,dirn}(exp,:),100); 
    % to smooth use this: movmean(output.l_local{neuron,dirn}(exp,:),100);
    z{neuron} = storethis;
end
xhat = predictKalman(kalmans,dirn,z);
% err(exp) = sqrt(immse(trial(exp,dirn).handPos(1:2,:),xhat(1:2,1:length(trial(exp,dirn).handPos))));
end 
hold on
plot(trial(1,dirn).handPos(1,:),trial(1,dirn).handPos(2,:),'b');
plot(xhat(1,:),xhat(2,:), 'r');
end

% plot(err,'b'); hold on; yline(mean(err),'r--');