include("utils.jl")
import  TimeSeries:lag
using  GLMakie,DataFrames,Pipe,PrettyTables,StatsBase
using GLM,AnovaGLM,TimeSeries

#step1  load data
        desc=Stat2Table(1463,"ResidualOil","glimpse dataset",["Year", "Qtr", "t", "Oil", "LogOil"])
        data=@pipe load_rda(desc.name)#get_df_feature(data)
        #@pt  first(data,3)
        
        #= 
            ┌───────┬───────┬───────┬─────────┬─────────┐
            │  Year │   Qtr │     t │     Oil │  LogOil │
            │ Int32 │ Int32 │ Int32 │ Float64 │ Float64 │
            ├───────┼───────┼───────┼─────────┼─────────┤
            │  1983 │     1 │     1 │ 90.7461 │ 4.50807 │
            │  1983 │     2 │     2 │ 84.0814 │ 4.43179 │
            │  1983 │     3 │     3 │ 85.6613 │  4.4504 │
            └───────┴───────┴───────┴─────────┴─────────┘
        =#
#step2  plot series
        function plot_series(data::AbstractDataFrame)
            yr=unique(data[:,:Year]).|>Symbol.|>String
            tr=Vector(1:4:length(data[:,:t]))
            fig=Figure(resolution=(1600,400))
            ax=Axis(fig[1,1];xlabel="Year",ylabel="Oils")
            ax.xticks=(tr,yr)
            Box(fig[1,1];color = (:orange,0.05),strokewidth=0.2)
            lines!(ax,data[:,:t],data[:,:Oil];linewidth=3,color=:blue)
            fig
        end
        #fig=plot_series(data);save("./ch12/ResidualOil/imgs/oil-series.png",fig)

#stpe4   dataframe|>TimeArray
       
        dt=[DateTime(d.Year,d.Qtr) for d in eachrow(data)]
        data.Timestamp=dt
        ts=TimeArray(data, timestamp = :Timestamp)

#step5  Linear fitting
        linear_model=lm(@formula(Oil~t), data)
        #= 
        Oil ~ 1 + t

            Coefficients:
            ──────────────────────────────────────────────────────────────────────────
                            Coef.  Std. Error       t  Pr(>|t|)  Lower 95%  Upper 95%
            ──────────────────────────────────────────────────────────────────────────
            (Intercept)  89.6943     1.86337     48.14    <1e-85   86.0089   93.3797
            t            -0.636611   0.0236012  -26.97    <1e-55   -0.68329  -0.589932
            ──────────────────────────────────────────────────────────────────────────
        =#
#step6  plot linear model fit line

        function plot_linearfitting(data,model::RegressionModel;xlabel::String="Year",ylabel::String="Oil",feature::Symbol=:Oil)
            yhat=predict(model,select(data,:t))
            yr=unique(data[:,:Year]).|>Symbol.|>String
            tr=Vector(1:4:length(data[:,:t]))
            fig=Figure(resolution=(1600,400))
            ax=Axis(fig[1,1];xlabel=xlabel,ylabel=ylabel)
            ax.xticks=(tr,yr)
            Box(fig[1,1];color = (:orange,0.05),strokewidth=0.2)
            lines!(ax,data[:,:t],data[:,feature];linewidth=2,color=:blue)
            lines!(ax,data[:,:t],yhat;linewidth=3,color=:red,label="fitting line")
            axislegend(ax)
            fig
        end
        #fig=plot_linearfitting(data,linear_model);save("./ch12/ResidualOil/imgs/linearmodel-fitting.png",fig)

#step7  plot residuals
    function plot_model_residuals(data::AbstractDataFrame,model::RegressionModel)
        yhat=predict(model,select(data,:t))
        resid=residuals(model)
        yr=unique(data[:,:Year]).|>Symbol.|>String
        tr=Vector(1:4:length(data[:,:t]))
        fig=Figure(resolution=(1600,1200))
        ax1=Axis(fig[1,1];xlabel="Year",ylabel="Oil")
        ax2=Axis(fig[2,1];xlabel="Year",ylabel="Rediduals")
        ax3=Axis(fig[3,1];xlabel="Year",ylabel="Rediduals")
        axs=[ax1,ax2,ax3]
        ax1.xticks=(tr,yr);ax2.xticks=(tr,yr);ax3.xticks=(tr,yr)
        [Box(fig[row,1];color = (:orange,0.05),strokewidth=0.2) for row in 1:3]
        lines!(ax1,data[:,:t],data[:,:Oil];linewidth=2,color=:blue)
        lines!(ax1,data[:,:t],yhat;linewidth=3,color=:red,label="fitting line")
        lines!(ax2,data[:,:t],resid;linewidth=3,color=:blue,label="residuals")
        hlines!(ax2,[0],linestyle=:dot,color=:green, linewidth=4)
        stem!(ax3,data[:,:t],resid;linewidth=3,color=:blue,label="residuals")
        hlines!(ax3,[0],linestyle=:dot,color=:green, linewidth=4)
        [axislegend(axs[i]) for i in 1:3]
        fig
    end
    #fig=plot_model_residuals(data,linear_model);save("./ch12/ResidualOil/imgs/linearmodel-residuals.png",fig)

#step8  lag-acf
    
    """
    plot_acf(data::TimeArray;feature::Symbol=:Oil)
     
    一阶自相关 lag 图
    
    """
    function plot_acf(data::TimeArray;feature::Symbol=:Oil)
        df=@pipe data[:,feature]|>lag|>DataFrame|>_[:,feature]
        acf=autocor(df)
        stem(acf)
    end
    #fig=plot_acf(ts,feature=:Oil);save("./ch12/ResidualOil/imgs/lag-autocor.png",fig)

