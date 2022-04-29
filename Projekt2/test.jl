inverted = [1,2,3,4,5,6,7,8,9,10]
x = 4
y = 7
inverted[x:y] = inverted[y:-1:x]
println(inverted)
inverted[x:y] = inverted[y:-1:x]
println(inverted)