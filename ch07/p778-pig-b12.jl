include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,Query,FreqTables
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests,AnovaMixedModels

# 1.  load data
    desc=Stat2Table(778,"PigFeed","antibotics affect pig gain weight by b12",["WgtGain","Antibiotic","B12"])
    data=@pipe load_rda(desc.name)

#2. construct contingency table

    gdf=groupby(data,["Antibiotic","B12"])
    M=@pipe [mean(df[:,:WgtGain]) for df in gdf].|>round.(_,digits=2)|>reshape(_,(2,2))
     c1=["b12(0mg)","b12(5mg)","Diff"]
     c2=[M[1,1],M[2,1],M[2,1]-M[1,1]]
     c3=[M[1,2],M[2,2],M[2,2]-M[1,2]]
     c4=[M[1,2]-M[1,1],M[2,2]-M[2,1],nothing]
     ctable=DataFrame(b12=c1,antibotics_0mg=c2,antibotics_5mg=c3,Diff=c4)
     #@pt ctable
     #=     ┌──────────┬────────────────┬────────────────┬─────────────────────┐
            │      b12 │ antibotics_0mg │ antibotics_5mg │                Diff │
            │   String │        Float64 │        Float64 │ U{Nothing, Float64} │
            ├──────────┼────────────────┼────────────────┼─────────────────────┤
            │ b12(0mg) │           19.0 │            3.0 │               -16.0 │
            │ b12(5mg) │           22.0 │           54.0 │                32.0 │
            │     Diff │            3.0 │           51.0 │             nothing │
            └──────────┴────────────────┴────────────────┴─────────────────────┘
     =#


#3. anova  

    #model = lm(@formula(WgtGain ~ Antibiotic*B12 ), data)
    #anova(model)
    #= 
        WgtGain ~ 1 + Antibiotic + B12 + Antibiotic & B12

        Table:
        ───────────────────────────────────────────────────────────────
                        DOF   Exp.SS  Mean Square   F value  Pr(>|F|)
        ───────────────────────────────────────────────────────────────
        (Intercept)         1  7203.00      7203.00  198.7034    <1e-06
        Antibiotic          1   192.00       192.00    5.2966    0.0504
        B12                 1  2187.00      2187.00   60.3310    <1e-04
        Antibiotic & B12    1  1728.00      1728.00   47.6690    0.0001
        (Residuals)         8   290           36.25              
        ───────────────────────────────────────────────────────────────
    =#

# 4.  interaction plot

     function plot_twoway_interaction(df::AbstractDataFrame)
         fig=Figure(resolution=(800,350))
         ax1=Axis(fig[1,1];xlabel="Antibotics(mg)",ylabel="Mean Weight Gain")
         ax1.xticks=([0,40])
         ax2=Axis(fig[1,2];xlabel="B12(mg)",ylabel="Mean Weight Gain")
         ax2.xticks=([0,5])
         scatterlines!(ax1,[0,40],[df[1,2],df[1,3]];linestyle=:dash,color=:purple,label="B12(0mg)")
         scatterlines!(ax1,[0,40],[df[2,2],df[2,3]];label="B12(5mg)")
         scatterlines!(ax2,[0,5],[df[1,2],df[2,2]];linestyle=:dash,color=:purple,label="Antibotics(0mg)")
         scatterlines!(ax2,[0,5],[df[1,3],df[2,3]];label="Antibotics(40mg)")
         axislegend(ax1;position=:lt);axislegend(ax2;position=:lt)
         fig
     end

     fig=plot_twoway_interaction(ctable)
     #save("./ch07/p778-interaction-plot.png",fig)