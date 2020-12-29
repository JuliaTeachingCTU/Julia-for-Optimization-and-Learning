# Loops and iterators

As in other languages, Julia supports two basic constructs for repeated evaluation: the `while` and` for` loops. Loops are useful when we want to repeat some computation multiple times with different values. A typical example is performing operations on array elements.

## `for` and `while` loop

The `while` loop evaluates the condition expression, and as long it remains `true`, keeps also evaluating the body of the `while` loop. If the condition expression is `false` when the while loop is first reached, the body is never evaluated.

```@repl
i = 1
while i <= 5
    @show i
    global i += 1
end
```

Note, that we use `global` statement inside the `while` loop. The reason is, that in the REPL Julia uses so-called soft scope, i.e. it is possible to use variables from outside of the loop, but when we want to change them, we have to use `global` keyword. We will talk about local and global scope of variables later.

Also note, that the `@show` macro takes an expression as an input and prints the expression and its result. It can be used to print multiple variables at once in a nice way

```@repl
a, b, c = 1, "hello", :world;
@show (a, b, c);
```
In the previous example, we can see, that we use a semicolon. In the REPL, if we evaluate any expression, its result is printed. If we use the semicolon, the print is omitted. It is similar behavior as in Matlab, but in Julia, the print is automatic only in the REPL.


`for` loops can be created in a similar way as in Matlab. In the following example, we iterate over the range of integers from 1 to 10. In the following example, we iterate over the range of integers from 1 to 10, and in each iteration, we use the `@show` macro to print the current value of the variable `i`

```@repl
for i in 1:5
    @show i
end
```

```@raw html
<div class = "info-body">
<header class = "info-header">An alternative notation for <code>for</code> loops</header><p>
```
There are two alternative notation for the `for` loop. It is possible to use `=` or `∈` instead of `in` keyword
```@repl
for i = 1:5
    @show i
end
```
However, for better readability, it is better to always use `in`. Or at least be consistent and use the same keyword in all `for` loops.

```@raw html
</p></div>
```

In Julia, it is possible to loop not only over ranges. For example, it is possible to loop over arrays or tuples. This is very useful because it allows us to get elements of iterable objects directly without having to use indexes

```@repl
persons = ["Alice", "Bob", "Carla", "Daniel"]
for name in persons
    println("Hi, my name is $name.")
end
```

It is also possible to iterate over other data structures. For example, we can iterate over dictionaries

```@repl
persons = Dict("Alice" => 10, "Bob" => 23, "Carla" => 14, "Daniel" => 34)
for (name, age) in persons
    println("Hi, my name is $name and I am $age old.")
end
```

Note, that in this case, we iterate over pairs of the key and corresponding value.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Use both `for` and `while` loop to print integers from `1` to `100`, which are divisible by `3` and `7`.

**Hint:** use the modulo function.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
The exercise can be solved as follows for the `for` loop
```@repl
for i in 1:100
    mod(i, 3) == mod(i, 7) == 0 && println(i)
end
```

and for `while` loop as follows

```@repl
i = 1;
while i <= 100
    mod(i, 3) == mod(i, 7) == 0 && println(i)
    global i += 1
end
```
```@raw html
</p></details>
```

### `break` and `continue`

It is sometimes useful to stop the `for` loop based on some condition. It can be done using the `break` keyword. In the following example, the loop iterates over the range from 1 to 10 and breaks when `i == 4`, i.e. only the first four numbers are printed

```@repl
for i in 1:10
    i == 4 && break
    @show i
end
```

Another useful feature is to skip some elements. It can be done using `continue` keyword. For example, the following code prints all even numbers from 1 to 10

```@repl
for i in 1:10
    mod(i, 2) == 0 || continue
    @show i
end
```

Note, that the code after `continue` keyword expression is not evaluated

### Nested loops

It is possible to create nested `for` loops in the following way

```@repl
for i in 1:3
    for j in i:3
        @show (i, j)
    end
end
```
Note, that the range in the inner loop depends on the variable `i` from the outer loop. This style of writing nested loops is common in other languages and is very useful. However, in Julia, it is possible to use an even shorter syntax

```@repl
for i in 1:3, j in i:3
    @show (i, j)
end
```
In this case, the output is the same as in the previous example, but this syntax is not equivalent to the previous one. The main difference is when using break statement. If we use the first syntax, a `break` statement inside an inner loop exits only the inner loop.
```@repl
for i in 1:3
    for j in i:10
        j > 3 && break
        @show (i, j)
    end
end
```
On the other hand, if we use the shorter syntax, a `break` statement inside an inner loop exits the entire nest of loops
```@repl
for i in 1:3, j in i:10
    j > 3 && break
    @show (i, j)
end
```
There are other limitations to sorter syntax. For example, it is not possible to perform any operation outside the inner loop. Nevertheless, it is still a very useful syntax in many cases.

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
