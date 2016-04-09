function [SE, IE, DE, LEV_DIST] =Levenshtein(hypothesis,annotation_dir)
% Input:
%	hypothesis: The path to file containing the the recognition hypotheses
%	annotation_dir: The path to directory containing the annotations
%			(Ex. the Testing dir containing all the *.txt files)
% Outputs:
%	SE: proportion of substitution errors over all the hypotheses
%	IE: proportion of insertion errors over all the hypotheses
%	DE: proportion of deletion errors over all the hypotheses
%	LEV_DIST: proportion of overall error in all hypotheses

% Count the various edits
sub_count = 0;
ins_count = 0;
del_count = 0;
ref_count = 0;

hyp_file = fopen(hypothesis);
C = textscan(hyp_file, '%s','delimiter', '\n');

topDD_txt = dir([annotation_dir, filesep, '*.txt']);
for i=1: (length(topDD_txt)-2)
    path =  strcat(annotation_dir, 'unkn_', int2str(i), '.txt');
    ref_text = fileread(path);

    hyp_text = C{1}{i};

    % Get the counts for the given phrases
    [cur_sub_count, cur_ins_count, cur_del_count, cur_ref_count ] = WordError(ref_text,hyp_text);
    
    % compute individual error rates
    cur_prop_sub = cur_sub_count / cur_ref_count;
    cur_prop_ins = cur_ins_count / cur_ref_count;
    cur_prop_del = cur_del_count / cur_ref_count;
    cur_prop_all = cur_prop_sub + cur_prop_ins + cur_prop_del;
    disp([i, cur_prop_sub, cur_prop_ins, cur_prop_del, cur_prop_all]);
    
    % Increment the total counts (used for calculation over total set)
    sub_count = sub_count + cur_sub_count;
    ins_count = ins_count + cur_ins_count;
    del_count = del_count + cur_del_count;
    ref_count = ref_count + cur_ref_count;
end

% Compute total error rates
SE = sub_count / ref_count;
IE = ins_count / ref_count;
DE = del_count / ref_count;
LEV_DIST = SE + IE + DE;

% Display totals
disp([31, SE, IE, DE, LEV_DIST]);
return
end


