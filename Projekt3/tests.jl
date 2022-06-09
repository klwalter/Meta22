include("genetic.jl")

const tsp_instances = ["bays29","berlin52","eil76","eil101","bier127","ch150"]
#
# Crossobers: 1 = order, 2 = double, 3 = mapped
#
const crossovers = [1, 2, 3]
const crossovers_name = ["order", "double", "mapped"]
#
# mutacja: 1 = invert, 2 = swap
#
const mutacja = [1,2]
const mutacja_name = ["invert", "swap"]
#
# 1 - random, 2 - nearest_neighbour, 3 - two_opt
#
const populations = [1,2,3]
const populations_name = ["random", "nearest_neighbour", "two_opt"]

const mutation_chance = [i/1000 for i in 1:100]