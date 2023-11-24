"""
    Model 4: Amount ~ 1 + Freq12 + Dollar12
    ────────────────────────────────────────────────────────────────────────────────
    DOF  ΔDOF  Res.DOF      R²     ΔR²      Res.SS     Exp.SS   F value  Pr(>|F|)
    ────────────────────────────────────────────────────────────────────────────────
    4    4     1       49  0.8718  0.8692    88715.51  601684.87  360.8340    <1e-24
    ────────────────────────────────────────────────────────────────────────────────
"""

include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
using  StatsBase
using  GLM,AnovaGLM

# 1. load data
    desc=Stat2Table(380,"Clothing","prediction customer spending ",["Recency", "Freq12", "Dollar12", "Freq24", "Dollar24", "Card","Amount"])
    df=@pipe load_rda(desc.name)|>select(_,desc.feature)
    #remove  outlier,  spendin =0 or very big
    data=@subset(df, :Amount .>0, :Amount .< 1506000)
    
# 2. pair plot
    #fig=plot_cor_group(data)#;save("./ch03/imgs/p380-customer-spending-pairplot.png",fig)

# 3. cor matrix  table
    #print_cormatrix(data, desc.feature)
    #= 
        ┌──────────┬─────────┬─────────┬──────────┬─────────┬──────────┬─────────┬─────────┐
        │     Name │ Recency │  Freq12 │ Dollar12 │  Freq24 │ Dollar24 │    Card │  Amount │
        │   String │ Float64 │ Float64 │  Float64 │ Float64 │  Float64 │ Float64 │ Float64 │
        ├──────────┼─────────┼─────────┼──────────┼─────────┼──────────┼─────────┼─────────┤
        │  Recency │     1.0 │   -0.58 │    -0.45 │   -0.55 │    -0.43 │   -0.33 │   -0.22 │
        │   Freq12 │   -0.58 │     1.0 │     0.56 │    0.71 │     0.42 │    0.33 │    0.05 │
        │ Dollar12 │   -0.45 │    0.56 │      1.0 │    0.48 │     0.83 │    0.51 │     0.8 │
        │   Freq24 │   -0.55 │    0.71 │     0.48 │     1.0 │      0.6 │     0.5 │     0.1 │
        │ Dollar24 │   -0.43 │    0.42 │     0.83 │     0.6 │      1.0 │    0.57 │    0.68 │
        │     Card │   -0.33 │    0.33 │     0.51 │     0.5 │     0.57 │     1.0 │    0.41 │
        │   Amount │   -0.22 │    0.05 │      0.8 │     0.1 │     0.68 │    0.41 │     1.0 │
        └──────────┴─────────┴─────────┴──────────┴─────────┴──────────┴─────────┴─────────┘
    =#

# 4. plot cor matrix
    #fig=plot_cormatrix_heatmap(data,"customer-feature")#;save("p380-customer-feature-cormatrix-hm.png",fig)

# 5. lm fitting   indepdent variable: Dollar12,  response variable :Amount
  # 5.1 fitting
  function single_var_lm(data)
    data1=select(data,[:Dollar12,:Amount])
    formula1=@formula(Amount~Dollar12)
    model1=lm(formula1,data1)
    return model1
  end
   #= 
   Amount ~ 1 + Dollar12

    Coefficients:
    ─────────────────────────────────────────────────────────────────────────
                    Coef.  Std. Error     t  Pr(>|t|)   Lower 95%  Upper 95%
    ─────────────────────────────────────────────────────────────────────────
    (Intercept)  10.0756    13.3783     0.75    0.4546  -16.7463    36.8975
    Dollar12      0.317557   0.0319965  9.92    <1e-13    0.253408   0.381706
    ─────────────────────────────────────────────────────────────────────────
  =#
   # 5.2  plot  res
    #fig=plot_lm_res(;data=data1,xlabel="Dollar12",ylabel="Amount",model=model1)
    #save("p380-dollar12-amount-reg.png",fig)

   # 5.3  R²=0.6459021291715572
    #r2(model1) 
    
