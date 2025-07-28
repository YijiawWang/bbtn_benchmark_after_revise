using Graphs, GraphIO
using OMEinsum
using CSV, DataFrames
using GenericTensorNetworks, ProblemReductions
using CUDA, CuTropicalGEMM
using BenchmarkTools

function solve_nets(nets)
    for net in nets
        solve(net, SizeMax(), T = Float32, usecuda = true)
    end
    nothing
end

function solve_net(net)
    solve(net, SizeMax(), T = Float32, usecuda = true)
    return nothing
end

function different_target_runtime()
    n = 70
    i = 7

    df = "../data/runtime/slice_runtime_ksg_n$(n).csv"
    CSV.write(df, DataFrame(name = String[], ds = Int[], runtime = Float64[]))

    for ds in 1:5
        dir = "/Einstein/xzgao/tnbb_jlds/random_ksg/$(n)_$(i)_ds$(ds)/"
        branch_df = CSV.read(joinpath(dir, "slices.csv"), DataFrame)
        nets = []
        for id in branch_df.id
            g = loadgraph(joinpath(dir, "graph_$(id).dot"))
            code = readjson(joinpath(dir, "eincode_$(id).json"))
            net = GenericTensorNetwork(IndependentSet(g), code, Dict{Int, Int}())
            push!(nets, net)
        end
        t = @belapsed solve_nets($nets)
        @show i, ds, t
        CSV.write(df, DataFrame(name = i, ds = ds, runtime = t), append = true)
    end
    nothing
end

function contract_runtime()
    n = 70
    # ids = [3, 2, 4, 5, 7, 9, 10]
    ids = [7, 9, 10]
    dir = @__DIR__

    graphs = loadgraphs(joinpath(dir, "../graphs/random_ksg/kernelized_tn_ksg_n$(n).dot"))

    df = joinpath(dir, "../data/runtime/contract_runtime_n$(n).csv")
    # CSV.write(df, DataFrame(name = String[], tnbb_runtime = Float64[], ds_runtime = Float64[]))

    for id in ids
        dir = "/Einstein/xzgao/tnbb_jlds/random_ksg/$(n)_$(id)_sc31/"
        branch_df = CSV.read(joinpath(dir, "slices.csv"), DataFrame)
        nets = []
        for id in branch_df.id
            g = loadgraph(joinpath(dir, "graph_$(id).dot"))
            code = readjson(joinpath(dir, "eincode_$(id).json"))
            net = GenericTensorNetwork(IndependentSet(g), code, Dict{Int, Int}())
            push!(nets, net)
        end
        tnbb_runtime = @belapsed solve_nets($nets)
        @show id, tnbb_runtime

        sliced_code = readjson(joinpath(@__DIR__, "../graphs/random_ksg/order/slice31_tn_ksg_n$(n)_s$(id)_treesa.json"))
        slice_net = GenericTensorNetwork(IndependentSet(graphs["$id"]), sliced_code, Dict{Int, Int}())
        ds_runtime = @belapsed solve_net($(slice_net))
        @show id, ds_runtime

        CSV.write(df, DataFrame(name = id, tnbb_runtime = tnbb_runtime, ds_runtime = ds_runtime), append = true)
    end
    nothing
end

contract_runtime()
