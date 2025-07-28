using Graphs, GraphIO
using TensorBranching
using TropicalGEMM
using CSV, DataFrames
using ProblemReductions

function kernelize_graphs_tn(subdir, n)
    dir = @__DIR__
    filename = joinpath(dir, subdir, "ksg_n$(n).dot")
    @show filename
    dict = loadgraphs(filename)

    kernelized_dict = Dict{String, SimpleGraph}()
    kernelized_data = Dict()

    df = CSV.write("data/kernelize/tn_ksg_n$(n).csv", DataFrame(name = String[], nv = Int[], ne = Int[], nv_kernelized = Int[], ne_kernelized = Int[], r = Int[]))
    Threads.@threads for i in 1:length(keys(dict))
        key = collect(keys(dict))[i]
        g = dict[key]
        @show key, nv(g), ne(g)
        res = kernelize(g, UnitWeight(nv(g)), TensorNetworkReducer(sub_reducer = XiaoReducer()))
        kernelized_dict[key] = res.g
        @show key, nv(res.g), ne(res.g)
        kernelized_data[key] = (g, res)
    end
    savegraph(joinpath(dir, subdir, "kernelized_tn_ksg_n$(n).dot"), kernelized_dict)

    for (key, (g, res)) in kernelized_data
        CSV.write(df, DataFrame(name = key, nv = nv(g), ne = ne(g), nv_kernelized = nv(res.g), ne_kernelized = ne(res.g), r = res.r), append = true)
    end

    return nothing
end

for n in 30:10:100
    kernelize_graphs_tn("../graphs/random_ksg", n)
end
