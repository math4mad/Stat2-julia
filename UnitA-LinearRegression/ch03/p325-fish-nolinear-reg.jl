include("utils.jl")
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
using  StatsBase
using  GLM,AnovaGLM

desc=Stat2Table(325,"Perch","fish-length-width-weight-predict",[:Length,:Width,:Weight])
data=@pipe load_rda(desc.name)|>select(_,desc.feature)
transform!(data, [:Length,:Width,] => ByRow(*) => :lengthxwidth)

# 1. pairplot
#fig=plot_cor_group(data);save("./ch03/imgs/fish-nolinear-feature-pairscatter.png",fig)
# 2.  get cross feature
model1=lm(@formula(Weight ~lengthxwidth),data)

#= 
    Weight ~ 1 + lengthxwidth

    Coefficients:
    ──────────────────────────────────────────────────────────────────────────────
                    Coef.  Std. Error       t  Pr(>|t|)   Lower 95%   Upper 95%
    ──────────────────────────────────────────────────────────────────────────────
    (Intercept)   -136.926    12.728      -10.76    <1e-14  -162.444    -111.408
    lengthxwidth     3.31929   0.0680371   48.79    <1e-45     3.18288     3.45569
    ──────────────────────────────────────────────────────────────────────────────
=#

R²1=r2(model1) #0.9778


# 3. full model
model2=lm(@formula(Weight ~Length+Width+lengthxwidth),data)

#= 
Weight ~ 1 + Length + Width + lengthxwidth

Coefficients:
───────────────────────────────────────────────────────────────────────────
                  Coef.  Std. Error      t  Pr(>|t|)   Lower 95%  Upper 95%
───────────────────────────────────────────────────────────────────────────
(Intercept)   113.935     58.7844     1.94    0.0580    -4.0246   231.894
Length         -3.48269    3.1521    -1.10    0.2743    -9.80785    2.84246
Width         -94.6309    22.2954    -4.24    <1e-04  -139.37     -49.8918
lengthxwidth    5.24124    0.413121  12.69    <1e-16     4.41225    6.07023
───────────────────────────────────────────────────────────────────────────
=#
R²2=r2(model2)  #0.9846880497978845

