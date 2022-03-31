# using Random

for i in 1:10
    n = 50*i
    name = "cum$n.tsp"
    seed = rand(Int,1)
    println(seed[1])
end