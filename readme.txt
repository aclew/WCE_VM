Word count estimator (WCE) version 0.1 for DiViMe virtual machine.

By Okko Räsänen & Shreyas Seshadri, (okko.rasanen@aalto.fi, shreyas.seshadri@aalto.fi)

See configs/config_default.txt for configuration options.

NOTE: This is a very preliminary release that has not been extensively tested for stability. Use at your own consideration.

If you use this code or its derivations in a publication or other software, remember cite the following document:

Rasanen, O., Seshadri, S., Karadayi, J., Riebling, E., Bunce, J., Cristia, A., Metze, F., Casillas, M., Rosemberg, C., Bergelson, E., 
& Soderstrom, M. (submitted): Automatic word count estimation from daylong child-centered recordings in various language environments 
using language-independent syllabification of speech 


####################################
Installation to DiViMe (these steps should be in the Vagrantfile)


# Get WCE from GitHub

cd ~/repos/
git clone https://github.com/aclew/WCE_VM

# Install WCE dependencies

 ~/anaconda/bin/pip install keras
 ~/anaconda/bin/pip install -U tensorflow

# Move WCE operating scripts to launcher

cp ~/repos/WCE_VM/aux_VM/WCE_preprocess.sh ~/launcher/
cp ~/repos/WCE_VM/aux_VM/WCE_fulltrain.sh ~/launcher/
cp ~/repos/WCE_VM/aux_VM/WCE_estimate.sh ~/launcher/
cp ~/repos/WCE_VM/aux_VM/WCE_LOSO_eval.sh ~/launcher/



####################################
How to operate WCE on VM

To prepare ACLEW-format data for training and cross-validation, place your .wav files into data/ folder of the VM 
(e.g., data/wavs/), and then the daylong annotation .eaf files to another folder (e.g., data/eafs/). Then 

    1) Call

    /launcher/WCE_preprocess.sh to carry out SAD on the data, and to derive the SAD-segment specific word counts.

    and then either

    2a)

    /launcher/WCE_LOSO_eval.sh to carry out leave-one-subject-out cross-validation on the provided data (depending on the
        dataset size, this might take some time)

    or 
    2b)

    /launcher/WCE_fulltrain.sh to first adapt WCE module to all provided and prepared data

    and then

    /launcher/WCE_estimate.sh <filenames.txt> to apply the adapted model to get word counts on new signals, where  
        <filenames.txt> is an ASCII .txt file with one signal path per row.


You can also call the WCE training and testing functions directly 

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

and

./run_WCEestimate.sh /usr/local/MATLAB/MATLAB_Runtime/v91/ <inputs.txt> <mymodelfile.mat> <output.csv>

where inputs.txt and mymodelfile.mat are as in training, and output.csv is the location where estimated word counts are stored.


####################################

DEMO scripts:

./run_WCEtrain.sh /usr/local/MATLAB/MATLAB_Runtime/v93/ demofiles.txt democounts.txt models/mymodel.mat configs/config_default.txt

./run_WCEestimate.sh /usr/local/MATLAB/MATLAB_Runtime/v93/ demofiles.txt models/mymodel.mat outputs/output.csv


####################################
Other notes:

1) The current software uses (and includes) Voicebox toolbox for MATLAB by Mike Brooks, 
as distributed under GNU Public License. 

No modifications to the original voicebox have been made.

http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.htm





####################################
MCR installation for standalone use outside DiViMe

(note that the correct MCR is already included on the DiViMe)

This is a stand-alone MATLAB binary that requires MATLAB Runtime Environment version v9.3.

Step 1: download
http://ssd.mathworks.com/supportfiles/downloads/R2016b/deployment_files/R2016b/installers/glnxa64/MCR_R2017b_glnxa64_installer.zip

Step 2: unzip and run
	sudo ./install -mode silent -agreeToLicense yes"
in the unpackaged MCR folder.

All source code (MATLAB and Python mostly) are included in the WCE/ folder, and can be re-compiled for new platforms if needed.
