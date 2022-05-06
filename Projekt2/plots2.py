from cProfile import label
from fileinput import close
import readline
from matplotlib import pyplot as plt
import json as js
import numpy as np

file = open("data/3/time_comp_rand.txt", "r")
lista = []
for line in file:
    lista.append(line)
file.close()
arguments = []
values = []
for line in lista:
    n = len(line)
    i = 1
    while line[i] != " ": 
        i += 1
    x = int(line[:i])
    y = float(line[i+1:-1])/x
    arguments.append(x)
    values.append(y)

plt.plot(arguments, values, label='random')


file = open("data/3/time_comp_nn.txt", "r")
lista = []
for line in file:
    lista.append(line)
file.close()
arguments = []
values = []
for line in lista:
    n = len(line)
    i = 1
    while line[i] != " ": 
        i += 1
    x = int(line[:i])
    y = float(line[i+1:-1])/x
    arguments.append(x)
    values.append(y)

plt.plot(arguments, values, label='extended neighbour')


# file = open("data/3/time_comp.txt", "r")
# lista = []
# for line in file:
#     lista.append(line)
# file.close()
# arguments = []
# values = []
# for line in lista:
#     n = len(line)
#     i = 1
#     while line[i] != " ": 
#         i += 1
#     x = int(line[:i])
#     y = 10**9*float(line[i+1:-1])/(x**4)
#     arguments.append(x)
#     values.append(y)

# plt.plot(arguments, values, label='2opt')

plt.legend()


# z = np.polyfit(arguments,values,15)
# p = np.poly1d(z)
# plt.plot(arguments, p(arguments), 'b--')


# x = np.average(values)
# arr = [x] * len(values)
# plt.plot(arguments,arr)
plt.ylim(-0.05, 1)
plt.savefig("plots/3/divided_time_rest.png")