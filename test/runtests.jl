using Aqua
using CheckConcreteStructs
using Documenter
using JET
using Test

@testset verbose = true "CheckConcreteStructs" begin
    @testset "Formalities" begin
        @testset "Aqua" begin
            Aqua.test_all(CheckConcreteStructs)
        end
        @testset "JET" begin
            JET.test_package(CheckConcreteStructs)
        end
    end

    @testset "Doctests" begin
        Documenter.doctest(CheckConcreteStructs)
    end

    @testset "Valid structs" begin
        include("valid.jl")
    end

    @testset "Invalid structs" begin
        include("invalid.jl")
    end

    @testset "Modules" begin
        include("modules.jl")
    end

    @testset "Error display" begin
        err = AbstractFieldError(:MyStruct, :myfield, Any)
        buf = IOBuffer()
        showerror(buf, err)
        msg = String(take!(buf))
        @test startswith(msg, "AbstractFieldError")
    end
end
