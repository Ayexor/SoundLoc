%Marco Zollinger
clc
clear
close all

%define receiver location (green): equilateral triangle with side length 1
%P1: center top, P2: left low, P3: right low
P1 = [0 sqrt(3)/3 0];
P2 = [-0.5 -sqrt(3)/6 0];
P3 = [0.5 -sqrt(3)/6 0];

%define sound source location (red)
S = [2.3 7.1 10];

%calculate boundaries for approximate heading
[ab(2), ab(1)] = pol2cart(deg2rad(60), 10);
[bc(2), bc(1)] = pol2cart(deg2rad(120), 10);
[cd(2), cd(1)] = pol2cart(deg2rad(180), 10);
[de(2), de(1)] = pol2cart(deg2rad(240), 10);
[ef(2), ef(1)] = pol2cart(deg2rad(300), 10);
[fa(2), fa(1)] = pol2cart(deg2rad(0), 10);

%distances between the source and every receiver
s1 = norm(P1-S);
s2 = norm(P2-S);
s3 = norm(P3-S);

%calculate approximate heading and reference station
if ((s1 <= s3) && (s3 <= s2))
    %sector a -> 30deg
    approxdeg = 30;
    ref = 1;
elseif ((s3 <= s1) && (s1 <= s2))
    %sector b -> 90deg
    approxdeg = 90;
    ref = 3;
elseif ((s3 <= s2) && (s2 <= s1))
    %sector c -> 150deg
    approxdeg = 150;
    ref = 3;
elseif ((s2 <= s3) && (s3 <= s1))
    %sector d -> 210deg
    approxdeg = 210;
    ref = 2;
elseif ((s2 <= s1) && (s1 <= s3))
    %sector e -> 270deg
    approxdeg = 270;
    ref = 2;
elseif ((s1 <= s2) && (s2 <= s3))
    %sector f -> 330deg
    approxdeg = 330;
    ref = 1;
end
[approxS(2), approxS(1)] = pol2cart(deg2rad(approxdeg), 1);

%calculate distance differences
if ref==1
    ds1 = s1 - s1;  %yes, zero
    ds2 = s2 - s1;
    ds3 = s3 - s1;
elseif ref==2
    ds1 = s1 - s2;
    ds2 = s2 - s2;  %yes, zero
    ds3 = s3 - s2;
elseif ref ==3
    ds1 = s1 - s3;
    ds2 = s2 - s3;
    ds3 = s3 - s3;  %yes, zero
end

%time differences between the receivers
c = 343;    %speed of sound in air
dt1 = ds1 / c;
dt2 = ds2 / c;
dt3 = ds3 / c;

%draw locations on map
figure(1)
hold on
axis equal
grid on
scatter(P1(1), P1(2), 10, [0 1 0], 'filled');
scatter(P2(1), P2(2), 10, [0 1 0], 'filled');
scatter(P3(1), P3(2), 10, [0 1 0], 'filled');
scatter(S(1), S(2), 10, [1 0 0], 'filled');
plot([P1(1) P2(1)],[P1(2) P2(2)], 'g');
plot([P2(1) P3(1)],[P2(2) P3(2)], 'g');
plot([P3(1) P1(1)],[P3(2) P1(2)], 'g');

% plot([0 ab(1)],[0 ab(2)], 'g');
% plot([0 bc(1)],[0 bc(2)], 'g');
% plot([0 cd(1)],[0 cd(2)], 'g');
% plot([0 de(1)],[0 de(2)], 'g');
% plot([0 ef(1)],[0 ef(2)], 'g');
% plot([0 fa(1)],[0 fa(2)], 'g');
% 
% scatter(approxS(1), approxS(2), 10, [0 0 1], 'filled');

plot([P1(1) S(1)],[P1(2) S(2)], 'r');
plot([P2(1) S(1)],[P2(2) S(2)], 'r');
plot([P3(1) S(1)],[P3(2) S(2)], 'r');
plot([0 S(1)],[0 S(2)], 'r');

angle = atan2(S(1), S(2)) * 180 / pi + 180

theta = cart2pol(S(1)-P1(1),S(2)-P1(2));
[vpoint(1), vpoint(2)] = pol2cart(theta, ds1);
plot([P1(1) P1(1)+vpoint(1)],[P1(2) P1(2)+vpoint(2)], 'b');

theta = cart2pol(S(1)-P2(1),S(2)-P2(2));
[vpoint(1), vpoint(2)] = pol2cart(theta, ds2);
plot([P2(1) P2(1)+vpoint(1)],[P2(2) P2(2)+vpoint(2)], 'b');

theta = cart2pol(S(1)-P3(1),S(2)-P3(2));
[vpoint(1), vpoint(2)] = pol2cart(theta, ds3);
plot([P3(1) P3(1)+vpoint(1)],[P3(2) P3(2)+vpoint(2)], 'b');

% Initial vector
x0 = [-0.1; -0.1; -0.1];
%x0 = [1; 1; 1];

%dt1 = 0; dt2 = 0; dt3 = 1;
dt1 * 1000
dt2 * 1000
dt3 * 1000

%[x,fval] = fsolve(@(x) tdoa_eq(x, P1, P2, P3, dt1, dt2, dt3), x0);
fone = @(x)jacob3x3(x,dt1,dt2,dt3);
ftwo = @(x)f3(x, dt1, dt2, dt3);
[x,iter] = newtonm(x0,ftwo,fone); 

scatter(x(1), x(2), 10, [0 0 1], 'filled');
