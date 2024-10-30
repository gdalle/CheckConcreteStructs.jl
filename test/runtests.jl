using CheckConcreteStructs
using Test

@testset verbose = true "CheckConcreteStructs" begin
    @check_concrete struct A end
    @check_concrete struct B <: AbstractVector{Int} end
    @check_concrete struct C{T} <: AbstractVector{T} end

    @test_throws TypeNotConcreteError @check_concrete struct D
        x
    end
    @test_throws TypeNotConcreteError @check_concrete struct E
        x::Vector
    end
    @test_throws TypeNotConcreteError @check_concrete struct F
        x::Vector{<:Real}
    end
    @test_throws TypeNotConcreteError @check_concrete struct G{T}
        x::AbstractVector{T}
    end
    @test_throws TypeNotConcreteError @check_concrete struct H
        x::Int
        y::Real
    end

    @check_concrete struct I
        x::Int
        y::Vector{Any}
    end

    @check_concrete struct J{T}
        x::Int
        y::Vector{T}
    end
end
