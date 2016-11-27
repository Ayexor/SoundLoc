clear all
clc
format shortEng


%% Import data from text file.
filename = 'E:\git\SoundLoc\Vivado\SoundLoc.sdk\soundLoc\log.txt';
fileID = fopen(filename,'r');
try
dataArray = textscan(fileID, '%f%f%[^\n\r]', 'Delimiter', ',',  'ReturnOnError', false);
catch
end
fclose(fileID);

MAX_TAU = 16;
decim = 40;
Ts = decim/100e6;

sample = 1;

tau = (1:MAX_TAU) - MAX_TAU/2;

tau01 = dataArray{:, 1};
tau02 = dataArray{:, 2};

tau01 = reshape(tau01, MAX_TAU, [])';
tau02 = reshape(tau02, MAX_TAU, [])';

subplot(1,2,1); mesh(tau01); subplot(1,2,2); mesh(tau02);

% plot(tau, tau01(sample,:), tau, tau02(sample,:), 'r');
% legend('tau01', 'tau02')
grid on