module MIMEBundles

export MIMEBundle, mimerepr, stringmime

using JSON

include("./mimerepr.jl")
include("./mimes.jl")

struct MIMEBundle
    data::Dict{MIME, Union{String, JSONText}}
    metadata::Dict{Any, Any}
end

function MIMEBundle(obj)
    data = Dict{MIME, Any}()
    metadata = Dict()
    for mime in MIMEOrVec[DEFAULT_MIMES..., extramimes(obj)...]
        mime, result = mimerepr(mime, obj)
        if result !== nothing
            if isjsonmime(mime)
                result = JSONText(result)
            end
            data[mime] = result
        end
    end
    return MIMEBundle(data, metadata)
end

end # module
