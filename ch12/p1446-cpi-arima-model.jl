include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,FreqTables
using  StatsBase,TableTransforms,Random,TimeSeries,Dates
using  GLM,AnovaGLM,HypothesisTests,Distributions
Random.seed!(34343)

#1. load data
        desc=Stat2Table(1446,"Inflation","arima model",["Month", "Year", "CPI", "CPIPctDiff", "t"])
        data=@pipe load_rda(desc.name)|>@transform!(_, :time=Date.(:Year,:Month))|>select(_,[:time,:CPI])
        
        ts=TimeArray(data, timestamp = :time)
        #= 
            ┌───────┬───────┬─────────┬────────────┬───────┐
            │ Month │  Year │     CPI │ CPIPctDiff │     t │
            │ Int32 │ Int32 │ Float64 │    Float64 │ Int32 │
            ├───────┼───────┼─────────┼────────────┼───────┤
            │     1 │  2009 │ 211.143 │      0.435 │     1 │
            │     2 │  2009 │ 212.193 │      0.497 │     2 │
            │     3 │  2009 │ 212.709 │      0.243 │     3 │
            └───────┴───────┴─────────┴────────────┴───────┘
        =#
#2.     lag
    
     diff_order(order)=@pipe diff(ts,order)|>DataFrame|>select(_,[:CPI])|>_[:,1]
     firstorder_diff=diff_order(1)
     lags=@pipe lag(ts)|>DataFrame|>_[:,2]
     firstorder_diff_ar=autocor(firstorder_diff)
     lag_ar=autocor(lags)
     stem(lag_ar)