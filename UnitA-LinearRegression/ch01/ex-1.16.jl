#= 
  有些昆虫雌性会通过发光来吸引雄性, 由此增加交配的机会, 
  从而产下更多的卵
=#

## 1. load package
include("../../utils.jl")

## 2. load data
desc=Stat2Table(178,"GlowWorms","",["Lantern","Eggs"])
data=@pipe load_rda(desc.name)

## 3. fit model 
model=lm(@formula(Eggs ~Lantern), data)
#= 
Eggs ~ 1 + Lantern

Coefficients:
────────────────────────────────────────────────────────────────────────
                Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
────────────────────────────────────────────────────────────────────────
(Intercept)  -8.97684    21.8685   -0.41    0.6851  -54.1113     36.1576
Lantern       7.32514     1.75687   4.17    0.0003    3.69914    10.9511
────────────────────────────────────────────────────────────────────────
=#

## 4. plot results

fig=plot_linreg_residuals(model,data)#;save("UnitA-LinearRegression/ch01/imgs/ex-1.16-plot-linreg-residuals.png",fig)