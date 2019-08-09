clear all;
close all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%

global BestFit;
global BestSol;
global FitAccess;
global count;
%Field Dimensions - x and y maximum (in meters)
xm=100;
ym=100;

% x and y Coordinates of the Sink
% Sink Position
sink.x=xm;
sink.y=ym;

%Number of Nodes in the field
n=50;

%maximum number of rounds
rmax=2000;


%Optimal Election Probability of a node
%to become cluster head
p=0.1;

%Energy Model (all values in Joules)
%Initial Energy 
Eo=0.5;
%Eelec=Etx=Erx *Why multiply with 50? look at paper
ETX=50*0.000000001;
ERX=50*0.000000001;
%Transmit Amplifier types *What is this?
Efs=10*0.000000000001;
Emp=0.0013*0.000000000001;
%Data Aggregation Energy   
%Energy consumption for data aggregation
EDA=5*0.000000001;

%Values for Hetereogeneity
%Percentage of nodes that are advanced Mean, have more Energy and power
p_a=0.1;
%\alpha ; Where we use Alpha?
a=1;

%%%%%%%%%%%%%%%%%%%%%%%%% END OF PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%
%%      INITIALIZATION

global slider_data slider1_data
slider_data.val = 25;
slider1_data.val = 25;
  
global fh 

fh = figure('Position',[250 250 450 450],...
            'Name','Simple Mobility WSN');
 
sh = uicontrol(fh,'Style','slider',...
               'Max',100,'Min',0,'Value',25,...
               'SliderStep',[0.05 0.2],...
               'Position',[10+90 0 100 15],...
               'Callback',@slider_callback);
           
           
sh1 = uicontrol(fh,'Style','slider',...
               'Max',100,'Min',0,'Value',25,...
               'SliderStep',[0.05 0.2],...
               'Position',[150+80 0 100 15],...
               'Callback',@slider1_callback);           
         
sth = uicontrol(fh,'Style','text','String',...
                'Animator Speed',...
                'Position',[10+90 15 100 15]);
            
     
sth1 = uicontrol(fh,'Style','text','String',...
                'Mobility Speed',...
                'Position',[150+80 15 100 15]);
            
            
            

setappdata(fh,'slider',slider_data); 
setappdata(fh,'slider',slider1_data); 


%%

%Computation of do ; what is this?
do=sqrt(Efs/Emp);

%% Variables Preallocation for fast execution of code 
% Variable 'S' denotes 'Sensor'
S.xd=[];
S.yd=[];
S.G=[];
S=repmat(S,n,1);
XR=repmat([],n,1);   %?
YR=repmat([],n,1);   %?
PACKETS_TO_CH_P_R=repmat([],rmax,1);   
PACKETS_TO_BS_P_R=repmat([],rmax,1);
STATISTICS=repmat([],n,1);
DEAD=repmat([],n,1);     


%%

%Creation of the random Sensor Network
%figure(1);
% 
%axis([0 xm 0 ym]);

cla;   
axis([0 xm 0 ym]); 
hold on
%% DISPERSING SENSOR NODES IN THE FIELD
for i=1:1:n
    %Setting Sensor i's X Dimension (x-coordinate);
    %Create a Random Number Between 0 and 1 and Multiply it with xm=100; 
    S(i).xd=rand(1,1)*xm;     
    XR(i)=S(i).xd;
    S(i).yd=rand(1,1)*ym;      %Setting Sensor i's Y Dimension (y-coordinate);
    YR(i)=S(i).yd;
    % G is the set of nodes that weren't cluster-head in the previous round.
    S(i).G=0;
    % Initially there are no cluster heads only nodes
    S(i).type='N';        %Node i's Type is 'Node' Or 'Cluster Head'
   
