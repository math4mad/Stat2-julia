#TeenPregnancy

include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1. load data
    desc=Stat2Table(545,"TeenPregnancy","state's role in civilwar affects  now teen pregnancy?",["CivilWar","Teen"])
    data=@pipe load_rda(desc.name)|>select(_,desc.feature)
    gdf=groupby(data,:CivilWar)
    cats= @pipe keys(gdf).|>values(_)[1]|>String.(_)
    colors=[:purple,:red,:green,:blue]
# 2. dotplot,boxplot
    #fig=plot_dot_boxplot(gdf,cats,colors,"Teen")
    #save("./ch05/imgs/p545-dot-boxplot.png",fig)

#  3. anova 
    sample=[gdf[idx][:,:Teen] for (idx,cat) in enumerate(cats)]
    OneWayANOVATest(sample...)
    #=
      Test summary:
        outcome with 95% confidence: reject h_0
        p-value:                     0.0002

    =#