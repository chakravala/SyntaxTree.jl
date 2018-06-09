module SyntaxTree

export linefilter

"""
    linefilter(::Expr)

Recursively filters out :line blocks from Expr objects
"""
@noinline function linefilter(e::Expr)
    total = length(e.args)
    i = 0
    while i < total
        i += 1
        if e.args[i] |> typeof == Expr
            if e.args[i].head == :line
                deleteat!(e.args,i)
                total -= 1
                i -= 1
            else
                e.args[i] = linefilter(e.args[i])
            end
        elseif e.args[i] |> typeof == LineNumberNode
            deleteat!(e.args,i)
            total -= 1
            i -= 1
        end
    end
    return e
end

"""
    sub(T::DataType,expr::Expr)

Make a substitution to convert numerical values to type T
"""
function sub(T::DataType,ixpr)
    if typeof(ixpr) == Expr
        expr = deepcopy(ixpr)
        if expr.head == :call && expr.args[1] == :^
            expr.args[2] = sub(T,expr.args[2])
            if typeof(expr.args[3]) == Expr
                expr.args[3] = sub(T,expr.args[3])
            end
        elseif expr.head == :macrocall &&
                expr.args[1] ∈ [Symbol("@int128_str"), Symbol("@big_str")]
            return convert(T,eval(expr))
        else
            for a ∈ 1:length(expr.args)
                expr.args[a] = sub(T,expr.args[a])
            end
        end
        return expr
    elseif typeof(ixpr) <: Number
        return convert(T,ixpr)
    end
    return ixpr
end

function makeabs(ixpr)
    if typeof(ixpr) == Expr
        expr = deepcopy(ixpr)
        if expr.head == :call && expr.args[1] == :^
            expr.args[2] = makeabs(expr.args[2])
            if typeof(expr.args[3]) == Expr
                expr.args[3] = makeabs(expr.args[3])
            end
        elseif expr.head == :macrocall &&
                expr.args[1] ∈ [Symbol("@int128_str"), Symbol("@big_str")]
            return abs(expr)
        else
            expr.head == :call && expr.args[1] == :- && (expr.args[1] = :+)
            for a ∈ 1:length(expr.args)
                expr.args[a] = makeabs(expr.args[a])
            end
        end
        return expr
    elseif typeof(ixpr) <: Number
        return abs(ixpr)
    end
    return ixpr
end

end # module
