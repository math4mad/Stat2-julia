
"""
1. plot pair scatter
2. lm fitting
3. anova table
4. plot  residals and  qqplot
"""

include("utils.jl")
using  GLMakie,DataFrames,Pipe,PrettyTables
using  StatsBase
using  GLM,AnovaGLM

desc=Stat2Table(293,"NFLStandings2016","defense offense  which is important ",["PointsFor","PointsAgainst","WinPct"])
data=@pipe load_rda(desc.name)|>select(_,desc.feature)

# 1. plot pair scatter
#fig=plot_cor_group(data);#save("nfl-offense-defense-to-win-scatter.png",fig)

# 2. lm fitting
lm_model=lm(@formula(WinPct ~ PointsFor+ PointsAgainst),data)
#= 
    WinPct ~ 1 + PointsFor + PointsAgainst

    Coefficients:
    ──────────────────────────────────────────────────────────────────────────────────
                        Coef.   Std. Error      t  Pr(>|t|)    Lower 95%    Upper 95%
    ──────────────────────────────────────────────────────────────────────────────────
    (Intercept)     0.78537     0.153742      5.11    <1e-04   0.470932     1.09981
    PointsFor       0.00169915  0.000262793   6.47    <1e-06   0.00116168   0.00223663
    PointsAgainst  -0.00248158  0.000320446  -7.74    <1e-07  -0.00313696  -0.00182619
    ──────────────────────────────────────────────────────────────────────────────────
=#

# 3. anova table

anove_table=anova(lm_model)

#= 
    Analysis of Variance

    Type 1 test / F test

    WinPct ~ 1 + PointsFor + PointsAgainst

    Table:
    ───────────────────────────────────────────────────────────
                DOF  Exp.SS  Mean Square   F value  Pr(>|F|)
    ───────────────────────────────────────────────────────────
    (Intercept)      1  8.0080       8.0080  859.3748    <1e-22
    PointsFor        1  0.4126       0.4126   44.2797    <1e-06
    PointsAgainst    1  0.5588       0.5588   59.9716    <1e-07
    (Residuals)     29  0.2702       0.0093              
    ───────────────────────────────────────────────────────────
=#

# 4. plot  residals and  qqplot
#fig=plot_residuals_qq(lm_model);save("./ch03/nfl-offense-defense-to-win-residuals&qqnoramal.png",fig)


#5.  R²
#R²=r2(lm_model)  #0.7823661947815876



