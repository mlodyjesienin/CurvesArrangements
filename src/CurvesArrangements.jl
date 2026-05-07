module CurvesArrangements

include("types.jl")

export Curve, ArbitraryCurve, ZeroCurve, Line, Conic, Singularity, ArbitrarySingularity, Arrangement,A, D, check_existance, 
    show_solutions, check_submatrices

#=
    Function for drawing the found solution matrix. 
=#
function draw_solution(arr::Arrangement, sol::Matrix{Int})
    col_headers = [c.name for c in arr.curves]
    row_headers = [s.name for s in arr.singularities]

    row_width = maximum(length.(row_headers))
    col_widths = fill(maximum(length.(col_headers)), length(col_headers))

    print(rpad("", row_width))
    for (j, col) in enumerate(col_headers)
        print(" ", rpad(col, col_widths[j]))
    end
    println()

    total_width = row_width + sum(col_widths) + length(col_headers)
    println("-"^total_width)

    for (i, rowname) in enumerate(row_headers)
        print(rpad(rowname, row_width))
        for j in eachindex(col_headers)
            print(" ", lpad(sol[i, j], col_widths[j]))
        end
        println()
    end
end

function show_solutions(arr::Arrangement)
    for sol in arr.solutions
        draw_solution(arr, sol)
        println()
    end 
end

#=
    Checks if every column of arrangament-matrix has sum
    less or equal then specified maximal values. 
=#
function check_sums(M::Matrix{Int}, max_sum::Vector{Int})
    col_sums = vec(sum(M, dims=1))    
    return all(col_sums .<= max_sum )
end


function is_valid_permutation(permutation, row)
    return permutation[row+1:end] == collect(row+1:length(permutation))
end
#=
    Function for checking whether there already exist solution that is the same as found one.
=#
function repetition(arr::Arrangement,
                    solutions::Vector{Matrix{Int}}, 
                    M::Matrix{Int})::Bool 
    rows = size(M)[1]
    for cols_perm in arr.cols_permutations 
        for rows_perm in arr.rows_permutations
            if(is_valid_permutation(rows_perm, rows))
                if(M[rows_perm[1:rows],cols_perm] in solutions)
                    return true 
                end 
            end 
        end 
    end 
    return false 
end

function possible_row_fills(arr::Arrangement, row::Int) #::Vector{Tuple{Vector{Int}}}
    all_curves = length(arr.curves)
    possible_outcomes = [()]
    for (quantity, multiplicity) in arr.singularities[row].mult
        new_possibile_outcomes = []
        for tuple_of_sets in possible_outcomes
            R = Set(1:all_curves)
            for Σ in tuple_of_sets
                R = setdiff(R, Σ)
            end
            if length(R) < quantity
                @error "Number of curves is too low."
                return 0 
            end 
            for p in combinations(collect(R),quantity)
                new_tuple = (tuple_of_sets...,p)
                push!(new_possibile_outcomes, new_tuple)
            end
        end
        possible_outcomes = new_possibile_outcomes
    end
    return possible_outcomes
end

#=
    The main recursive function for filling the arrangament matrix row by row. 
=#
function recursive_fill(arr::Arrangement, row::Int)
    if row > length(arr.singularities)
        return 
    end 
    
    @info "Processing row $row of $(length(arr.singularities)). 
            Considered possibilities: $(length(arr.solutions))"
    possibilities = possible_row_fills(arr, row)
    
    new_solutions = Matrix{Int}[]
    for M in arr.solutions
        for tuple_of_sets in possibilities
            M2 = vcat(copy(M), zeros(Int, 1, length(arr.curves)))
            for i in eachindex(tuple_of_sets)
                (quantity, multiplicity)  = arr.singularities[row].mult[i]
                M2[row, tuple_of_sets[i]] .= multiplicity 
            end
            check_sums(M2, arr.max_sum) || continue
            check_submatrices(M2, arr.curves, arr.singularities) || continue
            repetition(arr, new_solutions, M2) && continue
            push!(new_solutions, M2)
        end
    end 
    arr.solutions = new_solutions 
    recursive_fill(arr, row + 1)
end

#=
    Function for checking all proper arrangament-submatrices 
    of considered arrangement matrix.
=#

function eliminate_col( M::Matrix{Int},
                        col::Int,
                        singularities::Vector{<:Singularity})
    M2 = copy(M)
    for (i,row) in enumerate(eachrow(M2))
        if(row[col] != 0)
            val = div(sum(row) - 2*row[col], 2)
            row[col] = 0
            row[row.!=0] .= val 
        end
    end
    return M2
end

function print_subm(M, cols, curves)
    println("currently processed cols: $cols")
    for row in eachrow(M)
        println(row)
    end 
    sums = max_sum_for_arr(curves)
    a = check_sums(M, sums)
    println("sums: $(sums), check: $a")
end 

check_submatrices(M, curves, singularities) = check_submatrices(M,
                                                                curves,
                                                                singularities,
                                                                fill(true, length(curves)),
                                                                Set{Vector{Bool}}(),
                                                                0)
function check_submatrices(M::Matrix{Int}, 
                           curves::Vector{<:Curve}, 
                           singularities::Vector{<:Singularity},
                           cols::Vector{Bool},
                           checked_submatrices::Set{Vector{Bool}},
                           depth::Int)::Bool
    depth >= length(cols) - 2 && return true 

    for i in eachindex(cols)
        cols[i] || continue
        cols[i] = false 
        deleted_curve = curves[i]
        try 
            cols in checked_submatrices && continue
            push!(checked_submatrices, copy(cols))
            curves[i] = ZeroCurve() 
            M2 = eliminate_col(M,i, singularities)
            check_sums(M2,max_sum_for_arr(curves)) || return false 
            check_submatrices(M2, curves, singularities,cols, checked_submatrices, depth+1) || return false
        finally
            curves[i] = deleted_curve
            cols[i] = true
        end 
    end
    return true 
end

function combinatorics_coeff(s::Singularity)::Int 
    div(sum(p -> p.first * p.second, s.mult),2)
end

function naive_combinatorics(arr::Arrangement)::Bool
    lhs = sum(s -> combinatorics_coeff(s), arr.singularities)
    rhs = sum(m -> m[1].d*m[2].d, combinations(arr.curves,2))
    if(rhs != lhs)
        @error "Naive combinatorics does not hold. 
        The sum of intersection numbers is $lhs, 
        expected sum from Bezout's theorem is $rhs"
        return false
    end 
    @info "Naive combinatorics for arrangament holds."
    return true 
end
#=
    Main function finding all arrangement-matrices that satisfy
    incidency conditions.
=#
function check_existance(arr::Arrangement)::Bool
    @info "Checking existance of incidency matrices of $arr..."
    naive_combinatorics(arr) || return false 
    recursive_fill(arr, 1)
    @info """
    Found $(length(arr.solutions)) different incidence matrices up to permutations.

    To print solutions, run:
    show_solutions(arr)
    """
    return length(arr.solutions) > 0
end 
end #CurvesArrangements