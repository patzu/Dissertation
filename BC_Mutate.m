function BC_M=BC_Mutate(Ch,P_gm)
for i=1:numel(Ch.Position)
    
    r=rand;
    if (r<P_gm)
       if Ch.Position(i)==1
           Ch.Position(i)=0;
       else
           Ch.Position(i)=1;
       end
    end
    
end    
Ch.Fit=0;
BC_M=Ch;
end