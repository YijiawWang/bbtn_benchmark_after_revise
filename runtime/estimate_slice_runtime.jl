using Graphs, GraphIO
using OMEinsum
using CSV, DataFrames
using GenericTensorNetworks, ProblemReductions
using CUDA, CuTropicalGEMM
using BenchmarkTools

include("run_slice.jl")

n = 70
i = 7

dir = @__DIR__

function solve_net(net)
    solve(net, SizeMax(), T = Float32, usecuda = true)
    return nothing
end

function main()
    graphs = loadgraphs(joinpath(dir, "../graphs/random_ksg/kernelized_tn_ksg_n$(n).dot"))
    g = graphs["$i"]

    for ds in [1]
        target = 32 - ds
        code = readjson(joinpath(dir, "../graphs/random_ksg/order/slice_$(target)_tn_ksg_n$(n)_s$(i)_treesa.json"))
        net = GenericTensorNetwork(IndependentSet(g), code, Dict{Int, Int}())
        # t = @belapsed solve_net($net)
        # @show i, ds, t

        t = @elapsed solve_net(net)
        @show i, ds, t
    end
end

main()