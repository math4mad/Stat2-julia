 
"""
snippetslab://snippet/6F3A93ED-3E90-4D70-83FE-7B23C5C7D936
Introduction to Modern Statistics, First Edition by Mine Çetinkaya-Rundel and Johanna Hardin. 
https://openintro-ims.netlify.app
软件包  "openintro"  获得CSV 文件
1. 获取文件列表字符串
2. 获得 dataframe, 将字符串转换为 Symbol 作为 R 的参数  "Str"=>:Str
3. 转 csv,保存
"""

using CSV,DataFrames,RCall
"get list from R"
function get_list()::Vector{AbstractString}
    R"""
    library("openintro")
    info=data(package = "openintro")
    #df<-data.frame(d)
    """
    info=@rget info
    list=info[:results][:,3]
    return list
end
"save dfs to csv datasets"
function save_csv(list::Vector{AbstractString})
    for  str in list 
        d=Symbol(str)
        @rput d
        R"""
            library("openintro")
            df<-data.frame(d)
        """
        df=@rget df
        CSV.write("./openintro-dataset/$(str).csv", df)
    end
end

#get_list|>save_csv