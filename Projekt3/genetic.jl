import Base.@kwdef
using TSPLIB
include("heuristics.jl")
include("utilities.jl")
include("tabu.jl")

const RACE_SIZE = 10
const LADDER_SIZE = 8

@kwdef mutable struct Human
    name::String = ""
    solution::Vector{Int} = []
    prd::Float64 = 0.0
    age::Int = 0
    length::Float64 = 0.0
end

function new_human(tsp_data::TSP, start_algorithm::Function, _name::String, _age::Int, _length::Float64, aux_args...)
    _solution::Vector{Int} = start_algorithm(tsp_data, aux_args...)
    _solution_optimal::Vector{Float64} = get_optimal(tsp_data.name)
    _prd::Float64 = PRD(tsp_data, _solution, _solution_optimal[2])

    return Human(name = _name, solution = _solution, prd = _prd, age = _age, length = _length)
end

function simcity(tsp_data::TSP)
    starting_population::Vector{Human} = []
    algorithms::Vector{Tuple{Function, Any}} = [(k_random, 1), (two_opt, 0), (tabu_search, k_random)]
    ladders::Vector{Vector{Human}} = []
    lords::Vector{Human} = []

    for (i, algorithm) in enumerate(algorithms)
        println(algorithm)
        for j in 1:RACE_SIZE
            push!(starting_population, new_human(tsp_data, algorithm[1], "$(algorithm[1])$(j)", 10, 21.37, algorithm[2], 1))
        end
    end

    ladders = elections(starting_population, LADDER_SIZE)

    for subgroup in ladders
        lord = fight_in_the_lockerroom(subgroup)
        push!(lords, lord)
    end

    println("\n\t\t   +--------------------------+")
    println("\t\t   | Lords of the lockerrooms |")
    println("\t\t   +--------------------------+\n")
    for (i, lord) in enumerate(lords)
        println("|--> Lord number $(i):\t[Name: $(lord.name) || PRD: $(lord.prd)]")
    end
end

function elections(group::Vector{Human}, subgroups_size::Int)
    group_copy::Vector{Human} = copy(group)
    group_length::Int = length(group_copy)

    subgroups_count::Int = ceil(group_length / subgroups_size)
    subgroups::Vector{Vector{Human}} = []
    slice::Vector{Human} = []

    shuffle!(group_copy)
    println("SUBGROUP SIZE: $(subgroups_size)")
    println("SUBGROUP COUNT: $(subgroups_count)")

    for i in 1:subgroups_count
        slice = group_copy[((i - 1) * subgroups_size + 1) : min((i * subgroups_size), group_length)]
        push!(subgroups, slice)
    end

    for (i, subgroup) in enumerate(subgroups)
        println("\n>> Group number $(i) <<")
        for (j, resident) in enumerate(subgroup)
            println("|--> Jabroni number $(j):\t[Name: $(resident.name) || PRD: $(resident.prd)]")
        end
    end

    return subgroups
end

function fight_in_the_lockerroom(group::Vector{Human})
    lord::Human = group[1]
    best::Float64 = lord.prd

    for resident in group
        if resident.prd < best
            best = resident.prd
            lord = resident
        end
    end

    return lord
end

simcity(readTSP("TSP/berlin52.tsp"))