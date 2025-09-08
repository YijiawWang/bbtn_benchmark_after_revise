include("settings.jl")

begin
    fig = Figure(size = (500, 350), fontsize = 20)
    ax1 = Axis(fig[2, 1], xlabel = L"N", ylabel = L"t.c. \text{ (Flops)}", xticks = (30:10:70, [L"30", L"40", L"50", L"60", L"70"]), yticks = (0:15:60, [L"2^0", L"2^{15}", L"2^{30}", L"2^{45}", L"2^{60}"]))
    ax1_2 = Axis(fig[2, 1], yaxisposition = :right, ylabel = L"N_{BB}", ygridvisible = false, yticks = ([0, 5, 10, 15], [L"2^0", L"2^5", L"2^{10}", L"2^{15}"]))

    hidespines!(ax1_2)
    hidexdecorations!(ax1_2)

    n_bb = [30, 35, 40, 45, 50]
    n_bb_randn = [30, 35, 40, 45, 50, 55, 60, 65, 70]
    n_tn = [30:5:45...]

    n_scip = [30:5:50...]

    n_tn_large = [50:5:70...]
    df_tns_large = [CSV.read("../data/complexity/random_ksg/original_ksg_n$(n).csv", DataFrame) for n in n_tn_large]
    tc_tns_large = [geometric_mean(df_tns_large[i].tc) for i in 1:length(n_tn_large)]

    df_bbs = [CSV.read("../data/count_vc/ksg_n$(n)_count_vc.csv", DataFrame) for n in n_bb]
    df_bbs_randn = [CSV.read("../data/count_vc/ksg_n$(n)_count_add_xiao2021.csv", DataFrame) for n in n_bb_randn]
    df_tns = [CSV.read("../data/complexity/random_ksg/original_ksg_n$(n).csv", DataFrame) for n in n_tn]
    df_scip = [CSV.read("../data/runtime/ksg_n$(n)_scip_nodes.csv", DataFrame) for n in n_scip]

    count_bbs = log2.([geometric_mean(df_bbs[i].count) for i in 1:length(n_bb)])
    count_bbs_randn = log2.([geometric_mean(df_bbs_randn[i].count) for i in 1:length(n_bb_randn)])
    tc_tns = [geometric_mean(df_tns[i].tc) for i in 1:length(n_tn)]
    scip_nodes = log2.([geometric_mean(df_scip[i].nodes) for i in 1:length(n_scip)])

    ratio = 5580.683042049408 * geometric_mean(df_bbs[end].count)
    tn_ratio = 20.923843821 / geometric_mean(df_tns[end].tc)

    @. model_bb(x, p) = p[1] * x^p[2] + p[3]
    fit_bb = curve_fit(model_bb, n_bb, count_bbs, [1.0, 1.0, 1.0])
    @. model_tn(x, p) = p[1] * x + p[2]
    fit_tn = curve_fit(model_tn, n_tn, tc_tns, [1.0, 1.0])
    @. model_bb_randn(x, p) = p[1] * x^p[2] + p[3]
    fit_bb_randn = curve_fit(model_bb_randn, n_bb_randn, count_bbs_randn, [1.0, 1.0, 1.0])

    sc_bb = scatter!(ax1_2, n_bb, count_bbs, markersize = markersize, marker = markerstyle[1], color = colors[1], strokewidth = strokewidth, strokecolor = :black, label = "B&B (unit weight)")
    # sc_bb_randn = scatter!(ax1_2, n_bb_randn, count_bbs_randn, markersize = markersize, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black, label = "B&B (Gaussian weight)")
    sc_scip = scatter!(ax1_2, n_scip, scip_nodes, markersize = markersize, marker = markerstyle[4], color = colors[4], strokewidth = strokewidth, strokecolor = :black, label = "SCIP")

    sc_tn = scatter!(ax1, n_tn, tc_tns, markersize = markersize, marker = markerstyle[2], color = colors[2], strokewidth = strokewidth, strokecolor = :black, label = "Tropical TN")
    scatter!(ax1, n_tn_large, tc_tns_large, markersize = markersize, marker = markerstyle[2], color = :white, strokewidth = 2, strokecolor = colors[2])

    xs = range(25, 85, length = 100)

    lines!(ax1_2, xs, model_bb(xs, fit_bb.param), color = colors[1], linestyle = :dash)
    lines!(ax1, xs, model_tn(xs, fit_tn.param), color = colors[2], linestyle = :dash)
    # lines!(ax1_2, xs, model_bb_randn(xs, fit_bb_randn.param), color = colors[3], linestyle = :dash)

    n_start = 27.5
    n_end = 72.5

    t = 52.72703455212527

    hlines!(ax1, [t], color = :black, linestyle = hstyle, linewidth = hwidth)

    xlims!(ax1, n_start, n_end)
    ylims!(ax1, 0, t * 1.3)
    xlims!(ax1_2, n_start, n_end)
    ylims!(ax1_2, 0, 13.661416871102356 * 1.3)

    # Legend(fig[1, :], [sc_bb, sc_bb_randn, sc_tn], ["Branch&Bound", "Branch&Bound (randn)", "Tropical TN"], orientation = :horizontal, nbanks = 1, labelsize = 12)
    Legend(fig[1, :], [sc_tn, sc_bb, sc_bb_randn], ["Tropical-TN", "B&B (unit weight)", "B&B (Gaussian weight)"], position = :lt, labelsize = 15, orientation = :horizontal, nbanks = 1)

    text!(ax1, n_start + 1, t, text = L"$\sim 1$ hour", color = :black, fontsize = 18)

    save("../figs/compare_bb.pdf", fig)
    fig
