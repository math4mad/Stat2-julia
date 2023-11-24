#init  
    include("utils.jl")
    import TimeSeries:lag,diff
    using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
    using  StatsBase,TimeSeries
        


#1. load csv->dataframe->timearray
    desc=Stat2Table(1440,"PeaceBridge2003","longer seasonal time series",["Year", "Month", "Traffic", "t"])
    data=@pipe load_rda(desc.name)
    @transform!(data, :time=Date.(:Year,:Month))
    ts2=TimeArray(data, timestamp = :time)
    
#2. diff operation
    lag1=1
    diff_order(order)=@pipe diff(ts2,order)|>DataFrame|>select(_,[:Traffic])
     firstorder_acf=diff_order(1)|>d->d[:,1]|>autocor
    #lag_acf=TimeSeries.lag(ts2)|>DataFrame|>d->d[:,:Traffic]|>autocor

#3. plot lag-1st-order difference -acf
    
    acf=lag(ts2,lag1)|>DataFrame|>d->d[:,:Traffic]|>autocor
    #fig=stem(acf)#;save("p1440-peace-bridge-lag-autocar.png",fig)

    dif1=diff(ts2)|>DataFrame|>d->d[:,:Traffic]|>autocor
    #fig=stem(difs) #;save("p1440-peace-bridge-diff-autocar.png",fig)
    
    #fig=lines(diff(ts2)|>DataFrame|>d->d[:,:Traffic])
    #save("p1440-peacebridge2003-diff.png",fig)

#4 . seasonal diff   lag=12  以年为季节周期
    lag12=12
    dif12=diff(ts2,lag12)|>DataFrame|>d->d[:,:Traffic]
    #fig=lines(dif12);save("p1440-peacebridge-12order-diff.png",fig)
    dif12_autocor=autocor(dif12)
    #fig=stem(dif12_autocor)#;save("p1440-peacebridge-12order-diff-autocar.png",fig)

#5. combine 1order diff and seasonal diff
    
     complex_diff=@pipe diff(ts2,lag1)|>diff(_,lag12)|>DataFrame|>d->d[:,:Traffic]
     #fig=lines(complex_diff)#;save("p1440-peacebridge-1order-(12order)seasonal-diff.png",fig)
     complex_diff_autocor=autocor(complex_diff)
     #fig=stem(complex_diff_autocor)#;save("p1440-peacebridge-1order-(12order)-seasonal-diff-autocar.png",fig)