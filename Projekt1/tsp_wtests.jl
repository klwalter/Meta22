using TSPLIB
using Random

global improved = true

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
    # Zakładam, że mamy tu załadowaną instancję problemu
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
    while nodes_done < size-1 # lecimy tak długo, aż nie zostanie nam 1 wierzchołek
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
    end
    return solution
end


function better_neighbour(tsp_data::TSP)
    size = tsp_data.dimension
    solution = nearest_neightbour(1)
    for i in 2:size 
        temp = nearest_neightbour(i)
        if objective_function(tsp_data, solution) > objective_function(tsp_data, temp)
            solution = temp
        end
    end
    return solution
end

###########
#  2 OPT  #
###########

# function two_opt(tsp_data::TSP)
#                                                                 # Zakładam że mamy załadowany problem
#     rng = Random.MersenneTwister()                              # Wybieramy chad generator
#     size = tsp_data.dimension                                        #
#     solution = shuffle(rng, Vector(1:size))                     # Wybieramy losowe rozwiąnie początkowe
#     there_is_better = 1                                         # Tu ustawiłem flagę na 1, ale można zamiast tego ustawić ją na 0 i zrobić do while. Wychodzi na to samo
    
#     while there_is_better == 1                                  #
#         there_is_better = 0                                     # Dopóki nie znajdziemy lepszego, flaga jest opuszczona (PS nie wiem czy dobrze postawiłem przecinek)
#         current_solution = solution                             # current_solution to kandydat na lepsze rozwiązanie
#         dist = objective_function(tsp_data, current_solution)             #
#         for i in 1:size-1                                       # W tych dwóch pętlach sprawdzamy wszystkich sąsiadów obecnego rozwiązania
#             for j in i+1:size                                   #
#                 neighbour = solution                            #
#                 neighbour[i], neighbour[j] = solution[j], neighbour[i]                      # Tutaj robimy inwersję 
#                 if objective_function(tsp_data, neighbour) < dist         #
#                     current_solution = neighbour                #
#                     dist = objective_function(tsp_data, current_solution) #
#                     there_is_better = 1                         # Znaleźliśmy lepsze rozwiązanie, więc zamieniamy z poprzednim gorszym i podnosimy flagę there_is_better      
#                 end                                             #
#             end                                                 #
#         end                                                     #
#         solution = current_solution                             # Zamieniamy obecne rozwiązanie z nowym. Jeżeli flaga there_is_better nie została podniesiona, to podwójna pętla nic nie zmieniła.
#     end                                                         #
#     return solution                                             #
# end

function two_opt(tsp_data::TSP)
    rng = Random.MersenneTwister()
    size = tsp_data.dimension
    solution = shuffle(rng, Vector(1:size))                         # Wybieramy losowe rozwiąnie początkowe
    
    function swap(x, y)
        swapped = copy(solution)
        swapped[x], swapped[y] = swapped[y], swapped[x]
        return swapped
    end

    current_solution = solution                                     # current_solution to kandydat na lepsze rozwiązanie
    best_dist = objective_function(tsp_data, current_solution)

    while improved == true
        improved = false

        for i in 2:size                                             # W tych dwóch pętlach sprawdzamy wszystkich sąsiadów obecnego rozwiązania
            for j in i+1:size
                new_solution = swap(i, j)
                current_dist = objective_function(tsp_data, new_solution)
    
                if current_dist < best_dist
                    best_dist = current_dist
                    solution = new_solution
                    improved = true
                end
            end
        end
        return solution  
    end
end

##########
#  TEST  #
##########

function sim_test(tsp_data::TSP, algorithm::Function, objective::Function, reps::Int)
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
        final_path = algorithm(tsp_data)
        obj_dist = objective(tsp_data, final_path)
        # println("Tested path: ", final_path)
        # println("Tested distance: ", obj_dist)

        if i == 1
            best_path = final_path
            best_dist = obj_dist
        elseif rem(i, 1000) == 0
            println("$i out of $reps tests already done")
        else
            if obj_dist < best_dist
                best_path = final_path
                best_dist = obj_dist
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
    tsp = load_tsp()

    println("Choose which algorithm you want to use:")
    println("1. K-random")
    println("2. Nearest neighbour")
    println("3. 2-OPT")
    print("Your choice: ")
    choice = parse(Int, readline())
    println()
    
    if choice == 1
        println("You have chosen K-random")
        sim_test(tsp, two_opt, objective_function, repetitions)
    elseif choice == 2
        println("You have chosen Nearest neighbour")
        sim_test(tsp, two_opt, objective_function, repetitions)
    elseif choice == 3
        println("You have chosen 2-OPT")
        sim_test(tsp, two_opt, objective_function, repetitions)
    else
        println("Please enter correct number")
    end
    
end

main()