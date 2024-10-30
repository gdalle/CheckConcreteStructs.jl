module CheckConcreteStructs

function get_struct_name(expr::Expr)
    @assert expr.head == :struct
    struct_def = expr.args[2]
    struct_def isa Symbol && return struct_def
    if struct_def.head == :(<:)
        struct_def = struct_def.args[1]
    end
    struct_def isa Symbol && return struct_def
    if struct_def.head == :curly
        struct_def = struct_def.args[1]
    end
    @assert struct_def isa Symbol
    return struct_def
end

macro check_concrete(expr::Expr)
    @assert expr.head == :struct
    S = get_struct_name(expr)
    block = expr.args[3]
    for (i, arg) in enumerate(block.args)
        Meta.isexpr(arg, :(::)) || isa(arg, Symbol) || continue
        if isa(arg, Symbol)
            block.args[i] = :(throw($TypeNotConcreteError($(QuoteNode(arg)), Any)))
        else
            name, type = (arg.args[1], arg.args[2])
            block.args[i] = Expr(:(::), name, :($check_is_concretetype($type, $(QuoteNode(name)))))
        end
    end
    esc(expr)
end

struct TypeNotConcreteError <: Exception
    field::Symbol
    type::Type
end

Base.showerror(io::IO, exc::TypeNotConcreteError) = print(io, "TypeNotConcreteError: field ", exc.field, " with declared type ", exc.type, " is not concretely typed")

function check_is_concretetype(T, name)
    isconcretetype_with_typevar(T) || throw(TypeNotConcreteError(name, T))
    T
end

function isconcretetype_with_typevar(T::Type)
    isa(T, UnionAll) && return false
    isa(T, TypeVar) && return true
    isconcretetype(T) && return true
    isabstracttype(T) && return false
    for subT in fieldtypes(T)
        isconcretetype_with_typevar(subT) || return false
    end
    true
end

export @check_concrete, TypeNotConcreteError

end # module CheckConcreteStructs
