include("utils.jl")
using RCall
using  GLMakie,DataFrames,Pipe,PrettyTables
using  StatsBase
using  GLM,AnovaGLM

# 1. load data
    desc=Stat2Table(442,"FirstYearGPA","predictors select",["HSGPA", "SATV", "SATM", "HU", "SS","GPA"])
    data=@pipe load_rda(desc.name)|>select(_,desc.feature)

# 2. pair plot
    fig=plot_cor_group(data)#;save("./ch04/imgs/gpa-feature-pairplot.png",fig)


    