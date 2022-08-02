struct ScoredTestSet{S}
    description::S
    tests::Vector{Union{ScoredTest,ScoredTestSet}}

    ScoredTestSet(d::S="") where {S} = new{S}(d, [])
end

record(ts::ScoredTestSet, t::ScoredTest) = push!(ts.tests, t)
record(ts::ScoredTestSet, ts2::ScoredTestSet) = push!(ts.tests, ts2)

Base.:*(ts::ScoredTestSet, t::ScoredTest) = begin record(ts, t); return ts end
Base.:*(ts::ScoredTestSet, t::ScoredTestSet) = begin record(ts, t); return ts end


struct ScoredTestSetStats{I,F}
    count::I
    passed::I
    failed::I
    errored::I
    score::F
    maxscore::F
end

function Base.show(io::IO, s::ScoredTestSetStats)
    println(io, "ScoredTestSetStats")
    println(io, "  Count:     ", s.count)
    println(io, "  Passed:    ", s.passed)
    println(io, "  Failed:    ", s.failed)
    println(io, "  Errored:   ", s.errored)
    println(io, "  Score:     ", s.score)
      print(io, "  Max score: ", s.maxscore)
end

function stats(ts::ScoredTestSet)
    count = passed = failed = errored = 0
    currscore = maxscore = 0

    for t in ts.tests
        if t isa ScoredTestSet
            stat = stats(t)
            count += stat.count
            passed += stat.passed
            failed += stat.failed
            errored += stat.errored
            currscore += stat.score
            maxscore += stat.maxscore
            continue
        end

        count += 1
        currscore += score(t)
        maxscore += t.award

        if ispassed(t)
            passed += 1
        elseif isfail(t)
            failed += 1
        elseif iserror(t)
            errored += 1
        end
    end
    return ScoredTestSetStats(
        count,
        passed,
        failed,
        errored,
        currscore,
        maxscore,
    )
end

function _print_impl(io::IO, ts::ScoredTestSet, count::Integer=0)
    if count == 0
        println("No.   Result  Score  [Name]  [Error]")
    end
    !isempty(ts.description) && println(io, ts.description)

    for t in ts.tests
        if t isa ScoredTestSet
            println()
            count += _print_impl(io, t, count)
            continue
        end

        count += 1
        resultchar = "N/A"
        if ispassed(t)
            resultchar = "✓"
            color = :green
        elseif isfail(t)
            resultchar = "✗"
            color = :red
        elseif iserror(t)
            resultchar = "E"
            color = :red
        end

        # Column separator is "  " (two spaces)
        @printf(io, "%4d", count)
        printstyled(io, "  ", @sprintf("%6s", resultchar); color=color)
        @printf(io, "  %5d", score(t))
        print(io, isempty(t.name) ? "" : "  $(t.name)")
        iserror(t) && print(io, "  Error occured: $(t.result.exception)")
        println(io)
    end
    return count
end

function printsummary(io::IO, ts::ScoredTestSet, stat::ScoredTestSetStats=stats(ts))
    percentage(x, m) = "$(round(100 * x / m; digits=1))%"

    _print_impl(io, ts)
    println(io)
    println(io, "Summary")
    print(io, "  Passed $(stat.passed) tests of $(stat.count) [$(percentage(stat.passed, stat.count))]")
    stat.errored > 0 && print(io, " and $(stat.errored) of tests throws exceptions")
    println(io)
    println(io, "  Achieved $(stat.score) points of $(stat.maxscore) [$(percentage(stat.score, stat.maxscore))]")
    return nothing
end

printsummary(ts::ScoredTestSet, args...) = printsummary(stdout, ts, args...)
