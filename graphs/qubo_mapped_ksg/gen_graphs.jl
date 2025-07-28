using Graphs, Random, UnitDiskMapping, GraphIO, GenericTensorNetworks
using LinearAlgebra
using Primes

function save_weights(filename::String, weights::Vector{T}) where T
    # if f ex
    if isfile(filename)
        rm(filename)
    end
    f = open(filename, "w")
    write(f, "$(T)\n")
    for w in weights
        write(f, string(w) * "\n")
    end
    close(f)
    return nothing
end

dir = @__DIR__

for seed in 1:10
    Random.seed!(seed+1000)
    n = 60
    J = triu(randn(n, n), 1)
    J += J'
    h = randn(n) 
    qubo = UnitDiskMapping.map_qubo(J, h)
    qubo_graph, qubo_weights = UnitDiskMapping.graph_and_weights(qubo.grid_graph)
    graph = SimpleGraph(qubo_graph)

    weights = copy(qubo_weights)
    weights = [Float64(w) for w in weights]
    filename = joinpath(dir, "qubo_mapped_ksg_n$(n)_seed=$(seed).dot")
    savegraph(filename, graph)
    filename = joinpath(dir, "qubo_mapped_ksg_n$(n)_seed=$(seed)_weights.txt")
    save_weights(filename, weights)
end