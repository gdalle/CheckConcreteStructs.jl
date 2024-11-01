using CheckConcreteStructs
using Test

M1 = @eval module $(gensym(:TestModule))
struct Good{T1}
    x::T1
    y::Vector{Any}
end

struct AlsoGood{T1}
    x::Int
    y::Vector{T1}
end
end

@test all_concrete(M1)

M2 = @eval module $(gensym(:TestModule))
struct Good{T1}
    x::T1
    y::Vector{Any}
end

struct Bad{T1}
    x::Real
    y::Vector{T1}
end
end

@test !all_concrete(M2; verbose=false)
@test_logs (
    :warn,
    "AbstractFieldError in struct `Bad`: field `x` with declared type `Real` is not concretely typed.",
) !all_concrete(M2)
