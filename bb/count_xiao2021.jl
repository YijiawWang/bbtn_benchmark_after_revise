using CSV, DataFrames
using OptimalBranching.OptimalBranchingMIS
using Graphs, GraphIO
using Random

function count_xiao2021(n)
    dir = @__DIR__
    csv_file = joinpath(dirname(@__DIR__), "data/count_vc", "ksg_n$(n)_count_xiao2021.csv")

    filename = joinpath(dir, "../graphs/random_ksg/ksg_n$(n).dot")
    graphs = loadgraphs(filename)

    counts = zeros(Int, 10)
    times = zeros(Float64, 10)
    Threads.@threads for i in 1:10
        g = graphs["$i"]
        Random.seed!(i)
        weights = [abs(randn()) for _ in 1:nv(g)]
        start_time = time()
        res = counting_xiao2021(g, weights)
        times[i] = time() - start_time
        counts[i] = res.count
        @info "ksg_n$(n)_$(i), count = $(res.count), time = $(times[i])"
    end
    CSV.write(csv_file, DataFrame(id = 1:10, count = counts, time = times))
    @info "Done"
end

g = loadgraphs(joinpath(@__DIR__, "../graphs/random_ksg/ksg_n30.dot"))["1"]
counting_xiao2021(g, [abs(randn()) for _ in 1:nv(g)])

for n in 30:5:55
    count_xiao2021(n)
end 