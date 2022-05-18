function K = train_kalman(signal)
% trains using avg position for each angle
for dirn = 1:8
    
len = size(signal.avg_pos{dirn},2);

K{dirn}.X = signal.avg_pos{dirn}(1:2,1:len); 
K{dirn}.X_1 = signal.avg_pos{dirn}(1:2,1:(len-1)); 
K{dirn}.X_2 = signal.avg_pos{dirn}(1:2,2:len);
K{dirn}.A = K{dirn}.X_2*transpose(K{dirn}.X_1)/(K{dirn}.X_1*transpose(K{dirn}.X_1));

for i = 1:98
    K{dirn}.Z(i,:) = signal.l_PSTH{i,dirn}(:,1:len);
end 

K{dirn}.H = K{dirn}.Z*transpose(K{dirn}.X)/(K{dirn}.X*transpose(K{dirn}.X)); 
K{dirn}.W = (K{dirn}.X_2-K{dirn}.A*K{dirn}.X_1)*transpose(K{dirn}.X_2-K{dirn}.A*K{dirn}.X_1)./(size(K{dirn}.X_1,2));
K{dirn}.Q = (K{dirn}.Z - K{dirn}.H*K{dirn}.X)*transpose(K{dirn}.Z - K{dirn}.H*K{dirn}.X)/(size(K{dirn}.Z,2)); 
end 
end
