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

% All MFCC vectors have 14 features and then a log summary.
d = 14 + 1;

GMM = struct();

topDD = dir([dataDir, filesep, '*']);
for iDir=3:length(topDD)
    speakerDir = strcat(dataDir, topDD(iDir).name);
    
    % This speaker's GMM.
    GMM.(topDD(iDir).name) = gmmInit(M, d, speakerDir);
    
end

