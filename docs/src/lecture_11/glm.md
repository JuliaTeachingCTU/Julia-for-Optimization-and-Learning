```@setup glm
function plot_histogram(xs, f; kwargs...)
    plt = histogram(xs;
        label="Sampled density",
        nbins=100,
        normalize = :pdf,
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

This section revisits the linear regression. The classical statistical approach uses a different approach, but derives the same formulation for linear regression. Besides point estimates for parameters, this approach also computes their confidence intervals and is able to test whether some parameters can be omitted from the model. We will start with hypothesis testing and then continue with regression.

Julia provides lots of statistical packages. They are summarized at the [JuliaStats](https://juliastats.org/) webpage. This section will give a brief introduction to many of them.




## Theory of hypothesis testing

Hypothesis testing verifies whether data satisfy a given null hypothesis ``H_0``. Under some assumptions and the validity of the null hypothesis, the test derives that a transformation of the data follows some distribution. Then it constructs a confidence interval of this distribution and checks whether the trasnformed variable lies into the confidence interval. If it lies ourside of it, the test rejects the null hypothesis. In the opposite case, it fails to reject the null hypothesis. The latter is different from confirming the null hypothesis. Hypothesis is like a grumpy professor who tells whether a student knows his lecture. He never acknowledges that the student knows it sufficiently, but he is often clear that the student does not know it.

An example is the one-sided [Student's t-test](https://en.wikipedia.org/wiki/Student's_t-test) that verifies that a dataset has mean ``\mu``. It can be generalized to compare the mean (performance) of two datasets. Under some assumption, it derives that

```math
t = \sqrt{n}\frac{\overline X - \mu}{\hat\sigma}
```

follows the [Student's distribution](https://en.wikipedia.org/wiki/Student%27s_t-distribution) with ``n-1`` degress of freedom. Here, the dataset ``X`` has size ``n``, its mean is ``\overline X`` and its standard deviation ``\hat \sigma``. Instead of computing the confidence interval, the usual way is to define the ``p``-value

```math
p = 2\min\{\mathbb P(T\le t), \mathbb P(T\ge t)\}
```

If the ``p``-value is smaller than a given threshold, usually ``5\%``, the null hypothesis is rejected. In the opposite case, it is not rejected. The ``p``-value is a measure of the probability that an observed difference could have occurred just by random chance.




## Hypothesis testing



We first randomly generate data with from the normal distribution with zero mean.

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

The following exercise checks performs the ``t``-test to check whether it comes from a distribution with zero mean.





```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Use the ``t``-test to verify whether the samples were generated from a distribution with zero mean.

**Hint**: the Student's distribution is invoked by `TDist()`.

