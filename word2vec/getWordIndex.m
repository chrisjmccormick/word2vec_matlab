function [ index ] = getWordIndex( word2Index, word, verbose )
%GETWORDINDEX Gets the index of the specified word.
%   This function looks up the index for the given word, checking first
%   to confirm that the word is in the vocabulary.

% If the word is not in the vocabulary, return -1, and optionally print
% an error.
if ~isKey(word2Index, word)
    if verbose
        fprintf('  %s is not in the vocabulary!\n', word);
    end
    index = -1;
% Otherwise, just look it up.
else
    index = word2Index(word);
end


end

