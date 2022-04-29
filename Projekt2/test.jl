using DataStructures
lista = [1,2,3]
function d(x::Vector{Int64})
    x[2] = 5
end

d(lista)

println(lista)