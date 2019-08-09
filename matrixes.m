clear all;
clc;
%%

empty_matrix=zeros();

for i=1:1:100
        empty_matrix(i,1).x=randi([0 100]);
        empty_matrix(i,2).y=randi([0 100],1);
end
