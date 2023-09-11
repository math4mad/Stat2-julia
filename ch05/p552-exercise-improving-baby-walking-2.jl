"""
实验分为 4 个组:

1. 结合训练方法, 并且每周询问进展
2. 没有使用训练方法, 但是鼓励每天让婴儿练习 15 分钟,并且每周询问进展
3. 没有训练, 也没有鼓励练习, 但是每周询问进展
4. 没有任何措施, 只询问最终开始走路的时间点

以 LM 的方法实现 anova
以 LM 方法看anova,方差分析可以表示为:总均值+处理效应+残差
"""


include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1. load data
    desc=Stat2Table(552,"WalkingBabies","exercise  reduce first walking time of baby?",["Grpup","Age"])
    data=@pipe load_rda(desc.name)
    @pt first(data,5)
    #= 
        ┌───────────────────────────────────────────────────┬─────────┐
        │                                             Group │     Age │
        │ CategoricalArrays.CategoricalValue{String, UInt8} │ Float64 │
        ├───────────────────────────────────────────────────┼─────────┤
        │                                 special exercises │     9.0 │
        │                                 special exercises │     9.5 │
        │                         ⋮                         │    ⋮    │
        └───────────────────────────────────────────────────┴─────────┘
    =#
   gdf=groupby(data,:Group)
   cats=levels(data[:,:Group])
   colors=[:green,:orange,:blue,:purple]
   
    #= 
    ["exercise control", "final report", "special exercises", "weekly report"]
    =#

#2.  dot plot
     #fig=plot_dot_boxplot(gdf,cats,colors,"Age")   
     #save("./ch05/imgs/p552-babaywalking-group-dot-boxplot.png",fig)

#3.  anova 分析
    #res=anova_lm(@formula(Age ~Group), data)
    model=lm(@formula(Age ~Group), data)
    anova(model)
    #= 
        Analysis of Variance

        Type 1 test / F test

        Age ~ 1 + Group

        Table:
        ───────────────────────────────────────────────────────────
                    DOF   Exp.SS  Mean Square    F value  Pr(>|F|)
        ───────────────────────────────────────────────────────────
        (Intercept)    1  3105.60    3105.60    1398.8439    <1e-19
        Group          3    15.60       5.1991     2.3418    0.1039
        (Residuals)   20    44.40       2.2201               
        ───────────────────────────────────────────────────────────
    =#

