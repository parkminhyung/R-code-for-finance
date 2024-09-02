

# Heston model



## What is the Heston model ?

The Heston model, introduced in 1993 by Steven Heston, is a financial model used to price options where the underlying asset's volatility is not constant but follows a stochastic process.

 Unlike the Black-Scholes model, the Heston model assumes that both the asset's price and its volatility follow stochastic differential equations. 

This allows the model to capture the **"volatility smile**," where implied volatility varies with different strike prices. 

The model's ability to accurately reflect asset price dynamics and volatility surfaces makes it a standard in equity and foreign exchange markets.

"Heston 모형은 1993년 스티븐 헤스턴이 제안한 금융 모형으로, 기초 자산의 변동성이 일정하지 않고 확률적 과정에 따라 움직이는 옵션의 가격을 산정하는 데 사용됩니다.

 블랙-숄즈 모형과 달리, Heston 모형은 자산 가격과 변동성이 모두 확률적 미분 방정식을 따르는 것으로 가정합니다. 

이 모형은 "변동성 미소"를 설명할 수 있어, 주식 및 외환 시장에서 자산 가격의 동적 변화와 변동성 곡선을 정확히 반영할 수 있는 표준 모형으로 자리잡았습니다."

"Heston模型是由Steven Heston于1993年提出的金融模型，用于定价期权，其中基础资产的波动率不是常数，而是遵循一个随机过程。

与Black-Scholes模型不同，Heston模型假设资产价格和其波动率都遵循随机微分方程。这使得模型能够捕捉到**“波动率微笑”**现象，即隐含波动率随着不同的执行价格而变化。

该模型准确反映资产价格动态和波动率曲面，使其成为股票和外汇市场的标准模型。"



> **What is Volatility smile**

Option pricing is complex due to various external factors like time to maturity, strike price, and implied volatility of the underlying asset.

 These factors contribute to the volatility smile, where implied volatility is higher for in-the-money (ITM) and out-of-the-money (OTM) options compared to at-the-money (ATM) options.

 This smile occurs because there is generally more demand for ITM and OTM options, leading to higher implied volatility.

 Advanced models beyond Black-Scholes tend to overprice OTM options to account for the higher risk. 

As a result, ATM options usually have lower implied volatility, making call options more attractive to write than put options for money managers.

옵션 행사가격이 현재 시장 가격에 멀어짐 > 옵션의 implied volatility 증가 > 옵션 모형은 OTM의 과도한 리스크를 반영하기 위해 과대평가 하는 경향 존재 > ATM옵션의 IV는 낮게 유지, 변동성 미소가 존재 : call옵션 선호도 > put옵션 선호도

"期权定价复杂的原因在于各种外部因素，如到期时间、执行价格和基础资产的隐含波动率。这些因素会导致“波动率微笑”现象，即隐含波动率对于深度实值（ITM）和深度虚值（OTM）期权通常高于平值（ATM）期权。

这种微笑现象的出现是因为对ITM和OTM期权的需求通常更大，从而导致更高的隐含波动率。高级模型（如超越Black-Scholes模型的模型）通常会对OTM期权进行过高定价，以考虑到更高的风险。因此，ATM期权的隐含波动率通常较低，这使得对于资金经理而言，写入看涨期权通常比写入看跌期权更具吸引力。"





## Heston model parameters and equation



> **Heston model parameters and equation**

The Heston Model, which is utilized for option pricing, relies on stochastic differential equations (SDEs) as its fundamental concepts. 



To calculate the underlying asset price, the model uses equations as below: 

$$
dS_t = rS_tdt + \sqrt(V_t)S_tdW_{1t}
$$

$$
dV_t = k(\theta-V_t)dt + \sigma\sqrt(V_t)dW_{2t}
$$

*where*,

- **W<sub>1t</sub>** : the Brownian motion of the asset price
- **W<sub>2t</sub>** : the Brownian motion of the asset's price variance
- **ρ** : the correlation coefficient for W<sub>1t</sub> and W<sub>2t</sub>
- **S<sub>t</sub>** : the price of specific asset at time t
- **√V<sub>t</sub>** : the volatility of the asset price
- **σ** : the volatility of the volatility
- **r** : risk-free interest rate
- **θ** : long-term price variance
- **k** : the rate of reversion to the long-term price variance
- **dt** : the indefinitely small positive time increment



> **Equ1 : Stock price Dynamics (logarithmic price movement of underlying asset)**

$$
dS_t = \mu S_tdt + \sqrt(V_t)S_tdW_{1t}
\\
> S_t = S_{t-1}(1+ \mu*dt + \sqrt(V_{t-1})*dW_{1{(t-1)}})
$$


