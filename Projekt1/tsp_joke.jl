using TSPLIB
using Random

#################################
# Pierwszy fragment kodu szefie #
#################################

function load_tsp(name::String)
    path = "TSP/" * name
    global tsp = readTSP(path)
end

load_tsp("gr120.tsp")
println(tsp.name)
load_tsp("berlin52.tsp")
println(tsp.name)
load_tsp("br17.atsp")
println(tsp.name)

##############################
# Drugi fragment kodu szefie #
##############################

function random_instance(size::Number, seed::Number, variant::String)
    rng = Random.MersenneTwister(seed)
    random_vector = shuffle(rng, Vector(1:size))
    return (random_vector, variant)
end

test = random_instance(5, 124213, "lambda")
println(test)

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

function objective_function(result::Vector{Int})
    # Zakładam, że mamy tu załadowaną instancję problemu
    distance_matrix = tsp.weights
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
    return (objective_function(x) - f_ref)/f_ref
end


################################################################
#                        Heurystyki                            #
################################################################


############
# k-random #
############

function k_random(k::Number)
    # Zakładamy, że mamy załadowaną instancję problemu
    
    rng = Random.MersenneTwister()
    vertices_number = tsp.dimension

    solution = shuffle(rng, Vector(1:vertices_number))
    distance = objective_function(solution)
    for i in 1:k
        temp_solution = shuffle(rng, Vector(1:vertices_number))
        temp_distance = objective_function(temp_solution)
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

function nearest_neighbour(starting_point::Number)
    # Zakładamy, że mamy załadowaną instancję problemu
    size = tsp.dimension
    solution = zeros(Int, size)
    solution[1] = starting_point

    status = ones(Int, size)
    status[starting_point] = 0

    distance_matrix = tsp.weights
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

