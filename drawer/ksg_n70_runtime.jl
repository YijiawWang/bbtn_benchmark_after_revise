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

# time to solve ksg 70x70, sc = 31, kernlized
begin
    df_contract = CSV.read("../data/runtime/ksg_n70_sc31_contract.csv", DataFrame)
    df_ds = CSV.read("../data/runtime/ksg_n70_kernelized_sc31_ds_branch.csv", DataFrame)
    df_tnbb = CSV.read("../data/runtime/ksg_n70_sc31_tnbb_branch.csv", DataFrame)
    df_scip = CSV.read("../data/runtime/ksg_n70_kernelized_scip.csv", DataFrame)

    ns = df_contract.name
    scs = [df_ds[df_ds.name .== name, :original_sc][1] for name in ns]
    ds_branch_time = [df_ds[df_ds.name .== name, :runtime][1] for name in ns]
    tnbb_branch_time = [df_tnbb[df_tnbb.name .== name, :runtime][1] for name in ns]
    ds_contract_time = [df_contract[df_contract.name .== name, :ds_runtime][1] for name in ns]
    tnbb_contract_time = [df_contract[df_contract.name .== name, :tnbb_runtime][1] for name in ns]
    scip_time = [df_scip[df_scip.name .== name, :runtime][1] for name in ns]
    
    tnbb_tc = [df_tnbb[df_tnbb.name .== name, :total_tc][1] for name in ns]

    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (500, 400), fontsize = 20)
    # ax = Axis(fig[1, 1], xlabel = L"\text{log}_2(\text{sc})", ylabel = L"\text{Runtime (s)}", xticks = (1:5, [L"32", L"33", L"34", L"35", L"36"]))
    ax = Axis(fig[2, 1], xlabel = L"\text{log}_2(\text{tc}_{tnbb})", ylabel = L"\text{log}_2(\text{T}) \text{ (s)}", xticks = (1:6, [string(round(x, digits=1)) for x in sort(tnbb_tc)]), yticks = (0:2:12, [string(i) for i in 0:2:12]))
    # yticks = (0:2:12, [L"2^0", L"2^2", L"2^4", L"2^6", L"2^8", L"2^{10}", L"2^{12}"])

    heights = []
    for i in sortperm(tnbb_tc)

        tnbb_total = tnbb_branch_time[i] + tnbb_contract_time[i]
        ds_total = ds_branch_time[i] + ds_contract_time[i]

        push!(heights, log2(tnbb_total) * tnbb_branch_time[i] / tnbb_total)
        push!(heights, log2(tnbb_total) * tnbb_contract_time[i] / tnbb_total)
        push!(heights, log2(ds_total))
        push!(heights, log2(scip_time[i]))
    end

    cat = [(i - 1) % 4 + 1 for i in 1:24]
    x_group = vcat([[i for _ in 1:4] for i in 1:6]...)
    dodge_group = vcat([[1, 1, 2, 3] for i in 1:6]...)
    stack_group = vcat([[1, 2, 1, 1] for i in 1:6]...)

    barplot!(ax, x_group, heights,
       dodge = dodge_group,
       stack = stack_group,
       color = colors[cat],)

    ylims!(ax, (0, 13))

    Legend(fig[1, :], [PolyElement(polycolor = colors[i]) for i in 1:4], ["tnbb branching", "tnbb contraction", "tn", "ip"], orientation = :horizontal, nbanks = 1, labelsize = 12)

    save("../figs/ksg_n70_sc31_kernelized_runtime.pdf", fig)

    fig
end

