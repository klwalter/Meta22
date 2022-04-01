from fileinput import close
import readline
from matplotlib import pyplot as plt
import json as js
import numpy as np

file = open("two_opt_speed_test.txt", "r")
lista = []
for line in file:
    lista.append(line)
file.close()
arguments = []
values = []
for line in lista:
    n = len(line)
    i = 2
    while line[i] != " ": 
        i += 1
    x = int(line[:i])
    y = float(line[i+1:-1]) * 1000000 / x**4
    arguments.append(x)
    values.append(y)

plt.plot(arguments, values)
plt.ylim(-0.05,1)
plt.savefig("two_opt_4.png")