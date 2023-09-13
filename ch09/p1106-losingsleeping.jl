"""
数据显示方式变换

将
Row │ Person  Age    Outcome 
     │ Int32   Int32  Int32   
─────┼────────────────────────
   1 │      1     14        1
   2 │      2     18        0
   3 │      3     17        0
   4 │      4     18        1
   5 │      5     16        0
   6 │      6     15        0
   7 │      7     16        0
   8 │      8     17        1

   转变为:
   Row │ 14       15       16       17       18      
     │ Float64  Float64  Float64  Float64  Float64 
─────┼─────────────────────────────────────────────
   1 │   12.0     35.0     37.0     39.0      27.0
   2 │   34.0     79.0     77.0     65.0      41.0
   3 │   46.0    114.0    114.0    104.0      68.0
   4 │    0.74     0.69     0.68     0.62      0.6

步骤:

1 .  ft=freqtable(data,:Outcome,:Age) 按照行列转为 freqtable
2 .  按列统计比例 prob=@pipe prop(ft,margins=2)|>Matrix|>_[2,:]|>round.(_,digits=2)|>reshape(_,(1,5))
3 .  ft=> matrix 便于后续操作   mat=Matrix(ft)
4 .  按行合计:     mat_sum=sum(mat,dims=1)   dims=1
5 .  合并数据, 行总计, 比例数据  :summary_mat=vcat(mat,mat_sum,prob)
6 .  生成新的第一列,即每行的名称 c1=["l7","m7","total","propm7"]
7 .  获得列的名称 :cats=@pipe levels(data.Age)|>Symbol.(_)  转为  Symbol
8 .  利用 cats名生成新的dataframe, 并插入行名列, 并调整到第一列位置
"""

include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,Query
using  StatsBase,TableTransforms,FreqTables
using  GLM,AnovaGLM,HypothesisTests,CategoricalArrays

# 1. load data
    desc=Stat2Table(1106,"LosingSleep","children sleep status",["Age","Outcome"])
    data=@pipe load_rda(desc.name)
    
# 2. freqtable  
    colnames=["l7","m7","total","propm7"]



"""
    augment_freqtable(data::AbstractDataFrame,feature::Vector,colnames::Vector{String})
    
    在 freqtable 的基础上添加合计和比例行统计数据

## arguments
   1. data  long dataframe 形式
   2. feature :String或者 Symbol 数组, 第一元素为行,第二元素为列
   3. colnames:第一列的 title 用于注释
## 返回  dataframe 
   eg:  
```
   Row │ 14       15       16       17       18      
       │ Float64  Float64  Float64  Float64  Float64 
  ─────┼─────────────────────────────────────────────
     1 │   12.0     35.0     37.0     39.0      27.0
     2 │   34.0     79.0     77.0     65.0      41.0
```

"""
function augment_freqtable(data::AbstractDataFrame,feature::Vector,colnames)
        cats=@pipe levels(data[:,feature[2]])|>Symbol.(_)
        len=length(cats)
        ft=freqtable(data,feature)
        prob=@pipe prop(ft,margins=2)|>Matrix|>_[2,:]|>round.(_,digits=2)|>reshape(_,(1,len))
        mat=Matrix(ft)
        mat_sum=sum(mat,dims=1)
        summary_mat=vcat(mat,mat_sum,prob)
        summary_df=DataFrame([eachcol(summary_mat)...],cats)
        summary_df.title=colnames
        select!(summary_df,["title",cats...])
        return  summary_df
    end

augment_freqtable(data,["Outcome","Age"],colnames)
