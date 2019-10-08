% data preparation for AE relocation using machine learning
clear all;
close all;
clc

numNN = 50;
MaxEpochs = 100;
numNeuronList = {[2],[4],[6],[8],[10],[12],[14],[16],[6,6],[8,8]};


clr = viridis(length(numNeuronList));
for iii = 1:10
    
    numNeuron = numNeuronList{iii};

%% data for training
load('..\..\..\loc_test_data\AE_on_fault_data\pick_data_picking_update.mat')
load('..\..\..\loc_test_data\AE_on_fault_data\AE_locations.mat')

actual_coor_data = AE_location(1:39,:);
t_arri_indx_data = [AIC_picks(:,[1:18,23:39,44:47])];

%% try add perturbation
% p = 0.5; %  mm
% pterb = rand(39,2).*p;
%% additional data
actual_coor_data_add = [50, 168, 40;...
                        50, 168,  160;...
                        118, 100, 40;...
                        118, 100, 160;...
                        109, 109, 40;...
                        168, 50,  160;...
                        168, 50,  80;...
                        168, 50,  40;...
                        118, 100, 80;...
                        50,  168, 80;...
                        109, 109, 80;...
                        109, 109, 160;...
                        110, 108, 70;...
                        110, 108, 50;...
                        110, 108, 30;...
                        110, 108, 10;...
                        105, 110, 57
                        ];
t_arri_indx_data_add = [
                        [627733,627649,627718,627454,627199,627466,627026,626781,626465,627028,626401,626103]',... 
                        [631184,630853,630732,630816,631037,631002,630366,629840,630146,629531,629741,630385]',... 
                        [620103,620237,620573,620235,620010,619899,620328,620429,620169,620882,620553,620499]',... 
                        [630096,629911,630122,630239,630512,630141,630300,630127,630350,630264,630387,630668]',... 
                        [629273,629427,629721,629405,629217,629145,629420,629466,629201,629794,629452,629285]',... 
                        [626220,626423,626860,626961,627216,626699,627428,627505,627641,627804,627901,628155]',...
                        [628941,629389,629979,629792,629689,629237,630260,630481,630352,630850,630659,630638]',...
                        [626104,626585,627104,626870,626636,626233,627317,627469,627371,628106,627713,627592]',... 
                        [620284,620307,620630,620474,620421,620224,620556,620606,620446,620821,620682,620618]',... 
                        [627921,627702,627723,627632,627590,627655,627179,626770,626640,626768,626416,626387]',... 
                        [630124,630083,630348,630152,630135,629980,630160,630114,630027,630402,630191,630255]',... 
                        [630164,629938,630040,630150,630425,630151,630169,630027,630241,630136,630261,630523]',...
                        [1001252,1001379,1001609,1001378,1001319,1001907,1001394,1001412,1001249,1001695,1001431,1001394]',...
                        [1029872,1029919,1030202,1029930,1029764,1030466,1030032,1030045,1029843,1030325,1030063,1029936]',...
                        [1001492,1001686,1001949,1001647,1001404,1002125,1001647,1001707,1001437,1002004,1001648,1001477]',...
                        [1047578,1047753,1048088,1047754,1047477,1047571,1047788,1047882,1047545,1048192,1047815,1047547]',...
                        [630428,630437,630644,630350,630187,630170,630305,630310,630062,630598,630285,630104]'
                        ];

%% divide data into testing and training
testID = [2,3,4,5,11,12];
add_to_trainID = [1,6,7,8,9,10,13,14,15,16,17];
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
t_arri_indx_data_repeat_raw = AIC_picks(:,[19:22,40:43]);

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
net = fitnet(numNeuron,trainFcn);
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
perfs{iii} = zeros(1, numNN);
y2Total = 0;

for i = 1:numNN
  neti = nets{i};
  out = neti(t_arri_indx_data_test);
  perfs{iii}(i) = mse(neti, actual_coor_data_test, out);
  y2Total = y2Total + out;
end
perfs{iii}
perfs_mean(iii) = mean(perfs{iii})
figure(1)
hold on
plot(perfs{iii},'ko-','color',clr(iii,:),'MarkerFace',clr(iii,:),'MarkerSize',3)
box on
set(gca,'TickDir','out');
xlabel('Nets')
ylabel('Normalized MSE')

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

perfs_repeat{iii} = zeros(1, numNN);
y2Total_repeat = 0;
for i = 1:numNN
  neti = nets{i};
  out_repeat = neti(t_arri_indx_data_repeat);
  perfs_repeat{iii}(i) = mse(neti, actual_coor_data_repeat, out_repeat);
  y2Total_repeat = y2Total_repeat + out_repeat;
end
perfs_repeat{iii}
perfs_repeat_mean(iii) = mean(perfs_repeat{iii})

figure(2)
hold on
plot(perfs_repeat{iii},'bo-','color',clr(iii,:),'MarkerFace',clr(iii,:),'MarkerSize',3)
box on
set(gca,'TickDir','out');
xlabel('Nets')
ylabel('Normalized MSE')

legendInfo{iii} = [num2str(numNeuron)]; 

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

figure(1)
axP = get(gca,'Position'); 
hl = legend(legendInfo,'Location','NorthEastOutside');
title(hl,'Neurons')
% set(gca, 'Position', axP)

figure(2)
axP = get(gca,'Position'); 
hl = legend(legendInfo,'Location','NorthEastOutside');
title(hl,'Neurons')
% set(gca, 'Position', axP)


return

print(figure(1),'-dpng','-r300','./neuron_num_test_total_error.png');
print(figure(2),'-dpng','-r300','./neuron_num_test_rept_error.png');

save('neuron_num_test_total_error.mat','perfs','perfs_mean')
save('neuron_num_test_rept_error.mat','perfs_repeat','perfs_repeat_mean')