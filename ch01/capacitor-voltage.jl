"""
 log transform
"""


include("utils.jl")
using  GLMakie,DataFrames,Pipe,PrettyTables,StatsBase
using GLM

desc=Stat2Table(182,"Volts","电容放电电压与时间的关系,log变换电压值造成的差异",["Voltage","Time"])
df=@pipe load_rda(desc.name)
transform!(df, [:Voltage] => ByRow(log) =>:logVoltage)

"""
    plot_voltage(df::AbstractDataFrame)
    fig[1,1]: time-voltage  scatter
    fig[1,2]: time-logvolgate scatter
"""
function plot_voltage(df::AbstractDataFrame)
    fig=Figure(resolution=(800,300))
    ax1=Axis(fig[1,1],xlabel="time",ylabel="voltage")
    ax2=Axis(fig[1,2],xlabel="time",ylabel="logvoltage")
    scatter!(ax1,df[:,:Time],df[:,:Voltage],marker=:circle,markersize=12,color=(:red,0.4),strokewidth=2,strokecolor=:purple)
    scatter!(ax2,df[:,:Time],df[:,:logVoltage],marker=:circle,markersize=12,color=(:red,0.4),strokewidth=2,strokecolor=:purple)
    fig
end
#fig=plot_voltage(df);save("time-voltage-logvoltage-scatter.png",fig)

#lm
model=lm(@formula(logVoltage ~Time), df)
#= 
    logVoltage ~ 1 + Time

    Coefficients:
    ──────────────────────────────────────────────────────────────────────────
                    Coef.  Std. Error        t  Pr(>|t|)  Lower 95%  Upper 95%
    ──────────────────────────────────────────────────────────────────────────
    (Intercept)   2.18994  0.00463694   472.28    <1e-88    2.18062    2.19927
    Time         -2.05907  0.00815383  -252.53    <1e-75   -2.07546   -2.04267
    ──────────────────────────────────────────────────────────────────────────
=#

@pipe residuals(model)|>stem|>save("time-logvoltage-residuals.png",_)
