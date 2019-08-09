function z=Fitness(N,TD,TCH,RCSD)
    %TD Total distance
    %N Number of nodes
    %Total cluster heads
    %First part of formula tries to increase the number of cluster heads
    %the thing is if number of CHs become zero (TD-RCSD) will 
    w=0.3;
    
    z=w*(TD-RCSD)+(1-w)*(N-TCH);
    %RCSD is distance between typical sensors and their associated cluster
    %head
end
