%% ================ test perturbed arrival time ===========================
close all

[trainingData,actual_coor_data_repeat,t_arri_indx_data_repeat,t_arri_indx_train,actual_coor_train] = load_training_data;

% add perturbation to arrival picking
pt = 3; % microsecond
% NOTE: result may vary depends on the randomly generated purturbation. The overall trend should be the same.
if pt == 0
    t_arri_indx_data_repeat_peturb(2:11,:) = t_arri_indx_data_repeat(2:11,:);
    t_arri_indx_train_peturb(2:11,:) = t_arri_indx_train(2:11,:);
else
    pterb = randi(round(pt*40),10,8)-round(pt*40)/2;
    % t_arri_indx_data_test_peturb = t_arri_indx_data_test;
    % t_arri_indx_data_test_peturb(2:11,:) = pterb(1:10,:)+t_arri_indx_data_test_peturb(2:11,:);
    t_arri_indx_data_repeat_peturb =t_arri_indx_data_repeat;
    t_arri_indx_data_repeat_peturb(2:11,:) = pterb(1:10,:)+t_arri_indx_data_repeat_peturb(2:11,:);
    pterb = randi(round(pt*40),10,56)-round(pt*40)/2;
    t_arri_indx_train_peturb =t_arri_indx_train;
    t_arri_indx_train_peturb(2:11,:) = pterb(1:10,:)+t_arri_indx_train_peturb(2:11,:);
end
load('C:\experiment\software\AE_MATLAB_code\AE_relocation\ML_AE_relocation\AErelocNet_2D_Deploy.mat');
numNets = length(nets);
perfs = zeros(1, numNets);
y2Total = 0;

% for i = 1:numNets
%   neti = nets{i};
%   out_test = neti(t_arri_indx_data_test_peturb);
%   perfs(i) = mse(neti, actual_coor_data_test, out_test);
%   y2Total = y2Total + out_test;
% end
% % perfs
% 
% outAvg = y2Total / numNets;
% % perfAvg = mse(nets{1}, actual_coor_data_test, outAvg);
% 
% errs  = abs(outAvg-actual_coor_data_test);
% x_err = errs(1,:);
% z_err = errs(2,:);
% disp('------------------- Errors --------------------')
% disp('       Mean       Max        Min')
% disp(['x   ' num2str([mean(x_err),max(x_err),min(x_err)])])
% disp(['z   ' num2str([mean(z_err),max(z_err),min(z_err)])])
% disp('-----------------------------------------------')
%                                 
% for i = 1:N2
%     x_on_fault = (L+outAvg(1,i)-(L-outAvg(1,i)))/2;
%     dist_on_fault = sqrt(2)*(L-x_on_fault);
%     plot(dist_on_fault,outAvg(2,i),'bs','markerfacecolor','none','markerEdgecolor','k','MarkerSize',mksz+1,'Linewidth',1.5)
% %     text(dist_on_fault+2.5,outAvg(2,i),num2str(i),'FontSize',10)
% end

perfs_repeat = zeros(1, numNets);
y2Total_repeat = 0;
for i = 1:numNets
  neti = nets{i};
  out_repeat = neti(t_arri_indx_data_repeat_peturb);
  perfs_repeat(i) = mse(neti, actual_coor_data_repeat, out_repeat);
  y2Total_repeat = y2Total_repeat + out_repeat;
end
% perfs_repeat

outAvg_repeat = y2Total_repeat / numNets;
% perfAvg_repeat = mse(nets{1}, actual_coor_data_repeat, outAvg_repeat);

errs_repeat  = abs(outAvg_repeat-actual_coor_data_repeat);
x_err_repeat = errs_repeat(1,:);
z_err_repeat = errs_repeat(2,:);
disp('------------- Repeatability Errors --------------')
disp('       Mean       Max        Min')
disp(['x   ' num2str([mean(x_err_repeat),max(x_err_repeat),min(x_err_repeat)])])
disp(['z   ' num2str([mean(z_err_repeat),max(z_err_repeat),min(z_err_repeat)])])
disp('-------------------------------------------------')

% for i = 1:N3
%     x_on_fault = (L+outAvg_repeat(1,i)-(L-outAvg_repeat(1,i)))/2;
%     dist_on_fault = sqrt(2)*(L-x_on_fault);
%     plot(dist_on_fault,outAvg_repeat(2,i),'ko','markerfacecolor','none','markerEdgecolor','k','MarkerSize',mksz+1,'Linewidth',1.5)
% %     text(dist_on_fault+2.5,outAvg_repeat(2,i),num2str(i),'FontSize',10)
% end

%% plot fitting results
perfs_all_x = zeros(1, numNets);
perfs_all_z = zeros(1, numNets);

y2Total = 0;

for i = 1:numNets
  neti = nets{i};
  out_all = neti(t_arri_indx_train_peturb);
  perfs_all_x(i) = sqrt(sum((actual_coor_train(1,:)-out_all(1,:)).^2)/length(t_arri_indx_train));
  perfs_all_z(i) = sqrt(sum((actual_coor_train(2,:)-out_all(2,:)).^2)/length(t_arri_indx_train));
  y2Total = y2Total + out_all;
end
% perfs_all
outAvg_all = y2Total / numNets;

perfAvg_all_x = sqrt(sum((actual_coor_train(1,:)-outAvg_all(1,:)).^2)/length(t_arri_indx_train));
perfAvg_all_z = sqrt(sum((actual_coor_train(2,:)-outAvg_all(2,:)).^2)/length(t_arri_indx_train));

