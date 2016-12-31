clear all
clc
format shortEng

%% Import data from text file.
filename = 'E:\git\SoundLoc\Roy\Matlab\std_out.log';
fileID = fopen(filename,'r');

try
    data = fread(fileID,'int16');
%     dataArray = textscan(fileID, '%f%f%f%[^\n\r]', 'Delimiter', ',',  'ReturnOnError', false);
catch
end
fclose(fileID);
%%
data = data(1:floor(length(data)/3)*3);
data = reshape(data,3, [])';
mic1_r = data(:,1);
mic2_r = data(:,2);
mic3_r = data(:,3);

% mic1_r = dataArray{:, 1};
% mic2_r = dataArray{:, 2};
% mic3_r = dataArray{:, 3};

%% paramter
decim = 70;
c = 340; % speed of sound in m/s (set to 1 for delay in sec)
pTau = 50; % plot samples of corr
N = length(mic1_r);
Ts = decim/(100e6/32);
t = (1:N) * Ts;

% mic1 = upsample(mic1_r, upsampling);
% mic2 = upsample(mic2_r, upsampling);
% mic3 = upsample(mic3_r, upsampling);
mic1 = mic1_r;
mic2 = mic2_r;
mic3 = mic3_r;

f = (-N/2:N/2-1)/(Ts*N);
MIC1 = fftshift(fft(mic1,N));

cor12 = xcorr(mic1, mic2);
cor13 = xcorr(mic1, mic3);

cor12 = cor12(N-pTau:N+pTau)' - mean(cor12(N-pTau:N+pTau));
cor13 = cor13(N-pTau:N+pTau)' - mean(cor13(N-pTau:N+pTau));

% finde tau
[~, tau01] = max(cor12); tau01 = (tau01-pTau-1)*Ts*c;
[~, tau02] = max(cor13); tau02 = (tau02-pTau-1)*Ts*c;

angle = atan2(tau01, tau02)*180/pi + 135

tau = -pTau:pTau;
figure(1)
plot(t, mic1, 'r', t,  mic2, 'g', t,  mic3, 'b');
grid on
legend('mic1', 'mic2', 'mic3')
figure(2)
plot(tau, cor12, 'rx-', tau,  cor13, 'gx-');
grid on
legend('corr12', 'corr13');

figure(3)
plot(f, db(abs(MIC1)))
grid on
legend FFT(mic1)
