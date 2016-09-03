# -*- coding: utf-8 -*-
"""
Created on Thu Sep 01 17:06:47 2016

@author: Chris
"""

import scipy.io as sio
import numpy as np
import gensim
import pickle

# Read in the filtered vocabulary.
with open("vocabulary.txt", 'r') as f:
    vocab = f.read().splitlines()

# Update this path to point to the original Google model.
modelFile = '../../../inspect_word2vec/model/GoogleNews-vectors-negative300.bin'

# Load Google's pre-trained Word2Vec model.
#model = gensim.models.Word2Vec.load_word2vec_format(modelFile, binary=True)  


# This function will split our vocabulary into 'num' chunks of roughly equal 
# size. 
def chunkIt(seq, num):
  
  avg = int(np.ceil(len(seq) / float(num)))
  out = []
  last = 0.0

  while last < len(seq):
    out.append(seq[int(last):int(last + avg)])
    last += avg

  return out

# Divide the vocabulary into 10 roughly equal chunks.
vocab_chunked = chunkIt(vocab, 10)

# Write out each of the chunks to a separate .mat file.
chunkNum = 1
words = []
for chunk in vocab_chunked:
    # Select all of the word vectors for this chunk.
    wordvecs = []
    for word in chunk:
        wordvecs.append(model[word.decode('UTF-8')])

    # Make 'words' a list of numpy objects, this will allow the strings to be
    # imported into Matlab in cell format.
    words = np.zeros(len(chunk), dtype=np.object)
    words[:] = chunk

    # Save the word vectors and corresponding words to a .mat file
    sio.savemat('model_part_%02d.mat' % chunkNum, {'wordvecs_part': wordvecs, 'words_part': words})        
    chunkNum = chunkNum + 1
        

# Write out the mappings of each word to its alternate casings.
alt_cases_py = pickle.load( open( "alt_cases.pickle", "rb" ) )

# To save this for Matlab we need to do two things.
# 1. This a list of lists. The first list needs to be turned into a cell array,
#    and we do this using the dytpe parameter in numpy. 
# 2. Matlab indexing starts from 1! So we need to increment all of these  index
#    values by 1.
alt_cases_mat = np.empty((len(alt_cases_py),), dtype=np.object)
for i in range(len(alt_cases_py)):
    # Copy over the list to the new data structure.
    # Also, increment the each of the values by 1, since Matlab indexing 
    # starts at 1.
    alt_cases_mat[i] = [x + 1 for x in alt_cases_py[i]]
    
sio.savemat('alt_cases.mat', {'alt_cases': alt_cases_mat})