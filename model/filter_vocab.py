# -*- coding: utf-8 -*-
"""
Created on Sun Aug 28 09:19:53 2016

@author: Chris
"""

from nltk.corpus import wordnet
import gensim
import logging
import pickle

# Logging code taken from http://rare-technologies.com/word2vec-tutorial/
logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)

# Update this path to point to the original Google model.
modelFile = '../../../inspect_word2vec/model/GoogleNews-vectors-negative300.bin'

# Load Google's pre-trained Word2Vec model.
#model = gensim.models.Word2Vec.load_word2vec_format(modelFile, binary=True)  

###############################################################################
# Read in the list of analogy words.
#
# There are some capital cities which appear in the test analogies but do not
# have an entry in WordNet. For example, the analogies include "Ashgabat" as 
# the capital of Turkmenistan, but WordNet only contains the spelling 
# "Ashkhabad". (Wikipedia uses "Ashgabat" and has a redirect for "Askhabad")
###############################################################################

# Open the analogy test file
with open('test_analogies.txt', 'r') as f:
    # Read in all of the lines as separate strings.    
    lines = f.readlines()
    
# Find all of the unique words by adding them to a set.
test_words = set() 
for line in lines:
    for word in line.split():
        test_words.add(word)

###############################################################################
#  Filter the vocabulary using WordNet
###############################################################################

# Retrieve the entire list of "words" from the Google Word2Vec model
vocab = model.vocab.keys()

good_count = 0
good_vocab = []

# For each word in the Google model...
for word in vocab:

    # Check if it's in WordNet or the test words. If not, skip it.
    if not wordnet.synsets(word) and not (word in test_words):
        continue
    
    # If it is in WordNet, add it to the list. Escape any unicode characters.
    else:
        good_vocab.append(word.encode('UTF-8'))
        good_count = good_count + 1


print "Vocabulary size:", good_count    

# Sort the vocabulary alphabetically.
good_vocab.sort()

# Write out the good words to vocabulary.txt
with open("vocabulary.txt", 'w') as f:
    for word in good_vocab:
        f.write(word + '\n')

###############################################################################
# Identify multiple casings of the same word.
###############################################################################

# Create a copy of the vocabulary with all of the words turned to lower case.
vocab_lower = []
for word in good_vocab:
    vocab_lower.append(word.lower())

# Build a dictionary which maps each unique word to a list of indeces of the
# different casings of that word.     
alt_cases_d = dict()
i = 0
for word in vocab_lower:
    if word in alt_cases_d:
        alt_cases_d[word].append(i)
    else:
        alt_cases_d[word] = [i];
        
    i = i + 1

print 'There are', len(alt_cases_d), 'unique words after converting to lower case.'

# Just for fun, find the word with the most alternate casings.
most_alts = -1
most_alts_word = ''
for word, indeces in alt_cases_d.items():
    if (len(indeces) > most_alts):
        most_alts = len(indeces)
        most_alts_word = word
        
print 'The word \'%s\' has the most (%d) alternate casings:' % (most_alts_word, most_alts)
for i in alt_cases_d[most_alts_word]:
    print '  ', good_vocab[i]

# Create a list of lists which maps each word in the original vocabulary to a
# list of its alternate casings.
alt_cases = []
i = 0
for word in good_vocab:
    # Get the list of indeces of all casings of this word.    
    all_indeces = alt_cases_d[word.lower()]

    # Create a copy of the list.
    indeces = list(all_indeces)
    
    # Remove *this* instance of the word from the list.
    indeces.remove(i)
    
    alt_cases.append(indeces)
    
    i = i + 1

pickle.dump((alt_cases), open("alt_cases.pickle", "wb"))