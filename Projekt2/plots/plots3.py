from ast import If
from cProfile import label
from fileinput import close
import readline
from matplotlib import pyplot as plt
import json as js
import numpy as np
s1 = ["2opt", "extended neighbour","random"]
s2 = ['bays29', 'berlin52', 'eil76']

zd = -1

ii = 0
for napis2 in s2:

    values = []
    file = open("data/5/"+ napis2 +".txt", "r")
    lista = []
    for line in file:
        lista.append(line)
    file.close()

    for line in lista:
        n = len(line)
        i = 1
        while line[i] != " ": 
            i += 1
        x = line[:i]
        y = float(line[i+1:-1])
        values.append(y)
    print(values)
    pos = np.arange(len(s1))
    bar_width = 0.2
    move = zd*bar_width

    plt.bar(pos+move, values, bar_width, label=s2[ii])
    zd+=1
    ii+=1
plt.xticks(pos,s1)
plt.xlim([-1,3])
plt.legend()
plt.savefig("plots/5/starters.png")