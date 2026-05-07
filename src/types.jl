using Combinatorics
abstract type Curve end
abstract type Singularity end
struct Conic <: Curve
    name::String
    d::Int
end
Conic(name::String) = Conic(name, 2)

struct ArbitraryCurve <: Curve 
    name::String 
    d:: Int 
end 
struct Line <: Curve 
    name::String 
    d::Int
end 
Line(name::String) = Line(name, 1)

struct ZeroCurve <: Curve 
    name::String 
    d::Int
end 
ZeroCurve() = ZeroCurve("", 0) 

Base.show(io::IO, c::Curve) =
    print(io, "$(typeof(c)) $(c.name)")

Base.show(io::IO, c::ArbitraryCurve) =
    print(io, "$(typeof(c)) of degree $(c.d)")

struct ArbitrarySingularity <: Singularity 
    mult::Vector{Pair{Int}}
    n_c::Int 
    name::String 
end

struct A <: Singularity
    k::Int
    mult::Vector{Pair{Int, Int}}
    n_c::Int 
    name::String 
end
A(k::Int) = A(k,[Pair(2,(k + 1) ÷ 2)], 2, "A" * string(k))

struct D <: Singularity
    k::Int
    mult::Vector{Pair{Int, Int}}
    n_c::Int
    name::String
    function D(k::Int)
        name =  "D" * string(k) 
        if(k==4)
            mult = [Pair(3,2)]
        else 
            mult = [Pair(1,2), Pair(2, k ÷ 2)]
        end 
        return new(k,mult,3,name)
    end
end

function Base.show(io::IO, d::Singularity)
    print(io, d.name)
end 

function recursive_permutation(permutation::Vector{Int}, permutable::Vector{Vector{Int}}, result::Vector{Vector{Int}}, idx::Int)
    if(idx > length(permutable))
        push!(result, permutation)
        return 
    end 

    for p in permutations(permutable[idx])
        p_new = copy(permutation)
        p_new[permutable[idx]] .= p  
        recursive_permutation(p_new, permutable, result, idx+1)
    end 
end

function get_cols_permutations(curves::Vector{<:Curve})
    n = length(curves)
    cols_permutations = Vector{Int}[]
    groups = Dict{Int, Vector{Int}}()
    for (i, c) in enumerate(curves)
        push!(get!(groups, c.d, Int[]), i)

    end
    recursive_permutation(collect(1:n), collect(values(groups)), cols_permutations, 1)              
   
    return cols_permutations
end

function get_rows_permutations(singularities::Vector{<:Singularity})
    n = length(singularities)
    rows_permutations = Vector{Int}[]
    groups = Dict{String, Vector{Int}}()
    for (i, s) in enumerate(singularities)
        push!(get!(groups, s.name, Int[]), i)
    end
    recursive_permutation(collect(1:n), collect(values(groups)), rows_permutations, 1)              
    return rows_permutations
end

function max_sum_for_arr(curves::Vector{<:Curve}) 
    max_sum = zeros(Int,length(curves))
        total_deg = sum(curve.d for curve in curves);
        for (idx,curve) in enumerate(curves)
            d = curve.d
            max_sum[idx] += d*(total_deg - d)            
        end
    return max_sum 
end

mutable struct Arrangement
    curves::Vector{Curve}
    singularities::Vector{Singularity}
    solutions::Vector{Matrix{Int}}
    max_sum::Vector{Int}
    rows_permutations::Vector{Vector{Int}}
    cols_permutations::Vector{Vector{Int}}

    function Arrangement(curves::AbstractVector{<:Curve}, 
                         singularities::AbstractVector{<:Singularity})        
        n_curv = length(curves)
        M = zeros(Int, 0, n_curv)
        solutions = Matrix{Int}[]
        push!(solutions, M)
        max_sum = max_sum_for_arr(curves)
        rows_permutations = get_rows_permutations(singularities)
        cols_permutations = get_cols_permutations(curves)
        return new( collect(Curve,curves), 
                    collect(Singularity,singularities), 
                    solutions, 
                    max_sum, 
                    rows_permutations, 
                    cols_permutations)
    end
end

function Base.show(io::IO, arr::Arrangement)
    println(io, "Arrangement of ")
    for curve in arr.curves 
        print(io,curve,", ")
    end 
    print(io, "\n")
    println(io, "with singularities")
    for singularity in arr.singularities[begin:end-1]
        print(io,singularity,", ")
    end 
    print(io, arr.singularities[end],".")
end 
