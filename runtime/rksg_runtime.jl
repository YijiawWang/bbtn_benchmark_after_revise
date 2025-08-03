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

function rksg_runtime(n)
    dir = @__DIR__
    df = "../data/runtime/rksg_runtime_ksg_n$(n).csv"
    CSV.write(df, DataFrame(name = String[], runtime = Float64[]))

    graphs = loadgraphs(joinpath(dir, "../graphs/random_ksg/ksg_n$(n).dot"))

    for i in 1:10
        g = graphs["$i"]
        code = readjson(joinpath(dir, "../graphs/random_ksg/order/treesa_original_ksg_n$(n)_s$(i).json"))
        net = GenericTensorNetwork(IndependentSet(g), code, Dict{Int, Int}())
        cc = contraction_complexity(net)
        (cc.sc >= 32) && continue
        @show i, cc.sc, cc.tc
        t = @belapsed solve_net($net)
        @show i, t
        CSV.write(df, DataFrame(name = i, runtime = t), append = true)
    end
    nothing
end

for n in [30, 35, 40, 45, 50]
    rksg_runtime(n)
end