using Test
using ScoredTests

ST = ScoredTests

@testset "ScoredTests.jl" begin

@testset "@scoredtest" begin
    @testset "Exceptions" begin
        @test_throws ST.ScoredTestException @scoredtest(1 + 1)
    end

    @testset "Return cases" begin
        respassed = ST.ScoredTest(ST.Result(true, nothing), 1, -1, "")
        @test @scoredtest(1 + 1 == 2) == respassed

        resfailed = ST.ScoredTest(ST.Result(false, nothing), 1, -1, "")
        @test @scoredtest(1 + 1 != 2) == resfailed

        reserrored = ST.ScoredTest(ST.Result(false, UndefVarError(:x)), 1, -1, "")
        @test @scoredtest(1 + 1 == x) == reserrored
    end

    @testset "Basic interpolation" begin
        res = ST.ScoredTest(ST.Result(true, nothing), 1, -1, "")
        x = 2
        foo(x) = 2x
        @test @scoredtest(1 + 1 == x) == res
        @test @scoredtest(foo(x)/2 == 2) == res
    end

    @testset "Arguments" begin
        res = ST.ScoredTest(ST.Result(true, nothing), 10, -10, "Foo")
        @test @scoredtest(1 + 1 == 2, name="Foo", award=10, penalty=10) == res

        award, penalty, name = 10, 10, "Foo"
        @test @scoredtest(1 + 1 == 2, name=name, award=award, penalty=penalty) == res
    end
end

@testset "ScoredTestSet" begin
    @testset "Constructors" begin
        @test ScoredTestSet() isa ScoredTestSet
    end

    @testset "Appending" begin
        ts = ScoredTestSet()
        ts *= @scoredtest 1 + 1 == 2
        @test length(ts.tests) == 1

        ts *= ScoredTestSet()
        @test length(ts.tests) == 2
    end

    @testset "Statistics" begin
        tsoutter = ScoredTestSet()
        tsinner = ScoredTestSet()
        tsinner *= @scoredtest 1 + 1 == 2
        tsinner *= @scoredtest 1 + 2 == 2
        tsinner *= @scoredtest 1 + x == 2
        tsoutter *= tsinner
        tsoutter *= @scoredtest 1 + 1 == 2

        award = ScoredTests.DefaultScoring.award
        penalty = ScoredTests.DefaultScoring.penalty

        @testset "Testset depth 1" begin
            statinner = ScoredTests.stats(tsinner)
            @test statinner.count == 3
            @test statinner.passed == 1
            @test statinner.failed == 1
            @test statinner.errored == 1
            @test statinner.score == award - 2 * penalty
            @test statinner.maxscore == 3 * award
        end

        @testset "Testset depth 2" begin
            statoutter = ScoredTests.stats(tsoutter)
            @test statoutter.count == 4
            @test statoutter.passed == 2
            @test statoutter.failed == 1
            @test statoutter.errored == 1
            @test statoutter.score == 2 * award - 2 * penalty
            @test statoutter.maxscore == 4 * award
        end
    end
end

end # @testset
