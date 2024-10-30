using CheckConcreteStructs
using Test

@testset verbose = true "CheckConcreteStructs" begin
    @check_concrete struct A end
    @check_concrete struct B <: AbstractVector{Int} end
    @check_concrete struct C{T} <: AbstractVector{T} end

    @test_throws ErrorException @check_concrete struct D
        x
    end
    @test_throws ErrorException @check_concrete struct E
        x::Vector
    end
    @test_throws ErrorException @check_concrete struct F
        x::Vector{<:Real}
    end
    @test_throws ErrorException @check_concrete struct G{T}
        x::AbstractVector{T}
    end
    @test_throws ErrorException @check_concrete struct H
        x::Int
        y::Real
    end

    @test_skip @test_throws ErrorException @check_concrete struct I
        x::Int
        y::Vector{Any}
    end
end
