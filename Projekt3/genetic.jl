import Base.@kwdef
using TSPLIB
using Random
using TimesDates
include("heuristics.jl")
include("utilities.jl")
include("tabu.jl")

const RACE_SIZE = 10
const LADDER_SIZE = 8

###################
# Human structure #
###################

@kwdef mutable struct Human
    solution::Vector{Int} = []
    objective::Float64 = 0.0
    age::Int = 0
end

function new_human(tsp_data::TSP, start_algorithm::Function, _age::Int, aux_args...)
    _solution::Vector{Int} = start_algorithm(tsp_data, aux_args...)
    _objective::Float64 = objective_function(tsp_data,_solution)

    return Human(solution = _solution, objective = _objective, age = _age)
end

##############
# Simulation #
##############

function simcity(tsp_data::TSP)
    ladders::Vector{Vector{Human}} = []
    lords::Vector{Human} = []
    generation::Vector{Human} = []
    best_solution::Vector{Int} = 1:tsp_data.dimension                                         
    best_dist::Float64 = objective_function(tsp_data, best_solution)
    counter::Int = 1
    opt::Tuple{Bool, Float64} = get_optimal(tsp_data.name)
    ###################
    # Stop conditions #
    ###################

    time_start::DateTime = Dates.now()
    time_limit::Second = Second(120)
    time_elapsed::Millisecond = Second(0)

    generation = spawn_jabronis(tsp_data)

    ######################################
    # Find best from starting population #
    ######################################

    for human in generation
        if human.objective < best_dist
            best_dist = human.objective
            best_solution = human.solution 
        end
    end

    #############
    # Main loop #
    #############

    while true
        time_elapsed = Dates.now() - time_start
        if time_elapsed > time_limit
            return best_solution
        end
        size::Int = 0
        ladders = elections(generation, LADDER_SIZE)
    
        for subgroup in ladders
            lord = fight_in_the_lockerroom(subgroup)
            push!(lords, lord)
        end

        size = length(lords)
        j::Int = 1
        while j < size
            kids::Vector{Vector{Int}} = breeding_chambers(lords[j].solution, lords[j+1].solution, crossing_one)
            time_elapsed = Dates.now() - time_start
            if time_elapsed > time_limit
                return best_solution
            end
            for kid in kids
                temp_human = Human()
                temp_human.solution = kid
                temp_human.objective = objective_function(tsp_data, kid)
                if temp_human.objective < best_dist
                    best_dist = temp_human.objective
                    best_solution = temp_human.solution

                    if opt[1] == true
                        prd::Float64 = PRD(tsp_data, best_solution, opt[2])                        
                        println("Generation number: $counter, solution: $best_solution, distance: $best_dist, prd: $prd%")
                    else
                        println("Generation number: $counter, solution: $best_solution, distance: $best_dist")
                    end 
                end
                push!(generation, temp_human)
            end
            j += 2
        end
        for aniki in generation 
            aniki.age += 1
        end
        generation = filter!(x -> x.age < 5, generation)
        counter += 1
    end
    
    return best_solution
    # println("\n\t\t   +--------------------------+")
    # println("\t\t   | Lords of the lockerrooms |")
    # println("\t\t   +--------------------------+\n")
    # for (i, lord) in enumerate(lords)
    #     println("|--> Lord number $(i):\t[Name: $(lord.name) || Length: $(lord.objective)]")
    # end
end

#########################
# Generating Population #
#########################

function spawn_jabronis(tsp_data::TSP)
    population::Vector{Human} = []
    algorithms::Vector{Tuple{Function, Any}} = [(k_random, 1), (two_opt, 0), (tabu_search, k_random)]

    for (i, algorithm) in enumerate(algorithms)
        println(algorithm)
        for j in 1:RACE_SIZE
            push!(population, new_human(tsp_data, algorithm[1], 10, algorithm[2], 1))
        end
    end
    
    return population
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

    # for (i, subgroup) in enumerate(subgroups)
    #     println("\n>> Group number $(i) <<")
    #     for (j, resident) in enumerate(subgroup)
    #         println("|--> Jabroni number $(j):\t[Name: $(resident.name) || Length: $(resident.objective)]")
    #     end
    # end

    return subgroups
end

##################################
# Wiadomo, nie trzeba komentarza #
##################################

function fight_in_the_lockerroom(group::Vector{Human})
    lord::Human = group[1]
    best::Float64 = lord.objective

    for resident in group
        if resident.objective < best
            best = resident.objective
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
            if j == size
                j = 0
            end
            j += 1
        end
        sprout[i] = father2[j]
        found[father2[j]] = 1
        if j == size
            j = 0
        end
        j += 1
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
    push!(kids, sprout1)
    push!(kids, sprout2)
    return kids
end

function mutation!(sprout::Vector{Int})
    size::Int = length(sprout)
    i::Int = 1
    j::Int = 1
    while i == j
        i, j = rand(1:size,2)
    end
    sprout[:] = swap(i, j, sprout)
end

# println(crossing_one([1,2,3,4,5,6,7,8,9,10], shuffle!([1,2,3,4,5,6,7,8,9,10])))
# simcity(readTSP("TSP/berlin52.tsp"))
function test()
    a::Vector{Int} = 1:10

    println(a)
end
function test2(x)
    x = swap(1,3,x)
end
test()