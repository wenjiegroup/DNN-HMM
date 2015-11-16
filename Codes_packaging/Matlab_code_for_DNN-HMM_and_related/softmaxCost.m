function [cost, grad] = softmaxCost(theta, numClasses, inputSize, lambda, data, labels)

% numClasses - the number of classes 
% inputSize - the size N of the input vector
% lambda - weight decay parameter
% data - the N x M input matrix, where each column data(:, i) corresponds to
%        a single test set
% labels - an M x 1 matrix containing the labels corresponding for the input data
%

% Unroll the parameters from theta
theta = reshape(theta, numClasses, inputSize);

numCases = size(data, 2);

groundTruth = full(sparse(labels, 1:numCases, 1,numClasses,numCases));
cost = 0;

thetagrad = zeros(numClasses, inputSize);

%% ---------- YOUR CODE HERE --------------------------------------
%  Instructions: Compute the cost and gradient for softmax regression.
%                You need to compute thetagrad and cost.
%                The groundTruth matrix might come in handy.

M1 = theta * data;
M1 = bsxfun(@minus, M1, max(M1, [], 1)); %%Preventing overflows 
M2 = exp(M1);
M2 = bsxfun(@rdivide, M2, sum(M2));

cost = cost -  mean(sum(groundTruth.*log( M2 )));
cost = cost + lambda/2 * sum(sum(theta.^2)); %Ȩ��˥��

%%%����һ
% for j=1:numClasses  %%% ��numClasses�ϴ��ʱ�򣬿��Կ��ǽ�for��Ϊparfor���в��м�����٣���numClasses��С��ʱ����10����û�б�Ҫ���У����л���Щ
%     thetagrad(j,:) = -mean( bsxfun(@times,groundTruth(j,:)-M2(j,:),data),2 )'+lambda*theta(j,:);  
% end


%%%������
% temp1=repmat(groundTruth-M2,[1,1,inputSize]) .* permute( repmat(data,[1,1,numClasses]),[3 2 1] );
% temp2=-mean(temp1,2);
% temp3=squeeze(temp2);
% thetagrad1 = temp3 + lambda*theta;


%%%������
%%%������Ϊ��������Է���һ�����Щ���������ԣ���size(data)Ϊ784*60000�������Ϊ10ʱ������һ1s���ң�������15s���ң�������0.07s���ҡ����ַ����ٶȲ�ͬ�����ǽ������ȫ��ͬ��
%%%��Ϊ��������죬����÷�����
thetagrad = -1/numCases * (groundTruth - M2) * data' + lambda * theta;


%length(find(thetagrad-thetagrad))


% ------------------------------------------------------------------
% Unroll the gradient matrices into a vector for minFunc
grad = [thetagrad(:)];
end

