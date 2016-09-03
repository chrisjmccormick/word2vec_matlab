# word2vec_matlab
Google's *pre-trained* word2vec model in Matlab

This project allows you to play, in Matlab, with the word2vec model that Google trained on a giant Google News dataset. 

IMPORTANT: Note that this project does currently provide any ability to *train* a word2vec model. It simply provides you with the pre-trained Google model, and demonstrates some of the basic tricks you can do with this model, such as identifying similar words, identifying which word doesn't belong in a set of words, or completing an analogy. 

If you are interested in training a word2vec model on your own text corpus, I recommend having a look at the gensim package in Python.

The original model is publicly available here [GoogleNews-vectors-negative300.bin.gz](https://drive.google.com/file/d/0B7XkCwpI5KDYNlNUTTlSS21pQmM/edit?usp=sharing) This model contains a vocabulary of 3 million words; however, most of them are garbage. I've filtered this down to about 200,000 words.

The `word2vec` subdirectory contains some Matlab functions for playing with the model. They are written with the goal of providing clear illustrations of the techniques. 

You can look at and run `runExample.m` to see example uses of these word vectors.

## Vocabulary Filtering
I filtered the original vocabulary by looking up all of the words in WordNet--I kept only the words which existed in WordNet. This reduces the vocabulary size down to about 200,000 words.

Some notes about this:
* This eliminates misspellings of words (the original Google model included misspellings).
* Google used underscores in place of spaces, and WordNet is able to understand underscores as spaces. For example, you can find "New_York" in WordNet.
* They used a technique for identifying common word sequences and learning these as phrases. Many of these phrases are garbage.
* The vocabulary includes multiple cases of the same word (like "crawfish" and "Crawfish"). I have left the casing in the vocabulary as-is (more on this in the next section).
* I've included the Python code I used for filtering the vocabulary and converting the model to .mat format. However, you don't need to run this Python code, since the project includes the resulting .mat files.
  
## Vocabulary Casing
My filtered version of the vocabulary includes multiple entries for the same word with different casing.

For example, the word 'insight' has the most (7) alternate casings:
   INSIGHT
   INsight
   InSight
   Insight
   iNSIGHT
   inSight
   insight

You might think to convert all the words to lower case, except that you would have to decide which version of the word vector to keep! You could average all of them, but this applies equal weighting to all the variants, which may be undesirable. Unfortunately, the Google model does not include any word frequency information that you could otherwise use to weight the average.

To help with this issue, I created a data structure which, for a given input word, provides a list of the indeces of the other casings of the word. This data structure is used in the `most_similar` function, for example, to eliminate results which are just alternate casings of the input word. 






