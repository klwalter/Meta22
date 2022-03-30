using Random
using TSPLIB
function random_instance(size::Number, seed::Number, range::Number)
    rng = Random.MersenneTwister(seed)
    points = convert(Array{Float64},rand(rng, 1:range, size, 2)) # Macierz size x 2
    file = open("TSP/temp.tsp", "w") 
    napis = "NAME: temp\nTYPE: TSP\nCOMMENT: Temporary file, don't worry about it.\nDIMENSION: $size\nEDGE_WEIGHT_TYPE: EUC_2D\nNODE_COORD_SECTION\n" 
    write(file,napis)
    for i in 1:size
        x, y = points[i, 1], points[i, 2]
        write(file, "$i $x $y\n")
    end
    write(file, "EOF\n\n")
    close(file)
end

random_instance(10, 2137, 2000)

# # help = readTSP("TSP/temp.tsp")

# println(help.weights)