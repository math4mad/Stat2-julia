#= 
  植物叶子宽度会随着环境温度升高而减小,探索时间与叶子宽度的线性
  关系
=#

## 1. load package
include("../../utils.jl")

## 2. load data
desc=Stat2Table(178,"LeafWidth","Year-LeafWidth-Linreg",["Width", "Length", "LWRatio", "Area", "Year"])
data=@pipe load_rda(desc.name)|>select(_,["Year","Width"])

## 3.  lin reg
model=lm(@formula(Width ~Year), data)

#= 
Width ~ 1 + Year

Coefficients:
─────────────────────────────────────────────────────────────────────────────
                  Coef.  Std. Error      t  Pr(>|t|)   Lower 95%    Upper 95%
─────────────────────────────────────────────────────────────────────────────
(Intercept)  37.7231     8.57498      4.40    <1e-04  20.8347     54.6115
Year         -0.0175603  0.00435805  -4.03    <1e-04  -0.0261434  -0.00897711
─────────────────────────────────────────────────────────────────────────────
=#


## 4. plot results

 fig=plot_linreg_residuals(model,data)#;save("UnitA-LinearRegression/ch01/imgs/ex-1.15-plot-linreg-residuals.png",fig)

 