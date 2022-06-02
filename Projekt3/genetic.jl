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

#############################
# Divide into random groups #
#############################

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

##################################
# Wiadomo, nie trzeba komentarza #
##################################

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

###################
# Order Crossover #
###################

function crossing_one(father1::Vector{Int}, father2::Vector{Int})
    size::Int = length(father1)
    half_size::Int = div(size,2)
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

function breeding_chambers(father1::Vector{Int}, father2::Vector{Int}, crossing_algorithm::Function)
    kids::Vector{Vector{Int}} = []
    probability1::Float64, probability2::Float64 = rand(MersenneTwister(),2)
    sprout1 = crossing_algorithm(father1, father2)
    sprout2 = crossing_algorithm(father2, father1)
    if probability1 < 0.2
        mutation!(sprout1)
    end
    if probability2 < 0.2
        mutation!(sprout2)
    end
    append!(kids, sprout1)
    append!(kids, sprout2)
    return kids
end

function mutation!(sprout::Vector{Int})
    size::Int = length(sprout)
    i::Int = 0
    j::Int = 0
    while i != j
        i, j = rand(1:size,2)
    end
    sprout[:] = swap(i, j, sprout)
end

# println(crossing_one([1,2,3,4,5,6,7,8,9,10], shuffle!([1,2,3,4,5,6,7,8,9,10])))
# simcity(readTSP("TSP/berlin52.tsp"))
# function test()
#     a = [5,4,3,2,1]
#     test2(a)
#     println(a)
# end
# function test2(x)
#     x = swap(1,3,x)
# end
# test()