clear all
clc
format shortEng

N = 1024;
tau = -400;
En = 0.0; % Noise Energie
Ebg = 0.0;% Background (correlated noise)

%% Signale mit verschiebung
x = (4*(1:N)/(1*N)-1)*2;
% sig = sinc(x) + En*randn(1,N);
% sig = [zeros(1, N/2) ones(1,N/4) zeros(1, N/4)];
% sig = conv(sig(N/4:3*N/4), sig(N/4:3*N/4-1));
n = 5; % Anzahl oberwellen für Rechteck
sig = 1./(1:2:2*n)*sin((1:2:2*n)'*x) + Ebg*randn(1,N);

% sig = En*randn(1,N) + sig;


sigA = sig + En*randn(1,N);
if tau>=0 
    sigB = [zeros(1,tau) sig(1:N-tau)] + En*randn(1,N);
else %lag negativ
    sigB = [sig(-tau+1:N) zeros(1,-tau)] + En*randn(1,N);
end
%% Korrelation
% sigX_int(1) enthält den Wert, der neu dazukommt
% sigX_int(N+1) denjenigen Wert, der rausfällt
sigA_int = zeros(1,N+1); % Array, in dem die signale 
sigB_int = zeros(1,N+1); % intern durchgeschoben werden

corrAB = zeros(1,2*N-1); % Ausgangsvektor

tic
for sample = 1:N
    sigA_int = [sigA(N-sample+1) sigA_int(1:N)];
    sigB_int = [sigB(N-sample+1) sigB_int(1:N)];
    
    % 1     := tau = -N+1
    % N-1   := tau =  -1
    % tau < 0
    for idx = 1:N-1
        tau = idx-N;
        % negative verschiebung (bsp. tau= -2)
        % BSP:      tau = -4(=1-N)     tau = -2
        % sigA:          1 2 3 4 5        1 2 3 4 5
        % sigB:  1 2 3 4 5            1 2 3 4 5
        corrAB(idx) = corrAB(idx) + sigA_int(1)*sigB_int(1-tau) - sigA_int(N+1+tau)*sigB_int(N+1);
    end
    
    % N     := tau = 0
    corrAB(N) = corrAB(N) + sigA_int(1)*sigB_int(1) - sigA_int(N+1)*sigB_int(N+1);
    
    %  N+1  := tau = 1
    % 2N+1  := tau = N-1
    % tau > 0
    for tau = 1:N-1
        idx = N+tau;
        % negative verschiebung (bsp. tau= -2)
        % BSP:      tau = 2       tau = 4(=N-1)
        % sigA:  1 2 3 4 5        1 2 3 4 5
        % sigB:      1 2 3 4 5            1 2 3 4 5
        corrAB(idx) = corrAB(idx) + sigA_int(1+tau)*sigB_int(1) - sigA_int(N+1)*sigB_int(N+1-tau);
    end
    
end
toc
% corr mit matlab funktion
Xcorr = xcorr(sigA, sigB);
% Xcorr = Xcorr(N-1:2*N-2);

%Skallierung
D = std(sigA)*N;
% Xcorr = Xcorr/D; corrAB = corrAB / D;

%% plot für test
subplot(2,1,1)
plot(-N+1:N-1, corrAB, 'bx-', -N+1:N-1,  Xcorr, 'rx-', -N+1:N-1, 100/D*(corrAB - Xcorr))
grid on
legend('corrAB', 'XCorr', 'corrAB - XCorr [%]');
% ylim([-2000 2000])

subplot(2,1,2)
plot(x, sigA, x, sigB)
grid on
legend ('sigA', 'sigB')