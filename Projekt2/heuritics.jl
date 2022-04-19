using Random
using TSPLIB
using DataStructures
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
    local solution = shuffle(rng, Vector(1:size))   # Wybieramy losowe rozwiąnie początkowe
    function invert(x, y, list)
        swapped = copy(list)
        swapped[x:y] = swapped[y:-1:x]
        return swapped
    end

    local improved_flag = true
    local current_new_solution = solution            # current_solution to kandydat na lepsze rozwiązanie
    local best_dist = objective_function(tsp_data, solution)
    while improved_flag == true
        improved_flag = false
        
        for i in 2:size-1                            # W tych dwóch pętlach sprawdzamy wszystkich sąsiadów obecnego rozwiązania
            for j in i+1:size
                new_solution = invert(i, j, solution)
                current_dist = objective_function(tsp_data, new_solution)
    
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

###############
# Tabu search #
###############

function tabu(tsp_data::TSP, start::Vector{Int})
    local tabu_queue = Queue{Vector{Int}}()
    local improved_flag = true

    local current_new_solution = start                      # To jest lepsze
    local best_dist = objective_function(tsp_data, start)

    local size = tsp_data.dimension
    local solution = start

    # local candidate = start         #
    # local cand_dist = best_dist     # Kandydat = co najwyżej 105% najlepszego 

    function invert(x, y, list)
        swapped = copy(list)
        swapped[x:y] = swapped[y:-1:x]
        return swapped
    end

    # To na dole do przerobienia
    while improved_flag == true
        improved_flag = false
        local move = [0,0]
        for i in 2:size-1                            # W tych dwóch pętlach sprawdzamy wszystkich sąsiadów obecnego rozwiązania
            for j in i+1:size
                
                new_solution = invert(i, j, solution)
                current_dist = objective_function(tsp_data, new_solution)
                not_in_queue = true
                for inv in tabu_queue
                    if inv == (i,j) || inv ==(j,i)
                        not_in_queue = false
                        break
                    end
                end


                if current_dist < best_dist && not_in_queue # zapisujemy najlepsze do tej pory
                    best_dist = current_dist
                    current_new_solution = new_solution
                    move = [i,j]
                    improved_flag = true
                end

            end
        end
        if move != [0,0]
            enqueue!(tabu_queue, move)
            if length(tabu_queue) > 100
                dequeue!(tabu_queue)
            end
        end
        solution = current_new_solution
    end
    return solution
    # Taboo . To na górze do przerobienia
end



# sBest ← s0
# bestCandidate ← s0
# tabuList ← []
# tabuList.push(s0)
# while (not stoppingCondition())
#     sNeighborhood ← getNeighbors(bestCandidate)
#     bestCandidate ← sNeighborhood[0]
#     for (sCandidate in sNeighborhood)
#         if ( (not tabuList.contains(sCandidate)) and (fitness(sCandidate) > fitness(bestCandidate)) )
#             bestCandidate ← sCandidate
#         end
#     end
#     if (fitness(bestCandidate) > fitness(sBest))
#         sBest ← bestCandidate
#     end
#     tabuList.push(bestCandidate)
#     if (tabuList.size > maxTabuSize)
#         tabuList.removeFirst()
#     end
# end
# return sBest