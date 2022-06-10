from cProfile import label
from matplotlib import pyplot as plt
import numpy as np

tsp_instances = ["bays29","berlin52","eil76","eil101","bier127","ch150"]
crossovers_name = ["order", "double", "mapped"]
mutacja_name = ["invert", "swap"]
populations_name = ["random", "nearest_neighbour", "two_opt"]
mutation_chance = [(i+1)/1000 for i in range(10)]
multipliers = [i+1 for i in range(20)]

def plot(file, title_name, x_name, y_name):
    lista = []
    for line in file:
        lista.append(line)
    file.close()
    arguments = []
    values = []
    for line in lista:
        n = len(line)
        i = 1
        while line[i] != ":": 
            i += 1
        x = int(line[:i])
        y = float(line[i+1:-1])/x**2
        arguments.append(x)
        values.append(y)
    plt.plot(arguments, values)
    plt.xlabel(x_name)
    plt.ylabel(y_name)
    plt.title(title_name)
    plt.savefig("Plots/" + title_name)
    # plt.show()
# file = open("Dane/time/results", "r")
# plot(file, "Time(n) \\ n^2", "n = Instance size", "Time elapsed[s]")
# file.close()

def hist(path, title_name, tsp_name, value_name, x_label, y_label):
    zd = -0.5*(len(value_name) - 1)
    for napis1 in value_name: # To będzie w legendzie

        values = []
        for napis2 in tsp_name: # To będzie na dole

            file = open(path + napis2 + "_" + napis1, "r")
            lista = []
            for line in file:
                lista.append(line)
            file.close()

            for line in lista:
                n = len(line)
                i = 1
                while line[i] != ":": 
                    i += 1

                y = float(line[:i])
                values.append(y)

        print(values)
        pos = np.arange(len(tsp_name))
        bar_width = 0.2
        move = zd*bar_width
        plt.bar(pos+move, values, bar_width, label = napis1)
        zd+=1
    plt.xticks(pos,tsp_name)
    plt.xlim([-1,6])
    plt.title(title_name)
    plt.xlabel(x_label)
    plt.ylabel(y_label)
    plt.legend()
    plt.show()

# hist("Dane/mutation/","Mutations", tsp_instances, mutacja_name, "Instance's name","PRD")
# hist("Dane/crossover/", "Crossover", tsp_instances, crossovers_name, "Instance's name","PRD")
hist("Dane/population/", "Population", tsp_instances, populations_name,"Instance's name","PRD")