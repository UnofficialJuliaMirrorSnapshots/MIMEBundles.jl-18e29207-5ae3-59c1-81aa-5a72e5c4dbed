using Base64: Base64EncodePipe

"""
    isjsonmime(m::MIME)

Determine whether or not a MIME type is JSON data that should be included
literally in a MIMEBundle (otherwise they will be included as a JSON-encoded
string).
"""
isjsonmime(m::MIME) = istextmime(m) && endswith(string(m), "+json")
isjsonmime(m::AbstractString) = isjsonmime(MIME(m))

# """
#     maybejson(m::MIME, s::AbstractString)
#
# Wrap `s` in a `JSONText` if `m` is a JSON MIME type. This prevents the JSON from
# being doubly-encoded when `MIMEBundles` are JSON encoded.
# """
# function maybejson(m::MIME, s::AbstractString)
#     if isjsonmime(m)
#         return JSONText(s)
#     end
#     return String(s)
# end

"""
    israwtext(m::MIME, obj)

Determine whether or not `obj` should be displayed literally for the specified
MIME type. This is useful to display data that's already encoded properly with
a string MIME type and is used by `mimestring`.
"""
israwtext(m::MIME, x::AbstractString) = istextmime(m)
israwtext(::MIME"text/plain", x::AbstractString) = false
israwtext(::MIME, x) = false

"""
    mimestring(mime::MIME, obj[; limit=true, color=true])

Generate a string using the specified MIME type in a IO context with `:limit`
set to `true`. Binary data is base64-encoded.
"""
function mimestring(mime::MIME, obj; limit=true, color=true)::String
    # If the MIME type is textual and we're given some kind of string, we
    # assume that the data is already represented as that type and there's
    # no need to do anything else to it.
    # e.g. `mimestring("text/html", "<html>...</html>")`
    if israwtext(mime, obj)
        return obj
    end

    # Otherwise, we need to "coerce" obj to a correct MIME representation via
    # `Base.show`.
    buf = IOBuffer()
    if istextmime(mime)
        # Otherwise, we're trying to show some non-string object (or the MIME
        # type should never be considered raw, like text/plain) using the
        # specified MIME, so we defer to `Base.show`.
        # e.g. `mimestring("text/markdown", md"**hello!**")`
        show(IOContext(buf, :limit=>limit, :color=>color), mime, obj)
    else
        b64 = Base64EncodePipe(buf)

        # We were called with a binary MIME and a bunch of binary data (i.e. a
        # vector of bytes), so we should just pass it directly through.
        # e.g. `mimestring("image/png", read("/path/to/catparty.gif")`
        if isa(obj, Vector{UInt8})
            write(b64, obj)
        # We were called with some non-byte-vector object so we need to "coerce"
        # it to the correct MIME type representation.
        else
            show(IOContext(b64, :limit => true, :color => true), mime, obj)
        end

        close(b64)
    end

    return String(take!(buf))
end

function mimerepr(mime::MIME, obj)
    if !showable(mime, obj)
        return nothing, nothing
    end
    try
        return mime, mimestring(mime, obj)
    catch exc
        @warn "Exception while trying to generate MIME repr:" mime obj
        return nothing, nothing
    end
end

function mimerepr(mimes::AbstractVector{MIME}, obj)
    for mime in mimes
        result = mimerepr(mime, obj)
        if result[1] !== nothing
            return result
        end
    end

    # No MIMEs returned anything.
    return nothing, nothing
end
