function signal = signal_processing(trial,dt)

signal = struct();

signal.l_PSTH = cell(98,8);
signal.l_local = cell(98,8);
signal.avg_pos = cell(1,8);

for n=1:size(trial,1)
    for a = 1:size(trial,2)
    sizes_recordings(n,a) = length(trial(n,a).spikes(1,:));
    end 
end

for i = 1:size(trial(1,1).spikes,1)
     for a = 1:size(trial,2)

        max_len = max(sizes_recordings(:,a));
        min_len = min(sizes_recordings(:,a));

signal.l_PSTH{i,a} = zeros(1, max_len); 

A = zeros(1,max_len);
B = zeros(1,max_len);

signal.l_local{i,a} = zeros(size(trial,1), max_len);

A = trial(n,a).spikes(i,:);
for j = (dt+1):(length(A))
    l(j) = sum(A((j-dt):j))./(dt);
end

for n = 1:size(trial,1)

len = length(trial(n,a).spikes(i,:));
B(1:len) = B(1:len) + trial(n,a).spikes(i,:);

signal.l_local{i,a}(n,1:length(l)) = l;

B(1:len) = B(1:len) + trial(n,a).spikes(i,:);
end 

l = zeros(1,length(B));

for j = (dt+1):(length(B))
 l(j) = sum(B((j-dt):j))./(dt);
end

 signal.l_PSTH{i,a}(1:min_len) = l(1:min_len)./100;
 
        for index = (min_len+1):max_len
        signal.l_PSTH{i,a}(index) = l(index)./sum((sizes_recordings(:,a)>(index-1)));
        end
     end 
end 

% now get direction and avg position per direction
    for dirn = 1:8
        max_len = max(sizes_recordings(:,dirn));
        min_len = min(sizes_recordings(:,dirn));
        signal.avg_pos{dirn} = zeros(3,max_len);
        
        for n = 1:100
        signal.avg_pos{dirn}(:,1:size(trial(n,dirn).handPos,2)) = signal.avg_pos{dirn}(:,1:size(trial(n,dirn).handPos,2)) + trial(n,dirn).handPos;
        end
        signal.avg_pos{dirn}(:,1:min_len) = signal.avg_pos{dirn}(:,1:min_len)./n;
        for index = (min_len+1):max_len
        signal.avg_pos{dirn}(:,index) = signal.avg_pos{dirn}(:,index)./sum((sizes_recordings(:,dirn)>(index-1)));
       end
    end
end