function [SE, IE, DE, RC] = WordError(ref,hyp)

% Strip punctuation. Comment this out if this is unneeded.
ref = regexprep(ref, '[.,!''";:!]', '');
hyp = regexprep(hyp, '[.,!''";:!]', '');

% Split the strings into words.
ref = strsplit(ref);
hyp = strsplit(hyp);

% Remove unecessary parts
ref = ref(3:end-1);
hyp = hyp(3:end);

disp(ref);
disp(hyp);

% Setup the Levenshtein algorithm
n = length(ref);
m = length(hyp);
R = zeros((n+1), (m+1));
B = zeros((n+1), (m+1));

for i=1:n+1
    R(i,1) = Inf;
end
for j=1:m+1
    R(1, j) = Inf;
end
R(1,1) = 0;

% Compute the matrices
for i=1:n
   for j=1:m
       eq = 0;
       cur_r = ref(i);
       cur_h = hyp(j);
       if not (strcmp(cur_r, cur_h))
          eq = 1; 
       end
       del = R(i, j+1) + 1;
       sub = R(i, j) + eq;
       ins = R(i+1, j) + 1;
       smallest = min([del, sub, ins]);
       R(i+1, j+1) = smallest;
       if(R(i+1, j+1) == del)  
           B(i+1, j+1) = 1;     % 1 represents 'up'
       elseif (R(i+1, j+1) == ins)
           B(i+1, j+1) = 2;     % 2 represents 'left'
       else
           B(i+1, j+1) = 12;    % 12 represents 'up-left'
       end
           
   end
    
end

SE = 0;
IE = 0;
DE = 0;
RC = length(ref);

i = n;
j = m;
% Count the errors
while ((i > 1) && (j > 1))
    cur_r = ref(i);
    cur_h = hyp(j);
    
    if (B(i, j) == 1) % move up.
        i = i - 1;
        DE = DE +1;
    elseif (B(i, j) == 2)
        j = j - 1;
        IE = IE +1;

    elseif strcmp(cur_r, cur_h)
        i = i - 1;
        j = j - 1;
    else
        SE = SE + 1;
        i = i - 1;
        j = j - 1;
    end
end
end