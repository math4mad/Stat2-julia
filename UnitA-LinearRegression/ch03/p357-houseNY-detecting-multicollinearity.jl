include("utils.jl")
using RCall
using  GLMakie,DataFrames,Pipe,PrettyTables
using  StatsBase
using  GLM,AnovaGLM

# 1. load data
    desc=Stat2Table(357,"HousesNY","decting multicollinearity ",["Beds","Baths", "Size","Lot","Price"])
    data=@pipe load_rda(desc.name)|>select(_,desc.feature)
    formula=@formula(Price~Baths+Beds+Size+Lot) #define  lm formula
#====================================================#
# 2.  plot pair scatter
    #fig=plot_cor_group(data);
#====================================================#
# 3.  cor matrix
    function print_cormatrix()
        feature=DataFrame(Name=String.(desc.feature))
        df=@pipe  data|>Matrix|>cor|>round.(_,digits=2)|>DataFrame(_,desc.feature)
        cormatrix=hcat(feature,df)
        pretty_table(cormatrix)
    end
    #print_cormatrix()
    #= 
        ┌────────┬─────────┬─────────┬─────────┬─────────┬─────────┐
        │   Name │    Beds │   Baths │    Size │     Lot │   Price │
        │ String │ Float64 │ Float64 │ Float64 │ Float64 │ Float64 │
        ├────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
        │   Beds │     1.0 │    0.36 │    0.75 │   -0.21 │    0.42 │
        │  Baths │    0.36 │     1.0 │    0.42 │   -0.04 │    0.56 │
        │   Size │    0.75 │    0.42 │     1.0 │   -0.21 │    0.51 │
        │    Lot │   -0.21 │   -0.04 │   -0.21 │     1.0 │   -0.01 │
        │  Price │    0.42 │    0.56 │    0.51 │   -0.01 │     1.0 │
        └────────┴─────────┴─────────┴─────────┴─────────┴─────────┘
    =#
# 4.  lm fitting
    
    single_model=lm(formula,data)

 #= 
    Price ~ 1 + Beds + Baths + Size + Lot

    Coefficients:
    ───────────────────────────────────────────────────────────────────────
                    Coef.  Std. Error     t  Pr(>|t|)  Lower 95%  Upper 95%
    ───────────────────────────────────────────────────────────────────────
    (Intercept)  14.5899     23.2658   0.63    0.5336  -32.1892     61.369
    Beds          2.77075     8.73026  0.32    0.7523  -14.7826     20.3241
    Baths        26.2384      7.84382  3.35    0.0016   10.4673     42.0094
    Size         22.1551     11.9308   1.86    0.0695   -1.83333    46.1435
    Lot           4.62113     6.18388  0.75    0.4585   -7.8124     17.0547
    ───────────────────────────────────────────────────────────────────────
 =#

#  5.  nest lm fitting
    """
    在 嵌套模型nestmodels 中 formula=@formula(Price~Baths+Beds+Size+Lot),
    可以看做是 Baths 作为主要研究的对象, 其他变量作为共线性变量
    模型可以得到不同组合下的决定系数
    """
    nest_model = nestedmodels(LinearModel, formula, data; dropcollinear = false)
    anova(nest_model)
    
    #= 
        Analysis of Variance

        Type 1 test / F test

        Model 1: Price ~ 0
        Model 2: Price ~ 1
        Model 3: Price ~ 1 + Baths
        Model 4: Price ~ 1 + Baths + Beds
        Model 5: Price ~ 1 + Baths + Beds + Size
        Model 6: Price ~ 1 + Baths + Beds + Size + Lot

        Table:
        ─────────────────────────────────────────────────────────────────────────────────
        DOF  ΔDOF  Res.DOF       R²      ΔR²     Res.SS     Exp.SS   F value  Pr(>|F|)
        ─────────────────────────────────────────────────────────────────────────────────
        1    1             48   0                773604.57                         
        2    2     1       48  -0.0000  -0.0000   89255.40  684349.17  627.3888    <1e-29
        3    3     1       48   0.3117   0.3117   61434.26   27821.13   25.5055    <1e-05
        4    4     1       48   0.3674   0.0557   56465.51    4968.75    4.5552    0.0377
        5    5     1       48   0.4066   0.0392   52967.03    3498.48    3.2073    0.0795
        6    6     1       48   0.4134   0.0068   52357.90     609.14    0.5584    0.4585
        ─────────────────────────────────────────────────────────────────────────────────
    =#
    
# 6. computing VIF   
    #computing_vif(data,formula)