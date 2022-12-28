pacman::p_load('plotly','kableExtra')

#parameters
mu.A = 0.175 #returns
sig.A = 0.258 #std.dev
sig2.A = sig.A^2

mu.B = 0.055
sig.B = 0.115
sig2.B = sig.B^2

rho.AB = -0.164
sig.AB = rho.AB*sig.A*sig.B

#### Portfolio 1; WA = WB = .5 
x.A = 0.5 #Weight A
x.B = 0.5 #Weight B
mu.p1 = x.A*mu.A + x.B*mu.B 
sig2.p1 = x.A^2 * sig2.A + x.B^2 * sig2.B + 2*x.A*x.B*sig.AB 
sig.p1 = sqrt(sig2.p1)#portfolio SD

#### Portfolio 2; Wa = 1.5, Wb=-.5
x.A = 1.5
x.B = -0.5
mu.p2 = x.A*mu.A + x.B*mu.B
sig2.p2 = x.A^2 * sig2.A + x.B^2 * sig2.B + 2*x.A*x.B*sig.AB
sig.p2 = sqrt(sig2.p2)

## portfolio VAR
## VaR = -(mu.p + sig.p*Q)*w0 (initial)

w0 = 100000 #initial investment ()
VaR.A = -(mu.A + sig.A*qnorm(.05))*w0 # 95% quantile
VaR.B = -(mu.B + sig.B*qnorm(.05))*w0
VaR.p1 = -(mu.p1 + sig.p1*qnorm(.05))*w0
VaR.p2 = -(mu.p2 + sig.p2*qnorm(.05))*w0

data.frame(VaR.A, VaR.B, VaR.p1, VaR.p2) %>% 
  `colnames<-`(c("$VaR_{A,0.05}$",
                 "$VaR_{B,0.05}$",
                 "$VaR_{p_{1},0.05}$",
                 "$VaR_{p_{2},0.05}$")) %>% 
  kbl(x=.,col.names = colnames(.)) %>% 
  kable_styling(full_width = TRUE)

Weights = as.numeric('0.5','0.3','0.2')
means = as.numeric('.05','0.03','.002')
weighted.mean(means,Weights)

#weighted VaR 
#Wa = Wb = .5
data.frame(0.5*VaR.A+0.5*VaR.B, 1.5*VaR.A-.5*VaR.B) %>% 
  `colnames<-`(c("$0.5VaR_{A,0.05} + 0.5VaR_{B,0.05}$",
                 "$1.5VaR_{A,0.05} - 0.5VaR_{B,0.05}$")) %>% 
  kbl() %>% kable_styling(full_width = TRUE)


##################################################################
##################################################################

x.A = seq(from=-0.4, to=1.4, by=0.1)
x.B = 1 - x.A
mu.p = x.A*mu.A + x.B*mu.B
sig2.p = x.A^2 * sig2.A + x.B^2 * sig2.B + 2*x.A*x.B*sig.AB

sig.p = sqrt(sig2.p)
port.names = paste("portfolio", 1:length(x.A), sep=" ")
data.tbl = as.data.frame(cbind(x.A, x.B, mu.p, sig.p))
rownames(data.tbl) = port.names
col.names = c("$x_{A}$","$x_{B}$", "$\\mu_{p}$", "$\\sigma_{p}$" )
kbl(data.tbl, col.names=col.names) %>%
  kable_styling(full_width=FALSE)

data.tbl = data.frame(x.A,x.B,mu.p,sig.p) %>% 
  `rownames<-`(paste("portfolio", 1:length(x.A), sep=" "))

data.tbl  %>% 
  `colnames<-`(c("$x_{A}$","$x_{B}$", "$\\mu_{p}$", "$\\sigma_{p}$" )) %>% 
  kbl() %>% kable_styling(full_width = FALSE)


####PLOT
fig = data.tbl %>% 
  plot_ly(
    x=.$sig.p,
    y=.$mu.p,
    type = 'scatter',
    mode = 'markers + lines',
    marker = list(color = 'rgb(85,51,86)'),
    name = "Efficient Frontier")


#Global minimum variance portfolio
x.A = ((sig2.B - sig.AB)/(sig2.A+sig2.B-2*sig.AB)) %>% 
  round(x=.,digits=1)
x.B = 1-x.A
mu.min = round(x.A*mu.A + x.B*mu.B,digits = 1)
sig2.p.min = ((x.A*sig.A)^2 + (x.B*sig.B)^2 + 2*x.A*x.B*sig.AB) %>% 
  round(.,digits = 4)
sig.p.min = sqrt(sig2.p.min) %>% round(.,digits=3)

data.min = data.frame(x.A,x.B,mu.min,sig.p.min) 
data.min %>% 
  `colnames<-`(c("$x_{A}^{\\min}$",
                 "$x_{B}^{\\min}$",
                 "$\\mu_{P}^{\\min}$",
                 "$\\sigma_{P}^{\\min}$")) %>% 
  kbl() %>% kable_styling(full_width = FALSE)

a = list(
  x = mu.min,
  y = sig.p.min,
  text = "GMVP",
  xref = "x", yref = "y",
  showarrow = TRUE,
  arrowhead = 0)

fig %>% 
  add_markers(.,
              x=mu.min,
              y = sig.p.min,
              marker = list(color = 'rgb(191,74,57)'),
              text = "Global Minimum Variance Portfolio") 

### temporary CAPM (SML line)
rf = 0.05
beta = as.numeric((data.tbl[11,][3]-rf)/data.tbl[11,][4])
SML = function(x){
  return(x*beta+rf)
}
x = c("0",round(data.tbl$sig.p,digits=4)) %>% as.numeric
y = SML(x)
fig %>% 
  add_lines(
    x = x,
    y = y,
    name = "SML Line"
  ) %>% 
  layout(title = "Portfolio Efficient Frontier",
         showlegend = FALSE,
         xaxis = list(title = "\u03C3"),
         yaxis = list(title = "\u00B5"),
         annotations = a) ## code source JAVA,C code


