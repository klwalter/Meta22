using TSPLIB
using Random

#################################
# Pierwszy fragment kodu szefie #
#################################

function load_tsp(name::String)
    path = "TSP/" * name
    global tsp = readTSP(path)
end

load_tsp("gr120.tsp")
println(tsp.name)
load_tsp("berlin52.tsp")
println(tsp.name)
load_tsp("br17.atsp")
println(tsp.name)

##############################
# Drugi fragment kodu szefie #
##############################

function random_instance(size::Number, seed::Number, variant::String)
    rng = Random.MersenneTwister(seed)
    random_vector = shuffle(rng, Vector(1:size))
    return (random_vector, variant)
end

test = random_instance(5, 124213, "lambda")
println(test)

###############################
# Trzeci fragment kodu szefie #
###############################


function show()
    println(tsp.weight)
end

################################
# Czwarty fragment kodu szefie #
################################

function results(result::Vector{Int})
    println(result)
end

##############################
# Piąty fragment kodu szefie #
##############################

function objective_function(result::Vector{Int})
    # Zakładam, że mamy tu załadowaną instancję problemu
    distance_matrix = tsp.weight
    sum = 0
    l = length(result)
    for n in 1:l-1
        sum = sum + distance_matrix[result[n], result[n+1]]           
    end
    sum = sum + distance_matrix[l,1]
    return sum
end

###############################
# Szósty fragment kodu szefie #
###############################

function PRD(x::Vector{Int}, f_ref::Float32)
    return (objective_function(x) - f_ref)/f_ref
end
