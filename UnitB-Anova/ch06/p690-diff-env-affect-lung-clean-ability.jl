include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1. load data
    desc=Stat2Table(690,"RadioactiveTwins","living on city or rural ,lung clean ability diff?",["TwinPair", "Env", "Rate"])
    data=@pipe load_rda(desc.name)#|>select(_,desc.feature)
    gdf=groupby(data,:Env)

# 2. onw-way anova 
   OneWayANOVATest(gdf[1].Rate,gdf[2].Rate)
   #= 
     outcome with 95% confidence: fail to reject h_0
     p-value:                     0.7037
   =#


   
