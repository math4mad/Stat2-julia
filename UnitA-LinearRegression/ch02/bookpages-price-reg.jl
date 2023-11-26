include("../../utils.jl")


desc=Stat2Table(253,"TextPrices","pages-prices-reg",[:Pages,:Price])
data=@pipe load_rda(desc.name)


# 1. lm fitting
model=lm(@formula(Price~Pages), data)
#= 
  Price ~ 1 + Pages

    Coefficients:
    ──────────────────────────────────────────────────────────────────────────
                    Coef.  Std. Error      t  Pr(>|t|)   Lower 95%  Upper 95%
    ──────────────────────────────────────────────────────────────────────────
    (Intercept)  -3.42231   10.4637     -0.33    0.7461  -24.8563    18.0117
    Pages         0.147328   0.0192504   7.65    <1e-07    0.107896   0.186761
    ──────────────────────────────────────────────────────────────────────────
=#


fig=plot_lm_res(;data=data,xlabel="Pages",ylabel="Price",model=model)
#save("bookpages-price-reg.png",fig)

