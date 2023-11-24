"""
dataframe   combine nrow  
combine(gd, :c => sum, nrow, ungroup=false)
"""


include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,Query
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1. load data
    desc=Stat2Table(1106,"LosingSleep","children sleep status",["Age","Outcome"])
    data=@pipe load_rda(desc.name)|>select(_,desc.feature)|>Float64.(_)
    gdf=groupby(data,:Age)
    cats=keys(gdf).|>values.|>d->d[1]

    #row_gdf=combine(gdf,nrow=>:total, :Outcome=>(x->x.==1.0)=>nrows=>:m7, ungroup=false)
    #row_gdf[1]

    stack(data,:Outcome)


    