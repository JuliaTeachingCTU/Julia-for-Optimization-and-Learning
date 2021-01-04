# Other useful packages

## Distributions.jl


## BSON.jl

[BSON](https://github.com/JuliaIO/BSON.jl) is a package for working with the Binary JSON serialisation format. It can be used as a general store for Julia data structures.

```@repl bson
using BSON

BSON.bson("test.bson", Dict(:a => [1+2im, 3+4im], :b => "Hello, World!"))
BSON.load("test.bson")
```

```@repl bson
using BSON

BSON.bson("test.bson", a = [1+2im, 3+4im], b = "Hello, World!")
BSON.load("test.bson")
```

```@repl bson
using BSON: @save, @load

a = [1+2im, 3+4im];
b = "Hello, World!";

@save "test.bson" a b # Same as above
@load "test.bson" a b # Loads `a` and `b` back into the workspace
```

## ProgressMeter.jl

The [ProgressMeter](https://github.com/timholy/ProgressMeter.jl) package provides excellent utilities for printing progress bars for long-running computation. The package provides `@showprogress` macro, that can be used for printing progress bar for `for` loops in the following way

```julia
julia> using ProgressMeter

julia> @showprogress 1 "Computing..." for i in 1:50
           sleep(0.1)
       end
Computing... 20%|███████▊                               |  ETA: 0:00:04
```

The same syntax can be used also with `map`/`pmap`/`reduce` function. Progress bars can be also created manually, which allows additional formatting of the output. For example, it is possible to print and update information related to the computation by using the `showvalues` keyword as follows

```julia
julia> x, n = 1 , 10;

julia> p = Progress(n);

julia> for iter in 1:10
           x *= 2
           sleep(0.5)
           ProgressMeter.next!(p; showvalues = [(:iter, iter), (:x, x)])
       end
Progress: 100%|█████████████████████████████████████████| Time: 0:00:10
  iter:  10
  x:     1024
```

## BenchmarkTools.jl

The [BenchmarkTools](https://github.com/JuliaCI/BenchmarkTools.jl) package provides a framework for writing and running groups of benchmarks as well as comparing benchmark results. The primary macro provided by BenchmarkTools is `@benchmark`.

```@repl benchmark
using BenchmarkTools
@benchmark sin(x) setup=(x=rand())
```

The `setup` expression in the example above,  is run once per sample, and is not included in the timing results. Another handy macro provided by the package is the `@btime` macro. The output of this macro is similar to the built-in `@time` macro

```@repl benchmark
A = rand(3,3);
@btime inv($A);
```
Note, that we use `$` to interpolate variable `A` into the benchmark expression. Any expression that is interpolated in such a way into the benchmark expression, is "pre-computed" before benchmarking begins.
