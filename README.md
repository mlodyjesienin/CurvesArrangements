# CurvesArrangements

Computation of Pair Incidence Matrices (PIMs) for arrangements of smooth plane curves.

## Usage

```julia
push!(LOAD_PATH, "./src")
using CurvesArrangements

curves = [Conic("Q1"), Conic("Q2"), Line("L1"), Line("L2"), Line("L3")]
singularities = Singularity[A(1), D(4), A(3), D(6), D(6), D(8)]

arr = Arrangement(curves, singularities)

check_existance(arr)
show_solutions(arr)
```

## Using Arbitrary Curves and Singularities

`Conic` and `Line` are currently implemented as separate types. However, the package also supports smooth curves of arbitrary degree provided by the user.

The `ArbitraryCurve` structure is defined as follows:

```julia
struct ArbitraryCurve <: Curve
    name::String
    d::Int   # degree
end
```

Example usage:

```julia
curves = [ArbitraryCurve("C", 3), Line("L")]
singularities = [A(3), A(1)]

arr = Arrangement(curves, singularities)

check_existance(arr)
show_solutions(arr)
```

> [!NOTE]
> Throughout this package, singularity types follow the Arnold classification (see [this reference](https://www.singular.uni-kl.de/zca/Reports_on_ca/29/paper_html/node10.html)).

The package currently provides predefined singularity types of the form $A_{2k-1}$ and $D_{2k}$ for $k > 0$.

We additionally provide the `ArbitrarySingularity` structure:

```julia
struct ArbitrarySingularity <: Singularity
    mult::Vector{Pair{Int}}
    n_c::Int
    name::String
end
```

In this package, a singularity type is determined by:
- the number of curves intersecting at the singular point,
- and, for each curve, the intersection multiplicity with the union of the remaining curves at that point.

The `n_c` field specifies the number of intersecting curves, while `mult` encodes the multiplicity data in the following format:

- each pair is of the form `(n, m)`,
- where `n` is the number of curves having intersection multiplicity `m`.

For example, consider the $J_{2,0}$ singularity. For arrangements of smooth curves, it can be viewed as the intersection point of three curves $C_1, C_2, C_3$, where each curve is tangent to the other two. In particular, $I(C_1, C_2 \cup C_3) = I(C_2, C_1 \cup C_3) = I(C_3, C_1 \cup C_2) = 4$.

Therefore, in this case:

```julia
mult = [Pair(3, 4)]
```

Minimal working example:

```julia
curves = [Conic("Q1"), Conic("Q2"), Conic("Q3")]

J₂₀ = ArbitrarySingularity([Pair(3, 4)], 3, "J₂₀")

singularities = [A(3), A(3), A(3), J₂₀]

arr = Arrangement(curves, singularities)

check_existance(arr)
show_solutions(arr)
```

## Development

Run any Julia script inside the project environment with:

```shell
julia --project=. script_name.jl
```
