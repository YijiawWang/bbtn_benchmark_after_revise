using Graphs, GraphIO
using OMEinsum
using CSV, DataFrames
using GenericTensorNetworks, ProblemReductions
using CUDA, CuTropicalGEMM
using BenchmarkTools

CUDA.device!(5)
CUDA.allowscalar(false)

function solve_nets(nets)
    N = length(nets)
    for (i, net) in enumerate(nets)
        @info "Solving $i of $N"
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

function different_target_slice_runtime()
    n = 70
    i = 7

    dir = @__DIR__
    df = "../data/runtime/different_target_slice_runtime_ksg_n$(n).csv"
    # CSV.write(df, DataFrame(name = String[], ds = Int[], runtime = Float64[]))

    graphs = loadgraphs(joinpath(dir, "../graphs/random_ksg/kernelized_tn_ksg_n$(n).dot"))
    g = graphs["$i"]

    for ds in [1]
        target = 32 - ds
        code = readjson(joinpath(dir, "../graphs/random_ksg/order/slice_$(target)_tn_ksg_n$(n)_s$(i)_treesa.json"))
        net = GenericTensorNetwork(IndependentSet(g), code, Dict{Int, Int}())
        t = @belapsed solve_net($net)
        @show i, ds, t

        CSV.write(df, DataFrame(name = i, ds = ds, runtime = t), append = true)
    end
    nothing
end

function contract_runtime(n)
    ids = [1, 2, 3, 4, 6, 7, 8, 9, 10, 5]
    dir = @__DIR__

    graphs = loadgraphs(joinpath(dir, "../graphs/random_ksg/kernelized_tn_ksg_n$(n).dot"))

    # df = joinpath(dir, "../data/runtime/contract_runtime_a800_n$(n).csv")
    df = joinpath(dir, "../data/runtime/ksg_n$(n)_sc31_tnbb_contract.csv")
    CSV.write(df, DataFrame(name = String[], runtime = Float64[]))

    for id in ids
        dirname = "/home/xuanzhaogao/work/tnbb_data/$(n)_$(id)_sc31"
        df_tnbb = CSV.read(joinpath(dirname, "slices.csv"), DataFrame)

        #warmup
        id0 = df_tnbb.id[1]
        g0 = loadgraph(joinpath(dirname, "graph_$(id0).dot"))
        code0 = readjson(joinpath(dirname, "eincode_$(id0).json"))
        net = GenericTensorNetwork(IndependentSet(g0), code0, Dict{Int, Int}())
        solve_net(net)
        
        t = 0.0
        N = length(df_tnbb.id)
        for (i, id) in enumerate(df_tnbb.id)
            g = loadgraph(joinpath(dirname, "graph_$(id).dot"))
            code = readjson(joinpath(dirname, "eincode_$(id).json"))
            net = GenericTensorNetwork(IndependentSet(g), code, Dict{Int, Int}())
            t_id = @elapsed solve_net(net)
            @info "solved $i out of $N in $(t_id)s"
            t += t_id
        end

        @show id, t
        CSV.write(df, DataFrame(name = id, tnbb_runtime = t), append = true)
    end

    nothing
end

contract_runtime(80)
# different_target_slice_runtime()
