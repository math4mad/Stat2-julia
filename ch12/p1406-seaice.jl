
include("utils.jl")
    using  RCall
    using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,FreqTables
    using  StatsBase,TableTransforms
    using  GLM,AnovaGLM,HypothesisTests

#1.   load data
    desc=Stat2Table(1406,"SeaIce","sea ice  time series",["Year", "Extent", "Area", "t"])
    data=@pipe load_rda(desc.name)

#2.   plot  time-extend series
   
    fig,ax,plt=scatterlines(data[:,:Year],data[:,:Extent];marker_style...)
    #save("./ch12/imgs/p1406-seaice-timeseries.png",fig)

#3.   Year-Extent  linear regression
      model1=lm(@formula(Extent~Year), data)
    #= 
            Extent ~ 1 + Year

            Coefficients:
            ───────────────────────────────────────────────────────────────────────────────
                            Coef.   Std. Error       t  Pr(>|t|)   Lower 95%    Upper 95%
            ───────────────────────────────────────────────────────────────────────────────
            (Intercept)  180.729     17.397        10.39    <1e-11  145.411     216.047
            Year          -0.087321   0.00871143  -10.02    <1e-11   -0.105006   -0.0696359
            ───────────────────────────────────────────────────────────────────────────────
    =#
   


#4.   predict and plot fit line
        xs=select(data,:Year)
        yhat=predict(model1,)|>arr->round.(arr,digits=3)
        lines!(ax,data[:,:Year],yhat)
        ax.title="time-seaice-linear-reg"
        fig
        #save("p1406-time-seaice-linear-reg.png",fig)

#5.   using t scale as predict varible, 
        # t_scale=data[:,:Year].-min(data[:,:Year]...)
        model2=lm(@formula(Extent~t), data)
        #= 
            Extent ~ 1 + t

            Coefficients:
            ───────────────────────────────────────────────────────────────────────────
                            Coef.  Std. Error       t  Pr(>|t|)  Lower 95%   Upper 95%
            ───────────────────────────────────────────────────────────────────────────
            (Intercept)   8.00802   0.189861     42.18    <1e-30   7.62258    8.39346
            t            -0.087321  0.00871143  -10.02    <1e-11  -0.105006  -0.0696359
            ───────────────────────────────────────────────────────────────────────────
        =#
        
#6.   plot t-scale-extent fitline
        fig2,ax2,plt2=scatterlines(data[:,:t],data[:,:Extent];marker_style...)
        xs2=select(data,:t)
        yhat=predict(model2,xs2)|>arr->round.(arr,digits=3)
        lines!(ax2,data[:,:t],yhat)
        ax2.title="time-seaice-linear-reg"
        #fig2 ;save("t-scale-exten-linearreg.png",fig2)
        resid2=residuals(model2)|>arr->round.(arr,digits=3)
#7.   plot t-scale-extent linreg  residuals
        fig3,ax3,plt3= scatterlines(data[:,:t],resid2;marker_style...)
        hlines!(ax3,[0],linestyle=:dot, linewidth=2,color=(:red, 0.8))
        ax3.title="t-scale-extent linreg  residuals"
        #fig3;save("./ch12/imgs/p1406-t-extent-linreg-residuals.png",fig3)
#8.   according to 7. residuals , we add  quadartic term

        model3=lm(@formula(Extent~t+t^2), data)
        #= 
            Extent ~ 1 + t + :(t ^ 2)

            Coefficients:
            ────────────────────────────────────────────────────────────────────────────────
                            Coef.  Std. Error      t  Pr(>|t|)    Lower 95%     Upper 95%
            ────────────────────────────────────────────────────────────────────────────────
            (Intercept)   7.47048     0.273792    27.29    <1e-23   6.91406      8.02689
            t            -0.00462226  0.0332254   -0.14    0.8902  -0.0721445    0.0628999
            t ^ 2        -0.00217628  0.00084804  -2.57    0.0149  -0.00389971  -0.000452858
            ────────────────────────────────────────────────────────────────────────────────
        =#
        #r2(model3)  #0.78
#9.    plot  quadartic  fit  
            fig4,ax4,plt4=scatterlines(data[:,:t],data[:,:Extent];marker_style...)
            xs4=select(data,:t)
            yhat4=predict(model3,xs4)|>arr->round.(arr,digits=3)
            lines!(ax4,data[:,:t],yhat4)
            ax4.title="time-seaice-quad-reg"
            #fig4 ;save("t-scale-extent-quadreg.png",fig4)
        