end

  %% Mobility Range
  r=0;
  m1=0.01+(slider1_data.val/100);
  aa=-1;
  ba=1;
  o1=[S(1:n).xd];
  o2=[S(1:n).yd];
  x = aa + (ba-aa)*rand(1,n);
  x1 = aa + (ba-aa)*rand(1,n);
  
  o11=o1+(r+1).*x.*m1;
  o21=o2+(r+1).*x1.*m1;
 
  for i=1:n
      if (o11(i)<xm && o21(i)<ym && o11(i)>0 && o21(i)>0)
         S(i).xd=o11(i); 
         S(i).yd=o21(i);
      end
  end
  
 for i=1:n   
    % In the following two IFs, we select 'p_a' percent of nodes as an Advance nodes 
    temp_rnd0=i;
    % Random Election of Normal Nodes
    % Nodes with sign 'o' are Normal nodes, which have less energy level
    if (temp_rnd0>=p_a*n+1) 
        S(i).E=Eo;             % This variable represents the node's Energy
        S(i).ENERGY=0;   % This represents, whether node is advance or normal
      
        
    end
    %Random Election of Advanced Nodes
    % Nodes with sign '+' are Advance nodes, which have more energy level
    if (temp_rnd0<p_a*n+1)  
        S(i).E=Eo*(1+a);
        S(i).ENERGY=1;
      
      
    end
    
end    

%%

%First Iteration
%%figure(1);

%counter for CHs
countCHs=0;
%counter for CHs per round
rcountCHs=0;
cluster=1;

%countCHs
rcountCHs=rcountCHs+countCHs;
flag_first_dead=0;

% r=Round
% rmax= maximum Number Of Rounds
%r=0:1:rmax => mean for loop from 0 to 3500 with 1 increase in each step
for r=0:1:rmax
   
    
    % print value of 'r' in each Iteration
    r
    
   % Animator Speed
   
    za=10/(slider_data.val+0.001);
        pause(za)
    
   
    %Operation for epoch
    % (r mod 1/p) is the most recent round; (r mod 1/p) becomes zero when the round is starting.
    % Setting all the nodes 'G' and 'cl' to zero when the round is starting
    % or when the algorithm begins
  if(mod(r, round(1/p))==0)    
    for i=1:1:n
        % G is the set of nodes that weren't cluster-heads the previous round. 
        S(i).G=0;    
        % Variable for recognizing which cluster, Sensor i belong
        S(i).cl=0;    
    end
  end


  

%Number of dead nodes
dead=0;
%Number of dead Advanced Nodes
dead_a=0;
%Number of dead Normal Nodes
dead_n=0;

%counter for transmitted bits to Base Station and to Cluster Heads
packets_TO_BS=0;
packets_TO_CH=0;
%counter for transmitted bits to Bases Station and to Cluster Heads 
%per round
% why (r+1)? because the index in MATLAB starts from 1
PACKETS_TO_CH_P_R(r+1)=0;   
PACKETS_TO_BS_P_R(r+1)=0;

%hold off;


%% --------------------------------------------------
%%figure(1);
figure(fh);
%% -----------------------------------

%axis([0 xm 0 ym]);
%hold on;
plot(sink.x,sink.y,'r^','LineWidth',1,...
              'MarkerEdgeColor','k',...
              'MarkerFaceColor','r',...
              'MarkerSize',12);
axis([0 xm 0 ym]);
text(sink.x-.5,sink.y-.5,'AP','FontSize',7); 

hold on

%%            CHECKING FOR DEAD NODES
for i=1:1:n
    %checking if there is a dead node or not
    if (S(i).E<=0)      % mean node has no energy or if node is dead
        plot(S(i).xd,S(i).yd,'r.','LineWidth',1,...
              'MarkerSize',13);
        dead=dead+1;      % increase the overall dead sensors by one
        if(S(i).ENERGY==1)  % The dead sensor belong to Advance nodes
            dead_a=dead_a+1;
        end
        if(S(i).ENERGY==0)      % The dead sensor belong to normal nodes
            dead_n=dead_n+1;
        end
        hold on;    
    end
  
 if (S(i).E>0)
        S(i).type='N';      % ?
        if (S(i).ENERGY==0)  
        plot(S(i).xd,S(i).yd,'o','LineWidth',1,...
              'MarkerEdgeColor','k',...
              'MarkerSize',12);
        end
        if (S(i).ENERGY==1)  
        plot(S(i).xd,S(i).yd,'+','LineWidth',1,...
              'MarkerEdgeColor','k',...
              'MarkerSize',12);
        end
        if n<=10
            text(S(i).xd,S(i).yd,int2str(i),'Color','r','FontSize',9);
        end
        hold on;
    end
  %{
  Multiple comment lines.  
  %} 
