include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1. load data
    desc=Stat2Table(579,"Leafhoppers","diet affect life long of insect?",["Diet","Days"])
    data=@pipe load_rda(desc.name)
    @pt first(data,5)
    #= 
        ┌───────┬───────────────────────────────────────────────────┬─────────┐
        │  Dish │                                              Diet │    Days │
        │ Int32 │ CategoricalArrays.CategoricalValue{String, UInt8} │ Float64 │
        ├───────┼───────────────────────────────────────────────────┼─────────┤
        │     1 │                                           Control │     2.3 │
        │     2 │                                           Control │     1.7 │
        │     3 │                                           Sucrose │     3.6 │
        │     4 │                                           Sucrose │     4.0 │
        │     5 │                                           Glucose │     2.9 │
        └───────┴───────────────────────────────────────────────────┴─────────┘
    =#
#2.  anova 分析
    
    model=lm(@formula(Days ~Diet), data)
    anova(model)
    #= 
        Analysis of Variance

        Type 1 test / F test

        Days ~ 1 + Diet

        Table:
        ──────────────────────────────────────────────────────────
                    DOF   Exp.SS  Mean Square   F value  Pr(>|F|)
        ──────────────────────────────────────────────────────────
        (Intercept)    1  58.32        58.32    777.6000    <1e-05
        Diet           3   3.9200       1.3067   17.4222    0.0092
        (Residuals)    4   0.3000       0.0750              
        ──────────────────────────────────────────────────────────
    =#

#3.  results
        """
        pvalue=0.0092<0.05 因此拒绝 0 假设, 食物添加糖后对leafhopper 的寿命有影响
        """


