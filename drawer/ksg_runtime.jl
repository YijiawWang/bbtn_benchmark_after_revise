include("settings.jl")

begin
    df_branch = CSV.read("../data/runtime/branch_runtime_ksg_n70.csv", DataFrame)
    df_contract = CSV.read("../data/runtime/contract_runtime_ksg_n70.csv", DataFrame)
    scs = 32 .- df_branch.ds

    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (500, 350), fontsize = 20)
    ax = Axis(fig[1, 1], xlabel = L"\text{log}_2(\text{sc})", ylabel = L"\text{Runtime (s)}", yscale = log2, xticks = (-scs, string.(scs)))

    xlims!(ax, (- 31.5, -26.5))
    ylims!(ax, (2^4, 2^10))

    sc_branch = scatter!(ax, - scs, df_branch.runtime, markersize = markersize, marker = markerstyle[1], color = colors[1], strokewidth = strokewidth, strokecolor = :black, label = "branching phase")
    sc_contract = scatter!(ax, - scs, df_contract.runtime, markersize = markersize, marker = markerstyle[2], color = colors[2], strokewidth = strokewidth, strokecolor = :black, label = "contraction phase")
    sc_total = scatter!(ax, - scs, df_branch.runtime + df_contract.runtime, markersize = markersize, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black, label = "total")

    # Legend(fig[2, :], [sc_branch, sc_contract, sc_total], ["branching phase", "contraction phase", "total"], orientation = :horizontal, nbanks = 1, labelsize = 12)
    axislegend(ax, position = :lt, labelsize = 12)

    # ax2 = Axis(fig[2, 1], xlabel = L"\text{log}_2(\text{sc})", ylabel = L"\text{log}_2(\text{tc})", xticks = (-scs, string.(scs)))
    # scatter!(ax2, - scs, df_branch.total_tc, markersize = markersize, marker = markerstyle[4], color = colors[4], strokewidth = strokewidth, strokecolor = :black, label = "total tc")

    # axislegend(ax2, position = :lt, labelsize = 12)
    # xlims!(ax2, (- 31.5, -26.5))
    # ylims!(ax2, (44, 46))

    save("../figs/ksg_runtime.pdf", fig)

    fig
end