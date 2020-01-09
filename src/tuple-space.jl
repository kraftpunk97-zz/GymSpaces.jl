"""
A tuple (i.e., product) of simpler spaces

Example usage:
tuple_obj.observation_space = spaces.Tuple((spaces.Discrete(2), spaces.Discrete(3)))
"""
mutable struct TupleSpace <: AbstractSpace
    spaces::NTuple{N, AbstractSpace} where N
    shape::Int
    TupleSpace(space_array::NTuple{N, AbstractSpace}) where N = new(space_array, length(space_array))
    TupleSpace(space_array::Array{<:AbstractSpace, 1}) = new(Tuple(space_array), length(space_array))
end

sample(tuple_obj::TupleSpace) = Tuple(sample(space) for space in tuple_obj.spaces)

function contains(x, tuple_obj::TupleSpace)
    if isa(x, Array)
        x = Tuple(x)
    end
    return isa(x, Tuple) && Base.length(x) == Base.length(tuple_obj.spaces) &&
        all(part ∈ space for (space, part) in zip(tuple_obj.spaces, x))
end

Base.length(tuple_obj::TupleSpace) = length(tuple_obj.spaces)

Base.:(==)(tuple_obj::TupleSpace, other::TupleSpace) = tuple_obj.spaces == other.spaces
# Base.getindex(::Box, index...)

"""
    seed!(tuple_obj::TupleSpace, seeds...)

Manually set the seed to the assigned values.

# Example

julia> space = TupleSpace([Discrete(5), Discrete(10)])
.
.
.

julia> seed!(space, 42, 87) # Since there are only two spaces in the TupleSpace

julia> sample(space)
(4, 5)
"""
function seed!(tuple_obj::TupleSpace, seeds...)
    for (space, seed) in zip(tuple_obj.spaces, seeds)
        seed!(space, seed)
    end
end
