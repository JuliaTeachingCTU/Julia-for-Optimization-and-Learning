
# [Tests](@id unit-testing)

In this section, we discuss how to test functions defined in the package as well as whether the package follows good practices.

## Test dependencies

When testing the package, it is often usefull to have some additional dependencies that we do not directly use in the package, but are useful for testing. The prototypical example is the `Test` standard library, that contains utilities for testing. Since we use `PkgTemplates` to generate the package structure, we already have some test specific dependencies defined. We can check it in the `Project.toml`, where we have two section we didn';t talk about yet. The first one is `extras` section that cane be used to optional dependencies. In our case, the `extras` section contains two packages  

```toml
[extras]
Aqua = "4c88cf16-eb10-579e-8560-4a9242c79595"
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
```

The second section we didnt talked about yet, is the `targets` section. This section allows us to define which dependencies are used for testing. In our case, the section has the following content

```toml
[targets]
test = ["Aqua", "Test"]
```

It is a good practice to specify compatibility even for th packages that are used for testing. Unfortunatelly, the package manager curently do not support adding compatibility for extras. However, we can add the compatibility manually by modifying `compat` section in the `Project.toml` as follows

```julia
[compat]
Aqua = "0.8"
Colors = "0.9 - 0.13"
Test = "1.9"
julia = "1.9"
```

We specified, that we want to use any version of the `Aqua` package from interval `[0.8.0, 0.9.0)` and any version of the `Test` package from interval `[1.9.0, 2.0.0)`. In fact, the `Test` package is shipped with the Juli by default and technicaly, it doesn't have any version. For that reason, we used the same version as we used for Julia itself.    

## Aqua.jl

`Aqua.jl` provides functions to run a few quality assurance tests for Julia packages. The package for example tests, whether there are no method ambiguities or that all dependencies have specified compatibility constraints. Since we used `PkgTemplates` to generate the package structure, we already have all `Aqua` tests specified in `test/runtests.jl` file 

```julia
# test/runtests.jl
using ImageInspector
using Test
using Aqua

@testset "ImageInspector.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(ImageInspector)
    end
    # Write your tests here.
end
```

Now we can easily run the tests using the `test` command in the Pkg REPL. Note, that we mst have activated the correct envroment

```julia
(ImageInspector) pkg> test
     Testing ImageInspector
     Testing Running tests...
Test Summary:     | Pass  Total  Time
ImageInspector.jl |   11     11  7.6s
     Testing ImageInspector tests passed 
```

## Unit tests

The previous lecture added the `image` function with multiple methods. We also manually tested if these methods work correctly. Even though this practice works for small projects, it is not optimal for code testing and should be automized by [unit testing](https://en.wikipedia.org/wiki/Unit_testing). The `Test` package from the standard library provides utility functions to simplify writing unit tests. Its core is the `@test` macro that tests if an expression evaluates as `true`.

```@repl tests
using Test

@test 1 == 1
@test 1 == 3
```

It is possible to pass additional arguments to the `@test` macro.

```@repl tests
@test π ≈ 3.14 atol=0.01
```

If we go back to our package, we can start writing tests for the methods of the `image` function. All tests should be located in the ` /test` foldert. First, we have to import all necessary packages: `Test`, `ImageInspector` and `Colors`.

```julia
julia> using ImageInspector,  ImageInspector.Colors
```

We import `Colors` from the `ImageInspector` to use the same version. Now we define inputs and expected outputs for the `image` function.

```julia
julia> x = [0.1 0.2; 0.3 0.4];

julia> img = Gray.(x);

julia> img_flipped = Gray.(x');
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

julia> x1 = [0.1 0.2];

julia> x2 = [0.1 0.2; 0.3 0.4];

julia> x3 = [0.1 0.2 0.3; 0.4 0.5 0.6];

julia> x4 = [0.1 0.2; 0.3 0.4; 0.5 0.6];

julia> x5 = [0.1, 0.2];
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

!!! warning "Exercise:"
    Add all the unit tests we showed above into the `test/runtests.jl` file and run all the tests for the package.

!!! details "Solution:"
    The final testing file should be similar to the following one.

    ```julia
    # test/runtests.jl
    using ImageInspector
    using ImageInspector.Colors
    using Test
    using Aqua

    @testset "ImageInspector.jl" begin
        @testset "Code quality (Aqua.jl)" begin
            Aqua.test_all(ImageInspector)
        end

        x1 = [0.1 0.2]
        x2 = [0.1 0.2; 0.3 0.4]
        x3 = [0.1 0.2 0.3; 0.4 0.5 0.6]
        x4 = [0.1 0.2; 0.3 0.4; 0.5 0.6]
        x5 = [0.1, 0.2]

        @testset "size(x) = $(size(x))" for x in [x1, x2, x3, x4]
            img = Gray.(x)
            img_flipped = Gray.(x')
            @test image(x) == img_flipped
            @test image(x; flip=false) == img
            @test image(x; flip=true) == img_flipped
        end

        @test_throws MethodError image(x5)
    end
    ```

    We can again run all tests directly from the ImageInspector enviroment in the Pkg REPL using the `test` command. 

    ```julia
    (ImageInspector) pkg> test
        Testing ImageInspector
        Testing Running tests...
    Test Summary:     | Pass  Total  Time
    ImageInspector.jl |   24     24  5.8s
        Testing ImageInspector tests passed 
    ```

    We can also run tests for some specific package by specifying the name of the package after the `test` command. For example, we can run all testst for the ImageInspector from the `example` enviroment in the following way

    ```julia
    (ImageInspector) pkg> activate ./examples

    (examples) pkg> test ImageInspector
        Testing ImageInspector
        Testing Running tests...
    Test Summary:     | Pass  Total  Time
    ImageInspector.jl |   24     24  6.3s
        Testing ImageInspector tests passed 
    ```
