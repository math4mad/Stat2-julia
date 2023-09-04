include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1. load data
    desc=Stat2Table(540,"FatRats","high protein diet",["Gain","Protein","Source"])
    data=@pipe load_rda(desc.name)
    protein_gdf=groupby(data,:Protein)
    hiprotein_source_gdf=groupby(protein_gdf[1],:Source)
    cats=["Beef","Cereal","Pork"]
    colors=[:purple,:blue,:red]
# 2. plot dotplot,boxplot
    #fig=plot_dot_boxplot(hiprotein_source_gdf,cats,colors,"Gain")
    #save("./ch05/imgs/p540-rat-highprotien-gain-group-dot-boxplot.png",fig)

# 3. anova
  sample=[hiprotein_source_gdf[idx][:,:Gain] for (idx,cat) in enumerate(cats)]
  OneWayANOVATest(sample...)
  #= 
    One-way analysis of variance (ANOVA) test
    -----------------------------------------
    outcome with 95% confidence: fail to reject h_0
    p-value:                     0.0503
  =#


