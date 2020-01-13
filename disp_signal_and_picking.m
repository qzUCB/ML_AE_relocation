load('AE_signal_data.mat')

eventID = 1; % choose training event ID to show [1,56]

for k = eventID % you can loop from 1 to 56
    fh=figure(1);
    screen_size = get(0, 'ScreenSize');
    set(fh, 'Position', [100 50 screen_size(3)-200 screen_size(4)-130]);
    for i = 1:12 % channel ID from 1 to 12
        subplot(3,4,i)
        t_arri = arrival(k).pickings(i); % arrival time
        s = event(k).signal(i,:); % signal at 40 MHz
        
        plot(s,'k.-')
        hold on
        yl = ylim;
        plot([t_arri,t_arri],[yl(1),yl(2)],'r--')
        grid on
    end
end