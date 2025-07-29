include("settings.jl")

# begin
#     df_branch = CSV.read("../data/runtime/branch_runtime_ksg_n70.csv", DataFrame)
#     df_contract = CSV.read("../data/runtime/contract_runtime_ksg_n70.csv", DataFrame)
#     scs = 32 .- df_branch.ds

#     fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (500, 350), fontsize = 20)
#     ax = Axis(fig[1, 1], xlabel = L"\text{log}_2(\text{sc})", ylabel = L"\text{Runtime (s)}", yscale = log2, xticks = (-scs, string.(scs)))

#     xlims!(ax, (- 31.5, -26.5))
#     ylims!(ax, (2^4, 2^10))

#     sc_branch = scatter!(ax, - scs, df_branch.runtime, markersize = markersize, marker = markerstyle[1], color = colors[1], strokewidth = strokewidth, strokecolor = :black, label = "branching phase")
#     sc_contract = scatter!(ax, - scs, df_contract.runtime, markersize = markersize, marker = markerstyle[2], color = colors[2], strokewidth = strokewidth, strokecolor = :black, label = "contraction phase")
#     sc_total = scatter!(ax, - scs, df_branch.runtime + df_contract.runtime, markersize = markersize, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black, label = "total")

#     # Legend(fig[2, :], [sc_branch, sc_contract, sc_total], ["branching phase", "contraction phase", "total"], orientation = :horizontal, nbanks = 1, labelsize = 12)
#     axislegend(ax, position = :lt, labelsize = 12)

#     # ax2 = Axis(fig[2, 1], xlabel = L"\text{log}_2(\text{sc})", ylabel = L"\text{log}_2(\text{tc})", xticks = (-scs, string.(scs)))
#     # scatter!(ax2, - scs, df_branch.total_tc, markersize = markersize, marker = markerstyle[4], color = colors[4], strokewidth = strokewidth, strokecolor = :black, label = "total tc")

#     # axislegend(ax2, position = :lt, labelsize = 12)
#     # xlims!(ax2, (- 31.5, -26.5))
#     # ylims!(ax2, (44, 46))

#     save("../figs/ksg_runtime.pdf", fig)

#     fig
# end

# time to solve ksg 70x70, sc = 31
begin
    df_contract = CSV.read("../data/runtime/ksg_n70_sc31_contract.csv", DataFrame)
    df_ds = CSV.read("../data/runtime/ksg_n70_sc31_ds_branch.csv", DataFrame)
    df_tnbb = CSV.read("../data/runtime/ksg_n70_sc31_tnbb_branch.csv", DataFrame)

    ns = df_contract.name[1:5]
    scs = [df_ds[df_ds.name .== name, :original_sc][1] for name in ns]
    ds_branch_time = [df_ds[df_ds.name .== name, :runtime][1] for name in ns]
    tnbb_branch_time = [df_tnbb[df_tnbb.name .== name, :runtime][1] for name in ns]
    ds_contract_time = [df_contract[df_contract.name .== name, :ds_runtime][1] for name in ns]
    tnbb_contract_time = [df_contract[df_contract.name .== name, :tnbb_runtime][1] for name in ns]

    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (500, 350), fontsize = 20)
    ax = Axis(fig[1, 1], xlabel = L"\text{log}_2(\text{sc})", ylabel = L"\text{Runtime (s)}", xticks = (1:5, ["32", "33", "34", "35", "36"]))

    cat = [(i - 1) % 4 + 1 for i in 1:20]
    heights = []
    for i in sortperm(scs)
        push!(heights, tnbb_branch_time[i])
        push!(heights, tnbb_contract_time[i])
        push!(heights, ds_branch_time[i])
        push!(heights, ds_contract_time[i])
    end
    grp = [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5]
    grp_1 = [1, 1, 2, 2, 1, 1, 2, 2, 1, 1, 2, 2, 1, 1, 2, 2, 1, 1, 2, 2]
    grp_2 = [1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2]

    grp_3 = [1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4]

    barplot!(ax, grp, heights,
       dodge = grp_1,
       stack = grp_2,
       color = colors[grp_3],)

    fig
end

# different targets
begin
    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (500, 350), fontsize = 20)
    ax = Axis(fig[1, 1], xlabel = L"\text{log}_2(\text{sc})", ylabel = L"\text{Runtime (s)}", xticks = (1:5, ["31", "30", "29", "28", "27"]), yticks = (0:2:12, [L"2^0", L"2^2", L"2^4", L"2^6", L"2^8", L"2^{10}", L"2^{12}"]))

    df_tnbb = CSV.read("../data/runtime/ksg_n70_dt_tnbb_branch.csv", DataFrame)
    df_tnbb_contract = CSV.read("../data/runtime/ksg_n70_dt_tnbb_contract.csv", DataFrame)

    df_ds = CSV.read("../data/runtime/ksg_n70_dt_ds_branch.csv", DataFrame)
    df_ds_contract = CSV.read("../data/runtime/ksg_n70_dt_ds_contract.csv", DataFrame)

    tnbb_branch_time = df_tnbb.runtime
    ds_branch_time = df_ds.runtime
    
    tnbb_contract_time = df_tnbb_contract.runtime
    ds_contract_time = df_ds_contract.runtime
    
    tnbb_total = tnbb_branch_time + tnbb_contract_time
    ds_total = ds_branch_time + ds_contract_time

    heights = []
    for i in 1:5
        tnbb_total_i = log2(tnbb_total[i])
        ds_total_i = log2(ds_total[i])

        push!(heights, tnbb_total_i * tnbb_branch_time[i] / tnbb_total[i])
        push!(heights, tnbb_total_i * tnbb_contract_time[i] / tnbb_total[i])
        
        push!(heights, ds_total_i * ds_branch_time[i] / ds_total[i])
        push!(heights, ds_total_i * ds_contract_time[i] / ds_total[i])
    end
    
    x_groups = [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5]
    bar_groups = [1, 1, 2, 2, 1, 1, 2, 2, 1, 1, 2, 2, 1, 1, 2, 2, 1, 1, 2, 2]
    y_groups = [1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2]
    color_groups = [1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4]

    barplot!(ax, x_groups, heights,
       dodge = bar_groups,
       stack = y_groups,
       color = colors[color_groups])

    ylims!(ax, (0, 12))

    save("../figs/ksg_n70_runtime_dt.pdf", fig)

    fig
end