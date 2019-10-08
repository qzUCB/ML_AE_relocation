% data preparation for AE relocation using nueral networks
clear all;
% close all;
clc

KFolds = 10;
numNN = 50;
numNeural = 12;
MaxEpochs = 100;

%% data for training
    [trainingData,...
    actual_coor_data_repeat,...
    t_arri_indx_data_repeat,...
    t_arri_indx_train,...
    actual_coor_train] = load_training_data;

%% divide data into 10 groups for kfold cross-validation
actual_coor_train_all = actual_coor_train';
t_arri_indx_train_all = t_arri_indx_train';
cvp = cvpartition(size(t_arri_indx_train_all, 1), 'KFold', KFolds);
for fold = 1:KFolds
    
    actual_coor_data_test = (actual_coor_train_all(cvp.test(fold), :))';
    t_arri_indx_data_test = (t_arri_indx_train_all(cvp.test(fold), :))';
    t_arri_indx_train = (t_arri_indx_train_all(cvp.training(fold), :))';
    actual_coor_train = (actual_coor_train_all(cvp.training(fold), :))';   

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
%     net.plotFcns = {'plotperform','plottrainstate','ploterrhist', ...
%         'plotregression', 'plotfit'};

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

    %% test all the models and the averaged output
    if ~isempty(actual_coor_data_test)
        perfs = zeros(1, numNN);
        y2Total = 0;

        for i = 1:numNN
          neti = nets{i};
          out = neti(t_arri_indx_data_test);
          perfs(i) = mse(neti, actual_coor_data_test, out);
          y2Total = y2Total + out;
        end
        perfs

        outAvg = y2Total / numNN;
        perfAvg = mse(nets{1}, actual_coor_data_test, outAvg);

        errs  = abs(outAvg-actual_coor_data_test);
        validationRMSE(:,cvp.test(fold)) = sqrt(errs.^2/numel(outAvg(1,:)));
                
        x_err = errs(1,:);
        z_err = errs(2,:);
        
        disp('------------------- Errors --------------------')
        disp('       Mean       Max        Min')
        disp(['x   ' num2str([mean(x_err),max(x_err),min(x_err)])])
        disp(['z   ' num2str([mean(z_err),max(z_err),min(z_err)])])
        disp('-----------------------------------------------')

        perfs_repeat = zeros(1, numNN);
        y2Total_repeat = 0;
        for i = 1:numNN
          neti = nets{i};
          out_repeat = neti(t_arri_indx_data_repeat);
          perfs_repeat(i) = mse(neti, actual_coor_data_repeat, out_repeat);
          y2Total_repeat = y2Total_repeat + out_repeat;
        end
        perfs_repeat

        outAvg_repeat = y2Total_repeat / numNN;
        perfAvg_repeat = mse(nets{1}, actual_coor_data_repeat, outAvg_repeat);

        errs_repeat  = abs(outAvg_repeat-actual_coor_data_repeat);
        x_err_repeat = errs_repeat(1,:);
        z_err_repeat = errs_repeat(2,:);
        disp('------------- Repeatability Errors --------------')
        disp('       Mean       Max        Min')
        disp(['x   ' num2str([mean(x_err_repeat),max(x_err_repeat),min(x_err_repeat)])])
        disp(['z   ' num2str([mean(z_err_repeat),max(z_err_repeat),min(z_err_repeat)])])
        disp('-------------------------------------------------')
     
    end
end

mean(validationRMSE(1,:))
mean(validationRMSE(2,:))
