using DataStructures: OrderedDict


mutable struct DictSpace <: AbstractSpace
    spaces::OrderedDict{Union{Symbol, AbstractString}, AbstractSpace}
    shape::Tuple
    DictSpace(spaces::OrderedDict{<:Union{Symbol, AbstractString}, <:AbstractSpace}) =  new(spaces, ())
    DictSpace(;space_kwargs...) = new(OrderedDict{Symbol, AbstractSpace}(space_kwargs), ())
end

DictSpace(spaces::Dict{T , <:AbstractSpace}) where T  =
    DictSpace(OrderedDict(sort([(sym, space) for (sym, space) in pairs(spaces)])))

sample(dict_obj::DictSpace) = OrderedDict([(k, sample(space)) for (k, space) in pairs(dict_obj.spaces)])

function contains(x, dict_obj::DictSpace)
    # If x is not a dict or OrderedDict or if x doesn't have the same length as spaces
    if !(isa(x, Dict) || isa(x, OrderedDict)) || length(x) != length(dict_obj.spaces)
        return false
    end

    for (k, space) in pairs(dict_obj.spaces)
        # If k is not in x, or if x[k] ∉ space return false
        (isnothing(get(x, k, nothing)) || !(x[k] ∈ space)) && return false
    end
    return true
end

"""
    seed!(dict_obj::DictSpace; kwarg_seeds...)


Seeds the spaces in the DictSpace. Currently, seeding of DictSpaces with only Symbol keys is allowed.

# Example

julia> space = DictSpace(Dict(:position => Discrete(5),
                              :velocity => Box([0, 0], [1, 5], Float32)))
.
.
.

julia> seed!(space, position=42)

julia> seed!(space, position=2, velocity=4)
"""
function seed!(dict_obj::DictSpace; kwarg_seeds...)
    if !(Symbol <: dict_obj.spaces |> keys |> eltype)
        throw(ErrorException("Seeding with DictSpaces with only symbols as keys is allowed at the moment."))
    end
    for kwarg in kwarg_seeds
        space = get(dict_obj.spaces, kwarg.first, nothing)
        isnothing(space) &&
            throw(ArgumentError("$(kwarg.first) is not present in this DictSpace."))
        seed!(space, kwarg.second)
    end
end

Base.:(==)(dict_obj::DictSpace, other::DictSpace) = dict_obj.spaces == other.spaces
