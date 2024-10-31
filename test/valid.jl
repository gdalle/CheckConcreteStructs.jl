using CheckConcreteStructs
using Test

## Empty without type params

@check_concrete struct V11 end
@check_concrete struct V12 <: AbstractVector{Int} end

## Empty with type params

@check_concrete struct V21{T} end
@check_concrete struct V22{T} <: AbstractVector{Int} end
@check_concrete struct V23{T<:Integer} <: AbstractVector{Int} end

## Full without type params

@check_concrete struct V31
    x::Int
end

@check_concrete struct V32
    x::Int
    y::Vector{Int}
end

@check_concrete struct V33
    x::Int
    y::Vector{Integer}
end

@check_concrete struct V34
    x::Int
    y::Vector{Int}
    z::Vector{Tuple{Int,Integer}}
end

## Full with type params

@check_concrete struct V41{T}
    x::T
end

@check_concrete struct V42{T<:Integer}
    x::T
    y::Vector{T}
end

@check_concrete struct V43{T1<:Integer,T2}
    x::T1
    y::Vector{T2}
    z::Vector{Tuple{T2,Int}}
end

@check_concrete struct V51{T1}
    x::Union{T1, Int}
end

@check_concrete struct V52{T1}
    x::Union{T1, Int, Float64}
end

@check_concrete mutable struct V53{T1}
    const x::T1
    y::Vector{Any}
end

@check_concrete Base.@kwdef mutable struct V54{T1}
    const x::T1
    y::Vector{Any} = []
    const z::Int = 3
end

@test V54{Int}(; x = 2) isa V54
@test isconst(V54, :x)

"Struct definition."
Base.@kwdef @check_concrete mutable struct V55{T1}
    const x::T1
    y::Vector{Any} = []
    const z::Int = 3
end

@test V55{Int}(; x = 2) isa V55
@test isconst(V55, :x)
