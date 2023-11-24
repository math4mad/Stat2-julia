include("../utils.jl")
using  GLMakie,DataFrames,Pipe,PrettyTables,StatsBase
using GLM,AnovaGLM

desc=Stat2Table(138,"CountyHealth","hospital-predict-doctors-number",["County","MDs","Hospitals","Beds"])
data=@pipe load_rda(desc.name)|>select(_,desc.feature[1:3])
