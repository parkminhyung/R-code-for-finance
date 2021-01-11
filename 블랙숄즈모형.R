black_scholes = function(s,x,rf,std,t,y=NULL,D=NULL,r=NULL){
  if(!is.null(y) & is.null(D)){
    ### dividend rate is y    
    d1 = (log(s/x)+(rf-y+std/2)*t)/(std*sqrt(t)) 
    d2 = d1-(std*sqrt(t)) 
    call.price = s*exp(-y*t)*pnorm(d1)-x*exp(-rf*t)*pnorm(d2)
    put.price = x*exp(-rf*t)*pnorm(-d2) - s*exp(-y*t)*pnorm(-d1)
    
  } else if(is.null(y) & !is.null(D)){    
    ### dividends is D    
    k = ifelse(is.null(r),1,(1+r)^t)    
    s.d = s - D/k
    
    d1 = (log(s.d/x)+(rf+std/2)*t)/(std*sqrt(t)) 
    d2 = d1-(std*sqrt(t)) 
    call.price = s.d*pnorm(d1)-x*exp(-rf*t)*pnorm(d2)
    put.price = x*exp(-rf*t)*pnorm(-d2) - s.d*pnorm(-d1)
    
  } else {
    ### no dividends
    d1 = (log(s/x)+(rf+std/2)*t)/(std*sqrt(t)) 
    d2 = d1-(std*sqrt(t)) 
    call.price = s*pnorm(d1)-x*exp(-rf*t)*pnorm(d2)
    put.price = x*exp(-rf*t)*pnorm(-d2) - s*pnorm(-d1)
    
  }
  
  cat("===============================================","\n")
  cat("Call price is",round(call.price,digits = 3),"\n")
  cat("Put price is",round(put.price,digits = 3),"\n")
  cat("===============================================","\n")
  
  c(call.price,put.price)
}
