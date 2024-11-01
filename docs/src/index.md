# CheckConcreteStructs.jl

[![Build Status](https://github.com/gdalle/CheckConcreteStructs.jl/actions/workflows/Test.yml/badge.svg?branch=main)](https://github.com/gdalle/CheckConcreteStructs.jl/actions/workflows/Test.yml?query=branch%3Amain)
[![Dev Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://gdalle.github.io/CheckConcreteStructs.jl/dev/)
[![Coverage](https://codecov.io/gh/gdalle/CheckConcreteStructs.jl/branch/main/graph/badge.svg)](https://app.codecov.io/gh/gdalle/CheckConcreteStructs.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/JuliaDiff/BlueStyle)

Faulty or missing [type declarations](https://docs.julialang.org/en/v1/manual/performance-tips/#Type-declarations), especially for struct fields, are a common performance pitfall in Julia.
This package allows you to check that the structs you work with have concretely-typed fields.

## Getting started

You can install CheckConcreteStructs.jl from the GitHub URL:

```julia
using Pkg
Pkg.add(url="https://github.com/gdalle/CheckConcreteStructs.jl")
```

The main exports of this package are:

- the function [`all_concrete`](@ref), which can be used on an existing type or module
- the macro [`@check_concrete`](@ref), which can be used before a `struct` definition

Please read their docstrings for examples.

## Related packages

[ConcreteStructs.jl](https://github.com/jonniedie/ConcreteStructs.jl) exports a macro `@concrete` which adds all the necessary type parameters to a `struct` definition. In other words:

- CheckConcreteStructs.jl tells you how to fix problems when they occur.
- ConcreteStructs.jl prevents them from occurring at all (in a slightly more opaque way).
