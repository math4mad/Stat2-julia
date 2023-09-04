include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1. load data
    desc=Stat2Table(693,"SleepingShrews","sleep status",["Shrew","Phase","Rate"])
    data=@pipe load_rda(desc.name)|>select(_,desc.feature)
    gdf=groupby(data,:Phase)
# 2. anova
    OneWayANOVATest(gdf[1][:,:Rate],gdf[2][:,:Rate],gdf[3][:,:Rate])  
    #= 
        outcome with 95% confidence: fail to reject h_0
        p-value:                     0.5973
    =#

# 3.  make wide  list
   arr=[]
   gdf2=groupby(data,:Shrew)
   cats=keys(gdf2).|>values.|>d->d[1]
   for (idx,df) in enumerate(gdf2)
        temp=permutedims(df,2,"Shrew")
        temp[2,1]=cats[idx]
        push!(arr, DataFrame(temp[2,:]))
 
   end
   wide_df=vcat(arr...)
   @pt wide_df
   #= 
    ┌────────┬──────┬──────┬──────┐
    │  Shrew │  LSW │  DSW │  REM │
    │ String │  Any │  Any │  Any │
    ├────────┼──────┼──────┼──────┤
    │      A │ 14.0 │ 11.7 │ 15.7 │
    │      B │ 25.8 │ 21.1 │ 21.5 │
    │      C │ 20.8 │ 19.7 │ 18.3 │
    │      D │ 19.0 │ 18.2 │ 17.1 │
    │      E │ 26.0 │ 23.2 │ 22.5 │
    │      F │ 20.4 │ 20.7 │ 18.9 │
    └────────┴──────┴──────┴──────┘
   =#
   
