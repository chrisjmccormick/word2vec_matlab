function [ results ] = measure_accuracy(wordvecs_norm, word2Index, alt_cases  )
%MEASURE_ACCURACY Measures model accuracy against test analogies.
%   The Google team created a long list of analogies to use for testing
%   the quality of the learned word2vec model. This function runs 
%   that test.
%   To speed up the test process, we process the analogies in batches.
%   The cosine similarity calculation (dot product) is much more efficient
%   when performed between two matrices rather than a single vector at 
%   a time.

fprintf('Measuring model accuracy on completing analogies...\n');

% Open the analogies file.
fid = fopen('./model/test_analogies.txt');

% Create a matrix to hold the results.
% Each row stores the results for one category of analogy.
% The columns store:
%   Column 1: The number of correct answers.
%   Column 2: The total number of tests in this category.
results = [];

% Index of the current analogy category.
catIndex = 0;

numRight = 0;
totalRight = 0;
totalTests = 0;

queryM = [];
y = [];
exclude = {};

% Loop until the end of the file.
while true

    % Get the next line (without newline character).
    tline = fgetl(fid);
    
    % Split the line by spaces.
    if ischar(tline)
        words = strsplit(tline, ' ');
    end
     
    % If the first token is a colon, this indicates the start of a new
    % category of analogies.
    % This also handles the end of the file.
    if (~ischar(tline)) | (words{1} == ':')
        % Evaluate all the analogies from the last category.
        if catIndex ~= 0
            
            % wordvecs  [200k  x  300]
            % queryM'   [300   x    m]
            % cossims   [200k  x    m]
            cossims = wordvecs_norm * queryM';
            
            % Remove the input words from the results by overriding their
            % similarities with 0.
            for analogy = 1 : length(exclude)
                % Get the list of word indeces to exclude for this analogy.
                indeces = cell2mat(exclude(analogy));
                
                % Explicitly set the similarities for these words to 0.
                cossims(indeces, analogy) = 0;
            end
            
            % Find the entries (for each test case) with the highest similarity.
            [~, p] = max(cossims);
            
            % Compare against the expected answers in 'y'.
            numRight = sum(p' == y);
            
            % Print the accuracy.
            cat_accuracy = numRight / length(y) * 100.0;
            fprintf('(%d / %d) %.2f%%\n', numRight, length(y), cat_accuracy);            
        end
        
        % Break the loop when we reach the end of the file.
        if ~ischar(tline)
            break
        end
        
        % Display the name of this new category.
        fprintf('  %s    ', char(words{2}))
        catIndex = catIndex + 1;      
        
        % Update the result totalts.
        totalRight = totalRight + numRight;
        totalTests = totalTests + length(y);
        
        results = [results; numRight, length(y)];
        
        % Reset the results counters for the next category.
        numRight = 0;
        
        queryM = [];
        y = [];
        exclude = {};
    else
        % Lookup the word indeces for each of the query words.
        a_i = getWordIndex(word2Index, char(words{1}), true);
        b_i = getWordIndex(word2Index, char(words{2}), true);
        c_i = getWordIndex(word2Index, char(words{3}), true);

        % Note the indeces of the input words, which must be eliminated 
        % from the results for this analogy.
        % Also exclude any alternate casings of the input word. This
        % only helped a little--bringing the accuracy from 14,210 correct
        % to 14,258.
        %exclude = [exclude; a_i, b_i, c_i];
        testNum = length(y) + 1;
        exclude{testNum} = [a_i, cell2mat(alt_cases(a_i)), ...
                            b_i, cell2mat(alt_cases(b_i)), ...
                            c_i, cell2mat(alt_cases(c_i))];
        
        % Check if any of the words were not in the index.
        if (a_i == -1) || (b_i == -1) || (c_i == -1)
            query = zeros(1, size(wordvecs_norm, 2));
        else
            % Select the actual word vectors.
            a = wordvecs_norm(a_i, :);
            b = wordvecs_norm(b_i, :);
            c = wordvecs_norm(c_i, :);
            
            % The query vector is just the average of the three input vectors,
            % but a is given a negative weight.
            query = (b + c - a) / single(3);
            
            % Normalize the query vector and add it to the matrix.
            queryM = [queryM; query ./ norm(query)];
        end

        % Look up the index of the correct answer, append it to 'y'.
        y = [y; word2Index(char(words{4}))];
    end
end

fclose(fid);

fprintf('Overall accuracy: (%d / %d) %.2f%%\n', totalRight, totalTests, totalRight / totalTests * 100.0);

end

