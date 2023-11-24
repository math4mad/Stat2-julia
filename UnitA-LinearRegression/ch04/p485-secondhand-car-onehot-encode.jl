include("utils.jl")
using RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,TableTransforms,ScientificTypes
using  StatsBase
using  GLM,AnovaGLM

# 1. load data
    desc=Stat2Table(485,"ThreeCars2017","one hot code",["CarType", "Age", "Price", "Mileage", "Mazda6", "Accord", "Maxima"])
    data=@pipe load_rda(desc.name)
    