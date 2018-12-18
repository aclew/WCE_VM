
# This function takes an enriched.txt file and .rttm file and measures the
# number of words and syllables in each of the SAD segments defined in the .rttm file.

import csv, sys
import numpy as np
import glob

files_dir = ('%s' % sys.argv[1])
curr_id = ('%s' % sys.argv[2])

#files_dir = '/Users/seshads1/Documents/code/ACLEW/aclew_git_divime_2/DiViMe/data/tmp_out/'
#curr_id = 'BER_0396'

#print(files_dir)
#print(curr_id)
#enrich_file = '/Users/rasaneno/Documents/koodit/dev_python/VM/rttm_and_enrich_merger/0396_enriched.txt';
#rttm_file =  '/Users/rasaneno/Documents/koodit/dev_python/VM/rttm_and_enrich_merger/tocombo_sad_BER_0396_005220_005340.rttm';

# Read enriched file first to get original annotated utterances and their information

mainFile = files_dir + '/' + curr_id + '_totWords.txt'
file = open(mainFile,'r')
totWords = float(file.read())

alignFiles = glob.glob(files_dir + '/' + '*' + curr_id + '_*_words_out.txt')
align_words = np.array([])

for i in range(len(alignFiles)):
    with open(alignFiles[i], 'rt') as f:
        reader = csv.reader(f, delimiter='\t')
        for row in reader:
            align_words = np.append(align_words,float(row[0]))
            
words_all = np.array([totWords,sum(align_words)])

np.savetxt(mainFile ,words_all,fmt='%i',delimiter='\t')        

 