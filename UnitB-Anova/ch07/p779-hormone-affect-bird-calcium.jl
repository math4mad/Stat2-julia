include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,Query,FreqTables
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1.  load data
    desc=Stat2Table(779,"BirdCalcium","hormone affect bird calciym",["Bird", "Sex", "Hormone", "Group", "Ca"])
    df=load_rda(desc.name)
    #= 
          Row │ Bird   Sex   Hormone  Group  Ca      
              │ Int32  Cat…  Cat…     Cat…   Float64 
         ─────┼──────────────────────────────────────
            1 │     1  male  no       M No      14.5
            2 │     2  male  no       M No      11.0
            3 │     3  male  no       M No      10.8
    =#
    data=select(df,[:Group,:Ca])
    transform!(df,:Ca=> ByRow(log10)=>:logCa)

   
# 2. construct contingency table

     gdf=groupby(data,:Group)
     
     M=@pipe [mean(df[:,:Ca]) for df in gdf].|>round.(_,digits=2)|>reshape(_,(2,2))|>transpose|>[0 1; 1 0]*_
     c1=["Male","Femal3","Diff"]
     c2=[M[1,1],M[2,1],M[2,1]-M[1,1]]
     c3=[M[1,2],M[2,2],M[2,2]-M[1,2]]
     c4=[M[1,2]-M[1,1],M[2,2]-M[2,1],nothing]
     ctable=DataFrame(sexual=c1,hormone_no=c2,hormone_yes=c3,diff=c4)
     #@pt ctable

     #= 
            ┌────────┬────────────┬─────────────┬─────────────────────┐
            │ sexual │ hormone_no │ hormone_yes │                diff │
            │ String │    Float64 │     Float64 │ U{Nothing, Float64} │
            ├────────┼────────────┼─────────────┼─────────────────────┤
            │   Male │      12.12 │       27.78 │               15.66 │
            │ Femal3 │      14.88 │       31.08 │                16.2 │
            │   Diff │       2.76 │         3.3 │             nothing │
            └────────┴────────────┴─────────────┴─────────────────────┘
     =#

# 3.  anova with normal   Ca   scale
        normal_model = lm(@formula(Ca ~ Hormone*Sex), df)
        anova(normal_model)
     
    
    #= 
       Type 1 test / F test

        Ca ~ 1 + Hormone + Sex + Hormone & Sex

    Table:
    ──────────────────────────────────────────────────────────────
                DOF     Exp.SS  Mean Square   F value  Pr(>|F|)
    ──────────────────────────────────────────────────────────────
    (Intercept)      1  9214.92      9214.92    470.9120    <1e-12
    Hormone          1  1268.82      1268.82     64.8410    <1e-06
    Sex              1    45.90        45.90      2.3459    0.1451
    Hormone & Sex    1     0.3645       0.3645    0.0186    0.8931
    (Residuals)     16   313.09        19.57                
    ──────────────────────────────────────────────────────────────
    =#

# 4.  anova with normal   Ca   scale
    log_model = lm(@formula(logCa ~ Hormone*Sex), df)
    anova(log_model)
    #= 
        Analysis of Variance

        Type 1 test / F test

        logCa ~ 1 + Hormone + Sex + Hormone & Sex

        Table:
        ─────────────────────────────────────────────────────────────
                    DOF   Exp.SS  Mean Square    F value  Pr(>|F|)
        ─────────────────────────────────────────────────────────────
        (Intercept)      1  33.40        33.40    5248.2041    <1e-20
        Hormone          1   0.5724       0.5724    89.9467    <1e-07
        Sex              1   0.0212       0.0212     3.3254    0.0870
        Hormone & Sex    1   0.0030       0.0030     0.4726    0.5016
        (Residuals)     16   0.1018       0.0064               
        ─────────────────────────────────────────────────────────────
    =#


     
