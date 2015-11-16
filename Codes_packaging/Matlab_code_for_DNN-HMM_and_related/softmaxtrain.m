function [ softmaxModel ] = softmaxtrain(inputSize, numClasses, train_x, train_y, opts, softmaxlambda, flag )
%SOFTMAXTRAIN Summary of this function goes here
%   Detailed explanation goes here

if ~exist('opts', 'var')
    opts = struct;
end

if ~isfield(opts, 'batchsize')   
    opts.batchsize = 100;
end

%%����mini-batch��ĵ�������epoch��ȡ1�͹����ˣ�Խ��Խ��ҲԽ��ȷ��
%����epoch=1�Ļ�����ʱ1s���ң���ȷ��91%;epoch=10,��ʱ10s���ң�׼ȷ��92.5%
if ~isfield(opts, 'numepochs')  
    opts.numepochs = 1;
end

if nargin<6
    softmaxlambda=1e-4; % Weight decay parameter
end
if nargin<7
    flag=0;   %% flag to use minFunc. 1 to use, 0 otherwise
end

% Use minFunc to minimize the function
%addpath minFunc/
minFuncopts.Method = 'lbfgs'; % Here, we use L-BFGS to optimize our cost
                          % function. Generally, for minFunc to work, you
                          % need a function pointer with two outputs: the
                          % function value and the gradient. In our problem,
                          % softmaxCost.m satisfies this.
minFuncopts.display = 'off';
%%����mini-batch�ڵĵ�����������һ��epoch��batch��ʹ���ݶ��Ż��㷨�ĵ�����������Ϊʹ��mini-batch��
%��������1~3�ε����Ϳ��ԣ��������mini-batch����full batch��Ҫ����100��������,
%��ֵ��ǣ����ֵ���1��Ч���������죬����Խ��Խ��������⣬����Խ��Ч��Խ�����Ϊ���õ�����ֻ��һ��mini-batch
%��˵���Խ����������������batch�ľֲ����Ž⣬������mini-batch�Ĳ������ݶ��½�������һ�����Ҳ���
%��Ϊֻ����һ�Σ�����Ҳ��ȫ�����Լ�д�ݶ��½���
minFuncopts.maxIter = 1;

m = size(train_x, 1);
numbatches = floor(m/opts.batchsize);

% initialize parameters
softmaxOptTheta = 0.005 * randn(numClasses * inputSize, 1);

for i = 1 : opts.numepochs
    kk = randperm(m);
    Optcost = 0;
    for l = 1 : numbatches
        if l==numbatches 
            batch_x = train_x(kk((l - 1) * opts.batchsize + 1 : end), :);
            batch_y = train_y(kk((l - 1) * opts.batchsize + 1 : end), :);
        else
            batch_x = train_x(kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize), :);
            batch_y = train_y(kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize), :);
        end
        if flag
            [softmaxOptTheta, cost] = minFunc( @(p) softmaxCost(p, ...
                                       numClasses, inputSize, softmaxlambda, ...
                                       batch_x', batch_y), ...                                   
                                  softmaxOptTheta, minFuncopts);
        else
            [cost,grad]=softmaxCost(softmaxOptTheta,numClasses, inputSize, softmaxlambda,batch_x', batch_y);
            softmaxOptTheta = softmaxOptTheta - opts.alpha * grad;
        end
        Optcost=Optcost+cost;
    end
    Optcost=Optcost/numbatches;
    fprintf(1,'epoch %d / %d. The value of softmax cost function: %6.3f\n',i,opts.numepochs,Optcost); 
end

% Fold softmaxOptTheta into a nicer format
softmaxModel.optTheta = reshape(softmaxOptTheta, numClasses, inputSize);
softmaxModel.inputSize = inputSize;
softmaxModel.numClasses = numClasses;    



end

