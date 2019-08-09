function [GA,BF]=GeneticAlgorithm(S,sink)
%clc;
%clear;
%close all;
format short g;
%%  Problem Definition
global BestFit;
global BestSol;
global NFE;
NFE=0;
global count;
global FitAccess;
%FitFunction=@(x) Fitness(x);                           %Fit Function

nVar=size(S,1);                      % Number Of Decition variables   %Number Of genes
% VarSize=[1 nVar];          % Decision Variable Matrix Size

%%   GA Parameters

MaxIt=100;                      %Maximum Number of Iterations  % Criteria for Finishing Algorithm

nPop=50;                       %Population Size

pc=0.8;                        % Crossover percentage
nc=2*round(pc*nPop/2);         % Number Of Offsprings

pm=0.3;                        % Mutation Percentage
nm=round(pm*nPop);             % Number Of Mutants

%%  Initialization

empty_individual.Position=[];
empty_individual.Fit=[];
pop=repmat(empty_individual,nPop,1);

file = 'GA.txt';
fh = fopen(file, 'wb');
fprintf(fh, '%s      %s       %s       %s       %s\n','Iteration', 'Fitness', 'CH', 'Total Distance', 'RCSD');
     
for i=1:nPop
    
    % Initialize Position
    pop(i).Position=randi([0 1],1,nVar);
    
    %Preparing Fitness Parameters
    [TD,RCSD,CL]=FitParameters(sink,S,pop(i).Position);
    count.GA=0;
    % Evaluation
    pop(i).Fit=Fitness(nVar,TD,CL,RCSD);
    pop(i).CH=CL;
    count.GA=count.GA+1;
    
    % Data for plot based on sccessing Fitness Function
    %%FitAccess(i,1)=pop(i).Fit;
    %%FitAccess(i,2)=i;
    
    %fprintf(fh, '%.2f    %.2f    %d    %.2f         %d\n', TD,RCSD,CL,pop(i).Fit,0);
    
end
 % Here because our problem is minimization and using Fit Function we will
 % choose the chromosome that has the lowest value.
 
 % Sort Population
 Fits=[pop.Fit];
 [Fits, Sortorder]=sort(Fits,'descend');
 pop=pop(Sortorder);

% Store Best Solution
BestSol=pop(1);

% Array to Hold Best Solution
BestFit=zeros(MaxIt,6);

% Data for plot based on sccessing Fitness Function
FitAccess(1,1)=pop(1).Fit;
FitAccess(1,2)=nPop;
%%  Main Loop

for it=1:MaxIt
    
    % CrossOver
    popc=repmat(empty_individual,nc,2);
    
    for k=1:nc
        
        % Select First Parent
        i1=randi([1 nPop]);
        p1=pop(i1);
    
        % Select Second Parent
        i2=randi([1 nPop]);
        p2=pop(i2);
        
        % Apply CrossOver
        [popc(k,1).Position popc(k,2).Position]=SinglePointCrossover(p1.Position,p2.Position,nVar);
        
        % Evaluate Offsprings
        
        
        [TD,RCSD,CL]=FitParameters(sink,S,popc(k,1).Position);
        popc(k,1).Fit=Fitness(nVar,TD,CL,RCSD);
        count.GA=count.GA+1;
        popc(k,1).CH=CL;
        
        % Data for plot based on sccessing Fitness Function
        %%FitAccess(count.GA,1)=popc(k,1).Fit;
        %%FitAccess(count.GA,2)=count.GA;
        %fprintf(fh, '%.2f    %.2f    %d    %.2f         %d\n', TD,RCSD,CL,popc(k,1).Fit,it);
      
        [TD,RCSD,CL]=FitParameters(sink,S,popc(k,2).Position);
        popc(k,2).Fit=Fitness(nVar,TD,CL,RCSD);
        count.GA=count.GA+1;
        
       % Data for plot based on sccessing Fitness Function
        %%FitAccess(count.GA,1)=popc(k,2).Fit;
        %%FitAccess(count.GA,2)=count.GA;
        popc(k,2).CH=CL;
        %fprintf(fh, '%.2f    %.2f    %d    %.2f         %d\n', TD,RCSD,CL,popc(k,2).Fit,it);
    
    end
    popc=popc(:);     % For verticalize the popc matrix
    
    % Mutation
    popm=repmat(empty_individual,nm,1);
    for k=1:nm
        
        % Select Parent
        i=randi([1 nPop]);
        p=pop(i);
        
        %Apply Mutation
        popm(k).Position=Mutate(p.Position);
         
        % Evaluate Mutant
        
        [TD,RCSD,CL]=FitParameters(sink,S,popm(k).Position);
        popm(k).Fit=Fitness(nVar,TD,CL,RCSD);
        count.GA=count.GA+1;
        %%FitAccess(count.GA,1)=popm(k).Fit;
        %%FitAccess(count.GA,2)=count.GA;
        popm(k).CH=CL;
        %fprintf(fh, '%.2f    %.2f    %d    %.2f         %d\n', TD,RCSD,CL,popm(k).Fit,it);
    
    end
         
    % Create merged Population
    pop=[pop
        popc
        popm];
         
         %Sort Population
         Fits=[pop.Fit];
         %Fits=sortrows(Fits,'descend');
         
         [Fits Sortorder]=sort(Fits,'descend');
         pop=pop(Sortorder);
         Fits=Fits(:);
         
         
         
         %Truncation
         pop=pop(1:nPop);
         
         %Store best Solution
         BestSol=pop(1);
         fprintf(fh, '    %d           %0.2f       %d              %0.2f         %0.2f\n',it,BestSol.Fit,CL,TD,RCSD);
        
         %Store Best Fit
         BestFit(it,1)=BestSol.Fit;
         FitAccess(it+1,1)=BestSol.Fit;
         FitAccess(it+1,2)=FitAccess(it,2)+nc+nm;
         % Show Iteration information
       %  disp (['Iteration = ' num2str(it) ' nfe= ' num2str(nfe(it)) ' NFE = ' num2str(NFE) ' Best Fit = ' num2str(BestFit(it))])
         
       %{
         if (BestFit(it) == 0)  %Break The Loop If We reached the BestFit To Zero
             break
         end
       %} 
       
       
       
end
fprintf(fh, '\n%s    %.2f', 'Best choosen Fitness : ',BestSol.Fit);

fclose('all');
%% results
%{
figure;
plot(BestFit, 'Linewidth',3);
xlabel('Iteration');
ylabel('Fit');
%}

GA=BestSol.Position;
BF=BestSol.Fit;

end