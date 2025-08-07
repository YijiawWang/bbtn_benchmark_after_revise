include("settings.jl")

begin
    # random ksg
    df_tn_rksg = CSV.read("../data/runtime/ksg_n70_sc31_contract.csv", DataFrame)
    df_scip_rksg = CSV.read("../data/runtime/ksg_n70_scip.csv", DataFrame)
    df_mapped_ksg = CSV.read("../data/runtime/mapped_ksg_tnbb_ds.csv", DataFrame)

    rksg_name = 2
    rksg_tnbb_time = df_tn_rksg[df_tn_rksg.name .== rksg_name, :tnbb_runtime][1]
    rksg_ds_time = df_tn_rksg[df_tn_rksg.name .== rksg_name, :ds_runtime][1]
    rksg_scip_time = df_scip_rksg[df_scip_rksg.name .== rksg_name, :runtime][1]

    rksg_times = [rksg_tnbb_time, rksg_ds_time, rksg_scip_time]
    factorization_time = [df_mapped_ksg[df_mapped_ksg.name .== "factorization", :tnbb_contract_time][1], df_mapped_ksg[df_mapped_ksg.name .== "factorization", :dynamic_slicing_time][1], df_mapped_ksg[df_mapped_ksg.name .== "factorization", :scip_time][1]]
    mapped_mis_time = [df_mapped_ksg[df_mapped_ksg.name .== "mis", :tnbb_contract_time][1], df_mapped_ksg[df_mapped_ksg.name .== "mis", :dynamic_slicing_time][1], df_mapped_ksg[df_mapped_ksg.name .== "mis", :scip_time][1]]
    qubo_time = [df_mapped_ksg[df_mapped_ksg.name .== "qubo", :tnbb_contract_time][1], df_mapped_ksg[df_mapped_ksg.name .== "qubo", :dynamic_slicing_time][1], df_mapped_ksg[df_mapped_ksg.name .== "qubo", :scip_time][1]]

    max_time = 3 * 3600 * 24
    times = vcat(rksg_times, factorization_time, mapped_mis_time, qubo_time)
    times = map(x -> x > max_time ? max_time : x, times)

    cat = [1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4]
    bar_grp = [1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]

    runtime_colors = [:green, :orange, :purple]
    fig = Figure(size = (500, 400), fontsize = 20)
    ax = Axis(fig[2, 1], 
        # xlabel = "Problem Type", 
        ylabel = L"$T$ (s)", 
        xticks = (1:4, ["Random\n KSG", "Integer\nfactorization", "Arbitrary\nMWIS", "QUBO"]),
        yticks = (0:6, [L"10^0", L"10^1", L"10^2", L"10^3", L"10^4", L"10^5", L"10^6"]),
        xgridvisible = false,
        ygridvisible = true
    )
    barplot!(ax, cat, log10.(times), dodge = bar_grp, color = runtime_colors[bar_grp])
    ylims!(ax, 0, 6)

    Legend(fig[1, :], [PolyElement(polycolor = runtime_colors[i]) for i in 1:3], ["BBTN", "TTN & DS", "SCIP"], orientation = :horizontal, nbanks = 1, labelsize = 15)

    xlims!(ax, 0.3, 4.7)
    hlines!(ax, [log10(max_time)], color = :black, linestyle = :dot)
    text!(ax, 0.4, log10(max_time), text = L"Time limit ($72$h)", fontsize = 18)

    save("../figs/runtime.pdf", fig)
    fig
end