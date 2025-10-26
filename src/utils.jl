function get_cols_permutations(curves::Vector{<:Curve})
    n = length(curves)
    cols_permutations = Vector{Int}[]
    groups = Dict{Int, Vector{Int}}()
    for (i, c) in enumerate(curves)
        push!(get!(groups, c.d, Int[]), i)

    end
    for permutable_idxs in values(groups)
        if length(permutable_idxs) < 2 
            continue 
        end 
        cols = [
            (idxs = collect(1:n); idxs[permutable_idxs] .= perm; idxs)
            for perm in permutations(permutable_idxs)
        ]
        append!(cols_permutations, cols)      
    end 
          
    return cols_permutations
end

function get_rows_permutations(singularities::Vector{<:Singularity})
    n = length(singularities)
    rows_permutations = Vector{Int}[]
    groups = Dict{String, Vector{Int}}()
    for (i, s) in enumerate(singularities)
        push!(get!(groups, s.name, Int[]), i)

    end
    for permutable_idxs in values(groups)
        if length(permutable_idxs) < 2 
            continue 
        end 
        rows = [
            (idxs = collect(1:n); idxs[permutable_idxs] .= perm; idxs)
            for perm in permutations(permutable_idxs)
        ]
        append!(rows_permutations, rows)      
    end 
          
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