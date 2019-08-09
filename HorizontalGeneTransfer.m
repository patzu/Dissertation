function HGT=HorizontalGeneTransfer(Donor,Recip_Ch,Worst_Ch)

    Donor_Ch_Fit=Donor.Fit;
    Donor_Ch_Position=Donor.Position;
    Ch_Length=numel(Donor.Position);
    
    
    L=(abs(Donor_Ch_Fit-Recip_Ch.Fit)/abs(Donor_Ch_Fit-Worst_Ch.Fit))*Ch_Length;

    
    New_Ch.Position=Recip_Ch.Position;
    P=randi([1 Ch_Length]);

    for i=1:L
       New_Ch.Position(P)=Donor_Ch_Position(P); 
       P=P+1;
       if (P>Ch_Length)
           P=1;     
       end   
    end
    %Pop=[pop;x];
    HGT=New_Ch;  
end