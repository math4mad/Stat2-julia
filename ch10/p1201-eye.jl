include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,Query
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1. load data

    desc=Stat2Table(1201,"Eyes","sexual attitude",["DilateDiff", "Sex", "Gay", "SexMale"])
    data=@pipe load_rda(desc.name)
    