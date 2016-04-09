% main script
function main
trainDataDir = '/u/cs401/speechdata/Training/';
testDataDir = '/u/cs401/speechdata/Testing/';

% Pseudo code
% for .flac file in testDataDir: (there are 30)
%     ibmText = ibm(flac)
%     l = leven(associated .txt, ibmText) 
% 
%     % report the recognized transcript and word error rate 
%     echo discussion.txt l ,ibmText
topDD_flac = dir([testDataDir, filesep, '*.flac']);
topDD_txt = dir([testDataDir, filesep, '*.txt']);

% Part 4.1

% for i=1: 1 %length(topDD_flac)
%     command = strcat('env LD_LIBRARY_PATH='''' curl -u "282ef0a4-3a18-46aa-8cc7-dcad2c6ae893":"FwB8484gv6XO" -X POST --header "Content-Type: audio/flac" --header "Transfer-Encoding: chunked" --data-binary "@', ...
%         testDataDir, topDD_flac(i).name, '" "https://stream.watsonplatform.net/speech-to-text/api/v1/recognize?continuous=true"');
%     [~, text] = unix(command);
%     ibm_words = get_words(text); % get the actual words from the json string.
%     
%     % Get words from true file.
%     path =  strcat(testDataDir, topDD_txt(i+2).name); % offset by 2 due to the two extra text files.
%     file_text = fileread(path);
%     expr = '[^\s][\s][^\s]+[\s]';
%     [~, words_end] = regexp(file_text, expr);
%     true_words = file_text(words_end+1:end);
%     
%     % TODO: implement
%     %lev_value = levenstein(true_words, ibm_words);
%     [SE, IE, DE, RC] = WordError(ibm_words, true_words);
%     disp(true_words);
%     disp(ibm_words);
%     disp(SE/RC);
%     disp(IE/RC);
%     disp(DE/RC);
%     disp((DE + SE + IE)/RC);
%     
% end
% 
% Part 4.2.
for i=1: 1 %length(topDD_flac)
    disp(i);
    disp(topDD_flac(i).name);
    disp(topDD_txt(i+2).name); % offset by 2 due to the two extra text files.
    % Get words from true file.
    path =  strcat(testDataDir, topDD_txt(i+2).name); % offset by 2 due to the two extra text files.
    file_text = fileread(path);
    disp(file_text);
    
%     command = strcat('env LD_LIBRARY_PATH='''' curl -u "282ef0a4-3a18-46aa-8cc7-dcad2c6ae893":"FwB8484gv6XO" -X POST --header "Content-Type: audio/flac" --header "Transfer-Encoding: chunked" --data-binary "@', ...
%         testDataDir, topDD_flac(i).name, '" "https://stream.watsonplatform.net/speech-to-text/api/v1/recognize?continuous=true"');
%     disp(command);
%    [resp, text] = unix(command);
%    ibm_words = get_words(text); % get the actual words from the json string.
%    disp(ibm_words);
end

end

%function t = ibmSpeechToText(flac_file_path)
% Given an utterance (flacfile), run 
% it through ibm, and return the recognized 
% transcript and word error rate.
%
% Compute the Lev using algorithm from part 3.3.
%
%
%
%  
%command = strcat('env LD_LIBRARY_PATH='''' curl -u "7bc64b77-c00e-4b67-a916-de85af3d552b":"GmiB37fBLiSe" -X POST -F "text=', ...
%        fre, '" -F "source=fr" -F "target=en" "https://gateway.watsonplatform.net/language-translation/api/v2/translate"');
%    [resp, text] = unix(command);

function w = get_words(t)
% This is a pretty dumb regex match, but it works for our singlular purpose.
expr = '[c][r][i][p][t]["][:][\s]["][^"]*["]';
subchunk = regexp(t, expr,'match' );
sub = subchunk{1};
w = sub(10:end-1);
return
end

%function t = ibmTextToSpeech()
% Given an utterance (flacfile), run 
% it through ibm, and return the recognized 
% transcript and word error rate.
%
% Compute the Lev using algorithm from part 3.3.
%
%
%
%  