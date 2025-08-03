using CSV, DataFrames
using OptimalBranching.OptimalBranchingMIS
using Graphs, GraphIO
using Random

function count_xiao2021(n)
    dir = @__DIR__
    csv_file = joinpath(dirname(@__DIR__), "data/count_vc", "ksg_n$(n)_count_add_xiao2021.csv")

    filename = joinpath(dir, "../graphs/random_ksg/additional_ksg_n$(n).dot")
    graphs = loadgraphs(filename)

    if n == 30
        res = counting_xiao2021(graphs["1"], [abs(randn()) for _ in 1:nv(graphs["1"])])
        @info "ksg_n$(n)_1, count = $(res.count)"
    end

    N = 50
    counts = zeros(Int, N)
    times = zeros(Float64, N)
    Threads.@threads for i in 1:N
        g = graphs["$i"]
        Random.seed!(i)
        weights = [abs(randn()) for _ in 1:nv(g)]
        start_time = time()
        res = counting_xiao2021(g, weights)
        times[i] = time() - start_time
        counts[i] = res.count
        @info "ksg_n$(n)_$(i), count = $(res.count), time = $(times[i])"
    end
    CSV.write(csv_file, DataFrame(id = 1:N, count = counts, time = times))
    @info "Done"
end

for n in 30:5:70
    count_xiao2021(n)
end 