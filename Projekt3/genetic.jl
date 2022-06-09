import Base.@kwdef
using TSPLIB
using Random
using TimesDates
include("heuristics.jl")
include("utilities.jl")
include("tabu.jl")

###################
# Human structure #
###################

@kwdef mutable struct Human
    solution::Vector{Int} = []
    objective::Float64 = 0.0
    # age::Int = 0
end

function new_human(tsp_data::TSP, start_algorithm::Function, aux_args...)
    _solution::Vector{Int} = start_algorithm(tsp_data, aux_args...)
    _objective::Float64 = objective_function(tsp_data,_solution)

    return Human(solution = _solution, objective = _objective)
end

##############
# Simulation #
##############
#
# Dodać argumenty pozwalające na zmiane: populacji początkowej, rodzaju mutacji, czasu działania algorytmu, rodzaju krzyżowania, 
# wielkość populacji (potencjalnie), czas stagnaji
# Może poprawić radzenie sobie ze stagnacją. Możemy pomyśleć o elitryzmie
#
function simcity(tsp_data::TSP)
    ladders::Vector{Vector{Human}} = []
    lords::Vector{Human} = []
    generation::Vector{Human} = []
    best_solution::Vector{Int} = 1:tsp_data.dimension                                         
    best_dist::Float64 = objective_function(tsp_data, best_solution)
    counter::Int = 1
    opt::Tuple{Bool, Float64} = get_optimal(tsp_data.name)
    group_size::Int = floor(sqrt(tsp_data.dimension)) * 10
    population_size::Int = group_size * group_size

    generation = nearest_neighbour_population(tsp_data, population_size)
    # gensize::Int= length(generation)
    # println("Size of generation: $gensize")

    ######################################
    # Find best from starting population #
    ######################################

    for human in generation
        if human.objective < best_dist
            best_dist = human.objective
            best_solution = human.solution 
        end
    end

    if opt[1] == true
        prd::Float64 = PRD(tsp_data, best_solution, opt[2])                        
        println("Solution: $best_solution\nGeneration number: $counter\nDistance: $best_dist\nPrd: $prd%")
        if prd == 0.0
            println("Number of last generation: $counter")
            return best_solution
        end
    else
        println("Solution: $best_solution\nGeneration number: $counter\nDistance: $best_dist\n")
    end


    ########################
    # Detecting Stagnation #
    ########################

    stagnation_time_start::DateTime = Dates.now()
    stagnation_time_limit::Second = Second(10)
    stagnation_time_elapsed::Millisecond = Second(0)

    ###################
    # Stop conditions #
    ###################

    time_start::DateTime = Dates.now()
    time_limit::Second = Second(500)
    time_elapsed::Millisecond = Second(0)


    #############
    # Main loop #
    #############
    while true
        counter += 1
        lords = []
        time_elapsed = Dates.now() - time_start
        if time_elapsed > time_limit
            return best_solution
        end
        size::Int = 0
        # ladders = tournament(generation, group_size)
    
        # for subgroup in ladders
        #     lord = fight_in_the_lockerroom(subgroup)
        #     push!(lords, lord)
        # end
        lords = tournament(generation, group_size)
        generation = []
        size = length(lords)

        kids::Vector{Vector{Int}} = []
        for a in 1:size-1, b in a+1:size
            kids = [kids; crossover(lords[a].solution, lords[b].solution, ox)]
            time_elapsed = Dates.now() - time_start
            stagnation_time_elapsed = Dates.now() - stagnation_time_start
            if time_elapsed > time_limit
                println("Number of last generation: $counter")
                return best_solution
            end
        end
        for kid in kids
            temp_human = Human()
            temp_human.solution = kid
            temp_human.objective = objective_function(tsp_data, kid)
            time_elapsed = Dates.now() - time_start
            stagnation_time_elapsed = Dates.now() - stagnation_time_start
            if time_elapsed > time_limit
                println("Number of last generation: $counter")
                return best_solution
            end
            if temp_human.objective < best_dist
                best_dist = temp_human.objective
                best_solution = temp_human.solution
                stagnation_time_elapsed = Second(0)
                stagnation_time_start = Dates.now()
                if opt[1] == true
                    prd = PRD(tsp_data, best_solution, opt[2])                        
                    println("Solution: $best_solution\nGeneration number: $counter\nDistance: $best_dist\nPrd: $prd%")
                    if prd == 0.0
                        println("Number of last generation: $counter")
                        return best_solution
                    end
                else
                    println("Solution: $best_solution\nGeneration number: $counter\nDistance: $best_dist\n")
                end 
            end
            push!(generation, temp_human)
        end

        if stagnation_time_elapsed > stagnation_time_limit
            for human in generation
                mutation!(human.solution)
                human.objective = objective_function(tsp_data, human.solution)
            end
            println("Steve Rambo")
            stagnation_time_elapsed = Second(0)
            stagnation_time_start = Dates.now()
        end

        generation = [generation; lords]
    end
