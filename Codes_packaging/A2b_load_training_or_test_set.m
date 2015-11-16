function [ seqs,states ] = A2b_load_training_or_test_set( neibour )
%A2_LOADING_DATA Summary of this function goes here
%   Detailed explanation goes here
%   this script loads the data of training and test sets in MATLAB, for the DNN-HMM algorithm is implemented in MATLAB.

if nargin<1
	neibour=0;   %the number of neibours on both sides of the original one. in this paper, we used 'neibour=0', and for performance assessment we additionally used 'neibour=5' and 'neibour=10'
end

num_of_seq=50;

flag={'training_set','test_set'};    %% test_set  or  training_set
for kk=1:length(flag)
    disp(['loading ' flag{kk}]);
    dir_in=strcat('Data_for_training_tesing_and_prediction/',flag{kk});    
    seqs=[];
    states=[];

    for i=1:23   % chromosome
        chr=strcat('chr',num2str(i));
        if i==23
            chr='chrX';
        end
        for j=1:num_of_seq
            if ~exist(strcat(dir_in,'/','x_',chr,'_seq',num2str(j),'.matrix'))
                break;
            end

            x=load( strcat(dir_in,'/','x_',chr,'_seq',num2str(j),'.matrix') );
            y=load( strcat(dir_in,'/','y_',chr,'_seq',num2str(j),'.matrix') );

            if size(x,1)~=size(y,1);
                error('number of sample not match!');
            end

            train_x = format_x_locally(x,neibour);
            train_y = y;
            % train_x = bsxfun(@rdivide,train_x,max(train_x));
            train_x = train_x/100;    % use this, not the last row
            seqs{end+1} = train_x';
            states{end+1} = train_y';
        end
    end


    save(strcat(dir_in,'/',flag{kk},'_neibour',num2str(neibour),'.mat'),'seqs','states');
end

end

