using SyntaxTree
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

# write your own tests here
@test Meta.parse("begin x+1 end") |> linefilter == Expr(:block,:(x+1))
@test SyntaxTree.sub(Float64,:(7^(x+1))) == :(7.0^(x+1.0))
@test SyntaxTree.abs(:(x-1)) == :(x+1)
@test SyntaxTree.alg(:(x+1)) == :((1 + ϵ) * (x + 1))
@test (f = SyntaxTree.genfun(:x,[:x]); f(1) == 1)
@test callcount(:(x+y*z)) == 2
