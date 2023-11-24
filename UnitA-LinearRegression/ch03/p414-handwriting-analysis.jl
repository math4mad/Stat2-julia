include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
using  StatsBase
using  GLM,AnovaGLM

# 1. load data
    desc=Stat2Table(414,"Handwriting","Handwriting analysis",["Gender", "Survey1", "Survey2"])
    df=@pipe load_rda(desc.name)|>select(_,desc.feature)
    gdf=groupby(df,:Gender)[1:2]
# 2. plot
    feature=["Survey1", "Survey2"]
    cats=["boy","girl"]
    colors::Vector{Symbol}=[:purple,:blue]
    #fig=plot_group_scatter2(gdf,feature,cats,colors)
    #save("./ch03/imgs/p414-diff-gender-scatter.png",fig)
# 3. fit lm
   lm_boy=lm(@formula(Survey2 ~Survey1),gdf[1])
    #= 
        Survey2 ~ 1 + Survey1

        Coefficients:
        ───────────────────────────────────────────────────────────────────────
                        Coef.  Std. Error     t  Pr(>|t|)  Lower 95%  Upper 95%
        ───────────────────────────────────────────────────────────────────────
        (Intercept)  37.4606     7.38066   5.08    <1e-05  22.7908    52.1305
        Survey1       0.41997    0.126083  3.33    0.0013   0.169366   0.670574
        ───────────────────────────────────────────────────────────────────────
    =#

   lm_girl=lm(@formula(Survey2 ~Survey1),gdf[2])

    #= 
        Survey2 ~ 1 + Survey1

        Coefficients:
        ────────────────────────────────────────────────────────────────────────
                        Coef.  Std. Error     t  Pr(>|t|)  Lower 95%  Upper 95%
        ────────────────────────────────────────────────────────────────────────
        (Intercept)  54.4331     6.22029    8.75    <1e-13  42.0981     66.7682
        Survey1       0.202907   0.0928645  2.18    0.0311   0.018753    0.38706
        ────────────────────────────────────────────────────────────────────────
    =#

# 4. plot
    lms=[lm_boy,lm_girl]
    labels=(xlabel="Survey1",ylabel="Sruvey2")

    function plot_group_fitline_seperate(gdf,lms,labels,colors)
        fig=Figure(resolution=(1000,450))
        ax=[Axis(fig[1,i],xlabel=labels.xlabel,ylabel=labels.ylabel,title=cats[i]) for i in 1:2]
        
        for (idx,lm) in enumerate(lms)
        age_range=@pipe select(gdf[idx],:Survey1)|>@orderby(_,:Survey1)
        yhat=predict(lm,age_range)
        scatter!(ax[idx],gdf[idx][!,:Survey1],gdf[idx][!,:Survey2]
        ;marker=:circle,markersize=14,color=(colors[idx],0.4),strokewidth=0.5,strokecolor=:black
        )
        lines!(ax[idx],age_range[!,1],yhat,linewidth=4,label="fitline")
        
        end
        axislegend.(ax)
        fig

    end
    #fig=plot_group_fitline_seperate(gdf,lms,labels,colors)
    #save("p409-handwriting-diff-gender-1.png",fig)

    function plot_group_fitline_together(gdf::GroupedDataFrame{DataFrame},lms,labels,colors)
        fig=Figure(resolution=(700,450))
        ax=Axis(fig[1,1],xlabel=labels.xlabel,ylabel=labels.ylabel)
        
        for (idx,lm) in enumerate(lms)
        
        age_range=@pipe select(gdf[idx],:Survey1)|>@orderby(_,:Survey1)
        yhat=predict(lm,age_range)
        scatter!(ax,gdf[idx][!,:Survey1],gdf[idx][!,:Survey2]
        ;marker=:circle,markersize=14,color=(colors[idx],0.4),strokewidth=0.5,strokecolor=:black,label=cats[idx]
        )
        lines!(ax,age_range[!,1],yhat;color=(colors[idx],0.8),linewidth=4,label=cats[idx])

        end
        axislegend(ax;merge =true, unique =true)
        fig

    end
    #fig=plot_group_fitline_together(gdf,lms,labels,colors);
    #save("p409-handwriting-diff-gender-2.png",fig)

# 5. add indicatior 
    lm_=lm(@formula(Survey2 ~Survey1+Gender),df)
