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
    println("groups: $(groups)")
    recursive_permutation(collect(1:n), collect(values(groups)), rows_permutations, 1)              
    return rows_permutations
end

function max_sum_for_arr(curves::Vector{<:Curve})
    max_sum = zeros(length(curves))
        total_deg = sum(curve.d for curve in curves);
        for (idx,curve) in enumerate(curves)
            d = curve.d
            max_sum[idx] += d*(total_deg - d)            
        end
    return max_sum 
end

function is_valid_permutation(permutation, row)
    return permutation[row+1:end] == collect(row+1:length(permutation))
end