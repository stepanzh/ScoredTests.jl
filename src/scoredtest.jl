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

ispassed(t::ScoredTest) = t.result.passed
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
    @scoredtest expr [name=""] [award=1] [penalty=1]

Evaluates `expr`ession and returns [`ScoredTest`](@ref).
"""
macro scoredtest(expr, kwargs...)
    award = 1
    penalty = 1
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
        try
            result = $(esc(expr))
            if result isa Bool
                (
                    result ? ScoredTest(Result(true), $award, -$penalty, $name)
                           : ScoredTest(Result(false), $award, -$penalty, $name)
                )
            else
                throw(ScoredTestException("The tested expression returns non-Boolean", $(string(expr))))
            end
        catch e
            if e isa ScoredTestException
                rethrow(e)
            end
            ScoredTest(Result(false, e), $award, -$penalty, $name)
        end
    end
end