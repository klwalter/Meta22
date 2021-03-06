using Random
using TSPLIB
using DataStructures
using Dates
using TimesDates


###############
# Tabu search #
###############

function tabu_search(tsp_data::TSP, start_algotithm::Function, aux_args...)::Vector{Int}
    tabu_queue = Queue{Vector{Int}}()
    long_time_memory = Stack{Vector}()

    start::Vector{Int} = start_algotithm(tsp_data, aux_args...)
    current_solution::Vector{Int} = start                                      # Aktualny wierzchołek
    current_best_dist::Float64 = -1.0                                        # objective_function tego wierzchołka / sąsiada
    best_solution::Vector{Int} = start                                         # najlepsze rozwiąnie
    best_dist::Float64 = objective_function(tsp_data, start)               # objective_function tego wierzchołka

    size::Int = tsp_data.dimension
    tabu_size::Int = floor(sqrt(size))
    move_tabu::Vector{Int} = []
    move::Vector{Int} = []

    # Warunki stopu
    time_start::DateTime = Dates.now()
    time_limit::Second = Second(120)
    time_elapsed::Millisecond = Second(0)
    iteration_limit::Int = size
    iteration_counter::Int = 0
    
    # Wykrywanie stagnacji
    stagnation_time_start::DateTime = Dates.now()
    stagnation_time_limit::Second = Second(10)
    stagnation_time_elapsed::Millisecond = Second(0)

    # Wypisywanie
    optimum::Tuple{Bool, Float64} = get_optimal(tsp_data.name)
    prd::Float64 = 0.0
    flag::Bool = optimum[1]

    if flag == true
        prd = PRD(tsp_data, best_solution, optimum[2])
    end
    # println("Numer iteracji: $iteration_counter, długość: $best_dist, prd: $prd%") 
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
            new_solution::Vector{Int} = invert(i, j, current_solution)
            new_solution_dist::Float64 = objective_function(tsp_data, new_solution)

            # sprawdzamy czy jest na liście tabu
            not_in_tabu_queue::Bool = true
            for inv in tabu_queue
                if inv == [i,j] || inv == [j,i]
                    not_in_tabu_queue = false
                    break
                end
            end

            # sprawdzamy czy jest na liście obecnego rozwiąnia
            not_in_move_tabu::Bool = true
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

            if flag == true
                prd = PRD(tsp_data, best_solution, optimum[2])
            end
            # println("Numer iteracji: $iteration_counter, długość: $best_dist, prd: $prd%") 
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

