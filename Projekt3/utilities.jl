using TSPLIB


##########################
# Load existing instance #
##########################

function load_tsp()::TSP
    print("\n> Enter the name of the instance with extension: ")
    name::String = chomp(readline())
    path::String = "TSP/" * name

    return readTSP(path)
end

#########################
# Generate new instance #
#########################

function random_instance(asymmetric::Bool, type::String, size::Integer, seed::Integer, range::Integer, name::String)::TSP
    rng::MersenneTwister = Random.MersenneTwister(seed)
    points::Array{Float64} = convert(Array{Float64}, rand(rng, 1:range, size, 2))

    file::IOStream = open("TSP/" * name, "w") 
    header::String = "NAME: $name\nTYPE: TSP\nCOMMENT: User-generated TSP file\nDIMENSION: $size\nEDGE_WEIGHT_TYPE: EUC_2D\nNODE_COORD_SECTION\n" 
    
    write(file, header)
    for i in 1:size
        x, y = points[i, 1], points[i, 2]
        write(file, "$i $x $y\n")
    end
    write(file, "EOF\n\n")
    close(file)
    
    tsp::TSP = readTSP("TSP/" * name)
    mat::Matrix{Float64} = tsp.weights
    s::Int = tsp.dimension
    
    if type == "FULL_MATRIX"
        file = open("TSP/" * name, "w")
        header = "NAME: $name\nTYPE: TSP\nCOMMENT: User-generated TSP file\nDIMENSION: $size\nEDGE_WEIGHT_TYPE: FULL_MATRIX\nEDGE_WEIGHT_SECTION\n" 

        write(file, header)
    
        if asymmetric
            for i in 1:size
                for j in 1:size
                    if i == j
                        j = 0.0
                    else
                        j = convert(Float64, rand(rng, 1:range))
                    end
                    write(file, "$j ")
                end
                write(file, "\n")
            end
        else
            for i in 1:s
                for j in 1:s
                    x = mat[i,j]
                    write(file, "$x ")
                end
                write(file, "\n")
            end
        end
    elseif type == "LOWER_DIAG_ROW"
        file = open("TSP/" * name, "w")
        header = "NAME: $name\nTYPE: TSP\nCOMMENT: User-generated TSP file\nDIMENSION: $size\nEDGE_WEIGHT_TYPE: LOWER_DIAG_ROW\nEDGE_WEIGHT_SECTION\n" 

        write(file,header)

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
    
    return tsp
end

######################
# Objective function #
######################

function objective_function(tsp_data::TSP, result::Vector{<:Integer})::Float64
    distance_matrix::Matrix{Float64} = tsp_data.weights
    sum::Float64 = 0
    l::Int = length(result)

    sum = distance_matrix[result[l],result[1]]
    for n in 1:l-1
        sum = sum + distance_matrix[result[n], result[n+1]]           
    end

    return sum
end

########################
# Get PRD of solution  #
########################

function PRD(tsp_data::TSP, x::Vector{<:Integer}, f_ref::Float64)::Float64
    return 100 * (objective_function(tsp_data, x) - f_ref)/f_ref
end

################
# LOAD OPTIMUS #
################

function get_optimal(variant::String)::Tuple{Bool, Float64}
    path::String = "TSP/opt"
    file::IOStream = open(path, "r")
    
    dist::Float64 = 0.0
    found::Bool = false

    for line in eachline(file)
        i = 1

        if line == "-1"
            break
        end

        while line[i] != ':'
            i += 1
        end

        name::String = line[1:i-1]
        dist = parse(Float32, line[i+1: length(line)])
    
        if variant == name
            found = true
            break
        end
    end

    return(found, dist)
end

##########
# Invert #
##########

function invert(x::Integer, y::Integer, list::Vector{<:Integer})
    inverted::Vector{Int} = copy(list)
    inverted[x:y] = inverted[y:-1:x]
    return inverted
end

########
# Swap #
########

function swap(x::Integer, y::Integer, list::Vector{<:Integer})
    swapped::Vector{Int} = copy(list)
    swapped[x], swapped[y] = swapped[y], swapped[x]
    return swapped
end

##############
# Find index #
##############

function find_index(list::Vector{Int}, element::Int)
    size::Int = length(list)
    for i in 1:size
        if list[i] == element
            return i
        end
    end
    return 0
end
