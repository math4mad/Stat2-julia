include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1.  load data
    desc=Stat2Table(699,"Rectangles","",["Case", "Width", "Length", "Area", "logArea"])
    data=@pipe load_rda(desc.name)
    
