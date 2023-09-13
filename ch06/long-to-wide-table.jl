
"""
 long dataframe  => wide dataframe
Row │ ID     Rate   Subj  Drug 
     │ Int32  Int32  Cat…  Cat… 
─────┼──────────────────────────
   1 │     1     11  A     Pl
   2 │     2     56  B     Pl
   3 │     3     15  C     Pl
   4 │     4      6  D     Pl
   5 │     5     26  A     Ca
   6 │     6     83  B     Ca
   7 │     7     34  C     Ca
   8 │     8     13  D     Ca
   9 │     9     20  A     Th
  10 │    10     71  B     Th
  11 │    11     41  C     Th
  12 │    12     32  D     Th

  转为下面的形式

 Row │ Subj  Pl      Ca      Th     
     │ Cat…  Int32?  Int32?  Int32? 
─────┼──────────────────────────────
   1 │ A         11      26      20
   2 │ B         56      83      71
   3 │ C         15      34      41
   4 │ D          6      13      32

   采用的方法是:
   unstack(df::AbstractDataFrame, rowkeys, colkey, value;
        renamecols::Function=identity, allowmissing::Bool=false,
        combine=only, fill=missing, threads::Bool=true)
    
    在本例中 Subj 作为 rowkeys, Drug 作为 colkeys, Rate 为值

    从 long df===>  wide df

"""

include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,Query,FreqTables
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1.  load data
    desc=Stat2Table(699,"FranticFingers","drug affect response ability",["ID", "Rate", "Subj", "Drug"])
    data=@pipe load_rda(desc.name)
   
    #= 
       这个方法不对
       wide_frame = @from i in data begin
        @group i by i.Subj into g
        @select {group=key(g),Pl=(g.Drug=="Ca" ?  g.Rate : nothing)}
        @collect DataFrame
    end
    wide_frame =#
    
    wide_df=unstack(data, :Subj,:Drug,:Rate)
    #= 
      4×4 DataFrame
          Row │ Subj  Pl      Ca      Th     
              │ Cat…  Int32?  Int32?  Int32? 
         ─────┼──────────────────────────────
            1 │ A         11      26      20
            2 │ B         56      83      71
            3 │ C         15      34      41
            4 │ D          6      13      32
    =#
    
    transform!(wide_df,:Pl,:Ca,:Th=> ByRow(mean)=>:Ave)  #添加一列均值
    
   