**Hint**: the probability ``\mathbb P(T\le t)`` equals to the [distribution function](https://en.wikipedia.org/wiki/Cumulative_distribution_function) ``F(t)``, which can be called by `cdf`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

We compute the statistic ``t``, then define the Student's distribution with ``n-1`` degrees of freedom, evaluate the distribution function at ``t`` and finally compute the ``p``-value.

```@example glm
using Distributions

t = mean(xs) / std(xs) * sqrt(n)

prob = cdf(TDist(n-1), t)
p = 2*min(prob, 1-prob)

nothing # hide
```

```@raw html
</p></details>
```









Even though the computation of the ``p``-value is simple, we can use the [HypothesisTests](https://juliastats.org/HypothesisTests.jl/stable/) package. When we run the test, it gives us the same results as we computed.

```@example glm
using HypothesisTests

OneSampleTTest(xs)
```







## Theory of generalized linear models

The statistical approach to linear regression is different from the one from machine learning. It also assumes linear prediction function

```math
\operatorname{predict}(w;x) = w^\top x.
```

Then it considers some invertible link function ``g:\mathbb R\to \mathbb R`` and assumes that ``y`` conditioned on ``x`` follows an apriori specified distribution with density ``f``. The parameters of this distribution are uknown, but the distribution should satisfy the conditional expectation ``E(y\mid x) = g^{-1}(w^\top x)``. The goal is to find the weights ``w`` by the [maximum likelihood estimate](https://en.wikipedia.org/wiki/Maximum_likelihood_estimation). This technique maximizes the likelihood function

```math
\operatorname{maximize}\qquad \prod_{i=1}^n f(y_i).
```

Since the density is the derivative of the distribution function, the term ``f(y_i)`` describes the "probability" of ``y_i`` under density ``f``. If ``y_i`` are independent, then the product is the joint probability for all samples. Therefore, maximizing the the likelihood function amounts to finding the parameters of the apriori specified distribution such that the observed samples ``y_i`` have the highest probability to follow this distriubtion. Since these distributions are usually taken from the [exponential family](https://en.wikipedia.org/wiki/Exponential_family), the log-likelihood

```math
\operatorname{maximize}\qquad \sum_{i=1}^n \log f(y_i).
```

is often maximized. Since logarithm is an increasing function, these two approaches are equivalent.






#### Case 1: Linear regression

The first case considers ``g(z)=z`` to be the identity function and ``y\mid x`` with the [normal distribution](https://en.wikipedia.org/wiki/Normal_distribution) ``N(\mu_i, \sigma^2)``. Then

```math
w^\top x_i = g^{-1}(w^\top x_i) = \mathbb E(y_i \mid x_i) = \mu_i,
```

and, therefore, we need the solve the following optimization problem.

```math
\operatorname{maximize}_w\qquad \sum_{i=1}^n \log \left(\frac{1}{\sqrt{2\pi\sigma^2}}\exp\left(\frac{-(y_i - w^\top x_i)^2}{2\sigma^2}\right)\right).
```

Since we maximize with respect to ``w``, most terms behave like constants and this optimization problem is equivalent to


```math
\operatorname{minimize}\qquad \sum_{i=1}^n (y_i - w^\top x_i)^2.
```

This is precisely the linear regression as derived in the previous lectures.



#### Case 2: Logistic regression

The second case considers ``g(z)=\log z`` to be the logarithm function and ``y\mid x`` with the [Poisson distribution](https://en.wikipedia.org/wiki/Poisson_distribution) ``Po(\lambda)``. The inverse function to ``g`` is ``g^{-1}(z)=e^z``. Since the Poisson distribution has non-negative discrete values with probabilities ``\mathbb P(Y=k) = \frac{1}{k!}\lambda^ke^{-\lambda}``, labels ``y_i`` must also be non-negative integers. The same formula for the conditional expectation as before yields:

```math
e^{w^\top x_i} = g^{-1}(w^\top x_i) = \mathbb E(y_i \mid x_i) = \lambda_i,
```

Plugging this term into the maximizing the log-likelihood function, results in the following optimization problem:

```math
\operatorname{maximize}_w\qquad \sum_{i=1}^n\log\left( \frac{1}{y_i!}\lambda_i^{y_i} e^{-\lambda_i}\right).
```

By using the formula for ``\lambda_i`` and getting rid of constants, we transform this problem into

```math
\operatorname{minimize}_w\qquad  \sum_{i=1}^n \left(e^{w^\top x_i} - y_iw^\top x_i\right).
```

This function is similar to the one derived for logistic regression.


## Linear models

We will use the [Employment and Wages in Spain](https://vincentarelbundock.github.io/Rdatasets/doc/plm/Snmesp.html) dataset because it is slightly larger that iris. It contains 5904 observations of wages from 738 companies in Spain during 1983 to 1990. We will estimate the dependance of wages on other factors such as employment or cash flow. We first load the dataset and transform the original log-wages into normal wages. We use base ``2`` to obtain relatively small numbers.

```@example glm
using RDatasets

wages = dataset("plm", "Snmesp")
wages.W = 2. .^ (wages.W)

nothing # hide
```

We can use the already known precedure to compute the best fit. 

```@example glm
X = Matrix(wages[:, [:N, :Y, :I, :K, :F]])
X = hcat(ones(size(X,1)), X)
y = wages[:, :W]

w0 = (X'*X) \ (X'*y)

nothing # hide
```

Another possibility is to use the packege [GLM](https://juliastats.org/GLM.jl/stable/) and its command `lm` for linear models. 

```@example glm
using GLM

model = lm(@formula(W ~ 1 + N + Y + I + K + F), wages)
```

The table shows the value of the parameters and their confidence intervals. Besides that, it also tests the null hypothesis ``H_0: w_j = 0`` whether some of the regression coefficient can be omitted. The ``t`` statistics is in column `t`, while its ``p``-value in column `Pr(>|t|)`. The next exercise checks whether we can achieve the same results with fewer features.







```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Check that the results by computing the solution by hand and by `lm` are the same.

Then remove the feature with the highest ``p``-value and observe whether there was any performance drop. The performance is usually evaluated by the [coeffient of determination](https://en.wikipedia.org/wiki/Coefficient_of_determination) denote by ``R^2\in[0,1]``. Its higher values indicate better model.

**Hint**: Use functions `coef` and `r2`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Since the parameters for both approaches are almost the same, the approaches give the same result. 

```@example glm
norm(coef(model) - w0)
```

The ``p``-value for column ``K`` is ``3.3\%``. We define the reduced model without this feature.

```@example glm
model_red = lm(@formula(W ~ 1 + N + Y + I + F), wages)
```

Since we observe only a small performance drop, we could omit this feature without a change to prediction capability of the model.

```@example glm
r2(model) - r2(model_red)
```

```@raw html
</p></details>
```








The core assumption of this approach is that ``y`` has normal distribution. We use the `predict` function to predict the data and then use the `plot_histogram` function written earlier to plot the histogram and a density of the normal distribution. For the normal distribution, we need to specify the correct mean and variance.

```@example glm
y_hat = predict(model)

plot_histogram(y_hat, x -> pdf(Normal(mean(y_hat), std(y_hat)), x))
```

The distribution resembles the normal distribution, but there are some differences. We can use the more formal [Kolmogorov-Smirnov](https://en.wikipedia.org/wiki/Kolmogorov%E2%80%93Smirnov_test) test to verify whether a sample comes from a distribution.

```@example glm
test_normality = ExactOneSampleKSTest(y_hat, Normal(mean(y_hat), std(y_hat)))
```

The result is expected. The ``p``-value is close to ``1\%``, which means that we would reject the hypothesis that the data come from the normal distribution even though it is not entirely far away.



## Generalized linear models


For the generalized linear models, we need to specify the link function ``g`` and the distribution of ``y \mid x``. For the former we choose ``g(z) = \sqrt{z}`` and for the latter the [inverse Gaussian](https://en.wikipedia.org/wiki/Inverse_Gaussian_distribution) distribution. Since we want to use the generalized linear model, we replace `lm` by `glm`.

```@example glm
model = glm(@formula(W ~ 1 + N + Y + I + K + F), wages, InverseGaussian(), SqrtLink())
```








The next exercise plots the prediction for the linear model.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Create the scatter plot of predictions and labels. You are not allowed to use the `predict` function.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Due to construction of generalized linear models, the prediction equals ``g^{-1}(w^\top x)``. We save it into ``\hat y``.

```@example glm
g_inv(z) = z^2

y_hat = g_inv.(X*coef(model))

nothing # hide
```

The scatter plot is now simple.

```@example glm
scatter(y, predict(model);
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

