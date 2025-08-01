using Graphs, GraphIO
using OMEinsum
using CSV, DataFrames
using TensorBranching
using ProblemReductions
using BenchmarkTools

function slice_different_target(n, i)
    dir = @__DIR__
    df = joinpath(dir, "../data/complexity/random_ksg/slice_different_target_runtime_n$(n).csv")
    CSV.write(df, DataFrame(name = String[], ds = Int[], total_tc = Int[], num_slice = Int[], runtime = Float64[]))

    code = readjson(joinpath(dir, "../graphs/random_ksg/order/treesa_tn_ksg_n$(n)_s$(i)_treesa.json"))
    original_cc = mis_complexity(code)

    for ds in 1:5
        target = Int(original_cc.sc - ds)
        slicer = TreeSASlicer(sc_target = target)

        sliced_code = slice_code(code, uniformsize(code, 2), slicer)
        t = @belapsed slice_code($code, uniformsize($code, 2), $slicer)

        writejson(joinpath(dir, "../graphs/random_ksg/order/slice_$(target)_tn_ksg_n$(n)_s$(i)_treesa.json"), sliced_code)
        sliced_cc = mis_complexity(sliced_code)
        @show i, ds, sliced_cc.tc, t

        CSV.write(df, DataFrame(name = i, ds = ds, total_tc = sliced_cc.tc, num_slice = length(sliced_code.slicing), runtime = t), append = true)
    end
end

function slice_runtime_sc31_kernelized(n, i)
    dir = @__DIR__
    df = joinpath(dir, "../data/runtime/ksg_n70_sc31_ds_branch.csv")
    # CSV.write(df, DataFrame(name = String[], original_sc = Int[], total_tc = Int[], nslice = Int[], runtime = Float64[]))

    code = readjson(joinpath(dir, "../graphs/random_ksg/order/treesa_tn_ksg_n$(n)_s$(i)_treesa.json"))
    original_cc = mis_complexity(code)

    original_cc.sc <= 31 && return nothing
    slicer = TreeSASlicer(sc_target = 31)

    sliced_code = slice_code(code, uniformsize(code, 2), slicer)
    t = @elapsed slice_code(code, uniformsize(code, 2), slicer)

    sliced_cc = mis_complexity(sliced_code)
    @show i, original_cc.sc, sliced_cc.sc, sliced_cc.tc, sliced_cc.rwc, t
    @show sliced_cc.tc / sliced_cc.rwc

    writejson(joinpath(dir, "../graphs/random_ksg/order/slice31_tn_ksg_n$(n)_s$(i)_treesa.json"), sliced_code)

    CSV.write(df, DataFrame(name = i, original_sc = original_cc.sc, total_tc = sliced_cc.tc, nslice = length(sliced_code.slicing), runtime = t), append = true)

    return nothing
end

function slice_runtime_sc31(n)
    dir = @__DIR__
    df = joinpath(dir, "../data/runtime/ksg_n70_sc31_ds_branch.csv")
    CSV.write(df, DataFrame(name = String[], original_sc = Int[], total_tc = Int[], nslice = Int[], runtime = Float64[]))

    for i in [2, 3, 4, 5, 7, 9, 10]

        code = readjson(joinpath(dir, "../graphs/random_ksg/order/treesa_original_ksg_n$(n)_s$(i).json"))
        original_cc = mis_complexity(code)
        @show i, original_cc.sc, original_cc.tc

        sc_target = 31
        slicer = TreeSASlicer(sc_target = sc_target)
        sliced_code = slice_code(code, uniformsize(code, 2), slicer)
        t = @elapsed slice_code(code, uniformsize(code, 2), slicer)

        writejson(joinpath(dir, "../graphs/random_ksg/order/slice31_original_ksg_n$(n)_s$(i)_treesa.json"), sliced_code)

        sliced_cc = mis_complexity(sliced_code)
        @show i, original_cc.sc, sliced_cc.sc, sliced_cc.tc, sliced_cc.rwc, t

        CSV.write(df, DataFrame(name = i, original_sc = original_cc.sc, total_tc = sliced_cc.tc, nslice = length(sliced_code.slicing), runtime = t), append = true)
    end

    return nothing
end

slice_runtime_sc31(70)

# slice_different_target(70, 7)