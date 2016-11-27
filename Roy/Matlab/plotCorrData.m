clear all
clc
format shortEng


%% Import data from text file.
filename = 'E:\git\SoundLoc\Roy\SDK\src\log.txt';
fileID = fopen(filename,'r');
try
dataArray = textscan(fileID, '%f%f%[^\n\r]', 'Delimiter', ',',  'ReturnOnError', false);
catch
end
fclose(fileID);

%% Parameter
TAU_ADDR_WIDTH = 5;
decim = 40;
sample = 250;  
% whicht sample to plot in detail

%% calculation
Ts = decim/2.5e6;
TAU_CNT = 2^TAU_ADDR_WIDTH - 1;


tau = (-2^(TAU_ADDR_WIDTH-1)+1):(2^(TAU_ADDR_WIDTH-1)-1);

tau01 = dataArray{:, 1};
tau02 = dataArray{:, 2};

tau01 = reshape(tau01, TAU_CNT, [])';
tau02 = reshape(tau02, TAU_CNT, [])';

subplot(2,2,1); mesh(tau01); grid on;
subplot(2,2,2); mesh(tau02); grid on;
subplot(2,2,3:4); plot(tau, tau01(sample,:), 'bx', tau, tau02(sample,:), 'rx');
legend('tau01', 'tau02')
grid on