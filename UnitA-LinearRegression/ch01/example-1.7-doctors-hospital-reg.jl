#= 
 predict MDS with hospital
=#

include("../../utils.jl")


desc=Stat2Table(138,"CountyHealth","doctors-hospital-relation",["County","MDs","Hospitals","Beds"])
df=load_rda(desc.name)

# 1. scatter
fig,ax=plot_pair_scatter(df;xlabel="Hospitals",ylabel="MDs");fig

# 2.glm
model=lm(@formula(MDs ~Hospitals), df)
#= 
  MDs ~ 1 + Hospitals

Coefficients:
─────────────────────────────────────────────────────────────────────────
                 Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
─────────────────────────────────────────────────────────────────────────
(Intercept)  -1120.56     179.031   -6.26    <1e-07  -1479.98    -761.143
Hospitals      557.323     36.1766  15.41    <1e-20    484.695    629.95
─────────────────────────────────────────────────────────────────────────
=#

# 3. asses

#fig=plot_fitline_and_residual(;data=df,xlabel="Hospitals",ylabel="MDs",model=model)
fig=plot_lm_res(;data=df,xlabel="Hospitals",ylabel="MDs",model=model)







