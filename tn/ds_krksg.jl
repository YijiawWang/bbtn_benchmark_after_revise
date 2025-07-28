using Graphs, GraphIO
using OMEinsum
using CSV, DataFrames

function slice(n, target)
    slicer = TreeSASlicer(sc_target = target)
    df = CSV.write("data/complexity/slice32_tn_ksg_n$(n).csv", DataFrame(name = Int[], origin_sc = Float64[], origin_tc = Float64[], origin_rwc = Float64[], sliced_sc = Float64[], sliced_tc = Float64[], sliced_rwc = Float64[], sliced_boundes = Int[]))
    for i in 1:10
        code = readjson(joinpath(@__DIR__, "..", "graphs", "random_ksg", "order", "treesa_tn_ksg_n$(n)_s$(i)_treesa.json"))
        original_cc = contraction_complexity(code, uniformsize(code, 2))
        @show i, original_cc.sc, original_cc.tc, original_cc.rwc

        sliced_code = slice_code(code, uniformsize(code, 2), slicer)
        sliced_cc = contraction_complexity(sliced_code, uniformsize(sliced_code, 2))
        @show i, sliced_cc.sc, sliced_cc.tc, sliced_cc.rwc, length(sliced_code.slicing)

        CSV.write(df, DataFrame(name = i, origin_sc = original_cc.sc, origin_tc = original_cc.tc, origin_rwc = original_cc.rwc, sliced_sc = sliced_cc.sc, sliced_tc = sliced_cc.tc, sliced_rwc = sliced_cc.rwc, sliced_boundes = length(sliced_code.slicing)
        ), append = true)
        writejson(joinpath(@__DIR__, "..", "graphs", "random_ksg", "order", "slice3$(target)_tn_ksg_n$(n)_s$(i).json"), sliced_code)
    end
    return nothing
end

for n in 80:10:100
    slice(n, 32)
end