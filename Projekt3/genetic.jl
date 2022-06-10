import Base.@kwdef
using TSPLIB
using Random
using TimesDates
include("heuristics.jl")
include("utilities.jl")
include("tabu.jl")


const STAGNATION_LIMIT = 10


###################
# Human structure #
###################

@kwdef mutable struct Human
    solution::Vector{Int} = []
    objective::Float64 = 0.0
    # age::Int = 0
end

function new_human(tsp_data::TSP, start_algorithm::Function, aux_args...)::Human
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
function genetic(tsp_data::TSP, population_choice::Int, crossover_choice::Int, mutation_choice::Int, chance::Float64 = 0.005, 
                population_multiplier::Int = 10,runtime_limit::Int = 6000)::Vector{Int}
    lords::Vector{Human} = []
    generation::Vector{Human} = []
    best_solution::Vector{Int} = []   

    opt::Tuple{Bool, Float64} = get_optimal(tsp_data.name)
    
    best_dist::Float64 = 0.0
    
    counter::Int = 1
    group_size::Int = floor(sqrt(tsp_data.dimension)) * population_multiplier
    population_size::Int = group_size * group_size
    size::Int = 0

    
    ###############################
    # Population algorithm choice #
    ###############################

    population_type::Function = random_population

    if population_choice == 1
        population_type = random_population
    elseif population_choice == 2
        population_type = nearest_neighbour_population
    elseif population_choice == 3
        population_type = two_opt_population
    else
        println("Co się kurwa patrzysz")
        return
    end
    
    ##############################
    # Crossover algorithm choice #
    ##############################

    crossover_type::Function = order_crossover

    if crossover_choice == 1
        crossover_type = order_crossover
    elseif crossover_choice == 2
        crossover_type = double_order_crossover
    elseif crossover_choice == 3
        crossover_type = mapped_crossover
    else
        println("IT'S MORBIN TIME!")
        return
    end

    ###################
    # Mutation choice #
    ###################

    mutation_type::Function = invert
    if mutation_choice == 1
        mutation_type = invert
    elseif mutation_choice == 2
        mutation_type = swap
    else
        println("Spierdalaj")
        return
    end


    generation = population_type(tsp_data, population_size)
    best_solution = generation[1].solution
    best_dist = generation[1].objective
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
        # println("Solution: $best_solution\nGeneration number: $counter\nDistance: $best_dist\nPrd: $prd%")
        if prd == 0.0
            # println("Number of last generation: $counter")
            return best_solution
        end
    else
        # println("Solution: $best_solution\nGeneration number: $counter\nDistance: $best_dist\n")
    end


    ########################
    # Detecting Stagnation #
    ########################

    stagnation_time_start::DateTime = Dates.now()
    stagnation_time_limit::Second = Second(STAGNATION_LIMIT)
    stagnation_time_elapsed::Millisecond = Second(0)

    ###################
    # Stop conditions #
    ###################

    time_start::DateTime = Dates.now()
    time_limit::Second = Second(runtime_limit)
    time_elapsed::Millisecond = Second(0)

    #############
    # Main loop #
    #############

    while counter < 1000
        counter += 1
        lords = []
        time_elapsed = Dates.now() - time_start

        if time_elapsed > time_limit
            return best_solution
        end

        lords = tournament_selection(generation, population_size, group_size)
        generation = []
        size = length(lords)

        kids::Vector{Vector{Int}} = []
        for a in 1:size-1, b in a+1:size
            kids = [kids; init_crossover(lords[a].solution, lords[b].solution, crossover_type, mutation_type, chance)]
            time_elapsed = Dates.now() - time_start
            stagnation_time_elapsed = Dates.now() - stagnation_time_start
            if time_elapsed > time_limit
                # println("Number of last generation: $counter")
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
                # println("Number of last generation: $counter")
                return best_solution
            end
            if temp_human.objective < best_dist
                best_dist = temp_human.objective
                best_solution = temp_human.solution
                stagnation_time_elapsed = Second(0)
                stagnation_time_start = Dates.now()
                if opt[1] == true
                    prd = PRD(tsp_data, best_solution, opt[2])                        
                    # println("Solution: $best_solution\nGeneration number: $counter\nDistance: $best_dist\nPrd: $prd%")
                    if prd == 0.0
                        # println("Number of last generation: $counter")
                        return best_solution
                    end
                else
                    # println("Solution: $best_solution\nGeneration number: $counter\nDistance: $best_dist\n")
                end 
            end
            push!(generation, temp_human)
        end

        if stagnation_time_elapsed > stagnation_time_limit
            for human in generation
                mutation!(human.solution, mutation_type)
                human.objective = objective_function(tsp_data, human.solution)
            end
            stagnation_time_elapsed = Second(0)
            stagnation_time_start = Dates.now()
        end

        generation = [generation; lords]
    end
    return best_solution
end


#########################
# Generating Population #
#########################

function random_population(tsp_data::TSP, population_size::Int)::Vector{Human}
    population::Vector{Human} = [new_human(tsp_data, k_random, 1) for _ in 1:population_size]
    return population
end

function nearest_neighbour_population(tsp_data::TSP, population_size::Int)::Vector{Human}
    population::Vector{Human} = []
    
    for i in 1:tsp_data.dimension
        push!(population, new_human(tsp_data, nearest_neighbour, i))
    end

    for _ in tsp_data.dimension+1:population_size
        push!(population, new_human(tsp_data, k_random, 1))
    end

    return population
