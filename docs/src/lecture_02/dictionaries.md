# Dictionaries

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
[...]

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
