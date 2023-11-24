using  CodecBzip2,Pipe
using  RData,DataFrames,PrettyTables
using  UnicodePlots,GLMakie
using  HypothesisTests,StatsBase
using  GLM,AnovaGLM,AnovaBase

"""
    load_rda(str::AbstractString)
    加载 Stat2 rda  dataset
"""
function load_rda(str::AbstractString)
 df=load("./Stat2Data/$str.rda")
 return df["$str"]
end


Base.@kwdef struct  Stat2Table
    page::Int
    name::AbstractString
    question:: AbstractString
    feature::Vector{Union{AbstractString,Symbol}}
end


"""
    plot_pair_scatter(data::AbstractDataFrame;xlabel::String,ylabel::String,save::Bool=false)
    使用两个 feature 绘制散点图
    ## Params
    1. data::DataFrame
    2. xlabel::  x feature
    3. ylabel::  y feature
    4. save:: 是否保存图片 默认 false
    ## 返回值
       fig,ax
"""
function plot_pair_scatter(data::AbstractDataFrame;xlabel::String,ylabel::String,save::Bool=false)
    fig=Figure()
    ax=Axis(fig[1,1],xlabel=xlabel,ylabel=ylabel)
    ax.title="$(xlabel)-$(ylabel)-scatter"
    Box(fig[1,1];color = (:orange,0.1),strokewidth=0.5)
    scatter!(ax,data[!,xlabel],data[!,ylabel];marker=:circle,markersize=14,color=(:purple,0.4),strokewidth=1,strokecolor=:black)
    save&&save("$(xlabel)-$(ylabel)-scatter.png",fig)
    return (fig,ax)
end

"""
    summary_df(gdf::GroupedDataFrame,feature::Union{String,Symbol})

分组 dataframe summary 选择 feature

return n , mean,stddev
"""
function summary_df(gdf::GroupedDataFrame,feature::Union{String,Symbol})
    return combine(gdf,nrow=>:n ,feature=>mean=>:Mean,feature=>std=>:Stddev)
end


"""
    plot_linreg_residuals(model::StatsModels,data::AbstractDataFrame)

    plot GLM LinearRegression model residuals results with  two column dataframe data
"""
function plot_linreg_residuals(model::StatsModels.TableRegressionModel,data::AbstractDataFrame)
    @assert size(data,2)==2
    resis=residuals(model)
    coefs=coef(model)
    labels=names(data)
    y_hat=predict(model)
    fig=Figure(resolution=(1200,400))
    axs=[Axis(fig[1,i]) for i in 1:3]
    axs[1].xlabel=labels[1];axs[1].ylabel=labels[2]
    axs[2].xlabel="Residuals";axs[2].ylabel="Frequency"
    axs[3].xlabel="Fit Value";axs[3].ylabel="Residuals"
    scatter!(axs[1],eachcol(data)...;marker='o',color=:red)
    ablines!(axs[1],coefs..., linewidth=2, color=:blue)
    hist!(axs[2],resis;bins=15,color = :gray, strokewidth = 1, strokecolor = :black)
    scatter!(axs[3],y_hat,resis;marker='o',color=:red)
    fig
end



