# ScoredTests.jl

ScoredTests.jl is a tiny package providing

- `@scoredtest expr [award] [penalty] [name]` macro;
- `ScoredTestSet([description])`.

The macro evaluates an expression giving result of the test: was it passed, failed or errored during testing.

When a test is passed, it gives `award`, when failed or errored it takes `penalty`.

Tests (and testsets) can be grouped into `ScoredTestSet`-s via `*=` orepand.

## MWE

```julia-repl
julia> using ScoredTests

julia> ts = ScoredTestSet("Basic math");

julia> ts = ScoredTestSet("Basic math");

julia> ts2 = ScoredTestSet("Trigonometry");

julia> ts3 = ScoredTestSet("Quadratic polynomials");

julia> ts2 *= @scoredtest sin(x)^2 + cos(x)^2 == 1;

julia> ts2 *= @scoredtest sin(10)^2 + cos(10)^2 == 1;

julia> ts2 *= @scoredtest sin(-1) / cos(-1) == tan(-1) name="Tangent definition";

julia> ts3 *= @scoredtest (1 + 2)^2 == 1^2 + 2*1*2 + 2^2 name="Square of sum" award=5;

julia> ts3 *= @scoredtest (1 - 2)^2 == 1^2 + 2*1*2 + 2^2 name="Square of difference";

julia> ts3 *= @scoredtest 3^2 - 4^2 == (3 - x)(3 + x) penalty=2;

julia> ts *= ts2;

julia> ts *= ts3;

julia> printsummary(ts)
Basic math

Trigonometry
No.   Result  Score  [Name]  [Error]
   1       E     -1  Error occured: UndefVarError(:x)
   2       ✓      1
   3       ✗     -1  Tangent definition

Quadratic polynomials
No.   Result  Score  [Name]  [Error]
   4       ✓      5  Square of sum
   5       ✗     -1  Square of difference
   6       E     -2  Error occured: UndefVarError(:x)

Summary
  Passed 2 tests of 6 [33.3%] and 2 of tests throws exceptions
  Achieved 1 points of 10 [10.0%]
```
