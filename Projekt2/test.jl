using DataStructures
lista = [1,2,3]
s = Stack{Vector}()
push!(s,lista)
x,y = pop!(s)
println(x)
println(y)