using RData,DataFrames, CodecBzip2,Pipe,GLM,GLMakie

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
function plot_pair_scatter(data::AbstractDataFrame;xlabel::String,ylabel::String)
    fig=Figure()
    ax=Axis(fig[1,1],xlabel=xlabel,ylabel=ylabel)
    ax.title="$(xlabel)-$(ylabel)-scatter"
    Box(fig[1,1];color = (:orange,0.1),strokewidth=0.5)
    scatter!(ax,data[!,xlabel],data[!,ylabel];marker=:circle,markersize=14,color=(:purple,0.4),strokewidth=1,strokecolor=:black)
    #res= save==true ? save("$(xlabel)-$(ylabel)-scatter.png",fig) :  
    return (fig,ax)
    
end


"""
    plot_fitline_and_residual(;data::AbstractDataFrame,xlabel::Union{String,Symbol},ylabel::Union{String,Symbol},model::RegressionModel)
    绘制回归模型图: fig[1,1] 散点+拟合线, fig[1,2] 预测残差图

 ## Params
    1. data   df
    2. xlabel 预测变量  
    3. ylabel  响应变量
    4. model   回归模型
 ##  返回值
    fig  Makie 对象
"""
function plot_fitline_and_residual(;data::AbstractDataFrame,xlabel::Union{String,Symbol},ylabel::Union{String,Symbol},model::RegressionModel)
    y_hat=@pipe select(df,xlabel)|>predict(model,_)|>round.(_,digits=2)
    res=residuals(model)
    fig=Figure(resolution=(800,300))
    ax1=Axis(fig[1,1],xlabel=xlabel,ylabel=ylabel)
    ax2=Axis(fig[1,2],xlabel="fit_value",ylabel="residuals")
    #ax1.title="$(xlabel)-$(ylabel)-scatter"
    Box(fig[1,1];color = (:orange,0.1),strokewidth=0.5)
    Box(fig[1,2];color = (:orange,0.1),strokewidth=0.5)
    scatter!(ax1,data[!,xlabel],data[!,ylabel];marker=:circle,markersize=14,color=(:purple,0.4),strokewidth=1,strokecolor=:black)
    lines!(ax1,data[!,xlabel],y_hat,label="fit_line")
    stem!(ax2,res)
    return fig
end

"""
    plot_lm_res(;data::AbstractDataFrame,xlabel::Union{String,Symbol},ylabel::Union{String,Symbol},model::RegressionModel)
    绘制回归模型图: fig[1,1] 散点+拟合线, fig[1,2] 预测残差图,fig[2,1] residuals histrogram,fig[2,2]  residuals qqnorm
 
 ## Params
    1. data   df
    2. xlabel 预测变量  
    3. ylabel  响应变量
    4. model   回归模型
 ##  返回值
    fig  Makie 对象
"""
function plot_lm_res(;data::AbstractDataFrame,xlabel::Union{String,Symbol},ylabel::Union{String,Symbol},model::RegressionModel)
    y_hat=@pipe select(data,xlabel)|>predict(model,_)|>round.(_,digits=2)
    res=residuals(model)
    fig=Figure(resolution=(1000,800))
    Label(fig[0, 1:2], "$(xlabel)-$(ylabel)-Linear-Regression", fontsize = 24)

    ax1=Axis(fig[1,1],xlabel=xlabel,ylabel=ylabel)
    ax2=Axis(fig[1,2],xlabel="fit_value",ylabel="residuals")
    ax3=Axis(fig[2,1],xlabel="rediduals",ylabel="frequency")
    ax4=Axis(fig[2,2],xlabel="quantiles",ylabel="residuals")
    
    Box(fig[1,1];color = (:orange,0.1),strokewidth=0.3)
    Box(fig[1,2];color = (:orange,0.1),strokewidth=0.3)
    Box(fig[2,1];color = (:orange,0.1),strokewidth=0.3)
    Box(fig[2,2];color = (:orange,0.1),strokewidth=0.3)
    scatter!(ax1,data[!,xlabel],data[!,ylabel];marker=:circle,markersize=14,color=(:purple,0.4),strokewidth=1,strokecolor=:black)
    lines!(ax1,data[!,xlabel],y_hat,label="fit_line")
    stem!(ax2,res)
    hist!(ax3,res)
    qqnorm!(ax4,res;qqline = :fitrobust)
    return fig
end


"""
    plot_lm_res2(;data::AbstractDataFrame,xlabel::Union{String,Symbol},ylabel::Union{String,Symbol},model::RegressionModel)
    与 plot_lm_res 功能相同, y_hat 改为平方
    
`
xs=sort(data[!,xlabel])

y_hat=@pipe select(df,xlabel)|>predict(model,_)|>_.^2|>round.(_,digits=2)|>sort
`



TBW
"""
function plot_lm_res2(;data::AbstractDataFrame,xlabel::Union{String,Symbol},ylabel::Union{String,Symbol},model::RegressionModel)
    xs=sort(data[!,xlabel])
    y_hat=@pipe select(data,xlabel)|>predict(model,_)|>_.^2|>round.(_,digits=2)|>sort
    
    res=residuals(model)
    
    fig=Figure(resolution=(1000,800))
    Label(fig[0, 1:2], "$(xlabel)-$(ylabel)-Linear-Regression", fontsize = 24)

    ax1=Axis(fig[1,1],xlabel=xlabel,ylabel=ylabel)
    ax2=Axis(fig[1,2],xlabel="fit_value",ylabel="residuals")
    ax3=Axis(fig[2,1],xlabel="rediduals",ylabel="frequency")
    ax4=Axis(fig[2,2],xlabel="quantiles",ylabel="residuals")
    
    Box(fig[1,1];color = (:orange,0.1),strokewidth=0.3)
    Box(fig[1,2];color = (:orange,0.1),strokewidth=0.3)
    Box(fig[2,1];color = (:orange,0.1),strokewidth=0.3)
    Box(fig[2,2];color = (:orange,0.1),strokewidth=0.3)
    scatter!(ax1,data[!,xlabel],data[!,ylabel].^2;marker=:circle,markersize=14,color=(:purple,0.4),strokewidth=1,strokecolor=:black)
    scatterlines!(ax1,xs,y_hat,label="fit_line")
    stem!(ax2,res)
    hist!(ax3,res)
    qqnorm!(ax4,res;qqline = :fitrobust)
    return fig
end