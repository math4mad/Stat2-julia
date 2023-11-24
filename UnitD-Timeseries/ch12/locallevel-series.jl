
"""
 aus_export 数据来源于 R 软件包
"""

import StateSpaceModels:fit!
using  RCall,DataFrames,CSV,StateSpaceModels,Pipe
include("utils.jl")

str="aus_export"
data=@pipe load_data(str)|>filter(row -> row.Country == "Australia", _)|>select(_,["Year","Exports"])
ts=data[:,:Year]
ys=data[:,:Exports]

model=LocalLevel(ys)
fit!(model)
#print_results(model)
function plot_ssm(model::StateSpaceModel,ts,ys;label="Model Name")
    filter_output = StateSpaceModels.kalman_filter(model)
    fig=Figure()
    ax=Axis(fig[1,1],xlabel="time",ylabel="values")
    lines!(ax,ts, ys;label = "raw data")
    # 使用auto_arima get_filtered_state 获得了四组数据取第一列数据
    lines!(ax,ts, get_filtered_state(filter_output)[:,1], 
    label = label)
    axislegend(ax)
    fig
end
fig=plot_ssm(model,ts,ys;label="localvevel")
#save("australia-export-locallvel-model.png",fig)





