"""
 data  with log transform 
"""

include("../../utils.jl")


desc=Stat2Table(146,"SpeciesArea","number of spices related to islands area",["Area","Species","logArea","logSpecies"])
df=@pipe load_rda(desc.name)

data=select(df,desc.feature[1:2])
log_data=select(df,desc.feature[3:4])
data1=select(df,["logArea","Species"])
data2=select(df,["logArea","logSpecies"])

fig,ax=plot_pair_scatter(log_data;xlabel="logArea",ylabel="logSpecies");fig
#save("mammalspices-in-islands-log-transform.png",fig)

model1=lm(@formula(Species ~logArea), data1)
y_hat1=predict(model1,select(data1,"logArea"))
#= 
  Species ~ 1 + logArea

    Coefficients:
    ────────────────────────────────────────────────────────────────────────
                    Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
    ────────────────────────────────────────────────────────────────────────
    (Intercept)  -28.9891     8.92336  -3.25    0.0070  -48.4315    -9.54678
    logArea       10.1074     1.17795   8.58    <1e-05    7.54082   12.6739
    ────────────────────────────────────────────────────────────────────────
=#

model2=lm(@formula(logSpecies ~logArea), data2)
y_hat2=predict(model2,select(data2,"logArea"))
#= 
    logSpecies ~ 1 + logArea

    Coefficients:
    ────────────────────────────────────────────────────────────────────────
                    Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
    ────────────────────────────────────────────────────────────────────────
    (Intercept)  1.62491    0.132552   12.26    <1e-07    1.3361    1.91371
    logArea      0.235474   0.0174979  13.46    <1e-07    0.19735   0.273599
    ────────────────────────────────────────────────────────────────────────
=#

function plot_reg()
    
    fig=Figure(resolution=(700,300))
    ax1=Axis(fig[1,1],xlabel="logArea",ylabel="Species")
    ax2=Axis(fig[1,2],xlabel="logArea",ylabel="logSpecies")
    Box(fig[1,1];color = (:orange,0.1),strokewidth=0.5)
    Box(fig[1,2];color = (:orange,0.1),strokewidth=0.5)
    scatter!(ax1,data1[:,1],data1[:,2])
    scatter!(ax2,data2[:,1],data2[:,2])
    lines!(ax1,data1[:,1],y_hat1)
    lines!(ax2,data2[:,1],y_hat2)
    fig
end

fig=plot_reg()#;save("islandarea-species-num-reg-with-logtransform.png",fig)



