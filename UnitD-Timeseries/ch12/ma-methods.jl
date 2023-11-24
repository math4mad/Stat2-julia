"""
使用 Timeseries.jl 方法处理 moving 列
"""

using DataFrames,CSV,StateSpaceModels,Pipe,TimeSeries,DataFramesMeta
using Dates,StatsBase
include("utils.jl")

# 1.  load data-> TimeArray
    str="aus_export"
    df=@pipe load_data(str)|>filter(row -> row.Country == "Australia", _)|>select(_,["Year","Exports"])
    @transform!(df, :time =Date.(:Year))
    ts=TimeArray(df, timestamp = :time)

#2. Moving Average  

    ms_range= [3,5,7,9]
    mas=[@pipe moving(mean,ts,lag)|>DataFrame|>select(_,[:Year,:Exports]) for lag in ms_range]

# 3. plot MA  results
    function plot_ma(idx,ax,df,mas)
        lines!(ax,df[:,:Year],df[:,:Exports],label="data")
        lines!(ax,eachcol(mas[idx])...,label="$(ms_range[idx])-MA")
        axislegend(ax;position=:lt,bgcolor=(:white,0.2))
    end


    fig=Figure(resolution=(1000,600))
    function plot_mas()
        for  idx in 1:length(ms_range)
            ax=Axis(fig[fldmod1(idx,2)...])
            plot_ma(idx,ax,df,mas)
        end
        fig
    end
    #with_theme(plot_mas, ggplot_theme)
    #save("ma-compare-2.png",fig)

#4. diff operation |>dataframe  1 阶差分
        function plot_diff(data::AbstractDataFrame)
            fig=Figure()
            ax=Axis(fig[1,1])
            lines!(ax,eachcol(data)...)
            fig
        end
        order1_diff=@pipe diff(ts,1)|>DataFrame|>select(_,[:Exports])
        fig=plot_diff(order1_diff)#;save("aut_export-1order-diff.png",fig)
#5. 二阶差分
        #order2_diff=@pipe diff(ts,2)|>DataFrame|>select(_,[:Exports])
        #plot_diff(order2_diff)
    





