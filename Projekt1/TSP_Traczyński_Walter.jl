using TSPLIB
using Random

#########################
# Wczytywanie instancji #
#########################

function load_tsp()
    println()
    print("Enter the name of the instance with extension: ")
    name = chomp(readline())
    path = "TSP/" * name

    return readTSP(path)
end

#########################
# Generowanie instancji #
#########################

function random_instance(size::Number, seed::Number, range::Number, name::String, type::String)
    rng = Random.MersenneTwister(seed)
    points = convert(Array{Float64},rand(rng, 1:range, size, 2))

    file = open("TSP/" * name, "w") 
    napis = "NAME: $name\nTYPE: TSP\nCOMMENT: User-generated TSP file\nDIMENSION: $size\nEDGE_WEIGHT_TYPE: EUC_2D\nNODE_COORD_SECTION\n" 
    
    write(file,napis)
    for i in 1:size
        x, y = points[i, 1], points[i, 2]
        write(file, "$i $x $y\n")
    end
    write(file, "EOF\n\n")
    close(file)
    tsp = readTSP("TSP/" * name)
    
    if type == "FULL_MATRIX"
        napis = "NAME: $name\nTYPE: TSP\nCOMMENT: User-generated TSP file\nDIMENSION: $size\nEDGE_WEIGHT_TYPE: FULL_MATRIX\nEDGE_WEIGHT_SECTION\n" 
        file = open("TSP/" * name, "w")
        write(file,napis)
        mat = tsp.weights
        s = tsp.dimension
        for i in 1:s
            for j in 1:s
                x = mat[i,j]
                write(file, "$x ")
            end
            write(file, "\n")
        end
    elseif type == "LOWER_DIAG_ROW"
        napis = "NAME: $name\nTYPE: TSP\nCOMMENT: User-generated TSP file\nDIMENSION: $size\nEDGE_WEIGHT_TYPE: LOWER_DIAG_ROW\nEDGE_WEIGHT_SECTION\n" 
        file = open("TSP/" * name, "w")
        write(file,napis)
        mat = tsp.weights
        s = tsp.dimension

        for i in 1:s
            for j in 1:i
                x = mat[i,j]
                write(file, "$x")
                write(file, "\n")
            end
        end
    end
    write(file, "EOF\n\n")
    close(file)
    println(tsp.weights)
    return tsp
end
################
# Funkcja celu #
################

function objective_function(tsp_data::TSP, result::Vector{Int})
    distance_matrix = tsp_data.weights
    sum = 0
    l = length(result)
    sum = distance_matrix[result[l],result[1]]
    for n in 1:l-1
        sum = sum + distance_matrix[result[n], result[n+1]]           
    end

    return sum
end

#######
# PRD #
#######

function PRD(tsp_data::TSP, x::Vector{Int}, f_ref::Float64)
    return 100*(objective_function(tsp_data, x) - f_ref)/f_ref
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

    while nodes_done < size # lecimy tak d??ugo, a?? nie zostanie nam 1 wierzcho??ek
        for i in 1:size # interujemy po wszystkich wierzcho??kach
            if status[i] == 1 # sprawdzamy czy wierzcho??ek by?? odwiedzony
                temp_node = i
                temp_distance = distance_matrix[solution[nodes_done], i] # solution[nodes_done] = numer ostanio dodanego wierzcho??ka
                break # wybrali??my pierwszy wierzcho??ek o statusie 1
            end
        end
        for i in temp_node+1:size
            if status[i] == 1 # kolejny nieodwiedzony wierzcho??ek
                new_distance = distance_matrix[solution[nodes_done], i] # sprawdzamy odleg??o???? do nowego wierzcho??ka 
                if temp_distance > new_distance # Je??eli kolejny wiercho??ek jest bli??ej to zmieniamy
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
    local solution = shuffle(rng, Vector(1:size))   # Wybieramy losowe rozwi??nie pocz??tkowe
    function swap(x, y, list)
        swapped = copy(list)
        swapped[x], swapped[y] = swapped[y], swapped[x]
        return swapped
    end

    local improved_flag = true
    local current_new_solution = solution            # current_solution to kandydat na lepsze rozwi??zanie
    local best_dist = objective_function(tsp_data, solution)
    while improved_flag == true
        improved_flag = false
        
        for i in 2:size-1                            # W tych dw??ch p??tlach sprawdzamy wszystkich s??siad??w obecnego rozwi??zania
            for j in i+1:size
                new_solution = swap(i, j, solution)
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

################
# LOAD OPTIMUS #
################

function get_optimal(variant::String)
    path = "TSP/opt"
    file = open(path, "r")
    local dist = 0
    local found = false
    for line in eachline(file)
        if line == "-1"
            break
        end
        i = 1
        while line[i] != ':'
            i += 1
        end
        name = line[1:i-1]
        dist = parse(Float64,line[i+1: length(line)])
        
        if variant == name
            found = true
            break
        end
    end

    return [found, dist]
end
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
    repetitions = 100
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

            time = @elapsed alg_test(tsp, nearest_neighbour, objective_function, repetitions, a)            
        elseif choice == 3
            println("You have chosen Extended nearest neighbour")

            time = @elapsed alg_test(tsp, extended_neighbour, objective_function, repetitions)
        elseif choice == 4
            println("You have chosen 2-OPT")    

            time = @elapsed alg_test(tsp, two_opt, objective_function, repetitions)
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
