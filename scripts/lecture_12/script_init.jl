using Pkg
Pkg.activate(".")
Pkg.instantiate()

using DifferentialEquations
using LinearAlgebra
using Plots

f(u,p,t) = 0.98*u

u0 = 1.0
tspan = (0.0, 1.0)

prob = ODEProblem(f, u0, tspan)

sol = solve(prob)

plot(sol; label="")

sol(0.8)

function lorenz(u, p, t)
    σ, ρ, β = p
    x_t = σ*(u[2]-u[1])
    y_t = u[1]*(ρ-u[3]) - u[2]
    z_t = u[1]*u[2] - β*u[3]
    return [x_t; y_t; z_t]
end

u0 = [1.0; 0.0; 0.0]
p = [10; 28; 8/3] 

tspan = (0.0, 100.0)
prob = ODEProblem(lorenz, u0, tspan, p)