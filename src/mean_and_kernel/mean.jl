import Base: +, *
export CustomMean, ZeroMean, OneMean, ConstantMean, FiniteMean

"""
    MeanFunction
"""
abstract type MeanFunction end

# Default finite-ness condition.
isfinite(::MeanFunction) = false
length(μ::MeanFunction) = isfinite(μ) ? length(μ) : Inf

"""
    CustomMean <: MeanFunction

A user-defined mean function. `f` should be defined such that when applied to a `N x D`
(`Abstract`)`Matrix`, an `N`-`AbstractVector` is returned.
"""
struct CustomMean <: MeanFunction
    f
end
(μ::CustomMean)(x::Real) = mean(μ, fill(x, 1, 1))[1]
(μ::CustomMean)(x) = mean(μ, reshape(x, 1, length(x)))
mean(μ::CustomMean, X::AM) = μ.f(X)

"""
    ZeroMean <: MeanFunction

Returns zero (of the appropriate type) everywhere.
"""
struct ZeroMean{T<:Real} <: MeanFunction end
(::ZeroMean{T})(x) where T = zero(T)
mean(::ZeroMean{T}, X::AM) where T = zeros(T, size(X, 1))
==(::ZeroMean{<:Any}, ::ZeroMean{<:Any}) = true

"""
    ConstantMean{T} <: MeanFunction

Returns `c` (of the appropriate type) everywhere.
"""
struct ConstantMean{T<:Real} <: MeanFunction
    c::T
end
(μ::ConstantMean)(x) = μ.c
mean(μ::ConstantMean, X::AM) = fill(μ.c, size(X, 1))
==(μ::ConstantMean{<:Any}, μ′::ConstantMean{<:Any}) = μ.c == μ′.c 

# # Define composite mean functions.
# struct CompositeMean{O, T<:Tuple{Any, N} where N} <: μFun
#     args::T
# end

# +(μ::μFun, x′::Real) = μ + ConstantMean(x′)
# +(x::Real, μ′::μFun) = ConstantMean(x) + μ′
# +(μ::T, μ′::T′) where {T<:μFun, T′<:μFun} = CompositeMean{+, Tuple{T, T′}}((μ, μ′))
# (c::CompositeMean{+})(x) = c.args[1](x) + c.args[2](x)

# *(μ::μFun, x′::Real) = μ * ConstantMean(x′)
# *(x::Real, μ′::μFun) = ConstantMean(x) * μ′
# *(μ::T, μ′::T′) where {T<:μFun, T′<:μFun} = CompositeMean{*, Tuple{T, T′}}((μ, μ′))
# (c::CompositeMean{*})(x) = c.args[1](x) * c.args[2](x)
