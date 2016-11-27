clear all
clc
format shortEng

%% parameters
rm = 1.5e-2;    % mic radius
rs = 120e-2;     % sound source radius
c = 340;        % speed of sound
ar = 1; %360/64;    % angle resolution


%% calculation
phi = (ar:ar:360)';
% angle and position of mics
phim = [cos(2*pi/3); sin(2*pi/3)];
m = [rm  0 ;
    rm * [cos(2*pi/3) sin(2*pi/3)];
    rm * [cos(2*pi/3) -sin(2*pi/3)]];
% angle and source poisitions
phis = [cos(phi * pi/(180)) sin(phi * pi/(180))];
p = rs * phis;

% distance and differences
dm01 = m(2,:)-m(1,:);   % distance vector from mic0 to mic1
dm02 = m(3,:)-m(1,:);   % distance vector from mic0 to mic2

% tau
tau01 = dm01 * p'; % distance vector projected on location vector of source
tau02 = dm02 * p'; % for |p| >> |dm| !!

% recalculate angle
phi_rec = atan2(tau02, tau01)*180/pi + 135; % 135° angle offset

% [-180..180] => [0..360]
for i = 1:length(phi_rec)
    if(phi_rec(i) <= 0)
        phi_rec(i) = phi_rec(i) + 360;
    end
end
% error and compensation
phi_rec = phi_rec + 15*sin(2*pi/180*phi_rec) + 2.2*sin(4*pi/180*phi_rec);
phi_rec_error = phi_rec - phi';
% phi_rec = phi_rec + 15*sin(pi/180*phi_rec);

% phi_rec_error = phi_rec - phi' + 15*sin(2*2*pi/360*phi_rec);

%% plot
subplot(2,2,1)
plot(m(:,1), m(:,2), 'ro', p(:,1), p(:,2), 'b.')
grid on
title('Mic and Sound Source Positions'); 
xlabel('[m]'); ylabel('[m]');
axis([-rs rs -rs rs]);

subplot(2,2,2)
plot(phi, tau01, 'rx', phi, tau02, 'gx')
grid on
legend tau01 tau02
xlabel('[grad]'); ylabel('[m]');

subplot(2,2,3)
plot(phi, phi_rec)
grid on
title('recalculated angle')
xlabel('[grad]'); ylabel('[grad]');

subplot(2,2,4)
plot(phi,phi_rec_error)
grid on
title('compensated angle error')
xlabel('[grad]'); ylabel('[grad]');