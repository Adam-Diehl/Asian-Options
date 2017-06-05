#Asian Option Price Function
AsianPrice = function(S0,K,vol,r,t,dt,Realizations){
  
  #Precalculate constants
  Ncols = as.numeric(ceiling(t/dt))
  Nrows = Realizations
  drift <- (r-((vol^2)/2))*dt
  partial.stochastic.part <- vol*sqrt(dt)
  DiscountFactor = rep(exp(-r*t),times=Nrows)
  
  #Simulate Stock Movements
  S <- matrix(exp(drift+partial.stochastic.part*rnorm(Ncols*Nrows)), ncol=Ncols, nrow=Nrows)
  S <- t(apply(S,1,cumprod))
  S <- S*S0
  S[,1] <- S0
  #matplot(t(S), type = "l")
  
  #Generate Average
  A.Path = (1/Ncols)*rowSums(S)
      
  #Payoffs
  Payoff.Call = pmax(A.Path - K,0)
  Payoff.Put = pmax(K-A.Path,0)
   
  #Price
  Call = mean(Payoff.Call*DiscountFactor)
  Put = mean(Payoff.Put*DiscountFactor)
  Labels = c("Call","Put")
  Premiums = numeric(2)
  Premiums[1] = Call
  Premiums[2] = Put
  Output = list(Labels, Premiums)
  return(Output)
}