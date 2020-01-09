
mutable struct MultiBinary <: AbstractSpace
    n::Int
    shape::Tuple
    seed::MersenneTwister
    MultiBinary(n::Integer; seed::Int=42) = new(n, (n, ), MersenneTwister(seed))
end

sample(multibin_obj::MultiBinary) = rand(multibin_obj.seed, 0:1, multibin_obj.n)

contains(x, multibin_obj::MultiBinary) = all((x .== 0) .| (x .== 1))

Base.:(==)(multibin_obj::MultiBinary, other::MultiBinary) = multibin_obj.n == other.n
