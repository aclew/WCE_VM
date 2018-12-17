
import scipy,scipy.io

import keras
from keras.models import Sequential
from keras.layers import Dense, Dropout, Activation
from keras.optimizers import SGD
from keras.layers import Dense, merge
from keras.layers.merge import concatenate
from keras.layers import LSTM

import numpy

from keras.layers import Dense, Dropout, Embedding, LSTM, Input, merge, TimeDistributed
from keras.models import Model
from keras.layers.core import Masking
from keras.models import load_model

import sys

print('Keras/Python environment initialized succesfully')
print('Loading data...')

datadir = ('%s' % sys.argv[1])

loaddata = scipy.io.loadmat(('%s/data_in_1.mat' % datadir))
X_in_tmp = loaddata['X_in']
X_in = X_in_tmp

# If the data tensor has a special marking for splitting (too large tensor to fit into one .mat file, load the remaining chunks)
x = 2;
while X_in_tmp[-1,-1,-1] == 1.0:
   loaddata = scipy.io.loadmat('%s/data_in_%d.mat' % (datadir, x))
   X_in_tmp = loaddata['X_in']
   X_in = numpy.concatenate((X_in,X_in_tmp),axis=0)
   X_in[-1,-1,-1] = -1.0    # fix last value
   x = x+1;

print('Loading model...')
if(len(sys.argv) == 2):
    model = load_model('%s/trained_models/BLSTM_60_60_Estonian_Korean_Augmented.h5' % datadir)
else:
    if(isinstance(sys.argv[2], str)):
        print('Attempting to load %s' % sys.argv[2])
        model = load_model('%s/trained_models/%s' % (datadir, sys.argv[2]))
    else:
        raise Exception('Argument must be a string (name of the Keras model)')

if(len(model.layers[0].output_shape) > 3):
    X_in = numpy.reshape(X_in,[X_in.shape[0], X_in.shape[1], X_in.shape[2], 1])

# print('Generating syllable outputs..')
envelopes = model.predict_on_batch(X_in)

if(envelopes.ndim > 2):
    envelopes = envelopes[:,:,0]

# print('Saving outputs...')
numpy.savetxt(('%s/data_out.csv' % datadir) ,envelopes)
# print('Syllabification complete.')
