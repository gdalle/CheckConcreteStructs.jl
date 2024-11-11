"""
    CheckConcreteStructs

Lightweight package to check that types are defined with concrete fields.

# Exports

- [`all_concrete`](@ref)
- [`@check_concrete`](@ref)
"""
module CheckConcreteStructs

using Base.Meta: isexpr

export @check_concrete
export all_concrete

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

struct AbstractFieldError <: Exception
    struct_name::Symbol
    field_name::Symbol
    field_type::Type
end

function Base.string(exc::AbstractFieldError)
    return string(
        "AbstractFieldError in struct `",
        exc.struct_name,
        "`: field `",
        exc.field_name,
        "` with declared type `",
        exc.field_type,
        "` is not concretely typed.",
    )
end

function Base.showerror(io::IO, exc::AbstractFieldError)
    return print(io, string(exc))
end

"""
    @check_concrete struct MyType
        # fields
    end

Check that every field of a struct definition is concretely typed, throw an error if that is not the case.

# Examples

Types with abstract fields:

```jldoctest
julia> using CheckConcreteStructs

julia> @check_concrete struct Bad1; x; end  # missing annotation
ERROR: AbstractFieldError in struct `Bad1`: field `x` with declared type `Any` is not concretely typed.

julia> @check_concrete struct Bad2; x::AbstractVector; end  # abstract container
ERROR: AbstractFieldError in struct `Bad2`: field `x` with declared type `AbstractVector` is not concretely typed.

julia> @check_concrete struct Bad3; x::Vector{<:Real}; end  # abstract element type
ERROR: AbstractFieldError in struct `Bad3`: field `x` with declared type `Vector{<:Real}` is not concretely typed.

julia> @check_concrete struct Bad4; x::Array{Float64}; end  # not enough type parameters
ERROR: AbstractFieldError in struct `Bad4`: field `x` with declared type `Array{Float64}` is not concretely typed.
```

Types with only concrete fields:

```jldoctest
julia> using CheckConcreteStructs

julia> @check_concrete struct Good1; x::Vector{Float64}; end
true

julia> @check_concrete struct Good2{T<:Real}; x::Vector{T}; end
true

julia> @check_concrete struct Good3{T<:Real,V<:AbstractVector{T}}; x::V; end
true
```
"""
macro check_concrete(ex::Expr)
    if isexpr(ex, :macrocall)
        i = findfirst(x -> isexpr(x, :struct), ex.args)
        isnothing(i) && throw(ArgumentError("Expected `struct` definition, got $ex"))
        struct_def = ex.args[i]
    else
        struct_def = ex
    end
    isexpr(struct_def, :struct) ||
        throw(ArgumentError("Expected `struct` definition, got $struct_def"))
    struct_name = get_struct_name(struct_def)
    quote
        $(esc(ex))
        all_concrete_aux($(esc(struct_name)); throw_error=true, log_warning=false)
    end
end

"""
    all_concrete(M::Module; verbose=true)

Return `true` if every type defined inside the module `M` has only concretely-typed fields.

If `verbose=true`, any field with an abstract type will display a warning.

!!! warning
    This function does not handle submodules yet.
"""
function all_concrete(M::Module; verbose::Bool=true)
    concrete = true
    for name in names(M; all=true)
        x = getproperty(M, name)
        isa(x, Type) || continue
        isa(x, Union) && continue
        isabstracttype(x) && continue
        parentmodule(x) === M || continue
        if !all_concrete(x; verbose)
            concrete = false
        end
    end
    return concrete
end

"""
    all_concrete(T::Type; verbose=true)

Return `true` if type `T` has only concretely-typed fields.

If `verbose=true`, any field with an abstract type will display a warning.

# Examples

Types with abstract fields:

```jldoctest
julia> using CheckConcreteStructs

julia> struct Bad1; x; end  # missing annotation

julia> all_concrete(Bad1; verbose=false)
false

julia> struct Bad2; x::AbstractVector; end  # abstract container

julia> all_concrete(Bad2; verbose=false)
false

julia> struct Bad3; x::Vector{<:Real}; end  # abstract element type

julia> all_concrete(Bad3; verbose=false)
false

julia> struct Bad4; x::Array{Float64}; end  # not enough type parameters

julia> all_concrete(Bad4; verbose=false)
false
```

Types with only concrete fields:

```jldoctest
julia> using CheckConcreteStructs

julia> struct Good1; x::Vector{Float64}; end

julia> all_concrete(Good1)
true

julia> struct Good2{T<:Real}; x::Vector{T}; end

julia> all_concrete(Good2)
true

julia> struct Good3{T<:Real,V<:AbstractVector{T}}; x::V; end

julia> all_concrete(Good3)
true
```
"""
all_concrete(T; verbose::Bool=true) =
    all_concrete_aux(T; throw_error=false, log_warning=verbose)

function all_concrete_aux(T::UnionAll; throw_error::Bool, log_warning::Bool)
    return all_concrete_aux(Base.unwrap_unionall(T); throw_error, log_warning)
end

function all_concrete_aux(T::Type; throw_error::Bool, log_warning::Bool)
    concrete = true
    for (field_name, field_type) in zip(fieldnames(T), fieldtypes(T))
        if !recursive_isconcretetype(field_type)
            concrete = false
            exc = AbstractFieldError(nameof(T), field_name, field_type)
            throw_error && throw(exc)
            log_warning && @warn string(exc)
        end
    end
    return concrete
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
