"""
 StateSpaceModels.jl   DAR 模型
"""

include("utils.jl")
import  StateSpaceModels:fit!
using  GLMakie,DataFrames,Pipe,PrettyTables,StatsBase
using GLM,AnovaGLM,TimeSeries,StateSpaceModels

#step1  load data
        desc=Stat2Table(1463,"ResidualOil","glimpse dataset",["Year", "Qtr", "t", "Oil", "LogOil"])
        data=@pipe load_rda(desc.name)
#step2  DAR  model
        # Oil=data[:,:Oil]
        # model = LocalLevel(Oil)
        # fit!(model)
        # results(model)

#step3  test

            y = randn(100)

            model = LocalLevel(y)

            fit!(model)

            results(model)
        