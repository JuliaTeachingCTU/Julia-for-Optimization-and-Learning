
# [Unit testing](@id unit-testing)

The previous section added the `image` function with multiple methods. We also manually tested if these methods work correctly. Even though this practice works for small projects, it is not optimal for code testing and should be automized by [unit testing](https://en.wikipedia.org/wiki/Unit_testing). The `Test` package from the standard library provides utility functions to simplify writing unit tests. Its core is the `@test` macro that tests if an expression evaluates as `true`.

```@repl tests
using Test

@test 1 == 1
@test 1 == 3
```

It is possible to pass additional arguments to the `@test` macro.

```@repl tests
@test π ≈ 3.14 atol=0.01
```

If we go back to our package, we can start writing tests for the methods of the `image` function. All tests should be located in the ` /test` folder with its own environment. First, we have to import all necessary packages: `Test`, `ImageInspector` and `Colors`. Since we used `PkgTemplates` to generate the package, the `test` folder and the environment are both already generated. Moreover, the environment already contains the `Test` package. We do not have to add the `ImageInspector` package because it is added automatically. For simplicity, we use the environment from the `examples` folder.

```julia
# /test/runtests.jl
using ImageInspector
using Test
using ImageInspector.Colors
```

We import `Colors` from the `ImageInspector` to use the same version. Now we define inputs and expected outputs for the `image` function.

```julia
# /test/runtests.jl
x = [0.1 0.2; 0.3 0.4];
img = Gray.(x);
img_flipped = Gray.(x');
```

Since the input to the `image` function is a matrix, we test the first method of the `image` function that creates grayscale images.

```julia
julia> @test image(x) == img_flipped
Test Passed

julia> @test image(x; flip = false) == img
Test Passed

julia> @test image(x; flip = true) == img_flipped
Test Passed
```

Since all tests passed correctly, the message `Test Passed` is printed after each test. It is a good idea to group tests logically by the `@testset` macro.

```julia
# /test/runtests.jl
julia> @testset "image function" begin
           @test image(x) == img_flipped
           @test image(x; flip = false) == img
           @test image(x; flip = true) == img_flipped
       end
Test Summary:  | Pass  Total
image function |    3      3
```

We use the `begin ... end` block to specify which tests should be grouped. Moreover, it is possible to combine the `@testset` macro and the `for` loop to perform multiple tests at once. For example, we may want to test the `image` function for different input images.

```julia
# /test/runtests.jl
x1 = [0.1 0.2];
x2 = [0.1 0.2; 0.3 0.4];
x3 = [0.1 0.2 0.3; 0.4 0.5 0.6];
x4 = [0.1 0.2; 0.3 0.4; 0.5 0.6];
x5 = [0.1, 0.2];
```

In such a case, we use nested test sets to group all tests. This approach has the advantage that each iteration of the loop is treated as a separate test set.

```julia
julia> @testset "image function" begin
           @testset "size(x) = $(size(x))" for x in [x1, x2, x3, x4, x5]
               img = Gray.(x);
               img_flipped = Gray.(x');
               @test image(x) == img_flipped
               @test image(x; flip = false) == img
               @test image(x; flip = true) == img_flipped
           end
       end
size(x) = (2,): Error During Test
[...]
Test Summary:      | Pass  Error  Total
image function     |   12      3     15
  size(x) = (1, 2) |    3             3
  size(x) = (2, 2) |    3             3
  size(x) = (2, 3) |    3             3
  size(x) = (3, 2) |    3             3
  size(x) = (2,)   |           3      3
ERROR: Some tests did not pass: 12 passed, 0 failed, 3 errored, 0 broken.
```

Not all tests passed. The reason is that the variable `x5` is a vector. From the list of all methods defined for the `image` function, we see that there is no method for a vector.

```julia
julia> methods(image)
# 6 methods for generic function "image":
[1] image(x::AbstractArray{var"#s1",2} where var"#s1"<:Real) in ImageInspector at [...]
[2] image(x::AbstractArray{T,3}; flip) where T<:Real in ImageInspector at [...]
[3] image(x::AbstractArray{T,3}, ind::Int64; flip) where T<:Real in ImageInspector at [...]
[4] image(x::AbstractArray{T,3}, inds; flip) where T<:Real in ImageInspector at [...]
[5] image(x::AbstractArray{T,4}, ind::Int64; flip) where T<:Real in ImageInspector at [...]
[6] image(x::AbstractArray{T,4}, inds; flip) where T<:Real in ImageInspector at [...]
```

If we pass a vector as an argument, the `MethodError` will appear. The `Test` package provides the `@test_throw` macro to test if the expression throws the correct exception.

```julia
julia> @test_throws MethodError image(x5)
Test Passed
      Thrown: MethodError
```

The final testing file should be similar to the following one.

```julia
# /test/runtests.jl
using ImageInspector
using ImageInspector.Colors
using Test

@testset "ImageInspector.jl" begin
    x1 = [0.1 0.2]
    x2 = [0.1 0.2; 0.3 0.4]
    x3 = [0.1 0.2 0.3; 0.4 0.5 0.6]
    x4 = [0.1 0.2; 0.3 0.4; 0.5 0.6]
    x5 = [0.1, 0.2]

    @testset "size(x) = $(size(x))" for x in [x1, x2, x3, x4]
        img = Gray.(x);
        img_flipped = Gray.(x');
        @test image(x) == img_flipped
        @test image(x; flip = false) == img
        @test image(x; flip = true) == img_flipped
    end

    @test_throws MethodError image(x5)
end
```

There is `Project.toml` and `Manifest.toml` files in the `test` folder. Creating a different environment has the advantage that it may contain packages needed only for testing. We can run tests directly from the Pkg REPL by the `test` command.

```julia
(examples) pkg> test ImageInspector
    Testing ImageInspector
Status `.../Project.toml`
  [...]
Status `.../Manifest.toml`
  [...]
Test Summary:     | Pass  Total
ImageInspector.jl |   13     13
    Testing ImageInspector tests passed
```


