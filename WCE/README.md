This is a readme.

Use WCEtrain() to train the WCE for a new language using utterances for which
word or syllable counts are known.

Use WCEestimate() to get word/syllable counts on new utterances.

Dependencies & Installation issues

In order to use DNN-based syllabification (conf.syl_method = LSTMSeg in your
config file), you need to have Python (tested on 2.7) and Keras with TensorFlow
or Theano backend installed. In addition, if you have multiple Python versions
installed and/or the correct Python is not in your system environment paths, you
need to modify LSTMseg/LSTMseg.m and change "python_path" variable to point to
the Python binary in your environment.

Includes a copy of Voicebox-toolbox by Mike Brooks, available at
http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html under GNU Public License.

Need to include GNU GPL license text here.
