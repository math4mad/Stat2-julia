include("utils.jl")
using RCall
using  GLMakie,DataFrames,Pipe,PrettyTables
using  StatsBase
using  GLM,AnovaGLM

# 1. load data
    desc=Stat2Table(435,"HousesNY","added variable plot",["Beds","Size","Price"])
    data=@pipe load_rda(desc.name)|>select(_,desc.feature)
    
# 2. fit price  with beds
      formula1=@formula(Price~Beds) 
      beds_model=lm(formula1,data)
      #= 
      Price ~ 1 + Beds
       Coefficients:
        ──────────────────────────────────────────────────────────────────────
                    Coef.  Std. Error     t  Pr(>|t|)  Lower 95%  Upper 95%
        ──────────────────────────────────────────────────────────────────────
        (Intercept)  39.239     23.1606   1.69    0.0963   -7.25789    85.7359
        Beds         21.9046     6.64424  3.30    0.0018    8.56575    35.2435
        ──────────────────────────────────────────────────────────────────────
      =#
      #r2(beds_model)  #0.175

 # 3. plot beds-price  fitline  residuals

   
    fig=plot_fitline_residuals(data, beds_model;feature=["Beds","Price"]) #;save("./ch04/imgs/p435-beds-price-reg.png",fig)
# 4. fit  size with beds
    formula2=@formula(Size~Beds) 
    size_model=lm(formula2,data)
    #= 
        Size ~ 1 + Beds

        Coefficients:
        ─────────────────────────────────────────────────────────────────────────
                        Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
        ─────────────────────────────────────────────────────────────────────────
        (Intercept)  -0.232901    0.245077  -0.95    0.3464  -0.724914   0.259113
        Beds          0.562682    0.070307   8.00    <1e-09   0.421535   0.703829
        ─────────────────────────────────────────────────────────────────────────
    =#
    fig=plot_fitline_residuals(data, size_model;feature=["Beds","Size"]) #;save("./ch04/imgs/p435-beds-price-reg.png",fig)
# 5. residuals dataframe
    res1=predict(beds_model,select(data,:Beds))
    res2=predict(size_model,select(data,:Beds))
    resid_df=DataFrame(res1=res1, res2=res2)
# 6.  fitting   residuals1-residuals2
     resid_model=lm(@formula(res1~res2),resid_df)
  #= 
    res1 ~ 1 + res2

    Coefficients:
    ─────────────────────────────────────────────────────────────────────────────────────
                Coef.   Std. Error                   t  Pr(>|t|)  Lower 95%  Upper 95%
    ─────────────────────────────────────────────────────────────────────────────────────
    (Intercept)  48.3056  1.19604e-13  403879502764897.12    <1e-99    48.3056    48.3056
    res2         38.929   6.89246e-14  564804596371234.12    <1e-99    38.929     38.929
    ─────────────────────────────────────────────────────────────────────────────────────
  =#

  # 7. plot res1-res2 plot
  #fig=plot_fitline_residuals(resid_df, resid_model;feature=["res2","res1"])
   scatter(res2,res1)