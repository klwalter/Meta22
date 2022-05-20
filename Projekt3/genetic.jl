import Base.@kwdef
using TSPLIB
include("heuristics.jl")
include("utilities.jl")
include("tabu.jl")

const RACE_SIZE = 10

@kwdef mutable struct Human
    solution::Vector{Int} = []
    prd::Float64 = 0.0
    age::Int = 0
    length::Float64 = 0.0
end

function new_human(tsp_data::TSP, start_algorithm::Function, _age::Int, _length::Float64, aux_args...)
    _solution::Vector{Int} = start_algorithm(tsp_data, aux_args...)
    _solution_optimal = get_optimal(tsp_data.name)
    _prd = PRD(tsp_data, _solution, _solution_optimal[2])

    return Human(solution = _solution, prd = _prd, age = _age, length = _length)
end

function simcity(tsp_data::TSP)
    starting_population::Vector{Human} = []

    algorithms::Vector{Tuple{Function, Any}} = [(k_random, 1), (two_opt, 0), (tabu_search, k_random)]

    for (i, algorithm) in enumerate(algorithms)
        println(algorithm)
        for j in 1:RACE_SIZE
            push!(starting_population, new_human(tsp_data, algorithm[1], 10, 10.0, algorithm[2], 1))
            println("\nResident number $(((i - 1) * 10) + j): $(starting_population[((i - 1) * 10) + j])")
        end
    end
end

function fight_in_lockerroom(group::Vector{Human})

end

simcity(readTSP("TSP/berlin52.tsp"))