using Random
rng = Random.MersenneTwister(213312)
points = rand(rng, 1:100, 10, 2) # Macierz size x 2
x = points[1, 2]
println(x)
println(points)