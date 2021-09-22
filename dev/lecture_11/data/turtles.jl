using Images, ImageMagick, ImageFiltering
using Plots

file_name_in = joinpath("data", "turtle.jpg")
file_name_out = joinpath("data", "turtles.png")

img = load(file_name_in)

K1 = Float64.([1 1 1; 1 1 1; 1 1 1] ./ 9)
img1 = imfilter(img, K1)

K2 = Float64.([-1 -1 -1; -1 8 -1; -1 -1 -1])
img2 = imfilter(img, K2)

function fix_bounds!(img)
    for i in 1:size(img,1)
        for j in 1:size(img,2)
            a1 = min(max(img[i,j].r, 0), 1)
            a2 = min(max(img[i,j].g, 0), 1)
            a3 = min(max(img[i,j].b, 0), 1)
            img[i,j] = RGB(a1,a2,a3)
        end
    end
end

fix_bounds!(img1)
save("turtle1.jpg", img1)

fix_bounds!(img2)
save("turtle2.jpg", img2)

p = plot(
    axis = nothing,
    layout = @layout([a b c]),
    size=1.5.*(700,300)
)

plot!(p[1], img, ratio=1)
plot!(p[2], img1, ratio=1)
plot!(p[3], img2, ratio=1)

savefig(p, file_name_out)
