"""
@ref https://www.statology.org/two-way-table-in-r/
使用 PrettyTable 实现表格 hightlight 显示
"""

using DataFrames,PrettyTables,Pipe

data=@pipe ["Male" 13   15  20 ; "Femle" 23 16 13]
df=DataFrame(data,[:Gender,:BaseBall,:BasketBall,:FootBall])

transform!(df,[:BaseBall,:BasketBall,:FootBall] => ByRow(+) => :Sum)

#= total=combine(df,  :BaseBall=> sum => :BaseBall,:BasketBall=> sum => :BasketBall,:FootBall=> sum => :FootBall,
:BaseBall,:BasketBall,:FootBall=>(sum)=>:Sum  
)
insertcols!(total,1,:Gender=>["Total"])
vcat(df,total) =#