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

getfield_stable(x, ::Val{i}) where i = getfield(x, i)

macro check_concrete(expr::Expr)
    @assert expr.head == :struct
    S = get_struct_name(expr)
    return quote
        $(esc(expr))
        
        for (i, n) in enumerate(fieldnames($(esc(S))))
            vi = Val(i)
            ts = Base.return_types(s -> getfield_stable(s, vi), ($(esc(S)),))
            t = only(ts)
            if !isconcretetype(t)
                error("Field $n is not concrete ($t)")
            end
        end
    end
end

export @check_concrete

end # module CheckConcreteStructs
