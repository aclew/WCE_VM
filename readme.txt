Word count estimator (WCE) version 0.1

By Okko Räsänen & Shreyas Seshadri, (okko.rasanen@aalto.fi, shreyas.seshadri@aalto.fi)

See configs/config_default.txt for configuration options.

NOTE: This is a very preliminary release that has not been extensively tested for stability. Use at your own consideration.

####################################
MCR installation for standalone use

(note that the correct MCR is already included on the DiViMe)

This is a stand-alone MATLAB binary that requires MATLAB Runtime Environment version v9.1.

Step 1: download
http://ssd.mathworks.com/supportfiles/downloads/R2016b/deployment_files/R2016b/installers/glnxa64/MCR_R2016b_glnxa64_installer.zip

Step 2: unzip and run
	sudo ./install -mode silent -agreeToLicense yes"
in the unpackaged MCR folder.

All source code (MATLAB and Python mostly) are included in the WCE/ folder, and can be re-compiled for the DiViMe using MATLAB compiler running on Linux.


####################################
Training syntax on the DiViMe VM:

./run_WCEtrain.sh /usr/local/MATLAB/MATLAB_Runtime/v91/ <inputs.txt> <inputcounts.txt> <mymodelfile.mat> <configfile.txt>

where

inputs.txt = a .txt or .csv file containing training signal .wav paths to be processed
    (one .wav per line)

inputcounts.txt = a .txt or .csv file containing word count in each of the training .wavs
    (one per line)

mymodelfile.mat = specify where to store WCE model resulting from the training (a .mat
    file)

configfile = an ASCII file (e.g., .txt) containing parameter settings for the WCE, see
    configs/config_default.m for examples

####################################
Operation syntax on the DiViMe VM (once a model has been trained):

./run_WCEestimate.sh /usr/local/MATLAB/MATLAB_Runtime/v91/ <inputs.txt> <mymodelfile.mat> <output.csv>

where inputs.txt and mymodelfile.mat are as in training, and output.csv is the location where estimated word counts are stored.


####################################
DEMO scripts:

./run_WCEtrain.sh /usr/local/MATLAB/MATLAB_Runtime/v91/ demofiles.txt democounts.txt mymodel.mat configs/config_default.txt

./run_WCEestimate.sh /usr/local/MATLAB/MATLAB_Runtime/v91/ demofiles.txt mymodel.mat output.csv


####################################
Other notes:

1) The current software uses (and includes) Voicebox toolbox for MATLAB by Mike Brooks, 
as distributed under GNU Public License. 

No modifications to the original voicebox have been made.

http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.htm
