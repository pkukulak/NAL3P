function GMM = gmmTrain(dataDir, fn_GMM)
% Train a Gaussian mixture model for every speaker in
% the data set and save their model.
%
% INPUT:
%   dataDir - the top-level directory from which to train
%             each model, i.e. '/u/cs401/speechdata/Training/'
%   fn_GMM  - the part of the filename of each saved model
%             that is common to all models. for example, a
%             speaker whose data is stored in the subdirectory
%             'FEDC0' would produce the model saved in
%             [fn_gmm] + '_FEDC0.mat'
%
% OUTPUT:
%   GMM     - a struct containing all GMMs. that is, a GMM for
%             each speaker in the training set.



end

