include("../utils.jl")

desc=Stat2Table(73,"WeightLossIncentive4","finanicial incentives for weightloss",[])
df=load_rda(desc.name)
gdf=groupby(df,:Group)
cats = @pipe keys(gdf) .|> values(_)[1]
group_data=[d.WeightLoss for d in gdf]

## 2. summary  
summary_tabele=summary_df(gdf,:WeightLoss)

@pt  summary_tabele
#= 
┌───────────────────────────────────────────────────┬───────┬─────────┬─────────┐
│                                             Group │     n │    Mean │  Stddev │
│ CategoricalArrays.CategoricalValue{String, UInt8} │ Int64 │ Float64 │ Float64 │
├───────────────────────────────────────────────────┼───────┼─────────┼─────────┤
│                                           Control │    19 │ 3.92105 │ 9.10779 │
│                                         Incentive │    17 │ 15.6765 │ 9.41399 │
└───────────────────────────────────────────────────┴───────┴─────────┴─────────┘
=#

## ttest
EqualVarianceTTest(group_data...)

#= 
Two sample t-test (equal variance)
----------------------------------
Population details:
    parameter of interest:   Mean difference
    value under h_0:         0
    point estimate:          -11.7554
    95% confidence interval: (-18.03, -5.478)

Test summary:
    outcome with 95% confidence: reject h_0
    two-sided p-value:           0.0006

Details:
    number of observations:   [19,17]
    t-statistic:              -3.8053869134160236
    degrees of freedom:       34
    empirical standard error: 3.089151832422667
=#


