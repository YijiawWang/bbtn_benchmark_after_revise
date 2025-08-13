include("settings.jl")

# compare runtime of tn and bb
begin
    ns = [30, 35, 40, 45, 50]
    df_bbs = [CSV.read("../data/count_vc/ksg_n$(n)_count_vc.csv", DataFrame) for n in ns]
    df_tns = [CSV.read("../data/runtime/rksg_runtime_ksg_n$(n).csv", DataFrame) for n in ns]
    df_bbs_randn = [CSV.read("../data/count_vc/ksg_n$(n)_count_add_xiao2021.csv", DataFrame) for n in ns]

    time_bbs = [geometric_mean(df_bbs[i].time) for i in 1:length(ns)]
    time_tns = [geometric_mean(df_tns[i].runtime) for i in 1:length(ns)]
    time_bbs_randn = [geometric_mean(df_bbs_randn[i].time) for i in 1:length(ns)]

    fig = Figure(size = (500, 350), fontsize = 20)
    ax1 = Axis(fig[1, 1], xlabel = L"N", ylabel = L"\text{Runtime (s)}", yscale = log10)

    sc_bbs = scatter!(ax1, ns, time_bbs, markersize = markersize, marker = markerstyle[1], color = colors[1], strokewidth = strokewidth, strokecolor = :black, label = "Branch&Bound")
    sc_tns = scatter!(ax1, ns, time_tns, markersize = markersize, marker = markerstyle[2], color = colors[2], strokewidth = strokewidth, strokecolor = :black, label = "Tropical TN")
    sc_bbs_randn = scatter!(ax1, ns, time_bbs_randn, markersize = markersize, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black, label = "Branch&Bound (randn)")

    # axislegend(ax1, [sc_bbs, sc_tns, sc_bbs_randn], ["Branch&Bound", "Tropical TN", "Branch&Bound (randn)"], position = :lt, labelsize = 15)
    ylims!(ax1, 10^(-1.5), 10^4.5)

    # save("../figs/compare_bb_runtime.pdf", fig)
    fig
end