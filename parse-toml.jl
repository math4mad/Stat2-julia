using TOML,Pkg

res=TOML.parsefile("Project.toml")
deps=res["deps"]
#ky=keys(deps)

arr=[]

for k in  keys(deps)
    push!(arr, k)
end
arr

Pkg.add(arr)


