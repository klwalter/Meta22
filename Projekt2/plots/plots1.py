from ast import If
from cProfile import label
from fileinput import close
import readline
from matplotlib import pyplot as plt
import json as js
import numpy as np
s1 = ["linear", "log2","sqrt","stala"]
s2 = ['ftv33', 'ry48p', 'ft53']
zd = -1.5
for napis1 in s1:

    values = []
    for napis2 in s2:

        file = open("data/2/" + napis1 + "_" + napis2, "r")
        lista = []
        for line in file:
            lista.append(line)
        file.close()

        for line in lista:
            n = len(line)
            i = 1
            while line[i] != " ": 
                i += 1

            y = float(line[i+1:-1])
            values.append(y)
    print(values)
    pos = np.arange(len(s2))
    bar_width = 0.2
    move = zd*bar_width
    if napis1 == 'stala':
        napis1 = 'const (5)'
    plt.bar(pos+move, values, bar_width, label=napis1)
    zd+=1
plt.xticks(pos,s2)
plt.xlim([-1,3])
plt.legend()


# z = np.polyfit(arguments,values,15)
# p = np.poly1d(z)
# plt.plot(arguments, p(arguments), 'b--')


# x = np.average(values)
# arr = [x] * len(values)
# plt.plot(arguments,arr)
#plt.ylim(-0.05,2)
plt.savefig("plots/2/bars_atsp.png")