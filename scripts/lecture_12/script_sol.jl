using DifferentialEquations
using LinearAlgebra
using Plots

struct Wave
    f
    g
    c
end

# Exercise

function solve_wave(T, L, wave::Wave; n_t=100, n_x=100)
    ts = range(0, T; length=n_t)
    xs = range(0, L; length=n_x)
    Δt = ts[2] - ts[1]
    Δx = xs[2] - xs[1]
    y = zeros(n_t, n_x)
    
    y[:,1] .= wave.f(0)
    y[:,end] .= wave.f(L)

    y[1,2:end-1] = wave.f.(xs[2:end-1])
    y[2,2:end-1] = y[1,2:end-1] + Δt*wave.g.(xs[2:end-1])

    for t in 2:n_t-1, x in 2:n_x-1
        ∂y_xx = (y[t, x+1] - 2*y[t, x] + y[t, x-1])/Δx^2
        y[t+1, x] = c^2 * Δt^2 * ∂y_xx  + 2*y[t, x] - y[t-1, x]
    end

    return y
end

# Visualization

function plot_wave(y, file_name; fps = 60, kwargs...)
    anim = @animate for (i, y_row) in enumerate(eachrow(y))
        plot(
            y_row;
            title = "t = $(i-1)Δt",
            xlabel = "x",
            ylabel = "y(t, x)",
            legend = false,
            linewidth = 2,
            kwargs...
        )
    end
    gif(anim, file_name; fps, show_msg = false)
    
    return nothing
end

# Exercise

f(x,L) = 2*exp(-(x-L/2)^2) + x/L
g(x) = 0

L = 1.5*pi
T = 240
c = 0.02

wave = Wave(x -> f(x,L), g, c)

y1 = solve_wave(T, L, wave; n_t=241, n_x=101)
plot_wave(y1, "wave1.gif"; ylims=(-2,3), label="")

y2 = solve_wave(T, L, wave; n_t=241, n_x=7)
plot_wave(y2, "wave2.gif"; ylims=(-2,3), label="")














# DiferentialEquations

f(u,p,t) = 0.98*u

u0 = 1.0
tspan = (0.0, 1.0)

prob = ODEProblem(f, u0, tspan)

sol = solve(prob)

plot(sol; label="")

sol(0.8)

# Exercise

sol2 = solve(prob, dense=false)
sol3 = solve(prob, RK4())

ts = range(tspan...; length = 100)

plot(ts, t->exp(0.98*t), label="True solution", legend=:topleft)
plot!(ts, t->sol(t), label="Default")
plot!(ts, t->sol2(t), label="Linear")
plot!(ts, t->sol3(t), label="Runge-Kutta")

# Lorenz system

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

sol = solve(prob)

plot(sol)

plt1 = plot(sol, vars=(1,2,3), label="")

plot(sol, vars=(1,2,3), denseplot=false; label="")

traj = hcat(sol.u...)
plot(traj[1,:], traj[2,:], traj[3,:]; label="")

# Exercise

p0 = (nextfloat(p[1]), p[2:end]...) 

prob0 = ODEProblem(lorenz, u0, tspan, p0)
sol0 = solve(prob0)

plt0 = plot(sol0, vars=(1,2,3), label="")

plot(plt1, plt0; layout=(1,2))

# Solution comparison

hcat(sol(tspan[2]), sol0(tspan[2]))











# Bisection setup

function bisection(f, a, b; tol=1e-6)
    fa = f(a)
    fb = f(b)
    fa == 0 && return a
    fb == 0 && return b
    fa*fb > 0 && error("Wrong initial values for bisection")
    while b-a > tol
        c = (a+b)/2
        fc = f(c)
        fc == 0 && return c
        if fa*fc > 0
            a = c
            fa = fc
        else
            b = c
            fb = fc
        end
    end
    return (a+b)/2
end

# PMSM structure

struct PMSM{T<:Real}
    ρ::T
    ω::T
    A::Matrix{T}
    invA::Matrix{T}

    function PMSM(ρ, ω)
        A = -ρ*[1 0; 0 1] -ω*[0 -1; 1 0]
        return new{eltype(A)}(ρ, ω, A, inv(A))
    end
end

function expA(p::PMSM, t)
    ρ, ω = p.ρ, p.ω
    return exp(-ρ*t)*[cos(ω*t) sin(ω*t); -sin(ω*t) cos(ω*t)]
end

ρ = 0.1
ω = 2
x0 = [0;-0.5]
q = [1;0]

ps = PMSM(ρ, ω)

# Exercise

t = 5
exp0 = exp.(t*ps.A)
exp1 = exp(t*ps.A)
exp2 = expA(ps, t)

norm(exp1 - exp0) >= 1e-10 || error("Matrices are wrong")
norm(exp1 - exp2) <= 1e-10 || error("Matrices are wrong")

# Exercise

function trajectory_fin_diff(p::PMSM, x0, ts, q)
    xs = zeros(length(x0), length(ts))
    xs[:, 1] = x0

    for i in 1:length(ts)-1
        xs[:, i+1] = xs[:, i] + (ts[i+1]-ts[i])*(p.A * xs[:, i] + q)
    end
    return xs
end

function trajectory_exact(p::PMSM, x0, ts, q)
    xs = zeros(length(x0), length(ts))

    for (i, t) in enumerate(ts)
        xs[:, i] = expA(p, t)*(x0 + p.invA * (I - expA(p, -t))*q)
    end
    return xs
end

ts = 0:0.01:10

xs1 = trajectory_fin_diff(ps, x0, ts, q)
xs2 = trajectory_exact(ps, x0, ts, q)

plot(xs1[1,:], xs1[2,:], label="Finite differences")
plot!(xs2[1,:], xs2[2,:], label="True value")

# Plotting trajectory

ts = 0:0.0001:10

xs1 = trajectory_fin_diff(ps, x0, ts, q)
xs2 = trajectory_exact(ps, x0, ts, q)

plot(xs1[1,:], xs1[2,:], label="Finite differences")
plot!(xs2[1,:], xs2[2,:], label="True value")

# Exercise

U_max = 0.1
x_t = [0.25;-0.5]

f(t) = norm(expA(ps, -t)*x_t - x0 - ps.invA*(I-expA(ps, -t))*q) - U_max/ps.ρ*(exp(ps.ρ*t)-1)

τ = bisection(f, minimum(ts), maximum(ts))

# Plotting trajectory

function trajectory_control(p::PMSM, x0, ts, q, U_max, p0)
    xs = zeros(length(x0), length(ts))

    for (i, t) in enumerate(ts)
        eAt  = expA(p, t)
        emAt = expA(p, -t)
        xs[:, i] = eAt*(x0 + p.invA * (I - emAt)*q + U_max/ρ*(exp(ρ*t) - 1)*p0)
    end
    return xs
end

p0 = ps.ρ/(U_max*(exp(ps.ρ*τ)-1))*(expA(ps, -τ)*x_t - x0 - ps.invA*(I-expA(ps, -τ))*q)
p0 /= norm(p0)

ts = range(0, τ; length=100)

traj = trajectory_control(ps, x0, ts, q, U_max, p0)

plot(traj[1,:], traj[2,:], label="Optimal trajectory")
scatter!([x0[1]], [x0[2]], label="Starting point")
scatter!([x_t[1]], [x_t[2]], label="Target point")

# BONUS

ts = 0:0.01:10

plt = plot()
for α = 0:π/4:2*π
    trj = trajectory_control(ps, x0, ts, q, U_max, [sin(α); cos(α)])
    plot!(plt, trj[1,:], trj[2,:], label="")
end
display(plt)




