include("utils.jl")
using  GLMakie,DataFrames,Pipe,PrettyTables,StatsBase
using GLM,AnovaGLM

desc=Stat2Table(138,"CountyHealth","hospital-predict-doctors-number",["County","MDs","Hospitals","Beds"])
data=@pipe load_rda(desc.name)|>select(_,desc.feature[1:3])
@pt  data[1:5,:]
#= 
    ┌───────────────────────────────────────────────────┬───────┬───────────┐
    │                                            County │   MDs │ Hospitals │
    │ CategoricalArrays.CategoricalValue{String, UInt8} │ Int32 │     Int32 │
    ├───────────────────────────────────────────────────┼───────┼───────────┤
    │              Bay, FL                              │   351 │         3 │
    │              Beaufort, NC                         │    95 │         2 │
    │              Beaver, PA                           │   260 │         2 │
    │              Bernalillo, NM                       │  2797 │        11 │
    │              Bibb, GA                             │   769 │         5 │
    └───────────────────────────────────────────────────┴───────┴───────────┘
=#



