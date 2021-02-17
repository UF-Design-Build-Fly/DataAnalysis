clear; clc; close all;
T = readtable('dbf test flight one.csv');
t1 = T.Var1*(300/1000); %first column is the memory address each val was stored in. For the first test flight values were read every 300 milliseconds.
v1 = ((T.Var2*4)/1024)*5; %voltage readings from first test flight
t2 = T.Var3*(300/1000); %memory address vector for second test flight
v2 = ((T.Var4*4)/1024)*5; %voltage readings from second test flight.

plot(t1, v1);
title('Test flight 1');
xlabel('time (seconds)');
ylabel('Voltage');
figure()
plot(t2, v2);
title('Test flight 2');
xlabel('time (seconds)');
ylabel('Voltage');