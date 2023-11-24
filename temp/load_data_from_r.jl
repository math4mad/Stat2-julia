using RCall, DataFrames,CSV 

function load_df_R(name::AbstractString)::AbstractDataFrame
    @rput name
    R"""
    library("Stat2Data")
    df<-data.frame(name)
    """
    df=@rget df
    return df
end

df=load_df_R("MetroHealth83")


