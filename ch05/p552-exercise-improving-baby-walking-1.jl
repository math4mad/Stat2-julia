"""
实验分为 4 个组:

1. 结合训练方法, 并且每周询问进展
2. 没有使用训练方法, 但是鼓励每天让婴儿练习 15 分钟,并且每周询问进展
3. 没有训练, 也没有鼓励练习, 但是每周询问进展
4. 没有任何措施, 只询问最终开始走路的时间点

results:
    Test summary:
    outcome with 95% confidence: fail to reject h_0
    p-value:                     0.1039
    方法之间没有差异
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

#4.  anova 分析
    sample=[gdf[idx][:,:Age] for (idx,cat) in enumerate(cats)]
    #OneWayANOVATest(sample...)
#5.  anova results

    #= 
        One-way analysis of variance (ANOVA) test
        -----------------------------------------
        Population details:
            parameter of interest:   Means
            value under h_0:         "all equal"
            point estimate:          NaN

        Test summary:
            outcome with 95% confidence: fail to reject h_0
            p-value:                     0.1039

        Details:
            number of observations: [6, 6, 6, 6]
            F statistic:            2.34179
            degrees of freedom:     (3, 20)
    =#

#6. LeveneTest

    LeveneTest(sample...)
    #= 
                Levene's test
            -------------
            Population details:
                parameter of interest:   Variances
                value under h_0:         "all equal"
                point estimate:          NaN

            Test summary:
                outcome with 95% confidence: fail to reject h_0
                p-value:                     0.6717

            Details:
                number of observations: [6, 6, 6, 6]
                W statistic:            0.522486
                degrees of freedom:     (3, 20)
    =#
