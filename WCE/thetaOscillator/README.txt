This package contains codes for sonority-based syllabification of speech signals. 

Version 0.2 (20.5.2016)

------------
Basic pipeline:
    1) compute gammatone-envelopes for speech signals with 1000 Hz sampling rate
    2) call thetaOscillator.m with the envelopes as input 
    
See SylSegDemo.m for an example.

------------
(c) Okko Rasanen, okko.rasanen@aalto.fi , 2016.

If you use this algorithm in publications, please cite: 
 
Rasanen, O., Doyle, G. & Frank, M. C. (submitted). "Pre-linguistic 
rhythmic segmentation of speech into syllabic units".

------------

Note that the package uses Gammatone-filterbank front-end by Ning Ma 
(http://staffwww.dcs.shef.ac.uk/people/N.Ma/resources/gammatone/). 
If you are not using 64-bit OS X environment, compile the function first with
"mex gammatone_c.c". 

Also uses peakdet.m from Eli Billauer.