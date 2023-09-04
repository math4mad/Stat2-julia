
include("utils.jl")
using  GLMakie,DataFrames,Pipe,PrettyTables,StatsBase
using GLM,AnovaGLM

desc=Stat2Table(105,"AccordPrice","describe table",["Age","Price","Mileage"])
df=load_rda(desc.name)

#@pt df[1:8,:]
#= 
    ┌───────┬─────────┬─────────┐
    │   Age │   Price │ Mileage │
    │ Int32 │ Float64 │ Float64 │
    ├───────┼─────────┼─────────┤
    │     7 │    12.0 │    74.9 │
    │     4 │    17.9 │    53.0 │
    │     4 │    15.7 │    79.1 │
    │     7 │    12.5 │    50.1 │
    │     9 │     9.5 │    62.0 │
    │     1 │    21.5 │     4.8 │
    │    18 │     3.5 │    89.4 │
    │     2 │    22.8 │    20.8 │
    └───────┴─────────┴─────────┘
=#

low_group=filter(row -> row.Mileage <=25.0 , df)
high_group=filter(row -> row.Mileage >=65.0 , df)
mid_group=filter(row -> 25.0<row.Mileage<65.0, df)
gdf=[low_group,mid_group,high_group]
median_arr=@pipe gdf.|>_[:,3].|>median.|>round(_,digits=0)

function plot_boxplot()
    fig=Figure()
    ax=Axis(fig[1,1],xlabel="Mileage",ylabel="Price")
    ax.title="accord-mileage-price"
    ax.xticks =(1:3,["15","52","88"])
    for (idx,df) in enumerate(gdf)
        row,col=size(df)
        boxplot!(ax, fill(idx,row),gdf[idx][:,"Price"];)

    end
    fig
    #save("accord-mileage-price-boxplot.png",fig)
end

function plot_statter(df)
    fig=Figure()
    ax=Axis(fig[1,1],xlabel="Mileage",ylabel="Price")
    ax.title="accord-mileage-price"
    Box(fig[1,1];color = (:orange,0.1),strokewidth=0.5)
    scatter!(ax,df[!,:Mileage],df[!,:Price];marker=:circle,markersize=14,color=(:lightgreen,0.3),strokewidth=1,strokecolor=:black)
   return (fig,ax)
    #save("accord-mileage-price-scatterplot.png",fig)
end

#plot_statter()

#相关系数
#cor(df[!,:Mileage],df[!,:Price])  #-0.8489441492220791


#  glm

model=lm(@formula(Price ~Mileage), df)

#= 
    Price ~ 1 + Mileage

    Coefficients:
    ──────────────────────────────────────────────────────────────────────────
                    Coef.  Std. Error      t  Pr(>|t|)  Lower 95%   Upper 95%
    ──────────────────────────────────────────────────────────────────────────
    (Intercept)  20.8096     0.952861   21.84    <1e-18  18.8578    22.7615
    Mileage      -0.119812   0.0140952  -8.50    <1e-08  -0.148685  -0.0909391
    ──────────────────────────────────────────────────────────────────────────
=#

R²=r2(model)  #0.72


"""
    plot_res(res::AbstractArray)
    绘制残差图
"""
function plot_res(res::AbstractArray)
    fig=Figure()
    ax=Axis(fig[1,1])
    stem!(ax,res)
    fig
    #save("accord-mileage-price-lm-residuals.png",fig)
end
#residuals(model)|>plot_res

#predict(model,DataFrame(Mileage=[74.9]))  # 11.9

function plot_fit_line()
    xs=df[!,:Mileage]
    y_hat=predict(model,select(df,:Mileage))
    _,ax=plot_statter(df)
    lines!(ax,xs,y_hat)
    #save("accord-mileage-price-reg-line.png",fig)  
end


"""
    plot_qqnorm(model)
    ref:Makie.jl/examples/plotting_functions/qqplot/
    
"""
function plot_qqnorm(model)
    res=residuals(model)
    fig,_,_=qqnorm(res, qqline = :fitrobust)
    #save("accord-price-linreg-qqnorm.png",fig)
end

function plot_density(model)
    res=residuals(model)
    fig,_,_=density(res,color=(:lightblue,0.5))
    #save("accord-price-linreg-residuals-density.png",fig)
end



