using Graphs, GraphIO
using JuMP, SCIP
using CSV, DataFrames
using Random

function ip_mis(g::AbstractGraph, weights::Vector{Float64}; optimizer=SCIP.Optimizer, verbose::Bool=false)
    model = Model(optimizer)
    !verbose && set_silent(model)
    n = nv(g)
    @variable(model, 0 <= x[i = 1:n] <= 1, Int)
    @objective(model, Max, sum(weights .* x))
    for e in edges(g)
        @constraint(model, x[src(e)] + x[dst(e)] <= 1)
    end
    optimize!(model)
    @assert is_solved_and_feasible(model)
    return Int(round(sum(value.(x))))
end

function scip_runtime(n)
    dir = @__DIR__
    df = joinpath(dir, "../data/runtime/ksg_n$(n)_weighted_scip.csv") # unkernelized graphs
    CSV.write(df, DataFrame(name = String[], runtime = Float64[]))

    graphs = loadgraphs(joinpath(dir, "../graphs/random_ksg/ksg_n$(n).dot"))

    runtimes = zeros(10)

    Threads.@threads for i in 1:10
        g = graphs["$i"]
        Random.seed!(i)
        weights = [abs(randn()) for _ in 1:nv(g)]
        t = @elapsed ip_mis(g, weights, verbose = false)
        @show i, t
        runtimes[i] = t
    end
    CSV.write(df, DataFrame(name = 1:10, runtime = runtimes), append = true)
end

# scip_runtime(70)

for n in 60:10:100
    scip_runtime(n)
end