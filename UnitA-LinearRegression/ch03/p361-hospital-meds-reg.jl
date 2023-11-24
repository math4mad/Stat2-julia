
include("utils.jl")
using RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
using  StatsBase
using  GLM,AnovaGLM

# 1. load data
    desc=Stat2Table(361,"CountyHealth","sqrt transform of meds ",["Hospitals","Beds","sqrtMDs"])
    # 对医生数做平方根变换
    data=@pipe load_rda(desc.name)|>transform!(_,[:MDs]=>ByRow(sqrt) => :sqrtMDs)|>select(_,desc.feature)
    
    formula=@formula(sqrtMDs~Hospitals+Beds+Hospitals*Beds)
 
# 2. pair plot
    #fig=plot_cor_group(data)#;save("./ch03/imgs/p361-hospital-meds-pairplot.png",fig)

# 3. fit  lm model
     model=lm(formula,data)
    #= 
     sqrtMDs ~ 1 + Hospitals + Beds + Hospitals & Beds

        Coefficients:
        ───────────────────────────────────────────────────────────────────────────────────────
                                Coef.   Std. Error      t  Pr(>|t|)    Lower 95%     Upper 95%
        ───────────────────────────────────────────────────────────────────────────────────────
        (Intercept)       -0.624785     1.72872      -0.36    0.7193  -4.09878      2.84921
        Hospitals          3.142        0.610159      5.15    <1e-05   1.91584      4.36816
        Beds               0.0218939    0.00259788    8.43    <1e-10   0.0166732    0.0271145
        Hospitals & Beds  -0.000975549  0.000211608  -4.61    <1e-04  -0.00140079  -0.000550306
        ───────────────────────────────────────────────────────────────────────────────────────
    =# 
    
# 4. computing vif
     computing_vif(data,formula)
     #= 
       3-element Vector{Float64}:
        6.022160572917638
        16.092173553522347
        14.418667425185658
     =#


    show(names(data))