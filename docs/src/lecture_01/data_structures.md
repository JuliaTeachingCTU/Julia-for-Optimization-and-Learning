```@setup random
using Random
Random.seed!(1234)
```

# Data structures

In Julia, there are many types of structures that can be used to store data


## Arrays

Arrays can be constructed directly with square braces; the syntax

```@repl vector
vector = [1:2, 4:5]
```

creates a one dimensional array (i.e., a vector)

```@repl vector
size(vector)
```

If the arguments inside the square brackets are separated by semicolons (;) or newlines instead of commas, then their contents are vertically concatenated together instead of the arguments being used as elements themselves.

```@repl
[1:2; 4:5]
[1:2
```

Similarly, if the arguments are separated by tabs or spaces, then their contents are horizontally concatenated together.

```@repl
```

Using semicolons (or newlines) and spaces (or tabs) can be combined to concatenate both horizontally and vertically at the same time.

```@repl
[1 2
 3 4]
```

There is a convenient notation (called slicing) to access a subset of elements from an array. Let’s suppose we want to access the 2nd to 5th elements of an array of length 6, we can do it in the following way:

```@repl
a = [1,2,3,4,5,6]
a[2:5]
```

We can also use this notation to access a subset of a matrix, for example:

```@repl random
A = rand(4,4)
A[2:3, 2:3]
```

As in other programming languages, arrays are pointers to location in memory, thus we need to pay attention when we handle them. If we create an array `A` and we assign it to a variable `b`, the elements of the original array can be modified be modified by accessing `b`:

```@repl
a = [1,2,3]
b = a
b[2] = 42
a
```

This is particularly useful because it lets us save memory, but may have undesirable effects. If we want to make a copy of an array we need to use the function `copy`

```@repl
a = [1,2,3]
b = copy(a)
b[2] = 42
b
a
```

## Broadcasting

In Julia, with broadcasting we indicate the action of mapping a function or an operation (which are the same in Julia) over an array or a matrix element by element. The broadcasting notation for operators consists of adding a dot `.` before the operator (for example `.*`)

```@repl broadcasting
a = [1,2,3] # column vector
b = [4,5,6] # column vector
c = [4 5 6] # row vector
```

Without the dot, we get an error, since we cannot multiply column vector by another column vector

```@repl broadcasting
a * b
c * a
```

This makes perfectly sense from a mathematical point of view and operators behave how we would mathematically expect. Nonetheless, in programming it is often useful to write operations which work on an element by element basis, and for this reason broadcasting comes to our help.

```@repl broadcasting
a .* b
c .* a
```

We can use the broadcasting notation also to map a function over an n-dimensional array. There is no speed gain in doing so, as it will be exactly equivalent to writing a for loop, but its conciseness may be useful sometimes. So the core idea in Julia is to write functions that take single values and use broadcasting when needed, unless the functions must explicitly work on arrays (for example to compute the mean of a series of values, perform matrix operations, vector multiplications, etc).

```@repl
a = [1,2,3]
ff(x) = x + 1
ff.(a)
```

## Tuples

## Named Tuples

## Dictionaries

## References

- [Official documentation](https://docs.julialang.org/en/v1/manual/variables/)
- [Think Julia: How to Think Like a Computer Scientist](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html#chap02)
- [From Zero to Julia!](https://techytok.com/lesson-variables-and-types/)
