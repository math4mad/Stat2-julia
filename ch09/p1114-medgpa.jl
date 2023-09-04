


include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,Query
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1. load data

    desc=Stat2Table(1106,"MedGPA","children sleep status",["Accept","Acceptance","GPA","MCAT"])
    data=@pipe load_rda(desc.name)|>select(_,desc.feature)

# logistic  reg
    #model=glm(@formula(Acceptance~GPA+MCAT), data, Binomial(), ProbitLink())
    model1=lm(@formula(MCAT~GPA), data)
    model2=glm(@formula(Acceptance~GPA), data, Binomial(), ProbitLink())

    
    