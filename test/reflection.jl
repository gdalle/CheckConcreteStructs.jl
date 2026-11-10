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

struct ConcreteTypeField
    datatype::Type{Int}
end
struct TypeUnionField
    datatype::Union{Type{UInt32},Type{UInt64}}
end
struct TypeParameterField{T}
    datatype::Type{T}
end
struct ContainerTypeParameterField{T}
    datatype::Type{Vector{T}}
end
struct AbstractTypeField
    datatype::Type{Real}
end
struct UnrestrictedType
    datatype::Type
end
struct OpenTypeFamily
    datatype::Type{<:Integer}
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

@testset "Type fields" begin
    @test all_concrete(ConcreteTypeField)
    @test all_concrete(TypeUnionField)
    @test all_concrete(TypeParameterField)
    @test all_concrete(TypeParameterField{UInt32})
    @test !all_concrete(TypeParameterField{Real}; verbose=false)
    @test !all_concrete(TypeParameterField{Vector}; verbose=false)
    @test !all_concrete(TypeParameterField{Union{}}; verbose=false)
    @test all_concrete(TypeParameterField{Vector{Real}})
    @test all_concrete(ContainerTypeParameterField)
    @test !all_concrete(AbstractTypeField; verbose=false)
    @test !all_concrete(UnrestrictedType; verbose=false)
    @test !all_concrete(OpenTypeFamily; verbose=false)
end

@testset "Recursive parametric fields" begin
    @test all_concrete(RecursiveNode)
    @test all_concrete(RecursiveNode{Int})
    @test !all_concrete(RecursiveAbstractNode; verbose=false)
    @test !all_concrete(RecursiveAbstractNode{Int}; verbose=false)
end
