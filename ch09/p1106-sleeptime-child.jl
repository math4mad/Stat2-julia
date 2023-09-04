include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,Query
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1. load data
    desc=Stat2Table(1106,"LosingSleep","children sleep status",["Age","Outcome"])
    data=@pipe load_rda(desc.name)|>select(_,desc.feature)|>Float64.(_)
    gdf=groupby(data,:Age)
    cats=keys(gdf).|>values.|>d->d[1]
    
    m7=[]
    l7=[]
    for  df in gdf
       local  x = @from i in df begin
            @where i.Outcome ==1.0
            @select i
            @collect DataFrame
        end
        push!(m7,nrow(x))
        push!(l7,nrow(df)-nrow(x))
    end
   
   total=m7.+ l7
   prop=m7 ./ total

   agg_df=DataFrame(Age=Int64.(cats),more7=Int64.(m7),less7=Int64.(l7),total=total,more7proprotion=round.(prop,digits=2))
   @pt agg_df
   
     #= 
        ┌───────┬───────┬───────┬───────┬─────────────────┐
        │   Age │ more7 │ less7 │ total │ more7proprotion │
        │ Int64 │ Int64 │ Int64 │ Int64 │         Float64 │
        ├───────┼───────┼───────┼───────┼─────────────────┤
        │    14 │    34 │    12 │    46 │            0.74 │
        │    15 │    79 │    35 │   114 │            0.69 │
        │    16 │    77 │    37 │   114 │            0.68 │
        │    17 │    65 │    39 │   104 │            0.62 │
        │    18 │    41 │    27 │    68 │             0.6 │
        └───────┴───────┴───────┴───────┴─────────────────┘
     =#
   
     combine(gdf, :Outcome=>(o ->filter(x->x==1,o))=> :m7)
    


    



    

    