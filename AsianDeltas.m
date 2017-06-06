%Plots the delta of an Asian Option across a variety of initial stock
%prices using Monte Carlo simulation

%Set Constants
    S0 = 98; %Initial price
    vol = 0.35; %Volatility
    K = 99; %Strike Price of the Option
    r = 0.05; %Risk-Free Rate of Interest
    u = 0.05; %Expected Return on the Stock (Annualized)
    dt = 1/12; %Time Increment, 1/252 implies daily data
    T = 1; %Time to maturity, in years
    Nrows = 10000; %Number of Simulations
    Ncols = 12; %Number of days (or some other time increment) to simulate

%Pre-calculate as many parameters as possible
    drift = (u-((vol^2)/2))*dt; 
        %First term of the differential equation
    part_stoch_part = vol*sqrt(dt); 
        %This isn't the whole of the second term in the differential equation, 
        %because the randomness needs to be set within the matrix itself

%Generate Random numbers
    random = randn(Nrows, Ncols);

%Premium Storage
Premiums = zeros(200,5);

%Generate Stock Price Paths
for n=1:201
    S0 = n;
    S = ones(Nrows, Ncols);
    S = S.*exp(drift+part_stoch_part.*random);
    S = cumprod(S,2);
    S = S0*S;
    S(:,1) = S0;

%Calculate Asian Option Prices
    %Asian Call
        %Path Averages
            A_Path = (1/Ncols)*sum(S,2);
        %Calculate Payoff
            Payoff_Call = A_Path - K;
            for i=1:length(Payoff_Call)
                if Payoff_Call(i) <0
                    Payoff_Call(i) = 0;
                end
            end
            Adjusted_Call_Payoff = max(Payoff_Call,[],2);
            Adjusted_Call_Payoff = exp(-r*T).*Adjusted_Call_Payoff;
            Asian_Call_Value = mean(Adjusted_Call_Payoff);
    %Asian Put
        %Calculate Payoff
            Payoff_Put = K - A_Path;
            for i=1:length(Payoff_Put)
                if Payoff_Put(i) <0
                    Payoff_Put(i) = 0;
                end
            end
            Adjusted_Put_Payoff = max(Payoff_Put,[],2);
            Adjusted_Put_Payoff = exp(-r*T).*Adjusted_Put_Payoff;
            Asian_Put_Value = mean(Adjusted_Put_Payoff);
Premiums(n,1) = Asian_Call_Value;
Premiums(n,2) = Asian_Put_Value;

%Black Scholes Option Premiums
    d1 = (log(S0/K) + (r+(vol^2)/2)*T)/(vol*sqrt(T));
    d2 = d1-(vol*sqrt(T));
    Call_BS = S0*cdf('Normal',d1,0,1) - K*exp(-r*T)*cdf('Normal',d2,0,1);
    Put_BS = K*exp(-r*T)*cdf('Normal',-d2,0,1)-S0*cdf('Normal',-d1,0,1);
    Deltas = cdf('Normal',d1,0,1);
    
    Premiums(n,3) = Call_BS;
    Premiums(n,4) = Put_BS;
    Premiums(n,5) = Deltas;
end

AsianDelPlot = plot(diff(Premiums(:,1)));
%plot(diff(Premiums(:,3)), 'LineWidth',2); 
set(AsianDelPlot,'LineStyle','-.','LineWidth',.75,'Color','k');
hold on;
VanillaPlot = plot(Premiums(:,5));
set(VanillaPlot,'LineWidth',1,'Color','k');
axis([0,200,0,1]);
hold off;