using TSPLIB

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