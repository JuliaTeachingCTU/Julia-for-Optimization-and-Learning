using Plots

f(x) = (1+0.5*x)*sin(x)

xs = range(3, 12, length=1000)
fs = f.(xs)
i_min = findall((fs[2:end-1] .< fs[1:end-2]) .& (fs[2:end-1] .< fs[3:end])) .- 1
i_max = findall((fs[2:end-1] .> fs[1:end-2]) .& (fs[2:end-1] .> fs[3:end])) .- 1

plot(xs, fs, label="", ticks=false)
scatter!(xs[i_min], fs[i_min], label="Local minimum")
scatter!(xs[i_max], fs[i_max], label="Local maximum")

file_name = joinpath("src", "lecture_07", "minmax.svg")
savefig(file_name)