end

%%

% (r+1) because indices must be greater than zero
% For some statistics we distinguish between dead sensors in each round
STATISTICS(r+1).DEAD=dead;       
DEAD(r+1)=dead;     % Total dead sensors in each round (Advance+Normal) 
DEAD_N(r+1)=dead_n; % Total dead for Normal sensors in each round
DEAD_A(r+1)=dead_a;  % Total dead for Advance sensors in each round

%When the first node dies
if (dead==1)
    % flag_first_dead, variable cause 'if condition' execute just one time
    % when first node dies at the begining of each round
    %we set it to 1 because we don't want this if condition execute again
    if(flag_first_dead==0)     
        first_dead=r;
        flag_first_dead=1;
    end
end



%%  CHOOSING CLUSTER HEADS WITH GENETIC ALGORITHM


%************************************************************************
%************************************************************************
%************************************************************************
%************************************************************************

[BestChrom,BF(r+1,1)]=GeneticAlgorithm(S,sink);
[BestChrom1,BF(r+1,2)]=BacterialConjugation(S,sink);



%************************************************************************
%************************************************************************
%************************************************************************
%************************************************************************
B=figure(2);
hold off;
%set(B, 'Visible', 'off');
plot(BestFit(:,1),'r-','Linewidth',2);
hold on;
plot(BestFit(:,2),'b-','Linewidth',2);
legend('GA','BC','Location','SouthEast');
xlabel('Cluster Round');
ylabel('Fit');

% **************************************************

B=figure(3);
hold off;
%set(B, 'Visible', 'off');
plot(FitAccess(:,2),FitAccess(:,1),'r-','Linewidth',2);
hold on;
plot(FitAccess(:,4),FitAccess(:,3),'b-','Linewidth',2);
legend('GA','BC','Location','SouthEast');
xlabel('Number of access to fitness function');
ylabel('Fitness');

%****************************************************
figure(4);
bar(BF);
set(gca,'XTickLabel',{'GA BC'});

filename = sprintf('/figures/img_round_%d.jpg', r);
saveas(B, [pwd, filename]);
%}

figure(fh);
%xlswrite('output_data.xlsx', BestFit, sprintf('R %d',r));

C=[];
countCHs=0;
cluster=1;
for i=1:n
    if (BestChrom(i)==1)
        
        countCHs=countCHs+1;
        packets_TO_BS=packets_TO_BS+1; 
        PACKETS_TO_BS_P_R(r+1)=packets_TO_BS;   
        S(i).type='C';
        C(cluster).xd=S(i).xd;
        C(cluster).yd=S(i).yd;
        plot(S(i).xd,S(i).yd,'k*','LineWidth',1,...
              'MarkerEdgeColor','k',...
              'MarkerFaceColor','y',...
              'MarkerSize',12);
        distance=sqrt( (S(i).xd-(sink.x) )^2 + (S(i).yd-(sink.y) )^2 );
        C(cluster).distance=distance;
        C(cluster).id=i;
        X(cluster)=S(i).xd;  % For Voronoi diagram
        Y(cluster)=S(i).yd;  % For voronoi diagram
        C(cluster).color=Colorset(cluster);

        cluster=cluster+1;

        % Calculation of Energy dissipated
        if (distance>do)
            S(i).E=S(i).E- ( (ETX+EDA)*(4000) + Emp*4000*( distance*distance*distance*distance )); 
        end
        if (distance<=do)
            S(i).E=S(i).E- ( (ETX+EDA)*(4000)  + Efs*4000*( distance * distance )); 
        end
        
    end
end

% In the Leach protocol it is possible to not to have any
% CH in these cases sensors will send their 
% data to BS directly. also if sensors will be closer to the
% BS they will send their data to the BS instead of CH.



