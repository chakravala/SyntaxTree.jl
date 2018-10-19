#   This file is part of SyntaxTree.jl. It is licensed under the MIT license
#   Copyright (C) 2018 Michael Reed

function expravg(expr)
    cs = 0
    s = 0.0
    cp = 0
    p = 0.0
    if typeof(expr) == Expr
        if expr.head == :call && expr.args[1] == :^ &&
            expr.args[3] |> typeof <: Number
            cp += 1
            p  += abs(expr.args[3])
            (cst,st,cpt,pt) = expravg(expr.args[2])
            cs += cst
            s  += cst*st
            cp += cpt
            p  += cpt*pt
        else
            for arg ∈ expr.args
                (cst,st,cpt,pt) = expravg(arg)
                cs += cst
                s  += cst*st
                cp += cpt
                p  += cpt*pt
            end
        end
    elseif typeof(expr) <: Number
        cs += 1
        s  += log(abs(expr))
    end
    return (cs,0 ∈ [s,cs] ? 1.0 : s/cs,cp,cp == 0 ? 1.0 : p/cp)
end

function exprdev(expr,val,cal)
    s = 0.0
    if typeof(expr) == Expr
        for arg ∈ expr.args
            s += exprdev(arg,val,cal)
        end
    elseif typeof(expr) <: Number
        s  += ((log(abs(expr))-val)^2)/(cal-1)
    end
    return s
end

function exprval(expr)
    val = expravg(expr)
    cal = callcount(expr)
    mal = sqrt(exprdev(expr,val[2],cal))
    cal*sqrt(abs(val[2])*mal)*val[4], cal, mal, val[2], val[4]
end
