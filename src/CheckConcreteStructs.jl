"""
    CheckConcreteStructs

Lightweight package to check that structs are defined with concrete fields.

# Exports

- [`@check_concrete`](@ref)
- [`TypeNot`]
"""
module CheckConcreteStructs

using Base.Meta: isexpr

export @check_concrete
export check_concrete
export AbstractFieldError

function get_struct_name(struct_def::Expr)
    @assert isexpr(struct_def, :struct)
    struct_def = struct_def.args[2]  # first line
    struct_def isa Symbol && return struct_def
    if isexpr(struct_def, :(<:))
        struct_def = struct_def.args[1]
    end
    struct_def isa Symbol && return struct_def
    if isexpr(struct_def, :curly)
        struct_def = struct_def.args[1]
    end
    @assert struct_def isa Symbol
    return struct_def
end

"""
    AbstractFieldError

Exception thrown when [`@check_concrete`](@ref) detects a field without a concrete type. 
"""
struct AbstractFieldError <: Exception
    struct_name::Symbol
    field_name::Symbol
    field_type::Type
end

function Base.showerror(io::IO, exc::AbstractFieldError)
    return print(
        io,
        "AbstractFieldError in struct `",
        exc.struct_name,
        "`: field `",
        exc.field_name,
        "` with declared type `",
        exc.field_type,
        "` is not concretely typed.",
    )
end

"""
    @check_concrete struct MyType
        # fields
    end

Macro checking that every field in a struct has a concrete type.

# Examples

Suppose you want to define a struct with a single field containing a vector of real numbers.

The following definitions will throw errors of type [`AbstractFieldError`](@ref):

    @check_concrete struct BadType1
        x
    end

    @check_concrete struct BadType2
        x::AbstractArray
    end

    @check_concrete struct BadType3
        x::Array{<:Real}
    end

The following definitions will execute without error:

    @check_concrete struct GoodType1
        x::Vector{Float64}
    end

    @check_concrete struct GoodType2{T<:Real}
        x::Vector{T}
    end

    @check_concrete struct GoodType3{T<:Real,V<:AbstractVector{T}}
        x::V
    end
"""
macro check_concrete(ex::Expr)
    if isexpr(ex, :macrocall)
        i = findfirst(x -> isexpr(x, :struct), ex.args)
        isnothing(i) && throw(ArgumentError("Expected `struct` definition, got $ex"))
        struct_def = ex.args[i]
    else
        struct_def = ex
    end
    isexpr(struct_def, :struct) || throw(ArgumentError("Expected `struct` definition, got $struct_def"))
    struct_name = get_struct_name(struct_def)
    quote
        $(esc(ex))
        check_concrete($(esc(struct_name)))
    end
end

function check_concrete(m::Module)
    for name in names(m; all = true)
        x = getproperty(m, name)
        isa(x, Type) || continue
        parentmodule(x) === m || continue
        check_concrete(x)
    end
end

check_concrete(T::UnionAll) = check_concrete(Base.unwrap_unionall(T))
function check_concrete(T::Type)
    for (field_name, field_type) in zip(fieldnames(T), fieldtypes(T))
        if !recursive_isconcretetype(field_type)
            throw(AbstractFieldError(nameof(T), field_name, field_type))
        end
    end
end

function recursive_isconcretetype(T)
    isa(T, UnionAll) && return false
    isa(T, TypeVar) && return true  # key modification
    isconcretetype(T) && return true
    isabstracttype(T) && return false
    if isa(T, Union)
        subTs = Base.uniontypes(T)
        # If inference will give up on this union, report as `false`.
        length(subTs) > Core.Compiler.MAX_TYPEUNION_LENGTH && return false
    else
        subTs = fieldtypes(T)
    end
    for subT in subTs
        recursive_isconcretetype(subT) || return false
    end
    return true
end

end # module CheckConcreteStructs
