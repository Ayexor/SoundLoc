clear all
clc
format shortEng


%% Import data from text file.
filename = 'E:\git\SoundLoc\Roy\Matlab\std_out.log';
fileID = fopen(filename,'r');
try
dataArray = textscan(fileID, '%f%f%[^\n\r]', 'Delimiter', ',',  'ReturnOnError', false);
catch
end
fclose(fileID);

%% Parameter
TAU_ADDR_WIDTH = 6;
decim = 30;
sample = 250;  
% whicht sample to plot in detail

%% calculation
Ts = decim/(100e6/32);

a = sinc(-4*pi:0.005:4*pi);
b = [1];
a = a/sum(a);

tau01 = dataArray{:, 1};
tau02 = dataArray{:, 2};
N = length(tau01);

tau01f = filter(a, b, tau01);
tau02f = filter(a, b, tau02);
n = length(tau01f)

subplot(2,1,1)
plot(1:N, tau01, 1:N, tau02)
legend('tau01', 'tau02')
grid on

subplot(2,1,2)
plot(1:n, tau01f, 1:n, tau02f)
legend('tau01f', 'tau02f')
grid on
