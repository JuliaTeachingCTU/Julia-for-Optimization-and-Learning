## Tuples

A tuple is an immutable, ordered, fixed-sized group of elements. Therefore, it is impossible to add new elements or change any tuple element's values. Tuples are created using the following syntax:

```jldoctest tuples
julia> t = (1, 2.0, "3")
(1, 2.0, "3")
```

It is possible to omit the brackets.

```jldoctest tuples
julia> t = 1, 2.0, "3"
(1, 2.0, "3")
```

The same syntax is used in [function definitions](@ref Functions) to return multiple values at once. The tuple type consists of the types of all its elements.

```jldoctest tuples
julia> typeof(t)
Tuple{Int64, Float64, String}
```

In this case, we have a tuple that contains three elements: `Int64`, `Float64`, and `String`.

To access elements of a tuple, we can use the same syntax as for arrays.

```jldoctest tuples
julia> t[1] # the first element
1

julia> t[end] # the last element
"3"

julia> t[1:2] # the first two elements
(1, 2.0)
```

A handy feature is the possibility to unpack a tuple over its values.

```jldoctest tuples
julia> a, b, c = t
(1, 2.0, "3")

julia> println("The values stored in the tuple are: $a, $b and $c")
The values stored in the tuple are: 1, 2.0 and 3
```

Arrays can be unpacked similarly. However, tuples are usually used for storing a small number of values, while arrays are typically large. Recall that while tuples are immutable, arrays are mutable.

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise:</header>
<div class="admonition-body">
```

Create a tuple that contains the first four letters of the alphabet (these letters should be of type `String`). Then unpack this tuple into four variables `a`, `b`, `c` and `d`.

```@raw html
</div></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Such a tuple can be created easily using the standard syntax:

```jldoctest tuples_ex
julia> t = ("a", "b", "c", "d")
("a", "b", "c", "d")
```

We can use the four variables and the `=` sign to unpack the tuple.

```jldoctest tuples_ex
julia> a, b, c, d = t
("a", "b", "c", "d")
```

```@raw html
</p></details>
```

## Named tuples

Named tuples are similar to tuples, i.e., a named tuple is immutable, ordered, fixed-sized group of elements. The only difference is that each element consists of a name (identifier) and a value. Named tuples are created by the following syntax:

```jldoctest named_tuples
julia> t = (a = 1, b = 2.0, c = "3")
(a = 1, b = 2.0, c = "3")
```

It is also possible to create a named tuple directly from variables.

```jldoctest named_tuples
julia> a = 1;

julia> b = 2.0;

julia> c = "3";

julia> t = (; a, b, c)
(a = 1, b = 2.0, c = "3")
```

Here the semicolon is mandatory because, without the semicolon, the result will be a tuple instead of a named tuple. Similarly to tuples, the elements of a named tuple can be accessed via square brackets. However, as opposed to tuples, it is impossible to access multiple elements at once.

```jldoctest named_tuples
julia> t[1] # the first element
1

julia> t[end] # the last element
"3"

julia> t[1:2] # error
ERROR: MethodError: no method matching getindex(::NamedTuple{(:a, :b, :c), Tuple{Int64, Float64, String}}, ::UnitRange{Int64})
[...]
```

On the other hand, it is possible to get elements of a named tuple via their names or unpack elements directly to variables.

```jldoctest named_tuples
julia> t.a
1

julia> t.c
"3"

julia> a, b, c = t
(a = 1, b = 2.0, c = "3")

julia> println("The values stored in the tuple are: a = $a, b = $b")
The values stored in the tuple are: a = 1, b = 2.0
```

## Dictionaries

Dictionaries are mutable, unordered (random order) collections of pairs of keys and values. The syntax for creating a dictionary is:

```jldoctest dicts
julia> d = Dict("a" => [1, 2, 3], "b" => 1)
Dict{String, Any} with 2 entries:
  "b" => 1
  "a" => [1, 2, 3]
```

Another possibility is to use symbols instead of strings as keys.

```jldoctest dicts
julia> d = Dict(:a => [1, 2, 3], :b => 1)
Dict{Symbol, Any} with 2 entries:
  :a => [1, 2, 3]
  :b => 1
```

It is possible to use almost any type as a key in a dictionary. Dictionary's elements can be accessed via square brackets and a key.

```jldoctest dicts
julia> d[:a]
3-element Vector{Int64}:
 1
 2
 3
```

If the key does not exist in the dictionary, an error will occur if we try to access it.

```jldoctest dicts
julia> d[:c]
ERROR: KeyError: key :c not found

julia> haskey(d, :c)
false
```

The `haskey` function checks whether the dictionary has the `:c` key. To avoid such errors, we can use the `get` function that accepts three arguments: a dictionary, key, and a default value for this key, which is returned if the key does not exist in the dictionary.

```jldoctest dicts
julia> get(d, :c, 42)
42
```

There is also an in-place version of the `get` function. The `get!` function adds the default value to the dictionary if the key does not exist.

```jldoctest dicts
julia> get!(d, :c, 42)
42

julia> get!(d, :d, ["hello", "world"])
2-element Vector{String}:
 "hello"
 "world"

julia> d
Dict{Symbol, Any} with 4 entries:
  :a => [1, 2, 3]
  :b => 1
  :d => ["hello", "world"]
  :c => 42
```

Unwanted keys from the dictionary can be removed by the `delete!` function.

```jldoctest dicts
julia> delete!(d, :d)
Dict{Symbol, Any} with 3 entries:
  :a => [1, 2, 3]
  :b => 1
  :c => 42

julia> haskey(d, :d)
false
```

An alternative is the `pop!` function, which removes the key from the dictionary, and returns the value corresponding to it.

```jldoctest dicts
julia> pop!(d, :c)
42

julia> haskey(d, :c)
false
```

Optionally, it is possible to add a default value for a given key to the `pop!` function, which is returned if the key does not exist in the given dictionary.

```jldoctest dicts
julia> haskey(d, :c)
false

julia> pop!(d, :c, 444)
444
```
