#Dynamic Hedge 

Dy.stg = function(V,p,s,x,k,r,t,std){
  # Compute Future Price
  Future = s*exp(r*t)
  Np = V/(s*k) #V is Portfolio Size
  
  Floor = x*k*Np - p*k*Np*(1+r*t)  
  
  #Dynamic Hedge
  d1 = (log(s/x)+(r+std^2/2)*t)/(std*sqrt(t))
  Del.F = Future/s
  Del.P =  pnorm(d1)-1
  Nf = (Np*Del.P)/Del.F
  
  cat("===============================================","\n")
  cat("Theoretical Future Price : ",Future,"\n")
  cat("Floor of Protective Put : ",Floor,"\n")
  cat("Put Delta : ",Del.P,"\n")
  cat("Future Delta : ",Del.F,"\n")
  cat("동적헤지에 필요한 선물 수량 : ",Nf,"\n")
  cat("===============================================","\n")
}



