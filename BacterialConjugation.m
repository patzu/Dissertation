function [BC,BF]=BacterialConjugation(S,sink)


    %clc;
    global BestFit;
    global BestSol;
    global count;
    global FitAccess;
    count.BC=0;
    Ch_Length=size(S,1);
    MaxIt=100;
    nPop=50;
    file = 'BC.txt';
    fh = fopen(file, 'wb');
    fprintf(fh, '%s      %s       %s       %s       %s\n','Iteration', 'Fitness', 'CH', 'Total Distance', 'RCSD');

    for i=1:nPop

        % Initialize Position
        pop(i).Position=randi([0 1],1,Ch_Length);

        %Preparing Fitness Parameters
        [TD,RCSD,CL]=FitParameters(sink,S,pop(i).Position);
        
        % Evaluation
        pop(i).Fit=Fitness(Ch_Length,TD,CL,RCSD);
        count.BC=count.BC+1;
        
        pop(i).CL=CL;
        %fprintf(fh, '    %d           %.2f       %d       %d\n',i,pop(i).Fit,CL,TD,RCSD);

    end

    % Sort Population
     Fits=[pop.Fit];
     [Fits, Sortorder]=sort(Fits,'descend');
     pop=pop(Sortorder);
    
    FitAccess(1,3)=pop(1).Fit;
    FitAccess(1,4)=nPop;
    
    for it=1:MaxIt
        
        % Store Best Chromosome
    CH_Result=pop(1);
    BestCH=pop(1);
        
        for i=2:nPop

            Recip_Ch=pop(i);
            Worst_Ch=pop(end);
            New_Ch=HorizontalGeneTransfer(BestCH,Recip_Ch,Worst_Ch);  

            % Calculating number of similar genes
            SimGenes=0;
            for j=1:Ch_Length
                if (New_Ch.Position(j)==Recip_Ch.Position(j))
                    SimGenes=SimGenes+1; 
                end
            end

            Similarity=SimGenes/(Ch_Length*10);

            P_gm=Similarity;

            %Preparing Fitness Parameters
            [TD,RCSD,CL]=FitParameters(sink,S,New_Ch.Position);

            % Evaluation
            New_Ch.Fit=Fitness(Ch_Length,TD,CL,RCSD);
            count.BC=count.BC+1;
            New_Ch.CL=CL;
             %fprintf(fh, '%d   %.2f    %d    %d\n',i,New_Ch.Fit,CL,TD,RCSD);


            if (New_Ch.Fit>=Recip_Ch.Fit)
               CH_Mutated=BC_Mutate(Recip_Ch,P_gm);
               CH_Non_Mutated=New_Ch;
            else
               CH_Mutated=BC_Mutate(New_Ch,P_gm);
               CH_Non_Mutated=Recip_Ch;
            end


            %Preparing Fitness Parameters
            [TD,RCSD,CL]=FitParameters(sink,S,CH_Mutated.Position);

            % Evaluation
            CH_Mutated.Fit=Fitness(Ch_Length,TD,CL,RCSD);
            count.BC=count.BC+1;
            CH_Mutated.CL=CL;
            %fprintf(fh, '%d   %.2f    %d    %d\n',i,CH_Mutated.Fit,CL,TD,RCSD);

            if (CH_Mutated.Fit>CH_Non_Mutated.Fit)
                CH_Result=CH_Mutated;
            else
                CH_Result=CH_Non_Mutated;
            end
            if (CH_Result.Fit>BestCH.Fit)
               BestCH=CH_Result;
            end
            pop(i)=CH_Result;
        end
        
        % Sort Population
     Fits=[pop.Fit];
     [Fits, Sortorder]=sort(Fits,'descend');
     pop=pop(Sortorder);
        
        %Store Best Fit
        BestFit(it,2)=BestCH.Fit;
        
        FitAccess(it+1,3)=BestCH.Fit;
        FitAccess(it+1,4)=FitAccess(it,4)+nPop;
        fprintf(fh, '    %d           %.2f       %d            %.2f       %.2f\n',it,BestCH.Fit,BestCH.CL,TD,RCSD);
    end
    
    fprintf(fh, '    %s           %.2f       %d\n','Best Choosen Fitness & number of CHs: ',BestCH.Fit,BestCH.CL);  
    fclose('all');
    BC=CH_Result.Position;
    BF=BestCH.Fit;
    

end       
