include("utils.jl")
import  TimeSeries:lag

using  DataFrames,Pipe,PrettyTables,StatsBase,GLMakie
using  TimeSeries,StateSpaceModels
plotly()

#step1  load data
        desc=Stat2Table(1463,"ResidualOil","glimpse dataset",["Year", "Qtr", "t", "Oil", "LogOil"])
        data=@pipe load_rda(desc.name)
        ts=data[:,:t]
        logOil=data[:,:LogOil]


#step2  define statespacemodel  plot funciton 

        """
        plot_ssm(model::StateSpaceModel,ts,ys;label="Model Name")

        输出model fitting plot  

        ## Arguments
        1. model   eg. `model=auto_arima(logOil)`
        2. ts  时间轴数据
        3. ys  原始数据
        4. 模型名 eg `Arima`
        """
        function plot_ssm(model::StateSpaceModel,ts,ys;label="Model Name")

                
                filter_output = StateSpaceModels.kalman_filter(model)
                fig=Figure()
                ax=Axis(fig[1,1],xlabel="time",ylabel="values")
                lines!(ax,ts, ys;label = "raw data")
                # 使用auto_arima get_filtered_state 获得了四组数据取第一列数据
                lines!(ax,ts, get_filtered_state(filter_output)[:,1], 
                label = label)
                fig
        end

#step2   ARIMA 
         #model1= SARIMA(logOil; order = (1, 0, 0), seasonal_order = (0, 1, 1, 12))
         #plot_ssm(model2,ts,logOil;label="SARIMA")

#step4. autoarima
        model2=auto_arima(logOil)|>StateSpaceModels.fit!
        #plot_ssm(model,ts,logOil;label="autoARIMA")
 
#step5  print_results 
        model1=SARIMA(logOil; order = (1, 0, 0), seasonal_order = (0, 1, 1, 12))
        StateSpaceModels.fit!(model1)
        #fig=plot_ssm(model2,ts,logOil;label="autoARIMA")
        
 #step6   plot residuals
        function plot_residuals(model::StateSpaceModel,ts,ys;ax,label="Model Name")
                filter_output = StateSpaceModels.kalman_filter(model)
               
                yhat=get_filtered_state(filter_output)[:,1]
                residuals=ys-yhat
                stem!(ax,ts,residuals;label=label)
                axislegend(ax)
                fig
        end
        fig=Figure()
        ax=Axis(fig[1,1],xlabel="time",ylabel="values")
        fig=plot_residuals(model2,ts,logOil;ax,label="autoARIMA")
        save("auto-arima-model-fitting-residuals.png",fig)

        
#step7 computing  rmse
       function computing_rmsd(model::StateSpaceModel,ys)
                filter_output = StateSpaceModels.kalman_filter(model)
                yhat=get_filtered_state(filter_output)[:,1]
                return rmsd(ys,yhat)
        end
        #se=computing_rmsd(model2,logOil)
#step8  predict
         predicts=StateSpaceModels.forecast(model2,8)
         predicts.expected_value
