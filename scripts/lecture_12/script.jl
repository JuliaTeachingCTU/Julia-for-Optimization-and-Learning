using DifferentialEquations
using LinearAlgebra
using Plots

struct Wave
    f
    g
    c
end

# Exercise



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













# DiferentialEquations

f(u,p,t) = 0.98*u

u0 = 1.0
tspan = (0.0, 1.0)

prob = ODEProblem(f, u0, tspan)

sol = solve(prob)

plot(sol; label="")

sol(0.8)

# Exercise



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



# Exercise



# Plotting trajectory

ts = 0:0.0001:10

xs1 = trajectory_fin_diff(ps, x0, ts, q)
xs2 = trajectory_exact(ps, x0, ts, q)

plot(xs1[1,:], xs1[2,:], label="Finite differences")
plot!(xs2[1,:], xs2[2,:], label="True value")

# Exercise



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




