testSpkrDN = '/u/cs401/speechdata/Testing/';
testSpkrDD_mfcc = dir([testSpkrDN, filesep, '*.mfcc']);
testSpkrDD_phn = dir([testSpkrDN, filesep, '*.phn']);


% Trained models.
HMMs = load('hmms', '-mat');
HMMs = HMMs.HMMs;
HMM_fields = fieldnames(HMMs);

correct = 0;
incorrect = 0;
total = 0;

for iFile=1:length(testSpkrDD_mfcc)
    mfccFN = testSpkrDD_mfcc(iFile).name;
    mfcc_contents = textread(strcat(testSpkrDN, mfccFN));
    mfcc_contents = mfcc_contents(:, 1:14).';
    
    phnFN = testSpkrDD_phn(iFile).name;
    phnFID = fopen(strcat(testSpkrDN, phnFN));
    phn_contents = textscan(phnFID, '%d %d %s');
    
    frame_starts = phn_contents{1}/128;
    frame_ends = phn_contents{2}/128;
    frame_phns = phn_contents{3};
    
    for iPhn=1:length(frame_phns)
        total = total + 1;
        
        frame_start = frame_starts(iPhn) + 1;
        frame_end = frame_ends(iPhn) + 1;
        frame_phn = frame_phns{iPhn};
        
        if (strcmp(frame_phn, 'h#'))
            frame_phn = 'sil';
        end
        
        frame_inds = logical(frame_start:frame_end);
        phn_data = mfcc_contents(:, frame_inds);
        
        curr_max_LL = -Inf;
        
        for iTrn=1:numel(HMM_fields)
            trained_phn = HMMs.(HMM_fields{iTrn});
            curr_LL = loglikHMM(trained_phn, phn_data);
            if (curr_LL > curr_max_LL)
                curr_max_LL = curr_LL;
                prediction = (HMM_fields{iTrn});
            end
        end
        
        disp(['Final prediction: ', prediction]);
        disp(['True phoneme    : ', frame_phn]);
        if (strcmp(prediction, frame_phn))
            correct = correct + 1;
        else
            incorrect = incorrect + 1;
        end
        total = total + 1;
        disp(['Correct = ', num2str(correct), ...
            ' | Incorrect = ', num2str(incorrect), char(10)]);
        
    end
    fclose(phnFID);
end

