using Graphs, GraphIO
using OMEinsum
using CSV, DataFrames
using TensorBranching
using ProblemReductions

function tnbb_krksg_different_target(n)
    dir = @__DIR__
    filename = joinpath(dir, "../graphs/random_ksg/kernelized_tn_ksg_n$(n).dot")
    @show filename
    graphs = loadgraphs(filename)

    data = CSV.read(joinpath(dir, "../data/kernelize/tn_ksg_n$(n).csv"), DataFrame)

    df = "data/complexity/random_ksg/tnbb_different_target_freoptimize_n$(n).csv"
    # CSV.write(df, DataFrame(name = String[], target = Int[], total_tc = Int[], num_branch = Int[]))

    for i in [4]
        g = graphs["$i"]
        r = data[data.name .== i, :r][1]
        @show i, nv(g), ne(g), r
        code = readjson(joinpath(dir, "../graphs/random_ksg/order/treesa_tn_ksg_n$(n)_s$(i)_treesa.json"))
        original_cc = mis_complexity(code)
        for target in 24:-2:16
            slicer = ContractionTreeSlicer(sc_target = target, refiner = TreeSARefiner(reoptimize = false))
            # reducer = TensorNetworkReducer(sub_reducer = XiaoReducer())
            reducer = XiaoReducer()
            branch = SlicedBranch(g, UnitWeight(nv(g)), code, r)
            dirname = "/Einstein/xzgao/tnbb_jlds/random_ksg/$(n)_$(i)_target$(target)/"
            slice_bfs_rw(branch, slicer, reducer, dirname, 1)

            branch_df = CSV.read(joinpath(dirname, "slices.csv"), DataFrame)
            num_branches = length(branch_df.id)
            total_tc = log2(sum(2.0 .^ branch_df.tc))
            @show i, target, num_branches, total_tc

            CSV.write(df, DataFrame(name = i, target = target, total_tc = total_tc, num_branch = num_branches), append = true)
        end
    end

    return nothing
end

tnbb_krksg_different_target(80)
