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

end # module
