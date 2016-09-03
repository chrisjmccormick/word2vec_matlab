function [ words_i, sims ] = most_similar( wordvecs_norm, word2Index, alt_cases, input, k)
%MOST_SIMILAR Returns the top 'k' most similar words to the 'input' word
%    This function simply performs a k-Nearest Neighbor search against all
%    of the word vectors and returns the top 'k' results.
%
%    Word vectors are compared using the Cosine similarity: all the vectors
%    are normalized 
%
%    The word2Index is necessary both to map the input word string to its
%    vector but also to make sure that we don't return the input word as
%    a result!
%
%  Parameters:
%   wordvecs_norm - Normalized word vectors
%   word2Index    - Map of words to indeces
%   input         - Input word (string)
%   k             - Number of words to return 

    % Verify the input wordvectors are normalized. (Just checking the first
    % one).
    assert((norm(wordvecs_norm(1, :)) - 1.0) < 0.0001)
        
    % Get the index for the input word.
    input_i = word2Index(char(input));

    % Get the word vector for the input word.
    query = wordvecs_norm(input_i, :);
    
    % wordvecs [200k x 300]
    % query'   [300  x   1]
    % cossims  [200k x   1]
    cossims = wordvecs_norm * query';
      
    % We don't want to return any of the input words as the result, so
    % manually overwrite the similarities for those vectors to 0.
    cossims(input_i) = 0;
    
    % Get the list of indeces of alternate casings for this word.
    alt_i = alt_cases(input_i);
    for i = 1:length(alt_i{1})
        cossims(alt_i{1}(i)) = 0;
    end
    
    % Sort the similarites, with highest similarity first.
    % results_i becomes the indeces of the words.
    [cossims, results_i] = sort(cossims, 'descend');

    % Select just the top 'k' results.
    words_i = results_i(1:k);
    sims = cossims(1:k);
end

