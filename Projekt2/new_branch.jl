using Random
using TSPLIB
using DataStructures
using Dates
using TimesDates
include("utilities.jl")
##########
# invert #
##########

function invert(x, y, list)
    inverted = copy(list)
    inverted[x:y] = inverted[y:-1:x]
    return inverted
end

########
# swap #
########

function swap(x, y, list)
    swapped = copy(list)
    swapped[x], swapped[y] = swapped[y], swapped[x]
    return swapped
end

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

function tabu_search(tsp_data::TSP, start_algotithm::Function, aux_args...)
    local tabu_queue = Queue{Vector{Int}}()
    local long_time_memory = Stack{Vector}()

    local start = start_algotithm(tsp_data, aux_args...)
    local current_solution = start                                      # Aktualny wierzchołek
    local current_best_dist = -1                                        # objective_function tego wierzchołka / sąsiada
    local best_solution = start                                         # najlepsze rozwiąnie
    local best_dist = objective_function(tsp_data, start)               # objective_function tego wierzchołka

    local size = tsp_data.dimension
    local tabu_size = sqrt(size)
    local move_tabu = []
    local move

    # Warunki stopu
    local time_limit = Second(120)
    local time_start = Dates.now()
    local time_elapsed = Second(0)
    local iteration_limit = size*size/2
    local iteration_counter = 0

    # Wykrywanie stagnacji
    local stagnation_time_limit = Second(10)
    local stagnation_time_start = Dates.now()
    local stagnation_time_elapsed = Second(0)

    while iteration_counter < iteration_limit 
        iteration_counter += 1
        current_best_dist = -1                                          # nie wybraliśmy sąsiada
        move = [0,0]
        for i in 2:size-1, j in i+1:size                             # W tych dwóch pętlach sprawdzamy wszystkich sąsiadów obecnego rozwiązania

            time_elapsed = Dates.now() - time_start
            stagnation_time_elapsed = Dates.now() - stagnation_time_start
            if time_elapsed > time_limit
                return best_solution
            end

            if stagnation_time_elapsed > stagnation_time_limit && ( time_limit - time_elapsed > stagnation_time_limit )
                if isempty(long_time_memory)
                    current_solution = shuffle(current_solution)
                elseif length(long_time_memory) > 1
                    pop!(long_time_memory)
                    current_solution, tabu_queue, move_tabu = first(long_time_memory)
                else
                    current_solution, tabu_queue, move_tabu = pop!(long_time_memory)
                end
                current_best_dist = best_dist 
                move = [0,0]
                break
            end
            new_solution = invert(i, j, current_solution)
            new_solution_dist = objective_function(tsp_data, new_solution)

            # sprawdzamy czy jest na liście tabu
            not_in_tabu_queue = true
            for inv in tabu_queue
                if inv == [i,j] || inv == [j,i]
                    not_in_tabu_queue = false
                    break
                end
            end

            # sprawdzamy czy jest na liście obecnego rozwiąnia

            not_in_move_tabu = true
            for inv in move_tabu
                if inv == [i,j] || inv == [j,i]
                    not_in_move_tabu = false
                    break
                end
            end

            if not_in_tabu_queue && not_in_move_tabu && current_best_dist == -1  # Znajdujemy pierwszy, który nie jest na liście tabu
                current_best_dist = new_solution_dist
                current_solution = new_solution
                move = [i,j]
            end
            
            if new_solution_dist < current_best_dist && not_in_move_tabu && not_in_tabu_queue   # zapisujemy najlepsze do tej pory
                current_best_dist = new_solution_dist
                current_solution = new_solution
                move = [i,j]
            end
        end


        if current_best_dist < best_dist    # Mamy lepsze
            stagnation_time_start = Dates.now()
            stagnation_time_elapsed = Second(0)
            append!(move_tabu, move)
            best_dist = current_best_dist
            best_solution = current_solution 
            push!(long_time_memory, [best_solution, tabu_queue, move_tabu])
        end

        if move != [0,0]
            enqueue!(tabu_queue, move)
            move_tabu = []
            if length(tabu_queue) > tabu_size
                dequeue!(tabu_queue)
            end
        end
    end

    return best_solution
    
end

# Pierwsze
# for i in 1:50
# tabu_search(berlin, cos, tabu_size = i)
bays = readTSP("TSP/bays29.tsp")
# berlin = readTSP("TSP/berlin52.tsp")
eil = readTSP("TSP/eil76.tsp")
# br = readTSP("TSP/br17.atsp")
# problemy = [bays, berlin, eil, br]
# file = open("data/1/PRD_berlin_2opt.txt", "w")
# for i in 1:50 
#     prd = PRD(berlin, tabu_search(berlin, two_opt, i), 7542.0)
#     write(file, "$i $prd\n")
#     println(i)
# end
# close(file)

# file = open("extended_neighbour_speed_test.txt", "w")
# for i in 1:25
#     n = 10 * i
#     name = "cum$n.tsp"
#     tsp = readTSP("TSP/"*name)
#     time = @elapsed extended_neighbour(tsp) 
#     println("$n")
#     write(file, "$n $time\n")
# end
# close(file)
# function linear(n)
#     return n
# end

# function stala(n)
#     return 5
# end
# funkcje = [log2, sqrt, linear, stala]
# ft = readTSP("TSP/ry48p.atsp")
# problemy = [ft]
# for f in funkcje, prob in problemy

#     file = open("data/2/$(f)_$(prob.name)", "w")
#     ref = get_optimal("$(prob.name)")[2]
#     prd = PRD(prob, tabu_search(prob, two_opt, f), ref)
#     write(file, "$(prob.name) $prd\n")
#     println("$f")
#     close(file)
# end
# Drugie 
# tabu_search(problem1, tabu_size = const)
# tabu_search(problem2, tabu_size = const)
# tabu_search(problem3, tabu_size = const)
# tabu_search(problem1, tabu_size = log)
# tabu_search(problem2, tabu_size = log)
# tabu_search(problem3, tabu_size = log)
# .
# .
# .

# Trzecie 
# tabu_search(berlin) @elapsed / n^4
# for i in 1:25
#     n = 10 * i
#     name = "cum$n.tsp"
#     random_instance("EUC_2D", n, 2137, 100, name)
#     println("$n")
# end

# file = open("data/3/time_comp_rand.txt", "w")
# for i in 1:25
#     n = 10 * i
#     name = "cum$n.tsp"
#     tsp = readTSP("TSP/"*name)
#     println("$(tsp.name)")
#     time = @elapsed tabu_search(tsp, k_random,1)
#     println("$n")
#     write(file, "$n $time\n")
# end
# close(file)

# cum250 = readTSP("TSP/cum250.tsp")
# tabu_search(cum250, two_opt)

# time = @elapsed tabu_search(berlin, two_opt, sqrt)

#Czwarte
#raz komentujemy dodawanie do pamięci (też berlin)

#Piąte
#tabu_search(na każdym algorytmie)
file = open("data/5/bays.txt", "w")

prd = PRD(bays, tabu_search(bays, two_opt),2020.0)
write(file, "two_opt $prd\n")
prd = PRD(bays, tabu_search(bays, extended_neighbour),2020.0)
write(file, "extended_neighbour $prd\n")
prd = PRD(bays, tabu_search(bays, k_random,1),2020.0)
write(file, "random $prd\n")

close(file)