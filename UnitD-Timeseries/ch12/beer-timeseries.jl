include("utils.jl")
    using  RCall
    using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,FreqTables
    using  StatsBase,TableTransforms
    using  GLM,AnovaGLM,HypothesisTests

#1.   load data
    desc=Stat2Table(000,"ausbeer","https://online.stat.psu.edu/stat510/lesson/1/1.1",[:value])
    data=@pipe load_rda(desc.name)
#2.   plot series

    #lines(data)

#    plot quarto autocor

     stem(autocor(data))