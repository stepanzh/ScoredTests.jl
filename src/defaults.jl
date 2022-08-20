mutable struct Scoring{N}
    award::N
    penalty::N
end

"""
    ScoredTests.DefaultScoring

A default award and penalty for [`@scoredtest`](@ref).

To change award, use `ScoredTests.DefaultScoring.award = ...`.
To change penalty, use `ScoredTests.DefaultScoring.penalty = ...`.

**Warning**. `DefaultScoring` uses `Int`s, be careful of type conversion.
"""
const DefaultScoring = Scoring(1, 1)
