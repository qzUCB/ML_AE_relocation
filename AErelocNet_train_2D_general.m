% data preparation for AE relocation using nueral networks
clear all;
% close all;
clc


numNN = 50;
numNeural = 12;
MaxEpochs = 100;

%% data for training
load('..\..\..\loc_test_data\AE_on_fault_data\pick_data_picking_update.mat')
load('..\..\..\loc_test_data\AE_on_fault_data\AE_locations.mat')

actual_coor_data = AE_location(1:39,:);
t_arri_indx_data = [picks(:,[1:18,23:39,44:47])];

%% additional data
load('..\..\..\loc_test_data\additonal_data.mat')

%% divide data into testing and training
testID = [];
add_to_trainID = setdiff(1:17,testID);

actual_coor_data = [actual_coor_data; actual_coor_data_add(add_to_trainID,:)];
t_arri_indx_data = [t_arri_indx_data, t_arri_indx_data_add(:,add_to_trainID)];

actual_coor_data_test_raw = actual_coor_data_add(testID,:);
t_arri_indx_data_test_raw = t_arri_indx_data_add(:,testID);

actual_coor_data_repeat = [AE_location(18,:);...
                           AE_location(18,:);...
                           AE_location(18,:);...
                           AE_location(18,:);...
                           AE_location(35,:);...
                           AE_location(35,:);...
                           AE_location(35,:);...
                           AE_location(35,:)];
t_arri_indx_data_repeat_raw = picks(:,[19:22,40:43]);

N1 = length(t_arri_indx_data(1,:));
N2 = length(t_arri_indx_data_test_raw(1,:));
N3 = length(t_arri_indx_data_repeat_raw(1,:));

% figure
% hold on
% [xsp,ysp,zsp] = sphere(20);
% for i = 1:N1
%     r = 2;
%     s1 = surf(xsp*r+actual_coor_data(i,1)-r/2,ysp*r+actual_coor_data(i,2)-r/2,zsp*r+actual_coor_data(i,3)-r/2,'EdgeColor','none');
%     set(s1,'facecolor',[.98 .45 .02]);
% end
% for i = 1:N2
%     r = 2;
%     s1 = surf(xsp*r+actual_coor_data_test_raw(i,1)-r/2,ysp*r+actual_coor_data_test_raw(i,2)-r/2,zsp*r+actual_coor_data_test_raw(i,3)-r/2,'EdgeColor','none');
%     set(s1,'facecolor',[.1 .2 .2]);
% end
% camlight
% lighting gouraud

%% NOTE: 11 sensors are used b/c sensor 16 was broken
for i = 1:N1
    t_arri_indx_train(1:11,i) = t_arri_indx_data(1:11,i) - t_arri_indx_data(1,i); % arrival time difference
end
actual_coor_train = actual_coor_data(:,[1,3])';

for i = 1:N2
    t_arri_indx_data_test(1:11,i) = t_arri_indx_data_test_raw(1:11,i) - t_arri_indx_data_test_raw(1,i); % arrival time difference
end
actual_coor_data_test = actual_coor_data_test_raw(:,[1,3])';

for i = 1:N3
    t_arri_indx_data_repeat(1:11,i) = t_arri_indx_data_repeat_raw(1:11,i) - t_arri_indx_data_repeat_raw(1,i); % arrival time difference
end
actual_coor_data_repeat = actual_coor_data_repeat(:,[1,3])';
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

% Deploy
pk = input('Deploy the new model? Y/N [N]:','s');
if isempty(pk), pk = 'n'; end
if pk == 'y' || pk == 'Y'
    save('AErelocNet_Gen_2D.mat','nets')
    copyfile AErelocNet_2D_Gen.mat ..\..\..\MATLAB_code\AE_relocation\AErelocNet_2D_Gen_Deploy.mat
    copyfile AErelocNet_2D_Gen.mat AErelocNet_2D_Gen_Deploy.mat
end

