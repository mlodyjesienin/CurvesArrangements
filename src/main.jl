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
flag = false 
function repetition(solutions::Vector{Matrix{Int}}, M::Matrix{Int})
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

#=
    The main recursive function for filling the arrangament matrix row by row. 
=#
counter = 0
counter2 = 0
function recursive_fill(arr::Arrangement, row::Int)
    global  counter 
    global counter2
    if row > length(arr.singularities)
        return 
    end 
    println("counter : ", counter)

    num_curves = arr.singularities[row].n_c 
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

    new_solutions = Matrix{Int}[]
    for M in arr.solutions
        for tuple_of_sets in possible_outcomes
            M2 = vcat(copy(M), zeros(Int, 1, all_curves))
            for i in eachindex(tuple_of_sets)
                (quantity, multiplicity)  = arr.singularities[row].mult[i]
                M2[row, tuple_of_sets[i]] .= multiplicity 
            end
            if(!repetition(new_solutions, M2))
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
    println("test: ", length(arr.solutions))

    count = 0
    for sol in arr.solutions
        count += 1
        if count % 10000 != 0
            continue 
        end
        draw_solution(arr, sol) 
        println()
    end 
end 
curves = [Conic("Q₁"), Conic("Q₂"), Conic("Q₃"), Conic("Q₄")] 

singularities = [D(6)]
singularities = [A(1), A(3), A(5), D(4), D(6)]
singularities = [A(3), A(3), A(3), A(3), D(4), D(4), A(5),A(5), A(7)]

arr = Arrangement(curves, singularities)
check_existance(arr)

flag 

s = arr.cols_permutations
arr.rows_permutations
println(arr.solutions)

curves = [Line("L₁"), Line("L₂"), Line("L₃"), Conic("Q₁"), Conic("Q₂")]
singularities = [A(1), A(3), D(4), D(6), D(6)]
singularities = [A(1), A(3), D(4)]


counter = 0
counter 


arr.curves
arr.rows_permutations
arr.singularities
arr.cols_permutations



M = [1 2 3 ; 3 4 5;]


size(M)[1]


sol = arr.solutions

counter = 0
for (i,M) in enumerate(sol)
    sol2 = copy(sol)
    deleteat!(sol2,i)
    t = repetition(sol2,M)
    if(t)
        counter+=1
        println(M)
    end 
end
counter = 2 
counter +1 


arr.solutions[1]