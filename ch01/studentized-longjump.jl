"""
 outliers  detection
"""


include("utils.jl")
using  GLMakie,DataFrames,Pipe,PrettyTables,StatsBase
using GLM

desc=Stat2Table(172,"LongJumpOlympics2016","zscore-outliers",["Year","Gold"])
df=@pipe load_rda(desc.name)

model=lm(@formula(Gold ~Year), df)
#= 
    Gold ~ 1 + Year

    Coefficients:
    ───────────────────────────────────────────────────────────────────────────────
                    Coef.  Std. Error      t  Pr(>|t|)     Lower 95%   Upper 95%
    ───────────────────────────────────────────────────────────────────────────────
    (Intercept)  -16.4702     2.66628     -6.18    <1e-05  -21.9508      -10.9896
    Year           0.0125085  0.00136096   9.19    <1e-08    0.00971099    0.015306
    ───────────────────────────────────────────────────────────────────────────────
=#

studresiduals=residuals(model)|>zscore

#extrema(studresiduals)

function plot_studres()
   fig=Figure()
   ax=Axis(fig[1,1])
   ax.limits=(1900,2020,-4,4)
   scatter!(ax,df[:,1],studresiduals;marker=:circle,markersize=12,color=(:red,0.4),strokewidth=2,strokecolor=:purple)
   hlines!(ax,[-3,-2,2,3],linestyle=:dash,color=(:red),linewidth=4)
   fig
end

#plot_studres()

#TODO - 没有完成, studantized 方法还没有实现
studresiduals=residuals(model)|>zscore
deviance(model)
