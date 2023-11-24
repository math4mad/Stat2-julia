include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,Query
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1. load data

    desc=Stat2Table(1201,"Eyes","sexual attitude",["DilateDiff", "Sex", "Gay", "SexMale"])
    data=@pipe load_rda(desc.name)
    @pt first(data,5)
    gdf=groupby(data,:Gay)
    #= 
        ┌────────────┬───────────────────────────────────────────────────┬───────┬─────────┐
        │ DilateDiff │                                               Sex │   Gay │ SexMale │
        │    Float64 │ CategoricalArrays.CategoricalValue{String, UInt8} │ Int32 │   Int32 │
        ├────────────┼───────────────────────────────────────────────────┼───────┼─────────┤
        │   0.208042 │                                                 M │     0 │       1 │
        │   0.165694 │                                                 F │     0 │       0 │
        │  -0.260444 │                                                 M │     0 │       1 │
        │  -0.359692 │                                                 F │     0 │       0 │
        │  -0.488199 │                                                 M │     1 │       1 │
        └────────────┴───────────────────────────────────────────────────┴───────┴─────────┘
    =#
# 2.  groupby sexy  boxplot
    cats=["0","1"]
    colors=[:purple,:blue]
    #fig=plot_dot_boxplot(gdf,cats,colors,"DilateDiff")
    #save("./ch10/imgs/p1201-boxplot.png",fig)

# 3. 聚合生成表格
     #= 
            ┌─────────────────────────┬───────┬─────────────┬───────┐
            │                   Range │     n │        mean │   gay │
            │ Tuple{Float64, Float64} │ Int64 │     Float64 │ Int64 │
            ├─────────────────────────┼───────┼─────────────┼───────┤
            │          (-1.1, -0.301) │    27 │   -0.516925 │     4 │
            │          (-0.3, -0.074) │    26 │   -0.179788 │     7 │
            │          (-0.073, 0.07) │    26 │ -0.00444028 │    10 │
            │            (0.071, 1.3) │    27 │    0.417409 │    16 │
            └─────────────────────────┴───────┴─────────────┴───────┘
     =#
    

    Range=[(-1.1,-0.301),(-0.3,-0.074),(-0.073,0.070),(0.071,1.3)]
    gdf2=[filter(row -> r[1]<row.DilateDiff<r[2], data) for r in Range]
    combine_df(gdf)=combine(gdf,nrow=>:n,:DilateDiff=>(x->mean(x))=>:mean,
                             :Gay=>(x->filter(i->i==1,x)|>length)=>:gay)
    agg_df=mapreduce(combine_df,vcat,gdf2)
    insertcols!(agg_df,1,:Range=>Range)
    #@pt agg_df

# 4.  

   model1 = glm(@formula(Gay ~DilateDiff), gdf2[1], Binomial(), ProbitLink())
   predict(model1,select(gdf2[1],:DilateDiff))|>mean


    
    

    


