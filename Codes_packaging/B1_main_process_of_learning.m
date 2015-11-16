function [ T, record ] = B1_main_process_of_learning( neighbour, sizes, M, numepochs)
%   Detailed explanation goes here
%   this script learns the models of DNN-HMM and related DNN, Kmeans-GMM-HMM and EM-GMM-HMM respectively, 
%   and outputs the time cost, training accurary and test accurary. DNN is a part of DNN-HMM.

%input:
%neighbour: the number of neibours on both sides of the original one.
%       In this paper, we used 'neibour=0', and for performance assessment we additionally used 'neibour=5' and 'neibour=10'
%sizes: structure of DNN. A vector indicating the numbers of units in each
%       hidden layer. In this paper ,we use [500 500], which means the DNN
%       have 2 hidden layers and each layer have 500 units.
%M:     number of GMM components. In this paper ,we use M=5
%numepochs: number of iteration for DNN. In this paper ,we use 50

%You can omit the input parameter, which will use the paramerters we used
%in this paper.
%This scritp with the default parameters will take a long time, maybe
%several hours. For quick investigation or test, set the parameter smaller.
%For example, neighbour=0,sizes=[10 10],M=3,numepochs=10

%output
%T:     time cost by Kmeans-GMM-HMM, EM-GMM-HMM, DNN and DNN-HMM
%record:    record of training and testing accuracy. column order:
%           training accuracy and test accuracy. row order: Kmeans-GMM-HMM, EM-GMM-HMM, DNN and DNN-HMM


if nargin<1
    neighbour = 0;   %the number of neibours on both sides of the original one. 0
end
if nargin<2
    sizes = [500 500];   %structure of DNN. [500 500]
end
if nargin<3
    M = 5;   %number of GMM components. 5
end
if nargin<4
    numepochs = 50;   % 50
end
opts.numepochs=numepochs;

disp( ['numepochs=' num2str(opts.numepochs) '; M=' num2str(M) '; sizes=[' num2str(sizes) ']; neighbour=' num2str(neighbour) ]);
fprintf('\n');

dir_out='Model_learnt';
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end

addpath(genpath('Matlab_code_for_DNN-HMM_and_related/'));
%%load traning set
load(strcat('Data_for_training_tesing_and_prediction/training_set/training_set_neibour',num2str(neighbour),'.mat'));
training_x=seqs;
training_y=states;
%%load test set
load(strcat('Data_for_training_tesing_and_prediction/test_set/test_set_neibour',num2str(neighbour),'.mat'));
test_x=seqs;
test_y=states;

%% learning the whole model of DNN-HMM and related DNN, Kmeans-GMM-HMM and EM-GMM-HMM

[ PI,A,B1,B3,B_DNN,T,acc_DNN ] = lf_HMMSupervisedLearning( training_x, training_y, test_x, test_y, opts, M, sizes);  % the main learning function


%% refining some of the learnt model parameters to achieve higher performance. This should denpend on your input data and can be omitted
% refine the state transition probility of the state 13 and state 14 of the DNN-HMM model
A(:,13)=eps;  
A(13,:)=eps;
A(13,13)=1;
A(:,14)=eps;  
A(14,:)=eps;  
A(14,14)=1;  
A = bsxfun(@rdivide,A,sum(A,2));
% refine the component weight of state 14 of the Kmeans-GMM-HMM model
[~,ind] = max(B1.mixmat(14,:));
B1.mixmat(14,:) = 0;
B1.mixmat(14,ind) = 1;
B1.mixmat(14,:) = B1.mixmat(14,:)/sum(B1.mixmat(14,:)); 
% refine the component weight of state 14 of the EM-GMM-HMM model
[~,ind] = max(B3.mixmat{14});
B3.mixmat{14}(:) = 0;
B3.mixmat{14}(ind) = 1;
B3.mixmat{14} = B3.mixmat{14}/sum(B3.mixmat{14}); 



record=[];% record of training accuracy and test accuracy

