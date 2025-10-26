abstract type Curve end
abstract type Singularity end

include("utils.jl")

struct Conic <: Curve
    name::String
    d::Int
end
Conic(name::String) = Conic(name, 2)

struct Line <: Curve 
    name::String 
    d::Int 
end 
Line(name::String) =Line(name, 1)
struct A <: Singularity
    k::Int
    n_c::Int
    mult::Int
    name::String 
end
A(k::Int) = A(k, 2, (k + 1) ÷ 2, "A" * string(k))

struct D <: Singularity
    k::Int
    n_c::Int
    mult::Int
    name::String
end
D(k::Int) = D(k, 3, 2, "D" * string(k))


struct Arrangement{T<:Curve, S<:Singularity}
    curves::Vector{T}
    singularities::Vector{S}
    M::Matrix{Int}
    solutions::Vector{Matrix{Int}}
    max_sum::Vector{Int}
    rows_permutations::Vector{Vector{Int}}
    cols_permutations::Vector{Vector{Int}}

    function Arrangement(curves::Vector{T}, singularities::Vector{S}) where {T<:Curve, S<:Singularity}
        n_sing = length(singularities)
        n_curv = length(curves)
        M = zeros(Int, n_sing, n_curv)
        solutions = Matrix{Int}[]
        max_sum = zeros(length(curves))
        total_deg = sum(curve.d for curve in curves);
        for (idx,curve) in enumerate(curves)
            d = curve.d
            max_sum[idx] += d*(total_deg - d)            
        end
        rows_permutations = get_rows_permutations(singularites)
        cols_permutations = get_cols_permutations(curves)
        return new{T,S}(curves, 
                        singularities, 
                        M, 
                        solutions, 
                        max_sum, 
                        rows_permutations, 
                        cols_permutations)
    end
end