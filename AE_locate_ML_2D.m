% slip test AE events relocation with machine learning

%% ========================================================================
%  z (mm)
%        ^
%        |     o
%    200 +     o   oo  o     o            o  o
%        |       o    o     o
%    150 +                                o    o
%        |             o     o
%    100 +              o   o     o     o   o
%        |                o    o    o   o   o
%     50 +                      o o     o     o
%        |    
%      0 X-----+-----+-----+-----+-----+-----+----->
%        0     50   100   150   200   250   300   350   
%                           Fault axis (mm)
%% ========================================================================

clear all
close all
clear output
clc

L = 218;
H = 200;

face_clrs = {'none','none','none','none'};
% edge_clrs = {[0 .5 1],[1 .4 .2],[0 .8 .4],[.8 .2 .6],[1 .6 .2]};
edge_clrs = {[1 .4 .2],[1 .4 .2],[1 .4 .2]};
% edge_clrs = {[253,174,97]./255,[255,255,191]./255,[171,221,164]./255,[43,131,186]./255,[215,25,28]./255};

mksz = 5;

load('AE_test_arrivals.mat')

load('AErelocNet_2D_Deploy.mat');
numNN = length(nets);
N = length(t_arri_indx);
disp(['--> Relocating ' num2str(N) ' events <--'])

netinput = t_arri_indx(:,:)-t_arri_indx(1,:);
  
    %% one net
%     output = AErelocNet_Deploy(netinput);
    
    %% generalized nets 3D
%     outTotal = 0;
%     for ii = 1:numNN
%       neti = nets{ii};
%       out = neti(netinput);
%       outTotal = outTotal + out;
%     end
%     output = outTotal / numNN;

    %% generalized nets 2D
    outTotal = 0;
    for ii = 1:numNN
      neti = nets{ii};
      out = neti(netinput);
      outTotal = outTotal + out;
    end
    output = outTotal / numNN;

    output(3,:) = output(2,:);
    output(2,:) = L - output(1,:);
    

    plotonfault(output(1,:),output(3,:))

 %% print
print(figure(1),'-djpeg','-r300','./fault_surf_impose_ANN.jpg');