function [  ] = measure_accuracy(wordvecs_norm, word2Index  )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% Open the analogies file.
fid = fopen('./model/test_analogies.txt');

% Get the first line (without newline character).
tline = fgetl(fid);

% Create a matrix to hold the results.
% Each row stores the results for one category of analogy.
% The columns store:
%   Column 1: The number of correct answers.
%   Column 2: The total number of tests in this category.
results = zeros(10, 2);

% Index of the current analogy category.
catIndex = 0;

totalRight = 0;
totalTests = 0;

numRight = 0;
numTests = 0;

% Loop until the end of the file.
while ischar(tline)

    % Split the line by spaces.
    words = strsplit(tline, ' ');
    
    % If the first token is a colon, this indicates the start of a new
    % category of analogies.
    if words{1} == ':'
        % Display the accuracy from the last category.
        if catIndex ~= 0
            cat_accuracy = numRight / numTests * 100.0;
            fprintf('\n  (%d / %d) %.2f%%\n', numRight, numTests, cat_accuracy);
        end
        
        % Display the name of this new category.
        fprintf('%s\n', char(words{2}))
        catIndex = catIndex + 1;
        
        % Update the result totalts.
        totalRight = totalRight + numRight;
        totalTests = totalTests + numTests;
        
        % Reset the results counters for the next category.
        numRight = 0;
        numTests = 0;
    else
        % Complete the analogy using the word vectors.
        result = complete_analogy(wordvecs_norm, word2Index, words{1}, words{2}, words{3});
        
        % Look up the index of the correct answer.
        expected = word2Index(char(words{4}));
        
        % If it's correct, update the count.
        if (result == expected)
            numRight = numRight + 1;
        end
        
        numTests = numTests + 1;
        
        printIteration(numTests);        
    end

    % Get the next line.
    tline = fgetl(fid);
end

fclose(fid);

end

