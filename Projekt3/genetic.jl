import Base.@kwdef
using TSPLIB
using Random
include("heuristics.jl")
include("utilities.jl")
include("tabu.jl")

const RACE_SIZE = 10
const LADDER_SIZE = 8

@kwdef mutable struct Human
    name::String = ""
    solution::Vector{Int} = []
    objective::Float64 = 0.0
    age::Int = 0
    length::Float64 = 0.0
end

function new_human(tsp_data::TSP, start_algorithm::Function, _name::String, _age::Int, _length::Float64, aux_args...)
    _solution::Vector{Int} = start_algorithm(tsp_data, aux_args...)
    _objective::Float64 = objective_function(tsp_data,_solution)

    return Human(name = _name, solution = _solution, objective = _objective, age = _age, length = _length)
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
        println("|--> Lord number $(i):\t[Name: $(lord.name) || Length: $(lord.objective)]")
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
            println("|--> Jabroni number $(j):\t[Name: $(resident.name) || Length: $(resident.objective)]")
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

function crossing_one(father1::Vector{Int}, father2::Vector{Int})
    #kids::Vector{Vector{Int}} = []
    size::Int = length(father1)
    half_size::Int = div(size,2)
    probability = rand(MersenneTwister())
    sprout::Vector{Int} = zeros(Int, size)
    found::Vector{Int} = zeros(Int, size)
    i::Int = 1
    j::Int = 1
    while i <= half_size
        sprout[i] = father1[i]
        found[father1[i]] = 1
        i += 1
    end
    j = i
    while i <= size
        while found[father2[j]] != 0
            j += 1
            if j == size
                j = 1
            end
        end
        sprout[i] = father2[j]
        found[father2[j]] = 1
        j += 1
        if j == size
            j = 1
        end
        i += 1
    end
    return sprout
end

println(crossing_one([1,2,3,4,5,6,7,8,9,10], shuffle!([1,2,3,4,5,6,7,8,9,10])))
# simcity(readTSP("TSP/berlin52.tsp"))