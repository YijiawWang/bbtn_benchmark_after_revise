using CUDA, CuTropicalGEMM
using Graphs, GraphIO
using CSV, DataFrames
using OMEinsum, GenericTensorNetworks, ProblemReductions
using BenchmarkTools

CUDA.device!(1)

function tn_runtime(n)
    dir = @__DIR__
    df = joinpath(dir, "../data/runtime/ksg_n$(n)_tn_a800.csv")
    CSV.write(df, DataFrame(name = String[], runtime = Float64[]))

    graphs = loadgraphs(joinpath(dir, "../graphs/random_ksg/ksg_n$(n).dot"))

    for i in 1:10
        g = graphs["$i"]

        code = readjson(joinpath(dir, "../graphs/random_ksg/order/treesa_original_ksg_n$(n)_s$(i).json"))
        net = GenericTensorNetwork(IndependentSet(g), code, Dict{Int, Int}())

        cc = contraction_complexity(code, uniformsize(code, 2))

        if cc.sc <= 31 
            t = @belapsed solve_net(net)
            @show i, t
            CSV.write(df, DataFrame(name = i, runtime = t), append = true)
        end
    end
    nothing
end


for n in 30:5:50
    tn_runtime(n)
end