include("heuristics.jl")
include("utilities.jl")
include("tabu.jl")
include("genetic.jl")

const REPETITIONS = 10

#####################
# Algorithm testing #
#####################

function alg_test(tsp_data::TSP, reps::Integer, algorithm::Function, aux_args...)
    print("\n\n===========================[ TESTING ]===========================")
    print("\n\n> Currently tested TSP file:")
    print("\n|-> Name: ", tsp_data.name)
    print("\n|-> Nodes: ", tsp_data.dimension)
    print("\n|-> Variant: ", tsp_data.weight_type)
    print("\n|-> Algorithm: ", algorithm)
    print("\n|-> Repetitions: ", reps)
    print("\n\\--> Progress:")


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
            print("\n$i out of $reps tests done (", (i/reps)*100, "%)")
        end
    end

    print("\n\n===========================[ RESULTS ]===========================")
    print("\n\n|-> Best path found: ", best_path)
    print("\n|-> Best distance found: ", best_dist)

    if opt_pair[1] == true
        optimal_dist::Float64 = opt_pair[2]
        print("\n|-> PRD: ", PRD(tsp_data, best_path, optimal_dist), "%")
    else
        print("\n|-> Optimal tour file doesn't exist, can't obtain PRD!")
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
    choice::Int, alg_choice::Int, cross_choice = 0, 0, 0
    time::Float64 = 0

    print("\n========================[ LOAD INSTANCE ]========================")
    print("\n\n> Choose an option from menu below:")
    print("\n|-> 1. Load existing instance")
    print("\n|-> 2. Generate new instance")
    print("\n\\--> Your choice: ")
    choice = parse(Int, readline())

    if choice == 1
        tsp::TSP = load_tsp()
    elseif choice == 2
        print("\nPlease enter parameters for generator:\nAsymmetric format? (1 - true): ")
        asymmetric_flag = parse(Bool, readline())

        if asymmetric_flag != 1
            print("\nType of instance (FULL_MATRIX, LOWER_DIAG_ROW, EUC_2D): ")
            instance_type = convert(String, chomp(readline()))

            if instance_type != "EUC_2D" && instance_type != "FULL_MATRIX" && instance_type != "LOWER_DIAG_ROW"
                print("\nPlease enter correct type of instance\n")
                return
            end
        else
            instance_type = "FULL_MATRIX"
        end

        print("\nNumber of nodes: ")
        nodes_count = parse(Int, readline())

        print("\nSeed for RNG: ")
        seed = parse(Int, readline())

        print("\nRange of values (from 1 to X): ")
        range = parse(Int, readline())

        print("\nEnter the name of the instance with extension: ")
        instance_name = convert(String, chomp(readline()))
        
        tsp = random_instance(asymmetric_flag, instance_type, nodes_count, seed, range, instance_name)
    else
        print("\nPlease enter correct number\n")
        return -1
    end

    while exit_flag == false
        print("\n\n========================[ ALGORITHM MENU ]=======================")
        print("\n\n> Choose which algorithm you want to use:")
        print("\n|-> 1. K-random")
        print("\n|-> 2. Nearest neighbour")
        print("\n|-> 3. Extended nearest neighbour")
        print("\n|-> 4. 2-OPT")
        print("\n|-> 5. Tabu search")
        print("\n|-> 6. Genetic algorithm")
        print("\n\\--> Your choice: ")
        choice = parse(Int, readline())
        print()
        
        if choice == 1
            print("\n\t\t+--------------------------+")
            print("\n\t\t| You have chosen K-random |")
            print("\n\t\t+--------------------------+")

            print("\n\nPlease enter the K-value: ")
            aux_argument = parse(Int, readline())

            time = @elapsed alg_test(tsp, REPETITIONS, k_random, aux_argument)
        elseif choice == 2
            print("\n\t\t+-----------------------------------+")
            print("\n\t\t| You have chosen Nearest neighbour |")
            print("\n\t\t+-----------------------------------+")

            print("\nPlease enter the starting node: ")
            aux_argument = parse(Int, readline())

            time = @elapsed alg_test(tsp, 1, nearest_neighbour, aux_argument)            
        elseif choice == 3
            print("\n\t\t+--------------------------------------------+")
            print("\n\t\t| You have chosen Extended nearest neighbour |")
            print("\n\t\t+--------------------------------------------+")

            time = @elapsed alg_test(tsp, 1, extended_neighbour)
        elseif choice == 4
            print("\n\t\t+-----------------------+")
            print("\n\t\t| You have chosen 2-OPT |")    
            print("\n\t\t+-----------------------+")

            time = @elapsed alg_test(tsp, REPETITIONS, two_opt)
        elseif choice == 5
            print("\n\t\t+-----------------------------+")
            print("\n\t\t| You have chosen Tabu search |")    
            print("\n\t\t+-----------------------------+")

            print("\n\n> Choose starting solution algorithm for Tabu search:")
            print("\n|-> 1. Random array")
            print("\n|-> 2. K-random")
            print("\n|-> 3. Extended nearest neighbour")
            print("\n|-> 4. 2-OPT")
            print("\n\\--> Your choice: ")
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
        elseif choice == 6
            print("\n\t\t+-----------------------------------+")
            print("\n\t\t| You have chosen Genetic algorithm |")    
            print("\n\t\t+-----------------------------------+")

            print("\n\n> Choose starting population generation method:")
            print("\n|-> 1. Random")
            print("\n|-> 2. Extended nearest neighbour")
            print("\n|-> 3. 2-OPT")
            print("\n\\--> Your choice: ")
            alg_choice = parse(Int, readline())

            print("\n\n> Choose starting crossover method:")
            print("\n|-> 1. Ordered crossover")
            print("\n|-> 2. Partially mapped crossover")
            print("\n\\--> Your choice: ")
            cross_choice = parse(Int, readline())
            
            time = @elapsed alg_test(tsp, 1, genetic, alg_choice, cross_choice) 
        else
            print("\nPlease enter correct number!\n")
        end

        print("\n|-> Time elapsed: ", time, "s")
        
        choice = 0
        
        print("\n\n=========================[ REPEAT TEST ]========================")
        print("\n\nDo you want to repeat tests for other algorithm?")
        print("\n1. Yes")
        print("\n2-0. Exit app")
        print("\nYour choice: ")
        choice = parse(Int, readline())

        if choice == 1
            exit_flag = false
        else 
            print("\n\n=========================[ EXITING APP ]=========================\n\n")
            exit_flag = true
        end
    end
end

main()
