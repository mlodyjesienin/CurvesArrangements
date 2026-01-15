
#= 
    utility functions for checking large numbers of combinatorics
    or excluding arrangement based on  other conditions
=#

function check_all_combinatorics(orig_curves, mapping, combinatorics)
    result = Arrangement[]
    for combinatoric in combinatorics
        singularities = Singularity[]
        curves = copy(orig_curves)
        for (counter, (fn, args)) in zip(combinatoric, mapping)
            singularities = [singularities;fill(fn(args...), counter)]
        end 
        arr = Arrangement(curves, singularities)
        val = check_existance(arr)
        if(val)
            push!(result, deepcopy(arr))
        end 

    end 
    return result 
end

function number_of_intersections(incidence_matrix::Matrix{Int}, curve_index::Int)::Int 
    return count(!iszero, view(incidence_matrix, :, curve_index))
end 


function check_lines_intersections(arr::Arrangement)
    new_solutions = Matrix{Int}[]
    idxs = [i for (i,c) in enumerate(arr.curves) if c.d ==1] 
    for solution in arr.solutions
        if(all(i -> number_of_intersections(solution,i) == 3, idxs))
            push!(new_solutions, solution)
        end
    end
    arr.solutions = new_solutions
end 
