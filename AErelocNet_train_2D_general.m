% data preparation for AE relocation using nueral networks
clear all;
close all;
clc


numNN = 50;
numNeural = 12;
MaxEpochs = 100;

%% data for training
load('AE_train.mat')

%% build network
% Choose a Training Function
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
trainFcn = 'trainbr';  % Bayesian Regularization backpropagation.
net = fitnet(numNeural,trainFcn);
net.trainParam.epochs = MaxEpochs; %Maximum number of epochs to train

% Choose Input and Output Pre/Post-Processing Functions
% For a list of all processing functions type: help nnprocess
net.input.processFcns = {'removeconstantrows','mapminmax'};
net.output.processFcns = {'removeconstantrows','mapminmax'};

% Setup Division of Data for Training, Validation, Testing
% For a list of all data division functions type: help nndivision
net.divideFcn = 'dividerand';  % Divide data randomly
net.divideMode = 'sample';  % Divide up every sample
net.divideParam.trainRatio = 100/100;
net.divideParam.valRatio = 0/100;
net.divideParam.testRatio = 0/100;

% Choose a Performance Function
% For a list of all performance functions type: help nnperformance
net.performFcn = 'mse';  % Mean Squared Error

% Choose Plot Functions
% For a list of all plot functions type: help nnplot
net.plotFcns = {'plotperform','plottrainstate','ploterrhist', ...
    'plotregression', 'plotfit'};

% Train numNN Network for good generalization
nets = cell(1, numNN);
trs = cell(1, numNN);

for i = 1:numNN
    net = initnw(net,1);
    net = initnw(net,2);
    [net,tr] = train(net,t_arri_indx_train,actual_coor_train);
    nets{i} = net;
    trs{i} = tr;
end

% Deploy
pk = input('Deploy the new model? Y/N [N]:','s');
if isempty(pk), pk = 'n'; end
if pk == 'y' || pk == 'Y'
    save('AErelocNet_Gen_2D.mat','nets')
end

