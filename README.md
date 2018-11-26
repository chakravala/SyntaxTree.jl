<p align="center">
  <img src="./docs/src/assets/logo.png" alt="SyntaxTree.jl"/>
</p>

# SyntaxTree.jl

*Toolset for modifying Julia AST*

[![Build Status](https://travis-ci.org/chakravala/SyntaxTree.jl.svg?branch=master)](https://travis-ci.org/chakravala/SyntaxTree.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/udd0yvrqkeqa5hbp?svg=true)](https://ci.appveyor.com/project/chakravala/syntaxtree-jl)
[![Coverage Status](https://coveralls.io/repos/chakravala/SyntaxTree.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/chakravala/SyntaxTree.jl?branch=master)
[![codecov.io](http://codecov.io/github/chakravala/SyntaxTree.jl/coverage.svg?branch=master)](http://codecov.io/github/chakravala/SyntaxTree.jl?branch=master)

This package is a general purpose toolkit intended for manipulations of Julia's AST. It contains methods like `linefilter`, `callcount`, `genfun`, and `exprval`.

Additionally, this package provides the `exprval` method to compute the expression value as defined in "Optimal polynomial characteristic methods" by Michael Reed in 2018 and the supporting `expravg` and `exprdev` methods to compute scalar averages and standard deviations for expressions. The expression value can be used to order equivalent forms of an expression, where lower values are more optimal and computationally efficient.
