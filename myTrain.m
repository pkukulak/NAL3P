% Struct to track phoneme data.
phonemes = struct();

% Struct to track HMMs of all phonemes.
HMMs = struct();

max_iter = 20;

% Top-level directory storing all speaker data.
allSpkrDN = '/u/cs401/speechdata/Training/';
allSpkrDD = dir([allSpkrDN, filesep, '*']);

for iSpkr=3:length(allSpkrDD)
   spkr_name = allSpkrDD(iSpkr).name;
   spkrDN = strcat(allSpkrDN, spkr_name, '/');
   mfcc_spkrDD = dir([spkrDN, filesep, '*.mfcc']);
   phn_spkrDD = dir([spkrDN, filesep, '*.phn']);
   
   for iFile=3:length(mfcc_spkrDD)
       mfccFN = mfcc_spkrDD(iFile).name;
       mfcc_contents = textread(strcat(spkrDN, mfccFN));
       mfcc_contents = mfcc_contents(:, 1:14).';
       
       phnFN = phn_spkrDD(iFile).name;
       phnFID = fopen(strcat(spkrDN, phnFN));
       phn_contents = textscan(phnFID, '%d %d %s');
       
       frame_starts = phn_contents{1}/128;
       frame_ends = phn_contents{2}/128;
       frame_phns = phn_contents{3};
      
       for iPhn=1:length(frame_phns)
           frame_start = frame_starts(iPhn) + 1;
           frame_end = frame_ends(iPhn) + 1;
           frame_phn = frame_phns{iPhn};
           
           if (strcmp(frame_phn, 'h#'))
               frame_phn = 'sil';
           end
           
           if (~isfield(phonemes, frame_phn))
               phonemes.(frame_phn) = {};
           end
           frame_inds = logical(frame_start:frame_end);
           phn_data = mfcc_contents(:, frame_inds);
           phonemes.(frame_phn) = ...
               [phonemes.(frame_phn) phn_data];
       end
       
       fclose(phnFID);
   end
end

phns = fieldnames(phonemes);
for iPhn=1:numel(phns)
    fprintf('Training /%s/.\n', (phns{iPhn}));
    data = phonemes.(phns{iPhn});
    init = initHMM(data);
    HMMs.(phns{iPhn}) = trainHMM(init, data, max_iter);
end

save('hmms', 'HMMs', '-mat');