#step9  diff
    
    """
    plot_diff(data::TimeArray;feature::Symbol=:Oil)
    
    一阶 diff plot

    """
    function plot_diff(data::TimeArray;feature::Symbol=:Oil)
        first_diff=@pipe data[:,feature]|>diff|>DataFrame(_)|>_[:,feature]
        lines(diff)
    end
   #fig=plot_diff(data,ts,feature=:Oil);save("./ch12/ResidualOil/imgs/diff.png",fig)

#step10  logOil lm fitting
        "Year-logOil-model"
        linear_model2=lm(@formula(LogOil~t), data)
        #r2(linear_model2)  #0.9151
        #= 
            LogOil ~ 1 + t

            Coefficients:
            ──────────────────────────────────────────────────────────────────────────────
                            Coef.   Std. Error       t  Pr(>|t|)   Lower 95%   Upper 95%
            ──────────────────────────────────────────────────────────────────────────────
            (Intercept)   4.6826     0.0313643    149.30    <1e-99   4.62056     4.74463
            t            -0.0150975  0.000397255  -38.00    <1e-72  -0.0158832  -0.0143118
            ──────────────────────────────────────────────────────────────────────────────
        =#

#step11  plot logOil fitline
         #fig=plot_linearfitting(data,linear_model2;xlabel="year",ylabel="logOil",feature=:LogOil)
         #save("./ch12/ResidualOil/imgs/year-logOil-lm-fitting.png",fig)

#step12  quarter boxplot
         logOilMolel_resid=residuals(linear_model2)
         data.residuals=logOilMolel_resid
         "groupby quarter"
         quarter_gdf=groupby(data,:Qtr)

         function gdf_boxplot(gdf::GroupedDataFrame;xlabel="Quarter",ylabel="Residuals",feature=:residuals)
            fig=Figure()
            ax=Axis(fig[1,1];xlabel=xlabel,ylabel=ylabel)
            ax.xticks=(1:length(gdf))
            for (idx,df) in enumerate(gdf)
                row=nrow(df)
                boxplot!(ax, fill(idx,row),df[:,feature];)
            end
          fig
         end
        #fig=gdf_boxplot(quarter_gdf);
        #save("./ch12/ResidualOil/imgs/year-logOil-lm-fitting-residual-groupby(Qtr).png",fig)
        
   

#step13  linear+season mean fitting  month season  参见  GLM 文档, Categorical variables 部分
         "linear+qtr season regression model"
          model3=lm(@formula(LogOil ~t+Qtr), data, contrasts = Dict(:Qtr => DummyCoding()))
          #= 
                LogOil ~ 1 + t + Qtr

                Coefficients:
                ──────────────────────────────────────────────────────────────────────────────
                                Coef.   Std. Error       t  Pr(>|t|)   Lower 95%   Upper 95%
                ──────────────────────────────────────────────────────────────────────────────
                (Intercept)   4.75249    0.0400767    118.58    <1e-99   4.6732      4.83177
                t            -0.0150846  0.000388363  -38.84    <1e-73  -0.0158529  -0.0143163
                Qtr: 2       -0.122216   0.0431082     -2.84    0.0053  -0.207494   -0.0369376
                Qtr: 3       -0.100666   0.0431135     -2.33    0.0211  -0.185954   -0.0153768
                Qtr: 4       -0.0602074  0.0431222     -1.40    0.1650  -0.145514    0.0250986
                ──────────────────────────────────────────────────────────────────────────────
          =#
          #r2(model3) #0.9207
#step14  qqnormal plot
            """
                plot_qqnorm(model::RegressionModel,ax)

                plot_qqnorm(model)
                ref:`Makie.jl/examples/plotting_functions/qqplot/`

            """
            function plot_qqnorm(model::RegressionModel,ax)
                res=residuals(model)
                qqnorm!(ax,res, qqline = :fitrobust)
            end
            
            """
            plot_residuals(data::AbstractDataFrame,model::RegressionModel,ax;feature=[:t,:Qtr])
            绘制回归模型残差图

            """
            function  plot_residuals(data::AbstractDataFrame,model::RegressionModel,ax;feature=[:t,:Qtr])
                res=residuals(model)
                yhat=predict(model,select(data,feature))
                scatter!(ax,yhat,res)
                hlines!(ax,[0])
            end
            
            "residuals qqnorm pairs plot"
            function plot_resid_qqnorm()
                fig=Figure(resolution=(1000,300))
                ax1=Axis(fig[1,1],title="fittedvalue-residuals",xlabel="Fitted Values",ylabel="Residuals")
                ax2=Axis(fig[1,2],title="qqnorm",xlabel="Normal Quantiles",ylabel="Residuals")
                plot_qqnorm(model3,ax2)
                plot_residuals(data,model3,ax1;feature=[:t,:Qtr])
                return fig
            end
            #fig=plot_resid_qqnorm()
            #save("./ch12/ResidualOil/imgs/residual-qqnorm.png",fig)
            
#step   timeseries  split method

        
        
        """
         select_of_qtr(qtr)
         按季度对 timearray 分组
           
         select_of_qtr(qtr)=when(ts,quarterofyear,qtr)
         
         eg  :
         1. `select_of_qtr.([1,2])`  1,2 两季度
         2. `select_of_qtr.([1,2,3,4])`  4个季度
            
        """
       select_of_qtr(ts::TimeArray,qtr)=when(ts,quarterofyear,qtr)
        
       #qtr_group=select_of_qtr.(ts,[1,2,3,4])  #按四个季度分类

       
        """
           select_of_year(year)
           按年对 timearray 分组

        """
        select_of_year(ts::TimeArray,yr)=when(ts,year,yr)
        select_of_year(ts,2010)






        