% figure(10)
% hold on
% plot(1:numNets,perfs_all_x,'ko-','MarkerSize',5,'markerfacecolor','w','markerEdgecolor','k')
% plot(1:numNets,perfs_all_z,'ko-','MarkerSize',5,'markerfacecolor',[.5 .5 .5],'markerEdgecolor','k')
% plot(1:numNets,ones(1,numNets)*perfAvg_all_x,'k--','color','k','Linewidth',2)
% plot(1:numNets,ones(1,numNets)*perfAvg_all_z,'k:','color',[.5 .5 .5],'Linewidth',2)
% box on
% xlabel('Nets');
% ylabel('RMSE (mm)');
% legend('x single net','z single net','x generalized','z generalized')

face_clrs = {[.5 .5 .5],[43,131,186]./255,[215,25,28]./255};
edge_clrs = 'none';
L = 218;
H = 200;
mksz = 5;

x_on_fault = (L+outAvg_all(1,:)-(L-outAvg_all(1,:)))/2;
dist_on_fault = sqrt(2)*(L-x_on_fault);

x_on_fault_train = (L+actual_coor_train(1,:)-(L-actual_coor_train(1,:)))/2;
dist_on_fault_train = sqrt(2)*(L-x_on_fault_train);

figure(11)
hold on
plot([0,300],[0,300],'k:','LineWidth',2)
plot(dist_on_fault_train,dist_on_fault,'ko','markerfacecolor',face_clrs{1},'markerEdgecolor',edge_clrs,'MarkerSize',mksz,'Linewidth',1.5)
% plot(actual_coor_data_test(1,:),out_test(1,:),'bs','markerfacecolor','none','markerEdgecolor','k','MarkerSize',mksz+1,'Linewidth',1.5)
% plot(actual_coor_data_repeat(1,:),out_repeat(1,:),'ko','markerfacecolor','none','markerEdgecolor','k','MarkerSize',mksz+1,'Linewidth',1.5)
box on
axis square
legend('Target:Output = 1:1','Training points','Testing output','Repeatability testing output','Location','SouthEast')
ylabel('Model output x (mm)');
xlabel('Training data x (mm)');

% confidance interval
xdata = dist_on_fault_train;
ydata = dist_on_fault;
[p,S] = polyfit(xdata,ydata,1);
xRS = 1 - (S.normr/norm(ydata - mean(ydata)))^2
% Compute the real roots and determine the extent of the data.
r = roots(p)'; % Roots as a row vector.
real_r = r(imag(r) == 0); 	% Real roots.
% Assure that the data are row vectors.
xdata = reshape(xdata,1,length(xdata));
ydata = reshape(ydata,1,length(ydata));
% Extent of the data.
mx = min([real_r,xdata]);
Mx = max([real_r,xdata]);
my = min([ydata,0]);
My = max([ydata,0]);
% Scale factors for plotting.
sx = 0.05*(Mx-mx);
sy = 0.05*(My-my);

% Plot the data, the fit, and the roots.
xfit = mx-sx:0.1:Mx+sx;
yfit = polyval(p,xfit);
% hfit = plot(xfit,yfit,'b-','LineWidth',2);
axis([0 300 0 300])
% Add prediction intervals to the plot.
[Y,DELTA] = polyconf(p,xfit,S,'alpha',0.5);
hconf = plot(xfit,Y+DELTA,'b-');
plot(xfit,Y-DELTA,'b-')

% plot as area
% h = fill([xfit fliplr(xfit)],[Y+DELTA fliplr(Y-DELTA)],'b');
% set(h,'facealpha',.5)

figure(12)
hold on
plot([0,200],[0,200],'k:','LineWidth',2)
plot(actual_coor_train(2,:),outAvg_all(2,:),'ko','markerfacecolor',face_clrs{1},'markerEdgecolor',edge_clrs,'MarkerSize',mksz,'Linewidth',1.5)
% plot(actual_coor_data_test(2,:),out_test(2,:),'bs','markerfacecolor','none','markerEdgecolor','k','MarkerSize',mksz+1,'Linewidth',1.5)
% plot(actual_coor_data_repeat(2,:),out_repeat(2,:),'ko','markerfacecolor','none','markerEdgecolor','k','MarkerSize',mksz+1,'Linewidth',1.5)
box on
axis square
ylabel('Model output z (mm)');
xlabel('Training data z (mm)');
legend('Target:Output = 1:1','Training points','Testing output','Repeatability testing output','Location','SouthEast')

% confidance interval
xdata = actual_coor_train(2,:);
ydata = outAvg_all(2,:);
[p,S] = polyfit(xdata,ydata,1);
zRS = 1 - (S.normr/norm(ydata - mean(ydata)))^2
% Compute the real roots and determine the extent of the data.
r = roots(p)'; % Roots as a row vector.
real_r = r(imag(r) == 0); 	% Real roots.
% Assure that the data are row vectors.
xdata = reshape(xdata,1,length(xdata));
ydata = reshape(ydata,1,length(ydata));
% Extent of the data.
mx = min([real_r,xdata]);
Mx = max([real_r,xdata]);
my = min([ydata,0]);
My = max([ydata,0]);
% Scale factors for plotting.
sx = 0.05*(Mx-mx);
sy = 0.05*(My-my);

% Plot the data, the fit, and the roots.
xfit = mx-sx:0.1:Mx+sx;
yfit = polyval(p,xfit);
% hfit = plot(xfit,yfit,'b-','LineWidth',2);
axis([0 200 0 200])
% Add prediction intervals to the plot.
[Y,DELTA] = polyconf(p,xfit,S,'alpha',0.5);
hconf = plot(xfit,Y+DELTA,'b-');
plot(xfit,Y-DELTA,'b-')

%% print
print(figure(11),'-dpdf','-r300',['./training_ANN_x_perturb_' num2str(pt) '_us.pdf'])
print(figure(12),'-dpdf','-r300',['./training_ANN_z_perturb_' num2str(pt) '_us.pdf'])