using Plots

function juliaset(z, c; max_abs = 50, max_iter = 1000)
    for iter in 1:max_iter
        z = z^2 + c
        if abs(z) > max_abs
            return iter / max_iter
        end
    end
    return 0
end

n = 500
x = range(-1.5, stop = 1.5, length = 500)
y = range(-1.0, stop = 1.0, length = 500)
cs = 0.7885 .* exp.(range(π/2; stop = 3π/2, length = n) .* im)


@time anim = @animate for i in 1:length(cs)
    @info "$(i)/$(length(cs))"
    heatmap(
        x,
        y,
        (x, y) -> juliaset(x + y*im, cs[i]);
        c = :viridis,
        clims = (0,0.075),
        cbar = :none,
        framestyle = :none,
        ticks = :none,
    )
end
gif(anim, "julia_set.gif", fps = 20)


using Plots
f(x, y) = @. exp(-((x-4)^2+(y-4)^2)^2/1000) + exp(-((x +4)^2+(y+4)^2)^2/1000) + 0.1exp(-((x +4)^2+(y+4)^2)^2)+0.1exp(-((x -4)^2+(y-4)^2)^2)

x = range(-10, stop = 10, length = 1000)
y = range(-10, stop = 10, length = 1000)

surface(x, y, f)
