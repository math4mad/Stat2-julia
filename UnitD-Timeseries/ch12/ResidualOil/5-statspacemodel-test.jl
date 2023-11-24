using CSV, DataFrames,Plots

plotly()
using StateSpaceModels
air_passengers = CSV.File(StateSpaceModels.AIR_PASSENGERS) |> DataFrame
log_air_passengers = log.(air_passengers.passengers)
model = SARIMA(log_air_passengers; order = (0, 1, 1), seasonal_order = (0, 1, 1, 12))
fit!(model)
forec = forecast(model, 12)
plot(model, forec; legend = :topleft)


