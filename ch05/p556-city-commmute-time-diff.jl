"""
ANOVA 的假设前提之一是参与试验的组件方差相等所以在执行 ANOVA 假设检验之前需要对方差齐性先做出检验
方法是 LeveneTest  

LeveneTest  检验为:
  h₀: 各组方差相等
  hₐ: 组件方差不等 
"""

include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1. load data
    desc=Stat2Table(554,"MetroCommutes","commute time difference?",["City","Distance","Time"])
    data=@pipe load_rda(desc.name)
    @pt first(data,5)
    #= 
        ┌───────────────────────────────────────────────────┬──────────┬───────┐
        │                                              City │ Distance │  Time │
        │ CategoricalArrays.CategoricalValue{String, UInt8} │    Int32 │ Int32 │
        ├───────────────────────────────────────────────────┼──────────┼───────┤
        │                                            Boston │        8 │    20 │
        │                                            Boston │        5 │    30 │
        │                                            Boston │       10 │    40 │
        │                                            Boston │       10 │    15 │
        │                                            Boston │       15 │    25 │
        └───────────────────────────────────────────────────┴──────────┴───────┘
    =#

    gdf=groupby(data,:City)
    cats=levels(data[:,:City])
    colors=[:green,:orange,:blue,:purple]
    sample=[gdf[idx][:,:Time] for (idx,cat) in enumerate(cats)]

#2.  dot plot
     #fig=plot_dot_boxplot(gdf,cats,colors,"Time")   
     #save("./ch05/imgs/p556-commute-time-group-dot-boxplot.png",fig)

#3.  LeveneTest
     
     LeveneTest(sample...)  
     #= 
        Test summary:
        outcome with 95% confidence: reject h_0
        p-value:                     <1e-05

      由于拒绝 h₀所以不能直接使用 ANOVA 检验
     =#