# unkernelized ksg 70x70, sc = 31
begin
    df_tnbb_contract = CSV.read("../data/runtime/ksg_n70_sc31_contract.csv", DataFrame)
    df_ds_contract = CSV.read("../data/runtime/ksg_n70_sc31_ds_contract.csv", DataFrame)

    df_ds_branch = CSV.read("../data/runtime/ksg_n70_sc31_ds_branch.csv", DataFrame)
    df_tnbb_branch = CSV.read("../data/runtime/ksg_n70_sc31_tnbb_branch.csv", DataFrame)
    df_scip = CSV.read("../data/runtime/ksg_n70_scip.csv", DataFrame)

    ns = df_tnbb_contract.name
    tnbb_contract_time = [df_tnbb_contract[df_tnbb_contract.name .== name, :tnbb_runtime][1] for name in ns]
    ds_contract_time = [df_ds_contract[df_ds_contract.name .== name, :runtime][1] for name in ns]

    tnbb_branch_time = [df_tnbb_branch[df_tnbb_branch.name .== name, :runtime][1] for name in ns]
    ds_branch_time = [df_ds_branch[df_ds_branch.name .== name, :runtime][1] for name in ns]
    
    scip_time = [df_scip.runtime..., NaN]

    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (500, 400), fontsize = 20)

    ax = Axis(fig[2, 1], xlabel = L"\text{log}_2(\text{tc}_{tnbb})", ylabel = L"\text{log}_2(\text{T}) \text{ (s)}", xticks = (1:6, [string(round(x, digits=1)) for x in sort(tnbb_tc)]), yticks = (0:5:40, [string(i) for i in 0:5:40]))

    # yticks = (0:2:12, [L"2^0", L"2^2", L"2^4", L"2^6", L"2^8", L"2^{10}", L"2^{12}"])

    heights = []
    for i in sortperm(tnbb_tc)
        tnbb_total_i = tnbb_branch_time[i] + tnbb_contract_time[i]
        ds_total_i = ds_branch_time[i] + ds_contract_time[i]

        push!(heights, log2(tnbb_total_i) * tnbb_branch_time[i] / tnbb_total_i)
        push!(heights, log2(tnbb_total_i) * tnbb_contract_time[i] / tnbb_total_i)
        push!(heights, log2(ds_total_i))
        push!(heights, log2(scip_time[i]))
    end

    cat = [(i - 1) % 4 + 1 for i in 1:24]
    x_group = vcat([[i for _ in 1:4] for i in 1:6]...)
    dodge_group = vcat([[1, 1, 2, 3] for i in 1:6]...)
    stack_group = vcat([[1, 2, 1, 1] for i in 1:6]...)

    barplot!(ax, x_group, heights,
       dodge = dodge_group,
       stack = stack_group,
       color = colors[cat],)

    ylims!(ax, (0, 35))

    Legend(fig[1, :], [PolyElement(polycolor = colors[i]) for i in 1:4], ["tnbb branching", "tnbb contraction", "tn", "ip"], orientation = :horizontal, nbanks = 1, labelsize = 12)

    save("../figs/ksg_n70_sc31_runtime.pdf", fig)

    fig
end

# different targets
begin
    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (500, 380), fontsize = 20)
    ax = Axis(fig[2, 1], xlabel = L"\text{log}_2(\text{sc})", ylabel = L"\text{log}_2(\text{T}) \text{ (s)}", xticks = (1:5, [string(i) for i in 31:-1:27]), yticks = (0:2:12, [string(i) for i in 0:2:12]))

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

        # push!(heights, tnbb_total_i * tnbb_branch_time[i] / tnbb_total[i])
        # push!(heights, tnbb_total_i * tnbb_contract_time[i] / tnbb_total[i])
        
        # push!(heights, ds_total_i * ds_branch_time[i] / ds_total[i])
        # push!(heights, ds_total_i * ds_contract_time[i] / ds_total[i])

        # push!(heights, log2(tnbb_branch_time[i]))
        # push!(heights, log2(tnbb_total[i]) - log2(tnbb_branch_time[i]))
        # push!(heights, log2(ds_branch_time[i]))
        # push!(heights, log2(ds_total[i]) - log2(ds_branch_time[i]))

        push!(heights, log2(tnbb_branch_time[i]))
        push!(heights, log2(tnbb_contract_time[i]))
        # push!(heights, log2(tnbb_total[i]))
    end
    
    # x_groups = [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5]
    # bar_groups = [1, 1, 2, 2, 1, 1, 2, 2, 1, 1, 2, 2, 1, 1, 2, 2, 1, 1, 2, 2]
    # y_groups = [1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2]
    # color_groups = [1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4]

    x_groups = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5]
    bar_groups = [1, 2, 1, 2, 1, 2, 1, 2, 1, 2]

    barplot!(ax, x_groups, heights,
       dodge = bar_groups,
       color = colors[bar_groups])

    ylims!(ax, (0, 10))

    # legend
    labels = ["branching", "contraction"]
    elements = [PolyElement(polycolor = colors[i]) for i in 1:length(labels)]

    Legend(fig[1, :], elements, labels, orientation = :horizontal, nbanks = 1, labelsize = 12)

    save("../figs/ksg_n70_runtime_dt.pdf", fig)

    fig
end