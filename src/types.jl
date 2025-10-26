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
    mult::Vector{Int}
    name::String 
end
A(k::Int) = A(k, 2, [(k + 1) ÷ 2, (k + 1) ÷ 2], "A" * string(k))

struct D <: Singularity
    k::Int
    n_c::Int
    mult::Vector{Pair{Int}}
    name::String
    function D(k::Int)
        n_c = 3
        name =  "D" * string(k) 
        if(k==2)
            mult = [Pair(3,2)]
        else 
            mult = [Pair(1,2), Pair(2, k ÷ 2)]
        end 
        return new(k,n_c,mult, name)
    end
end




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
        max_sum = max_sum_for_arr(curves)
        rows_permutations = get_rows_permutations(singularities)
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