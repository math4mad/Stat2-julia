
include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
using  StatsBase,TableTransforms
using  GLM,AnovaGLM

# 1. load data
    desc=Stat2Table(508,"AccordPrice","second hand car price predict",["Mileage","Price"])
    data=@pipe load_rda(desc.name)|>select(_,desc.feature)
    formula=@formula(Price ~Mileage)
# 2. scatter data
    #fig,ax=plot_pair_scatter(data,xlabel="Mileage",ylabel="Price");fig
    #save("./ch04/imgs/p508-accord-used-car-mileage-price-scatter.png",fig)
# 3. lm fitting
    model=lm(formula,data)  
    #= 
        Price ~ 1 + Mileage

        Coefficients:
        ──────────────────────────────────────────────────────────────────────────
                        Coef.  Std. Error      t  Pr(>|t|)  Lower 95%   Upper 95%
        ──────────────────────────────────────────────────────────────────────────
        (Intercept)  20.8096     0.952861   21.84    <1e-18  18.8578    22.7615
        Mileage      -0.119812   0.0140952  -8.50    <1e-08  -0.148685  -0.0909391
        ──────────────────────────────────────────────────────────────────────────
    =#
    #plot  fitline  residuals
        #fig=plot_fitline_and_residual(;data=data,xlabel="Mileage",ylabel="Price",model=model)
        #save("accord-mileage-price-fitline-residuals.png",fig)

#4. bootstrap sampleing 
    #bs_sample=(;data)|>Sample(25, replace=true)
   # models=Vector{RegressionModel}(undef, 30);
    # for (m,p) in zip(bs_sample.Mileage,bs_sample.Price)
    #     local model=lm(formula,(Mileage=m,Price=p)) 
    #     push!(models,model) 
    # end

    