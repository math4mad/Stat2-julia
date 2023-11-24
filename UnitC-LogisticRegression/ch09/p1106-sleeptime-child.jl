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
   
     #= TABLE 9.2
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
   
    #combine(gdf, :Outcome=>(o ->filter(x->x==1,o))=> :m7)
    
#2.  plot  every group  sleep more than 7 hours porprotion

    fig1,ax1,pl1=scatter(agg_df[:,:Age],agg_df[:,:more7proprotion];msstyle...)
    ax1.limits=(0,40,0.0,1.0)

 #3.   fit lm 
     xtest=DataFrame(Age=Vector(0:1:40))
     model1=lm(@formula(more7proprotion ~Age),agg_df) 
     
     yhat1=predict(model1,xtest)
     #lines!(ax1,xtest[:,:Age],yhat1)
     #save("./ch09/imgs/p1106-losingsleeping-(age-more7sleep)-reg.png",fig1)
 
#4.   logistic lm
 
     model2 = glm(@formula(more7proprotion ~Age), agg_df, Binomial(), ProbitLink())

    #= 
        more7proprotion ~ 1 + Age

        Coefficients:
        ──────────────────────────────────────────────────────────────────────────
                        Coef.  Std. Error      z  Pr(>|z|)  Lower 95%  Upper 95%
        ──────────────────────────────────────────────────────────────────────────
        (Intercept)   1.9822       6.65293    0.30    0.7657  -11.0573   15.0217
        Age          -0.0968295    0.412635  -0.23    0.8145   -0.90558   0.711921
        ──────────────────────────────────────────────────────────────────────────
    =#
    yhat2=predict(model2,xtest)
    lines!(ax1,xtest[:,:Age],yhat2)
    #save("./ch09/imgs/p1106-losingsleeping-(age-more7sleep)-logistics-reg.png",fig1)



    

    