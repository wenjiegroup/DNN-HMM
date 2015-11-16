function [ PI,A,B1,B3,B_DNN,T,acc_DNN ] = lf_HMMSupervisedLearning( training_x, training_y, test_x, test_y, opts, M, sizes )
%LF_HMMSUPERVISEDLEARNING Summary of this function goes here
%   Detailed explanation goes here
%   the main learning process of DNN-HMM and related DNN, Kmeans-GMM-HMM
%   and EM-GMM-HMM. DNN is a part of DNN-HMM.
%
%input:
%training_x:  the training data
%training_y:  the training lable
%test_x:    the test data
%test_y:    the test lable
%opts:  other optional parameter.
%M: number of GMM components
%size:  structure of DNN
%
%output:
%PI:    initial state probability vecort of DNN-HMM
%A: state transition probability matrix of DNN-HMM
%B1:    all model parameters of Kmeans-GMM-HMM
%B3:    all model parameters of EM-GMM-HMM
%B_DNN: all model parameters of DNN
%T: time cost of these algorithms
%acc_DNN:   traning and test accuracy of DNN

addpath(genpath('./'));


if ~iscell(training_x) || ~iscell(training_y)
    error(message('stats:lf_HMMSupervisedLearning:Type of both inputs must be cell'));    
end

K = numel(training_x);
if K ~= numel(training_y)
    error(message('stats:lf_HMMSupervisedLearning:Number of input sequences must equal'));
end

for i=1:K
    if size(training_x{i},2) ~= size(training_y{i},2)
        error(message('stats:lf_HMMSupervisedLearning:Length of observation and state must equal'));
    end
end
   
D = size(training_x{1},1);
for i=1:K
    if size(training_x{i},1) ~= D
        error(message('stats:lf_HMMSupervisedLearning:Dimension of observation must equal'));
    end
end

if nargin < 5
    opts.numepochs = 1;
end
if nargin < 6
    M = 10;
    sizes = [200 200];
end
if nargin < 7
    sizes = [200 200];
end



% initiate pararmeter
AllState = [];
for i=1:K    
    AllState = [AllState, unique(training_y{i})];
end
N = length(unique(AllState));
PI = zeros(N,1);
A = zeros(N);
B1.info = 'GMM';
B1.mixmat = zeros(N,M);
B1.mu = zeros(D,N,M);
B1.sigma = zeros(D,D,N,M);
B3.info = 'GMM';

pseudoPI  = ones(size(PI))-1;
pseudoA = ones(size(A))-1;

% calculate PI and A
training_data=[];
training_label=[];
for i = 1:N
    data{i} = [];
end
for k = 1:K 
    Tk = length(training_y{k});
    PI(training_y{k}(1)) = PI(training_y{k}(1)) + 1;     
    for t=1:Tk-1
        A(training_y{k}(t),training_y{k}(t+1)) = A(training_y{k}(t),training_y{k}(t+1)) + 1;   
        % xi{k}(:,:,t) =      % full( sparse(training_y{k}(1:Tk-1) ,training_y{k}(2:Tk) ,1,N,N) );
        % gamma{k}(:,t) = 
    end
    for i = unique(training_y{k})
        data{i} = [data{i},training_x{k}(:,find(training_y{k}==i))];
    end
    training_data=[training_data,training_x{k}];
    training_label=[training_label,training_y{k}];
end

PI = PI + pseudoPI;
A = A + pseudoA;

PI = PI/sum(PI);
A = bsxfun(@rdivide,A,sum(A,2));


T=[];
%% GMM
for i = unique(AllState)
    disp(['State: ',num2str(i),'; Number of data: ',num2str(size(data{i},2))]);
    
    %%% Method 1: use kmeans to model GMM. This is fastest, more than 50
    %%% times(less than 100 times)
    %%% faster than the following methods. The accuracy is acceptable, which is slightly lower than the
    %%% following methods
    tic;
    [B1.mixmat(i,:), B1.mu(:,i,:), B1.sigma(:,:,i,:)] = EM_init_kmeans(data{i}, M); 
    T(1,i)=toc;
    disp(['Kmeans takes ',num2str(T(end,i)),'s']);
    
    %%% Method 2: use EM to model GMM with kmeans initialized. This method uses the result of Method 1 as initiation. 
    %%% This is the slowest method of Method 1,2,3,4. The accuracy is slightly higher
    %%% than Method 1
