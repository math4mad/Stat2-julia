"""
125 只果蝇被随机分配到有不同雌性果蝇的房间:

1.  一只怀孕的雌性果蝇
2.  8只 雌性果蝇
3.  一只没有产过卵的雌性
4.  8 只没有产过卵的雌性
"""


include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1. load data
    desc=Stat2Table(583,"FruitFlies","male sexual activity shorten life long?",["Treatment","Longevity"])
    data=@pipe load_rda(desc.name)|>select(_,desc.feature)
    @pt first(data,2)
    gdf=groupby(data,:Treatment)
    cats=levels(data[:,:Treatment])
    colors=[:black,:green,:orange,:blue,:purple]
    #= 
        ┌───────────────────────────────────────────────────┬───────────┐
        │                                         Treatment │ Longevity │
        │ CategoricalArrays.CategoricalValue{String, UInt8} │     Int32 │
        ├───────────────────────────────────────────────────┼───────────┤
        │                                        8 pregnant │        35 │
        │                                        8 pregnant │        37 │
        └───────────────────────────────────────────────────┴───────────┘
    =#

#2. dot and box plot
    #fig=plot_dot_boxplot(gdf,cats,colors,"Longevity")
    #save("./ch05/imgs/p583-dot-boxplot.png",fig)

#3.  anova 分析
    
        model=lm(@formula(Longevity ~Treatment), data)
        anova(model)
        #= 
                    Table:
            ─────────────────────────────────────────────────────────────
                        DOF     Exp.SS  Mean Square    F value  Pr(>|F|)
            ─────────────────────────────────────────────────────────────
            (Intercept)    1  412419.20    412419.20  1880.7938    <1e-74
            Treatment      4   11939.28      2984.82    13.6120    <1e-08
            (Residuals)  120   26313.52       219.28               
            ─────────────────────────────────────────────────────────────
        =#
#3.  results
     """
     Treatment 的 pvalue 远小于 0.05 因此处理对于雄性果蝇的寿命是由影响的
     """
# 4. plot residuals by group

     resid=residuals(model)
     data.Residuals=resid
     resid_group=groupby(data,:Treatment)
      fig=plot_residuals_boxplot_qq(resid_group,resid,cats,colors,"Residuals")
      #save("./ch05/imgs/p583-anova-residuals-plot.png",fig)




