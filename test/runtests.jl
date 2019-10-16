using MIMEBundles
using Test
using JSON

@testset "MIMEBundle for String" begin
    bundle = MIMEBundle("foo")
    mimes = keys(bundle.data)
    @test length(mimes) == 1
    @test first(mimes) == MIME("text/plain")
    @test bundle.data[MIME("text/plain")] == "\"foo\""
end
