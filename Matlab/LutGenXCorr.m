clear all
clc
format shortEng

%% 0 : 4pi
N = 600;
A = 2^6; % Amplitude
% width = 16;%in bit

x = (0.5:(2*N+1)/(2*N):N)'/(N) .* 4*pi;

y = 0*A.*sin(x) + A*randn(N,1); %
% y = y .* 2^(width-1); % width-1 wegen signed, /1.5 um auf -1..1 zu normalisieren
y = floor(y)';
y = typecast(int16(y), 'int16)');
plot(x,y)

fprintf('const s16 sin_lut[%d] = {', N);
for i = 1:N-1
    fprintf('(s16)%d, ', y(i));
end
fprintf('(s16)%d};\n', y(N));