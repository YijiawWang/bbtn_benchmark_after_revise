using Graphs, GraphIO
using OMEinsum, TensorBranching
using CSV, DataFrames

function extract_complexity(subdir, n)
    dir = @__DIR__
    filename = joinpath(dir, subdir, "ksg_n$(n).dot")
    @show filename
    graphs = loadgraphs(filename)

    scs = zeros(Float64, 10)
    tcs = zeros(Float64, 10)
    rwcs = zeros(Float64, 10)

    Threads.@threads for i in 1:10
        g = graphs["$i"]
        order = initialize_code(g, TreeSA())
        @info n, i, mis_complexity(order)
        order_name = joinpath(dir, subdir, "order/treesa_original_ksg_n$(n)_s$(i).json")
        writejson(order_name, order)
        cc = mis_complexity(order)
        scs[i] = cc.sc
        tcs[i] = cc.tc
        rwcs[i] = cc.rwc
    end
    CSV.write("data/complexity/original_ksg_n$(n).csv", DataFrame(name = 1:10, sc = scs, tc = tcs, rwc = rwcs))
    return nothing
end

for n in [55, 65]
    extract_complexity("../graphs/random_ksg", n)
end