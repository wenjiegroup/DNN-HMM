function [  ] = D1b_analyse_the_threshold_of_filtering(  )
%A17B_ANALYSIS_OF_FILTERING_ Summary of this function goes here
%   Detailed explanation goes here

dir_in='Result_of_prediction_bed_DNN_HMM';

data=load( strcat(dir_in,'/E6_data_for_filtering.txt') );
data(:,3)=[data(2:end,2);99999999];
data_new(:,1)=data(:,1);
data_new(:,2)=min(data(:,2:3),[],2);

figure;ksdensity(log(data_new(:,1)))
figure;ksdensity(log(data_new(:,2)))

t=[];
[~,c]=kmeans(log(data_new(:,1)),2);
t(end+1)=exp(mean(c));
disp(exp(mean(c)));
[~,c]=kmeans(log(data_new(:,2)),2);
t(end+1)=exp(mean(c));
disp(exp(mean(c)));
% [~,c]=kmeans(log(data_new),2);
% disp(exp(mean(c)));

dlmwrite( strcat(dir_in,'/E6_threshold_for_filtering.txt'),t,'delimiter','\t')

end

