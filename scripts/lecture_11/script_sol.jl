using BenchmarkTools
using Distributions
using GLM
using HypothesisTests
using LinearAlgebra
using Plots
using Random
using RDatasets
using SpecialFunctions
using Statistics

plot(0:0.1:10, gamma;
    xlabel="x",
    ylabel="gamma(x): log scale",
    label="",
    yscale=:log10,
)

# Exercise

volume_true(m, R) = π^(m/2) *R^2 / gamma(m/2 + 1)

plot(1:100, m -> volume_true.(m, 1);
    xlabel="dimension",
    ylabel="unit ball volume: log scale",
    label="",
    yscale=:log10,
)

# Exercise

function volume_monte_carlo(m::Int; n::Int=10000)
    X = 2*rand(m, n).-1
    X_norm_sq = sum(X.^2; dims=1)
    return 2^m*mean(X_norm_sq .<= 1)
end

# Volume of a ball

ms = 1:15
ns = Int64.([1e1; 1e3; 1e5])

Random.seed!(666)

plt = plot(ms, m -> volume_true(m, 1);
    xlabel="dimension",
    ylabel="unit ball volume",
    legend=:topleft,
    label="True",
    line=(4,:black),
)

for n in ns
    plot!(plt, ms, m -> volume_monte_carlo.(m; n=n); label="n = $n")
end

display(plt)

# Generating from the uniform distributions

rand(Uniform(-1, 1), 10, 5)

# Sampling from distributions

d1 = Normal()
d2 = Normal(1, 1)
d3 = Normal(0, 0.01)

f1(x) = pdf(d1, x)
f2(x) = pdf(d2, x)
f3(x) = pdf(d3, x)

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

plot_histogram(rand(d1, 1000000), f1)

# Exercise

function rejection_sampling(f, f_max, x_min, x_max; n=1000000)
    xs = x_min .+ (x_max - x_min)*rand(n)
    ps = f_max*rand(n)
    return xs[f.(xs) .>= ps]
end

# Rejection sampling

xlims = (-10, 10)

for (f, d) in zip((f1, f2, f3), (d1, d2, d3))
    Random.seed!(666)
    xs = rejection_sampling(f, f(d.μ), xlims...)

    pl = plot_histogram(xs, f)
    display(pl)
end

# Exercise

n = 1000
m = 9

Random.seed!(666)
xs = rand(m, n)

dist1 = [norm(x-y) for x in eachcol(xs), y in eachcol(xs)]
dist2 = [dist1[i,j] for i in 1:n for j in i+1:n]

extrema(dist2)









# Hypothesis testing

Random.seed!(666)

n = 1000
xs = randn(n)

# Exercise

t = mean(xs) / std(xs) * sqrt(n)

prob = cdf(TDist(n-1), t)
p = 2*min(prob, 1-prob)

# One-sample t-test

OneSampleTTest(xs)

# Linear models

wages = dataset("plm", "Snmesp")
wages.W = 2. .^ (wages.W)


X = Matrix(wages[:, [:N, :Y, :I, :K, :F]])
X = hcat(ones(size(X,1)), X)
y = wages[:, :W]

w0 = (X'*X) \ (X'*y)

model = lm(@formula(W ~ 1 + N + Y + I + K + F), wages)

# Exercise

norm(coef(model) - w0)

model_red = lm(@formula(W ~ 1 + N + Y + I + F), wages)

(r2(model), r2(model_red))

# Plot histograms

y_hat = predict(model)

plot_histogram(y_hat, x -> pdf(Normal(mean(y_hat), std(y_hat)), x))

plot_histogram(y_hat, x -> pdf(fit(Normal, y_hat), x))

test_normality = ExactOneSampleKSTest(y_hat, Normal(mean(y_hat), std(y_hat)))

# Generalized linear models

model = glm(@formula(W ~ 1 + N + Y + I + K + F), wages, InverseGaussian(), SqrtLink())

# Exercise

g_inv(z) = z^2

y_hat = g_inv.(X*coef(model))

scatter(y, y_hat;
    label="",
    xlabel="Label",
    ylabel="Prediction",
)










# Ridge regression

n = 10000
m = 1000

Random.seed!(666)
X = randn(n, m)

y = 10*X[:,1] + X[:,2] + randn(n)

# Exercise

ridge_reg(X, y, μ) = (X'*X + μ*I) \ (X'*y)

eigen_dec = eigen(X'*X)
Q = eigen_dec.vectors
Q_inv = Matrix(Q')
λ = eigen_dec.values

ridge_reg(X, y, μ, Q, Q_inv, λ) = Q * ((Diagonal(1 ./ (λ .+ μ)) * ( Q_inv * (X'*y))))

w1 = ridge_reg(X, y, 10)
w2 = ridge_reg(X, y, 10, Q, Q_inv, λ)

norm(w1 - w2)

# Comparison

@btime ridge_reg(X, y, 10);

@btime ridge_reg(X, y, 10, Q, Q_inv, λ);

# Dependence on mu

μs = range(0, 1000; length=50)

ws = hcat(ridge_reg.(Ref(X), Ref(y), μs, Ref(Q), Ref(Q_inv), Ref(λ))...)

plot(μs, abs.(ws');
    label="",
    yscale=:log10,
    xlabel="mu",
    ylabel="weights: log scale",
)

# LASSO

S(x, η) = max(x-η, 0) - max(-x-η, 0)

function lasso(X, y, μ, Q, Q_inv, λ;        
        max_iter = 100,
        ρ = 1e3,
        w = zeros(size(X,2)),
        u = zeros(size(X,2)),
        z = zeros(size(X,2)),
    )
    
    for i in 1:max_iter
        w = Q * ( (Diagonal(1 ./ (λ .+ ρ)) * ( Q_inv * (X'*y + ρ*(z-u))))) 
        z = S.(w + u, μ / ρ)
        u = u + w - z
    end
    return w, u, z  
end

ws = zeros(size(X,2), length(μs))

for (i, μ) in enumerate(μs)
    global w, u, z
    w, u, z = i > 1 ? lasso(X, y, μ, Q, Q_inv, λ; w, u, z) : lasso(X, y, μ, Q, Q_inv, λ)
    ws[:,i] = w
end

plot(μs, abs.(ws');
    label="",
    yscale=:log10,
    xlabel="mu",
    ylabel="weights: log scale",
)
