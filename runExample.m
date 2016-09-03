% Load all the word vectors (stored in 10 separate .mat files)
words = [];
wordvecs = [];

% For each of the .mat files...
for i = 1:10
    load(sprintf('./model/model_part_%02d.mat', i));
    words = [words, words_part];
    wordvecs = [wordvecs; wordvecs_part];
end

% Create a Map so we can easily lookup the word vector for a given word.
word2Index = containers.Map(words, (1:length(words)));

% Load the list of indeces of alternate cases for each word.
load('./model/alt_cases.mat');

% Create a copy of the word vectors that are all normalized (for Cosine
% similarity).
fprintf('Creating normalized copy of word vectors...\n');
wordvecs_norm = zeros(size(wordvecs));
for i = 1 : size(wordvecs, 1)
    % Get the next vector.
    v = wordvecs(i, :);
    
    % Normalize the vector.
    wordvecs_norm(i, :) = v ./ norm(v);
end

% Complete an analogy.
fprintf('\nBoy is to girl as brother is to...\n');
d = complete_analogy(wordvecs_norm, word2Index, 'boy', 'girl', 'brother');
fprintf('  %s\n', char(words(d)));

% Find most similar words.
fprintf('\nMost similar words to crawfish:\n');
[indeces, sims] = most_similar(wordvecs_norm, word2Index, alt_cases, 'crawfish', 5);
for i = 1:5
    fprintf('  %0.2f %s\n', sims(i), char(words(indeces(i))));
end
fprintf('\n');

% Measure the model's accuracy on the test analogies.
measure_accuracy(wordvecs_norm, word2Index, alt_cases);