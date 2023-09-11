


include("utils.jl")
using  RCall
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta,Query
using  StatsBase,TableTransforms
using  GLM,AnovaGLM,HypothesisTests

# 1. load data

    desc=Stat2Table(1106,"MedGPA","children sleep status",["Accept","Acceptance","GPA","MCAT"])
    data=@pipe load_rda(desc.name)|>select(_,desc.feature)

# 2. lm and logistic  reg
    #model=glm(@formula(Acceptance~GPA+MCAT), data, Binomial(), ProbitLink())
    model1=lm(@formula(MCAT~GPA), data)
    model2=glm(@formula(Acceptance~GPA), data, Binomial(), ProbitLink())
    xtest=DataFrame(GPA=Vector(range(2.5,4.0,100)))
    yhat1=predict(model1,xtest)
    yhat2=predict(model2,xtest)

# 3. plot tow type model
   function plot_models()
    fig=Figure(resolution=(900,400))
    ax1=Axis(fig[1,1],xlabel="GPA",ylabel="MCAT")
    ax2=Axis(fig[1,2],xlabel="GPA",ylabel="P(Accept)")
    scatter!(ax1, data[:,:GPA],data[:,:MCAT])
    lines!(ax1,xtest[:,:GPA],yhat1;color=:orange)
    scatter!(ax2,data[:,:GPA],data[:,:Acceptance])
    lines!(ax2,xtest[:,:GPA],yhat2;color=:orange)
    fig
   end
   #fig=plot_models()#;save("./ch09/imgs/p1114-medgpa-lm-logistics-reg.png",fig)



 model2
    
    