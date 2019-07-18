import csv, sys, os
import numpy as np
import scipy.io.wavfile as wav
import glob

# Split wav files into utterances based on SAD outputs in .rttm files.

rttm_folder = ('%s' % sys.argv[1])
if(len(sys.argv) == 3):
    sadname = ('%s' % sys.argv[2])
else:
    sadname = 'opensmile'


if(len(sys.argv) == 4):
    outputdir = ('%s' % sys.argv[2])
else:
    outputdir = rttm_folder + '/wav_tmp/'

fileList = sorted(glob.glob(outputdir + '/' + sadname + '*.wav'))
for f in fileList:
    os.remove(f)


fileList = sorted(glob.glob(rttm_folder + sadname + '*.rttm'))


for rttm_file in fileList:
    path, filename = os.path.split(rttm_file)

    SAD_onsets = np.array([])
    SAD_offsets = np.array([])

    tmp = filename.rfind('_')
    wavfile = path + '/' + filename[tmp+1:-5] + '.wav'

    if not os.path.exists(outputdir):
        os.mkdir(outputdir)

    [rate,mainWav] = wav.read(wavfile)
    if(mainWav.ndim > 1):
        #mainWav = np.mean(mainWav, axis=1)
        mainWav = mainWav[:,0]

    with open(rttm_file, 'rt') as f:
        reader = csv.reader(f, delimiter=' ')
        for row in reader:
            row = filter(None, row) # fastest
            SAD_onsets = np.append(SAD_onsets,float(row[3]))
            SAD_onsets_tmp = float(row[3])
            SAD_offsets = np.append(SAD_offsets,float(row[4])+float(row[3]))

            short_wav_file = outputdir + '/' + filename[0:-5]+ '_' + str(int(float(row[3])*1000)).zfill(8) + '.wav'
            SAD_onsets_tmp = int(np.floor(float(row[3])*rate))+1
            SAD_offsets_tmp = int(np.floor(float(row[4])*rate+float(row[3])*rate))-1
            short_wav = mainWav[SAD_onsets_tmp:SAD_offsets_tmp]
            wav.write(short_wav_file,rate,short_wav)
