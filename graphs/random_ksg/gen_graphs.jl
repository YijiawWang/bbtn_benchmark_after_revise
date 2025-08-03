using Graphs, GraphIO
using GenericTensorNetworks
using Random

dir = @__DIR__

# N = 10
# for n in [55, 65, 75]
#     dict = Dict{String, SimpleGraph}()
#     for i in 1:N
#         Random.seed!(i)
#         g = SimpleGraph(GenericTensorNetworks.random_diagonal_coupled_graph(n, n, 0.8))
#         dict["$i"] = g
#     end
#     filename = joinpath(dir, "ksg_n$(n).dot")
#     savegraph(filename, dict)
# end


N = 50
for n in 30:5:70
    dict = Dict{String, SimpleGraph}()
    for i in 1:N
        Random.seed!(i + 10)
        g = SimpleGraph(GenericTensorNetworks.random_diagonal_coupled_graph(n, n, 0.8))
        dict["$i"] = g
    end
    filename = joinpath(dir, "additional_ksg_n$(n).dot")
    savegraph(filename, dict)
end