using Graphs, GraphIO
using GenericTensorNetworks
using Random

dir = @__DIR__

N = 10
for n in [35, 45]
    dict = Dict{String, SimpleGraph}()
    for i in 1:N
        Random.seed!(i)
        g = SimpleGraph(GenericTensorNetworks.random_diagonal_coupled_graph(n, n, 0.8))
        dict["$i"] = g
    end
    filename = joinpath(dir, "ksg_n$(n).dot")
    savegraph(filename, dict)
end