from cProfile import label
from fileinput import close
import readline
from matplotlib import pyplot as plt
import json as js
import numpy as np

file = open("data/1/PRD_berlin_2opt.txt", "r")
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
    y = float(line[i+1:-1])
    arguments.append(x)
    values.append(y)

plt.plot(arguments, values, label='2opt')
z = np.polyfit(arguments,values,5)
p = np.poly1d(z)
plt.plot(arguments, p(arguments), 'b--')


file = open("data/1/PRD_berlin.txt", "r")
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
    y = float(line[i+1:-1])
    arguments.append(x)
    values.append(y)

plt.plot(arguments, values, label='random')
z = np.polyfit(arguments,values,5)
p = np.poly1d(z)
plt.plot(arguments, p(arguments), '--', color='orange')

file = open("data/1/PRD_berlin_nn.txt", "r")
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
    y = float(line[i+1:-1])
    arguments.append(x)
    values.append(y)

plt.plot(arguments, values, label='extended_neighbour')

plt.legend()


# z = np.polyfit(arguments,values,15)
# p = np.poly1d(z)
# plt.plot(arguments, p(arguments), 'b--')


# x = np.average(values)
# arr = [x] * len(values)
# plt.plot(arguments,arr)
#plt.ylim(-0.05,2)
plt.savefig("plots/1/berlin.png")