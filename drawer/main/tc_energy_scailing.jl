include("../settings.jl")

begin
    t = 15

    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (600, 500), fontsize = 20)

    ax = Axis(fig[1, 1],
        xlabel = L"N", ylabel = L"t.c. \text{ (Flops)}",
        xticks = (30:10:100, [L"30", L"40", L"50", L"60", L"70", L"80", L"90", L"100"]),
        yticks = (0:5:35, [L"10^0", L"10^{5}", L"10^{10}", L"10^{15}",
                           L"10^{20}", L"10^{25}", L"10^{30}", L"10^{35}"]),
        xlabelsize = 26, ylabelsize = 26, xticklabelsize = 22, yticklabelsize = 22,
        xticksize = 8, yticksize = 8,
    )

    n_tn   = [50:10:100...]
    n_ds   = [50:10:100...]
    n_tnbb = [50:10:100...]

    df_tn   = [CSV.read("../../data/main/complexity/random_ksg/original_ksg_n$(n).csv", DataFrame) for n in n_tn]
    df_ds   = [CSV.read("../../data/main/complexity/random_ksg/slice32_rksg_n$(n).csv",  DataFrame) for n in n_ds]
    df_tnbb = [CSV.read("../../data/main/complexity/random_ksg/tnbb_ksg_n$(n).csv",     DataFrame) for n in n_tnbb]

    tc_tn   = log10.(2 .^([geometric_mean(df_tn[i].tc)          for i in 1:length(n_tn)]))
    tc_ds   = log10.(2 .^([geometric_mean(df_ds[i].sliced_tc)   for i in 1:length(n_ds)]))
    tc_tnbb = log10.(2 .^([geometric_mean(df_tnbb[i].total_tc)  for i in 1:length(n_tnbb)]))

    @. model_tn(x, p)   = p[1] * x + p[2]
    fit_tn   = curve_fit(model_tn, n_tn, tc_tn, [1.0, 1.0])
    @. model_ds(x, p)   = p[1] * x^p[2] + p[3]
    fit_ds   = curve_fit(model_ds, n_ds, tc_ds, [1.0, 1.0, 1.0])
    @. model_tnbb(x, p) = p[1] * x + p[2]
    fit_tnbb = curve_fit(model_tnbb, n_tnbb[1:4], tc_tnbb[1:4], [1.0, 1.0])

    xs = range(45, 105, length = 100)

    lines!(ax, xs, model_tn(xs, fit_tn.param),     color = method_colors["TN"],              linestyle = :dash)
    lines!(ax, xs, model_ds(xs, fit_ds.param),     color = method_colors["TN_with_Slicing"], linestyle = :solid)
    lines!(ax, xs, model_tnbb(xs, fit_tnbb.param), color = method_colors["BBTN"],            linestyle = :solid)

    sc_tn   = scatter!(ax, n_tn,   tc_tn,   markersize = t * 1.0, marker = :utriangle,        color = method_colors["TN"],              strokewidth = 1.0, strokecolor = :black)
    sc_ds   = scatter!(ax, n_ds,   tc_ds,   markersize = t * 1.0, marker = markerstyle[3],    color = method_colors["TN_with_Slicing"], strokewidth = 1.0, strokecolor = :black)
    sc_tnbb = scatter!(ax, n_tnbb[1:4], tc_tnbb[1:4], markersize = t * 1.0, marker = markerstyle[2], color = method_colors["BBTN"], strokewidth = 1.0, strokecolor = :black)
    scatter!(ax, n_tnbb[5:end], tc_tnbb[5:end], markersize = t * 1.0, marker = markerstyle[2],
             color = :white, strokewidth = 2, strokecolor = method_colors["BBTN"])

    xlims!(ax, 45, 105)
    ylims!(ax, 0, 35)

    hlines!(ax, [tc_min],           color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax, 46, tc_min,           text = L"$1$ min",      color = :black, fontsize = 22)
    hlines!(ax, [tc_month],         color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax, 46, tc_month,         text = L"$1$ month",    color = :black, fontsize = 22)
    hlines!(ax, [tc_1000000_years], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax, 46, tc_1000000_years, text = L"$10^6$ years", color = :black, fontsize = 22)

    legend_dict = Dict{String, Any}()
    legend_dict["BBTN"]            = sc_tnbb
    legend_dict["TN with Slicing"] = sc_ds
    legend_dict["TN"]              = sc_tn
    labels_order = ["BBTN", "TN with Slicing", "TN"]
    legend_items = [legend_dict[l] for l in labels_order]
    Legend(fig[0, 1], legend_items, labels_order,
           labelsize = 20, orientation = :horizontal,
           nbanks = 1, tellwidth = false, halign = :center)

    save("../../figs/tc_energy_scailing.pdf", fig)
    fig
end
