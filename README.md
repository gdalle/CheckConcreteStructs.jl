# CheckConcreteStructs.jl

Faulty or missing [type declarations](https://docs.julialang.org/en/v1/manual/performance-tips/#Type-declarations) are a performance pitfall in Julia.
This package allows you to check whether your `struct` definitions involve only concrete types, as they should.

You can install it from the GitHub URL:

```julia
julia> using Pkg; Pkg.add(url="https://github.com/gdalle/CheckConcreteStructs.jl")
```

The main export of this package is the macro `@check_concrete`.
Please read its docstring for examples of use.

```julia
julia> using CheckConcreteStructs

help?> @check_concrete
```
