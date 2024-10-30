# CheckConcreteStructs.jl

[![Build Status](https://github.com/gdalle/CheckConcreteStructs.jl/actions/workflows/Test.yml/badge.svg?branch=main)](https://github.com/gdalle/CheckConcreteStructs.jl/actions/workflows/Test.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/gdalle/CheckConcreteStructs.jl/branch/main/graph/badge.svg)](https://app.codecov.io/gh/gdalle/CheckConcreteStructs.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/JuliaDiff/BlueStyle)

Faulty or missing [type declarations](https://docs.julialang.org/en/v1/manual/performance-tips/#Type-declarations) are a performance pitfall in Julia.
This package allows you to check whether your `struct` definitions involve only concrete types, as they should.

You can install it from the GitHub URL:

```julia
pkg> add "https://github.com/gdalle/CheckConcreteStructs.jl"
```

The main export of this package is the macro `@check_concrete`.
Please read its docstring for examples of use.

```julia
julia> using CheckConcreteStructs

help?> @check_concrete
```
