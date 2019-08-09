function y=Mutate(x)
nVar=numel (x);
j=randi ([1 nVar]);
x(j)=1-x(j);
y=x;
end