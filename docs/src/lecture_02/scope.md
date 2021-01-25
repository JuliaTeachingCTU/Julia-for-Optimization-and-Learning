# Soft Local Scope

The scope of a variable is the region of a code where a variable is visible. There are two main types of scopes in Julia: **global** and **local**, and we will discuss it [later](@ref Scope-of-Variables). In this section, we will only focus on loops.

Every variable created inside a loop is local, i.e., it is possible to use it only inside the loop

```jldoctest
julia> for i in 1:2
           t = 1 + i
           @show t
       end
t = 2
t = 3

julia> t
ERROR: UndefVarError: t not defined
```

Note that the variable `i` in the example above is also local. It is possible to create nested local scopes, for example, nested loops. In such a case, the behavior is as follows

```jldoctest
julia> for j in 1:5
           for i in 1:2
               @show i + j
           end
           i
       end
i + j = 2
i + j = 3
ERROR: UndefVarError: i not defined
```

The variable `j` is a local variable defined in the outer loop.  It means that `j` can be accessed in any local scope defined inside the outer loop, i.e., we can use it inside the inner loop.  On the other hand, the variable `i` is a local variable from the inner loop and, therefore, cannot be accessed in the outer loop.

What happens if we want to use variables from the global scope inside loops? In this case, it depends whether the loop is created in *interactive* context (REPL, Jupyter notebook) or *non-interactive* (file, eval). In the interactive case (in the REPL in our case), global variables can be accessed and modified in local scopes without any restrictions

```jldoctest
julia> s = 0
0

julia> for i = 1:10
           t = 1 + i # new local variable t
           s = t # assigning a new value to the global variable
       end

julia> s
11
```

In this case, if we want to assign a value to a variable, there are two possibilities:
- The case of variable `t`: there is no global variable with the same name, then a new local variable is created.
- The case of variable `s`: there is a global variable with the same name, then a new value is assigned to the global variable.

However, in the non-interactive case, the variables behave differently. In the following example, we create a Julia code as a string and then evaluate it using the `include_string` function.

```jldoctest
julia> code = """
       s = 0
       for i = 1:10
           t = 1 + i # new local variable t
           s = t #  new local variable s + warning
       end
       s
       """;

julia> include_string(Main, code)
┌ Warning: Assignment to `s` in soft scope is ambiguous because a global variable by the same name exists: `s` will be treated as a new local. Disambiguate by using `local s` to suppress this warning or `global s` to assign to the existing global variable.
└ @ string:4
0
```

In this case, if we want to assign a value to a variable inside a loop, there are two possibilities:
- The case of variable `t`: there is no global variable with the same name, then a new local variable is created.
- The case of variable `s`: there is a global variable with the same name, then assignment in soft scope is ambiguous, and a new local variable is created as in the first case.

In our example, the variable `s` is defined before the loop as global. In the loop, we get a warning that the assignment to `s` in soft scope is ambiguous, and a new local variable `s` is created instead. The behavior described above can be changed by using the `local`

```jldoctest softscope; output = false
code_local = """
s = 0
for i = 1:10
    t = 1 + i # new local variable t
    local s = t # assigning a new value to the global variable
end
s
"""

# output
"s = 0\nfor i = 1:10\n    t = 1 + i # new local variable t\n    local s = t # assigning a new value to the global variable\nend\ns\n"
```

or the ` global` keyword

```jldoctest softscope; output = false
code_global = """
s = 0
for i = 1:10
    t = 1 + i # new local variable t
    global s = t # assigning a new value to the global variable
end
s
"""

# output
"s = 0\nfor i = 1:10\n    t = 1 + i # new local variable t\n    global s = t # assigning a new value to the global variable\nend\ns\n"
```

to specify whether the variable should be defined as local or global

```jldoctest softscope
julia> include_string(Main, code_global)
11

julia> include_string(Main, code_local)
0
```

There are two obvious questions one could ask:
1. Why doesn't it just work like the REPL everywhere?
2. Why doesn't it just work like in files everywhere? And maybe skip the warning?

The behavior from REPL has the advantage of being intuitive and convenient since it approximates the behavior inside of a function body. In particular, it makes it easy to move code back and forth between a function body and the REPL when trying to debug the behavior of a function. However, it may easily lead to confusion and errors, especially if the code is long and/or split into multiple files. The intent of the following code is obvious: we want to modify the existing global variable `s` inside the loop

```julia
s = 0
for i = 1:10
    s += i
end
```

However, the actual code is usually more complicated. Consider the following example

```julia
x = 200

# much later
# maybe in a different file

for i = 1:10
    x = 1000
    println(x)
end

# much later
# maybe in yet another file
# or maybe back in the first one where `x = 200`

y = x + 234
```

It is not clear what should happen here. Should be the variable `x` inside the loop considered local or global? If we consider the variable `x` inside the loop as local, then the variable `y` will be `434`. On the other hand, if we consider the variable `x` inside the loop as global, then we assign a new value to it, and the variable `y` will be `1234`. We can accidentally change the value of a variable and get incorrect results because we use the same variable name multiple times in different scopes.  In this case, it is complicated to find why the results are wrong since there is no error in the code. To help users, Julia prints the warning about the ambiguity in such cases. For more information see official [documentation](https://docs.julialang.org/en/v1/manual/variables-and-scoping/).
