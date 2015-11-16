function [  ] = A3b_load_unlabelled_sets( neibour )
%A2_LOADING_DATA Summary of this function goes here
%   Detailed explanation goes here
%   this script loads the data of unlabelled sets in MATLAB, for the DNN-HMM algorithm is implemented in MATLAB.

if nargin<1
	neibour=0;   %the number of neibours on both sides of the original one. for prediction of unlabelled sets, we only used 'neibour=0' in this paper
end

dir_in='Data_for_training_tesing_and_prediction/unlabelled_set';

subdirs=dir(dir_in);

for f=3:numel(subdirs);
    disp(subdirs(f).name);
    
    unlabelled_seqs=[];
    for i=1:23
        chr=strcat('chr',num2str(i));
        if i==23
            chr='chrX';
        end
        if exist(strcat(dir_in,'/',subdirs(f).name,'/','x_',chr,'.matrix'),'file');
            x=load( strcat(dir_in,'/',subdirs(f).name,'/','x_',chr,'.matrix') );
        else
            continue;
        end
        

        unlabelled_x=format_x_locally(x,neibour);
        unlabelled_x=bsxfun(@rdivide,unlabelled_x,max(unlabelled_x));
        unlabelled_seqs{end+1} = unlabelled_x';

    end
    

    save(strcat(dir_in,'/',subdirs(f).name,'/',subdirs(f).name,'_neibour',num2str(neibour)),'unlabelled_seqs','-v7.3');


end

