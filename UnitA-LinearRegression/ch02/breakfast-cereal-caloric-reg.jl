include("../../utils.jl")


desc=Stat2Table(253,"Cereal","sugar-calories-reg",["Cereal","Calories","Sugar","Fiber"])
data=@pipe load_rda(desc.name)|>select(_,"Calories","Sugar")


# 1. lm fitting
model=lm(@formula(Calories~Sugar), data)
#= 
 Calories ~ 1 + Sugar

    Coefficients:
    ────────────────────────────────────────────────────────────────────────
                    Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
    ────────────────────────────────────────────────────────────────────────
    (Intercept)  87.4277     5.16268   16.93    <1e-17    76.9359   97.9195
    Sugar         2.48081    0.707399   3.51    0.0013     1.0432    3.91842
    ────────────────────────────────────────────────────────────────────────
=#


fig=plot_lm_res(;data=data,xlabel="Sugar",ylabel="Calories",model=model)
#save("breakfast-sugar-calories-reg.png",fig)