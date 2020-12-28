```@setup loops
using Random
Random.seed!(1234)
```

# Loops and iterators

## `for` loop

```@repl
for i in [1,2,3,4]
    println(i)
end
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Use the for loop to print integers from `1` to `100`, which are divisible by `3` and `7`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
Firstly we generate integers from `1` to `100`. It can be done using `range` function that accept positional argument `start` point and keyword arguemnt `stop` point or `length`. The user can also set the step length using keyword argument `step`. If `length`, `stop`, and `step` are all specified, they must agree. To generate integers from `1` to `100` we can use following code

```@repl
range(1; stop = 100) # or equivalently range(1; length = 100)
```

which is equivalent to using shorter syntax `start:step:stop` (the `step` can be omitted if it is equal to `1`)

```@repl
1:100 # or equivalently 1:1:100
```
Now we have to select only integers that are divisible by `3` and `7`. That can be done using the modulo function, `for` loop and `if` statement

```@repl
for i in 1:100
    if mod(i, 3) == 0 && mod(i, 7) == 0
        println(i)
    end
end
```

or we can use short-circuit evaluation and chain of conditions

```@repl
for i in 1:100
    mod(i, 3) == mod(i, 7) == 0 && println(i)
end
```
```@raw html
</p></details>
```


## `while` loop


```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Use the while loop to print integers from `1` to `100`, which are divisible by `3` and `7`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

```@repl
i = 0
while i < 100
    i += 1
    mod(i, 3) == mod(i, 7) == 0 && println(i)
end
```

```@raw html
</p></details>
```

## Iterators

```@repl loops
for i in eachindex(A)
    @show i
end
for (i, a) in enumerate(A)
    @show (i, a)
end
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

For matrix A defined as
```julia
A = [i + j for i in 1:10, j in 1:10]
```
compute the sum of all elements in each row and print the following message
> Sum of all elements in row `i` is `i_sum`
where `i` represents the number of the row and `i_sum` the sum of all elements in this row.


```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

```@repl
A = [i + j for i in 1:10, j in 1:10];
for (i, row) in enumerate(eachrow(A))
    println("Sum of all elements in row $(i) is $(sum(row))")
end
```

```@raw html
</p></details>
```

## List comprehension

Comprehensions provide a general and powerful way to construct arrays. Comprehension syntax is similar to set construction notation in mathematics:

```@repl
[x + y for x in 1:10, y in 1:4]
```

```@repl
f(x, y) = 2 + x*y
[f(x,y) for x in 1:10, y in 11:14]
```

```@repl
[x^2 for x in 1:10 if isodd(x)]
```

```@repl
[x^2 + y^2  for x in 1:10, y in 1:10 if x + y < 5]
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Use the list comprehension to select integers from `1` to `100`, which are divisible by `3` and `7`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

```@repl
[i for i in 1:100 if mod(i, 3) == mod(i, 7) == 0]
```

```@raw html
</p></details>
```

## Generator expressions

Comprehensions can also be written without the enclosing square brackets, producing an object known as a generator. This object can be iterated to produce values on demand, instead of allocating an array and storing them in advance (see Iteration). For example, the following expression sums a series without allocating memory:

```@repl
sum(1/n^2 for n in 1:1000)
```

Ranges in generators and comprehensions can depend on previous ranges by writing multiple for keywords:

```@repl
[(i,j) for i in 1:3 for j in 1:i]
```

In such cases, the result is always 1-d. Generated values can also be filtered using the if keyword:

```@repl
[(i,j) for i in 1:3 for j in 1:i if i+j == 4]
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Use a generator to sum the square of all integers from `1` to `100`, which are divisible by `3` and `7`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

```@repl
sum(i^2 for i in 1:100 if mod(i, 3) == mod(i, 7) == 0)
```

```@raw html
</p></details>
```

## `map` function


## `mapreduce` function
