function [trainingData,actual_coor_data_repeat,t_arri_indx_data_repeat,t_arri_indx_train,actual_coor_train] = load_training_data

% data for training
load('..\..\..\loc_test_data\AE_on_fault_data\pick_data_picking_update.mat')
load('..\..\..\loc_test_data\AE_on_fault_data\AE_locations.mat')
actual_coor_data = AE_location(1:39,:);
t_arri_indx_data = [picks(:,[1:18,23:39,44:47])];
% additional data
load('..\..\..\loc_test_data\additonal_data.mat')
% divide data into testing and training
% testID = [];
% add_to_trainID = setdiff(1:17,testID);

actual_coor_data = [actual_coor_data; actual_coor_data_add];
t_arri_indx_data = [t_arri_indx_data, t_arri_indx_data_add];

% actual_coor_data_test_raw = actual_coor_data_add(testID,:);
% t_arri_indx_data_test_raw = t_arri_indx_data_add(:,testID);

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
N3 = length(t_arri_indx_data_repeat_raw(1,:));

% % % edge_clrs = 'none';
% % % face_clrs = {[.5 .5 .5],[43,131,186]./255,[215,25,28]./255};
% % % mksz = 5;
% % % L = 218;
% % % H = 200;
% % % fh = figure; % fault normal view
% % % set(fh, 'Position', [1620 600 550 450] );
% % % hold on
% % % box on
% % % axis equal
% % % set(gca,'TickDir','out');
% % % plot([0,sqrt((L)^2+(L)^2),sqrt((L)^2+(L)^2),0,0],[0,0,H,H,0],'b-','LineWidth',2)
% % % plot([sqrt(2)*L/2-75,sqrt(2)*L/2,sqrt(2)*L/2,sqrt(2)*L/2-75,sqrt(2)*L/2-75],[H-16,H-16,H,H,H-16],'b-','LineWidth',2)
% % % text(1,207,'SW')
% % % text(291,207,'NE')
% % % grid on
% % % grid minor
% % % for i = 1:N1
% % %         x_on_fault = (L+actual_coor_data(i,1)-actual_coor_data(i,2))/2;
% % %         dist_on_fault = sqrt(2)*(L-x_on_fault);
% % %         plot(dist_on_fault,actual_coor_data(i,3),'ro','markerfacecolor',face_clrs{1},'markerEdgecolor','none','MarkerSize',mksz,'Linewidth',1.5)
% % % %         text(dist_on_fault+2.5,actual_coor_data(i,3),num2str(i),'FontSize',10)
% % % end
% % % for i = 1:N3
% % %         x_on_fault = (L+actual_coor_data_repeat(i,1)-actual_coor_data_repeat(i,2))/2;
% % %         dist_on_fault = sqrt(2)*(L-x_on_fault);
% % %         plot(dist_on_fault,actual_coor_data_repeat(i,3),'bo','markerfacecolor','none','markerEdgecolor',face_clrs{3},'MarkerSize',mksz+1,'Linewidth',1.5)
% % % end
% % % xlabel('Fault axis, x (mm)')
% % % ylabel('Height, z (mm)')


% NOTE: 11 sensors are used b/c sensor 16 was broken
for i = 1:N1
    t_arri_indx_train(1:11,i) = t_arri_indx_data(1:11,i) - t_arri_indx_data(1,i); % arrival time difference
end
actual_coor_train = actual_coor_data(:,[1,3])';

% for i = 1:N2
%     t_arri_indx_data_test(1:11,i) = t_arri_indx_data_test_raw(1:11,i) - t_arri_indx_data_test_raw(1,i); % arrival time difference
% end
% actual_coor_data_test = actual_coor_data_test_raw(:,[1,3])';

for i = 1:N3
    t_arri_indx_data_repeat(1:11,i) = t_arri_indx_data_repeat_raw(1:11,i) - t_arri_indx_data_repeat_raw(1,i); % arrival time difference
end
actual_coor_data_repeat = actual_coor_data_repeat(:,[1,3])';

trainingData = [t_arri_indx_train;actual_coor_train];