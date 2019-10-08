function plotonfault(xpredict,zpredict)

% plot on fault
face_clrs = {'none','none','none','none'};
% edge_clrs = {[0 .5 1],[1 .4 .2],[0 .8 .4],[.8 .2 .6],[1 .6 .2]};
edge_clrs = {[1 .4 .2],[1 .4 .2],[1 .4 .2]};
mksz = 5;

L = 218;
H = 200;

output(3,:) = zpredict; % z
output(1,:) = xpredict; % x
output(2,:) = L - output(1,:); % y

%% plot

scle = 3;
fig = figure;
img = imread('D:\AE_rec\Granite_fault_AE\sample_after_slip_01_02_03_low_quality.jpg'); 
img2 = imresize(img, scle*[H round(sqrt(2)*L)]);
imshow(img2);
axis on
axis equal
hold on

N = length(xpredict);
for i = 1:N
    x_on_fault = scle*(L+output(1,i)-output(2,i))/2;
    dist_on_fault = sqrt(2)*(scle*L-x_on_fault);
    depth_on_fault = scle*H-scle*output(3,i);

        if i == 70 || i == 89
            plot(dist_on_fault,depth_on_fault,'gp','markerfacecolor',face_clrs{2},'markerEdgecolor','b','MarkerSize',6,'Linewidth',1.5)
        else
            plot(dist_on_fault,depth_on_fault,'go','markerfacecolor',face_clrs{2},'markerEdgecolor',edge_clrs{2},'MarkerSize',mksz,'Linewidth',1.5)
        end
%     text(dist_on_fault+dL/2+2.5,depth_on_fault,num2str(i),'FontSize',10)
end
ylim([1,scle*H])

xlabel('Fault axis, x (mm)')
ylabel('Height, z (mm)')
xticks([0,50,100,150,200,250,300]*scle)
xticklabels({'0','50','100','150','200','250','300'})
yticks([0,50,100,150,200]*scle)
yticklabels({'200','150','100','50','0'})