# Soft local scope

The scope of a variable is the region of a code where the variable is visible. There are two main types of scopes in Julia: **global** and **local**, and we will discuss it [later](@ref Scope-of-variables). In this section, we will only focus on loops.

Every variable created inside a loop is local, i.e., it is possible to use it only inside the loop.

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

The variable `i` in the example above is also local. A similar behaviour happens in nested loops:

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

Variable `j` is a local variable defined in the outer loop.  This means that it is visible inside the inner loop and can be used there. On the other hand, variable `i` is a local variable from the inner loop and cannot be accessed in the outer loop.

What happens if use variables from the global scope inside loops? In this case, it depends whether the loop is created in *interactive* (REPL, Jupyter notebook) or *non-interactive* context (file, eval). In the interactive case (in the REPL in our case), global variables can be accessed and modified in local scopes without any restrictions.

```jldoctest
julia> s = 0
0

julia> for i = 1:10
           t = 1 + i # new local variable t
           s = t # assign a new value to the global variable
       end

julia> s
11
```

In this case, if we want to assign a value to a variable, there are two possibilities:
- Variable `t`: there is no global variable with the same name. A new local variable is created.
- Variable `s`: there is a global variable with the same name. A new value is assigned to the global variable.

However, in the non-interactive case, the variables behave differently. In the following example, we create a Julia code as a string and then evaluate it using the `include_string` function.

```jldoctest
julia> code = """
       s = 0
       for i = 1:10
           t = 1 + i # new local variable t
           s = t # new local variable s and warning
       end
       s
       """;

julia> include_string(Main, code)
┌ Warning: Assignment to `s` in soft scope is ambiguous because a global variable by the same name exists: `s` will be treated as a new local. Disambiguate by using `local s` to suppress this warning or `global s` to assign to the existing global variable.
└ @ string:4
0
```

In this case, if we want to assign a value to a variable inside a loop, there are two possibilities:
- Variable `t`: there is no global variable with the same name. A new local variable is created.
- Variable `s`: there is a global variable with the same name. The assignment in the soft scope is ambiguous, and a new local variable is created.

In our example, the variable `s` is defined before the loop as global. In the loop, we get a warning that the assignment to `s` in soft scope is ambiguous, and a new local variable `s` is created instead. The behaviour described above can be changed by specifying that variable `s` is `local`.

```jldoctest softscope; output = false
code_local = """
s = 0
for i = 1:10
    t = 1 + i # new local variable t
    local s = t # assigning a new value to the local variable
end
s
"""

# output
"s = 0\nfor i = 1:10\n    t = 1 + i # new local variable t\n    local s = t # assigning a new value to the global variable\nend\ns\n"
```

Another option is to specify that the variable `s` is `global`.

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

When we evaluate the strings, no warning is produced.

```jldoctest softscope
julia> include_string(Main, code_global)
11

julia> include_string(Main, code_local)
0
```

There are two obvious questions:
1. Why does it not work like the REPL everywhere?
2. Why does it not work like in files everywhere? Why is the warning not skipped?

Since the behaviour from REPL approximates the behaviour inside a function body, it has the advantage of being intuitive and convenient. In particular, it makes it easy to move code back and forth between a function body and the REPL when trying to debug a function. However, it may easily lead to confusion and errors, especially if the code is long or split into multiple files. The intent of the following code is obvious: we want to modify the existing global variable `s` inside the loop.

```julia
s = 0
for i = 1:10
    s += i
end
```

However, real code is usually more complicated. Consider the following example:

```julia
x = 200

# much later, maybe in a different file

for i = 1:10
    x = 1000
    println(x)
end

# much later, maybe in yet another file

y = x + 234
```

It is not clear what should happen here. Should the variable `x` inside the loop be considered local or global? If it is local inside the loop, then the variable `y` will be `434`. On the other hand, if it is global inside the loop, then we assign a new value to it, and the variable `y` will be `1234`. We can accidentally change a variable value and get incorrect results because we use the same variable name multiple times in different scopes.  In this case, it is complicated to find why the results are wrong since there is no error in the code. Julia prints the warning about the ambiguity in such cases to help users. For more information, see the official [documentation](https://docs.julialang.org/en/v1/manual/variables-and-scoping/).
