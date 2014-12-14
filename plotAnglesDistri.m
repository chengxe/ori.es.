
% clear all
% load nonortho\trajectories.mat
% noTraj = trajectories; clear trajectories;
% load ortho\trajectories.mat
% oTraj = trajectories; clear trajectories;
% 
% angles1 = []; angles2 = []; angles3 = [];
% for i = 1:size(oTraj, 2)
%     traj = oTraj(i);
%     
%     for n = 1 : size(traj.vel, 2)
%         dVel = traj.vel(:,n); dOri = traj.ori(:,n); dRec = traj.rec(:,n);
%         
%         angle = acos( unit(dVel)' * unit(dOri) ); angle = angle * 180 / pi;
%         angles1 = [ angles1, angle];
%         
%         angle = acos( unit(dRec)' * unit(dOri) ); angle = angle * 180 / pi;
%         angles2 = [ angles2, angle];
%     end
% end
% for i = 1:size(noTraj, 2)
%     traj = noTraj(i);
%     
%     for n = 1 : size(traj.vel, 2)
%         dOri = traj.ori(:,n); dRec = traj.rec(:,n);
%         
%         angle = acos( unit(dRec)' * unit(dOri) ); angle = angle * 180 / pi;
%         angles3 = [ angles3, angle];
%     end
% end
% return;

figure1 = figure(1);  clf; set(gcf,'Position',[300,10,800,700]); grid on; hold on;
bins = linspace(0, 180, 181);

%----------------------------------------------------------------------------
[n ,~] = hist(angles1, bins);
normalized_n = n / sum(n);
x = bins; y = normalized_n; 
% h1 = plot(x, y, '-r', 'linewidth',2);
cdf = min(cumsum(normalized_n), 1); 
h1 = plot(x, cdf, '-r', 'linewidth',2);

%----------------------------------------------------------------------------
[n ,~] = hist(angles2, bins);
normalized_n = n / sum(n);
x = bins; y = normalized_n; 
% h2 = plot(x, y, '-r', 'linewidth',2);
cdf = min(cumsum(normalized_n), 1); 
h2 = plot(x, cdf, '-g', 'linewidth',2); 

%----------------------------------------------------------------------------
[n ,~] = hist(angles3, bins);
normalized_n = n / sum(n);
x = bins; y = normalized_n; 
% h3 = plot(x, y, '-r', 'linewidth',2);
cdf = min(cumsum(normalized_n), 1); 
h3 = plot(x, cdf, '-b', 'linewidth',2);

%plot2([0,0.99;180,0.99], '--k');
plot(124,0,'*r',  'linewidth', 2, 'markersize', 10);  plot(2,0,'*g', 'linewidth', 2,  'markersize', 10);  plot(5,0,'*b',  'linewidth', 2, 'markersize', 10); 

%%
hl = legend([h1,h2,h3], 'motion', 'orthogonal cameras', 'non-orthogonal cameras');
set(hl, 'fontsize', 20);
set(gca, 'XMinorGrid', 'on'); %set(gca, 'XMinorTick', 'on');
set(gca, 'YMinorGrid', 'on');
axis([0,180,0,1]);


set(gca, 'fontsize', 16);
xlabel('angle (degree)', 'fontsize', 20);
ylabel('probability', 'fontsize',20);
set(gca, 'Units', 'normalized', 'Position', [0.08 0.08 0.9000 0.890]);    

%%
set(hl,...
    'Position',[0.611041666666666 0.653095238095238 0.28125 0.155238095238095],...
    'FontSize',20);

% Create textbox
annotation(figure1,'textbox',...
    [0.76875 0.141857142857143 0.09625 0.0957142857142857],'String',{'(a)'},...
    'FontSize',36,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'LineStyle','none');