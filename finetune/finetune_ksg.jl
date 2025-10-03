using Graphs, GraphIO
using OMEinsum, TensorBranching
using CSV, DataFrames
using GenericTensorNetworks
using ProblemReductions
using Statistics

function treesa_optimize(code, iters)
    betas = range(1.0, 15.0, length = iters)
    optimizer = TreeSA(βs = betas, ntrials = 1, niters = 1)
    opt_code = optimize_code(code, uniformsize(code, 2), optimizer)
    @info mis_complexity(opt_code)
    return opt_code
end

function finetune(code, iters)
    betas = range(1.0, 15.0, length = iters)
    code = TensorBranching.rethermalize(code, uniformsize(code, 2), betas, 1, 1, 0)
    @info mis_complexity(code)
    return code
end

function main()
    dir = @__DIR__
    graphs = loadgraphs(joinpath(dir, "../graphs/random_ksg/kernelized_tn_ksg_n60.dot"))
    g = graphs["1"]
    code = readjson(joinpath(dir, "../graphs/random_ksg/order/treesa_tn_ksg_n60_s1_treesa.json"))

    df = CSV.write("data/finetune/finetune_n60_s1.csv", DataFrame(name = String[], iters = Int[], id = Int[], sc = Float64[], tc = Float64[], rwc = Float64[]))

    @info mis_complexity(code)

    slicer = ContractionTreeSlicer(sc_target = 0)
    rvs, _ = TensorBranching.ob_region(g, code, slicer, ScoreRS(loss = :sc_score, n_max = 100), uniformsize(code, 2), 0)
    @show rvs, length(rvs)

    g_new, vmap = induced_subgraph(g, setdiff(1:nv(g), rvs))

    code_new_mapped = TensorBranching.update_code(g_new, code, vmap)
    code_new_flatten = OMEinsum.flatten(initialize_code(g_new, GreedyMethod()))
    @show mis_complexity(code_new_mapped)
    @show mis_complexity(code_new_flatten)

    for iters in 10:10:100
        scs = zeros(100)
        tcs = zeros(100)
        rwcs = zeros(100)
        Threads.@threads for i in 1:100
            code_new_finetuned = finetune(code_new_mapped, iters)
            cc = mis_complexity(code_new_finetuned)
            scs[i] = cc.sc
            tcs[i] = cc.tc
            rwcs[i] = cc.rwc
        end
        CSV.write(df, DataFrame(name = "finetune", iters = iters, id = 1:100, sc = scs, tc = tcs, rwc = rwcs), append = true)
        @show iters, mean(scs), mean(tcs), mean(rwcs)
    end

    for iters in 100:100:1000
        scs = zeros(100)
        tcs = zeros(100)
        rwcs = zeros(100)
        Threads.@threads for i in 1:100
            code_new_treesa = treesa_optimize(code_new_flatten, iters)
            cc = mis_complexity(code_new_treesa)
            scs[i] = cc.sc
            tcs[i] = cc.tc
            rwcs[i] = cc.rwc
        end
        CSV.write(df, DataFrame(name = "treesa", iters = iters, id = 1:100, sc = scs, tc = tcs, rwc = rwcs), append = true)
        @show iters, mean(scs), mean(tcs), mean(rwcs)
    end

    # baseline
    code_new_reopt = optimize_code(code_new_flatten, uniformsize(code_new_flatten, 2), TreeSA())
    @show mis_complexity(code_new_reopt)
    CSV.write(df, DataFrame(name = "baseline", iters = 1, id = 1, sc = mis_complexity(code_new_reopt).sc, tc = mis_complexity(code_new_reopt).tc, rwc = mis_complexity(code_new_reopt).rwc), append = true)

    return nothing
end

main()