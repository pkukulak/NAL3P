% A script for running speaker classification on
% MFCCs of utterances.
%
% Modify the parameters below for desired behavior.
% A model has already been trained in the file
% m_8_iter_100.


% Parameters for training.
M = 8;
d = 14;
max_iter = 10;
trainDataDir = '/u/cs401/speechdata/Training/';
testDataDir =  '/u/cs401/speechdata/Testing/';
fn_GMM = ''; % Change this if you want to save the model.

GMM = gmmTrain(trainDataDir, '', M, max_iter);
trainDD = dir([trainDataDir, filesep, '*']);
testDD = dir([testDataDir, filesep, '*.mfcc']);

% Attempt to classify every training example.
for N=1:length(testDD)
    speakerFn = strcat(testDataDir, '/', testDD(N).name);
    %disp(textDD(N).name);
    unkn_N = textread(speakerFn);
    unkn_N = unkn_N(:, 1:14);
    b = zeros(size(unkn_N,1), M);
    log_Ps = [];
    % Calculate likelihood for each speaker.
    for S=3:length(trainDD)
        spkr = trainDD(S).name;
        curr_w = GMM.(spkr).w;
        curr_mu = GMM.(spkr).mu;
        curr_sig = GMM.(spkr).sig;
        
        % Because I'm trash and I don't know how to vectorize this.
        for i=1:M
            mu_m = curr_mu(i, :);
            sig_m = curr_sig(i, :);
        
            log_b_m = -(sum(bsxfun(@minus, unkn_N, mu_m).^2, 2) ...
                      / (2 * sum(sig_m))) - (d / 2) * log(2 * pi) ...
                      - (.5 * log(prod(sig_m)));
            
            b(:, i) = log_b_m;
        end
       
        %[max_b, max_b_ix] = max(b, [], 2);
        %b = bsxfun(@minus, b, max_b); 

        % Probabilities and log probabilities.
        P = sum(bsxfun(@times, exp(b), curr_w.'), 2);
        log_P = sum(log(P), 1);
        %disp(size(P));
        %disp(size(log_P));
        % sorted_log_P = sort(log_P, 'descend');
        log_Ps = [log_Ps log_P];
        
    end
    %disp('unsorted');
    %disp(log_Ps);
    [sorted_log_Ps, ix] = sort(log_Ps, 'descend');
    %disp('sorted');
    %disp(sorted_log_Ps);
    disp(ix(1:5));
    predict_log_Ps = sorted_log_Ps(1:5);
    %disp(predict_log_Ps);
    %disp(trainDD(ix(1:5)+2));
    %disp(ix);
    predicts = arrayfun(@(x) x.name, trainDD(ix(1:5)+2), 'UniformOutput', false);
    %disp(predicts);
    
    dlmwrite(strcat('unkn_', num2str(N), '.lik'), predicts(:), 'delimiter', '');
    dlmwrite(strcat('unkn_', num2str(N), '.lik'), predict_log_Ps, '-append');
end
