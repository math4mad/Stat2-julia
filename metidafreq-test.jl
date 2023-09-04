"""
test metidafreq.jl

"""


include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,FreqTables
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests
using MetidaFreq,CSV

# 1.  load data
    #desc=Stat2Table(1106,"LosingSleep","children sleep status",["Age","Outcome"])
    #data=@pipe load_rda(desc.name)|>select(_,desc.feature)|>Float64.(_)

    df = CSV.File(joinpath(dirname(pathof(MetidaFreq)), "..", "test", "csv",  "ft.csv")) |> DataFrame
     
    #= 
        Row │ col      row      s1       s2      
            │ String1  String1  String1  String1 
       ─────┼────────────────────────────────────
          1 │ a        c        e        g
          2 │ a        c        e        g
        170 │ a        d        f        i
        171 │ a        d        f        i
    =#
    ct = MetidaFreq.contab(df, :row, :col)
    #= 
        Contingency table:
        --- ---- ---- -------
            b    a   Total 
        --- ---- ---- -------
        c   20   24      44
        d   83   44     127
        --- ---- ---- -------
    =#