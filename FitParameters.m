function [TD,RCSD,CL]=FitParameters(sink,S,popPos)

    nVar=size(S,1);
    % Total distance of all nodes with BS.
    td=0; % Total distance of all sensor nodes with Base Station.
    dis=0;
    cluster=1;
    rcsd=0; 
    distance=0;
    for j=1:1:nVar
        dis=sqrt( (S(j).xd-(sink.x) )^2 + (S(j).yd-(sink.y) )^2 );
        td=td+dis;
        if (popPos(j)==1)
            C(cluster).xd=S(j).xd;
            C(cluster).yd=S(j).yd;
            C(cluster).distance=dis;
            S(j).type='C';
            cluster=cluster+1;   
        end 
    end
    
    % Try to find minimum distance closest CH, among all CHs.
    
    if (cluster>1)
        for j=1:nVar
            mindis=inf;
          if (S(j).type ~= 'C')
            for c=1:cluster-1
                distance=sqrt((S(j).xd-(C(c).xd))^2 + (S(j).yd-(C(c).yd))^2);
                if (distance < mindis)
                    mindis=distance;
                end
            end

          if (mindis ~=inf)
             rcsd=rcsd+mindis;
          end
         end  
        end
    %Add base station's distance to rcsd.
        for c=1:cluster-1    
            rcsd=rcsd+C(c).distance;    
        end
    else
         rcsd=td;
    end  
    
    
TD=td;          % Total distance
RCSD=rcsd;
CL=cluster-1;   % Number Of cluster heads
end