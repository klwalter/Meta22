include("heuritics.jl")
include("utilities.jl")

###########
#  TESTS  #
###########

function alg_test(tsp_data::TSP, algorithm::Function, objective::Function, reps::Int, aux_args...)
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
            if rem(i, (reps/10)) == 0
                println("$i out of $reps tests done (", (i/reps)*100, "%)")
            end
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
    println("Choose an option from menu below:")
    println("1. Load existing instance")
    println("2. Generate new instance")
    print("Your choice: ")
    choice = parse(Int, readline())

    if choice == 1
        tsp = load_tsp()
    elseif choice == 2
        println()
        print("Please enter parameters for generator:\nNumber of nodes: ")
        a = parse(Int, readline())

        print("Seed for RNG: ")
        b = parse(Int, readline())

        print("Range of values (from 1 to X): ")
        c = parse(Int, readline())

        print("Enter the name of the instance with extension: ")
        d = convert(String, chomp(readline()))
        
        print("Enter type (FULL_MATRIX, LOWER_DIAG_ROW, EUC_2D): ")
        e = convert(String, chomp(readline()))

        tsp = random_instance(a, b, c, d, e)
    else
        println("\nPlease enter correct number\n")
        return -1
    end

    while exit_flag == false
        println()
        println("Choose which algorithm you want to use:")
        println("1. K-random")
        println("2. Nearest neighbour")
        println("3. Extended nearest neighbour")
        println("4. 2-OPT")
        println("5. TS")
        print("Your choice: ")
        choice = parse(Int, readline())
        println()
        
        if choice == 1
            println("You have chosen K-random")
            print("Please enter the K-value: ")
            a = parse(Int, readline())

            time = @elapsed alg_test(tsp, k_random, objective_function, repetitions, a)
        elseif choice == 2
            println("You have chosen Nearest neighbour")
            print("Please enter the starting node: ")
            a = parse(Int, readline())

            time = @elapsed alg_test(tsp, nearest_neighbour, objective_function, 1, a)            
        elseif choice == 3
            println("You have chosen Extended nearest neighbour")

            time = @elapsed alg_test(tsp, extended_neighbour, objective_function, 1)
        elseif choice == 4
            println("You have chosen 2-OPT")    

            time = @elapsed alg_test(tsp, two_opt, objective_function, repetitions)
        elseif choice == 5
            println("You have chosen TS")    
            sol = extended_neighbour(tsp)
            time = @elapsed alg_test(tsp, tabu, objective_function, repetitions, sol)
        else
            println("Please enter correct number!\n")
        end

        println("Time elapsed: ", time, "s")
        println()
    
        choice = 0
        
        println()
        println("Do you want to repeat tests for other algorithm?")
        println("1. Yes")
        println("2-0. Exit app")
        print("Your choice: ")
        choice = parse(Int, readline())

        if choice == 1
            println("Going back")
        else 
            exit_flag = true
        end
    
    end
end

main()
