function [ stackedAEOptTheta ] = unsupervisedfinetuning( stackedAEOptTheta,train_x, netconfig,lambda, opts, flag )
%FINETUNING Summary of this function goes here
%   Detailed explanation goes here

if ~exist('opts', 'var')
    opts = struct;
end

if ~isfield(opts, 'batchsize')   
    opts.batchsize = 100;
end

%%这是mini-batch外的迭代次数epoch，取1就够用了，越大越慢也越精确，
%比如epoch=1的话，耗时1s左右，正确率91%;epoch=10,耗时10s左右，准确率92.5%
if ~isfield(opts, 'numepochs')  
    opts.numepochs = 1;
end

if nargin<6
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
%%这是mini-batch内的迭代次数，在一个epoch的batch中使用梯度优化算法的迭代次数，因为使用mini-batch，
%所以这里1~3次迭代就可以，如果不是mini-batch而是full batch则要迭代100甚至更多,
%奇怪的是，发现迭代1次效果最好且最快，迭代越多越慢容易理解，迭代越多效果越差，是因为利用的数据只是一个mini-batch
%因此迭代越多则容易收敛到该batch的局部最优解，所以在mini-batch的策略下梯度下降法迭代一次最快也最好
%因为只迭代一次，所以也完全可以自己写梯度下降法
minFuncopts.maxIter = 1;

m = size(train_x, 1);
numbatches = m/opts.batchsize;

for i = 1 : opts.numepochs
    kk = randperm(m);
    Optcost = 0;
    for l = 1 : numbatches
        batch_x = train_x(kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize), :);
        if flag
            [stackedAEOptTheta, cost] =  minFunc(@(p)unsupervisedstackedAECost(p,hiddenSizeL2,...
                              netconfig,lambda, batch_x'),...
                            stackedAEOptTheta,minFuncopts);
            
        else
            [cost,grad]=unsupervisedstackedAECost(stackedAEOptTheta, netconfig,lambda, batch_x');
            stackedAEOptTheta = stackedAEOptTheta - opts.alpha * grad;
        end
            Optcost=Optcost+cost;
    end
    Optcost=Optcost/numbatches;
    fprintf(1,'epoch %d / %d. The value of fine tuning cost function: %6.3f\n',i,opts.numepochs,Optcost); 
end

end

