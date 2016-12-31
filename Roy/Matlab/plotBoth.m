clear all
clc
format shortEng


%% Import data from text file.
filename = 'E:\git\SoundLoc\Roy\Matlab\std_out.log';
fileID = fopen(filename,'r');
try
dataArray = textscan(fileID, '%f%f%f%f%f%[^\n\r]', 'Delimiter', ',',  'ReturnOnError', false, 'HeaderLines', 1);
catch
end
fclose(fileID);

%% Parameter
decim = 30;
% whicht sample to plot in detail

%% calculation
Ts = decim/(100e6/32);

% a = sinc(-2*pi:0.1:2*pi);
a = ones(1,1);
b = [1];
a = a/sum(a);

mic0 = dataArray{:, 1};
mic1 = dataArray{:, 2};
mic2 = dataArray{:, 3};
tau01 = dataArray{:, 4};
tau02 = dataArray{:, 5};
N = 1:length(tau01);

tau01f = filter(a, b, tau01);
tau02f = filter(a, b, tau02);
n = 1:length(tau01f);

subplot(2,2,1)
plot(N, mic0, N, mic1, N, mic2)
legend('mic0', 'mic1', 'mic2')
grid on

subplot(2,2,2)
plot(n, tau01f, n, tau02f)
legend('tau01', 'tau02')
grid on

subplot(2,2,3)
plot(n, tau01f, n, tau02f)
legend('tau01f', 'tau02f')
grid on
