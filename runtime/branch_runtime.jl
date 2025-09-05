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

    df = "data/complexity/tnbb_different_target_runtime_n$(n).csv"
    CSV.write(df, DataFrame(name = String[], ds = Int[], total_tc = Int[], num_branch = Int[], runtime = Float64[]))

    for i in [7]
        g = graphs["$i"]
        r = data[data.name .== i, :r][1]
        @show i, nv(g), ne(g), r
        code = readjson(joinpath(dir, "../graphs/random_ksg/order/treesa_tn_ksg_n$(n)_s$(i)_treesa.json"))
        original_cc = mis_complexity(code)
        for ds in 1:5
            target = original_cc.sc - ds
            slicer = ContractionTreeSlicer(sc_target = target)
            # reducer = TensorNetworkReducer(sub_reducer = XiaoReducer())
            reducer = XiaoReducer()
            branch = SlicedBranch(g, UnitWeight(nv(g)), code, r)
            dirname = "/Einstein/xzgao/tnbb_jlds/random_ksg/$(n)_$(i)_ds$(ds)/"
            if ds == 1
                slice_bfs_rw(branch, slicer, reducer, "/Einstein/xzgao/tnbb_jlds/random_ksg/$(n)_$(i)_ds$(ds)_temp/", 1)
            end
            t = @elapsed slice_bfs_rw(branch, slicer, reducer, dirname, 1)

            branch_df = CSV.read(joinpath(dirname, "slices.csv"), DataFrame)
            num_branches = length(branch_df.id)
            total_tc = log2(sum(2.0 .^ branch_df.tc))
            @show i, ds, num_branches, total_tc, t

            CSV.write(df, DataFrame(name = i, ds = ds, total_tc = total_tc, num_branch = num_branches, runtime = t), append = true)
        end
    end

    return nothing
end

function tnbb_krksg(n)
    dir = @__DIR__
    filename = joinpath(dir, "../graphs/random_ksg/kernelized_tn_ksg_n$(n).dot")
    @show filename
    graphs = loadgraphs(filename)

    data = CSV.read(joinpath(dir, "../data/kernelize/tn_ksg_n$(n).csv"), DataFrame)

    df = "data/runtime/ksg_n$(n)_sc31_tnbb_branch.csv"
    CSV.write(df, DataFrame(name = String[], original_sc = Int[], total_tc = Int[], num_branch = Int[], runtime = Float64[]))

    for i in 1:10
        g = graphs["$i"]
        r = data[data.name .== i, :r][1]

        @show i, nv(g), ne(g), r
        code = readjson(joinpath(dir, "../graphs/random_ksg/order/treesa_tn_ksg_n$(n)_s$(i)_treesa.json"))
        original_cc = mis_complexity(code)
        @show i, original_cc.sc

        # original_cc.sc <= 31 && continue

        dirname = "/home/xuanzhaogao/work/tnbb_data/$(n)_$(i)_sc31"

        # if original_cc.sc < 31

        #     !isdir(dirname) && mkdir(dirname)

        #     TensorBranching.save_finished(dirname, SlicedBranch(g, UnitWeight(nv(g)), code, r), 1)
        #     CSV.write(joinpath(dirname, "slices.csv"), DataFrame(id = 1, sc = original_cc.sc, tc = original_cc.tc, r = r))

        #     continue
        # end

        target = 31
        slicer = ContractionTreeSlicer(sc_target = target)

        reducer = XiaoReducer()
        branch = SlicedBranch(g, UnitWeight(nv(g)), code, r)
        t = @elapsed slice_bfs_rw(branch, slicer, reducer, dirname, 1)

        branch_df = CSV.read(joinpath(dirname, "slices.csv"), DataFrame)
        num_branches = length(branch_df.id)
        total_tc = log2(sum(2.0 .^ branch_df.tc))
        @show i, original_cc.sc, num_branches, total_tc, t

        CSV.write(df, DataFrame(name = i, original_sc = original_cc.sc, total_tc = total_tc, num_branch = num_branches, runtime = t), append = true)
    end

    return nothing
end

tnbb_krksg(60)