end

begin
    
    fig = Figure(size = (500, 300), fontsize = 20)
    

    ax0 = Axis(fig[2, 1], xlabel = L"N", ylabel = L"t.c.", yticks = (0:10:60, [L"2^0", L"2^{10}", L"2^{20}", L"2^{30}", L"2^{40}", L"2^{50}", L"2^{60}"]), xticks = (30:10:50, [L"30", L"40", L"50"]))
    ax1 = Axis(fig[2, 2], xlabel = L"N", ylabel = L"N_{B}", yticks = ([0, 5, 10, 15, 20], [L"2^0", L"2^5", L"2^{10}", L"2^{15}", L"2^{20}"]), xticks = (30:10:50, [L"30", L"40", L"50"]))
    # ax1_2 = Axis(fig[2, 3], xlabel = L"N", ylabel = L"N_{B}", yticks = ([0, 5, 10, 15], [L"2^0", L"2^5", L"2^{10}", L"2^{15}"]), xticks = (30:10:50, [L"30", L"40", L"50"]))

    n_tn = [30:5:50...]
    n_bb = [30, 35, 40, 45, 50]
    n_ip = [30, 35, 40, 45, 50]

    df_tns = [CSV.read("../data/complexity/random_ksg/original_ksg_n$(n).csv", DataFrame) for n in n_tn]
    df_bbs = [CSV.read("../data/count_vc/additional_ksg_n$(n)_count_vc.csv", DataFrame) for n in n_bb]
    df_ips = [CSV.read("../data/runtime/ksg_n$(n)_scip_nodes.csv", DataFrame) for n in n_ip]

    count_bbs = log2.([geometric_mean(df_bbs[i].count) for i in 1:length(n_bb)])
    count_ips = log2.([geometric_mean(df_ips[i].nodes) for i in 1:length(n_ip)])
    tc_tns = [geometric_mean(df_tns[i].tc) for i in 1:length(n_tn)]

    sc_tn = scatter!(ax0, n_tn, tc_tns, markersize = markersize, marker = markerstyle[2], color = colors[2], strokewidth = strokewidth, strokecolor = :black, label = "Tropical TN")
    sc_bb = scatter!(ax1, n_bb, count_bbs, markersize = markersize, marker = markerstyle[1], color = colors[1], strokewidth = strokewidth, strokecolor = :black, label = "B&B")
    sc_ip = scatter!(ax1, n_ip, count_ips, markersize = markersize, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black, label = "IP")

    @. model_bb(x, p) = p[1] *(x)^p[2] + p[3]
    fit_bb = curve_fit(model_bb, n_bb, count_bbs, [1.0, 1.0, 1.0])
    @. model_ip(x, p) = p[1] * (x)^p[2] + p[3]
    fit_ip = curve_fit(model_ip, n_ip, count_ips, [1.0, 1.0, 1.0])

    @. model_tn(x, p) = p[1] * x + p[2]
    fit_tn = curve_fit(model_tn, n_tn, tc_tns, [1.0, 1.0])

    x_start = 27
    x_end = 53

    xs = range(x_start, x_end, length = 100)

    xlims!(ax0, x_start, x_end)
    xlims!(ax1, x_start, x_end)
    xlims!(ax1_2, x_start, x_end)

    ylims!(ax0, 20, 50)
    ylims!(ax1, 0, 20)
    ylims!(ax1_2, 0, 10)

    lines!(ax0, xs, model_tn(xs, fit_tn.param), color = colors[2], linestyle = :dash)
    lines!(ax1, xs, model_bb(xs, fit_bb.param), color = colors[1], linestyle = :dash)
    lines!(ax1, xs, model_ip(xs, fit_ip.param), color = colors[3], linestyle = :dash)

    # axislegend(ax0, position = :lt, labelsize = 10)
    # axislegend(ax1, position = :lt, labelsize = 10)
    # axislegend(ax1_2, position = :lt, labelsize = 10)

    Legend(fig[1, :], [sc_tn, sc_bb, sc_ip], ["Tropical-TN", "B&B", "SCIP"], position = :lt, labelsize = 15, orientation = :horizontal, nbanks = 1)

    save("../figs/compare_bb_ip.pdf", fig)
    fig
end