using Combinatorics

include("types.jl")
include("utils.jl")


#=
    Function for drawing the found solution matrix. 
=#
function draw_solution(arr::Arrangement, sol::Matrix{Int})
    col_headers = [c.name for c in arr.curves]
    row_headers = [s.name for s in arr.singularities]

    col_widths = [maximum(length.(col_headers)); fill(6, length(col_headers))...]

    for (j, col) in enumerate(col_headers)
        print(" ", rpad(col, col_widths[j+1]))
    end
    println()
    total_width = sum(col_widths) + length(col_headers)
    println("-"^total_width)

    for (i, rowname) in enumerate(row_headers)
        print(rpad(rowname, col_widths[1]))
        for j in 1:length(col_headers)
            print(" ", lpad(sol[i, j], col_widths[j+1]))
        end
        println()
    end
end

#=
    Checks if every column of arrangament-matrix has sum
    less or equal then specified maximal values. 
=#
function check_sums(M::Matrix{Int}, max_sum::Vector{Int})
    col_sums = sum(M, dims=1)             
    return all(col_sums .<= max_sum )
end

#=
    Function for checking whether there already exist solution that is the same as found one.
=#
function repetition(arr::Arrangement)
    M = copy(arr.M) 
    for cols_perm in arr.cols_permutations 
        for rows_perm in arr.rows_permutations
            if(M[rows_perm,cols_perm] in arr.solutions)
                return true 
            end 
        end 
    end 
    return false 
end

#=
    The main recursive function for filling the arrangament matrix row by row. 
=#
function recursive_fill(arr::Arrangement, row::Int)
    if row > length(arr.singularities)
        if !repetition(arr)
            push!(arr.solutions, copy(arr.M))
        end
        return 
    end 

    M = arr.M
    num_curves = arr.singularities[row].n_c 
    all_curves = length(arr.curves)
    possible_outcomes = [(set(),)]
    possibilities = collect(combinations(1:all_curves, num_curves))
    for (quantity, multiplicity) in arr.singularities[row].mult 
        for tuple_of_sets in possible_outcomes
            R = set(1:all_curves)
            for Σ in tuple_of_sets
                R = setminus(R, Σ)
            end
            if size(R) < quantity
                println("error size of a set is not enough")
                return 0 
            end 
            for p in collect(combinations(R,quantity))
                new_tuple = copy(tuple_of_sets)
                push!(new_tuple, p)
                new_possibile_outcomes = 
            end
        end
    end 
    for comb in possibilities
        M[row, :] .= 0
        M[row, comb] .= arr.singularities[row].mult

        if !check_sums(M, arr.max_sum)
            continue 
        end 

        recursive_fill(arr, row + 1)
    end

    M[row, :] .= 0
end

#=
    Not working yet. Placeholder function for checking all proper arrangament-submatrices 
    of considered arrangement matrix.
=#
function check_submatrices(cols::Vector{Int},
                           checked_submatrices::Set{Vector{Int}},
                           M::Matrix{Int}, 
                           curves::Vector{<:Curve}, 
                           singularities::Vector{<:Singularity})
    M = copy(M)    
end

#=
    Main function finding all arrangement-matrices that satisfy
    incidency conditions.
=#
function check_existance(arr::Arrangement)
    recursive_fill(arr, 1)
    println("miau: ", length(arr.solutions))

    for sol in arr.solutions
        draw_solution(arr, sol) 
        println()
    end 
end

curves = [Conic("Q₁"), Conic("Q₂"), Conic("Q₃"),Conic("Q₄")]    
singularities = [A(3), A(3), A(3), A(3), D(4), D(4), A(5), A(5), A(7)]

arr = Arrangement(curves, singularities)
check_existance(arr)

println(arr.solutions)
println("test!")


