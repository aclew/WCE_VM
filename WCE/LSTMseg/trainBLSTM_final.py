import scipy,scipy.io


from keras.models import Sequential
from keras.layers import Dense, Dropout, Activation
from keras.optimizers import SGD
from keras.layers import Dense, merge
from keras.layers.merge import concatenate
from keras.layers import LSTM
import keras
import numpy

from keras.layers import Dense, Dropout, Embedding, LSTM, Input, merge, TimeDistributed, add
from keras.models import Model
from keras.layers.core import Masking

from keras.layers import Flatten
from keras.layers import Reshape
from keras.layers import Dropout
from keras import optimizers
from keras.callbacks import Callback
from keras.models import load_model

import os,sys

# LSTM version

# create the model
if(os.path.isdir('/Users/orasanen/Documents/koodit/dev/syllabification_platform/main/LSTMseg/')):
    datadir = '/Users/orasanen/Documents/koodit/dev/syllabification_platform/main/LSTMseg/'
elif(os.path.isdir('/work/t405/T40523/work/orasanen/LSTM/')):
    datadir = '/work/t405/T40523/work/orasanen/LSTM/'


if(len(sys.argv) == 1):
    savefile = ('%sBLSTM_2_layer_30_dropout05.h5' % datadir)
else:
    if(isinstance(sys.argv[1], basestring)):
        savefile = ('%s%s.h5' % (datadir,sys.argv[1]))
    else:
        raise Exception('Save file must be a string!')

loaddata = scipy.io.loadmat('%sLSTM_traindata_1.mat' % datadir,variable_names=["X_in", "X_out"])
X_in_tmp = loaddata['X_in']
X_out_tmp = loaddata['X_out']

X_in = X_in_tmp
X_out = X_out_tmp

# If the data tensor has a special marking for splitting (too large tensor to fit into one .mat file, load the remaining chunks)
x = 2;
while X_in_tmp[-1,-1,-1] == 1.0:
   loaddata = scipy.io.loadmat('%sLSTM_traindata_%d.mat' % (datadir, x),variable_names=["X_in", "X_out"])
   X_in_tmp = loaddata['X_in']
   X_out_tmp = loaddata['X_out']
   X_in = numpy.concatenate((X_in,X_in_tmp),axis=0)
   X_out = numpy.concatenate((X_out,X_out_tmp),axis=0)
   X_in[-1,-1,-1] = -1.0    # fix last value
   x = x+1;

X_out = numpy.reshape(X_out,[X_out.shape[0], X_out.shape[1],1])

earlyStopping=keras.callbacks.EarlyStopping(monitor='val_loss', min_delta=0.0001, patience=15, verbose=0, mode='auto')
checkPoint=keras.callbacks.ModelCheckpoint(('%s/BLSTM_intermed.h5' % datadir), monitor='val_loss')

# savefile = ('%sBLSTM_2_layer_60_dropout00_channel_2.h5' % (datadir))
##### tata lasketaan GPU koneella
sequence = Input(shape=(X_in.shape[1:]))
# apply forwards LSTM
#mask = Masking(mask_value=-1, input_shape=(X_in.shape[1:]))(sequence)
forwards1 = LSTM(units=60, return_sequences=True)(sequence)
# apply backwards LSTM
backwards1 = LSTM(units=60, return_sequences=True,
                 go_backwards=True)(sequence)
                 # concatenate the outputs of the 2 LSTMs

#merged = merge([forwards, backwards], mode='concat', concat_axis=-1)
merged1 = add([forwards1, backwards1])
#after_dp = Dropout(0)(merged1)

forwards2 = LSTM(units=60, return_sequences=True)(merged1)
# apply backwards LSTM
backwards2 = LSTM(units=60, return_sequences=True,
                 go_backwards=True)(merged1)

merged2 = add([forwards2, backwards2])
#after_dp2 = Dropout(0)(merged2)

# TimeDistributed for sequence
#outputvar = Dense(output_dim=X_out.shape[2], activation='sigmoid')(after_dp)
outputvar = Dense(units=1, activation='sigmoid')(merged2)

#model = Model(input=sequence, output=outputvar)
model = Model(outputs=outputvar, inputs=sequence)
model.compile(loss='binary_crossentropy', optimizer='rmsprop', metrics=['mean_squared_error'])
print(model.summary())
model.fit(X_in, X_out, validation_data=(X_in, X_out), shuffle=True, epochs=15000,batch_size=250,callbacks=[earlyStopping, checkPoint], validation_split=0.1)

#model.save('%s/BLSTM_2_layer_60_dropout05_sharp_output_v3_noised.h5' % datadir)
model.save('%s' % savefile)

#x =  model.layers[10].output
#y = LSTM(30)(x)
#y2 = Dense(88,activation='softmax')(y)

#model2 = Model(input=model.input,output=y2)

#model2.compile(loss='categorical_crossentropy', optimizer='rmsprop', metrics=['mean_squared_error'])

#model2.fit(X_in, X_counts, validation_data=(X_in, X_counts), shuffle=True, epochs=150,batch_size=100,callbacks=[earlyStopping, checkPoint], validation_split=0.1)
#model2.save('%s/BLSTM_2_layer_60_dropout05_sharp_output_v3_E2E.h5' % datadir)
