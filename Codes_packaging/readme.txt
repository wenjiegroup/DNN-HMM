This directory contains all the Perl scripts and MATLAB codes we writed for the identification of replication domains in our paper. So to run them ,first you should have Perl and MATLAB installed on your computer. The version of Perl we used is v5.14.2 and MATLAB is MATLAB 8.2(R2013b).


------------------------------
In order to save space, we don't provide the raw data and temporary results. However, we save some of results in the corresponding directories for your quick look.
To run all the scripts without error, you need at least prepare well the files of the six cell cycle fractions (G1/G1b, S1, S2, S3, S4, G2) of Replicate 1 of Bj cells, for the manual annotations of training and test sets are made on Replicate 1 of Bj cells. see 'UW_Repli-seq_data/readme.txt' for detail.


------------------------------
Here are some instructions of the scripts we writed.

***A: data pre-processing
All the .pl and .m files whose name begins with 'A' prepares the input data into the format that will be used by DNN-HMM writed in MATLAB. These procedures are just data pre-processing and can be replaced by any other operations depending on your data. What you need to do is just to process and transform your data into the format used by our DNN-HMM. You'd better scale your data into the range of [0,1].
There are some instructions and comment lines in each of the files.

***B: identification
The two .m files whose name begins with 'B' are the main processes of learning and prediction of DNN-HMM. The DNN-HMM is a general method, which can be used to do a lot of things else. Here we just use it to identify replication domains.
There are some instructions and comment lines in each of the files.
The raw result of identification is at the directory 'Result_of_prediction'.

***C: merging sub-states
The two .pl files whose name begins with 'C' are just merging the 14 sub-states into 6 states in .bed format.
The merged result of identification is at the directory 'Result_of_prediction_bed_DNN_HMM' with '_6_segments.bed' suffix.

***D: post-refinement
The .pl and .m files whose name begins with 'D' filter the results of dead zones and biphasic zones to get a better result. These steps are not necessary and are flexible according to your data.
The final refined result of identification is at the directory 'Result_of_prediction_bed_DNN_HMM' with '_refined_segments.bed' suffix.


Run the scripts by the order of A1a, A1b, ..., B1, B2, C1, C2, D1a, ..., D2. For example, type 'perl A1a_format_wig_to_decomposed_signal.pl' to run this perl script.
There are some instructions and comment lines in each of the files.


------------------------------
Here are some brief introductions about each directory.

'UW_Repli-seq_data': contain raw UW Repli-seq data.

'Custom_Signal': contain files in our custom signal format transformed from the raw UW Repli-seq data. The results of scripts with 'A1' prefix are in this directory.

'Manual_annotation': contain manual annotations of training and test sets.

'Data_for_training_tesing_and_prediction': contain data for training, testing and prediction. These files are extracted from the custom signal files and manual annotated labels. The results of scripts with 'A2' and 'A3' prefix are in this directory.

'Matlab_code_for_DNN-HMM_and_related': contain all the matlab codes of DNN-HMM and related DNN, Kmeans GMM-HMM and EM GMM-HMM algorithm.

'Model_learnt': contain all the learnt model parameters, time cost and accuracy of training and test set for the above four algorithms. The results of scripts with 'B1' prefix are in this directory.

'Result_of_prediction': contain raw results of identification using DNN-HMM and related algorithms. Prediction is based on the model learnt in the learning step. The results of scripts with 'B2' prefix are in this directory.

'Result_of_prediction_bed_DNN_HMM': contain files of the raw identification results, merged results and refined results in .bed format. The results of scripts with 'C' and 'D' prefix are in this directory.




