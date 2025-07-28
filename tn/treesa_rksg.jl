using Graphs, GraphIO
using OMEinsum, TensorBranching
using CSV, DataFrames

function extract_complexity(subdir, n)
    dir = @__DIR__
    filename = joinpath(dir, subdir, "ksg_n$(n).dot")
    @show filename
    graphs = loadgraphs(filename)

    df = CSV.write("data/complexity/original_ksg_n$(n).csv", DataFrame(name = String[], sc = Float64[], tc = Float64[], rwc = Float64[]))
    for i in 1:10
        g = graphs["$i"]
        order = initialize_code(g, TreeSA())
        @info n, i, mis_complexity(order)
        order_name = joinpath(dir, subdir, "order/treesa_original_ksg_n$(n)_s$(i).json")
        writejson(order_name, order)
        cc = mis_complexity(order)
        CSV.write(df, DataFrame(name = i, sc = cc.sc, tc = cc.tc, rwc = cc.rwc), append = true)
    end
    return nothing
end

for n in 80:10:100
    extract_complexity("../graphs/random_ksg", n)
end