function [ d ] = complete_analogy( wordvecs_norm, word2Index, a, b, c)
%COMPLETE_ANALOGY Complete the analogy a is to b as c is to ___.
%   Completes the analogy by taking the average of -a, b, and c,  
%   then finding the word that is most similar to this query vector.
%   The input words are excluded from the results.
%   Returns the index of the most similar word.

    % Lookup the word indeces for each of the query words.
    a_i = getWordIndex(word2Index, char(a), false);
    b_i = getWordIndex(word2Index, char(b), false);
    c_i = getWordIndex(word2Index, char(c), false);
       
    % Check if any of the words were not in the index.
    if (a_i == -1) || (b_i == -1) || (c_i == -1)
        d = -1;
        return;
    end
    
    % Select the actual word vectors.
    a = wordvecs_norm(a_i, :);
    b = wordvecs_norm(b_i, :);
    c = wordvecs_norm(c_i, :);

    % The query vector is just the average of the three input vectors,
    % but a is given a negative weight.
    query = (b + c - a) / single(3);
    
    % Normalize the query vector.
    query = query ./ norm(query);
    
    % wordvecs [200k x 300]
    % query'   [300  x   1]
    % cossims  [200k x   1]
    cossims = wordvecs_norm * query';
      
    % We don't want to return any of the input words as the result, so
    % manually overwrite the similarities for those vectors to 0.
    cossims(a_i) = 0;
    cossims(b_i) = 0;
    cossims(c_i) = 0;
    
    % Get the index of the most similar word.
    [~, d] = max(cossims);
 
end

