#init  
include("utils.jl")
        using  RCall
        using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,FreqTables
        using  StatsBase,TableTransforms
        using  GLM,AnovaGLM,HypothesisTests


#1. load data
        desc=Stat2Table(1421,"PeaceBridge2003","longer seasonal time series",["Year", "Month", "Traffic", "t"])
        data=@pipe load_rda(desc.name)
        ts=tspan=data[:,:t]
        traffic=data[:,:Traffic]

#2. plot time series
        fig1,ax1,plt1=scatterlines(data[:,:t],data[:,:Traffic];marker_style...,linewidth=4)
        #save("./ch12/imgs/p1421-long-seasonal-timeseries.png",fig1)  

#3. fit two models:  1:cosine model 2: season model

        cost(t)=cos(2pi*t/12); sint(t)=sin(2pi*t/12)
        cosine_model=lm(@formula(Traffic~t+cost(t)+sint(t)), data)
        season_model=lm(@formula(Traffic ~t+Month), data, contrasts = Dict(:Month => DummyCoding()))
        mds=[cosine_model,season_model]

#4. plot  fitline
        yhat1=predict(mds[1],select(data,:t))
        yhat2=predict(mds[2],select(data,[:Month,:t]))
        function plot_two_reg()
            yr=unique(data[:,:Year]).|>Symbol.|>String
            tr=Vector(1:12:length(data[:,:t]))
            fig=Figure(resolution=(1400,400))
            ax1=Axis(fig[1,1];xlabel="time",ylabel="traffic",title=L"Linear+Cossine")
            ax2=Axis(fig[1,2];xlabel="time",ylabel="traffic",title=L"Linear+Seasonal Means")
            ax1.xticks=(tr,yr)
            ax2.xticks=(tr,yr)
            Box(fig[1,1];color = (:orange,0.05),strokewidth=0.5)
            Box(fig[1,2];color = (:orange,0.05),strokewidth=0.5)
            scatterlines!(ax1,data[:,:t],data[:,:Traffic];marker_style...,linewidth=4)
            scatterlines!(ax2,data[:,:t],data[:,:Traffic];marker_style...,linewidth=4)
            lines!(ax1,data[:,:t],yhat1;color=:red,linestyle=:dash,linewidth=3) 
            lines!(ax2,data[:,:t],yhat2;color=:red,linestyle=:dash,linewidth=3) 
            fig

        end
        #fig=plot_two_reg()#;save("./ch12/imgs/p1421-two-model-timeseries.png",fig)
#5. plot residuals
        "linear-cosine  residuals"
        lc_resid=residuals(mds[1]) 
        "lienar-seasonalmeans residuals"
        ls_resid=residuals(mds[2]) 
        
        function plot_pair_resid()
            yr=unique(data[:,:Year]).|>Symbol.|>String
            tr=Vector(1:12:length(data[:,:t]))
            fig=Figure(resolution=(1400,400))
            Box(fig[1,1];color = (:orange,0.05),strokewidth=0.2)
            Box(fig[1,2];color = (:orange,0.05),strokewidth=0.2)
            ax1=Axis(fig[1,1];xlabel="time",ylabel="residuals",title=L"Linear+Cossine")
            ax2=Axis(fig[1,2];xlabel="time",ylabel="residuals",title=L"Linear+Seasonal Means")
            
            ax1.xticks=(tr,yr)
            ax2.xticks=(tr,yr)
            
            linkyaxes!(ax1, ax2)
            lines!(ax1,ts,lc_resid)
            lines!(ax2,ts,ls_resid)
            hlines!(ax1,[0],linestyle=:dot, linewidth=2,color=(:red, 0.8))
            hlines!(ax2,[0],linestyle=:dot, linewidth=2,color=(:red, 0.8))
            fig

        end
        #fig=plot_pair_resid()#;save("p1421-two-models-residuals.png",fig)
        
#6.    report  R² and  SE

        yhat1=predict(mds[1],select(data,:t))
        yhat2=predict(mds[2],select(data,[:Month,:t]))

        se1=rmsd(data[:,:Traffic],Float64.(yhat1))
        se2=rmsd(data[:,:Traffic],Float64.(yhat2))
        r21=r2(mds[1])
        r22=r2(mds[2])
        c1=["Linear Model","Linear+Season Means"]
        c2=[r21,r22].|>(d->round(d,digits=2)).|>d->"$(100*d)%"
        c3=[se1,se2]
        report_table=DataFrame(Model=c1,R²=c2,SE=c3)
        #@pt  report_table
        #= 
                ┌─────────────────────┬────────┬─────────┐
                │               Model │     R² │      SE │
                │              String │ String │ Float64 │
                ├─────────────────────┼────────┼─────────┤
                │        Linear Model │  81.0% │  44.427 │
                │ Linear+Season Means │  95.0% │  22.735 │
                └─────────────────────┴────────┴─────────┘
        =#
#7.     lag-acf plot

        data=traffic[1:end-1]
        lag= traffic[2:end]
        diff=data-lag
        
        acf=autocor(diff)  # diff  autocor
        function plot_acf()
                fig=Figure()
                ax=Axis(fig[1,1];xlabel="Lag",ylabel="ACF",title="Price Lag ACF")
                stem!(ax,acf[2:end])
                fig
        end
        fig= plot_acf()
