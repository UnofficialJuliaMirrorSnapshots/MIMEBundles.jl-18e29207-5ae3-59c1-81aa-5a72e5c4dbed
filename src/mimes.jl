const MIMEVec = AbstractVector{MIME}
const MIMEOrVec = Union{MIME, MIMEVec}

"""
    extramimes(x)

Get a vector of extra (non-default) MIME types to include in a MIMEBundle.
"""
extramimes(x::Any) = MIME[]

"""
Default MIME types to show.

Every MIME type listed here will be included in the default MIMEBundle for an
object if it has a corresponding `show` method. If a nested vector of MIMEs is
specified, the first applicable MIME will be included (and the result will not).

This list is as long as it is for legacy reasons. Types should define an
`extramimes` methods to include extra mimes in their bundle (recommended), or
define a custom `MIMEBundle` method for complete control over exactly what MIME
types are included.
"""
const DEFAULT_MIMES = Vector{MIMEOrVec}([
    MIME("text/plain"),
    MIME("text/latex"),
    MIME("image/svg+xml"),
    [
        MIME("image/png"),
        MIME("image/jpeg"),
    ],
    [
        MIME("text/markdown"),
        MIME("text/html"),
    ],
    [
        MIME("application/vnd.vegalite.v3+json"),
        MIME("application/vnd.vegalite.v2+json"),
        MIME("application/vnd.vega.v5+json"),
        MIME("application/vnd.vega.v4+json"),
        MIME("application/vnd.vega.v3+json"),
    ],
    [
        MIME("application/vnd.dataresource+json"),
        MIME("application/vnd.plotly.v1+json"),
    ],
])
