% Test Script to give to the students, March 2015
%% Continuous Position Estimator Test Script
% This function first calls the function "positionEstimatorTraining" to get
% the relevant modelParameters, and then calls the function
% "positionEstimator" to decode the trajectory. 

function RMSE = testFunction_for_students_MTb(BrainMachineInYourFaces)

load monkeydata_training.mat

% Set random number generator
rng(2013);
ix = randperm(length(trial));

% Select training and testing data (you can choose to split your data in a different way if you wish)
training_data = trial(ix(1:99),:);
test_data = trial(ix(99:end),:);

fprintf('Testing the continuous position estimator...')

meanSqError = 0;
n_predictions = 0;  

figure
hold on
axis square
grid

% Train Model
modelParameters = positionEstimatorTrainingKNN(training_data);
% modelParameters.direction = 4 % randi(8)
colours = ['r','b','g','c','m','k','y','r'];
for n=1:size(test_data,1)
    display(['Decoding block ',num2str(n),' out of ',num2str(size(test_data,1))]);
    pause(0.001)
    for dirn=randperm(8) 
        decodedHandPos = [];
        disp(dirn)
        times=320:20:size(test_data(n,dirn).spikes,2);
        
        for t=times
            past_current_trial.trialId = test_data(n,dirn).trialId;
            past_current_trial.spikes = test_data(n,dirn).spikes(:,1:t); 
            past_current_trial.decodedHandPos = decodedHandPos;

            past_current_trial.startHandPos = test_data(n,dirn).handPos(1:2,1); 
            
            [decodedPosX, decodedPosY, modelParameters] = positionEstimatorKNN(past_current_trial, modelParameters);          
            
            decodedPos = [decodedPosX; decodedPosY];
            decodedHandPos = [decodedHandPos decodedPos];
            
            meanSqError = meanSqError + norm(test_data(n,dirn).handPos(1:2,t) - decodedPos)^2;
            
        end
        n_predictions = n_predictions+length(times);
        hold on
        plot(decodedHandPos(1,:),decodedHandPos(2,:), 'color', colours(dirn), 'LineStyle', '--')
        plot(test_data(n,dirn).handPos(1,times),test_data(n,dirn).handPos(2,times), 'color', colours(dirn), 'LineStyle', '-')
    end
end
legend('Decoded Position', 'Actual Position');

RMSE = sqrt(meanSqError/n_predictions) 


end

