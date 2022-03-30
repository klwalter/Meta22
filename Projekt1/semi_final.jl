using TSPLIB
using Random

global improved_flag = true

#################################
# Pierwszy fragment kodu szefie #
#################################

function load_tsp()
    println()
    print("Enter the name of the instance with extension: ")
    name = chomp(readline())
    path = "TSP/" * name
    return readTSP(path)
end

##############################
# Drugi fragment kodu szefie #
##############################

function random_instance(size::Number, seed::Number, variant::String)
    rng = Random.MersenneTwister(seed)
    random_vector = shuffle(rng, Vector(1:size))
    return (random_vector, variant)
end

###############################
# Trzeci fragment kodu szefie #
###############################


function show()
    println(tsp.weight)
end

################################
# Czwarty fragment kodu szefie #
################################

function results(result::Vector{Int})
    println(result)
end

##############################
# Piąty fragment kodu szefie #
##############################

function objective_function(tsp_data::TSP, result::Vector{Int})
    distance_matrix = tsp_data.weights
    sum = 0
    l = length(result)
    for n in 1:l-1
        sum = sum + distance_matrix[result[n], result[n+1]]           
    end
    sum = sum + distance_matrix[l,1]
    return sum
end

###############################
# Szósty fragment kodu szefie #
###############################

function PRD(x::Vector{Int}, f_ref::Float32)
    return (objective_function(tsp_data, x) - f_ref)/f_ref
end


################################################################
#                        Heurystyki                            #
################################################################


############
# k-random #
############

function k_random(tsp_data::TSP, k::Number)
    rng = Random.MersenneTwister()
    vertices_number = tsp_data.dimension

    solution = shuffle(rng, Vector(1:vertices_number))
    distance = objective_function(tsp_data, solution)

    for i in 1:k
        temp_solution = shuffle(rng, Vector(1:vertices_number))
        temp_distance = objective_function(tsp_data, temp_solution)

        if distance > temp_distance
            distance = temp_distance
            solution = temp_solution
        end
    end    
    return solution
end

#####################
# nearest neighbour #
#####################

function nearest_neighbour(tsp_data::TSP, starting_point::Number)
    size = tsp_data.dimension
    solution = zeros(Int, size)
    solution[1] = starting_point
    local temp_node
    local temp_distance

    status = ones(Int, size)
    status[starting_point] = 0

    distance_matrix = tsp_data.weights
    nodes_done = 1
    while nodes_done < size # lecimy tak długo, aż nie zostanie nam 1 wierzchołek
        for i in 1:size # interujemy po wszystkich wierzchołkach
            if status[i] == 1 # sprawdzamy czy wierzchołek był odwiedzony
                temp_node = i
                temp_distance = distance_matrix[solution[nodes_done], i] # solution[nodes_done] = numer ostanio dodanego wierzchołka
                break # wybraliśmy pierwszy wierzchołek o statusie 1
            end
        end
        for i in temp_node+1:size
            if status[i] == 1 # kolejny nieodwiedzony wierzchołek
                new_distance = distance_matrix[solution[nodes_done], i] # sprawdzamy odległość do nowego wierzchołka 
                if temp_distance > new_distance # Jeżeli kolejny wierchołek jest bliżej to zmieniamy
                    temp_node = i
                    temp_distance = new_distance
                end
            end
        end
        nodes_done += 1
        solution[nodes_done] = temp_node
        status[temp_node] = 0
    end
    return solution
end

######################
# extended neighbour #
######################

function extended_neighbour(tsp_data::TSP)
    size = tsp_data.dimension
    solution = nearest_neighbour(tsp_data, 1)

    for i in 2:size 
        temp = nearest_neighbour(tsp_data, i)
        if objective_function(tsp_data, solution) > objective_function(tsp_data, temp)
            solution = temp
        end
    end
    return solution
end

###########
#  2 OPT  #
###########

