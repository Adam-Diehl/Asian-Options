%Asian Option Pricing

function [AsianCall,AsianPut]=AsianPrice(S0,K,r,vol,T,dt,Nrows)

%Nrows is the number of realizations or paths, i.e. Nrows == N.

tic
    
%Pre-calculate as many parameters as possible
    Ncols = T/dt;
    drift = (r-((vol^2)/2))*dt; 
    part_stoch_part = vol*sqrt(dt); 
    Discount = exp(-r*T);

%Generate Random numbers
    random = randn(Nrows, Ncols);

%Generate Stock Price Paths
    S = ones(Nrows, Ncols);
    S = S.*exp(drift+part_stoch_part.*random);
    S = cumprod(S,2);
    S = S0*S;
    S(:,1) = S0;

clear random; %Free up a chunk of RAM

%Calculate Asian Option Prices
    %Asian Call
        %Path Averages
            A_Path = (1/Ncols)*sum(S,2);
        %Calculate Payoff
            Payoff_Call = [zeros(Nrows,1) A_Path - K];
            Payoff_Call = Discount.*max(Payoff_Call,[],2);
            AsianCall = mean(Payoff_Call);
    %Asian Put
        %Calculate Payoff
            Payoff_Put = [zeros(Nrows,1) K - A_Path];
            Payoff_Put = exp(-r*T).*max(Payoff_Put,[],2);
            AsianPut = mean(Payoff_Put);
toc
