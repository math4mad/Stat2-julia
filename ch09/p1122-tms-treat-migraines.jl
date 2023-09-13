include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,Query
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1. load data

    desc=Stat2Table(1122,"Migraines","tms teat Migraines",["Accept","Acceptance","GPA","MCAT"])
    data=@pipe load_rda(desc.name)
    
    #= 
        Row │ Group    Yes    No     Trials 
            │ Cat…     Int32  Int32  Int32  
       ─────┼───────────────────────────────
          1 │ TMS         39     61     100
          2 │ Placebo     22     78     100
    =#

