using RData,DataFrames, CodecBzip2,GLMakie

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