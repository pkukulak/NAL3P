function init_res = gmmInit(M, d, spkrDir)
% Initialize the parameters for a Gaussian mixture model.
%
% INPUT:
%   M       - the number of Gaussian models to be mixed.
%   d       - the dimension/feature count of input data.
%   spkrDir - the directory where data for this speaker is stored.
%
% OUTPUT:
%   w       - The mixing coefficients of each model.
%   mu      - The mean vectors of each model.
%   cov     - The variance vectors of each model.
%   X       - the MFCC data matrix for the speaker.

% Construct this speaker's MFCC matrix, X.
% X is of dimension T x d, where T = t_1 + .. + t_9
% That is, we vertically stack all MFCC frames of each
% utterance for this speaker.
X = zeros(0, d);
spkrDD = dir([spkrDir, filesep, '*.mfcc']);

for iFile=1:length(spkrDD)
    
    speakerFn = strcat(spkrDir, '/', spkrDD(iFile).name);
    X = [X; textread(speakerFn)];
end

% Covariance matrices are diagonal, so we initialize
% a d x M matrix, where each column i represents the diagonal
% of a d x d covariance matrix for component i.

% We return a struct with the initialized parameters and data
% as fields.
init_res.w = ones(M, 1) / M;
init_res.mu = X(ceil(rand * size(X, 1)), :);
init_res.sig = ones(d, M);
init_res.X = X;

end
