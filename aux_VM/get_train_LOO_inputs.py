
# This function takes an enriched.txt file and .rttm file and measures the
# number of words and syllables in each of the SAD segments defined in the .rttm file.

import csv, sys
import numpy as np
import scipy.io.wavfile as wav
import glob

val_Id = ('%s' % sys.argv[1])
savedir = ('%s' % sys.argv[2])
all_files = ('%s' % sys.argv[3:])

all_files = all_files.replace("'",'')
all_files = all_files.replace('[','')
all_files = all_files.replace(']','')
all_files = all_files.replace(' ','')
all_files = all_files.split(',')

#print(val_Id)
#print(savedir)
#print(all_files)


words_tot = 0
words_aligned = 0
waveList = []
wordList = []

for i in range(len(all_files)):
    if i == int(val_Id):
        continue

    # list of wavFiles
    curr_files = glob.glob(savedir + '*' + all_files[i] + '*_wavList.txt')
    for ii in curr_files:
        file = open(ii, 'rt')
        waveList.append(file.read().splitlines())
        file.close()
        # list of wordCounts
        ii_i = ii.replace('wavList','words_out')
        file = open(ii_i, 'rt')
        wordList.append(file.read().splitlines())
        file.close()


#    curr_files = glob.glob(savedir + all_files[i] + '*_words_out.txt')
#    for ii in curr_files:
#        file = open(ii, 'rt')
#        wordList.append(file.read().splitlines())
#        file.close()

    # for alpha calcuation
    filepath = glob.glob(savedir + '*' + all_files[i]+ '_totWords.txt')
    #print(filepath[0])
    file = open(filepath[0], 'rt')
    row = file.read().splitlines()
    file.close()
    words_tot += float(row[0])
    words_aligned += float(row[1])

waveList = [item for sublist in waveList for item in sublist]
wordList = [item for sublist in wordList for item in sublist]


with open(savedir + 'WAVFILES_TRAIN.txt','w') as f:
    for item in waveList:
        f.write("%s\n" % item)

with open(savedir + 'WORDCOUNTS_TRAIN.txt','w') as f:
    for item in wordList:
        f.write("%s\n" % item)

alpha = words_aligned/words_tot
f = open(savedir + 'ALPHA.txt','w')
f.write("%s" % alpha)
f.close()


waveList = []
wordList = []


if int(val_Id)>=0:
    # list of wavFiles
    curr_files = glob.glob(savedir + '*' +all_files[int(val_Id)] + '*_wavList.txt')
    for ii in curr_files:
        file = open(ii, 'rt')
        waveList.append(file.read().splitlines())
        file.close()
        # list of wordCounts
        ii_i = ii.replace('wavList','words_out')
        file = open(ii_i, 'rt')
        wordList.append(file.read().splitlines())
        file.close()

    # list of wordCounts
#    curr_files = glob.glob(savedir + all_files[int(val_Id)] + '*_words_out.txt')
#    for ii in curr_files:
#       file = open(ii, 'rt')
#        wordList.append(file.read().splitlines())
#        file.close()



    waveList = [item for sublist in waveList for item in sublist]
    wordList = [item for sublist in wordList for item in sublist]


    with open(savedir + 'WAVFILES_TEST.txt','w') as f:
        for item in waveList:
            f.write("%s\n" % item)

    with open(savedir + 'WORDCOUNTS_TEST.txt','w') as f:
        for item in wordList:
            f.write("%s\n" % item)
