using Graphs, GraphIO
using OMEinsum
using CSV, DataFrames
using GenericTensorNetworks, ProblemReductions
using CUDA, CuTropicalGEMM
using BenchmarkTools

function solve_net(net)
    solve(net, SizeMax(), T = Float32, usecuda = true)
    return nothing
end

function qubo_runtime()
    graph = loadgraph("../data/qubo/complete_n60/graph_1.dot")
    code = readjson("../data/qubo/complete_n60/eincode_1.json")
    net = GenericTensorNetwork(IndependentSet(graph), code, Dict{Int, Int}())

    @show contraction_complexity(code, uniformsize(code, 2))

    t = @elapsed solve_net(net)
    @info "first run" t

    t = @elapsed solve_net(net)
    @info "second run" t
end

qubo_runtime()