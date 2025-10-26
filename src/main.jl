using Combinatorics

include("types.jl")

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
    println("XDDDDDDDDDDDDDDDDDDDDDDDDDDD")
    n = length(singularities)
    rows_permutations = Vector{Int}[]
    groups = Dict{String, Vector{Int}}()
    printlnt(typeof(groups))
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
        append!(rows_permutations, cols)      
    end 
          
    return rows_permutations
end

function remove_repetitions(arr::Arrangement)
    cols_permutations = get_cols_permutations(arr.curves)
    println("is it working?")
    rows_permutations = get_rows_permutations(arr.singularities)    
    return cols_permutations, rows_permutations
end

function check_sums(M::Matrix{Int}, max_sum::Vector{Int})
    col_sums = sum(M, dims=1)             
    return all(col_sums .<= max_sum )
end

function recursive_fill(arr::Arrangement, row::Int)
    if row > length(arr.singularities)
        push!(arr.solutions, arr.M)
        return 
    end 

    M = arr.M
    num_curves = arr.singularities[row].n_c 
    all_curves = length(arr.curves)
    possibilities = collect(combinations(1:all_curves, num_curves))

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

function check_existance(arr::Arrangement)
    recursive_fill(arr, 1)
    println("miau: ", length(arr.solutions))

    for sol in arr.solutions
        draw_solution(arr, sol) 
        println()
    end 
end

curves = [Conic("Q₁"), Conic("Q₂"), Conic("Q₃"),Conic("Q₄")]    
singularites = [A(3), A(3), A(3), A(3), D(4), D(4), A(5), A(5), A(7)]

arr = Arrangement(curves, singularites)
arr.max_sum
check_existance(arr)
length(arr.solutions)

remove_repetitions(arr)

lol = [2,2,3,4,5]
c = [3,4,5,10,3]
all(lol.<c)

idxs = [1, 3, 4]

X = [1 2 3 4;
     1 2 3 4;
     1 2 3 4;
     1 2 3 4]

mats = []

permutable_idxs = [1,3,4]
n = 4
cols_permutations = [
    (idxs = collect(1:n); idxs[permutable_idxs] .= perm; idxs)
    for perm in permutations(permutable_idxs)
]


unique()