- **µ** : Coefficient, representing the expected return of the asset per unit time.

- **µS<sub>t</sub>dt (Expected Return) :** the average amount of the asset price, which can direct the movement of asset price. 

- **√v<sub>t</sub>S<sub>t</sub>dW<sub>1t</sub> (random Fluctuations) : ** it reflects the random ups and downs of asset price, which can be refered to "**market noise**"

  

**Equ2 : Volatility Dynamics**
$$
dV_t = k(\theta-V_t)dt + \sigma\sqrt(V_t)dW_{2t}
\\
> V_t = V_{t-1}+k*(\theta-V_{t-1}*dt+\sigma*\sqrt(V_{t-1})*dW_{2(t-1)})
$$

- **k(θ - v<sub>t</sub>)dt (Mean Reversion) :** "k" means "mean reversion rate", and θ is long-term average. the higher the k, the stronger the pull and drag back toward "θ (long-term average)"  

  k가 커질수록 기존 변동성이 롱텀 변동성 θ에 끌려가는 힘이 더욱 강해져 θ로 회귀

  **均值回归**：该项表明波动率v<sub>t</sub>会朝向长期平均值θ回归。具体地说，θ - v<sub>t</sub>是当前波动率与长期平均值之间的差距，而***k***是调整这个差距的速率。越高的***k***值意味着波动率会更强烈地向θ回归。

  **回归力量**：当波动率高于长期平均值时（θ < v<sub>t</sub>），均值回归项会推动波动率向下回归；而当波动率低于长期平均值时（θ > v<sub>t</sub>），均值回归项会推动波动率向上回归。



