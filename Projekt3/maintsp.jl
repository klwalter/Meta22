include("heuristics.jl")
include("utilities.jl")
include("tabu.jl")
include("genetic.jl")

const REPETITIONS = 10

#####################
# Algorithm testing #
#####################

function alg_test(tsp_data::TSP, reps::Integer, algorithm::Function, aux_args...)
    println("\n================================================")
    println()
    println("-----------------TESTING-----------------")
    println("Currently tested TSP file:")
    println("Name: ", tsp_data.name)
    println("Nodes: ", tsp_data.dimension)
    println("Variant: ", tsp_data.weight_type)
    println("Algorithm: ", algorithm)
    println("Repetitions: ", reps)
    println("\nProgress:")


    best_path::Vector{Int} = []
    best_dist::Float64 = 0.0
    opt_pair::Tuple{Bool, Float64} = get_optimal(tsp_data.name)

    for i in 1:reps
        final_path::Vector{Int} = algorithm(tsp_data, aux_args...)
        obj_dist::Float64 = objective_function(tsp_data, final_path)

        if i == 1
            best_path = final_path
            best_dist = obj_dist
        else
            if obj_dist < best_dist
                best_path = final_path
                best_dist = obj_dist
            end
        end
        
        if rem(i, (reps/10)) == 0
            println("$i out of $reps tests done (", (i/reps)*100, "%)")
        end
    end

    println()
    println("-----------------RESULTS-----------------")
    println("Best path found: ", best_path)
    println("Best distance found: ", best_dist)

    if opt_pair[1] == true
        optimal_dist::Float64 = opt_pair[2]
        println("PRD: ", PRD(tsp_data, best_path, optimal_dist), "%")
    else
        println("Optimal tour file doesn't exist, can't obtain PRD!")
    end
end

########
# MAIN #
########

function main()
    exit_flag::Bool, asymmetric_flag::Bool = false, false
    instance_type::String, instance_name::String = "", ""
    seed::Int, nodes_count::Int, range::Int = 0, 0, 0
    aux_argument::Int = 0
    choice::Int8, alg_choice::Int8 = 0, 0
    time::Float64 = 0

    println()
    println("================================================")
    println("Choose an option from menu below:")
    println("1. Load existing instance")
    println("2. Generate new instance")
    print("Your choice: ")
    choice = parse(Int, readline())
    println("================================================")

    if choice == 1
        tsp::TSP = load_tsp()
    elseif choice == 2
        println()
        print("Please enter parameters for generator:\nAsymmetric format? (1 - true): ")
        asymmetric_flag = parse(Bool, readline())

        if asymmetric_flag != 1
            print("Type of instance (FULL_MATRIX, LOWER_DIAG_ROW, EUC_2D): ")
            instance_type = convert(String, chomp(readline()))

            if instance_type != "EUC_2D" && instance_type != "FULL_MATRIX" && instance_type != "LOWER_DIAG_ROW"
                println()
                println("Please enter correct type of instance\n")
                return
            end
        else
            instance_type = "FULL_MATRIX"
        end

        print("Number of nodes: ")
        nodes_count = parse(Int, readline())

        print("Seed for RNG: ")
        seed = parse(Int, readline())

        print("Range of values (from 1 to X): ")
        range = parse(Int, readline())

        print("Enter the name of the instance with extension: ")
        instance_name = convert(String, chomp(readline()))
        
        tsp = random_instance(asymmetric_flag, instance_type, nodes_count, seed, range, instance_name)
    else
        println("\nPlease enter correct number\n")
        return -1
    end

    while exit_flag == false
        println()
        println("================================================")
        println("Choose which algorithm you want to use:")
        println("1. K-random")
        println("2. Nearest neighbour")
        println("3. Extended nearest neighbour")
        println("4. 2-OPT")
        println("5. Tabu search")
        print("Your choice: ")
        choice = parse(Int, readline())
        println()
        
        if choice == 1
            println("\t+------------------------+")
            println("\t|You have chosen K-random|")
            println("\t+------------------------+")

            print("\nPlease enter the K-value: ")
            aux_argument = parse(Int, readline())

            time = @elapsed alg_test(tsp, REPETITIONS, k_random, aux_argument)
        elseif choice == 2
            println("\t+---------------------------------+")
            println("\t|You have chosen Nearest neighbour|")
            println("\t+---------------------------------+")

            print("\nPlease enter the starting node: ")
            aux_argument = parse(Int, readline())

            time = @elapsed alg_test(tsp, 1, nearest_neighbour, aux_argument)            
        elseif choice == 3
            println("\t+------------------------------------------+")
            println("\t|You have chosen Extended nearest neighbour|")
            println("\t+------------------------------------------+")

            time = @elapsed alg_test(tsp, 1, extended_neighbour)
        elseif choice == 4
            println("\t+---------------------+")
            println("\t|You have chosen 2-OPT|")    
            println("\t+---------------------+")

            time = @elapsed alg_test(tsp, REPETITIONS, two_opt)
        elseif choice == 5
            println("\t+---------------------------+")
            println("\t|You have chosen Tabu search|")    
            println("\t+---------------------------+")

            print("\n/ Choose starting solution algorithm for Tabu search:\n")
            print("| 1. Random array\n| 2. K-random\n| 3. Extended nearest neighbour\n| 4. 2-OPT\n")
            print("\\ Your choice: ")
            alg_choice = parse(Int, readline())
            
            if alg_choice == 1
                time = @elapsed alg_test(tsp, REPETITIONS, tabu_search, k_random, 1)
            elseif alg_choice == 2
                print("\nPlease enter the K-value: ")
                aux_argument = parse(Int, readline())
                time = @elapsed alg_test(tsp, REPETITIONS, tabu_search, k_random, aux_argument)
            elseif alg_choice == 3
                time = @elapsed alg_test(tsp, 1, tabu_search, extended_neighbour)
            elseif alg_choice == 4
                time = @elapsed alg_test(tsp, REPETITIONS, tabu_search, two_opt)
            end
        else
            println("Please enter correct number!\n")
        end

        println("Time elapsed: ", time, "s")
        println()
        
        choice = 0
        
        println("================================================")
        println()
        println("Do you want to repeat tests for other algorithm?")
        println("1. Yes")
        println("2-0. Exit app")
        print("Your choice: ")
        choice = parse(Int, readline())

        if choice == 1
            println("Going back")
        else 
            println("\n================================================\n")
            exit_flag = true
        end
    end
end

main()
