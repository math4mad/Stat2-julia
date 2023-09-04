include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
using  StatsBase
using  GLM,AnovaGLM

# 1. load data
    desc=Stat2Table(409,"BrainpH","research in brain tissue ",["pH", "Sex", "Age"])
    df=@pipe load_rda(desc.name)|>select(_,desc.feature)
    gdf=groupby(df,:Sex)

# 2. plot group pairplot
     feature=["Age","pH"]
     cats=["F","M"]
     colors::Vector{Symbol}=[:purple,:blue]
     #fig=plot_group_scatter2(gdf,feature,cats,colors)
     #save("p409-diff-gender-scatter.png",fig)

# 3. fit lm model
      lm_girl=lm(@formula(pH ~ Age),gdf[1])
      #= 
      pH ~ 1 + Age

        Coefficients:
        ──────────────────────────────────────────────────────────────────────────
                        Coef.  Std. Error      t  Pr(>|t|)   Lower 95%  Upper 95%
        ──────────────────────────────────────────────────────────────────────────
        (Intercept)  6.03963    0.503862    11.99    <1e-05   4.87772    7.20154
        Age          0.0137397  0.00815999   1.68    0.1307  -0.0050773  0.0325566
        ──────────────────────────────────────────────────────────────────────────
        
      =#

      lm_boy=lm(@formula(pH ~ Age),gdf[2])

      #= 
        pH ~ 1 + Age

        Coefficients:
        ─────────────────────────────────────────────────────────────────────────────
                        Coef.  Std. Error      t  Pr(>|t|)    Lower 95%  Upper 95%
        ─────────────────────────────────────────────────────────────────────────────
        (Intercept)   6.98911      0.129547   53.95    <1e-39   6.72767     7.25055
        Age          -0.00227928   0.0022891  -1.00    0.3251  -0.00689887  0.0023403
        ─────────────────────────────────────────────────────────────────────────────
      =#

      full_model=lm(@formula(pH ~Age ),df)
      #= 
        pH ~ 1 + Age

        Coefficients:
        ───────────────────────────────────────────────────────────────────────────────
                            Coef.  Std. Error      t  Pr(>|t|)    Lower 95%   Upper 95%
        ───────────────────────────────────────────────────────────────────────────────
        (Intercept)   6.88811      0.132119    52.14    <1e-45   6.62299     7.15323
        Age          -0.000390457  0.00229443  -0.17    0.8655  -0.00499457  0.00421366
        ───────────────────────────────────────────────────────────────────────────────

    =#

# 4. plot  

     lms=[lm_girl,lm_boy]
     labels=(xlabel="Age(month)",ylabel="pH")

    function plot_group_fitline_seperate2(gdf,lms,labels,colors)
        fig=Figure(resolution=(1000,450))
        ax=[Axis(fig[1,i],xlabel=labels.xlabel,ylabel=labels.ylabel,title=cats[i]) for i in 1:2]
        
        for (idx,lm) in enumerate(lms)
           age_range=@pipe select(gdf[idx],:Age)|>@orderby(_,:Age)
           yhat=predict(lm,age_range)
           scatter!(ax[idx],gdf[idx][!,:Age],gdf[idx][!,:pH]
           ;marker=:circle,markersize=14,color=(colors[idx],0.4),strokewidth=0.5,strokecolor=:black
           )
          lines!(ax[idx],age_range[!,1],yhat,linewidth=4,label="fitline")
          
        end
        axislegend.(ax)
        fig
   
    end
    #fig=plot_group_fitline_seperate2(gdf,lms,labels,colors)
    #save("p409-study-brain-tissue-diff-gender-1.png",fig)

    function plot_group_fitline_together(gdf::GroupedDataFrame{DataFrame},lms,labels,colors)
        fig=Figure(resolution=(700,450))
        ax=Axis(fig[1,1],xlabel=labels.xlabel,ylabel=labels.ylabel)
        
        for (idx,lm) in enumerate(lms)
           
           age_range=@pipe select(gdf[idx],:Age)|>@orderby(_,:Age)
           yhat=predict(lm,age_range)
           scatter!(ax,gdf[idx][!,:Age],gdf[idx][!,:pH]
           ;marker=:circle,markersize=14,color=(colors[idx],0.4),strokewidth=0.5,strokecolor=:black,label=cats[idx]
           )
           lines!(ax,age_range[!,1],yhat;color=(colors[idx],0.8),linewidth=4,label=cats[idx])
    
        end
        axislegend(ax;merge =true, unique =true)
        fig
    
    end
    #fig=plot_group_fitline_together(gdf,lms,labels,colors);
    #save("p409-study-brain-tissue-diff-gender-2.png",fig)
    

    