- **σ√ (v<sub>t</sub>)dW<sub>2t</sub> (Random Shocks):** volatility can also exprience "unexpected fluctuations", so the "random shocks" considers √ (v<sub>t</sub>) (the volatility's current level), and dW<sub>2t</sub> (random shock factor)



> **Example i : Stock price Dynamics**

**#Python**

```python
import numpy as np
import matplotlib.pyplot as plt

# Parameters of both equations
T = 1.0 # Total time
N = 1000 # Number of time steps
dt = T / N # Time step size
t = np.linspace(0.0, T, N+1) # Time vector
mu = 0.1 # Expected return
v0 = 0.1 # Initial volatility
kappa = 3.0 # Mean reversion rate
theta = 0.2 # Long-term average volatility
sigma = 0.1 # Volatility

dW1 = np.random.randn(N) * np.sqrt(dt)
dW2 = np.random.randn(N) * np.sqrt(dt)

S = np.zeros(N+1)
v = np.zeros(N+1)
S[0] = 100.0 # Initial stock price
v[0] = v0 # Initial volatility

# Euler-Maruyama method to solve the stochastic differential equation for stock price dynamics
for i in range(1, N+1):
    v[i] = v[i-1] + kappa * (theta - v[i-1]) * dt + sigma * np.sqrt(v[i-1]) * dW2[i-1]
    S[i] = S[i-1] * (1 + mu * dt + np.sqrt(v[i-1]) * dW1[i-1])

# Plot the results
plt.figure(figsize=(10, 6))
plt.subplot(2, 1, 1)
plt.plot(t, S)
plt.title('Stock Price Dynamics')
plt.xlabel('Time')
plt.ylabel('Stock Price')
plt.grid(True)
```

**#R**

```R
pacman::p_load(plotly)

T = 1.0 # Total time
N = 1000 # Number of time steps
dt = T / N # Time step size
t = seq(0,T,by=dt) # Time vector
mu = 0.1 # Expected return
v0 = 0.1 # Initial volatility
kappa = 3.0 # Mean reversion rate
theta = 0.2 # Long-term average volatility
sigma = 0.1 # Volatility

dW1 = rnorm(N)*sqrt(dt)
dW2 = rnorm(N)*sqrt(dt)

#initial value for stock price and volatiliy
S = rep(0,N+1)
v = rep(0,N+1)

S[1] = 100
v[1] = v0

for (i in 2:(N+1)) {
  S[i] = S[i-1]*(1+mu * dt+sqrt(v[i-1]) * dW1[i-1])
  v[i] = v[i-1] + kappa * (theta - v[i-1]) * dt + sigma * sqrt(v[i-1]) * dW2[i-1]
}


#Visualization

sdvd = data.frame(
  stock = S,
  volt = v
)

p1 = sdvd %>% 
  plot_ly() %>% 
  add_lines(
    x=1:nrow(sdvd),
    y=~stock,
    name = "stock dynamic"
  )

p2 = sdvd %>% 
  plot_ly() %>% 
  add_lines(
    x=1:nrow(sdvd),
    y=~volt,
    name = "volatility dynamic"
  )

subplot(p1,p2,nrows=2)
```



**Result :** 

![image-20240902153130737](/Users/allenpark/Library/Application Support/typora-user-images/image-20240902153130737.png)



> **Steps for pricing Europe options using Heston model**
>
> Step i. Define model parameters 
>
> Step ii. Calculate the characteristic function
>
> Step iii. Calculate the option price



**Step i. Define model parameters (Heston characteristic model)** 



**Step ii. Calculate the Hestion characteristic function**

 The Heston model's characteristic function is a key mathematical tool used in option pricing, describing the joint distribution of the underlying asset price and its stochastic volatility at expiration.


$$
\phi(\mu,S_0,K,r,T,k,\theta,\rho,v_0) \\= exp(C(\mu,S_0,K,r,T,k,\theta,\rho,v_0))\\
=D((\mu,S_0,K,r,T,k,\theta,\rho,v_0)v_0 + iulog(S_0))
$$
*where*,

- **µ** : the integration variable 
- **S<sub>0</sub>** : the initial stock price
- **K** : the strike price
- **r** : risk-free interest rate
- **T** : the time to maturity
- **k(kappa)** : the rate of reversion to the long-term price variance
- **σ** : the volatility of the volatility
- **ρ** : the correlation coefficient between <u>the asset price and its volatility</u>
- **v<sub>0</sub>** : the initial volatility



**#Python**

```python
# Define characteristic functions
def heston_characteristic_function(u, S0, K, r, T, kappa, theta, sigma, rho, v0):
   xi = kappa - rho * sigma * 1j * u
   d = np.sqrt((rho * sigma * 1j * u - xi)**2 - sigma**2 * (-u * 1j - u**2))
   g = (xi - rho * sigma * 1j * u - d) / (xi - rho * sigma * 1j * u + d)
   C = r * 1j * u * T + (kappa * theta) / sigma**2 * ((xi - rho * sigma * 1j * u - d) * T - 2 * np.log((1 - g * np.exp(-d * T)) / (1 - g)))
   D = (xi - rho * sigma * 1j * u - d) / sigma**2 * ((1 - np.exp(-d * T)) / (1 - g * np.exp(-d * T)))
   return np.exp(C + D * v0 + 1j * u * np.log(S0))

```

**#R**

```R
#Heston Chracteristic model
  heston_chr <- function(u, S0, K, r, T, kappa, theta, sigma, rho, v0) {
    xi <- kappa - rho * sigma * 1i * u
    d <- sqrt((rho * sigma * 1i * u - xi)^2 - sigma^2 * (-1i * u - u^2))
    g <- (xi - rho * sigma * 1i * u - d) / (xi - rho * sigma * 1i * u + d)
    
    C <- r * 1i * u * T + (kappa * theta) / sigma^2 * ((xi - rho * sigma * 1i * u - d) * T - 2 * log((1 - g * exp(-d * T)) / (1 - g)))
    D <- (xi - rho * sigma * 1i * u - d) / sigma^2 * ((1 - exp(-d * T)) / (1 - g * exp(-d * T)))
    
    value <- exp(C + D * v0 + 1i * u * log(S0))
    return(value)
  }
```



**Step iii. Calculate the European option price (Fourier Inversion)**

 Fourier inversion is a mathematical method used to compute option prices, particularly in models like the Heston model. 

It involves integrating the characteristic function over a range of frequencies to obtain the option price.



$$
C(K) = e^{-rT} (\frac{1}2S_0 - \frac{1}{\pi} \int_0^\infty \ \frac{e^{-iu\ln(K)} \phi(u)}{iu}du) 
\\
\\
P(K) = e^{-rT} (\frac{1}{\pi} \int_0^\infty \ \frac{e^{-iu\ln(K)} \phi(u)}{iu}du) - S_0+Ke^{-rt}
$$
*Where,*

- **C(K)** : European call option price at the strike price "K"
- **P(K)** : European put option price at the strike price "K"
- **S<sub>0</sub>** : the initial stock price
- **K** : the strike price
- **r** : risk-free interest rate
- **T** : the time to maturity
- **ϕ (u)** : Characteristic function of the Heston model
- **e<sup>−iuln(K)</sup>** :Exponential term in the integrand
- **du** : Integration variable



**#Python**

```python
# Define functions to compute call and put options prices
def heston_call_price(S0, K, r, T, kappa, theta, sigma, rho, v0):
   integrand = lambda u: np.real(np.exp(-1j * u * np.log(K)) / (1j * u) * heston_characteristic_function(u - 1j, S0, K, r, T, kappa, theta, sigma, rho, v0))
   integral, _ = quad(integrand, 0, np.inf)
   return np.exp(-r * T) * 0.5 * S0 - np.exp(-r * T) / np.pi * integral


def heston_put_price(S0, K, r, T, kappa, theta, sigma, rho, v0):
   integrand = lambda u: np.real(np.exp(-1j * u * np.log(K)) / (1j * u) * heston_characteristic_function(u - 1j, S0, K, r, T, kappa, theta, sigma, rho, v0))
   integral, _ = quad(integrand, 0, np.inf)
   return np.exp(-r * T) / np.pi * integral - S0 + K * np.exp(-r * T)
```

**#R** 

```R
heston_call = function(S0, K, r, T, kappa, theta, sigma, rho, v0){

  #Heston Chracteristic model
  heston_chr <- function(u, S0, K, r, T, kappa, theta, sigma, rho, v0) {
    xi <- kappa - rho * sigma * 1i * u
    d <- sqrt((rho * sigma * 1i * u - xi)^2 - sigma^2 * (-1i * u - u^2))
    g <- (xi - rho * sigma * 1i * u - d) / (xi - rho * sigma * 1i * u + d)
    
    C <- r * 1i * u * T + (kappa * theta) / sigma^2 * ((xi - rho * sigma * 1i * u - d) * T - 2 * log((1 - g * exp(-d * T)) / (1 - g)))
    D <- (xi - rho * sigma * 1i * u - d) / sigma^2 * ((1 - exp(-d * T)) / (1 - g * exp(-d * T)))
    
    value <- exp(C + D * v0 + 1i * u * log(S0))
    return(value)
  }
  #Integrate 
  integral <- function(u, K, S0, r, T, kappa, theta, sigma, rho, v0) {
    Re((exp(-1i * u * log(K)) * heston_chr(u - 1i, S0, K, r, T, kappa, theta, sigma, rho, v0)) / (1i * u))
  }

  #Fourier Inversion Option Pricing model
  value = exp(-r*T)*(.5*S0-(1/pi)*integrate(integral, lower = 0, upper = Inf, K = K, S0 = S0, r = r, T = T, kappa = kappa, theta = theta, sigma = sigma, rho = rho, v0 = v0)$value)
  return(value)
}

heston_put = function(S0, K, r, T, kappa, theta, sigma, rho, v0){

  #Heston Chracteristic model
  heston_chr <- function(u, S0, K, r, T, kappa, theta, sigma, rho, v0) {
    xi <- kappa - rho * sigma * 1i * u
    d <- sqrt((rho * sigma * 1i * u - xi)^2 - sigma^2 * (-1i * u - u^2))
    g <- (xi - rho * sigma * 1i * u - d) / (xi - rho * sigma * 1i * u + d)
    
    C <- r * 1i * u * T + (kappa * theta) / sigma^2 * ((xi - rho * sigma * 1i * u - d) * T - 2 * log((1 - g * exp(-d * T)) / (1 - g)))
    D <- (xi - rho * sigma * 1i * u - d) / sigma^2 * ((1 - exp(-d * T)) / (1 - g * exp(-d * T)))
    
    value <- exp(C + D * v0 + 1i * u * log(S0))
    return(value)
  }

  #Integrate 
  integral <- function(u, K, S0, r, T, kappa, theta, sigma, rho, v0) {
    Re((exp(-1i * u * log(K)) * heston_chr(u - 1i, S0, K, r, T, kappa, theta, sigma, rho, v0)) / (1i * u))
  }

  #Fourier Inversion Option Pricing model
  value = exp(-r*T)*((1/pi)*integrate(integral, lower = 0, upper = Inf, K = K, S0 = S0, r = r, T = T, kappa = kappa, theta = theta, sigma = sigma, rho = rho, v0 = v0)$value) -S0+K*exp(-r*T)
  return(value)
}

```



> Example 

**#Python**

```python
call_price = heston_call_price(S0, K, r, T, kappa, theta, sigma, rho, v0)
put_price = heston_put_price(S0, K, r, T, kappa, theta, sigma, rho, v0)

print("European Call Option Price:", np.round(call_price, 2))
print("European Put Option Price:", np.round(put_price, 2))
```

**#R**

```R
#example : Call option price
heston_call(S0, K, r, T, kappa, theta, sigma, rho, v0)
#[1] 27.6263

# example : Put option price
heston_put(S0, K, r, T, kappa, theta, sigma, rho, v0)
#[1] 15.05811
```



