include("settings.jl")

begin
    fig = Figure(size = (500, 350), fontsize = 20)
    ax1 = Axis(fig[2, 1], xlabel = L"N", ylabel = L"\text{log}_2(\text{tc})", yticklabelcolor = :blue)
    ax1_2 = Axis(fig[2, 1], yticklabelcolor = :red, yaxisposition = :right, ylabel = L"\text{log}_2(N_{bb})", ygridvisible = false)

    hidespines!(ax1_2)
    hidexdecorations!(ax1_2)

    n_bb = [30, 35, 40, 45, 50]
    n_tn = [30:10:100...]
    n_ktn = [50:10:100...]

    df_bbs = [CSV.read("../data/count_vc/ksg_n$(n)_count_vc.csv", DataFrame) for n in n_bb]
    df_tns = [CSV.read("../data/complexity/original_ksg_n$(n).csv", DataFrame) for n in n_tn]
    df_ktns = [CSV.read("../data/complexity/treesa_tn_ksg_n$(n).csv", DataFrame) for n in n_ktn]

    count_bbs = log2.([maximum(df_bbs[i].count_lp) for i in 1:length(n_bb)])
    tc_tns = [geometric_mean(df_tns[i].tc) for i in 1:length(n_tn)]
    tc_ktns = [geometric_mean(df_ktns[i].tc) for i in 1:length(n_ktn)]

    @. model_bb(x, p) = p[1] * x^p[2] + p[3]
    fit_bb = curve_fit(model_bb, n_bb, count_bbs, [1.0, 1.0, 1.0])
    @. model_tn(x, p) = p[1] * x + p[2]
    fit_tn = curve_fit(model_tn, n_tn, tc_tns, [1.0, 1.0])
    @. model_ktn(x, p) = p[1] * x + p[2]
    fit_ktn = curve_fit(model_ktn, n_ktn, tc_ktns, [1.0, 1.0])

    sc_bb = scatter!(ax1_2, n_bb, count_bbs, markersize = markersize, marker = markerstyle[1], color = colors[1], strokewidth = strokewidth, strokecolor = :black, label = "Branch&Bound")
    sc_tn = scatter!(ax1, n_tn, tc_tns, markersize = markersize, marker = markerstyle[2], color = colors[2], strokewidth = strokewidth, strokecolor = :black, label = "Tropical TN")
    sc_ktn = scatter!(ax1, n_ktn, tc_ktns, markersize = markersize, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black, label = "Kernelize + TN")

    xs = range(25, 85, length = 100)

    lines!(ax1_2, xs, model_bb(xs, fit_bb.param), color = colors[1], linestyle = :dash)
    lines!(ax1, xs, model_tn(xs, fit_tn.param), color = colors[2], linestyle = :dash)
    lines!(ax1, xs, model_ktn(xs, fit_ktn.param), color = colors[3], linestyle = :dash)

    n_start = 25
    n_end = 85

    xlims!(ax1, n_start, n_end)
    ylims!(ax1, 0, 80)
    xlims!(ax1_2, n_start, n_end)
    ylims!(ax1_2, 0, 30)

    Legend(fig[1, :], [sc_bb, sc_tn, sc_ktn], ["Branch&Bound", "Tropical TN", "Kernelize + TN"], orientation = :horizontal, nbanks = 1, labelsize = 15)

    save("../figs/compare_bb.pdf", fig)
end

fig