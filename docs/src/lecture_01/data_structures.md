## Tuples

A tuple is an immutable, ordered, fixed-sized group of elements, i.e., it is not possible to add new elements or change the value of any element in a tuple. Tuples are created using the following syntax

```jldoctest tuples
julia> t = (1, 2.0, "3")
(1, 2.0, "3")
```

It is even possible to omit the brackets

```jldoctest tuples
julia> t = 1, 2.0, "3"
(1, 2.0, "3")
```

The same syntax is used in a [function definition](@ref Functions) to return multiple values at once. The types of all its elements give the type of a tuple

```jldoctest tuples
julia> typeof(t)
Tuple{Int64,Float64,String}
```

In this case,  we have a tuple that contains three elements, where the first one is of type `Int64`, the second one of type `Float64`, and the last one of type `String`.

To access elements of a tuple, we can use the same syntax as for arrays

```jldoctest tuples
julia> t[1] # the first element
1

julia> t[end] # the last element
"3"

julia> t[1:2] # the first two elements
(1, 2.0)
```

A handy feature is that it is possible to unpack a tuple over many values

```jldoctest tuples
julia> a, b, c = t
(1, 2.0, "3")

julia> println("The values stored in the tuple are: $a, $b and $c")
The values stored in the tuple are: 1, 2.0 and 3
```

Note that arrays can be unpacked similarly. Tuples are usually used for storing a small number of values, and then this feature may be useful. On the other hand, arrays are usually large, so such a feature is not useful for arrays most of the time.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Create a tuple that contains the first four letters of the alphabet (these letters should be of type `String`). Then unpack this tuple into four variables `a`, `b`, `c` and `d`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Such a tuple can be created easily using the standard syntax

```jldoctest tuples_ex
julia> t = ("a", "b", "c", "d")
("a", "b", "c", "d")
```

To unpack the tuple, we can use the four variables and the `=` sign

```jldoctest tuples_ex
julia> a, b, c, d = t
("a", "b", "c", "d")
```

```@raw html
</p></details>
```

## Named Tuples

Named tuples are similar to tuples, i.e., a named tuple is immutable, ordered, fixed-sized group of elements. The only difference is that each element consists of a name (identifier) and value. Named tuples are created using the following syntax

```jldoctest named_tuples
julia> t = (a = 1, b = 2.0, c = "3")
(a = 1, b = 2.0, c = "3")
```

or it is possible to create a named tuple directly from variables

```jldoctest named_tuples
julia> a = 1;

julia> b = 2.0;

julia> c = "3";

julia> t = (; a, b, c)
(a = 1, b = 2.0, c = "3")
```

Here the semicolon is mandatory because, without the semicolon, the result will be a tuple instead of a named tuple. Similarly to tuples, the elements of a named tuple can be accessed via square brackets. However, in opposed to tuples, it is not possible to access multiple elements at once

```jldoctest named_tuples
julia> t[1] # the first element
1

julia> t[end] # the last element
"3"

julia> t[1:2] # error
ERROR: MethodError: no method matching getindex(::NamedTuple{(:a, :b, :c),Tuple{Int64,Float64,String}}, ::UnitRange{Int64})
[...]
```

Moreover, it is possible to get elements of a named tuple via their names or unpack elements directly to variables

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

Dictionaries are mutable, unordered (random order) collections of pairs of keys and values. The syntax for creating a dictionary is as follows

```jldoctest dicts
julia> d = Dict("a" => [1, 2, 3], "b" => 1)
Dict{String,Any} with 2 entries:
  "b" => 1
  "a" => [1, 2, 3]
```

or using symbols instead of strings as keys

```jldoctest dicts
julia> d = Dict(:a => [1, 2, 3], :b => 1)
Dict{Symbol,Any} with 2 entries:
  :a => [1, 2, 3]
  :b => 1
```

In fact, it is possible to use almost any type as a key in a dictionary. The elements of a dictionary can be accessed via square brackets and a key

```jldoctest dicts
julia> d[:a]
3-element Array{Int64,1}:
 1
 2
 3
```

If the key does not exist in the dictionary and we try to get it using the square brackets syntax, an error will occur

```jldoctest dicts
julia> d[:c]
ERROR: KeyError: key :c not found

julia> haskey(d, :c)
false
```

Note that we use the `haskey` function to check if the given dictionary has the `:c` key. To avoid such errors, we can use the `get` function that accepts three arguments: a dictionary, key, and a default value for this key, which is returned if the key does not exist in the given dictionary

```jldoctest dicts
julia> get(d, :c, 42)
42
```

There is also an in-place version of the `get` function. The `get!` function add the default value to the dictionary if the key does not exist

```jldoctest dicts
julia> get!(d, :c, 42)
42

julia> get!(d, :d, ["hello", "world"])
2-element Array{String,1}:
 "hello"
 "world"

julia> d
Dict{Symbol,Any} with 4 entries:
  :a => [1, 2, 3]
  :b => 1
  :d => ["hello", "world"]
  :c => 42
```

Unwanted keys from the dictionary can be removed using the `delete!` function

```jldoctest dicts
julia> delete!(d, :d)
Dict{Symbol,Any} with 3 entries:
  :a => [1, 2, 3]
  :b => 1
  :c => 42

julia> haskey(d, :d)
false
```

An alternative is the `pop!` function, which removes the key from the dictionary and returns the value corresponding to this key

```jldoctest dicts
julia> pop!(d, :c)
42

julia> haskey(d, :c)
false
```

Optionally it is possible to add a default value for a given key to the `pop!` function, which is returned if the key does not exist in the given dictionary

```jldoctest dicts
julia> haskey(d, :c)
false

julia> pop!(d, :c, 444)
444
```
