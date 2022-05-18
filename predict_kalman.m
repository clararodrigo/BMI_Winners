%% predict kalman kalmans

function xhat = predict_kalman(kalmans,dirn,z)
xhat(:,1) = zeros(2,1);
P{1}= zeros(2,2);

for k=2:size(z{1},2)
    for neuron=1:98
        xbar(:,k) = kalmans{dirn}.A*xhat(:,k-1);
        Pbar{k} = kalmans{dirn}.A*(P{k-1})*transpose(kalmans{dirn}.A) + kalmans{dirn}.W; 
        K{k}= Pbar{k}*transpose(kalmans{dirn}.H)/(kalmans{dirn}.H*Pbar{k}*transpose(kalmans{dirn}.H)+kalmans{dirn}.Q); 
%         disp(det((kalmans{dirn}.H*Pbar{k}*transpose(kalmans{dirn}.H)+kalmans{dirn}.Q)));
        xhat(:,k) = xbar(:,k) + K{k}*(z{neuron}{k}-kalmans{dirn}.H*xbar(:,k));

        P{k}= (eye(size(K{k},1))- K{k}*kalmans{dirn}.H)*Pbar{k};
    end
end
end