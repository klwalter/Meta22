from fileinput import close
import readline
from matplotlib import pyplot as plt
import json as js
import numpy as np

file = open("berlin_k_random_test.txt", "r")
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

plt.plot(arguments, values)
z = np.polyfit(arguments,values,11)
p = np.poly1d(z)
plt.plot(arguments, p(arguments), 'r--')
# x = np.average(values)
# arr = [x] * len(values)
# plt.plot(arguments,arr)
#plt.ylim(-0.05,2)
plt.savefig("berlin_krand_prd_0.png")