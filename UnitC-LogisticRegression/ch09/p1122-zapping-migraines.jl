include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,Query
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1. load data

    desc=Stat2Table(1122,"Migraines","tms treatment of migraines",["Group", "Yes", "No", "Trials"])
    data=@pipe load_rda(desc.name)
    first(data,10)
    