end

function two_opt_population(tsp_data::TSP, population_size::Int)::Vector{Human}
    population::Vector{Human} = []
    
    for _ in 1:tsp_data.dimension
        push!(population, new_human(tsp_data, two_opt))
    end

    for _ in tsp_data.dimension+1:population_size
        push!(population, new_human(tsp_data, k_random, 1))
    end

    return population
end


########################
# Selection algorithms #
########################

function tournament_selection(population::Vector{Human}, population_size::Int, subgroups_size::Int)::Vector{Human}
    population_copy::Vector{Human} = copy(population)
    subgroups::Vector{Vector{Human}} = []
    slice::Vector{Human} = []
    lords::Vector{Human} = []
    
    subgroups_count::Int = ceil(population_size / subgroups_size)


    shuffle!(population_copy)

    for i in 1:subgroups_count
        slice = population_copy[((i - 1) * subgroups_size + 1) : min((i * subgroups_size), population_size)]
        push!(subgroups, slice)
    end

    for subgroup in subgroups 
        lord::Human = subgroup[1]
        best::Float64 = lord.objective

        for human in subgroup
            if human.objective < best
                best = human.objective
                lord = human
            end
        end

        push!(lords, lord)
    end

    return lords
end


###################
# Order Crossover #
###################

function order_crossover(parent1::Vector{Int}, parent2::Vector{Int})::Vector{Int}
    size::Int = length(parent1)
    sprout::Vector{Int} = zeros(Int, size)
    found::Vector{Int} = zeros(Int, size)

    cross_point::Int = rand(1:size-1)
    i::Int = 1
    j::Int = 1


    while i <= cross_point
        sprout[i] = parent1[i]
        found[parent1[i]] = 1

        i += 1
    end

    j = i

    while i <= size
        while found[parent2[j]] != 0
            if j == size
                j = 0
            end
            j += 1
        end

        sprout[i] = parent2[j]
        found[parent2[j]] = 1

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

function mapped_crossover(parent1::Vector{Int}, parent2::Vector{Int})::Vector{Int}
    size::Int = length(parent1)
    sprout::Vector{Int} = zeros(Int, size)
    found::Vector{Int} = zeros(Int, size)

    i::Int = 1
    j::Int = 1


    while i >= j
        i, j = rand(1:size,2)
    end

    for k in i:j
        sprout[k] = parent1[k]
        found[parent1[k]] = 1
    end

    for k in i:j
        if found[parent2[k]] == 0
            new_place::Int = parent1[k]
            ind::Int = find_index(parent2, new_place)

            while i <= ind && ind <= j
                new_place = parent1[ind]
                ind = find_index(parent2, new_place)
            end

            sprout[ind] = parent2[k]
            found[parent2[k]] = 1
        end
    end

    for k in 1:size
        if sprout[k] == 0
            sprout[k] = parent2[k]
        end
    end

    return sprout
end

################################
# Double point order crossover #
################################

function double_order_crossover(parent1::Vector{Int}, parent2::Vector{Int})::Vector{Int}
    size::Int = length(parent1)
    sprout::Vector{Int} = zeros(Int, size)
    found::Vector{Int} = zeros(Int, size)

    i::Int = 1
    j::Int = 1

    while i >= j
        i, j = rand(1:size,2)
    end

    for a in i:j 
        sprout[a] = parent1[a]
        found[parent1[a]] = 1
    end
    k::Int = j + 1
    if k > size
        k = 1
    end
    while k != i

        while found[parent2[j]] != 0
            if j == size
                j = 0
            end
            j += 1
        end

        sprout[k] = parent2[j]
        found[parent2[j]] = 1

        if j == size
            j = 0
        end
        if k == size
            k = 0
        end
        j += 1
        k += 1
    end

    return sprout
end

########################
# Initialize crossover #
########################

function init_crossover(father1::Vector{Int}, father2::Vector{Int}, crossover_algorithm::Function, mutation_type::Function, chance::Float64)::Vector{Vector{Int}}
    kids::Vector{Vector{Int}} = []

    probability1::Float64, probability2::Float64 = rand(MersenneTwister(),2)
    

    sprout1 = crossover_algorithm(father1, father2)
    sprout2 = crossover_algorithm(father2, father1)
    
    if probability1 < chance
        mutation!(sprout1, mutation_type)
    end
    if probability2 < chance
        mutation!(sprout2, mutation_type)
    end
    
    push!(kids, sprout1)
    push!(kids, sprout2)
    
    return kids
end


############
# Mutation #
############

function mutation!(sprout::Vector{Int}, mutation_type::Function)
    size::Int = length(sprout)
    i::Int = 1
    j::Int = 1

    while i == j
        i, j = rand(1:size,2)
    end

    sprout[:] = mutation_type(i, j, sprout)
end

# println(ox([1,2,3,4,5,6,7,8,9,10], shuffle!([1,2,3,4,5,6,7,8,9,10])))
# tsp = readTSP("TSP/berlin52.tsp")
# genetic(tsp,1,1,1)
# function test(a::Int = 5)
#     println(a)
#     f1 = [1,2,3,4,5,6,7,8,9]
#     f2 = [9,3,7,8,2,6,5,1,4]
#     println(f1)
#     println(f2)
#     println(double_order_crossover(f1,f2))
# end
# function test2(x)
#     x = swap(1,3,x)
# end
# test(7)