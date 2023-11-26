include("../../utils.jl")


desc=Stat2Table(138,"CountyHealth","doctors-hospital-relation",["County","MDs","Hospitals","Beds"])
df=load_rda(desc.name)

transform!(df, [:MDs] => ByRow(sqrt) =>:sqrt_MDs)

# 1. scatter
#fig,ax=plot_pair_scatter(df;xlabel="Hospitals",ylabel="sqrt_MDs")
#save("doctors-hospital-reg-with-sqrt-transform-scatter.png",fig)
# 2.glm
model=lm(@formula(sqrt_MDs ~Hospitals), df)
#= 
 sqrt_MDs ~ 1 + Hospitals

    Coefficients:
    ────────────────────────────────────────────────────────────────────────
                    Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
    ────────────────────────────────────────────────────────────────────────
    (Intercept)  -2.75333    1.98496   -1.39    0.1714   -6.73831    1.23166
    Hospitals     6.87636    0.401101  17.14    <1e-22    6.07112    7.68161
    ────────────────────────────────────────────────────────────────────────
=#
# 3  asses
fig=plot_lm_res2(;data=df,xlabel="Hospitals",ylabel="sqrt_MDs",model=model)
#save("hospital-sqrt_doctors_linreg.png",fig)