# 6. nest model
   function nest_model_fitting()
        full_formula=@formula(Amount~(Freq12+Dollar12)+Recency+Freq24+Dollar24+Card)
        nest_model = nestedmodels(LinearModel, full_formula, data; dropcollinear = false)
        res=anova(nest_model)
        return res
   end
   #= 
    Analysis of Variance

        Type 1 test / F test

        Model 1: Amount ~ 0
        Model 2: Amount ~ 1
        Model 3: Amount ~ 1 + Freq12
        Model 4: Amount ~ 1 + Freq12 + Dollar12
        Model 5: Amount ~ 1 + Freq12 + Dollar12 + Recency
        Model 6: Amount ~ 1 + Freq12 + Dollar12 + Recency + Freq24
        Model 7: Amount ~ 1 + Freq12 + Dollar12 + Recency + Freq24 + Dollar24
        Model 8: Amount ~ 1 + Freq12 + Dollar12 + Recency + Freq24 + Dollar24 + Card

        Table:
        ────────────────────────────────────────────────────────────────────────────────
        DOF  ΔDOF  Res.DOF      R²     ΔR²      Res.SS     Exp.SS   F value  Pr(>|F|)
        ────────────────────────────────────────────────────────────────────────────────
        1    1             49  0               1348888                            
        2    2     1       49  0       0        692243.43  656644.57  393.7936    <1e-26
        3    3     1       49  0.0027  0.0027   690400.39    1843.04    1.1053    0.2978
        4    4     1       49  0.8718  0.8692    88715.51  601684.87  360.8340    <1e-24
        5    5     1       49  0.8751  0.0033    86445.99    2269.52    1.3610    0.2487
        6    6     1       49  0.8794  0.0043    83458.96    2987.04    1.7913    0.1867
        7    7     1       49  0.8795  0.0001    83385.35      73.60    0.0441    0.8344
        8    8     1       49  0.8820  0.0024    81706.72    1678.63    1.0067    0.3206
        ────────────────────────────────────────────────────────────────────────────────
   =#



   
#=7. based on 6, we choose two variables: Freq12 + Dollar12 


  # then make some tuning
  Dollar12/Freq12  表示为 12 个月内花销每次花销的均值, 未来的每次的消费值应该在这个值附近,
  因此复合值作为 explanatory variables 是个不错的选择, 
  由于有顾客的Dollar12 为 0 ,所以需要过滤掉, 这样损失了样本中的个体,稍后考虑这个问题
   =# 
   complex_data= @chain data begin
    @subset(:Dollar12.>0)
    @transform(:AvgSpent12 = :Dollar12./:Freq12)
  end
   
   function fit_combine_var_lm(data::AbstractDataFrame,formula)
     model=lm(formula,data)
     return model
   end
   #7.1 
   complex_formula1=@formula(Amount~AvgSpent12)
   complex_model1=fit_combine_var_lm(complex_data,complex_formula1)
   
   #= 
     Amount ~ 1 + AvgSpent12

    Coefficients:
    ─────────────────────────────────────────────────────────────────────────
                    Coef.  Std. Error      t  Pr(>|t|)  Lower 95%  Upper 95%
    ─────────────────────────────────────────────────────────────────────────
    (Intercept)  -38.8254    8.34378    -4.65    <1e-04  -55.5844   -22.0665
    AvgSpent12     1.43681   0.0642007  22.38    <1e-26    1.30786    1.56576
    ─────────────────────────────────────────────────────────────────────────
   =#
   #r2(complex_model1)  #0.9092333821974714

   
   #@pipe (complex_data,complex_model1)|>plot_lm_res(;data=_[1],xlabel="AvgSpent12",ylabel="Amount",model=_[2])
   #|>save("p380-combinevariables-reg.png",_)
   #7.2 square transform

   complex_formula2=@formula(Amount~AvgSpent12+AvgSpent12^2)
   complex_model2=fit_combine_var_lm(complex_data,complex_formula2)
   #= 
    Amount ~ 1 + AvgSpent12 + :(AvgSpent12 ^ 2)

    Coefficients:
    ────────────────────────────────────────────────────────────────────────────────────
                        Coef.    Std. Error     t  Pr(>|t|)     Lower 95%    Upper 95%
    ────────────────────────────────────────────────────────────────────────────────────
    (Intercept)     14.0224      14.5669       0.96    0.3405  -15.2509      43.2956
    AvgSpent12       0.570852     0.214508     2.66    0.0105    0.139781     1.00192
    AvgSpent12 ^ 2   0.00228933   0.000547657  4.18    0.0001    0.00118877   0.00338989
    ────────────────────────────────────────────────────────────────────────────────────
   =#
   #r2(complex_model2)  #0.9330934377677886
   #@pipe (complex_data,complex_model2)|>plot_lm_res(;data=_[1],xlabel="AvgSpent12",ylabel="Amount",model=_[2])
   #|>save("p380-combinevariables-reg-2.png",_)



   


    

   




