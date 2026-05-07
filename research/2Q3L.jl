#=
    File for testing the possible maximal arrangements of three conics and two lines 
=#
push!(LOAD_PATH, "../src")
using CurvesArrangements 

include("utils.jl")

orig_curves = [Conic("Q1"), Conic("Q2"), Line("L1"), Line("L2"), Line("L3")]

mapping = ((A, (1)), (D,(4)), (A,(3)), (A,(5)), (A,(7)), (D,(6)), (D,(8)))

vec = [(0,2,0,0,0,2,1),(0,2,2,0,0,1,1),(0,2,4,0,0,0,1),
(0,3,0,0,0,0,2),(0,3,1,1,0,0,1),(1,1,1,0,0,2,1),(1,1,3,0,0,1,1),(1,2,0,1,0,1,1),
(1,2,1,0,0,0,2),(1,2,2,1,0,0,1),(1,3,0,0,1,0,1),(2,0,0,0,0,3,1),(2,0,2,0,0,2,1),
(2,1,0,0,0,1,2),(2,1,1,1,0,1,1),(2,1,2,0,0,0,2),(2,2,0,2,0,0,1),(2,2,1,0,1,0,1),
(3,0,0,1,0,2,1),(3,0,1,0,0,1,2),(3,0,2,1,0,1,1),(3,0,3,0,0,0,2),(3,1,0,0,1,1,1),
(3,1,0,1,0,0,2),(3,1,1,2,0,0,1),(3,1,2,0,1,0,1),(4,0,0,0,0,0,3),(4,0,0,2,0,1,1),
(4,0,1,0,1,1,1),(4,0,1,1,0,0,2),(4,1,0,1,1,0,1),(5,0,0,0,1,0,2),(6,0,0,0,2,0,1)]

@time result = check_all_combinatorics(orig_curves,mapping,vec)

for possible in result
    println("possible combinatoric: ")
    for s in possible.singularities
        print("$s, ")
    end 
    println("number of possibilites: $(length(possible.solutions))")
end 


for possible in result 
    check_lines_intersections(possible)
end 
show_solutions(result[2])


result = [a for a in result if length(a.solutions )> 0]

show_solutions(result[1])