```@setup glm
function plot_histogram(xs, f; kwargs...)
    plt = histogram(xs;
        label="Sampled density",
        xlabel = "x",
        ylabel = "pdf(x)",
        nbins = 85,
        normalize = :pdf,
        opacity = 0.5,
        kwargs...
    )

    plot!(plt, range(minimum(xs), maximum(xs); length=100), f;
        label="True density",
        line=(4,:black),
    )

    return plt
end
```


# [Linear regression revisited](@id statistics)

This section revisits the linear regression. The classical statistical approach uses derives the same formulation for linear regression as the optimization approach. Besides point estimates for parameters, it also computes their confidence intervals and can test whether some parameters can be omitted from the model. We will start with hypothesis testing and then continue with regression.

Julia provides lots of statistical packages. They are summarized at the [JuliaStats](https://juliastats.org/) webpage. This section will give a brief introduction to many of them.




## Theory of hypothesis testing

Hypothesis testing verifies whether data satisfy a given null hypothesis ``H_0``. Most of the tests need some assumptions about the data, such as normality. Under the validity of the null hypothesis, the test derives that a transformation of the data follows some distribution. Then it constructs a confidence interval of this distribution and checks whether the transformed variable lies in this confidence interval. If it lies outside of it, the test rejects the null hypothesis. In the opposite case, it fails to reject the null hypothesis. The latter is different from confirming the null hypothesis. Hypothesis testing is like a grumpy professor during exams. He never acknowledges that a student knows the topic sufficiently, but he is often clear that the student does not know it.

An example is the one-sided [Student's t-test](https://en.wikipedia.org/wiki/Student's_t-test) that verifies that a one-dimensional dataset has mean ``\mu``. It can be generalized to compare the mean (performance) of two datasets. Under some assumptions, it derives that

```math
t = \sqrt{n}\frac{\hat \mu - \mu}{\hat\sigma}
```

follows the [Student's distribution](https://en.wikipedia.org/wiki/Student%27s_t-distribution) with ``n-1`` degrees of freedom. Here, ``n`` is the number of datapoints. Their mean is ``\hat \mu`` and their standard deviation ``\hat \sigma``. Instead of computing the confidence interval, the usual way is to define the [``p``-value](https://en.wikipedia.org/wiki/P-value)

```math
p = 2\min\{\mathbb P(T\le t \mid H_0), \mathbb P(T\ge t\mid H_0)\}
```

If the ``p``-value is smaller than a given threshold, usually ``5\%``, the null hypothesis is rejected. In the opposite case, it is not rejected. The ``p``-value is a measure of the probability that an observed difference could have occurred just by random chance.




## Hypothesis testing



We first randomly generate data from the normal distribution with zero mean.

```@example glm
using Random
using Statistics
using LinearAlgebra
using Plots

Random.seed!(666)

n = 1000
xs = randn(n)

nothing # hide
```

The following exercise performs the ``t``-test to check whether the data come from a distribution with zero mean.





```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise:</header>
<div class="admonition-body"><p>
```
Use the ``t``-test to verify whether the samples were generated from a distribution with zero mean.

**Hint**: the Student's distribution is invoked by `TDist()`.

**Hint**: the probability ``\mathbb P(T\le t)`` equals to the [distribution function](https://en.wikipedia.org/wiki/Cumulative_distribution_function) ``F(t)``, which can be called by `cdf`.
```@raw html
</p></div></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

We compute the statistic ``t``, then define the Student's distribution with ``n-1`` degrees of freedom, evaluate the distribution function at ``t`` and finally compute the ``p``-value.

```@example glm
using Distributions

t = mean(xs) / std(xs) * sqrt(n)

prob = cdf(TDist(n-1), t)
p = 2*min(prob, 1-prob)
```

The ``p``-value is significantly larger than ``5\%``. Therefore, we cannot reject the zero hypothesis, which is fortunate because the data were generated from the normal distribution with zero mean.

```@raw html
</p></details>
```









Even though the computation of the ``p``-value is simple, we can use the [HypothesisTests](https://juliastats.org/HypothesisTests.jl/stable/) package. When we run the test, it gives us the same results as we computed.

```@example glm
using HypothesisTests

OneSampleTTest(xs)
```







## Theory of generalized linear models

The statistical approach to linear regression is different from the one from machine learning. It also assumes a linear prediction function:

```math
\operatorname{predict}(w;x) = w^\top x.
```

Then it considers some invertible link function ``g:\mathbb R\to \mathbb R`` and assumes that ``y`` conditioned on ``x`` follows an apriori specified distribution with density ``f``. The parameters of this distribution are unknown, but the distribution should satisfy the conditional expectation ``E(y\mid x) = g^{-1}(w^\top x)``. The goal is to find the weights ``w`` by the [maximum likelihood estimate](https://en.wikipedia.org/wiki/Maximum_likelihood_estimation). This technique maximizes the likelihood function:

```math
\operatorname{maximize}\qquad \prod_{i=1}^n f(y_i).
```

Since the density is the derivative of the distribution function, the term ``f(y_i)`` describes the "probability" of ``y_i`` under density ``f``. If ``y_i`` are independent, then the product is the joint probability for all samples. Therefore, maximizing the likelihood function amounts to finding the parameters of the apriori specified distribution such that the observed samples ``y_i`` have the highest probability. Since these distributions are usually taken from the [exponential family](https://en.wikipedia.org/wiki/Exponential_family), the log-likelihood

```math
\operatorname{maximize}\qquad \sum_{i=1}^n \log f(y_i).
```

is often maximized. Since the logarithm is an increasing function, these two formulas are equivalent.






#### Case 1: Linear regression

The first case considers ``g(z)=z`` to be the identity function and ``y\mid x`` with the [normal distribution](https://en.wikipedia.org/wiki/Normal_distribution) ``N(\mu_i, \sigma^2)``. Then

```math
w^\top x_i = g^{-1}(w^\top x_i) = \mathbb E(y_i \mid x_i) = \mu_i,
```

and, therefore, we need the solve the following optimization problem:

```math
\operatorname{maximize}_w\qquad \sum_{i=1}^n \log \left(\frac{1}{\sqrt{2\pi\sigma^2}}\exp\left(\frac{-(y_i - w^\top x_i)^2}{2\sigma^2}\right)\right).
```

Since we maximize with respect to ``w``, most terms behave like constants, and this optimization problem is equivalent to


```math
\operatorname{minimize}_w\qquad \sum_{i=1}^n (y_i - w^\top x_i)^2.
```

This is precisely linear regression as derived in the previous lectures.



#### Case 2: Logistic regression

The second case considers ``g(z)=\log z`` to be the logarithm function and ``y\mid x`` with the [Poisson distribution](https://en.wikipedia.org/wiki/Poisson_distribution) ``Po(\lambda)``. The inverse function to ``g`` is ``g^{-1}(z)=e^z``. Since the Poisson distribution has non-negative discrete values with probabilities ``\mathbb P(Y=k) = \frac{1}{k!}\lambda^ke^{-\lambda}``, labels ``y_i`` must also be non-negative integers. The same formula for the conditional expectation as before yields:

```math
e^{w^\top x_i} = g^{-1}(w^\top x_i) = \mathbb E(y_i \mid x_i) = \lambda_i.
```

Plugging this term into the log-likelihood function results in the following optimization problem:

```math
\operatorname{maximize}_w\qquad \sum_{i=1}^n\log\left( \frac{1}{y_i!}\lambda_i^{y_i} e^{-\lambda_i}\right).
```

By using the formula for ``\lambda_i`` and getting rid of constants, we transform this problem into

```math
\operatorname{minimize}_w\qquad  \sum_{i=1}^n \left(e^{w^\top x_i} - y_iw^\top x_i\right).
```

This function is similar to the one derived for logistic regression.


## Linear models

We will use the [Employment and Wages in Spain](https://vincentarelbundock.github.io/Rdatasets/doc/plm/Snmesp.html) dataset because it is slightly larger than the iris dataset. It contains 5904 observations of wages from 738 companies in Spain from 1983 to 1990. We will estimate the dependence of wages on other factors such as employment or cash flow. We first load the dataset and transform the original log-wages into non-normalized wages. We use base ``2`` to obtain relatively small numbers.

```@example glm
using RDatasets

wages = dataset("plm", "Snmesp")
wages.W = 2. .^ (wages.W)

nothing # hide
```

We can use the already known procedure to compute the best fit. 

```@example glm
X = Matrix(wages[:, [:N, :Y, :I, :K, :F]])
X = hcat(ones(size(X,1)), X)
y = wages[:, :W]

w0 = (X'*X) \ (X'*y)

nothing # hide
```

Another possibility is to use the package [GLM](https://juliastats.org/GLM.jl/stable/) and its command `lm` for linear models. 

```@example glm
using GLM

model = lm(@formula(W ~ 1 + N + Y + I + K + F), wages)
```

The table shows the parameter values and their confidence intervals. Besides that, it also tests the null hypothesis ``H_0: w_j = 0`` whether some of the regression coefficients can be omitted. The ``t`` statistics is in column `t`, while its ``p``-value in column `Pr(>|t|)`. The next exercise checks whether we can achieve the same results with fewer features.







```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise:</header>
<div class="admonition-body"><p>
```
Check that the solution computed by hand and by `lm` are the same.

Then remove the feature with the highest ``p``-value and observe whether there was any performance drop. The performance is usually evaluated by the [coeffient of determination](https://en.wikipedia.org/wiki/Coefficient_of_determination) denoted by ``R^2\in[0,1]``. Its higher values indicate a better model.

**Hint**: Use functions `coef` and `r2`.
```@raw html
</p></div></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Since the parameters for both approaches are almost the same, the approaches give the same result. 

```@example glm
norm(coef(model) - w0)
```

The table before this exercise shows that the ``p``-value for feature ``K`` is ``3.3\%``. We define the reduced model without this feature.

```@example glm
model_red = lm(@formula(W ~ 1 + N + Y + I + F), wages)
```

Now we show the performances of both models.

```@example glm
(r2(model), r2(model_red))
```

Since we observe only a small performance drop, we could omit this feature without changing the model prediction capability.

```@raw html
</p></details>
```








The core assumption of this approach is that ``y`` follows the normal distribution. We use the `predict` function for predictions and then use the `plot_histogram` function written earlier to plot the histogram and a density of the normal distribution. For the normal distribution, we need to specify the correct mean and variance.

```@example glm
y_hat = predict(model)

plot_histogram(y_hat, x -> pdf(Normal(mean(y_hat), std(y_hat)), x))
```

Another possibility would be the `fit` function from the `Distributions` package.

```@example glm
plot_histogram(y_hat, x -> pdf(fit(Normal, y_hat), x))
```

The results look identical. The distribution resembles the normal distribution, but there are some differences. We can use the more formal [Kolmogorov-Smirnov](https://en.wikipedia.org/wiki/Kolmogorov%E2%80%93Smirnov_test), which verifies whether a sample comes from some distribution.

```@example glm
test_normality = ExactOneSampleKSTest(y_hat, Normal(mean(y_hat), std(y_hat)))
```

The result is expected. The ``p``-value is close to ``1\%``, which means that we reject the null hypothesis that the data follow the normal distribution even though it is not entirely far away.



## Generalized linear models

While the linear models do not transform the labels, the generalized models transform them by the link function. Moreover, they allow choosing other than the normal distribution for labels. Therefore, we need to specify the link function ``g`` and the distribution of ``y \mid x``.

We repeat the same example with the link function ``g(z) = \sqrt{z}`` and the [inverse Gaussian](https://en.wikipedia.org/wiki/Inverse_Gaussian_distribution) distribution for the labels. Since we want to use the generalized linear model, we replace `lm` by `glm`.

```@example glm
model = glm(@formula(W ~ 1 + N + Y + I + K + F), wages, InverseGaussian(), SqrtLink())
```








The following exercise plots the predictions for the generalized linear model.

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise:</header>
<div class="admonition-body"><p>
```
Create the scatter plot of predictions and labels. Do not use the `predict` function.
```@raw html
</p></div></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Due to the construction of the generalized linear model, the prediction equals ``g^{-1}(w^\top x)``. We save it into ``\hat y``.

```@example glm
g_inv(z) = z^2

y_hat = g_inv.(X*coef(model))

nothing # hide
```

The scatter plot is now simple.

```@example glm
scatter(y, y_hat;
    label="",
    xlabel="Label",
    ylabel="Prediction",
)

savefig("glm_predict.svg")
```


```@raw html
</p></details>
```

![](glm_predict.svg)
