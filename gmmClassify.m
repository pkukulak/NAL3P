% Parameters for training.
M = 8;
d = 14;
max_iter = 1;
trainDataDir = '/u/cs401/speechdata/Training/';
testDataDir = '/u/cs401/speechdata/Testing/';
fn_GMM = ''; % Change this if you want to save the model.

GMM = gmmTrain(trainDataDir, '', M, max_iter);
trainDD = dir([trainDataDir, filesep, '*']);
testDD = dir([testDataDir, filesep, '*.mfcc']);

% Attempt to classify every training example.
for N=1:length(testDD)
    speakerFn = strcat(testDataDir, '/', testDD(N).name);
    unkn_N = textread(speakerFn);
    unkn_N = unkn_N(:, 1:14);
    b = zeros(size(unkn_N,1), M);
    
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
                      / 2 * sum(sig_m)) - (d / 2) * log(2 * pi) ...
                      - (.5 * log(prod(sig_m)));
            b(:, i) = log_b_m;
        end
        
        % Probabilities and log probabilities.
        P = bsxfun(@times, b, curr_w.');
        log_P = sum(log(P));
        
        [sorted_P, sorted_ix] = sort(log_P, 'descend');
    end
end