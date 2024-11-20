using SyntaxTree
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

# write your own tests here
@test Meta.parse("begin x+1 end") |> linefilter! == Expr(:block,:(x+1))
if VERSION < v"0.7"
@test SyntaxTree.sub(Float64,:(7^(x+1)+$(Expr(:macrocall,Symbol("@big_str"),"2")))) == :(7.0^(x+1.0)+2.0)
@test SyntaxTree.abs(:((x-1)^2+$(Expr(:macrocall,Symbol("@big_str"),"2")))) == :((x + 1) ^ 2 + $(Expr(:macrocall,Symbol("@big_str"),"2")))
else
@test SyntaxTree.sub(Float64,:(7^(x+1)+$(Expr(:macrocall,Symbol("@big_str"),nothing,"2")))) == :(7.0^(x+1.0)+2.0)
@test SyntaxTree.abs(:((x-1)^2+$(Expr(:macrocall,Symbol("@big_str"),nothing,"2")))) == :((x + 1) ^ 2 + $(Expr(:macrocall,Symbol("@big_str"),nothing,"2")))
end
@test SyntaxTree.alg(:(x+1)) == :((1 + ϵ) * (x + 1))
@test (f = SyntaxTree.genfun(:x,:x); invokelatest(f, 1) == 1)
@test (f = SyntaxTree.genfun(:x,(:x,:y)); invokelatest(f,1,0) == 1)
@test (f = SyntaxTree.genlatest(:x,:x); invokelatest(f,1) == 1)
@test (f = SyntaxTree.genlatest(:x,(:x,:y)); invokelatest(f,1,0) == 1)
@test callcount(:(x+y*z)) == 2
@test SyntaxTree.exprval(:(x^2-2))[1] == 0.0