function two_opt(tsp_data::TSP)
    rng = Random.MersenneTwister()
    size = tsp_data.dimension
    local solution = shuffle(rng, Vector(1:size))                         # Wybieramy losowe rozwiąnie początkowe
    #println("Solution 1", solution)
    function swap(x, y, list)
        swapped = copy(list)
        swapped[x], swapped[y] = swapped[y], swapped[x]
        return swapped
    end

    local current_new_solution = solution                                     # current_solution to kandydat na lepsze rozwiązanie
    local best_dist = objective_function(tsp_data, solution)
    while improved_flag == true
        improved_flag = false
        for i in 2:size                                             # W tych dwóch pętlach sprawdzamy wszystkich sąsiadów obecnego rozwiązania
            for j in i+1:size
                new_solution = swap(i, j, solution)
                current_dist = objective_function(tsp_data, new_solution)
    
                if current_dist < best_dist

                    best_dist = current_dist
                    current_new_solution = new_solution
                    #println("Solution 2", current_new_solution)
                    #solution = new_solution
                    improved_flag = true
                end
            end
        end
        
        solution = current_new_solution
        #println("Solution 3", solution) 
    end
    #println("Solution 4", solution)
    return solution
end

################
# LOAD OPTIMUS #
################

function get_optimal(variant::String)
    path = "TSP/" * variant
    file = open(path, "r")
    solution = Int[]
    numbers = false
    for line in eachline(file)
        

        if line == "-1"
            break
        end

        if numbers
            liczba = parse(Int, line)
            append!(solution, liczba)
        end

        if line == "TOUR_SECTION"
            numbers = true
        end

    end
    return solution
end

###########
#  TESTS  #
###########

function alg_test(tsp_data::TSP, algorithm::Function, objective::Function, reps::Int, aux_args...)
    println()
    println("-----------------TEST-----------------")
    println("Currently tested TSP file:")
    println("Name: ", tsp_data.name)
    println("Nodes: ", tsp_data.dimension)
    println("Algorithm: ", algorithm)
    println("Repetitions: ", reps)

    best_path = []
    best_dist = 0

    for i in 1:reps
        final_path = algorithm(tsp_data, aux_args...)
        obj_dist = objective(tsp_data, final_path)
        # println()
        # println("Tested path $i: ", final_path)
        # println("Tested distance $i: ", obj_dist)

        if i == 1
            best_path = final_path
            best_dist = obj_dist
        else
            if obj_dist < best_dist
                best_path = final_path
                best_dist = obj_dist
            end
            if rem(i, 1000) == 0
                println("$i out of $reps tests done")
                
            end
        end
    end

    println()
    println("-----------------RESULTS-----------------")
    println("Best path found: ", best_path)
    println("Best distance found: ", best_dist)
    println()
end


##########
#  MAIN  #
##########

function main()
    repetitions = 10000
    aux = 0
    tsp = load_tsp()
    local time

    println("Choose which algorithm you want to use:")
    println("1. K-random")
    println("2. Nearest neighbour")
    println("3. Extended nearest neighbour")
    println("4. 2-OPT")
    print("Your choice: ")
    choice = parse(Int, readline())
    println()
    
    if choice == 1
        println("You have chosen K-random")
        print("Please enter the K-value: ")
        aux = parse(Int, readline())
        @time begin            
            time = @elapsed alg_test(tsp, k_random, objective_function, repetitions, aux)
        end
    elseif choice == 2
        println("You have chosen Nearest neighbour")
        print("Please enter the starting node: ")
        aux = parse(Int, readline())
        @time begin
            alg_test(tsp, nearest_neighbour, objective_function, repetitions, aux)            
        end
    elseif choice == 3
        println("You have chosen Extended nearest neighbour")
        @time begin
            alg_test(tsp, extended_neighbour, objective_function, repetitions)
        end
    elseif choice == 4
        println("You have chosen 2-OPT")    
        time = @elapsed alg_test(tsp, two_opt, objective_function, repetitions)
    else
        println("Please enter correct number")
    end

    println(time)
end

main()