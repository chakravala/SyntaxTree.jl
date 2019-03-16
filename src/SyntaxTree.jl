module SyntaxTree

#   This file is part of SyntaxTree.jl. It is licensed under the MIT license
#   Copyright (C) 2018 Michael Reed

export linefilter!, linefilter, callcount, genfun, @genfun

if VERSION < v"0.7.0"
    linefilter(expr) = linefilter!(expr)
else
    @deprecate linefilter(expr) linefilter!(expr)
end

"""
    linefilter!(::Expr)

Recursively filters out `:LineNumberNode` from `Expr` objects.
"""
@noinline function linefilter!(expr::Expr)
    total = length(expr.args)
    i = 0
    while i < total
        i += 1
        if expr.args[i] |> typeof == Expr
            if expr.args[i].head == :line
                deleteat!(expr.args,i)
                total -= 1
                i -= 1
            else
                expr.args[i] = linefilter!(expr.args[i])
            end
        elseif expr.args[i] |> typeof == LineNumberNode
            if expr.head == :macrocall
                expr.args[i] = nothing
            else
                deleteat!(expr.args,i)
                total -= 1
                i -= 1
            end
        end
    end
    return expr
end

"""
    sub(T::DataType,expr::Expr)

Make a substitution to convert numerical values inside an `Expr` to type `T`.
"""
@noinline function sub(T::DataType,expr)
    if typeof(expr) == Expr
        ixpr = deepcopy(expr)
        if ixpr.head == :call && ixpr.args[1] == :^
            ixpr.args[2] = sub(T,ixpr.args[2])
            if typeof(ixpr.args[3]) == Expr
                ixpr.args[3] = sub(T,ixpr.args[3])
            end
        elseif ixpr.head == :macrocall &&
                ixpr.args[1] ∈ [Symbol("@int128_str"), Symbol("@big_str")]
            return convert(T,eval(ixpr))
        else
            for a ∈ 1:length(ixpr.args)
                ixpr.args[a] = sub(T,ixpr.args[a])
            end
        end
        return ixpr
    elseif typeof(expr) <: Number
        return convert(T,expr)
    end
    return expr
end

"""
    SyntaxTree.abs(expr)

Apply `abs` to the expression recursively.
"""
@noinline function abs(expr)
    if typeof(expr) == Expr
        ixpr = deepcopy(expr)
        if ixpr.head == :call && ixpr.args[1] == :^
            ixpr.args[2] = abs(ixpr.args[2])
            if typeof(ixpr.args[3]) == Expr
                ixpr.args[3] = abs(ixpr.args[3])
            end
        elseif ixpr.head == :macrocall &&
                ixpr.args[1] ∈ [Symbol("@int128_str"), Symbol("@big_str")]
                val = VERSION < v"0.7" ? (ixpr.args[1],) : (ixpr.args[1],nothing)
                rep = ('-',"")
                return Expr(:macrocall,val...,replace(ixpr.args[end],(VERSION < v"0.7" ? rep : (Pair(rep...),))...))
        else
            ixpr.head == :call && ixpr.args[1] == :- && (ixpr.args[1] = :+)
            for a ∈ 1:length(ixpr.args)
                ixpr.args[a] = abs(ixpr.args[a])
            end
        end
        return ixpr
    elseif typeof(expr) <: Number
        return Base.abs(expr)
    end
    return expr
end

"""
    alg(expr,f=:(1+ϵ))

Recursively insert a machine epsilon bound (1+ϵ) per call in `expr`.
"""
@noinline function alg(expr,f=:(1+ϵ))
    if typeof(expr) == Expr
        ixpr = deepcopy(expr)
        if ixpr.head == :call
            ixpr.args[2:end] = alg.(ixpr.args[2:end],Ref(f))
            ixpr = Expr(:call,:*,f,ixpr)
        end
        return ixpr
    else
        return expr
    end
end

"""
    @genfun(expr, args)

Returns an anonymous function based on the given `expr` and `args`.

```Julia
julia> @genfun x^2+y^2 x y
```
"""
macro genfun(expr,args...); :(($(args...),)->$expr) end

"""
    genfun(expr, args)

Returns an anonymous function based on the given `expr` and `args`.

```Julia
julia> genfun(:(x^2+y^2),[:x,:y])
julia> genfun(:(x^2+y^2),(:x,:y))
julia> genfun(:(x^2+y^2),:x,:y)
```
"""
genfun(expr,args::Union{Vector,Tuple}) = eval(:(($(args...),)->$expr))
genfun(expr,args::Symbol...) = genfun(expr,args)

"""
    @genlatest(expr, args)

Returns an invokelatest function based on the given `expr` and `args`.

```Julia
julia> @genlatest x^2+y^2 x y
```
"""
macro genlatest(expr,args,gs = gensym())
    eval(Expr(:function,Expr(:call,gs,args.args...),expr))
    :($(Expr(:tuple,args.args...))->Base.invokelatest($gs,$(args.args...)))
end

"""
    genlatest(expr, args)

Returns an invokelatest function based on the given `expr` and `args`.

```Julia
julia> genlatest(:(x^2+y^2),[:x,:y])
julia> genlatest(:(x^2+y^2),(:x,:y))
julia> genlatest(:(x^2+y^2),:x,:y)
```
"""
function genlatest(expr,args::T,gs=gensym()) where T<:Union{Vector,Tuple}
    eval(Expr(:function,Expr(:call,gs,args...),expr))
    if length(args) == 0
        ()->Base.invokelatest(eval(gs))
    elseif length(args) == 1
        (a)->Base.invokelatest(eval(gs),a)
    elseif length(args) == 2
        (a,b)->Base.invokelatest(eval(gs),a,b)
    elseif length(args) == 3
        (a,b,c)->Base.invokelatest(eval(gs),a,b,c)
    elseif length(args) == 4
        (a,b,c,d)->Base.invokelatest(eval(gs),a,b,c,d)
    elseif length(args) == 5
        (a,b,c,d,e)->Base.invokelatest(eval(gs),a,b,c,d,e)
    elseif length(args) == 6
        (a,b,c,d,e,f)->Base.invokelatest(eval(gs),a,b,c,d,e,f)
    elseif length(args) == 7
        (a,b,c,d,e,f,g)->Base.invokelatest(eval(gs),a,b,c,d,e,f,g)
    end
end
genlatest(expr,arg,gs=gensym()) = genlatest(expr,(arg,),gs)

"""
    callcount(expr)

Returns a count of the `call` operations in `expr`.
"""
@noinline function callcount(expr)
    c = 0
    if typeof(expr) == Expr
        expr.head == :call && (c += 1)
        c += sum(callcount.(expr.args))
    end
    return c
end

include("exprval.jl")

end # module
