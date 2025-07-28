using Graphs, GraphIO
using OMEinsum
using CSV, DataFrames

function slice_different_target(n)
    df = "data/complexity/treesa_different_target_n$(n).csv"
    # CSV.write(df, DataFrame(name = Int[], ds = Int[], origin_sc = Float64[], origin_tc = Float64[], origin_rwc = Float64[], sliced_sc = Float64[], sliced_tc = Float64[], sliced_rwc = Float64[], sliced_boundes = Int[]))
    for i in 1:10            
        code = readjson(joinpath(@__DIR__, "..", "graphs", "random_ksg", "order", "treesa_tn_ksg_n$(n)_s$(i)_treesa.json"))
        original_cc = contraction_complexity(code, uniformsize(code, 2))
        @show i, original_cc.sc, original_cc.tc, original_cc.rwc

        for ds in 11:15
            target = original_cc.sc - ds
            slicer = TreeSASlicer(sc_target = target)
            sliced_code = slice_code(code, uniformsize(code, 2), slicer)
            sliced_cc = contraction_complexity(sliced_code, uniformsize(sliced_code, 2))
            @show i, ds, target, sliced_cc.sc, sliced_cc.tc, sliced_cc.rwc, length(sliced_code.slicing)

            CSV.write(df, DataFrame(name = i, ds = ds, origin_sc = original_cc.sc, origin_tc = original_cc.tc, origin_rwc = original_cc.rwc, sliced_sc = sliced_cc.sc, sliced_tc = sliced_cc.tc, sliced_rwc = sliced_cc.rwc, sliced_boundes = length(sliced_code.slicing)), append = true)
        end
    end
    return nothing
end


slice_different_target(80)