# This function calculates a number of error metrics for syllable- or word count
# estimator, given the estimates and ground truth counts .

# Inputs are supposed to be (estimate_file,reference_file,output_file)

# estimate_file  = contains WCE estimates, one per row
# reference_file = contains the corresponding ground truth estimates .
# output_file (optional) = where to save results. If not provided, the results
# will be saved to the same folder where this script was called.

import csv, sys, os
import numpy as np

if(len(sys.argv) < 3):
    raise ValueError('Too few input arguments (must provide filepath to estimated counts, and filepath to reference counts).')

estimate_file = ('%s' % sys.argv[1])
reference_file = ('%s' % sys.argv[2])

if(len(sys.argv) > 3):
    output_file = ('%s' % sys.argv[3])
else:
    output_file = os.getcwd() + "/WCE_results.txt"

# Read estimated word counts
est = np.array([])
with open(estimate_file, 'rb') as f:
    reader = csv.reader(f, delimiter='\t')
    for row in reader:
        est = np.append(est,float(row[0]))

# Read reference word counts
ref = np.array([])
with open(reference_file, 'rb') as f:
    reader = csv.reader(f, delimiter='\t')
    for row in reader:
        ref = np.append(ref,float(row[0]))


if(len(ref) != len(est)):
    raise ValueError('Estimated and reference counts are of different length.')

linear_corr = np.corrcoef(est,ref)[0,1]

# If reference count is 0, set it to one to get relative measures
ref[ref == 0] = 1

ERR_RMSE = np.sqrt(np.mean(np.power(np.abs(est-ref)/ref,2)))*100

ERR_mean = np.mean(np.abs(est-ref)/ref)*100

ERR_median = np.median(np.abs(est-ref)/ref)*100

with open(output_file, mode='w') as output_fid:
    writer = csv.writer(output_fid, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)

    writer.writerow(['lincorr', 'ERR_RMSE', 'ERR_mean','ERR_median'])
    writer.writerow([linear_corr,ERR_RMSE,ERR_mean,ERR_median])
