###########################################
# Unconstrained optimization
###########################################

f(x) = sin(x[1] + x[2]) + cos(x[1])^2
g(x) = [cos(x[1] + x[2]) - 2*cos(x[1])*sin(x[1]); cos(x[1] + x[2])]

f(x1,x2) = f([x1;x2])

f([0; 0])
f(0, 0)

#### Exercise

using Plots

xs = range(-3, 1, length = 40)
ys = range(-2, 1, length = 40)

contourf(xs, ys, f, color = :jet)

#### Exercise

finite_difference(f, x::Real; h=1e-8) = (f(x+h) - f(x)) / h

#### Exercise

x = [-2; -1]
fin_diff(h) = finite_difference(y -> f(x[1], y), x[2]; h=h)

true_grad = g(x)[2]

hs = 10. .^ (-15:0.01:-1)

plot(hs, fin_diff,
    xlabel = "h",
    ylabel = "Partial gradient wrt y",
    label = ["Approximation" "True gradient"],
    xscale = :log10,
)

hline!([true_grad]; label =  "True gradient")

#### Numerical errors

x = 1
h = 1e-13

(x+h)^2 - x^2
2*x*h + h^2

#### Exercise

x = [-2; -1]
α = 0.25
x_grad = [x x.+α.*g(x)]

contourf(xs, ys, f; color = :jet)
plot!(x_grad[1, :], x_grad[2, :];
    line = (:arrow, 4, :black),
    label = "",
)

#### Exercise

function optim(f, g, x, α; max_iter=100)
    xs = zeros(length(x), max_iter+1)
    xs[:,1] = x
    for i in 1:max_iter
        x -= α*g(x)
        xs[:,i+1] = x
    end
    return xs
end

#### Animation

using Random

function create_anim(
    f,
    path,
    xlims,
    ylims,
    file_name = joinpath(pwd(), randstring(12) * ".gif");
    xbounds = xlims,
    ybounds = ylims,
    fps = 15,
)
    xs = range(xlims...; length = 100)
    ys = range(ylims...; length = 100)
    plt = contourf(xs, ys, f; color = :jet)

    # add constraints if provided
    if !(xbounds == xlims && ybounds == ylims)
        x_rect = [xbounds[1]; xbounds[2]; xbounds[2]; xbounds[1]; xbounds[1]]
        y_rect = [ybounds[1]; ybounds[1]; ybounds[2]; ybounds[2]; ybounds[1]]
        
        plot!(x_rect, y_rect; line = (2, :dash, :red), label="")
    end

    # add an empty plot
    plot!(Float64[], Float64[]; line = (4, :arrow, :black), label = "")

    # extract the last plot series
    plt_path = plt.series_list[end]

    # create the animation and save it
    anim = Animation()
    for x in eachcol(path)
        push!(plt_path, x[1], x[2]) # add a new point
        frame(anim)
    end
    gif(anim, file_name; fps = fps, show_msg = false)
    return nothing
end

#### Exercise

x_gd = optim([], g, [0; -1], 0.1)

xlims = (-3, 1)
ylims = (-2, 1)
create_anim(f, x_gd, xlims, ylims, "anim1.gif")

f_gd = [f(x) for x in eachcol(x_gd)]

plot(f_gd, label="", xlabel="Iteration", ylabel="Function value")

#### Different stepsizes

x_gd = optim([], g, [0; -1], 0.01)

create_anim(f, x_gd, xlims, ylims, "anim2.gif")

x_gd = optim([], g, [0; -1], 1)

create_anim(f, x_gd, xlims, ylims, "anim3.gif")

#### Stepsize selection

abstract type Step end

struct GD <: Step
    α::Float64
end

#### Gradient descent

optim_step(s::GD, f, g, x) = -s.α*g(x)

function optim(f, g, x, s::Step; max_iter=100)
    xs = zeros(length(x), max_iter+1)
    xs[:,1] = x
    for i in 1:max_iter
        x += optim_step(s, f, g, x)
        xs[:,i+1] = x
    end
    return xs
end

gd = GD(0.1)
x_opt = optim(f, g, [0;-1], gd)

create_anim(f, x_opt, xlims, ylims, "anim4.gif")

#### Exercise

struct Armijo <: Step
    c::Float64
    α_max::Float64
end

function optim_step(s::Armijo, f, g, x)
    fun = f(x)
    grad = g(x)
    α = s.α_max
    while f(x .- α*grad) > fun - s.c*α*(grad'*grad)
        α /= 2
        if α <= 1e-6
            warning("Armijo line search failed.")
            break
        end
    end
    return -α*grad
end

gd = Armijo(1e-4, 1)
x_opt = optim(f, g, [0;-1], gd)

create_anim(f, x_opt, xlims, ylims, "anim5.gif")

###########################################
# Constrained optimization
###########################################

f(x) = sin(x[1] + x[2]) + cos(x[1])^2
g(x) = [cos(x[1] + x[2]) - 2*cos(x[1])*sin(x[1]); cos(x[1] + x[2])]

f(x1,x2) = f([x1;x2])

#### Projected gradients

function optim(f, g, P, x, α; max_iter=100)
    xs = zeros(length(x), max_iter+1)
    ys = zeros(length(x), max_iter)
    xs[:,1] = x
    for i in 1:max_iter
        ys[:,i] = xs[:,i] - α*g(xs[:,i])
        xs[:,i+1] = P(ys[:,i])
    end
    return xs, ys
end

P(x, x_min, x_max) = min.(max.(x, x_min), x_max)

x_min = [-1; -1]
x_max = [0; 0]

xs, ys = optim(f, g, x -> P(x,x_min,x_max), [0;-1], 0.1)

#### Plot 1

xlims = (-3, 1)
ylims = (-2, 1)

create_anim(f, xs, xlims, ylims, "anim6.gif";
    xbounds=(x_min[1], x_max[1]),
    ybounds=(x_min[2], x_max[2]),
)

#### Plot 2

xys = hcat(reshape([xs[:,1:end-1]; ys][:], 2, :), xs[:,end])

create_anim(f, xys, xlims, ylims, "anim7.gif";
    xbounds=(x_min[1], x_max[1]),
    ybounds=(x_min[2], x_max[2]),
)


