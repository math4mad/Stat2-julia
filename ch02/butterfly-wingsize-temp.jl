include("utils.jl")
using  GLMakie,DataFrames,Pipe,PrettyTables,StatsBase
using GLM,AnovaGLM

desc=Stat2Table(138,"ButterfliesBc","wings-tempature-reg",["Temp","Wing","Sex","Species" ])
df=@pipe load_rda(desc.name)|>select(_,desc.feature[1:3])
data=groupby(df,:Sex)[1]

# 1. scatter
fig,ax=plot_pair_scatter(data;xlabel="Temp",ylabel="Wing");fig

#lm fitting
model=lm(@formula(Wing ~Temp), data)
#= 
    Wing ~ 1 + Temp
    Coefficients:
    ───────────────────────────────────────────────────────────────────────────
                    Coef.  Std. Error       t  Pr(>|t|)  Lower 95%   Upper 95%
    ───────────────────────────────────────────────────────────────────────────
    (Intercept)  19.3439     0.187211   103.33    <1e-20  18.9423    19.7454
    Temp         -0.238814   0.0794577   -3.01    0.0094  -0.409234  -0.0683939
    ───────────────────────────────────────────────────────────────────────────
=#

# four plot about lm model
plot_lm_res(;data=data,xlabel="Temp",ylabel="Wing",model=model)


#  R²
r2(model)  #0.392184274356429

