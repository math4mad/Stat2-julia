"""
 data  with log transform 
"""

include("utils.jl")
using  GLMakie,DataFrames,Pipe,PrettyTables,StatsBase
using GLM,AnovaGLM

rad=Vector(1:3:50)
area=rad.^2*pi

df=DataFrame(Radius=rad,Area=area,logRadius=log.(rad),logArea=log.(area))

function plot_radius()
    fig=Figure(resolution=(800,300))
    ax1=Axis(fig[1,1],xlabel="Radius",ylabel="Area")
    ax2=Axis(fig[1,2],xlabel="logRadius",ylabel="logArea")
    scatter!(ax1,df[:,1],df[:,2];marker=:circle,markersize=10,color=(:purple,0.4),strokewidth=1,strokecolor=:black)
    scatter!(ax2,df[:,3],df[:,4];marker=:circle,markersize=10,color=(:purple,0.4),strokewidth=1,strokecolor=:black)
    fig
end

#fig=plot_radius();save("circle-area-log-transform.png",fig)


