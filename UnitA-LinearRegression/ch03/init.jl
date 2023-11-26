include("../../utils.jl")


desc=Stat2Table(138,"CountyHealth","hospital-predict-doctors-number",["County","MDs","Hospitals","Beds"])
data=@pipe load_rda(desc.name)|>select(_,desc.feature[1:3])
