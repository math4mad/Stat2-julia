include("utils.jl")
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
using  StatsBase
using  GLM,AnovaGLM

desc=Stat2Table(337,"CO2Germany","co2-multinomial-reg",[:Day,:CO2])
data=@pipe load_rda(desc.name)#|>select(_,desc.feature)

model=lm(@formula(CO2 ~Day+Day^2),data)
time=@pipe select(data,:Day)
yhat=predict(model,time)

function plot_fitline()
    fig=Figure()
    ax=Axis(fig[1,1])
    scatter!(ax,data[:,:Day],data[:,:CO2])
    lines!(ax,data[:,:Day], yhat;linewidth=4,color=(:orange),label="fit curve")
    axislegend(ax)
    fig
end

fig=plot_fitline()#;save("./ch03/imgs/p337-co2-multinomial-reg.png",fig)


fig=plot_lm_res(;data=data,xlabel="Day",ylabel="CO2",model=model)#;save("./ch03/imgs/p337-co2-quadratic-reg.png",fig)