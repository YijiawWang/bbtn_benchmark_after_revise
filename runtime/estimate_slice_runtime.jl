using Graphs, GraphIO
using OMEinsum
using CSV, DataFrames
using GenericTensorNetworks, ProblemReductions
using CUDA, CuTropicalGEMM
using BenchmarkTools

CUDA.device!(4)
CUDA.allowscalar(false)

include("run_slice.jl")

function solve_net(net)
    solve(net, SizeMax(), T = Float32, usecuda = true)
    return nothing
end

function estimate_slice_runtime(n, ids)

    dir = @__DIR__
    graphs = loadgraphs(joinpath(dir, "../graphs/random_ksg/ksg_n$(n).dot"))
    df = joinpath(dir, "../data/runtime/ksg_n$(n)_slice31_ds_contract.csv")
    CSV.write(df, DataFrame(name = String[], runtime = Float64[]))

    for i in ids
        g = graphs["$i"]
        code = readjson(joinpath(dir, "../graphs/random_ksg/order/slice31_original_ksg_n$(n)_s$(i)_treesa.json"))
        net = GenericTensorNetwork(IndependentSet(g), code, Dict{Int, Int}())
        t = @belapsed solve_net($net)
        @show i, t, length(code.slicing)
        CSV.write(df, DataFrame(name = i, runtime = t * 2^length(code.slicing)), append = true)
    end

    return nothing
end

estimate_slice_runtime(80, [1:10...])