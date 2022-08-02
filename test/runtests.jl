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
end

end # @testset
