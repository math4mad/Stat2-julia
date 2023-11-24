"""
1. plot pair scatter
2. lm fitting
3. anova table
4. plot  residals and  qqplot
"""

include("utils.jl")
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
using  StatsBase
using  GLM,AnovaGLM

desc=Stat2Table(314,"Kids198","boy-girl-growth-rate",[:Age,:Weight,:Sex])
data=@pipe load_rda(desc.name)|>select(_,desc.feature)
gdf=groupby(data,:Sex)


# 1 plot group  scatter
cats=["boy","girl"]
colors::Vector{Symbol}=[:purple,:blue]
#fig=plot_group_scatter(gdf,cats,colors);#save("./ch03/boy-girl-growth-age-weight-scatter.png",fig)

# fit two group lm  model
lm_boy=lm(@formula(Weight ~ Age),gdf[1])
lm_girl=lm(@formula(Weight ~ Age),gdf[2])
lms::Vector{RegressionModel}=[lm_boy,lm_girl]
labels=(xlabel="Age(month)",ylabel="Weight(pound)")

"""
    plot_group_fitline_seperate(gdf::GroupedDataFrame{DataFrame},lms::Array{RegressionModel},labels,colors)
    绘制分 2组的回归拟合线
    ## Arguments
    1. gdf :GroupedDataFrame{DataFrame}
    2. lms:  lm model array
    3.  labels  eg (xlabel="Age(month)",ylabel="Weight(pound)")
    4.  colors  eg [:purple,:blue]
    
    ## 返回值
    Makie  fig 对象

"""
function plot_group_fitline_seperate(gdf::GroupedDataFrame{DataFrame},lms::Vector{RegressionModel},labels,colors::Vector{Symbol})
     fig=Figure(resolution=(1000,450))
     ax=[Axis(fig[1,i],xlabel=labels.xlabel,ylabel=labels.ylabel,title=cats[i]) for i in 1:2]
     
     for (idx,lm) in enumerate(lms)
        age_range=@pipe select(gdf[idx],:Age)|>@orderby(_,:Age)
        yhat=predict(lm,age_range)
        scatter!(ax[idx],gdf[idx][!,:Age],gdf[idx][!,:Weight]
        ;marker=:circle,markersize=14,color=(colors[idx],0.4),strokewidth=0.5,strokecolor=:black
        )
        lines!(ax[idx],age_range[!,1],yhat,linewidth=4,label="fitline")

     end
     axislegend.(ax)
     fig

end


#fig=plot_group_fitline_seperate(gdf,lms,labels,colors)
#save("./ch03/imgs/boy-girl-growth-age-weight-separate-lm-reg.png",fig)


function plot_group_fitline_together(gdf::GroupedDataFrame{DataFrame},lms::Vector{RegressionModel},labels,colors::Vector{Symbol})
    fig=Figure(resolution=(700,450))
    ax=Axis(fig[1,1],xlabel=labels.xlabel,ylabel=labels.ylabel)
    
    for (idx,lm) in enumerate(lms)
       
       age_range=@pipe select(gdf[idx],:Age)|>@orderby(_,:Age)
       yhat=predict(lm,age_range)
       scatter!(ax,gdf[idx][!,:Age],gdf[idx][!,:Weight]
       ;marker=:circle,markersize=14,color=(colors[idx],0.4),strokewidth=0.5,strokecolor=:black,label=cats[idx]
       )
       lines!(ax,age_range[!,1],yhat;color=(colors[idx],0.8),linewidth=4,label=cats[idx])

    end
    axislegend(ax;merge =true, unique =true)
    fig

end

fig=plot_group_fitline_together(gdf,lms,labels,colors);
#save("./ch03/imgs/boy-girl-growth-age-weight-linreg-together.png",fig)
