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
eps = 0.1;

GMM = struct();

topDD = dir([dataDir, filesep, '*']);
for iDir=3:length(topDD)
    spkr_name = topDD(iDir).name;
    speakerDir = strcat(dataDir, topDD(iDir).name);
    
    % This speaker's GMM.
    GMM.(spkr_name) = gmmInit(M, d, speakerDir);
    curr_X = GMM.(spkr_name).X;
    T = size(curr_X, 1);
    
    iter = 0;
    b = zeros(T, M);
    LL = zeros(T, M);
    prev_LL = zeros(T, M);
    diff = Inf;

    disp(spkr_name);
    while ((iter < max_iter) && (diff >= eps))
        curr_mu = GMM.(spkr_name).mu;
        curr_sig = GMM.(spkr_name).sig;
        curr_w = GMM.(spkr_name).w;
       
        % First, calculate all b values.
        for i=1:M
            mu_m = curr_mu(i, :);
            sig_m = curr_sig(i, :);
            
            log_b_m = -(sum(bsxfun(@minus, curr_X, mu_m).^2, 2) ...
                      / (2 * sum(sig_m)) -(d / 2) * log(2 * pi) ...
                       - (.5 * (sum(log(sig_m)))));
            b(:, i) = log_b_m;
            %disp(log_b_m);
            %pause;
            
        end

        %[max_b, max_b_ix] = max(b, [], 2);
        %b = bsxfun(@minus, b, max_b);
        % Then, for every model, calculate likelihood.
        
        %numer = bsxfun(@times, exp(b), curr_w.');
        numer = exp(b) .* repmat(curr_w.', T, 1);
        %disp(exp(b));

        denom = sum(numer, 2);
        %LL = bsxfun(@rdivide, numer, denom);
        LL = numer ./ repmat(denom, 1, M);
        
        % Finally, update parameters.
        GMM.(spkr_name).w =  (sum(LL, 1) / T).';
        GMM.(spkr_name).mu = bsxfun(@rdivide, LL.' * curr_X, ...
                                    sum(LL, 1).');
        GMM.(spkr_name).sig = bsxfun(@rdivide, LL.' * (curr_X.^2), ...
                             sum(LL, 1).') - (GMM.(spkr_name).mu).^2; 
                         
        % Update convergence criterion.
        diff = norm(abs(LL - prev_LL));
        prev_LL = LL;
        iter = iter + 1;
        
    end
end

% SAVE THE FILE. SAVE THE FILE. SAVE IT LAWRENCE!!!
if (~strcmp('', fn_GMM))
    save( fn_GMM, 'GMM', '-mat');
end