end

#########################
# Generating Population #
#########################

function nearest_neighbour_population(tsp_data::TSP, population_size::Int)
    population::Vector{Human} = []
    for i in 1:tsp_data.dimension
        push!(population, new_human(tsp_data, nearest_neighbour, i))
    end
    for _ in tsp_data.dimension+1:population_size
        push!(population, new_human(tsp_data, k_random, 1))
    end
    return population
end

function two_opt_population(tsp_data::TSP, population_size::Int)
    population::Vector{Human} = []
    for i in 1:tsp_data.dimension
        push!(population, new_human(tsp_data, two_opt))
    end
    for _ in tsp_data.dimension+1:population_size
        push!(population, new_human(tsp_data, k_random, 1))
    end
    return population
end

function random_population(tsp_data::TSP, population_size::Int)
    return [new_human(tsp_data, k_random, 1) for _ in 1:population_size]
end
########################
# Selection algorithms #
########################

function tournament(group::Vector{Human}, subgroups_size::Int)
    group_copy::Vector{Human} = copy(group)
    group_length::Int = length(group_copy)

    subgroups_count::Int = ceil(group_length / subgroups_size)
    subgroups::Vector{Vector{Human}} = []
    slice::Vector{Human} = []

    shuffle!(group_copy)
    # println("SUBGROUP SIZE: $(subgroups_size)")
    # println("SUBGROUP COUNT: $(subgroups_count)")

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

    lords::Vector{Human} = []
    for group in subgroups 
        lord::Human = group[1]
        best::Float64 = lord.objective
        for resident in group
            if resident.objective < best
                best = resident.objective
                lord = resident
            end
        end
        push!(lords, lord)
    end
    return lords
end

###################
# Order Crossover #
###################

function ox(father1::Vector{Int}, father2::Vector{Int})
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
##############################
# Partially Mapped Crossover #
##############################

function pmx(father1::Vector{Int}, father2::Vector{Int})
    size::Int = length(father1)
    sprout::Vector{Int} = zeros(Int, size)
    found::Vector{Int} = zeros(Int, size)
    i::Int = 1
    j::Int = 1
    while i >= j
        i, j = rand(1:size,2)
    end
    for k in i:j
        sprout[k] = father1[k]
        found[father1[k]] = 1
    end
    for k in i:j
        if found[father2[k]] == 0
            new_place::Int = father1[k]
            ind::Int = find_index(father2, new_place)
            while i <= ind && ind <= j
                new_place = father1[ind]
                ind = find_index(father2, new_place)
            end
            sprout[ind] = father2[k]
            found[father2[k]] = 1
        end
    end
    for k in 1:size
        if sprout[k] == 0
            sprout[k] = father2[k]
        end
    end
    return sprout
end

function crossover(father1::Vector{Int}, father2::Vector{Int}, crossing_algorithm::Function)
    kids::Vector{Vector{Int}} = []
    probability1::Float64, probability2::Float64 = rand(MersenneTwister(),2)
    sprout1 = crossing_algorithm(father1, father2)
    sprout2 = crossing_algorithm(father2, father1)
    chance::Float64 = 0.005
    if probability1 < chance
        mutation!(sprout1)
    end
    if probability2 < chance
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
    sprout[:] = invert(i, j, sprout)
end

# println(ox([1,2,3,4,5,6,7,8,9,10], shuffle!([1,2,3,4,5,6,7,8,9,10])))
# tsp = readTSP("TSP/berlin52.tsp")
# simcity(tsp)
function test()
    f1 = [1,2,3,4,5,6,7,8,9]
    f2 = [9,3,7,8,2,6,5,1,4]
    println(f1)
    println(f2)
    println(pmx(f1,f2))
end
function test2(x)
    x = swap(1,3,x)
end
test()