import csv, sys, os
import numpy as np

from numpy import genfromtxt

#WCE_file = '/home/vagrant/my_WCE_output.txt'

WCE_file = ('%s' % sys.argv[1])

path, filename = os.path.split(WCE_file)


if(len(sys.argv) == 3):
    output_rttm_folder = ('%s' % sys.argv[2])
else:
    output_rttm_folder = path


# Find unique .rttm output names first and delete them
with open(WCE_file, 'rt') as f:
    reader = csv.reader(f, delimiter=',')
    for row in reader:
        row = filter(None, row) # fastest
        path, filename = os.path.split(row[0])
        tmp = filename.rfind('_')
        orig_filnam = filename[0:tmp]
        rttm_filnam = output_rttm_folder + '/WCE_' + orig_filnam + '.rttm'
        if os.path.exists(rttm_filnam):
            os.remove(rttm_filnam)

# Append to new rttm files result by result
with open(WCE_file, 'rt') as f:
    reader = csv.reader(f, delimiter=',')
    for row in reader:
        row = filter(None, row) # fastest
        path, filename = os.path.split(row[0])
        tmp = filename.rfind('_')
        tmp2 = filename.rfind('-')
        orig_filnam = filename[0:tmp]
        #t_onset = float(filename[tmp+1:-4])/1000
        t_onset = float(filename[tmp+1:tmp2])/1000
        dur = float(filename[tmp2+1:-4])/1000
        rttm_filnam = output_rttm_folder + '/WCE_' + orig_filnam + '.rttm'
        #y = 'SPEAKER\t'+ '1\t' + orig_filnam + '\t' + str(t_onset) + '\t' + str(dur) + '\t' + '<NA>\t' + '<NA>\t' + row[1] + '\t' + '<NA>\t' + '<NA>\t' + '\n'
        y = 'SPEAKER\t'+ orig_filnam + '\t' + '1\t' + str(t_onset) + '\t' + str(dur) + '\t' + '<NA>\t' + '<NA>\t' + row[1] + '\t' + '<NA>\t' + '<NA>\t' + '\n'
        with open(rttm_filnam,'a') as fd:
            fd.write(y)