%     tic;
%     [B2.mixmat(i,:), B2.mu(:,i,:), B2.sigma(:,:,i,:)] = EM(data{i}, B1.mixmat(i,:), squeeze(B1.mu(:,i,:)), squeeze(B1.sigma(:,:,i,:)));
%     T(end+1,i)=toc;
    
    %%% Method 3: use EM to model GMM with kmeans initialized. This method
    %%% and Method 2 both use EM algorithm to model GMM, and both use the result of Method 1 as initiation,
    %%% but these two methods are writed by different persons. As a reslut,
    %%% Method 3 is about five times faster than Method 2, and more robust
    %%% than Method 2(Method 2 may get errors sometimes). The accuracy is more or less same as that of than Method 2.
    model.weight = B1.mixmat(i,:);
    model.mu = squeeze(B1.mu(:,i,:));
    model.Sigma = squeeze(B1.sigma(:,:,i,:));
    tic;
    [~, model, llh] = emgm(data{i}, model);
    T(2,i)=toc;
    fprintf('Number of components: %d\n',length(model.weight));
    disp(['EM takes ',num2str(T(end,i)),'s']);
    fprintf('\n');
    try        
        B3.mixmat{i} = model.weight;
        B3.mu{i} = model.mu;
        B3.sigma{i} = model.Sigma;
    catch err
        if (strcmp(err.identifier,'MATLAB:subsassigndimmismatch'))
            warning(strcat('You should try a smaller number of components, for example ',num2str(length(model.weight)),', or it will take much more time!'));
%             tic;
%             [~, model, llh] = emgm(data{i}, M);
%             T(end,i)=toc;
        else
            rethrow(err);
        end
    end
    
    %%% Method 4: use EM to model GMM which is randomly initialized. This
    %%% is same as Method 3 except that the algorithm is randomly
    %%% initialized. So it is slower than Method 3, and the accuracy is
    %%% almost the same.
%     tic;
%     [~, model, llh] = emgm(data{i}, M);
%     T(end+1,i)=toc;
%     B4.mixmat(i,:) = model.weight;
%     B4.mu(:,i,:) = model.mu;
%     B4.sigma(:,:,i,:) = model.Sigma;
    
    %%% In summary, Method 1 is the fastest, whose accuracy is
    %%% acceptable(slightly lower than other methods). The accuracies of Method 2 and Method 4
    %%% are almost the same with that of Method 3, but both are much slower than Method 3.
    %%% So, we chose Method 1 and Method 3 as the final methods(Method 1 fastest, Method 3 more accurte and slower than Method 1).
    %%% The following DNN method is more accurte and slower than Method 3,
    %%% and thus we have three levels of algorithms.(speed: Method 1>Method 3>DNN; accuracy: DNN>Method 3>Method 1 )
    
    
    
    
    %%% use the matlab inline function, but it always gets errors. So
    %%% don't use it
% %     S.PComponents = B1.mixmat(i,:); 
% %     S.mu = squeeze(B1.mu(:,i,:))';  
% %     S.Sigma = squeeze(B1.sigma(:,:,i,:)); 
% %     tic;
% %     obj = gmdistribution.fit(data{i}',M,'Start',S,'CovType',CovType);
% %     %obj = gmdistribution.fit(data{i}',M,'CovType',CovType);
% %     T(end+1,i)=toc;
% %     B2.mixmat(i,:) = obj.PComponents;
% %     B2.mu(:,i,:) = obj.mu';
% %     B2.sigma(:,:,i,:) = obj.Sigma;

end
T=sum(T,2);

%% DNN
addpath('.');
% [~, model] = emgm(training_data, M);   % there is no need to calculate P(Xt), just for checking. In final version, this can be omitted
% obj = gmdistribution(model.mu',model.Sigma,model.weight); 

test_data=[];
test_label=[];
for k = 1:numel(test_y)   %%  get test data and label
    test_data=[test_data,test_x{k}];
    test_label=[test_label,test_y{k}];
end

tic;
[ acc_DNN,stackedAEOptTheta,output1,output2,output3,T_DNN ] = supervisedlearnig(training_data',training_label',test_data',test_label',sizes, 0, opts); %% the main learning function of DNN
T(end+1)=T_DNN;
B_DNN.stackedAEOptTheta = stackedAEOptTheta;
B_DNN.output1 = output1;
B_DNN.output2 = output2;
B_DNN.output3 = output3;
for i=unique(AllState)
    B_DNN.p(i) = (size(data{i},2)/size(training_data,2));
end
B_DNN.p =  B_DNN.p(:);
% B_DNN.obj = obj;
B_DNN.info = 'DNN';
T(end+1)=toc;

end

