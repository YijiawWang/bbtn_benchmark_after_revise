using Graphs, GraphIO
using OMEinsum
using CSV, DataFrames
using TensorBranching
using ProblemReductions

function slice_runtime(n)
    dir = @__DIR__
    df = "data/complexity/ds_sc31_runtime_n$(n).csv"
    CSV.write(df, DataFrame(name = String[], original_sc = Int[], total_tc = Int[], nslice = Int[], runtime = Float64[]))

    for i in 1:10
        code = readjson(joinpath(dir, "../graphs/random_ksg/order/treesa_tn_ksg_n$(n)_s$(i)_treesa.json"))
        original_cc = mis_complexity(code)

        original_cc.sc <= 31 && continue
        slicer = TreeSASlicer(sc_target = 31)

        sliced_code = slice_code(code, uniformsize(code, 2), slicer)
        t = @elapsed slice_code(code, uniformsize(code, 2), slicer)

        sliced_cc = mis_complexity(sliced_code)
        @show i, original_cc.sc, sliced_cc.sc, sliced_cc.tc, t

        writejson(joinpath(dir, "../graphs/random_ksg/order/slice31_tn_ksg_n$(n)_s$(i)_treesa.json"), sliced_code)

        CSV.write(df, DataFrame(name = i, original_sc = original_cc.sc, total_tc = sliced_cc.tc, nslice = length(sliced_code.slicing), runtime = t), append = true)
    end

    return nothing
end

slice_runtime(70)