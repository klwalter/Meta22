from cProfile import label
from matplotlib import pyplot as plt
import numpy as np

tsp_instances = ["bays29","berlin52","eil76","eil101","bier127","ch150"]
crossovers_name = ["order", "double", "mapped"]
mutacja_name = ["invert", "swap"]
populations_name = ["random", "nearest_neighbour", "two_opt"]
mutation_chance = [(i+1)/1000 for i in range(10)]
multipliers = [i+2 for i in range(19)]

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
        y = float(line[i+1:-1])/x**3
        arguments.append(x)
        values.append(y)
    plt.plot(arguments, values)
    plt.xlabel(x_name)
    plt.ylabel(y_name)
    plt.title(title_name)
    # plt.savefig("Plots/" + title_name)
    # plt.clf()
    plt.show()
file = open("Dane/time/results", "r")
plot(file, "Time_quotient_3", "n = Instance size", "Time elapsed[s]")
file.close()

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
    # plt.show()
    plt.savefig("Plots/" + title_name)
    plt.clf()


# hist("Dane/mutation/","Mutations", tsp_instances, mutacja_name, "Instance's name","PRD")
# hist("Dane/crossover/", "Crossover", tsp_instances, crossovers_name, "Instance's name","PRD")
# hist("Dane/population/", "Population", tsp_instances, populations_name,"Instance's name","PRD")

def plot2(path, tsp_name, value_name, title_name, x_name, y_name):
    for tsp_problem in tsp_name:
        arguments = [i+1 for i in range(len(value_name))]
        values = []
        for chance in value_name:
            file = open(path + tsp_problem + "_" + str(chance))
            lista = []
            for line in file:
                lista.append(line)
            file.close()
            for line in lista:
                n = len(line)
                i = 1
                while line[i] != ":": 
                    i += 1
                x = float(line[:i])
                values.append(x)
        plt.plot(arguments, values, label = tsp_problem)
    plt.xlabel(x_name)
    plt.ylabel(y_name)
    plt.legend()
    plt.title(title_name)
    plt.savefig("Plots/" + title_name)
    plt.clf()
    # plt.show()
# plot2("Dane/multipliers/", tsp_instances[:3], multipliers, "Multipliers for dimension size sub 100", "Multiplier value", "PRD")
# plot2("Dane/multipliers/", tsp_instances[3:], multipliers, "Multipliers for dimension size over 100", "Multiplier value", "PRD")
# plot2("Dane/chance/", tsp_instances[:3], mutation_chance, "Mutation for dimension size chance sub 100", "Mutation chance value", "PRD")
# plot2("Dane/chance/", tsp_instances[3:], mutation_chance, "Mutation for dimension size chance over 100", "Mutation chance value", "PRD")

