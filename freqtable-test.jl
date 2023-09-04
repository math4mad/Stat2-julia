"""
使用 freqtable  聚合频数数据
"""


include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,FreqTables
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1.  load data
    desc=Stat2Table(1106,"LosingSleep","children sleep status",["Age","Outcome"])
    data=@pipe load_rda(desc.name)|>select(_,desc.feature)|>Float64.(_)

    res=freqtable(data, :Age, :Outcome)

    
    #total=res[:,1]+res[:,2]
    #data2=DataFrame(m7=res[:,2],l7=res[:,1],com=total,ratio=res[:,2]./total)
    

