using CheckConcreteStructs
using Test

module ParametricUnionAliases
const Optional{T} = Union{Nothing,T}
const HostOrPointer{T} = Union{Vector{T},Ptr{T}}
struct Good
    value::Int
end
end

module ParametricAliasesWithAbstractField
const Optional{T} = Union{Nothing,T}
struct Bad
    value::Real
end
end

struct SingletonHeader
    datatype::Union{Type{UInt32},Type{UInt64}}
end
struct SingletonParameter{T}
    datatype::Type{T}
end
struct SingletonAbstractType
    datatype::Type{Real}
end
struct UnrestrictedType
    datatype::Type
end
struct OpenTypeFamily
    datatype::Type{<:Integer}
end

struct TabledLaw{N}
    p::NTuple{N,Float64}
    sy::NTuple{N,Float64}
end
struct AbstractTuple{N}
    values::NTuple{N,Real}
end
struct OpenTupleLength
    values::Tuple{Vararg{Float64}}
end
struct UnrestrictedTuple
    values::Tuple
end

struct RecursiveNode{T}
    next::Union{Nothing,RecursiveNode{T}}
    value::T
end
struct RecursiveAbstractNode{T}
    next::Union{Nothing,RecursiveAbstractNode{T}}
    value::T
    abstract_value::Real
end

@testset "Parametric union aliases" begin
    @test all_concrete(ParametricUnionAliases)
    @test !all_concrete(ParametricAliasesWithAbstractField; verbose=false)
end

@testset "Singleton type fields" begin
    @test all_concrete(SingletonHeader)
    @test all_concrete(SingletonParameter)
    @test all_concrete(SingletonParameter{UInt32})
    @test all_concrete(SingletonAbstractType)
    @test !all_concrete(UnrestrictedType; verbose=false)
    @test !all_concrete(OpenTypeFamily; verbose=false)
end

@testset "Tuple length parameters" begin
    @test all_concrete(TabledLaw)
    @test all_concrete(TabledLaw{3})
    @test isbitstype(TabledLaw{3})
    @test !all_concrete(AbstractTuple; verbose=false)
    @test !all_concrete(OpenTupleLength; verbose=false)
    @test !all_concrete(UnrestrictedTuple; verbose=false)
end

@testset "Recursive parametric fields" begin
    @test all_concrete(RecursiveNode)
    @test all_concrete(RecursiveNode{Int})
    @test !all_concrete(RecursiveAbstractNode; verbose=false)
    @test !all_concrete(RecursiveAbstractNode{Int}; verbose=false)
end
