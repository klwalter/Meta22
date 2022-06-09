include("genetic.jl")
using TSPLIB
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

const mutation_chance = [i/1000 for i in 1:10]

const multipliers = [i for i in 2:20]

# crossover
function cross()
    print("\n> cross:")
    for tsp_name in tsp_instances
        tsp = readTSP("TSP/"*tsp_name*".tsp")
        for i in crossovers
            print("\n|->$(tsp.name):  crossover $(crossovers_name[i])")
            file = open("Dane/crossover/"*tsp_name*"_"*crossovers_name[i], "w")
            solution = genetic(tsp, 2, i, 1)
            opt::Tuple{Bool, Float64} = get_optimal(tsp_name)
            prd = PRD(tsp, solution, opt[2])
            dist = objective_function(tsp, solution)
            write(file,"$prd:$dist\n")
            close(file)
        end
    end
end

# mutacja
function mut()
    print("\n> mutation:")
    for tsp_name in tsp_instances
        tsp = readTSP("TSP/"*tsp_name*".tsp")
        for i in mutacja
            print("\n|->$(tsp.name):  mutation $(mutacja_name[i])")
            file = open("Dane/mutation/"*tsp_name*"_"*mutacja_name[i], "w")
            solution = genetic(tsp, 2, 3, i)
            opt::Tuple{Bool, Float64} = get_optimal(tsp_name)
            prd = PRD(tsp, solution, opt[2])
            dist = objective_function(tsp, solution)
            write(file,"$prd:$dist\n")
            close(file)
        end
    end
end

# starting population
function pop()
    print("\n> population:")
    for tsp_name in tsp_instances
        tsp = readTSP("TSP/"*tsp_name*".tsp")
        for i in populations
            print("\n|->$(tsp.name):  population $(populations_name[i])")
            file = open("Dane/population/"*tsp_name*"_"*populations_name[i], "w")
            solution = genetic(tsp, i, 3, 1)
            opt::Tuple{Bool, Float64} = get_optimal(tsp_name)
            prd = PRD(tsp, solution, opt[2])
            dist = objective_function(tsp, solution)
            write(file,"$prd:$dist\n")
            close(file)
        end
    end
end

# chance
function chance()
    print("\n> chance:")
    for tsp_name in tsp_instances
        tsp = readTSP("TSP/"*tsp_name*".tsp")
        for i in mutation_chance
            print("\n|->$(tsp.name):  chance $i")
            file = open("Dane/chance/"*tsp_name*"_"*"i", "w")
            solution = genetic(tsp, 2, 3, 1, i)
            opt::Tuple{Bool, Float64} = get_optimal(tsp_name)
            prd = PRD(tsp, solution, opt[2])
            dist = objective_function(tsp, solution)
            write(file,"$prd:$dist\n")
            close(file)
        end
    end
end

# multipliers
function multi()
    print("\n> multipliers:")
    for tsp_name in tsp_instances
        tsp = readTSP("TSP/"*tsp_name*".tsp")
        for i in multipliers
            print("\n|->$(tsp.name):  chance $i")
            file = open("Dane/multipliers/"*tsp_name*"_"*"i", "w")
            solution = genetic(tsp, 2, 3, 1, 0.005, i)
            opt::Tuple{Bool, Float64} = get_optimal(tsp_name)
            prd = PRD(tsp, solution, opt[2])
            dist = objective_function(tsp, solution)
            write(file,"$prd:$dist\n")
            close(file)
        end
    end
end

cross()
# mut()
# pop()
# chance()
# multi()