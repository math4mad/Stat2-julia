#init  
include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,FreqTables
using  StatsBase,TableTransforms,Random,TimeSeries,Dates
using  GLM,AnovaGLM,HypothesisTests,Distributions
Random.seed!(34343)

#1. load data
        desc=Stat2Table(1494,"TechStocks","googld stock time series",["Date", "AAPL", "GOOG", "MSFT", "t"])
        data=@pipe load_rda(desc.name)|>select(_,[:Date,:GOOG,:t])
#2.  construct ts
    
    change(d)=@pipe d|>String|>split(_,"/")|>DateTime("$(_[3])-$(_[1])-$(_[2])", DateFormat("y-m-d"))
    new_data=transform(data, ["Date"] => ByRow(change) =>:Date)
    ts=TimeArray(new_data, timestamp = :Date)    

#3. plot series
    
    function plot_series(data::AbstractDataFrame;xlabel="Time",ylabel="Price",feature::Union{AbstractString,Symbol})
        xs=1:nrow(data)
        ys=data[:,feature]
        fig=Figure()
        ax=Axis(fig[1,1];xlabel=xlabel,ylabel=ylabel)
        lines!(ax,xs, ys)
        fig
    end

    #fig=plot_series(data;feature=:GOOG)
    #save("./ch12/imgs/p1494-google-stock-series.png",fig)

#step2,  linear reg of t  
     
    linear_model=lm(@formula(GOOG~t), data)

    #= 
         GOOG ~ 1 + t

        Coefficients:
        ─────────────────────────────────────────────────────────────────────────────
                        Coef.  Std. Error       t  Pr(>|t|)   Lower 95%   Upper 95%
        ─────────────────────────────────────────────────────────────────────────────
        (Intercept)  663.104      3.52114    188.32    <1e-99  656.186     670.022
        t              0.623187   0.0120828   51.58    <1e-99    0.599448    0.646926
        ─────────────────────────────────────────────────────────────────────────────
    =#
#step4.  plot linear model fitting line

        
        function plot_reg(model::RegressionModel,data::AbstractDataFrame;feature=[:t,:GOOG])
            ts=data[:,feature[1]]
            yhat=predict(model,select(data,feature[1]))
            fig=Figure(resolution=(1200,400))
            ax=Axis(fig[1,1];xlabel="time",ylabel="traffic",title=L"Linear model")
            ax.xticks=(1:20:nrow(data))
            Box(fig[1,1];color = (:orange,0.05),strokewidth=0.5)
            scatterlines!(ax,ts,data[:,feature[2]];marker_style...,linewidth=4)
            lines!(ax,ts,yhat;color=:red,linestyle=:dash,linewidth=3) 
            
            fig

        end
       #fig=plot_reg(linear_model,data)
       #save("./ch12/imgs/p1494-google-stock-(t-price-reg).png",fig)

                