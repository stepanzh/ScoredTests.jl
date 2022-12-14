struct Result{E}
    passed::Bool
    exception::E

    Result(passed, ex::E=nothing) where {E} = new{E}(passed, ex)
end

struct ScoredTest{R,S,T}
    result::R
    award::T
    penalty::T
    name::S
end

ispass(t::ScoredTest) = t.result.passed
isfail(t::ScoredTest) = !t.result.passed && isnothing(t.result.exception)
iserror(t::ScoredTest) = !t.result.passed && !isnothing(t.result.exception)
score(t::ScoredTest) = t.result.passed ? t.award : t.penalty

struct ScoredTestException <: Exception
    cause
    expr
end

function Base.showerror(io::IO, e::ScoredTestException)
    println(io, e.cause)
    print(io, "  ", e.expr)
end

"""
    @scoredtest expr [name=""] [award=DefaultScoring.award] [penalty=DefaultScoring.penalty] -> ScoredTests.ScoredTest
    @scoredtest(expr[, name="", award=DefaultScoring.award, penalty=DefaultScoring.penalty]) -> ScoredTests.ScoredTest

Evaluates boolean `expr`ession and returns [`ScoredTest`](@ref),
throws [`ScoredTests.ScoredTestException`](@ref) when `expr` returns not `Bool`.

[`ScoredTest`](@ref) has `name` (should be string), `award` and `penalty` (should be *positive* `Real`s).

A [`ScoredTest`](@ref) can be

- Passed: `expr` is `true`, test gives `award`;
- Failed: `expr` is `false`, test takes `penalty`;
- Errored: `expr` throws error, test takes `penalty`.

Status of test can be checked by [`ScoredTests.ispass`](@ref),
[`ScoredTests.isfail`](@ref) and [`ScoredTests.iserror`](@ref).

Achived score accesible by [`ScoredTests.score`](@ref).

# Example

```julia-repl
julia> st = @scoredtest π < 3 award=2 penalty=4;

julia> ScoredTests.ispass(st)
false

julia> ScoredTests.isfail(st)
true

julia> ScoredTests.iserror(st)
false

julia> ScoredTests.score(st)
-4
```
"""
macro scoredtest(expr, kwargs...)
    award = DefaultScoring.award
    penalty = DefaultScoring.penalty
    name = ""

    for kw in kwargs
        if kw.args[1] ≡ :award
            award = kw.args[2]
        end
        if kw.args[1] ≡ :penalty
            penalty = kw.args[2]
        end
        if kw.args[1] ≡ :name
            name = kw.args[2]
        end
    end

    return quote
        # Macro Arguments
        a = $(esc(award))
        p = $(esc(penalty))
        n = $(esc(name))

        try
            result = $(esc(expr))
            if result isa Bool
                (
                    result ? ScoredTest(Result(true), a, -p, n)
                           : ScoredTest(Result(false), a, -p, n)
                )
            else
                throw(ScoredTestException("The tested expression returns non-Boolean", $(string(expr))))
            end
        catch e
            if e isa ScoredTestException
                rethrow(e)
            end
            ScoredTest(Result(false, e), a, -p, n)
        end
    end
end
