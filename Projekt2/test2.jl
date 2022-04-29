include("heuritics.jl")
include("utilities.jl")

###########
#  TESTS  #
###########

function alg_test(tsp_data::TSP, algorithm::Function, objective::Function, reps::Int, aux_args...)
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


    best_path = []
    best_dist = 0

    pair = get_optimal(tsp_data.name)

    for i in 1:reps
        final_path = algorithm(tsp_data, aux_args...)
        obj_dist = objective(tsp_data, final_path)

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

    if pair[1] == true
        optimal = pair[2]
        println("PRD: ", PRD(tsp_data, best_path, optimal), "%")
    else
        println("Opt tour file doesn't exist, can't obtain PRD!")
    end
end

##########
#  MAIN  #
##########

function main()
    repetitions = 10
    a, b, c, d = 0, 0, 0, 0
    exit_flag = false
    local time = 0

    println()
    println("================================================")
    println("Choose an option from menu below:")
    println("1. Load existing instance")
    println("2. Generate new instance")
    print("Your choice: ")
    choice = parse(Int, readline())
    println("================================================")

    if choice == 1
        tsp = load_tsp()
    elseif choice == 2
        println()
        print("Please enter parameters for generator:\nType of instance (FULL_MATRIX, LOWER_DIAG_ROW, EUC_2D): ")
        a = convert(String, chomp(readline()))

        if a != "EUC_2D" && a != "FULL_MATRIX" && a!= "LOWER_DIAG_ROW"
            println()
            println("Please enter correct type of instance\n")
            return
        end

        print("Number of nodes: ")
        b = parse(Int, readline())

        print("Seed for RNG: ")
        c = parse(Int, readline())

        print("Range of values (from 1 to X): ")
        d = parse(Int, readline())

        print("Enter the name of the instance with extension: ")
        e = convert(String, chomp(readline()))
        
        

        tsp = random_instance(a, b, c, d, e)
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
            a = parse(Int, readline())

            time = @elapsed alg_test(tsp, k_random, objective_function, repetitions, a)
        elseif choice == 2
            println("\t+---------------------------------+")
            println("\t|You have chosen Nearest neighbour|")
            println("\t+---------------------------------+")

            print("\nPlease enter the starting node: ")
            a = parse(Int, readline())

            time = @elapsed alg_test(tsp, nearest_neighbour, objective_function, 1, a)            
        elseif choice == 3
            println("\t+------------------------------------------+")
            println("\t|You have chosen Extended nearest neighbour|")
            println("\t+------------------------------------------+")

            time = @elapsed alg_test(tsp, extended_neighbour, objective_function, 1)
        elseif choice == 4
            println("\t+---------------------+")
            println("\t|You have chosen 2-OPT|")    
            println("\t+---------------------+")

            time = @elapsed alg_test(tsp, two_opt, objective_function, repetitions)
        elseif choice == 5
            println("\t+---------------------------+")
            println("\t|You have chosen Tabu search|")    
            println("\t+---------------------------+")

            print("\n/ Please enter the starting solution algorithm for Tabu search:  \n")
            print("| 1. Random array\n| 2. K-random\n| 3. Extended nearest neighbour\n| 4. 2-OPT\n")
            print("\\ Your choice: ")
            a = parse(Int, readline())
            
            if a == 1
                time = @elapsed alg_test(tsp, tabu_search, objective_function, repetitions, k_random, 1)
            elseif a == 2
                print("\nPlease enter the K-value: ")
                b = parse(Int, readline())
                time = @elapsed alg_test(tsp, tabu_search, objective_function, repetitions, k_random, b)
            elseif a == 3
                time = @elapsed alg_test(tsp, tabu_search, objective_function, repetitions, extended_neighbour)
            elseif a == 4
                time = @elapsed alg_test(tsp, tabu_search, objective_function, repetitions, two_opt)
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
