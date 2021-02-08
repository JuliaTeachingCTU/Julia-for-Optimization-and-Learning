# Why julia?

There are a lot of established programming languages like Python, Matlab, R, or C. So when a new language is introduced, it is natural to ask, why should I learn this new language? What are the advantages and disadvantages of this language? In this section, we will try to introduce the major advantages and disadvantages of Julia and compare Julia to Python, Matlab, R, or C.


## Intuitive and flexible syntax

Julia provides very intuitive and yet flexible syntax, that allows users to write relatively complicated functions in a simple and readable way. As an example, we can compare the definition of the function that computes the [Fibonacci number](https://en.wikipedia.org/wiki/Fibonacci_number) in different languages. In Matlab, the naive implementation of such function is as follows

```matlab
function f = fib(n)
    if n < 2
        f = n;
    else
        f = fib(n-1) + fib(n-2);
    end
end
```

Note that we do not check if the input argument is a non-negative integer. Using the Python, we get the following implementation

```python
def fib(n):
    if n<2:
        return n
    return fib(n-1) + fib(n-2)
```

and if we use the C language the function definition is following

```c
int fib(int n) {
    return n < 2 ? n : fib(n-1) + fib(n-2);
}
```

We see that all three implementations are very different. Surprisingly, the implementation in C is the shortest one. The reason is, that in C it is possible to use the [ternary operator](https://en.wikipedia.org/wiki/%3F:). In Matlab, it is possible to write the `if-else` statement on one line, however, it will decrease the code readability. Implementation of the Fibonacci function in Julia is the following

```julia
fib(n::Int) = n < 2 ? n : fib(n-1) + fib(n-2)
```

But it is also possible to use traditional multiline function declaration syntax

```julia
function fib(n::Int)
    if n < 2
        return n
    else
        return fib(n-1) + fib(n-2)
    end
end
```

Note that annotation of the input argument type and use of the `return` keyword is optional and can be omitted. What we can see it, that Julia supports different syntax for defining functions. It is very useful because it is possible to write simple functions on one line and use a multiline syntax for more complicated functions. Additionally, the authors of Julia took inspiration from other languages and the result is, that Julia provides many handy features known from other languages. For example:
- The syntax of matrix operations are inspired by the one in Matlab.
- Statistical packages use similar syntax to the packages in R.
- It is possible to use list comprehensions and generators like in Python.

## Type system and Multiple-Dispatch

## Performance

One of the most obvious advantages of Julia is its speed. Since Julia uses just-in-time compilation it is possible to achieve the performance of C without using any special tricks or packages. It can be seen in the following figure which shows speed comparison of various languages in multiple micro-benchmarks. The full description of these micro-benchmarks can be found on the official [Julia Micro-Benchmarks](https://julialang.org/benchmarks/) webpage.

These micro-benchmarks test performance on a range of common code patterns, such as function calls, string parsing, sorting, numerical loops, random number generation, recursion, and array operations. It is important to say that the used benchmark codes are not optimized for maximal performance. Instead, the benchmarks are written to test the performance of identical algorithms and code patterns implemented in each language. In the following figure, we can see the computational time increase against the C language for several benchmark functions.

![](benchmarks.svg)

It is fair to say, that in many cases it is possible to improve the performance of other languages using simple tricks. For example, the performance of Python can be improved using Numba, an open-source JIT compiler that translates a subset of Python and NumPy into fast machine code using [LLVM](https://en.wikipedia.org/wiki/LLVM) compiler. Since both Numba and Julia use the same compiler, it is interesting to compare the performance of Julia and Python+Numba.

For the comparison consider the following example of estimating ``\pi`` using Monte Carlo sampling originally posted [here](https://blakeaw.github.io/2019-09-20-numba-vs-julia/). A naive implementation of such estimation in pure Python 3.8.5 (using NumPy for the random number generator) is as follows

```python
import numpy as np

def estimate_pi(n):
    n_circle = 0
    for i in range(n):
        x = 2*np.random.random() - 1
        y = 2*np.random.random() - 1
        if np.sqrt(x**2 + y**2) <= 1:
           n_circle += 1
    return 4*n_circle/n
```

In order to track the computational time, we use the [IPython 7.13.0](https://ipython.org/) command shell in combination with the `timeit` package as follows

```python
In [2]: import timeit
   ...: n = 10000000

In [3]: %timeit estimate_pi(n)
18.3 s ± 990 ms per loop (mean ± std. dev. of 7 runs, 1 loop each)
```

We see that the average computation time is **19.3** seconds, which is a lot. The reason is, that `for` loops in Python are slow. One way how to improve the performance is to use NumPy vectorized operations (it is a similar approach used often in Matlab to improve performance). The vectorized version of the function above can be written as follows

```python
def estimate_pi_vec(n):
    xy = 2*np.random.random((n, 2)) - 1
    n_circle = (np.sqrt((xy**2).sum(axis = 1)) <= 1).sum()
    return 4*n_circle/n
```

Using the same function to track the computational time, we get **354** milliseconds as can be seen below

```python
In [5]: %timeit estimate_pi_vec(n)
354 ms ± 21.3 ms per loop (mean ± std. dev. of 7 runs, 1 loop each)
```

The vectorized version is 50 times faster than the pure Python implementation using the `for` loop. However, it requires rewriting the code and in many cases, it can be very difficult or even impossible to vectorize the code. Another approach is to use the Numba package mentioned above. The Numba package is very easy to use. In our case, we only need to add one line of code before the function definition

```python
import numba

@numba.jit()
def estimate_pi_numba(n):
    n_circle = 0
    for i in range(n):
        x = 2*np.random.random() - 1
        y = 2*np.random.random() - 1
        if np.sqrt(x**2 + y**2) <= 1:
           n_circle += 1
    return 4*n_circle/n
```

The result, in this case, is quite impressive and the average computational time is only **109** milliseconds as can be seen below

```python
In [7]: %timeit estimate_pi_numba(n)
109 ms ± 2.3 ms per loop (mean ± std. dev. of 7 runs, 1 loop each)
```

The resulting code is more than 150 times faster than the pure Python implementation. The question is, how fast is Julia? To answer this question, we use the exact same function definition as in the case of the pure Python implementation.

```julia
function estimate_pi(n)
    n_circle = 0
    for i in 1:n
        x = 2*rand() - 1
        y = 2*rand() - 1
        if sqrt(x^2 + y^2) <= 1
           n_circle += 1
        end
    end
    return 4*n_circle/n
end
```

In Julia, we can use the `BenchmarkTools` package that allows simple benchmarking of the code. To track the computational time we use `@benchmark` macro as follows

```julia
julia> using BenchmarkTools

julia> n = 10000000
10000000

julia> @benchmark estimate_pi(n)
BenchmarkTools.Trial:
  memory estimate:  16 bytes
  allocs estimate:  1
  --------------
  minimum time:     86.532 ms (0.00% GC)
  median time:      93.298 ms (0.00% GC)
  mean time:        95.266 ms (0.00% GC)
  maximum time:     112.988 ms (0.00% GC)
  --------------
  samples:          53
  evals/sample:     1
```

We see that the average computation time is **95.266** seconds. Without any modifications, Julia's code is faster than the Python implementation that uses Numba. The performance gap is not large. However, the Numba package will work only on a small subset of Python and NumPy functionalities. Of course, there are other packages that can be used to increase performance such as Cython. But all these packages have the same problem as Numba and will not support all Python functionalities. The reason is, that Python was not designed to be compiled and thus there are many limitations that can not be solved. On the other hand, Julia was designed to be fast and provides high-performance out of the box without the necessity to do any additional steps. Moreover, the performance in Julia is not restricted only to the subset of the Language as in the case of Numba and other similar packages.


## Disadvantages

There is no language that is perfect for all tasks. In most cases, the choice of the language is a matter of subjective preferences. To be as objective as possible we provide a list of disadvantages of Julia

- **A limited number of packages:** Even though Julia grows rapidly and there are a large number of packages, it can not be compared to the number of available packages in Python or R. However, Julia provides a simple way how to interact with other languages. So if there is no adequate package in Julia, it is possible to use packages from other languages.

- **Slow first run:** Since Julia uses just-in-time compilation, the first call of every function is slower due to compilation. This slowdown can be significant if multiple functions are called for the first time at once. Such a case is creating a plot in a fresh Julia session because packages for plotting are large and use a lot of functions.  It results in a long time to the first plot (~20 s with [Plots.jl](https://github.com/JuliaPlots/Plots.jl)).

- **Limited number of job opportunities:** Because Julia is a relatively new language, there is a limited number of job opportunities, especially compared to Python. On the other hand, there is a list of Julia users and Julia Computing customers on the official webpage of [Julia Computing](https://juliacomputing.com/) containing for example Amazon, Google, IBM, Intel and many others.
