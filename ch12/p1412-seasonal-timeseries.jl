#init  
    include("utils.jl")
    using  RCall
    using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,FreqTables
    using  StatsBase,TableTransforms
    using  GLM,AnovaGLM,HypothesisTests


#1.    load data
        desc=Stat2Table(1412,"PeaceBridge2012","seasonal time series",["Year", "Month", "Traffic", "t"])
        data=@pipe load_rda(desc.name)
        ts=tspan=data[:,:t]

#2.    plot time series
        fig1,ax1,plt1=scatterlines(data[:,:t],data[:,:Traffic];marker_style...,linewidth=4)
        #save("./ch12/imgs/p1412-seasonal-timeseries.png",fig)

##  3.    cos,sin  tranformtion  for  fitting
       cost(t)=cos(2pi*t/12); sint(t)=sin(2pi*t/12)
       model1=lm(@formula(Traffic~cost(t)+sint(t)), data)
       #= 
            Traffic ~ 1 + :(cost(t)) + :(sint(t))

            Coefficients:
            ────────────────────────────────────────────────────────────────────────
                            Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
            ────────────────────────────────────────────────────────────────────────
            (Intercept)  478.325      6.06123  78.92    <1e-49   466.117    490.533
            cost(t)      -78.2165     8.57187  -9.12    <1e-11   -95.4812   -60.9519
            sint(t)      -61.6879     8.57187  -7.20    <1e-08   -78.9525   -44.4232
            ────────────────────────────────────────────────────────────────────────
       =#

## 4.    model1 ftest   
       ftest(model1.model)
       #F-statistic: 67.53 on 48 observations and 2 degrees of freedom, p-value: <1e-13 

#5.    add cos fitting
       
       model2=lm(@formula(Traffic~cost(t)), data)  # just cost  model
       yhat2=predict(model2,select(data,:t))|>arr->round.(arr,digits=3)
       #lines!(ax1,ts,yhat2;color=:red,linestyle=:dash,linewidth=3) 
       #fig1;save("./ch12/imgs/p1412-cost-traffic-reg.png",fig1)

#6.    month season  参见  GLM 文档, Categorical variables 部分
       model3=lm(@formula(Traffic ~Month), data, contrasts = Dict(:Month => DummyCoding()))

       #= 
        Traffic ~ 1 + Month

        Coefficients:
        ────────────────────────────────────────────────────────────────────────
                    Coef.  Std. Error      t  Pr(>|t|)   Lower 95%  Upper 95%
        ────────────────────────────────────────────────────────────────────────
        (Intercept)  383.075     12.9524  29.58    <1e-26  356.806      409.344
        Month: 2     -10.675     18.3174  -0.58    0.5637  -47.8245      26.4745
        Month: 3      78.225     18.3174   4.27    0.0001   41.0755     115.374
        Month: 4      64.9       18.3174   3.54    0.0011   27.7505     102.049
        Month: 5     108.025     18.3174   5.90    <1e-06   70.8755     145.174
        Month: 6     133.475     18.3174   7.29    <1e-07   96.3255     170.624
        Month: 7     228.975     18.3174  12.50    <1e-13  191.826      266.124
        Month: 8     255.775     18.3174  13.96    <1e-15  218.626      292.924
        Month: 9     107.775     18.3174   5.88    <1e-06   70.6255     144.924
        Month: 10     99.05      18.3174   5.41    <1e-05   61.9005     136.199
        Month: 11     39.55      18.3174   2.16    0.0376    2.40052     76.6995
        Month: 12     37.925     18.3174   2.07    0.0456    0.775517    75.0745
        ────────────────────────────────────────────────────────────────────────
       =#
       # month1  作为常数项,回归以 1 月的数据作为基准, month2:-10.675 ,意思是在二月份比一月份少-10.675*1000车辆通行
       # 其他月份同样处理

        #r2(model3)  #0.923
        #ftest(model3.model) #F-statistic: 39.74 on 48 observations and 11 degrees of freedom, p-value: <1e-16
#7.    plot month season variable 
        
        yhat3=predict(model3,select(data,:Month))|>arr->round.(arr,digits=3)
        #lines!(ax1,data[:,:t],yhat3;color=:red,linestyle=:dash,linewidth=3) 
        #fig1;save("./ch12/imgs/p1412-month-season-reg.png",fig1)
#8.    plot  cost, month sesaon rediduals#=  =#
        cost_resid=residuals(model2)
        season_resid=residuals(model3)
        xs4=data[:,:t]
       function plot_pair_resid()
          fig=Figure(resolution=(1200,300))
          ax1=Axis(fig[1,1];xlabel="time",ylabel="cost-rediduals")
          ax2=Axis(fig[1,2];xlabel="time",ylabel="monthseason-rediduals")
          Box(fig[1,1];color = (:orange,0.05),strokewidth=0.5)
          Box(fig[1,2];color = (:orange,0.05),strokewidth=0.5)
          linkyaxes!(ax1, ax2)
          lines!(ax1,xs4,cost_resid)
          lines!(ax2,xs4,season_resid)
          hlines!(ax1,[0],linestyle=:dot, linewidth=2,color=(:red, 0.8))
          hlines!(ax2,[0],linestyle=:dot, linewidth=2,color=(:red, 0.8))
          fig

       end
       #fig5=plot_pair_resid();save("./ch12/imgs/p1412-seasonal-timeseries-residuals.png",fig5)
        