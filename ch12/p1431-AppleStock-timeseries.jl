#init  
include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,FreqTables
using  StatsBase,TableTransforms,Random,TimeSeries,Dates
using  GLM,AnovaGLM,HypothesisTests,Distributions
Random.seed!(34343)

#1. load data
        desc=Stat2Table(1431,"AppleStock","stock time series",["Date", "Price", "Change", "Volume"])
        data=@pipe load_rda(desc.name)
#2. plot timeseries,randon walk
    d=Normal(0,1.5)
    randomwalks=[cumsum([100,rand(d,65)...];dims=1) for i in 1:3]
    series4=[data[:,:Price],randomwalks...] #一行真实数据, 三行随机行走数据
    """
    plot_series()
    apple stock series+ 3 random walk  series from 100, 
    dist=Norml(0,1.5)

    """
    function plot_series()
        xs=1:nrow(data)
        fig=Figure(resolution=(900,600))
        axs=[Axis(fig[i,j];xlabel="day",ylabel="Price") for i in 1:2 for j in 1:2]
        labels=["series$i" for i in 1:4]
        for i in 1:4
           lines!(axs[i],xs, series4[i], label=labels[i])
           axislegend(axs[i])
         end
        fig
    end
    #fig=plot_series();save("./ch12/imgs/p1431-stock-randomwalk.png",fig)
     
#3. plor difference
    function plot_difference()
        
        fig=Figure(resolution=(900,600))
        axs=[Axis(fig[i,j];xlabel="day",ylabel="Difference") for i in 1:2 for j in 1:2]
        linkyaxes!(axs[1],axs[2:4]...)
        labels=["series$i" for i in 1:4]
        for i in 1:4
            data=series4[i][1:end-1]
            lag= series4[i][2:end]
            diff=lag-data
            lines!(axs[i],1:65, diff, label=labels[i])
            hlines!(axs[i],[0],linewidth=3,linestyle=:dot,color=:red)
            axislegend(axs[i])
        end
        fig
    end
    #fig=plot_difference()#;save("./ch12/imgs/p1431-stock-randomwalk-diff.png",fig)

#4. price lag and diff  plot
    function plot_lag()
        
        data=series4[1][1:end-1]
        lag= series4[1][2:end]
        diff=lag-data
        data2=diff[1:end-1]
        lag2=diff[2:end]
        
        fig=Figure(resolution=(900,400))
        ax1=Axis(fig[1,1];xlabel="Previous Price",ylabel="Price")
        ax2=Axis(fig[1,2];xlabel="Previous Difference",ylabel="Difference")
        scatter!(ax1,data,lag;marker_style...)
        scatter!(ax2,data2,lag2;marker_style...)

        fig

    end
    #fig=plot_lag()#;save("./ch12/imgs/p1431-pricelag-diff-lag.png",fig)
    
#5. detection  autocorrelation 
    data=series4[1][1:end-1]
    lag= series4[1][2:end]
    diff=lag-data
    acf1=autocor(data)  # price  autocor
    acf2=autocor(diff)  # diff  autocor
    function plot_acf()
        fig=Figure(resolution=(900,300))
        ax1=Axis(fig[1,1];xlabel="Lag",ylabel="ACF",title="Price Lag ACF")
        ax2=Axis(fig[1,2];xlabel="Lag",ylabel="ACF",title="Difference Lag ACF")
        linkyaxes!(ax1, ax2)
        stem!(ax1,acf1[2:end])
        stem!(ax2,acf2[2:end])
        fig
    end
    #fig=plot_acf()#;save("./ch12/imgs/p1431-AppleStock-price-diff-acf.png",fig)
#6.  using TimeSeries.jl package
     
     df=load_rda(desc.name)
     #res=@pipe split("10/10/2016","/")|>Date(_[3],_[1],_.[2])
     
     
     