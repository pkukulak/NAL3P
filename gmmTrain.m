function GMM = gmmTrain(dataDir, fn_GMM, M, max_iter)
% Train a Gaussian mixture model for every speaker in
% the data set and save their model.
%
% INPUT:
%   dataDir  - the top-level directory from which to train
%              each model, i.e. '/u/cs401/speechdata/Training/'
%   fn_GMM   - the part of the filename of each saved model
%              that is common to all models. for example, a
%              speaker whose data is stored in the subdirectory
%              'FECD0' would produce the model saved in
%              [fn_gmm] + '_FECD0.mat'
%   M        - the number of gaussians mixed into each mixture.
%   max_iter - the maximum iterations to train each mixture.
%
% OUTPUT:
%   GMM      - a struct containing all GMMs. that is, a GMM for
%              each speaker in the training set.

% All MFCC vectors have 13 features followed by log energy.
d = 13 + 1;

% Convergence criteria hyperparameter.
eps = 0.005;

GMM = struct();

topDD = dir([dataDir, filesep, '*']);
for iDir=3:length(topDD)
    spkr_name = topDD(iDir).name;
    speakerDir = strcat(dataDir, topDD(iDir).name);
    
    % This speaker's GMM.
    GMM.(spkr_name) = gmmInit(M, d, speakerDir);
    curr_X = GMM.(spkr_name).X;
    T = size(curr_X, 1);
    
    i = 0;
    b = zeros(T, M);
    LL = zeros(T, M);
    prev_LL = zeros(T, M) * -Inf;
    diff = Inf;

    disp(spkr_name);
    while (i < max_iter && diff >= eps)
        curr_mu = GMM.(spkr_name).mu;
        curr_sig = GMM.(spkr_name).sig;
        curr_w = GMM.(spkr_name).w;
       
        % First, calculate all b values.
        for i=1:M
            mu_m = curr_mu(i, :);
            sig_m = curr_sig(i, :);
            log_b_m = -(sum(bsxfun(@minus, curr_X, mu_m).^2, 2) ...
                      / 2 * sum(sig_m)) - (d / 2) * log(2 * pi) ...
                      - (.5 * log(prod(sig_m)));
            b(:, i) = log_b_m;
        end
        
        % Then, for every model, calculate likelihood.
        denom = bsxfun(@times, b, curr_w.');
        numer = sum(denom, 2);
        LL = bsxfun(@rdivide, denom, numer);
        
        % Finally, update parameters.
        GMM.(spkr_name).w =  (sum(LL, 1) / T).';
        GMM.(spkr_name).mu = bsxfun(@rdivide, LL.' * curr_X, ...
                                    sum(LL, 1).');
        GMM.(spkr_name).sig = bsxfun(@rdivide, LL.' * (curr_X.^2), ...
                             sum(LL, 1).') - (GMM.(spkr_name).mu).^2; 
                         
        % Update convergence criterion.
        diff = norm(LL - prev_LL);
        prev_LL = LL;
        i = i + 1;
    end
end

