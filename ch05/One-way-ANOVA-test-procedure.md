
# One-way Anova test  workflow  in julia

## 1. load data and group

## 2. exploring data 
      dotplot, boxplot
      ```julia
       gdf=groupby(data,:Group)
      ```

## 3. Fitting ANOVA  model
    ```julia
        sample=[gdf[idx][:,:Age] for (idx,cat) in enumerate(cats)]
        OneWayANOVATest(sample...)
    ```

## 4.  ANOVA 是基于分析组之间的方差没有差异的前提, 需要对方差齐性进行检验
       
    ```julia
     LeveneTest(sample...)
    ```

## 5. analysis  anova table
      
       One-way analysis of variance (ANOVA) test
        -----------------------------------------
        Population details:
            parameter of interest:   Means
            value under h_0:         "all equal"
            point estimate:          NaN

        Test summary:
            outcome with 95% confidence: fail to reject h_0
            p-value:                     0.1039

        Details:
            number of observations: [6, 6, 6, 6]
            F statistic:            2.34179
            degrees of freedom:     (3, 20)
      
## 6. One-way ANOVA 检验的假设

      h₀: 组间均值没有差异
      hₐ: 组间均值有差异 
## 7. One-way ANOVA 的 ad-hoc 检验 
      One-way ANOVA对均值进行检验,是否有差异, 但是并不能告诉我们到底哪些组之间有差异
      所以需要进行后续实验 方法有 `TukeyHSD()`,实际就是组之间的配对 t检验的组合

      
