include("utils.jl")
using  GLMakie,DataFrames,Pipe,PrettyTables,StatsBase
using  DataFrames
using GLM,AnovaGLM

desc=Stat2Table(256,"MetabolicRate","ch02/metabolic-rate-log-transform-reg",[:LogBodySize,:LogMrate])
data=@pipe load_rda(desc.name)|>select(_,desc.feature)

fig,_=plot_pair_scatter(data;xlabel="LogBodySize",ylabel="LogMrate");fig
#save("LogBodySize-LogMrate-scatter.png",fig)
lm_model=lm(@formula(LogMrate ~ LogBodySize ),data)
anove_table=anova(lm_model)

#= 
  Analysis of Variance

Type 1 test / F test

LogMrate ~ 1 + LogBodySize

Table:
────────────────────────────────────────────────────────────
             DOF    Exp.SS  Mean Square    F value  Pr(>|F|)
────────────────────────────────────────────────────────────
(Intercept)    1  120.81       120.81    3935.1217    <1e-99
LogBodySize    1  169.02       169.02    5505.2553    <1e-99
(Residuals)  303    9.3026       0.0307               
────────────────────────────────────────────────────────────
SSModel=120.81+169.02
SSE= 9.3026 
SSTotal=SSModel+SSE
=#

R²=r2(lm_model)  #0.9478328720043627

teststat(anove_table)