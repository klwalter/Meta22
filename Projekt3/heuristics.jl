using Random
using TSPLIB


############
# K-random #
############

function k_random(tsp_data::TSP, k::Int, aux_args...)::Vector{Int}
    rng::MersenneTwister = Random.MersenneTwister()
    vertices_number::Int = tsp_data.dimension
    
    solution::Vector{Int} = shuffle(rng, Vector(1:vertices_number))
    distance::Float64 = objective_function(tsp_data, solution)

    for i in 1:k
        temp_solution::Vector{Int} = shuffle(rng, Vector(1:vertices_number))
        temp_distance::Float64 = objective_function(tsp_data, temp_solution)

        if distance > temp_distance
            distance = temp_distance
            solution = temp_solution
        end
    end    

    return solution
end

#####################
# Nearest neighbour #
#####################

function nearest_neighbour(tsp_data::TSP, starting_point::Int)::Vector{Int}
    size::Int = tsp_data.dimension
    temp_node::Int = 0
    temp_distance::Float64 = 0.0 
    
    solution::Vector{Int} = zeros(Int, size)
    solution[1] = starting_point

    status::Vector{Int} = ones(Int, size)
    status[starting_point] = 0

    distance_matrix::Matrix{Float64} = tsp_data.weights
    nodes_done::Int = 1


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
                new_distance::Float64 = distance_matrix[solution[nodes_done], i] # sprawdzamy odległość do nowego wierzchołka 
                
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

##############################
# Extended nearest neighbour #
##############################

function extended_neighbour(tsp_data::TSP)::Vector{Int}
    size::Int = tsp_data.dimension
    solution::Vector{Int} = nearest_neighbour(tsp_data, 1)

    for i in 2:size 
        temp::Vector{Int} = nearest_neighbour(tsp_data, i)

        if objective_function(tsp_data, solution) > objective_function(tsp_data, temp)
            solution = temp
        end
    end

    return solution
end

#########
# 2-OPT #
#########

function two_opt(tsp_data::TSP, aux_args...)::Vector{Int}
    rng::MersenneTwister = Random.MersenneTwister()
    size::Int = tsp_data.dimension
    solution::Vector{Int} = shuffle(rng, Vector(1:size))   # Wybieramy losowe rozwiąnie początkowe

    improved_flag::Bool = true
    current_new_solution::Vector{Int}  = solution            # current_solution to kandydat na lepsze rozwiązanie
    best_dist::Float64 = objective_function(tsp_data, solution)

    while improved_flag == true
        improved_flag = false

        for i in 2:size-1                            # W tych dwóch pętlach sprawdzamy wszystkich sąsiadów obecnego rozwiązania
            for j in i+1:size
                new_solution::Vector{Int} = invert(i, j, solution)
                current_dist::Float64 = objective_function(tsp_data, new_solution)
    
                if current_dist < best_dist
                    best_dist = current_dist
                    current_new_solution = new_solution
                    improved_flag = true
                end
            end
        end
        
        solution = current_new_solution
    end

    return solution
end
