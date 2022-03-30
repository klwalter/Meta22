using TSPLIB

path = "TSP/a280.opt.tour"
file = open(path, "r")
solution = Int[]
numbers = false
for line in eachline(file)
    
    #println(line)
    if line == "-1"
        break
    end

    if numbers
        liczba = parse(Int, line)
        append!(solution, liczba)
    end

    if line == "TOUR_SECTION"
        global numbers = true
    end

end
println(solution)