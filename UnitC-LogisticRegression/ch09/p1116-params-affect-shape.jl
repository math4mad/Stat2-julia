
using GLMakie,Statistics,StatsFuns

xs1=range(0,4.5,100)
xs2=range(0,20,100)

function plot_res()
    dotstyles=[:dot,:solid,:dashdot]
    fig=Figure(resolution=(900,450))
    ax1=Axis(fig[1,1],title=L"change \beta_0,with \beta_1=5.5")
    ax2=Axis(fig[1,2],title=L"change \beta_1,with \beta_0=4")
    for (β₀,dotstyle) in zip([-17,-19,-21],dotstyles)
        expr(x)=logistic(5.5*x+β₀)
        lines!(ax1,xs1,expr.(xs1);linestyle=dotstyle,linewidth=3,label="β₀=$(β₀)")
    end

    for (β₁,dotstyle) in zip([-0.8,-0.5,-0.3],dotstyles)
        expr(x)=logistic(β₁*x+4)
        lines!(ax2,xs2,expr.(xs2);linestyle=dotstyle,linewidth=3,label="β₁=$(β₁)")
    end
    axislegend(ax1,position=:lb)
    axislegend(ax2,position=:lb)
    fig
end

fig=plot_res() #save("./ch09/imgs/p1116-params-affect-logistics-shape.png",fig)