%% accuracy of traning set
total_length=0;
acc=zeros(4,1);
for kk=1:numel(training_x)
    total_length=total_length+length(training_y{kk});
    
    B = mixgauss_prob(training_x{kk}, B1.mu, B1.sigma, B1.mixmat);% Kmeans-GMM-HMM
    [path] = lf_HMMViterbi(PI,A, B);
    acc(1)=acc(1)+sum(path==training_y{kk});
    
    B = mixgauss_prob(training_x{kk}, B3.mu, B3.sigma, B3.mixmat);% EM-GMM-HMM
    [path] = lf_HMMViterbi(PI,A, B);
    acc(2)=acc(2)+sum(path==training_y{kk});
    
    [path,M2] = supervisedstackedAEPredict(B_DNN.stackedAEOptTheta,B_DNN.output1,B_DNN.output2,B_DNN.output3, training_x{kk});% DNN
    acc(3)=acc(3)+sum(path==training_y{kk});   
    % B = bsxfun(@rdivide, bsxfun(@times,M2, pdf(B_DNN.obj,training_x{1}')') ,B_DNN.p) ;
    
    %%%refining some of the learnt model parameters to achieve higher performance. This should denpend on your input data and can be omitted
    index=[2 7 12]; % the state 2, 7 and 12 should have same disbribution 
    M2(index,:)=repmat(sum(M2(index,:))/length(index),length(index),1);
    B_DNN.p(index)=sum(B_DNN.p(index))/length(index);
    index=[3 6 8 11];  % the state 3, 6, 8 and 11 should have same disbribution 
    M2(index,:)=repmat(sum(M2(index,:))/length(index),length(index),1);
    B_DNN.p(index)=sum(B_DNN.p(index))/length(index);
    index=[4 9 10];  % the state 4, 9 and 10 should have same disbribution 
    M2(index,:)=repmat(sum(M2(index,:))/length(index),length(index),1);
    B_DNN.p(index)=sum(B_DNN.p(index))/length(index);

    B = bsxfun(@rdivide,M2 ,B_DNN.p) ; %DNN-HMM
    [path] = lf_HMMViterbi(PI,A, B);
    acc(4)=acc(4)+sum(path==training_y{kk});   
end
acc=acc/total_length;
disp(strcat('training accuracy of Kmeans-GMM-HMM:',num2str(acc(1)*100),'%'))
disp(strcat('training accuracy of EM-GMM-HMM:',num2str(acc(2)*100),'%'))
disp(strcat('training accuracy of DNN:',num2str(acc(3)*100),'%')) %same with acc_DNN(1)
disp(strcat('training accuracy of DNN-HMM:',num2str(acc(4)*100),'%'))
record(:,1)=acc;
    
%% accuracy of testing set

total_length=0;
acc=zeros(4,1);
for kk=1:numel(test_x)
    total_length=total_length+length(test_y{kk});
    
    B = mixgauss_prob(test_x{kk}, B1.mu, B1.sigma, B1.mixmat);% Kmeans-GMM-HMM
    [path] = lf_HMMViterbi(PI,A, B);
    acc(1)=acc(1)+sum(path==test_y{kk});
    
    B = mixgauss_prob(test_x{kk}, B3.mu, B3.sigma, B3.mixmat);% EM-GMM-HMM
    [path] = lf_HMMViterbi(PI,A, B);
    acc(2)=acc(2)+sum(path==test_y{kk});
    
    [path,M2] = supervisedstackedAEPredict(B_DNN.stackedAEOptTheta,B_DNN.output1,B_DNN.output2,B_DNN.output3, test_x{kk});% DNN
    acc(3)=acc(3)+sum(path==test_y{kk});   
    % B = bsxfun(@rdivide, bsxfun(@times,M2, pdf(B_DNN.obj,training_x{1}')') ,B_DNN.p) ;
    
    %%%refining some of the learnt model parameters to achieve higher performance. This should denpend on your input data and can be omitted
    index=[2 7 12]; % the state 2, 7 and 12 should have same disbribution 
    M2(index,:)=repmat(sum(M2(index,:))/length(index),length(index),1);
    B_DNN.p(index)=sum(B_DNN.p(index))/length(index);
    index=[3 6 8 11];  % the state 3, 6, 8 and 11 should have same disbribution 
    M2(index,:)=repmat(sum(M2(index,:))/length(index),length(index),1);
    B_DNN.p(index)=sum(B_DNN.p(index))/length(index);
    index=[4 9 10];   % the state 4, 9 and 10 should have same disbribution 
    M2(index,:)=repmat(sum(M2(index,:))/length(index),length(index),1);
    B_DNN.p(index)=sum(B_DNN.p(index))/length(index);

    B = bsxfun(@rdivide,M2 ,B_DNN.p) ; %DNN-HMM
    [path] = lf_HMMViterbi(PI,A, B);
    acc(4)=acc(4)+sum(path==test_y{kk});   
end
acc=acc/total_length;
disp(strcat('test accuracy of Kmeans-GMM-HMM:',num2str(acc(1)*100),'%'))
disp(strcat('test accuracy of EM-GMM-HMM:',num2str(acc(2)*100),'%'))
disp(strcat('test accuracy of DNN:',num2str(acc(3)*100),'%')) %same with acc_DNN(2)
disp(strcat('test accuracy of DNN-HMM:',num2str(acc(4)*100),'%'))
record(:,2)=acc;


size_flag=[];
for i=1:length(sizes)
    size_flag=strcat(size_flag,'_',num2str(sizes(i)));
end
save(strcat(dir_out,'/HMMSupervised_result_M',num2str(M),'_i',num2str(opts.numepochs),size_flag,'_n',num2str(neighbour),'.mat'),'PI','A','B1','B3','B_DNN','T','record');


%% output the predicted label of unlabelled data
% 
% prediction_result_dir='Result_of_prediction/';
% if ~exist(prediction_result_dir,'dir')
%     mkdir(prediction_result_dir);
% end
% unlabelled_dir='./Data_for_training_tesing_and_prediction/unlabelled_set/';
% unlabelled_cells = dir(unlabelled_dir);
% for ii=3:numel(unlabelled_cells)
%     disp(['writing results of ' unlabelled_cells(ii).name '...']);
%     unlabelled_cell = unlabelled_cells(ii).name;
%     
%     if ~exist(strcat(prediction_result_dir,unlabelled_cell),'dir')
%         mkdir(strcat(prediction_result_dir,unlabelled_cell));
%     end
%     %%load unlabelled data for prediction
%     load(strcat(unlabelled_dir,unlabelled_cell,'/',unlabelled_cell,'_neibour',num2str(neighbour),'.mat'));
% 
%     disp('  writing Kmeans-GMM-HMM...')
%     for i=1:numel(unlabelled_seqs) %prediction of Kmeans-GMM-HMM
%         B = mixgauss_prob(unlabelled_seqs{i}, B1.mu, B1.sigma, B1.mixmat);
%         [path] = lf_HMMViterbi(PI,A, B);
%         dlmwrite(strcat(prediction_result_dir,unlabelled_cell,'/',unlabelled_cell,'_labelled_state_of_Kmeans_GMM_HMM_chr',num2str(i),'.txt'),path(:),'delimiter','' );
%     end
%     
%     disp('  writing EM-GMM-HMM...')
%     for i=1:numel(unlabelled_seqs) %prediction of EM-GMM-HMM
%         B = mixgauss_prob(unlabelled_seqs{i}, B3.mu, B3.sigma, B3.mixmat);
%         [path] = lf_HMMViterbi(PI,A, B);
%         dlmwrite(strcat(prediction_result_dir,unlabelled_cell,'/',unlabelled_cell,'_labelled_state_of_EM_GMM_HMM_chr',num2str(i),'.txt'),path(:),'delimiter','' );
%     end
%     
%     disp('  writing DNN and DNN-HMM...')
%     for i=1:numel(unlabelled_seqs)
%         [path,M2] = supervisedstackedAEPredict(B_DNN.stackedAEOptTheta,B_DNN.output1,B_DNN.output2,B_DNN.output3, unlabelled_seqs{i});%prediction of DNN
%         dlmwrite(strcat(prediction_result_dir,unlabelled_cell,'/',unlabelled_cell,'_labelled_state_of_DNN_chr',num2str(i),'.txt'),path(:),'delimiter','' );
%         
%         index=[2 7 12];
%         M2(index,:)=repmat(sum(M2(index,:))/length(index),length(index),1);
%         B_DNN.p(index)=sum(B_DNN.p(index))/length(index);
%         index=[3 6 8 11];
%         M2(index,:)=repmat(sum(M2(index,:))/length(index),length(index),1);
%         B_DNN.p(index)=sum(B_DNN.p(index))/length(index);
%         index=[4 9 10];
%         M2(index,:)=repmat(sum(M2(index,:))/length(index),length(index),1);
%         B_DNN.p(index)=sum(B_DNN.p(index))/length(index);
% 
%         B = bsxfun(@rdivide,M2 ,B_DNN.p) ; %prediction of DNN-HMM
%         [path] = lf_HMMViterbi(PI,A, B);
%         dlmwrite(strcat(prediction_result_dir,unlabelled_cell,'/',unlabelled_cell,'_labelled_state_of_DNN_HMM_chr',num2str(i),'.txt'),path(:),'delimiter','' );
%     end
% end














%% after an unsupervised DNN
%%% 此部分代码还是有问题需要进一步测试，目前先把复制时间的问题解决了在考虑解决这个思路
% [ stackedAEOptTheta,netconfig,stackedAETheta ] = unsupervisedlearnig([chr1_x;chr10_x],[200 200 10], 0, opts );
% [chr1_x] = unsupervisedstackedAEPredict(stackedAEOptTheta, netconfig, chr1_x');
% [chr10_x] = unsupervisedstackedAEPredict(stackedAEOptTheta, netconfig, chr10_x');
% [chrX_x] = unsupervisedstackedAEPredict(stackedAEOptTheta, netconfig, chrX_x');
% training_x={chr1_x,chr10_x};
% test_x=chrX_x;
% [~,state1]=max(chr1_y');
% [~,state10]=max(chr10_y');
% [~,test_y]=max(chrX_y');
% training_y={state1,state10};
% [ PI,A,B1,B2,B3,T2,B_DNN ] = lf_HMMSupervisedLearning( training_x, training_y, opts);
% record{end+1}='--------';
% 
% B = mixgauss_prob(training_x{1}, B1.mu, B1.sigma, B1.mixmat);
% [path] = lf_HMMViterbi(PI,A, B);
% acc=sum(path==training_y{1})/length(path);
% disp(strcat('training acc of B1:',num2str(acc*100),'%'))
% record{end+1}=strcat('training acc of B1:',num2str(acc*100),'%');
% 
% B = mixgauss_prob(training_x{1}, B2.mu, B2.sigma, B2.mixmat);
% [path] = lf_HMMViterbi(PI,A, B);
% acc=sum(path==training_y{1})/length(path);
% disp(strcat('training acc of B2:',num2str(acc*100),'%'))
% record{end+1}=strcat('training acc of B2:',num2str(acc*100),'%');
% 
% B = mixgauss_prob(training_x{1}, B3.mu, B3.sigma, B3.mixmat);
% [path] = lf_HMMViterbi(PI,A, B);
% acc=sum(path==training_y{1})/length(path);
% disp(strcat('training acc of B3:',num2str(acc*100),'%'))
% record{end+1}=strcat('training acc of B3:',num2str(acc*100),'%');
% 
% [~,M2] = supervisedstackedAEPredict(B_DNN.stackedAEOptTheta,B_DNN.output1,B_DNN.output2,B_DNN.output3, training_x{1});
% B = bsxfun(@rdivide, bsxfun(@times,M2, pdf(B_DNN.obj,training_x{1}')') ,B_DNN.p) ;
% [path] = lf_HMMViterbi(PI,A, B);
% acc=sum(path==training_y{1})/length(path);
% disp(strcat('training acc of B_DNN:',num2str(acc*100),'%'))
% record{end+1}=strcat('training acc of B_DNN:',num2str(acc*100),'%');
% 
% B = mixgauss_prob(test_x, B1.mu, B1.sigma, B1.mixmat);
% [path] = lf_HMMViterbi(PI,A, B);
% acc=sum(path==test_y)/length(path);
% disp(strcat('testing acc of B1:',num2str(acc*100),'%'))
% record{end+1}=strcat('testing acc of B1:',num2str(acc*100),'%');
% 
% B = mixgauss_prob(test_x, B2.mu, B2.sigma, B2.mixmat);
% [path] = lf_HMMViterbi(PI,A, B);
% acc=sum(path==test_y)/length(path);
% disp(strcat('testing acc of B2:',num2str(acc*100),'%'))
% record{end+1}=strcat('testing acc of B2:',num2str(acc*100),'%');
% 
% B = mixgauss_prob(test_x, B3.mu, B3.sigma, B3.mixmat);
% [path] = lf_HMMViterbi(PI,A, B);
% acc=sum(path==test_y)/length(path);
% disp(strcat('testing acc of B3:',num2str(acc*100),'%'))
% record{end+1}=strcat('testing acc of B3:',num2str(acc*100),'%');
% 
% [~,M2] = supervisedstackedAEPredict(B_DNN.stackedAEOptTheta,B_DNN.output1,B_DNN.output2,B_DNN.output3, test_x);
% B = bsxfun(@rdivide, bsxfun(@times,M2, pdf(B_DNN.obj,chrX_x)') ,B_DNN.p) ;
% [path] = lf_HMMViterbi(PI,A, B);
% acc=sum(path==test_y)/length(path);
% disp(strcat('testing acc of B_DNN:',num2str(acc*100),'%'))
% record{end+1}=strcat('testing acc of B_DNN:',num2str(acc*100),'%');






end