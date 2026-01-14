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
    col_sums = vec(sum(M, dims=1))    
    return all(col_sums .<= max_sum )
end

#=
    Function for checking whether there already exist solution that is the same as found one.
=#
flag = false 
function repetition(arr::Arrangement,
                    solutions::Vector{Matrix{Int}}, 
                    M::Matrix{Int})::Bool 
    global flag
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

function possible_row_fills(arr::Arrangement, row::Int)::Vector{Tuple{Vector{Int}}}
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
                println("error size of a set is not enough")
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
counter = 0
counter2 = 0
counter3 = 0
function recursive_fill(arr::Arrangement, row::Int)
    global  counter 
    global counter2
    global counter3
    if row > length(arr.singularities)
        return 
    end 
    println("counter : ", counter)
    
    possibilities = possible_row_fills(arr, row)
    
    new_solutions = Matrix{Int}[]
    for M in arr.solutions
        for tuple_of_sets in possibilities
            M2 = vcat(copy(M), zeros(Int, 1, length(arr.curves)))
            for i in eachindex(tuple_of_sets)
                (quantity, multiplicity)  = arr.singularities[row].mult[i]
                M2[row, tuple_of_sets[i]] .= multiplicity 
            end
            if(!check_sums(M2, arr.max_sum))
                counter3+=1
                continue
            end 
            # if(!check_submatrices(M2,arr.curves, arr.singularities))
            #     counter3+=1
            #     println("odrzucone przez podmacierze! $counter3")
            #     for  wiersz in eachrow(M2)
            #         println(wiersz)
            #     end
            #     continue
            # end 
            if(!repetition(arr, new_solutions, M2))
                push!(new_solutions, M2)
                counter+=1
                println("new:  $counter, row: $row")
            else 
                counter2+=1
                println("not new: $counter2, row: $row")
            end 
        end
    end 
    arr.solutions = new_solutions 
    println("arr solutions length: $(length(arr.solutions))")
    recursive_fill(arr, row + 1)
end

#=
    Not working yet. Placeholder function for checking all proper arrangament-submatrices 
    of considered arrangement matrix.
=#

function print_check_submatrices(M, cols, col,  deleted_curve, max_sum)
    println("cols: $cols")
    println("now deleted col: $col")
    println("deleted curve: $deleted_curve")
    println("required sums: $max_sum")
    println("current M:")
    for row in eachrow(M)
        println(row)
    end 
end

function eliminate_col( M::Matrix{Int},
                        col::Int,
                        singularities::Vector{<:Singularity})
    M2 = copy(M)
    for (i,row) in enumerate(eachrow(M2))
        if(row[col] != 0)
            val = div(sum(row) - 2*row[col], singularities[i].n_c)
            row[col] = 0
            row[row.!=0] .= val 
        end
    end
    return M2
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
            cols in checked_submatrices && begin println("this was already checked: $cols") 
                                            continue end  
            push!(checked_submatrices, copy(cols))
            curves[i] = ZeroCurve() 
            M2 = eliminate_col(M,i, singularities)
            print_check_submatrices(M2, cols, i, deleted_curve, max_sum_for_arr(curves))

            check_sums(M2,max_sum_for_arr(curves)) || begin println("SUBMATRIX WRONG")
                                                            return false end 
            check_submatrices(M2, curves, singularities,cols, checked_submatrices, depth+1) || return false
        finally
            curves[i] = deleted_curve
            cols[i] = true
        end 
    end
    return true 
end

#=
    Main function finding all arrangement-matrices that satisfy
    incidency conditions.
=#
function check_existance(arr::Arrangement)
    global counter, counter2, counter3 
    counter = 0
    counter2 = 0 
    counter3 = 0 
    recursive_fill(arr, 1)
    println("test: ", length(arr.solutions))

    count_loc = 0
    for sol in arr.solutions
        count_loc += 1
        if count_loc % 10000 != 0
            continue 
        end
        draw_solution(arr, sol) 
        println()
    end 
end 
curves = Curve[Conic("Q₁"), Conic("Q₂"), Conic("Q₃"), Conic("Q₄")] 

singularities = [D(6)]
singularities = [A(1), A(3), A(5), D(4), D(6)]
singularities = [A(3), A(3), A(3), A(3), D(4), D(4), A(5),A(5), A(7)]

arr = Arrangement(curves, singularities)
check_existance(arr)

arr.max_sum
flag 

s = arr.cols_permutations
arr.rows_permutations
println(arr.solutions)

curves = [Line("L₁"), Line("L₂"), Line("L₃"), Conic("Q₁"), Conic("Q₂")]
singularities = [A(1), A(3), D(4), D(6), D(6)]
singularities = [A(1), A(3), D(4)]

arr.curves
counter = 0
counter3


arr.curves
arr.rows_permutations
arr.singularities
arr.cols_permutations


sol = arr.solutions

M = arr.solutions[15]
cols = [true for i=1:4]
dsa = check_submatrices(M, arr.curves, arr.singularities)

three_conics = Curve[Conic("Q1"), Conic("Q2"), Conic("Q3")]


four_conics = Curve[Conic("Q1"), Conic("Q2"), Conic("Q3"), Conic("Q4")]
d4_four = Singularity[D(4) for i=1:3]
a5_five = Singularity[A(5) for i=1:5]


singularities_test = Singularity[d4_four ; a5_five]
arr_test = Arrangement(four_conics, singularities_test)


arr_test.rows_permutations
check_existance(arr_test)
xM = []

weird = arr_test.solutions[1]

check_submatrices(weird, arr_test.curves, arr_test.singularities)