include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1.  load data
    desc=Stat2Table(699,"FranticFingers","drug affect response ability",["ID", "Rate", "Subj", "Drug"])
    data=@pipe load_rda(desc.name)
    gdf=groupby(data,:Subj)
    
# 2.  plot  side-by-side plot
    ls=[:dot,:dash,:dashdot,:solid]
    colors=[:purple,:blue,:red,:green]
    function plot_sbs()
        fig=Figure(resolution=(800,300))
        ax1=Axis(fig[1,1],xticks=(1:3,["Pi","Ca","H"]))
        ax2=Axis(fig[1,2],xticks=(1:3,["Pi","Ca","H"]))
        for (idx,df) in enumerate(gdf)
             lines!(ax1,1:3,df[:,"Rate"];linestyle=ls[idx],linewidth=3,color=colors[idx])
             scatter!(ax1,1:3,df[:,"Rate"];marker=:circle,markersize=10,color=(colors[idx],0.6),strokewidth=1,strokecolor=:black)
             [text!(ax1,i,df[i,"Rate"];text="$idx",color=colors[idx]) for i in 1:3]
             scatter!(ax2,1:3,df[:,"Rate"];marker=:circle,markersize=12,color=(colors[idx],0.6),strokewidth=1,strokecolor=:black)
        end
        fig
    end
    #fig=plot_sbs();save("./ch06/imgs/p699-FranticFingers-sidebyside-plot.png",fig)

# 3.  one way anova
    drug_gdf=groupby(data,:Drug)
    groups=[d[:,:Rate] for (idx,d) in enumerate(drug_gdf)]
    OneWayANOVATest(groups...)
    #= 
        Test summary:
        outcome with 95% confidence: fail to reject h_0
        p-value:                     0.5330
    =#     

# 4. wide data
    data_matrix=res= @pipe data[:,:Rate]|>reshape(_,(4,3))|>Int64.(_)
    function make_widedata(res)
        

        c1::Vector{String}=["A","B","C","D"]
        c2::Vector{Int64}=res[:,1]
        c3::Vector{Int64}=res[:,2]
        c4::Vector{Int64}=res[:,3]
        wide_data=DataFrame(Subj=c1,PI=c2,Ca=c3,Th=c4)
        ave_data=DataFrame(Subj=["Ave"],PI=mean(c2),Ca=mean(c3),Th=mean(c4))
        #transform(wide_data, [:PI,:Ca,:Th] => ByRow(+) => :Ave)
        combine_data=vcat(wide_data,ave_data)
        res=@rtransform(combine_data, :Ave =mean([:PI,:Ca,:Th]))
        return res
    end
    @pt make_widedata(res)
    #= 
        ┌────────┬─────────┬─────────┬─────────┬─────────┐
        │   Subj │      PI │      Ca │      Th │     Ave │
        │ String │ Float64 │ Float64 │ Float64 │ Float64 │
        ├────────┼─────────┼─────────┼─────────┼─────────┤
        │      A │    11.0 │    26.0 │    20.0 │    19.0 │
        │      B │    56.0 │    83.0 │    71.0 │    70.0 │
        │      C │    15.0 │    34.0 │    41.0 │    30.0 │
        │      D │     6.0 │    13.0 │    32.0 │    17.0 │
        │    Ave │    22.0 │    39.0 │    41.0 │    34.0 │
        └────────┴─────────┴─────────┴─────────┴─────────┘
    =#

    data_matrix
    pretty_table(data_matrix;tf=tf_matrix,show_header = false)
    #= 
        ┌            ┐
        │ 11  26  20 │
        │ 56  83  71 │
        │ 15  34  41 │
        │  6  13  32 │
        └            ┘
    =#

    ave_matrix=@pipe data[:,:Rate]|>mean|>fill(_,12)|>reshape(_,(4,3))|>Int64.(_)
    pretty_table(ave_matrix;tf=tf_matrix,show_header = false)
    #= 
        ┌            ┐
        │ 34  34  34 │
        │ 34  34  34 │
        │ 34  34  34 │
        │ 34  34  34 │
        └            ┘
    =#

    pretty_table(data_matrix-ave_matrix;tf=tf_matrix,show_header = false)
    #= 
        ┌               ┐
        │ -23   -8  -14 │
        │  22   49   37 │
        │ -19    0    7 │
        │ -28  -21   -2 │
        └               ┘
    =#
    # estimated effects
     #data2=make_widedata(res)
     #@transform(data2, :Effect =:Ave.-34.0)

# 5. drug effect

     


  """
  怎么想到用 anovabase 做two-way anova ?
  """
# 6. two-way anova 
     anova_lm(@formula(Rate~Drug +Subj),data)
    #= 
        Rate ~ 1 + Drug + Subj

        Table:
        ───────────────────────────────────────────────────────────
                    DOF    Exp.SS  Mean Square   F value  Pr(>|F|)
        ───────────────────────────────────────────────────────────
        (Intercept)    1  13872.00     13872.00  250.6988    <1e-05
        Drug           2    872.00       436.00    7.8795    0.0210
        Subj           3   5478.00      1826.00   33.0000    0.0004
        (Residuals)    6    332           55.33              
        ───────────────────────────────────────────────────────────
    =#
     


   