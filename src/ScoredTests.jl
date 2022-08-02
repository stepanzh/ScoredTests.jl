module ScoredTests

export @scoredtest
export ScoredTestSet
export printsummary, stats

using Printf

include("scoredtest.jl")
include("scoredtestset.jl")

end # module
