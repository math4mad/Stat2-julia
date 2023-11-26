#= 
  2d,3d system which method  estimate accuracy of valume
=#

## 1. load package
include("../../utils.jl")

## 2. load data
desc=Stat2Table(191,"Oysters","",[])
data_2d=@pipe load_rda(desc.name)|>select(_,["TwoD","Volume"])
data_3d=@pipe load_rda(desc.name)|>select(_,["ThreeD","Volume"])


## 3.  lin reg 
model_2d=lm(@formula(Volume ~TwoD), data_2d)
#= 
Volume ~ 1 + TwoD

Coefficients:
────────────────────────────────────────────────────────────────────────────────
                   Coef.  Std. Error      t  Pr(>|t|)     Lower 95%    Upper 95%
────────────────────────────────────────────────────────────────────────────────
(Intercept)  0.336699     0.907626     0.37    0.7135  -1.52249      2.19589
TwoD         0.000264885  2.13517e-5  12.41    <1e-12   0.000221148  0.000308622
────────────────────────────────────────────────────────────────────────────────
=#

model_3d=lm(@formula(Volume ~ThreeD),data_3d)
#= 
Volume ~ 1 + ThreeD

Coefficients:
─────────────────────────────────────────────────────────────────────────────
                  Coef.  Std. Error      t  Pr(>|t|)    Lower 95%   Upper 95%
─────────────────────────────────────────────────────────────────────────────
(Intercept)  0.419572    0.467128     0.90    0.3767  -0.537296    1.37644
ThreeD       2.47522e-6  1.03051e-7  24.02    <1e-19   2.26413e-6  2.68631e-6
─────────────────────────────────────────────────────────────────────────────
=#


## 4 . plot residuals
#fig=plot_linreg_residuals(model_2d,data_2d);save("UnitA-LinearRegression/ch01/imgs/ex-1.43-2d-measure.png",fig)
#fig=plot_linreg_residuals(model_3d,data_3d);save("UnitA-LinearRegression/ch01/imgs/ex-1.43-3d-measure.png",fig)

## 5. anova  

anova(model_2d)
#= 
Analysis of Variance

Type 1 test / F test

Volume ~ 1 + TwoD

Table:
───────────────────────────────────────────────────────────
             DOF   Exp.SS  Mean Square    F value  Pr(>|F|)
───────────────────────────────────────────────────────────
(Intercept)    1  3812.42    3812.42    2723.6254    <1e-28
TwoD           1   215.43     215.43     153.9039    <1e-12
(Residuals)   28    39.19       1.3998               
───────────────────────────────────────────────────────────
=#

anova(model_3d)
#= 
Analysis of Variance

Type 1 test / F test

Volume ~ 1 + ThreeD

Table:
───────────────────────────────────────────────────────────
             DOF   Exp.SS  Mean Square    F value  Pr(>|F|)
───────────────────────────────────────────────────────────
(Intercept)    1  3812.42    3812.42    9057.5602    <1e-35
ThreeD         1   242.84     242.84     576.9311    <1e-19
(Residuals)   28    11.79       0.4209               
───────────────────────────────────────────────────────────
=#

