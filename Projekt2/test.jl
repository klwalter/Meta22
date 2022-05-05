using Dates
function f()
    local t1 = Dates.now()
    local t2 = Dates.now() - t1
    local t3 = Second(0)
    while(true)
        t2 = Dates.now() - t1
        for i in 1:100, j in 1:100
            if t2>t3
                println(t2)
                println("dupa")
                return
            end
        end
        println("while")
    end
    println("nie while")
end 

f()