% save number of cluster heads
STATISTICS(r+1).CLUSTERHEADS=cluster-1;
CLUSTERHS(r+1)=cluster-1;



%% Election of Associated Cluster Head for Normal Nodes
 for i=1:1:n
   if(cluster-1>=1)
     if ( S(i).type=='N' && S(i).E>0 )  %  Are you a normal node and have energy?
         %if(cluster-1>=1)    % checking for existence of CH
         % find the distance between sensor i and base station
         %MIN_dis=sqrt((S(i).xd-sink.x)^2 + (S(i).yd-sink.y)^2);
         MIN_dis=inf;
         % min_dis_cluster=1;
        for c=1:1:cluster-1
            CH_dis=sqrt( (S(i).xd-C(c).xd)^2 + (S(i).yd-C(c).yd)^2 );
            % min_dis=min(BS_dis,CH_dis);
            % we want to find the minimum distance from Normal sensor i to any
            % CH rather than base station.
            if ( CH_dis < MIN_dis )
               MIN_dis=CH_dis;
               min_dis_cluster=c;
            end
        end
       
        % Energy dissipated by associated Cluster Head
            MIN_dis;
            if (MIN_dis>do)
                S(i).E=S(i).E- ( ETX*(4000) + Emp*4000*( MIN_dis * MIN_dis * MIN_dis * MIN_dis)); 
            end
            if (MIN_dis<=do)
                S(i).E=S(i).E- ( ETX*(4000) + Efs*4000*( MIN_dis * MIN_dis)); 
            end
        %Energy dissipated
        if(MIN_dis>0)
          S(C(min_dis_cluster).id).E = S(C(min_dis_cluster).id).E- ( (ERX + EDA)*4000 ); 
         PACKETS_TO_CH_P_R(r+1)=n-dead-cluster+1; 
        end

       S(i).min_dis=MIN_dis;
       S(i).min_dis_cluster=min_dis_cluster;
     
      %end 
     end
   end
   
   % Seperating Each Cluster's nodes with different colors
   
     if (S(i).type ~= 'C')
       if (S(i).ENERGY==0 && S(i).type ~= 'C'&& size(C,1)~=0)  
          plot(S(i).xd,S(i).yd,'o','LineWidth',1,...
              'MarkerEdgeColor','k',...
              'MarkerFaceColor',C(S(i).min_dis_cluster).color,...
              'MarkerSize',12);
          
       end
       if (S(i).ENERGY==1 && S(i).type ~= 'C' && size(C,1)~=0)  
          plot(S(i).xd,S(i).yd,'+','LineWidth',3,...
              'color',C(S(i).min_dis_cluster).color,...
              'MarkerSize',12);
       end
     end 
    
 end

 %%
hold on;

countCHs;
rcountCHs=rcountCHs+countCHs;
cluster
if (cluster-1 >= 3)
    [vx,vy]=voronoi(X,Y);
    plot(vx,vy,'b-');
    %hold on;
    %voronoi(X,Y);
    %axis([0 xm 0 ym]);
    
end
%{
% Mobilizing sensor nodes
for i=1:n
d=randi([1 4],1,1);
switch d
    case {1}
        
    case {2}
        
    case {3}
        
    case {4}
        
end
%}

%% Mobility Range

  m1=0.01+(slider1_data.val/100);
  aa=-1;
  ba=1;
  o1=[S(1:n).xd];
  o2=[S(1:n).yd];
  x = aa + (ba-aa)*rand(1,n);
  x1 = aa + (ba-aa)*rand(1,n);
  
  o11=o1+(r+1).*x.*m1;
  o21=o2+(r+1).*x1.*m1;
  ReEnergy(r+1,1)=0;  
  for i=1:n
      if (o11(i)<xm && o21(i)<ym && o11(i)>0 && o21(i)>0)
         S(i).xd=o11(i); 
         S(i).yd=o21(i);
      end
      %remained energy in each round for plotting
      ReEnergy(r+1,1)=ReEnergy(r+1,1)+S(i).E;
  end

  hold off;
end




