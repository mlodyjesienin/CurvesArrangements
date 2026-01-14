push!(LOAD_PATH, "./src")
using CurvesArrangements 

curves = Curve[Conic("Q1"), Conic("Q2"), Conic("Q3"), Conic("Q4")]
singularities = Singularity[ A(3), A(3), A(3), A(3), A(3), D(4), D(4), A(7), A(7)]
arr = Arrangement(curves, singularities)
check_existance(arr)