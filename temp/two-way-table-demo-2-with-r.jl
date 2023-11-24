"""
@ref https://www.statology.org/two-way-table-in-r/
使用 PrettyTable 实现表格 hightlight 显示
"""

using DataFrames,PrettyTables,Pipe,RCall

R"""
    df <- data.frame(sport=c('Base', 'Base', 'Bask', 'Foot', 'Foot'),
                    gender=c('Male', 'Female', 'Male', 'Male', 'Female'))

    #view data frame 
    df

    #create two way table from data frame
    data <- table(df$gender, df$sport)

    #display two way table
    data 
"""
df=@rget data