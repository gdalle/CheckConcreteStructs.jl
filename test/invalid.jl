using CheckConcreteStructs
using Test

## Without type params

@test_throws AbstractFieldError @check_concrete struct I11
    x
end

@test_throws AbstractFieldError @check_concrete struct I12
    x::Int
    y
end

@test_throws AbstractFieldError @check_concrete struct I13
    x::Int
    y::Integer
end

@test_throws AbstractFieldError @check_concrete struct I14
    x::Int
    y::Array
end

@test_throws AbstractFieldError @check_concrete struct I15
    x::Int
    y::Array{Int}
end

@test_throws AbstractFieldError @check_concrete struct I16
    x::Int
    y::AbstractArray{Int,1}
end

@test_throws AbstractFieldError @check_concrete struct I18
    x::Int
    y::Vector{<:Integer}
end

## With type params

@test_throws AbstractFieldError @check_concrete struct I21{T}
    x::Int
    y::AbstractVector{T}
end

@test_throws AbstractFieldError @check_concrete struct I22{T<:Integer}
    x::Int
    y::Tuple{Int,AbstractVector{T}}
end

@test_throws AbstractFieldError @check_concrete struct I23{T1,T2}
    x::Int
    y::Tuple{T1,Array{T2}}
end

@test_throws AbstractFieldError @check_concrete struct I24{T1}
    x::Union{T1, Int, Float32, Float64}
end

@test_throws AbstractFieldError @check_concrete mutable struct I25{T1}
    const x::Real
    y::Vector{Any}
end

@test_throws AbstractFieldError @eval Base.@kwdef @check_concrete mutable struct I26{T1}
    const x::T1
    y::AbstractVector{Any} = []
    const z::Int = 3
end

@test_throws AbstractFieldError @eval Base.@kwdef @check_concrete mutable struct I27{T1}
    const x::T1
    y::Vector{Any} = []
    const z::Real = 3
end
