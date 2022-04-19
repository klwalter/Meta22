using DataStructures

q = Queue{Int}()
n = 5
enqueue!(q, n)
enqueue!(q, 2)
enqueue!(q, 3)
enqueue!(q, 7)
dequeue!(q)
println(length(q))