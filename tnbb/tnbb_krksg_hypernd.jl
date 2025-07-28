using Graphs, GraphIO
using OMEinsum
using CSV, DataFrames
using TensorBranching
using ProblemReductions
using KaHyPar, Metis
using OMEinsumContractionOrders: METISND, KaHyParND

function tnbb_krksg(n)
    dir = @__DIR__
    filename = joinpath(dir, "../graphs/random_ksg/kernelized_tn_ksg_n$(n).dot")
    @show filename
    graphs = loadgraphs(filename)

    data = CSV.read(joinpath(dir, "../data/kernelize/tn_ksg_n$(n).csv"), DataFrame)

    # df = "data/complexity/tnbb_ksg_n$(n)_2.csv"
    df = CSV.write("data/complexity/tnbb_ksg_hypernd_n$(n).csv", DataFrame(name = String[], total_tc = Int[], num_branch = Int[]))

    for i in [2]
        g = graphs["$i"]
        r = data[data.name .== i, :r][1]
        @show i, nv(g), ne(g), r
        code = readjson(joinpath(dir, "../graphs/random_ksg/order/treesa_tn_ksg_n$(n)_s$(i)_treesa.json"))

        slicer = ContractionTreeSlicer(sc_target = 32, refiner = ReoptimizeRefiner(optimizer = HyperND(dis=METISND(), width=32, imbalances=100:10:200)))
        # reducer = TensorNetworkReducer(sub_reducer = XiaoReducer())
        reducer = XiaoReducer()
        branch = SlicedBranch(g, UnitWeight(nv(g)), code, r)
        # dirname = "/Euler/xzgao/n100/i_$(i)"
        dirname = "/Einstein/xzgao/tnbb_jlds/random_ksg/hypernd_$(n)_$(i)/"
        slice_bfs_rw(branch, slicer, reducer, dirname, 1)

        branch_df = CSV.read(joinpath(dirname, "slices.csv"), DataFrame)
        num_branches = length(branch_df.id)
        total_tc = log2(sum(2.0 .^ branch_df.tc))
        @show i, num_branches, total_tc

        CSV.write(df, DataFrame(name = i, total_tc = total_tc, num_branch = num_branches), append = true)
    end

    return nothing
end

tnbb_krksg(90)
