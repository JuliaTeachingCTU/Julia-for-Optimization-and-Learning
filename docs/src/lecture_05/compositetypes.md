# Composite types

```@repl structs
abstract type Person end

struct Student
    name
    age
end
```

```@repl structs
s = Student("Paul", 25)
typeof(s)
```

```@repl structs
fieldnames(Student)
s.name
getfield(s, :age)
```

```@repl structs
s.name = "Steven"
```

## Mutable structures

## Functors

## Parametric composite types
