using Aqua
using CheckConcreteStructs
using Test

@testset verbose = true "CheckConcreteStructs" begin
    @testset "Formalities" begin
        Aqua.test_all(CheckConcreteStructs)
    end

    @testset "Valid structs" begin
        include("valid.jl")
    end

    @testset "Invalid structs" begin
        include("invalid.jl")
    end

    @testset "Error display" begin
        err = AbstractFieldError(:MyStruct, :myfield, Any)
        buf = IOBuffer()
        showerror(buf, err)
        msg = String(take!(buf))
        @test startswith(msg, "AbstractFieldError")
    end
end
