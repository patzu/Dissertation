clear all
close all
clc
  
load count.dat;
yMat = count(1:10,1:2);
figure;
bar(yMat);