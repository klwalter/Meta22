import Base.@kwdef
using TSPLIB
include("heuristics.jl")
include("utilities.jl")
include("tabu.jl")

@kwdef mutable struct Human
    solution::Vector{Int}
    prd::Float64
    age::Int
    length::Float64
end

function new_human(tsp_data::TSP, start_algorithm::Function, _age::Int, _length::Float64, aux_args...)
    _solution::Vector{Int} = start_algorithm(tsp_data, aux_args...)
    _solution_optimal = get_optimal(tsp_data.name)
    _prd = PRD(tsp_data, _solution, _solution_optimal[2])

    return Human(solution = _solution, prd = _prd, age = _age, length = _length)
end

function simcity()
    tsp = readTSP("TSP/berlin52.tsp")
    latino = new_human(tsp, tabu_search, 10, 10.0, extended_neighbour)
    println("Latino solution: $(latino.solution)\nLatino PRD: $(latino.prd)\n")
end

simcity()